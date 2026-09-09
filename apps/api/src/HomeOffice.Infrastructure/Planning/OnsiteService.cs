using System.Text.Json;
using HomeOffice.Application.Planning;
using HomeOffice.Domain.Planning;
using Microsoft.EntityFrameworkCore;
using static HomeOffice.Domain.Planning.PlanningRules;

namespace HomeOffice.Infrastructure.Planning;

public sealed partial class PlanningService
{
    private async Task<OnsiteRequirement> LoadRequirement(Guid employee, Guid id, CancellationToken ct)
    {
        var r = await db.Set<OnsiteRequirement>().SingleOrDefaultAsync(x => x.EmployeeId == employee && x.Id == id, ct);
        Require(r is not null, "requirement_not_found", 404); return r!;
    }
    private async Task<OnsiteView> OnsiteViewOf(OnsiteRequirement r, CancellationToken ct) => new(r.Id, r.EmployeeId,
        r.From, r.To, r.Reason, r.Location, r.Reference, r.State, r.Revision, r.Version,
        await db.Set<OnsiteAcknowledgement>().Where(a => a.RequirementId == r.Id && a.Revision == r.Revision).Select(a => (DateTimeOffset?)a.ReadAt).SingleOrDefaultAsync(ct));

    private void WorkHistory(PlanningProfile p, Guid actor, WorkContext kind, Guid id, string action, object snapshot, string text = "") =>
        db.Set<WorkEntry>().Add(new()
        {
            OrganizationId = p.OrganizationId,
            EmployeeId = p.EmployeeId,
            AuthorId = actor,
            RequirementId = kind == WorkContext.Requirement ? id : null,
            TaskId = kind == WorkContext.Task ? id : null,
            CreatedAt = clock.GetUtcNow(),
            Action = action,
            Text = text,
            SnapshotJson = JsonSerializer.Serialize(snapshot, Json),
            CalendarVersion = p.CalendarVersion
        });

    private async Task<OnsiteConflict[]> OnsiteConflicts(Guid employee, DateOnly from, DateOnly to, string location, Guid? excludes, CancellationToken ct)
    {
        var plans = await db.Set<PlanDay>().Where(x => x.EmployeeId == employee && x.LocalDate >= from && x.LocalDate <= to &&
            (x.Location != WorkLocation.OfficeSwitzerland || x.Availability != Availability.Working)).ToArrayAsync(ct);
        var sources = plans.Select(x => x.SourceDayId).ToArray();
        var requests = await db.Set<RequestedDay>().Where(x => x.EmployeeId == employee && sources.Contains(x.Id)).ToDictionaryAsync(x => x.Id, x => x.RequestId, ct);
        var pending = await db.Set<RequestedDay>().Where(x => x.EmployeeId == employee && x.ReservesDate && x.LocalDate >= from && x.LocalDate <= to).ToArrayAsync(ct);
        var others = await db.Set<OnsiteRequirement>().Where(x => x.EmployeeId == employee && x.Id != excludes && x.State != OnsiteState.Cancelled && x.From <= to && x.To >= from).ToArrayAsync(ct);
        var result = plans.Select(x => new OnsiteConflict(x.LocalDate, x.Availability == Availability.Working ? "approved_remote" : "approved_unavailability", x.SourceDayId, requests[x.SourceDayId])).ToList();
        result.AddRange(pending.Select(x => new OnsiteConflict(x.LocalDate, "pending_request", x.Id, x.RequestId)));
        foreach (var other in others)
        {
            var incompatible = other.State == OnsiteState.Active && !string.Equals(other.Location.Trim(), location.Trim(), StringComparison.OrdinalIgnoreCase);
            result.AddRange(Expand(from > other.From ? from : other.From, to < other.To ? to : other.To, true)
                .Select(date => new OnsiteConflict(date, incompatible ? "different_onsite_location" : "other_requirement", other.Id, null)));
        }
        return result.OrderBy(x => x.LocalDate).ThenBy(x => x.Code).ThenBy(x => x.ContextId).ToArray();
    }
    private static OnsiteState ConflictState(OnsiteConflict[] conflicts) => conflicts.Any(x => x.Code is "approved_remote" or "approved_unavailability" or "different_onsite_location")
        ? OnsiteState.NeedsResolution : OnsiteState.Active;

    public Task<OnsitePreview> PreviewOnsite(Guid actor, Guid employee, DateOnly from, DateOnly to, string location, Guid? excludes, CancellationToken ct) => Read(actor, employee, async () =>
    {
        Text(location, 200, true);
        var member = await Authorize(actor, employee, Permission.Read, false, ct);
        Dates(Expand(from, to, true), await Today(member.OrganizationId, ct));
        if (excludes is { } id) await LoadRequirement(employee, id, ct);
        var conflicts = await OnsiteConflicts(employee, from, to, location, excludes, ct);
        return new OnsitePreview(await CalendarVersion(employee, ct), ConflictState(conflicts), conflicts);
    }, ct);

    public Task<OnsitePage> Requirements(Guid actor, Guid employee, int offset, int limit, OnsiteState? state, CancellationToken ct) => Read(actor, employee, async () =>
    {
        Page(offset, limit); Require(state is null || Enum.IsDefined(state.Value), "invalid_onsite_state", 400);
        var rows = await db.Set<OnsiteRequirement>().Where(x => x.EmployeeId == employee && (state == null || x.State == state))
            .OrderByDescending(x => x.CreatedAt).ThenBy(x => x.Id).Skip(offset).Take(limit + 1).ToArrayAsync(ct);
        var views = new List<OnsiteView>(); foreach (var r in rows.Take(limit)) views.Add(await OnsiteViewOf(r, ct));
        return new OnsitePage(views.ToArray(), rows.Length > limit ? offset + limit : null, await CalendarVersion(employee, ct));
    }, ct);
    public Task<OnsiteView> Requirement(Guid actor, Guid employee, Guid id, CancellationToken ct) =>
        Read(actor, employee, async () => await OnsiteViewOf(await LoadRequirement(employee, id, ct), ct), ct);

