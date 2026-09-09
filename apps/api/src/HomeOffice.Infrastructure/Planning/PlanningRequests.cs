using HomeOffice.Application.Planning;
using HomeOffice.Domain.Planning;
using Microsoft.EntityFrameworkCore;
using static HomeOffice.Domain.Planning.PlanningRules;

namespace HomeOffice.Infrastructure.Planning;

public sealed partial class PlanningService
{
    private async Task ValidateInput(DayInput[]? days, PlanningProfile profile, Guid? parent, CancellationToken ct)
    {
        Require(days is not null && days.All(x => x is not null), "days_required", 400);
        Dates(days!.Select(x => x.LocalDate).ToArray(), await Today(profile.OrganizationId, ct));
        foreach (var d in days)
        {
            Dimensions(d.Location, d.Availability, d.Cancel);
            Require((d.BaseDayId is null) == (d.BasePlanVersion is null) && (!d.Cancel || d.BaseDayId is not null), "base_day_required", 400);
            if (d.BaseDayId is { } baseId)
            {
                Require(parent is not null, "revision_required");
                var source = await db.Set<RequestedDay>().SingleOrDefaultAsync(x => x.Id == baseId && x.EmployeeId == profile.EmployeeId, ct);
                Require(source is not null && source.RequestId == parent && source.LocalDate == d.LocalDate, "invalid_revision_base");
            }
        }
    }
    private async Task ValidateEffective(RequestedDay[] days, CancellationToken ct)
    {
        foreach (var d in days)
        {
            var plan = await db.Set<PlanDay>().SingleOrDefaultAsync(x => x.EmployeeId == d.EmployeeId && x.LocalDate == d.LocalDate, ct);
            if (d.BaseDayId is null) Require(plan is null, "approved_day_requires_revision");
            else Require(plan?.SourceDayId == d.BaseDayId && plan.Version == d.BasePlanVersion, "stale_plan_base", 412);
        }
    }
    private async Task Reserve(PlanningRequest request, CancellationToken ct)
    {
        Dates(request.Days.Select(x => x.LocalDate).ToArray(), await Today(request.OrganizationId, ct));
        await ValidateEffective(request.Days.ToArray(), ct);
        var dates = request.Days.Select(x => x.LocalDate).ToArray();
        Require(!await db.Set<RequestedDay>().AnyAsync(x => x.EmployeeId == request.EmployeeId && x.RequestId != request.Id && x.ReservesDate && dates.Contains(x.LocalDate), ct), "pending_overlap");
        request.SubmittedAt = clock.GetUtcNow(); request.State = RequestState.Submitted;
        foreach (var d in request.Days) { d.ReservesDate = true; d.Decision = DayDecision.Pending; }
    }
    private async Task<PlanningRequest> NewRequest(PlanningProfile p, Guid? parentId, string note, DayInput[] days, CancellationToken ct)
    {
        Text(note, 2000); await ValidateInput(days, p, parentId, ct);
        var r = new PlanningRequest
        {
            OrganizationId = p.OrganizationId,
            EmployeeId = p.EmployeeId,
            ParentRevisionId = parentId,
            Note = note,
            CreatedAt = clock.GetUtcNow()
        };
        if (parentId is { } parent)
        {
            var previous = await LoadRequest(p.EmployeeId, parent, ct);
            Require(previous.State != RequestState.Draft, "parent_not_submitted");
            r.RootId = previous.RootId;
            r.Revision = await db.Set<PlanningRequest>().Where(x => x.RootId == r.RootId).MaxAsync(x => x.Revision, ct) + 1;
        }
        else r.RootId = r.Id;
        SetDays(r, days);
        db.Set<PlanningRequest>().Add(r);
        return r;
    }
    private static void SetDays(PlanningRequest r, DayInput[] days) => r.Days = days.Select(d => new RequestedDay
    {
        OrganizationId = r.OrganizationId,
        EmployeeId = r.EmployeeId,
        RequestId = r.Id,
        LocalDate = d.LocalDate,
        Location = d.Location,
        Availability = d.Availability,
        Cancel = d.Cancel,
        BaseDayId = d.BaseDayId,
        BasePlanVersion = d.BasePlanVersion
    }).ToList();

