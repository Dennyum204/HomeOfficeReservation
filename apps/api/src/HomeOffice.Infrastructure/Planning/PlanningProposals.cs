using System.Text.Json;
using HomeOffice.Application.Planning;
using HomeOffice.Domain.Planning;
using Microsoft.EntityFrameworkCore;
using static HomeOffice.Domain.Planning.PlanningRules;

namespace HomeOffice.Infrastructure.Planning;

public sealed partial class PlanningService
{
    public Task<MutationReceipt> Propose(Guid actor, Guid employee, Guid request, Guid? replaces, ProposalInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Manager, "planning.counterproposed", replaces, new { request, input }, key, input.ExpectedCalendarVersion, async p =>
        {
            var r = await LoadRequest(employee, request, ct); Visible(r, actor); Version(input.ExpectedRequestVersion, r.Version);
            Text(input.Reason, 1000, true); await ValidateInput(input.Days, p, request, ct);
            ChangeProposal? previous = null;
            if (replaces is { } priorId)
            {
                previous = await db.Set<ChangeProposal>().SingleOrDefaultAsync(x => x.Id == priorId && x.RequestId == request && x.EmployeeId == employee, ct);
                Require(previous is not null, "proposal_not_found", 404);
                Require(previous!.State != ProposalState.Superseded, "proposal_superseded");
                if (previous.AcceptedRequestId is { } accepted)
                {
                    var priorRequest = await LoadRequest(employee, accepted, ct);
                    Require(priorRequest.Days.All(d => d.Decision == DayDecision.Pending), "accepted_proposal_already_resolved");
                    foreach (var d in priorRequest.Days) Resolve(d, DayDecision.Superseded, actor, input.Reason);
                    priorRequest.State = RequestState.Closed; priorRequest.Version++;
                }
                previous.State = ProposalState.Superseded;
            }
            var affected = Selection(input.AffectedDays).Select(s =>
            {
                var d = r.Days.SingleOrDefault(d => d.Id == s.DayId);
                Require(d is not null, "invalid_affected_day"); Version(s.ExpectedVersion, d!.Version);
                Require(d.Decision is DayDecision.Pending or DayDecision.Approved ||
                    d.Decision == DayDecision.Superseded && previous?.AcceptedRequestId is not null && previous.AffectedDayIds.Contains(d.Id), "invalid_affected_day");
                return d;
            }).ToArray();
            Dates(affected.Select(d => d.LocalDate).ToArray(), await Today(p.OrganizationId, ct));
            foreach (var d in affected.Where(d => d.Decision == DayDecision.Approved))
                Require(input.Days.Any(x => x.BaseDayId == d.Id), "approved_replacement_must_be_explicit");
            foreach (var d in input.Days.Where(d => d.BaseDayId is not null))
                Require(affected.Any(a => a.Id == d.BaseDayId && a.Decision == DayDecision.Approved), "invalid_proposal_base");
            var proposal = new ChangeProposal
            {
                EmployeeId = employee,
                OrganizationId = p.OrganizationId,
                RequestId = request,
                AuthorId = actor,
                Reason = input.Reason,
                CreatedAt = clock.GetUtcNow(),
                AffectedDayIds = affected.Select(x => x.Id).ToArray(),
                AffectedDayVersions = affected.Select(x => x.Version).ToArray(),
                DaysJson = JsonSerializer.Serialize(input.Days, Json),
                Revision = (previous?.Revision ?? 0) + 1
            };
            proposal.GroupId = previous?.GroupId ?? proposal.Id;
            db.Set<ChangeProposal>().Add(proposal);
            return (proposal.Id, proposal.Revision);
        }, ct);

    public Task<MutationReceipt> Accept(Guid actor, Guid employee, Guid proposalId, AcceptProposalInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Employee, "planning.counterproposal-accepted", proposalId, input, key, input.ExpectedCalendarVersion, async p =>
        {
            var proposal = await db.Set<ChangeProposal>().SingleOrDefaultAsync(x => x.EmployeeId == employee && x.Id == proposalId, ct);
            Require(proposal is not null, "proposal_not_found", 404);
            Version(input.ExpectedProposalRevision, proposal!.Revision);
            Require(proposal.State == ProposalState.Open, "proposal_not_open");
            var parent = await LoadRequest(employee, proposal.RequestId, ct);
            for (var i = 0; i < proposal.AffectedDayIds.Length; i++)
            {
                var day = parent.Days.Single(x => x.Id == proposal.AffectedDayIds[i]);
                Version(proposal.AffectedDayVersions[i], day.Version);
                if (day.Decision == DayDecision.Pending) Resolve(day, DayDecision.Superseded, actor, "counterproposal_accepted");
            }
            parent.Version++; parent.State = Summary(parent.Days);
            // Release replaced pending reservations before inserting the new revision; rollback covers both saves.
            await SaveIntermediate(ct);
            var r = await NewRequest(p, parent.Id, proposal.Reason, JsonSerializer.Deserialize<DayInput[]>(proposal.DaysJson, Json)!, ct);
            r.AcceptedProposalId = proposal.Id;
            await Reserve(r, ct);
            proposal.AcceptedRequestId = r.Id; proposal.State = ProposalState.Accepted;
            db.Set<ProposalAcknowledgement>().Add(new()
            {
                OrganizationId = p.OrganizationId,
                EmployeeId = employee,
                ProposalId = proposal.Id,
                Revision = proposal.Revision,
                AcknowledgedAt = clock.GetUtcNow()
            });
            return (r.Id, r.Version);
        }, ct);
}
