namespace HomeOffice.Domain.Planning;

public enum WorkLocation { Unplanned, OfficeSwitzerland, RemotePortugal }
public enum Availability { Working, Leave, Unavailable }
public enum RequestState { Draft, Submitted, Closed, Withdrawn }
public enum DayDecision { Pending, Approved, Rejected, Withdrawn, Superseded, Cancelled }
public enum ProposalState { Open, Accepted, Superseded }

public sealed class PlanningProfile
{
    public Guid EmployeeId { get; set; }
    public Guid OrganizationId { get; set; }
    public long CalendarVersion { get; set; }
}

public sealed class WeeklyPattern
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid EmployeeId { get; set; }
    public Guid OrganizationId { get; set; }
    public DateOnly EffectiveFrom { get; set; }
    // ISO Monday=1 .. Sunday=7; explicit seven entries, persisted as integers.
    public WorkLocation[] Locations { get; set; } = [];
    public long Version { get; set; }
}

public sealed class PlanningRequest
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid EmployeeId { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid RootId { get; set; }
    public Guid? ParentRevisionId { get; set; }
    public int Revision { get; set; } = 1;
    public long Version { get; set; } = 1;
    public RequestState State { get; set; }
    public string Note { get; set; } = "";
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? SubmittedAt { get; set; }
    public Guid? AcceptedProposalId { get; set; }
    public List<RequestedDay> Days { get; set; } = [];
}

public sealed class RequestedDay
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid RequestId { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid OrganizationId { get; set; }
    public DateOnly LocalDate { get; set; }
    public WorkLocation Location { get; set; }
    public Availability Availability { get; set; }
    public bool Cancel { get; set; }
    public Guid? BaseDayId { get; set; }
    public long? BasePlanVersion { get; set; }
    public DayDecision Decision { get; set; }
    // Draft days do not reserve dates. Unique partial index protects submitted Pending dates.
    public bool ReservesDate { get; set; }
    public string? Reason { get; set; }
    public Guid? DecidedBy { get; set; }
    public DateTimeOffset? DecidedAt { get; set; }
    public long Version { get; set; } = 1;
}

public sealed class PlanDay
{
    public Guid EmployeeId { get; set; }
    public Guid OrganizationId { get; set; }
    public DateOnly LocalDate { get; set; }
    public WorkLocation Location { get; set; }
    public Availability Availability { get; set; }
    public Guid SourceDayId { get; set; }
    public Guid DecidedBy { get; set; }
    public long Version { get; set; }
}

public sealed class ChangeProposal
{
    public Guid? RequirementId { get; set; }
    public int? RequirementRevision { get; set; }
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid GroupId { get; set; }
    public int Revision { get; set; } = 1;
    public Guid EmployeeId { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid RequestId { get; set; }
    public Guid AuthorId { get; set; }
    public string Reason { get; set; } = "";
    public Guid[] AffectedDayIds { get; set; } = [];
    public long[] AffectedDayVersions { get; set; } = [];
    public string DaysJson { get; set; } = "[]";
    public ProposalState State { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public Guid? AcceptedRequestId { get; set; }
}

public sealed class ProposalAcknowledgement
{
    public Guid ProposalId { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid OrganizationId { get; set; }
    public int Revision { get; set; }
    public DateTimeOffset AcknowledgedAt { get; set; }
}

public sealed class PlanningComment
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid EmployeeId { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid RequestId { get; set; }
    public Guid? ProposalId { get; set; }
    public Guid AuthorId { get; set; }
    public string Text { get; set; } = "";
    public DateTimeOffset CreatedAt { get; set; }
}

public sealed class PlanningAudit
{
    public Guid Id { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid ActorId { get; set; }
    public Guid ContextId { get; set; }
    public string Action { get; set; } = "";
    public long CalendarVersion { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public string ChangedDaysJson { get; set; } = "[]";
}

public sealed class PlanningOutbox
{
    public HomeOffice.Domain.Notifications.ProcessingState State { get; set; }
    public bool Historical { get; set; }
    public int Attempts { get; set; }
    public Guid? LeaseId { get; set; }
    public DateTimeOffset? LeaseUntil { get; set; }
    public DateTimeOffset NextAttemptAt { get; set; }
    public DateTimeOffset? ProcessedAt { get; set; }
    public string? LastError { get; set; }
    public Guid Id { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid EmployeeId { get; set; }
    public string Type { get; set; } = "";
    public string Payload { get; set; } = "";
    public long CalendarVersion { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? DeliveredAt { get; set; }
}

public sealed class PlanningReceipt
{
    public Guid ActorId { get; set; }
    public string Operation { get; set; } = "";
    public string Key { get; set; } = "";
    public string PayloadHash { get; set; } = "";
    public string ResponseJson { get; set; } = "";
    public DateTimeOffset CreatedAt { get; set; }
}
