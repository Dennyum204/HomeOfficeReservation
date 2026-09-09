using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using HomeOffice.Application.Notifications;
using HomeOffice.Domain.Notifications;
using Microsoft.Extensions.Options;

namespace HomeOffice.Infrastructure.Notifications;

public sealed class PushSender(IOptions<NotificationOptions> options) : IPushSender, IDisposable
{
    private FirebaseApp? app;
    private readonly SemaphoreSlim initialization = new(1);
    public async Task<PushResult> Send(PushProvider provider, string address, Guid notificationId, CancellationToken ct)
    {
        if (provider == PushProvider.Local) return new(false, Simulated: true, Code: "local_simulation");
        if (provider != PushProvider.Fcm || string.IsNullOrWhiteSpace(options.Value.FirebaseProjectId))
            return new(false, Permanent: true, Code: "provider_not_configured");
        using var timeout = CancellationTokenSource.CreateLinkedTokenSource(ct); timeout.CancelAfter(TimeSpan.FromSeconds(15));
        try
        {
            await initialization.WaitAsync(timeout.Token);
            try
            {
                app ??= FirebaseApp.Create(new AppOptions
                {
                    ProjectId = options.Value.FirebaseProjectId,
                    Credential = await GoogleCredential.GetApplicationDefaultAsync(timeout.Token)
                }, "homeoffice-push-" + Guid.NewGuid().ToString("N"));
            }
            finally { initialization.Release(); }
            // Current Admin SDK targets FIDs. No employee names, dates, reasons or task contents leave the API.
            await FirebaseMessaging.GetMessaging(app).SendAsync(new Message
            {
                Fid = address,
                Notification = new() { Title = "HomeOffice", Body = "Tem uma nova atualização. Abra a aplicação para consultar." },
                Data = new Dictionary<string, string> { ["notificationId"] = notificationId.ToString(), ["schema"] = "1" },
                Android = new()
                {
                    Priority = Priority.Normal,
                    TimeToLive = TimeSpan.FromHours(1),
                    Notification = new() { Tag = notificationId.ToString(), Visibility = NotificationVisibility.PRIVATE }
                }
            }, timeout.Token);
            return new(true);
        }
        catch (FirebaseMessagingException e)
        {
            var code = e.MessagingErrorCode;
            return new(false, Permanent: code is not (MessagingErrorCode.Unavailable or MessagingErrorCode.Internal or MessagingErrorCode.QuotaExceeded),
                InvalidDevice: code == MessagingErrorCode.Unregistered, Code: "fcm_" + (code?.ToString() ?? "configuration"));
        }
        catch (OperationCanceledException) when (!ct.IsCancellationRequested) { return new(false, Code: "provider_timeout"); }
        catch (HttpRequestException) { return new(false, Code: "provider_network"); }
        catch (Exception) when (!ct.IsCancellationRequested) { return new(false, Permanent: true, Code: "provider_configuration"); }
    }
    public void Dispose() { app?.Delete(); initialization.Dispose(); }
}
