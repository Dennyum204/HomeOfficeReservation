using HomeOffice.Domain.Access;
using HomeOffice.Domain.Notifications;
using HomeOffice.Domain.Planning;
using HomeOffice.Application.Notifications;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Notifications;

public sealed class NotificationAccess(HomeOfficeDbContext db)
{
    // Filter before pagination/counting; account administration is not planning authority.
    public IQueryable<InboxNotification> Visible(Guid actor) => db.Set<InboxNotification>().Where(n =>
        n.RecipientId == actor &&
        db.Members.Any(e => e.Id == n.EmployeeId && e.OrganizationId == n.OrganizationId && e.Active && e.IsEmployee) &&
        db.Members.Any(r => r.Id == actor && r.Active && r.OrganizationId == n.OrganizationId &&
            (r.Id == n.EmployeeId && r.IsEmployee || r.IsManager && r.Id != n.EmployeeId &&
                db.ReportingLines.Any(l => l.OrganizationId == n.OrganizationId && l.EmployeeId == n.EmployeeId && l.ManagerId == actor))));

    public async Task<bool> CanAccess(Guid actor, Guid employee, Guid org, CancellationToken ct)
    {
        var people = await db.Members.AsNoTracking().Where(m => (m.Id == actor || m.Id == employee) && m.OrganizationId == org).ToArrayAsync(ct);
        var recipient = people.SingleOrDefault(m => m.Id == actor);
        var target = people.SingleOrDefault(m => m.Id == employee);
        if (recipient?.Active != true || target?.Active != true || !target.IsEmployee) return false;
        if (actor == employee) return recipient.IsEmployee;
        return AccessRules.CanManage(recipient, target, await db.ReportingLines.AsNoTracking().SingleOrDefaultAsync(l => l.EmployeeId == employee, ct));
    }

    public async Task<NotificationDestination?> Destination(InboxNotification n, CancellationToken ct)
    {
        var employee = n.EmployeeId; var org = n.OrganizationId;
        switch (n.Context)
        {
            case NotificationContext.Request:
                if (await db.Set<PlanningRequest>().AnyAsync(r => r.Id == n.ContextId && r.EmployeeId == employee && r.OrganizationId == org && r.State != RequestState.Draft, ct))
                    return new(NotificationContext.Request, employee, n.ContextId, null);
                break;
            case NotificationContext.Proposal:
                var proposal = await db.Set<ChangeProposal>().AsNoTracking().SingleOrDefaultAsync(p => p.Id == n.ContextId && p.EmployeeId == employee && p.OrganizationId == org, ct);
                if (proposal is not null && await db.Set<PlanningRequest>().AnyAsync(r => r.Id == proposal.RequestId && r.State != RequestState.Draft, ct))
                    return new(NotificationContext.Request, employee, proposal.RequestId, proposal.Id);
                break;
            case NotificationContext.Requirement:
                if (await db.Set<OnsiteRequirement>().AnyAsync(r => r.Id == n.ContextId && r.EmployeeId == employee && r.OrganizationId == org, ct))
                    return new(NotificationContext.Requirement, employee, n.ContextId, null);
                break;
            case NotificationContext.Task:
                if (await db.Set<AssignedTask>().AnyAsync(t => t.Id == n.ContextId && t.EmployeeId == employee && t.OrganizationId == org, ct))
                    return new(NotificationContext.Task, employee, n.ContextId, null);
                break;
        }
        return null;
    }
}