    public Task<MutationReceipt> SaveRequirement(Guid actor, Guid employee, Guid? id, OnsiteInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Manager, id is null ? "onsite.created" : "onsite.edited", id, input, key, input.ExpectedCalendarVersion, async p =>
        {
            Text(input.Reason, 1000, true); Text(input.Location, 200, true); Text(input.Reference, 200);
            var today = await Today(p.OrganizationId, ct); Dates(Expand(input.From, input.To, true), today);
            OnsiteRequirement r;
            if (id is { } existing)
            {
                r = await LoadRequirement(employee, existing, ct); Version(input.ExpectedVersion, r.Version);
                Require(r.State != OnsiteState.Cancelled, "requirement_cancelled"); Dates(Expand(r.From, r.To, true), today);
                r.Revision++; r.Version++;
            }
            else
            {
                r = new() { OrganizationId = p.OrganizationId, EmployeeId = employee, CreatedBy = actor, CreatedAt = clock.GetUtcNow() };
                db.Set<OnsiteRequirement>().Add(r);
            }
            r.From = input.From; r.To = input.To; r.Reason = input.Reason.Trim(); r.Location = input.Location.Trim(); r.Reference = input.Reference.Trim();
            r.State = ConflictState(await OnsiteConflicts(employee, r.From, r.To, r.Location, r.Id, ct));
            WorkHistory(p, actor, WorkContext.Requirement, r.Id, id is null ? "onsite.created" : "onsite.edited", r);
            return (r.Id, r.Version);
        }, ct);

    public Task<MutationReceipt> CancelRequirement(Guid actor, Guid employee, Guid id, WorkVersionInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Manager, "onsite.cancelled", id, input, key, input.ExpectedCalendarVersion, async p =>
        {
            var r = await LoadRequirement(employee, id, ct); Version(input.ExpectedVersion, r.Version);
            Require(r.State != OnsiteState.Cancelled, "requirement_cancelled"); Dates(Expand(r.From, r.To, true), await Today(p.OrganizationId, ct));
            r.State = OnsiteState.Cancelled; r.Version++; r.Revision++;
            WorkHistory(p, actor, WorkContext.Requirement, id, "onsite.cancelled", r);
            return (r.Id, r.Version);
        }, ct);

    public Task<MutationReceipt> AcknowledgeRequirement(Guid actor, Guid employee, Guid id, OnsiteAcknowledgeInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Employee, "onsite.read", id, input, key, input.ExpectedCalendarVersion, async p =>
        {
            var r = await LoadRequirement(employee, id, ct); Version(input.ExpectedVersion, r.Version); Version(input.Revision, r.Revision);
            Require(r.State != OnsiteState.Cancelled, "requirement_cancelled");
            Require(!await db.Set<OnsiteAcknowledgement>().AnyAsync(x => x.RequirementId == id && x.Revision == r.Revision, ct), "already_acknowledged");
            db.Set<OnsiteAcknowledgement>().Add(new() { OrganizationId = p.OrganizationId, EmployeeId = employee, RequirementId = id, Revision = r.Revision, ReadAt = clock.GetUtcNow() });
            r.Version++; WorkHistory(p, actor, WorkContext.Requirement, id, "onsite.read", new { r.Revision, r.Version });
            return (r.Id, r.Version);
        }, ct);

    // Run after explicit changes are saved, under the SAME profile lock and transaction.
    // No PlanDay is written/restored by requirement changes; only current facts determine activation.
    private async Task ReconcileRequirements(PlanningProfile p, Guid actor, CancellationToken ct)
    {
        var today = await Today(p.OrganizationId, ct);
        var rows = await db.Set<OnsiteRequirement>().Where(x => x.EmployeeId == p.EmployeeId && x.State != OnsiteState.Cancelled && x.To >= today)
            .OrderBy(x => x.CreatedAt).ThenBy(x => x.Id).ToArrayAsync(ct);
        foreach (var r in rows)
        {
            var next = ConflictState(await OnsiteConflicts(p.EmployeeId, r.From, r.To, r.Location, r.Id, ct));
            if (r.State == next) continue;
            r.State = next; r.Version++;
            WorkHistory(p, actor, WorkContext.Requirement, r.Id, "onsite.revalidated", r);
            await SaveIntermediate(ct); // Later overlapping requirements observe the newly active one.
        }
    }

    private async Task ValidateOnsiteDecision(Guid employee, RequestedDay[] days, CancellationToken ct)
    {
        foreach (var d in days.Where(d => !d.Cancel && (d.Location != WorkLocation.OfficeSwitzerland || d.Availability != Availability.Working)))
            Require(!await db.Set<OnsiteRequirement>().AnyAsync(x => x.EmployeeId == employee && x.State == OnsiteState.Active && x.From <= d.LocalDate && x.To >= d.LocalDate, ct), "active_onsite_conflict");
    }
    private async Task ValidateRequirementRevision(Guid employee, Guid? id, int? revision, CancellationToken ct)
    {
        Require((id is null) == (revision is null), "requirement_revision_required", 400);
        if (id is not { } requirementId) return;
        var r = await LoadRequirement(employee, requirementId, ct);
        Version(revision, r.Revision); Require(r.State != OnsiteState.Cancelled, "requirement_cancelled");
    }
}
