using HomeOffice.Domain.Notifications;

namespace HomeOffice.Application.Notifications;

public sealed record NotificationDestination(NotificationContext Kind, Guid EmployeeId, Guid ResourceId, Guid? ProposalId);
public sealed record NotificationView(Guid Id, string EventType, DateTimeOffset CreatedAt, DateTimeOffset? ReadAt, bool Historical, NotificationDestination? Destination);
public sealed record NotificationPage(NotificationView[] Items, int? NextOffset, int UnreadCount);
public sealed record NotificationCount(int UnreadCount);
public sealed record NotificationReadInput(bool Read);
public sealed record DeviceRegistrationInput(Guid InstallationId, PushProvider Provider, string Address, long? ExpectedVersion);
public sealed record DeviceRegistrationView(Guid InstallationId, PushProvider Provider, long Version, DateTimeOffset ExpiresAt);
public sealed record DeviceReceiptInput(Guid InstallationId);
public sealed record NotificationCapabilities(PushProvider Provider);
public sealed record NotificationOperations(int OutboxPending, int OutboxFailed, int PushPending, int PushFailed, int ProviderAccepted, int Simulated);
public sealed record RetryNotificationInput(Guid Id, bool Push);

public interface INotificationService
{
    Task<NotificationPage> List(Guid actor, int offset, int limit, bool unreadOnly, bool historical, CancellationToken ct);
    Task<NotificationCount> Count(Guid actor, CancellationToken ct);
    Task<NotificationView> Detail(Guid actor, Guid id, CancellationToken ct);
    Task<NotificationView> Read(Guid actor, Guid id, bool read, CancellationToken ct);
    Task<DeviceRegistrationView> Register(Guid actor, DeviceRegistrationInput input, CancellationToken ct);
    Task RemoveDevice(Guid actor, Guid installation, CancellationToken ct);
    Task DeviceReceipt(Guid actor, Guid notification, Guid installation, CancellationToken ct);
    Task<NotificationOperations> Operations(Guid actor, CancellationToken ct);
    Task Retry(Guid actor, RetryNotificationInput input, CancellationToken ct);
}

public sealed record PushResult(bool Accepted, bool Simulated = false, bool Permanent = false, bool InvalidDevice = false, string? Code = null);
public interface IPushSender
{
    Task<PushResult> Send(PushProvider provider, string address, Guid notificationId, CancellationToken ct);
}
