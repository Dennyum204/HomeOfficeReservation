namespace HomeOffice.Domain.Access;

// Account changes must not increment a planning version or impersonate a calendar decision.
public sealed class AccessAudit
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid OrganizationId { get; set; }
    public Guid MemberId { get; set; }
    public Guid? ActorMemberId { get; set; }
    public string Source { get; set; } = "";
    public string Action { get; set; } = "";
    public string Reason { get; set; } = "";
    public DateTimeOffset CreatedAt { get; set; }
    public string BeforeJson { get; set; } = "null";
    public string AfterJson { get; set; } = "null";
}
