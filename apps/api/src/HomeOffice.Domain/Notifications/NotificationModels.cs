namespace HomeOffice.Domain.Notifications;

public enum NotificationContext { Request, Proposal, Requirement, Task }
public enum ProcessingState { Pending, Leased, Processed, Ignored, Failed }
public enum PushState { Pending, Leased, ProviderAccepted, Simulated, Suppressed, Failed }
public enum PushProvider { Disabled, Local, Fcm }

public sealed class InboxNotification
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid EventId { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid RecipientId { get; set; }
    public Guid EmployeeId { get; set; }
    public string EventType { get; set; } = "";
    public NotificationContext Context { get; set; }
    public Guid ContextId { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? ReadAt { get; set; }
    public bool Historical { get; set; }
}

public sealed class PushDevice
{
    public Guid InstallationId { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid MemberId { get; set; }
    public PushProvider Provider { get; set; }
    public string ProtectedAddress { get; set; } = "";
    public string AddressHash { get; set; } = "";
    public long Version { get; set; } = 1;
    public bool Active { get; set; } = true;
    public DateTimeOffset RegisteredAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public DateTimeOffset ExpiresAt { get; set; }
}

public sealed class PushDelivery
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid NotificationId { get; set; }
    public Guid InstallationId { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid RecipientId { get; set; }
    public long DeviceVersion { get; set; }
    public PushState State { get; set; }
    public int Attempts { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset NextAttemptAt { get; set; }
    public Guid? LeaseId { get; set; }
    public DateTimeOffset? LeaseUntil { get; set; }
    public DateTimeOffset? ProviderAcceptedAt { get; set; }
    public DateTimeOffset? DeviceReportedAt { get; set; }
    public string? LastError { get; set; }
}

// Event names come from successful server-side business commands, never from a client notification request.
public static class NotificationEvents
{
    public static (NotificationContext Context, bool ToManager)? Map(string type) => type switch
    {
        "planning.submitted" or "planning.withdrawn" or "planning.counterproposal-accepted" => (NotificationContext.Request, true),
        "planning.decided" => (NotificationContext.Request, false),
        "planning.counterproposed" => (NotificationContext.Proposal, false),
        "onsite.created" or "onsite.edited" or "onsite.cancelled" => (NotificationContext.Requirement, false),
        "task.assigned" or "task.updated" => (NotificationContext.Task, false),
        _ => null
    };
}