    public Task<MutationReceipt> Draft(Guid actor, Guid employee, Guid? id, DraftInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Employee, id is null ? "planning.draft-created" : "planning.draft-edited", id, input, key, input.ExpectedCalendarVersion, async p =>
        {
            if (id is null) { var created = await NewRequest(p, input.ParentRevisionId, input.Note, input.Days, ct); return (created.Id, created.Version); }
            var r = await LoadRequest(employee, id.Value, ct); Version(input.ExpectedRequestVersion, r.Version);
            Require(r.State == RequestState.Draft, "submitted_revision_is_frozen");
            Require(r.ParentRevisionId == input.ParentRevisionId, "revision_parent_is_immutable");
            Text(input.Note, 2000); await ValidateInput(input.Days, p, r.ParentRevisionId, ct);
            db.Set<RequestedDay>().RemoveRange(r.Days);
            await SaveIntermediate(ct); // Free draft date keys inside the same rollback-protected transaction.
            SetDays(r, input.Days); db.Set<RequestedDay>().AddRange(r.Days); r.Note = input.Note; r.Version++;
            return (r.Id, r.Version);
        }, ct);

    public Task<MutationReceipt> Submit(Guid actor, Guid employee, Guid id, SubmitInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Employee, "planning.submitted", id, input, key, input.ExpectedCalendarVersion, async _ =>
        {
            var r = await LoadRequest(employee, id, ct); Version(input.ExpectedRequestVersion, r.Version);
            Require(r.State == RequestState.Draft, "request_not_draft");
            if (r.ParentRevisionId is { } parentId)
            {
                var parent = await LoadRequest(employee, parentId, ct);
                var dates = r.Days.Select(d => d.LocalDate).ToHashSet();
                var replaced = parent.Days.Where(d => d.Decision == DayDecision.Pending && dates.Contains(d.LocalDate)).ToArray();
                if (replaced.Length > 0)
                {
                    foreach (var d in replaced) Resolve(d, DayDecision.Superseded, actor, "explicit_linked_revision");
                    parent.State = Summary(parent.Days); parent.Version++;
                    await SaveIntermediate(ct);
                }
            }
            await Reserve(r, ct); r.Version++; return (r.Id, r.Version);
        }, ct);

    public Task<MutationReceipt> Withdraw(Guid actor, Guid employee, Guid id, WithdrawInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Employee, "planning.withdrawn", id, input, key, input.ExpectedCalendarVersion, async _ =>
        {
            var r = await LoadRequest(employee, id, ct); Version(input.ExpectedRequestVersion, r.Version);
            var days = Pending(r, input.Days);
            Dates(days.Select(x => x.LocalDate).ToArray(), await Today(r.OrganizationId, ct));
            foreach (var d in days) Resolve(d, DayDecision.Withdrawn, actor, null);
            r.State = Summary(r.Days); r.Version++; return (r.Id, r.Version);
        }, ct);

