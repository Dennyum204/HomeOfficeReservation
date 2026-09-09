using HomeOffice.Api.Access;
using HomeOffice.Api.Planning;
using HomeOffice.Application.Notifications;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Notifications;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace HomeOffice.Api.Notifications;

public static class NotificationEndpoints
{
    private static Guid Actor(HttpContext c) => ((Member)c.Items[typeof(Member)]!).Id;
    public static void MapNotifications(this WebApplication app)
    {
        var group = app.MapGroup("/api/v1/notifications").WithTags("Notifications").RequireAuthorization()
            .AddEndpointFilter<ActiveMemberFilter>().AddEndpointFilter<PlanningErrorFilter>()
            .WithMetadata(new ProducesResponseTypeAttribute(typeof(ProblemDetails), 400), new ProducesResponseTypeAttribute(typeof(ProblemDetails), 403),
                new ProducesResponseTypeAttribute(typeof(ProblemDetails), 404), new ProducesResponseTypeAttribute(typeof(ProblemDetails), 409), new ProducesResponseTypeAttribute(typeof(ProblemDetails), 412));
        group.MapGet("", (HttpContext c, INotificationService s, CancellationToken ct, int offset = 0, int limit = 25, bool unreadOnly = false, bool historical = false) => s.List(Actor(c), offset, limit, unreadOnly, historical, ct)).WithName("ListNotifications");
        group.MapGet("/unread-count", (HttpContext c, INotificationService s, CancellationToken ct) => s.Count(Actor(c), ct)).WithName("GetNotificationUnreadCount");
        group.MapGet("/capabilities", (IOptions<NotificationOptions> o) => new NotificationCapabilities(o.Value.PushProvider)).WithName("GetNotificationCapabilities");
        group.MapGet("/{notificationId:guid}", (Guid notificationId, HttpContext c, INotificationService s, CancellationToken ct) => s.Detail(Actor(c), notificationId, ct)).WithName("GetNotification");
        group.MapGet("/operations", (HttpContext c, INotificationService s, CancellationToken ct) => s.Operations(Actor(c), ct)).WithName("GetNotificationOperations");
        var writes = group.MapGroup("").AddEndpointFilter<CsrfFilter>();
        writes.MapPut("/{notificationId:guid}/read", (Guid notificationId, NotificationReadInput input, HttpContext c, INotificationService s, CancellationToken ct) => s.Read(Actor(c), notificationId, input.Read, ct)).WithName("SetNotificationRead");
        writes.MapPut("/devices", (DeviceRegistrationInput input, HttpContext c, INotificationService s, CancellationToken ct) => s.Register(Actor(c), input, ct)).WithName("RegisterPushDevice");
        writes.MapDelete("/devices/{installationId:guid}", async (Guid installationId, HttpContext c, INotificationService s, CancellationToken ct) =>
        { await s.RemoveDevice(Actor(c), installationId, ct); return TypedResults.NoContent(); }).WithName("RemovePushDevice");
        writes.MapPut("/{notificationId:guid}/device-receipt", async (Guid notificationId, DeviceReceiptInput input, HttpContext c, INotificationService s, CancellationToken ct) =>
        { await s.DeviceReceipt(Actor(c), notificationId, input.InstallationId, ct); return TypedResults.NoContent(); }).WithName("ReportNotificationDeviceReceipt");
        writes.MapPost("/operations/retry", async (RetryNotificationInput input, HttpContext c, INotificationService s, CancellationToken ct) =>
        { await s.Retry(Actor(c), input, ct); return TypedResults.NoContent(); }).WithName("RetryFailedNotificationWork");
    }
}
