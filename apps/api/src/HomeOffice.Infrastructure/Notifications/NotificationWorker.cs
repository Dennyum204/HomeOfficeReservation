using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using HomeOffice.Infrastructure.Access;

namespace HomeOffice.Infrastructure.Notifications;

public sealed class NotificationWorker(IServiceScopeFactory scopes, IOptions<NotificationOptions> options, ILogger<NotificationWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        if (!options.Value.WorkerEnabled) return;
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                for (var i = 0; i < 4; i++)
                {
                    await using var scope = scopes.CreateAsyncScope();
                    var delivery = scope.ServiceProvider.GetRequiredService<InvitationDelivery>();
                    var claim = await delivery.Claim(ct: stoppingToken);
                    if (claim is null) break;
                    await delivery.Process(claim, stoppingToken);
                }
                NotificationLease[] claims;
                await using (var scope = scopes.CreateAsyncScope()) claims = await scope.ServiceProvider.GetRequiredService<NotificationProcessor>().ClaimOutbox(stoppingToken);
                foreach (var claim in claims)
                {
                    await using var scope = scopes.CreateAsyncScope();
                    await scope.ServiceProvider.GetRequiredService<NotificationProcessor>().ProcessOutbox(claim, stoppingToken);
                }
                for (var i = 0; i < Math.Min(options.Value.BatchSize, 4); i++)
                {
                    await using var scope = scopes.CreateAsyncScope(); var processor = scope.ServiceProvider.GetRequiredService<NotificationProcessor>();
                    var claim = await processor.ClaimPush(stoppingToken); if (claim is null) break;
                    await processor.ProcessPush(claim, stoppingToken);
                }
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested) { break; }
            catch (Exception e) { logger.LogWarning("Notification worker iteration failed ({FailureType}); durable work remains recoverable.", e.GetType().Name); }
            try { await Task.Delay(TimeSpan.FromSeconds(options.Value.PollSeconds), stoppingToken); }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested) { break; }
        }
    }
}
