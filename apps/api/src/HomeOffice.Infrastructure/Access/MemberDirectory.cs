using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Access;

public sealed class MemberDirectory(HomeOfficeDbContext db, TimeProvider clock, InvitationService invitations) : IMemberDirectory
{
    public Task<Member?> CurrentAsync(string identityUserId) =>
        db.Members.AsNoTracking().SingleOrDefaultAsync(m => m.IdentityUserId == identityUserId);

    private IQueryable<MemberProfile> Profiles(IQueryable<Member> members) =>
        from member in members.AsNoTracking()
        join organization in db.Organizations on member.OrganizationId equals organization.Id
        join user in db.Users on member.IdentityUserId equals user.Id
        select new MemberProfile(member.Id, organization.Id, organization.Name, member.DisplayName,
            user.Email!, member.Active, member.IsEmployee, member.IsManager, member.IsAccountAdministrator);

    public async Task<MemberProfile?> ProfileAsync(Member actor, Guid memberId, bool managementOnly = false)
    {
        var target = await db.Members.AsNoTracking().SingleOrDefaultAsync(x => x.Id == memberId);
        if (target is null || !actor.Active || target.OrganizationId != actor.OrganizationId) return null;
        var line = await db.ReportingLines.AsNoTracking().SingleOrDefaultAsync(x => x.EmployeeId == memberId);
        var manages = AccessRules.CanManage(actor, target, line);
        if (managementOnly ? !manages : actor.Id != target.Id && !AccessRules.CanAdminister(actor, target) && !manages) return null;
        return await Profiles(db.Members.Where(x => x.Id == memberId)).SingleAsync();
    }

    public async Task<MemberList> ListAsync(Member actor)
    {
        if (!actor.Active) return new([]);
        var allowed = db.Members.Where(m => m.OrganizationId == actor.OrganizationId &&
            (m.Id == actor.Id || actor.IsAccountAdministrator ||
                actor.IsManager && m.Active && m.IsEmployee && db.ReportingLines.Any(l =>
                    l.OrganizationId == actor.OrganizationId && l.ManagerId == actor.Id && l.EmployeeId == m.Id)))
            .OrderBy(m => m.DisplayName).Take(100);
        return new(await Profiles(allowed).ToArrayAsync());
    }

    public async Task<OperationResult> UpdateAsync(Member actor, Guid memberId, UpdateMemberRequest request)
    {
        await using var tx = await db.Database.BeginTransactionAsync();
        if (!await AccessChanges.LockOrganization(db, actor.OrganizationId) ||
            await AccessChanges.Administrator(db, actor) is null) return new(false, "forbidden");
        var target = await db.Members.SingleOrDefaultAsync(x => x.Id == memberId);
        if (target is not null) await db.Entry(target).ReloadAsync();
        if (target is null || !AccessRules.CanAdminister(actor, target)) return new(false, "forbidden");
        // Account administrators cannot lock themselves out or alter their own privileges through this endpoint.
        if (actor.Id == target.Id) return new(false, "self_administration_denied");
        if (target.Active && target.IsAccountAdministrator && !(request.Active && request.IsAccountAdministrator) &&
            !await db.Members.AnyAsync(m => m.OrganizationId == target.OrganizationId && m.Id != target.Id && m.Active && m.IsAccountAdministrator))
            return new(false, "last_active_administrator");
        var before = AccessChanges.State(target);
        if (request.Active && await db.Set<AccessInvitation>().AnyAsync(i => i.MemberId == target.Id && i.State == InvitationState.Cancelled))
            return new(false, "invitation_cancelled");
        if (!request.Active) await invitations.CancelPending(target, actor.Id);
        target.Active = request.Active;
        target.IsEmployee = request.IsEmployee;
        target.IsManager = request.IsManager;
        target.IsAccountAdministrator = request.IsAccountAdministrator;
        if (before != AccessChanges.State(target))
            AccessChanges.Record(db, clock, target, actor.Id, "access.member_updated", before, AccessChanges.State(target));
        await db.SaveChangesAsync();
        await tx.CommitAsync();
        return new(true, "updated");
    }

    public async Task<OperationResult> AssignManagerAsync(Member actor, Guid employeeId, Guid managerId)
    {
        await using var tx = await db.Database.BeginTransactionAsync();
        if (!await AccessChanges.LockOrganization(db, actor.OrganizationId) ||
            await AccessChanges.Administrator(db, actor) is null) return new(false, "forbidden");
        var employee = await db.Members.AsNoTracking().SingleOrDefaultAsync(x => x.Id == employeeId);
        var manager = await db.Members.AsNoTracking().SingleOrDefaultAsync(x => x.Id == managerId);
        if (employee is null || manager is null || !AccessRules.CanAdminister(actor, employee) ||
            !AccessRules.CanAdminister(actor, manager)) return new(false, "forbidden");
        if (!employee.Active || !manager.Active || !employee.IsEmployee || !manager.IsManager || employee.Id == manager.Id)
            return new(false, "invalid_relationship");
        var line = await db.ReportingLines.SingleOrDefaultAsync(x => x.EmployeeId == employeeId);
        if (line is not null) await db.Entry(line).ReloadAsync();
        var previousManager = line?.ManagerId;
        if (line is null) db.ReportingLines.Add(new() { OrganizationId = actor.OrganizationId, EmployeeId = employeeId, ManagerId = managerId });
        else line.ManagerId = managerId;
        if (previousManager != managerId)
            AccessChanges.Record(db, clock, employee, actor.Id, "access.manager_assigned", new { managerId = previousManager }, new { managerId });
        await db.SaveChangesAsync();
        await tx.CommitAsync();
        return new(true, "assigned");
    }
}
