using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Access;

public sealed class MemberDirectory(HomeOfficeDbContext db) : IMemberDirectory
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
        var target = await db.Members.SingleOrDefaultAsync(x => x.Id == memberId);
        if (target is null || !AccessRules.CanAdminister(actor, target)) return new(false, "forbidden");
        // Account administrators cannot lock themselves out or alter their own privileges through this endpoint.
        if (actor.Id == target.Id) return new(false, "self_administration_denied");
        target.Active = request.Active;
        target.IsEmployee = request.IsEmployee;
        target.IsManager = request.IsManager;
        target.IsAccountAdministrator = request.IsAccountAdministrator;
        await db.SaveChangesAsync();
        return new(true, "updated");
    }

    public async Task<OperationResult> AssignManagerAsync(Member actor, Guid employeeId, Guid managerId)
    {
        var employee = await db.Members.SingleOrDefaultAsync(x => x.Id == employeeId);
        var manager = await db.Members.SingleOrDefaultAsync(x => x.Id == managerId);
        if (employee is null || manager is null || !AccessRules.CanAdminister(actor, employee) ||
            !AccessRules.CanAdminister(actor, manager)) return new(false, "forbidden");
        if (!employee.Active || !manager.Active || !employee.IsEmployee || !manager.IsManager || employee.Id == manager.Id)
            return new(false, "invalid_relationship");
        var line = await db.ReportingLines.SingleOrDefaultAsync(x => x.EmployeeId == employeeId);
        if (line is null) db.ReportingLines.Add(new() { OrganizationId = actor.OrganizationId, EmployeeId = employeeId, ManagerId = managerId });
        else line.ManagerId = managerId;
        await db.SaveChangesAsync();
        return new(true, "assigned");
    }
}