    public Task<MutationReceipt> Decide(Guid actor, Guid employee, Guid id, DecisionInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Manager, "planning.decided", id, input, key, input.ExpectedCalendarVersion, async p =>
        {
            var r = await LoadRequest(employee, id, ct); Version(input.ExpectedRequestVersion, r.Version);
            var days = Pending(r, input.Days);
            Text(input.Reason ?? "", 1000, !input.Approve);
            Dates(days.Select(x => x.LocalDate).ToArray(), await Today(r.OrganizationId, ct));
            if (r.AcceptedProposalId is { } proposalId)
            {
                var proposal = await db.Set<ChangeProposal>().SingleAsync(x => x.Id == proposalId, ct);
                Require(proposal.State == ProposalState.Accepted && await db.Set<ProposalAcknowledgement>().AnyAsync(x => x.ProposalId == proposalId && x.EmployeeId == employee && x.Revision == proposal.Revision, ct), "proposal_acknowledgement_required");
            }
            if (input.Approve) await ValidateEffective(days, ct); // Validate the complete selection before mutating anything.
            var changedSources = new HashSet<Guid>();
            foreach (var d in days)
            {
                if (input.Approve)
                {
                    var plan = await db.Set<PlanDay>().SingleOrDefaultAsync(x => x.EmployeeId == employee && x.LocalDate == d.LocalDate, ct);
                    if (plan is not null)
                    {
                        var original = await db.Set<RequestedDay>().SingleAsync(x => x.Id == plan.SourceDayId, ct);
                        // Keep the original approval's actor, timestamp and reason; its replacement has its own decision.
                        original.Decision = d.Cancel ? DayDecision.Cancelled : DayDecision.Superseded;
                        original.Version++;
                        changedSources.Add(original.RequestId);
                    }
                    if (d.Cancel) db.Set<PlanDay>().Remove(plan!);
                    else
                    {
                        if (plan is null) { plan = new() { OrganizationId = p.OrganizationId, EmployeeId = employee, LocalDate = d.LocalDate }; db.Set<PlanDay>().Add(plan); }
                        plan.Location = d.Location; plan.Availability = d.Availability; plan.SourceDayId = d.Id;
                        plan.Version = p.CalendarVersion; plan.DecidedBy = actor;
                    }
                }
                Resolve(d, input.Approve ? d.Cancel ? DayDecision.Cancelled : DayDecision.Approved : DayDecision.Rejected, actor, input.Reason);
            }
            foreach (var sourceId in changedSources) { var source = await LoadRequest(employee, sourceId, ct); source.Version++; }
            r.State = Summary(r.Days); r.Version++; return (r.Id, r.Version);
        }, ct);

    public Task<MutationReceipt> Pattern(Guid actor, Guid employee, PatternInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Employee, "planning.pattern-changed", null, input, key, input.ExpectedCalendarVersion, async p =>
        {
            Dates([input.EffectiveFrom], await Today(p.OrganizationId, ct));
            Require(input.Locations is { Length: 7 } && input.Locations.All(Enum.IsDefined), "invalid_weekly_pattern", 400);
            // Append-only effective dates preserve earlier inferred history, including earlier future versions.
            var latest = await db.Set<WeeklyPattern>().Where(x => x.EmployeeId == employee).MaxAsync(x => (DateOnly?)x.EffectiveFrom, ct);
            Require(latest is null || input.EffectiveFrom > latest, "pattern_effective_date_must_advance");
            var pattern = new WeeklyPattern { EmployeeId = employee, OrganizationId = p.OrganizationId, EffectiveFrom = input.EffectiveFrom, Locations = input.Locations!, Version = p.CalendarVersion };
            db.Set<WeeklyPattern>().Add(pattern); return (pattern.Id, pattern.Version);
        }, ct);

    public Task<MutationReceipt> Comment(Guid actor, Guid employee, Guid request, CommentInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Read, "planning.commented", request, input, key, input.ExpectedCalendarVersion, async p =>
        {
            var r = await LoadRequest(employee, request, ct); Visible(r, actor); Text(input.Text, 2000, true);
            if (input.ProposalId is { } proposal) Require(await db.Set<ChangeProposal>().AnyAsync(x => x.Id == proposal && x.RequestId == request && x.EmployeeId == employee, ct), "proposal_not_found", 404);
            var comment = new PlanningComment
            {
                OrganizationId = p.OrganizationId,
                EmployeeId = employee,
                RequestId = request,
                ProposalId = input.ProposalId,
                AuthorId = actor,
                Text = input.Text,
                CreatedAt = clock.GetUtcNow()
            };
            db.Set<PlanningComment>().Add(comment); return (comment.Id, 1L);
        }, ct);
}
