using System.Security.Cryptography;
using System.Text.Json;
using HomeOffice.Application.Notifications;
using HomeOffice.Domain.Notifications;
using HomeOffice.Domain.Planning;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace HomeOffice.Infrastructure.Notifications;

public sealed record NotificationLease(Guid Id, Guid LeaseId);

public sealed class NotificationProcessor(HomeOfficeDbContext db, NotificationAccess access, TimeProvider clock,
    IOptions<NotificationOptions> options, IDataProtectionProvider protection, IPushSender sender)
{
    private NotificationOptions Settings => options.Value;
    public async Task<NotificationLease[]> ClaimOutbox(CancellationToken ct)
    {
        var now = clock.GetUtcNow(); var lease = Guid.NewGuid(); var until = now.AddSeconds(Settings.LeaseSeconds);
        await db.Set<PlanningOutbox>().Where(x => (x.State == ProcessingState.Pending || x.State == ProcessingState.Leased && x.LeaseUntil <= now) && x.Attempts >= Settings.MaxAttempts)
            .ExecuteUpdateAsync(s => s.SetProperty(x => x.State, ProcessingState.Failed).SetProperty(x => x.LastError, "lease_retry_exhausted").SetProperty(x => x.LeaseId, (Guid?)null).SetProperty(x => x.LeaseUntil, (DateTimeOffset?)null), ct);
        var rows = await db.Set<PlanningOutbox>().FromSqlInterpolated($"""
            WITH candidates AS (
              SELECT "Id" FROM "PlanningOutbox"
              WHERE ("State" = 0 OR ("State" = 1 AND "LeaseUntil" <= {now}))
                AND "NextAttemptAt" <= {now} AND "Attempts" < {Settings.MaxAttempts}
              ORDER BY "CreatedAt", "Id" LIMIT {Settings.BatchSize} FOR UPDATE SKIP LOCKED
            )
            UPDATE "PlanningOutbox" AS o SET "State"=1, "LeaseId"={lease}, "LeaseUntil"={until}, "Attempts"=o."Attempts"+1
            FROM candidates c WHERE o."Id"=c."Id" RETURNING o.*
            """).AsNoTracking().ToArrayAsync(ct);
        return rows.Select(x => new NotificationLease(x.Id, lease)).ToArray();
    }

    public async Task ProcessOutbox(NotificationLease claim, CancellationToken ct)
    {
        try
        {
            await using var tx = await db.Database.BeginTransactionAsync(ct);
            var rows = await db.Set<PlanningOutbox>().FromSqlInterpolated($"SELECT * FROM \"PlanningOutbox\" WHERE \"Id\"={claim.Id} FOR UPDATE").ToArrayAsync(ct);
            var row = rows.SingleOrDefault(); var now = clock.GetUtcNow();
            if (row is null || row.State != ProcessingState.Leased || row.LeaseId != claim.LeaseId || row.LeaseUntil <= now) return;
            var mapping = NotificationEvents.Map(row.Type);
            string? ignored = null;
            if (mapping is null) ignored = "event_not_notifiable";
            else
            {
                using var json = JsonDocument.Parse(row.Payload); var payload = json.RootElement;
                var schema = payload.GetProperty("schemaVersion").GetInt32();
                if (schema is not (1 or 2) || payload.GetProperty("eventId").GetGuid() != row.Id || payload.GetProperty("employeeId").GetGuid() != row.EmployeeId)
                    throw new JsonException();
                var actor = payload.GetProperty("actorId").GetGuid(); var context = payload.GetProperty("contextId").GetGuid();
                // Pre-HO007 events have no recipient snapshot: archive only, using current authority.
                var historical = row.Historical || schema == 1;
                Guid? recipient = schema == 2
                    ? payload.GetProperty("recipientId").ValueKind == JsonValueKind.Null ? null : payload.GetProperty("recipientId").GetGuid()
                    : mapping.Value.ToManager
                        ? await db.ReportingLines.Where(l => l.EmployeeId == row.EmployeeId && l.OrganizationId == row.OrganizationId).Select(l => (Guid?)l.ManagerId).SingleOrDefaultAsync(ct)
                        : row.EmployeeId;
                if (recipient is null || recipient == actor || !await access.CanAccess(recipient.Value, row.EmployeeId, row.OrganizationId, ct)) ignored = "recipient_unavailable";
                else
                {
                    var notification = await db.Set<InboxNotification>().SingleOrDefaultAsync(n => n.EventId == row.Id && n.RecipientId == recipient, ct);
                    if (notification is null)
                    {
                        notification = new()
                        {
                            EventId = row.Id,
                            OrganizationId = row.OrganizationId,
                            EmployeeId = row.EmployeeId,
                            RecipientId = recipient.Value,
                            Context = mapping.Value.Context,
                            ContextId = context,
                            EventType = row.Type,
                            CreatedAt = row.CreatedAt,
                            Historical = historical
                        };
                        if (await access.Destination(notification, ct) is null) ignored = "context_unavailable";
                        else
                        {
                            db.Set<InboxNotification>().Add(notification);
                            if (!historical && Settings.PushProvider != PushProvider.Disabled && row.CreatedAt >= now.AddHours(-1))
                            {
                                var devices = await db.Set<PushDevice>().AsNoTracking().Where(d => d.MemberId == recipient && d.OrganizationId == row.OrganizationId && d.Active && d.ExpiresAt > now && d.RegisteredAt <= row.CreatedAt && d.Provider == Settings.PushProvider).ToArrayAsync(ct);
                                foreach (var device in devices) db.Set<PushDelivery>().Add(new()
                                {
                                    NotificationId = notification.Id,
                                    OrganizationId = row.OrganizationId,
                                    RecipientId = recipient.Value,
                                    InstallationId = device.InstallationId,
                                    DeviceVersion = device.Version,
                                    CreatedAt = now,
                                    NextAttemptAt = now
                                });
                            }
                        }
                    }
                }
            }
            row.State = ignored is null ? ProcessingState.Processed : ProcessingState.Ignored;
            row.LastError = ignored; row.ProcessedAt = now; row.DeliveredAt = now; // Legacy field means internal processing, never push receipt.
            row.LeaseId = null; row.LeaseUntil = null;
            await db.SaveChangesAsync(ct); await tx.CommitAsync(ct);
        }
        catch (OperationCanceledException) when (ct.IsCancellationRequested) { throw; }
        catch (Exception e)
        {
            db.ChangeTracker.Clear();
            var permanent = e is JsonException or KeyNotFoundException or FormatException or InvalidOperationException;
            await FailOutbox(claim, permanent ? "invalid_event" : "processing_failed", permanent, ct);
        }
    }
    private async Task FailOutbox(NotificationLease claim, string code, bool permanent, CancellationToken ct)
    {
        var row = await db.Set<PlanningOutbox>().AsNoTracking().SingleOrDefaultAsync(x => x.Id == claim.Id && x.LeaseId == claim.LeaseId && x.State == ProcessingState.Leased, ct);
        if (row is null) return;
        var failed = permanent || row.Attempts >= Settings.MaxAttempts;
        await db.Set<PlanningOutbox>().Where(x => x.Id == claim.Id && x.LeaseId == claim.LeaseId && x.State == ProcessingState.Leased)
            .ExecuteUpdateAsync(s => s.SetProperty(x => x.State, failed ? ProcessingState.Failed : ProcessingState.Pending)
                .SetProperty(x => x.LastError, code).SetProperty(x => x.NextAttemptAt, clock.GetUtcNow().AddSeconds(Backoff(row.Attempts)))
                .SetProperty(x => x.LeaseId, (Guid?)null).SetProperty(x => x.LeaseUntil, (DateTimeOffset?)null), ct);
    }
    private static int Backoff(int attempt) => Math.Min(900, 5 * (1 << Math.Min(attempt, 7)));

    // Claim one delivery just before sending, so a slow provider does not consume another delivery's lease.
    public async Task<NotificationLease?> ClaimPush(CancellationToken ct)
    {
        var now = clock.GetUtcNow(); var lease = Guid.NewGuid(); var until = now.AddSeconds(Settings.LeaseSeconds);
        await db.Set<PushDelivery>().Where(x => (x.State == PushState.Pending || x.State == PushState.Leased && x.LeaseUntil <= now) && x.Attempts >= Settings.MaxAttempts)
            .ExecuteUpdateAsync(s => s.SetProperty(x => x.State, PushState.Failed).SetProperty(x => x.LastError, "lease_retry_exhausted").SetProperty(x => x.LeaseId, (Guid?)null).SetProperty(x => x.LeaseUntil, (DateTimeOffset?)null), ct);
        var rows = await db.Set<PushDelivery>().FromSqlInterpolated($"""
            WITH candidate AS (
              SELECT "Id" FROM "PushDelivery"
              WHERE ("State"=0 OR ("State"=1 AND "LeaseUntil" <= {now})) AND "NextAttemptAt" <= {now} AND "Attempts" < {Settings.MaxAttempts}
              ORDER BY "CreatedAt", "Id" LIMIT 1 FOR UPDATE SKIP LOCKED
            )
            UPDATE "PushDelivery" AS p SET "State"=1, "LeaseId"={lease}, "LeaseUntil"={until}, "Attempts"=p."Attempts"+1
            FROM candidate c WHERE p."Id"=c."Id" RETURNING p.*
            """).AsNoTracking().ToArrayAsync(ct);
        return rows.Length == 0 ? null : new(rows[0].Id, lease);
    }
    public async Task ProcessPush(NotificationLease claim, CancellationToken ct)
    {
        var now = clock.GetUtcNow();
        var delivery = await db.Set<PushDelivery>().AsNoTracking().SingleOrDefaultAsync(d => d.Id == claim.Id && d.State == PushState.Leased && d.LeaseId == claim.LeaseId && d.LeaseUntil > now, ct);
        if (delivery is null) return;
        var notification = await access.Visible(delivery.RecipientId).AsNoTracking().SingleOrDefaultAsync(n => n.Id == delivery.NotificationId, ct);
        var device = await db.Set<PushDevice>().AsNoTracking().SingleOrDefaultAsync(d => d.InstallationId == delivery.InstallationId && d.MemberId == delivery.RecipientId && d.OrganizationId == delivery.OrganizationId && d.Active && d.ExpiresAt > now && d.Version == delivery.DeviceVersion, ct);
        if (notification is null || device is null || device.Provider != Settings.PushProvider || notification.Historical || notification.CreatedAt < now.AddHours(-1) || await access.Destination(notification, ct) is null)
        { await FinishPush(claim, PushState.Suppressed, "access_device_or_context_changed", null, ct); return; }
        PushResult result;
        try
        {
            var address = protection.CreateProtector("HomeOffice.Notifications.DeviceAddress.v1").Unprotect(device.ProtectedAddress);
            result = await sender.Send(device.Provider, address, notification.Id, ct);
        }
        catch (OperationCanceledException) when (ct.IsCancellationRequested) { throw; }
        catch (CryptographicException) { result = new(false, Permanent: true, Code: "device_key_unavailable"); }
        catch (Exception) { result = new(false, Code: "provider_failed"); }
        if (result.InvalidDevice)
            await db.Set<PushDevice>().Where(d => d.InstallationId == device.InstallationId && d.Version == device.Version && d.MemberId == delivery.RecipientId)
                .ExecuteUpdateAsync(s => s.SetProperty(d => d.Active, false).SetProperty(d => d.ProtectedAddress, "").SetProperty(d => d.Version, d => d.Version + 1), ct);
        var state = result.Simulated ? PushState.Simulated : result.Accepted ? PushState.ProviderAccepted : result.Permanent || delivery.Attempts >= Settings.MaxAttempts ? PushState.Failed : PushState.Pending;
        await FinishPush(claim, state, result.Code, clock.GetUtcNow().AddSeconds(Backoff(delivery.Attempts)), ct);
    }
    private async Task FinishPush(NotificationLease claim, PushState state, string? code, DateTimeOffset? next, CancellationToken ct)
    {
        var now = clock.GetUtcNow();
        await db.Set<PushDelivery>().Where(d => d.Id == claim.Id && d.State == PushState.Leased && d.LeaseId == claim.LeaseId)
            .ExecuteUpdateAsync(s => s.SetProperty(d => d.State, state).SetProperty(d => d.LastError, code)
                .SetProperty(d => d.NextAttemptAt, next ?? now).SetProperty(d => d.ProviderAcceptedAt, state == PushState.ProviderAccepted ? now : (DateTimeOffset?)null)
                .SetProperty(d => d.LeaseId, (Guid?)null).SetProperty(d => d.LeaseUntil, (DateTimeOffset?)null), ct);
    }
}
