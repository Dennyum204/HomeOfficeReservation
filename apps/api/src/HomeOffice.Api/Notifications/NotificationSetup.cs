using HomeOffice.Application.Notifications;
using HomeOffice.Domain.Notifications;
using HomeOffice.Infrastructure.Notifications;

namespace HomeOffice.Api.Notifications;

public static class NotificationSetup
{
    public static void AddNotifications(this IServiceCollection services, IConfiguration config, IHostEnvironment environment, bool contract)
    {
        services.AddOptions<NotificationOptions>().Bind(config.GetSection("Notifications"))
            .Validate(o => o.BatchSize is >= 1 and <= 100 && o.PollSeconds is >= 1 and <= 60 && o.LeaseSeconds is >= 30 and <= 600 && o.MaxAttempts is >= 1 and <= 10 && o.DeviceLeaseHours is >= 1 and <= 24 && Enum.IsDefined(o.PushProvider), "Invalid bounded notification worker configuration.")
            .Validate(o => o.PushProvider != PushProvider.Local || environment.IsDevelopment() || environment.IsEnvironment("Testing"), "Local push simulation is only available in Development/Testing.")
            .ValidateOnStart();
        services.AddScoped<NotificationAccess>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<NotificationProcessor>();
        services.AddSingleton<IPushSender, PushSender>();
        if (!contract) services.AddHostedService<NotificationWorker>();
    }
}
