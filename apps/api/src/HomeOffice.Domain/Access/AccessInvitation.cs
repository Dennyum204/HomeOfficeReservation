namespace HomeOffice.Domain.Access;

public enum InvitationState { Pending, Accepted, Cancelled }
public enum InvitationDeliveryState { Pending, Sending, Sent, Failed, Stopped }

// One durable activation lifecycle per existing member. No password or plaintext Identity code.
public sealed class AccessInvitation
{
    public Guid MemberId { get; set; }
    public Guid OrganizationId { get; set; }
    public Guid? CreatedBy { get; set; }
    public string CreationFingerprint { get; set; } = "";
    public InvitationState State { get; set; }
    public long Version { get; set; } = 1;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? AcceptedAt { get; set; }
    public DateTimeOffset? CancelledAt { get; set; }
    public string? ProtectedCode { get; set; }
    public DateTimeOffset? CodeExpiresAt { get; set; }
    public DateTimeOffset LastRequestedAt { get; set; }
    public DateTimeOffset WindowStartedAt { get; set; }
    public int RequestsInWindow { get; set; }
    public InvitationDeliveryState DeliveryState { get; set; }
    public int Attempts { get; set; }
    public DateTimeOffset NextAttemptAt { get; set; }
    public DateTimeOffset? DeliveredAt { get; set; }
    public string? LastError { get; set; }
    public Guid? LeaseId { get; set; }
    public DateTimeOffset? LeaseUntil { get; set; }
}

// Receipts bind a command to its actor, target and immutable request; no credential material.
public sealed class InvitationCommand
{
    public Guid OrganizationId { get; set; }
    public Guid ActorId { get; set; }
    public Guid CommandId { get; set; }
    public Guid MemberId { get; set; }
    public string Operation { get; set; } = "";
    public long ExpectedVersion { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}
