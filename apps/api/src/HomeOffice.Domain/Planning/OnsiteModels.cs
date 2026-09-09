namespace HomeOffice.Domain.Planning;

public enum OnsiteState { Active, NeedsResolution, Cancelled }
public enum AssignedTaskState { Todo, InProgress, Done, Cancelled }
public enum WorkContext { Requirement, Task }

public sealed class OnsiteRequirement
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid OrganizationId { get; set; }
    public Guid EmployeeId { get; set; }
    public DateOnly From { get; set; }
    public DateOnly To { get; set; }
    public string Reason { get; set; } = "";
    public string Location { get; set; } = "";
    public string Reference { get; set; } = "";
    public OnsiteState State { get; set; }
    public int Revision { get; set; } = 1;
    public long Version { get; set; } = 1;
    public Guid CreatedBy { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}

public sealed class OnsiteAcknowledgement
{
    public Guid RequirementId { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid EmployeeId { get; set; }
    public int Revision { get; set; }
    public DateTimeOffset ReadAt { get; set; }
}

public sealed class AssignedTask
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid OrganizationId { get; set; }
    public Guid EmployeeId { get; set; }
    public string Title { get; set; } = "";
    public string Description { get; set; } = "";
    public DateOnly Deadline { get; set; }
    public AssignedTaskState State { get; set; }
    public bool RequiresOnsite { get; set; }
    public Guid? RequirementId { get; set; }
    public string ProgressNote { get; set; } = "";
    public long Version { get; set; } = 1;
    public DateTimeOffset CreatedAt { get; set; }
}

// Authorized context history and comments; no notification delivery or external payloads.
public sealed class WorkEntry
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid OrganizationId { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid? RequirementId { get; set; }
    public Guid? TaskId { get; set; }
    public Guid AuthorId { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public string Action { get; set; } = "";
    public string Text { get; set; } = "";
    public string SnapshotJson { get; set; } = "{}";
    public long CalendarVersion { get; set; }
}
