using HomeOffice.Domain.Notifications;

namespace HomeOffice.Infrastructure.Notifications;

public sealed class NotificationOptions
{
    public bool WorkerEnabled { get; set; } = true;
    public PushProvider PushProvider { get; set; } = PushProvider.Disabled;
    public int BatchSize { get; set; } = 20;
    public int PollSeconds { get; set; } = 3;
    public int LeaseSeconds { get; set; } = 120;
    public int MaxAttempts { get; set; } = 5;
    public int DeviceLeaseHours { get; set; } = 24;
    public string? FirebaseProjectId { get; set; }
}
