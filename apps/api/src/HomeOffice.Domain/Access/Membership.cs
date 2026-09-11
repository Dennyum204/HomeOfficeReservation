namespace HomeOffice.Domain.Access;

public sealed class Organization
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = "";
    public string PlanningTimeZone { get; set; } = "Europe/Zurich";
}

public sealed class Member
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid OrganizationId { get; set; }
    public string IdentityUserId { get; set; } = "";
    public string DisplayName { get; set; } = "";
    public bool Active { get; set; } = true;
    public bool IsEmployee { get; set; }
    public bool IsManager { get; set; }
    public bool IsAccountAdministrator { get; set; }
    public long AccessVersion { get; set; }
}

public sealed class ReportingLine
{
    public Guid OrganizationId { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid ManagerId { get; set; }
}

public static class AccessRules
{
    // Shared by member reads and the transactional planning decision use case.
    public static bool CanManage(Member actor, Member employee, ReportingLine? line) =>
        actor.Active && employee.Active && actor.IsManager && employee.IsEmployee &&
        actor.Id != employee.Id && actor.OrganizationId == employee.OrganizationId &&
        line?.OrganizationId == actor.OrganizationId && line.ManagerId == actor.Id && line.EmployeeId == employee.Id;

    public static bool CanAdminister(Member actor, Member target) =>
        actor.Active && actor.IsAccountAdministrator && actor.OrganizationId == target.OrganizationId;
}
