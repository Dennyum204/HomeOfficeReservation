using System.Security.Cryptography;
using System.Text;
using HomeOffice.Application.Notifications;
using HomeOffice.Domain.Access;
using HomeOffice.Domain.Notifications;
using HomeOffice.Domain.Planning;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Npgsql;
using static HomeOffice.Domain.Planning.PlanningRules;

namespace HomeOffice.Infrastructure.Notifications;

public sealed class NotificationService(HomeOfficeDbContext db, NotificationAccess access, TimeProvider clock,
    IDataProtectionProvider protection, IOptions<NotificationOptions> options) : INotificationService
{
    private IDataProtector Protector => protection.CreateProtector("HomeOffice.Notifications.DeviceAddress.v1");
    private async Task<NotificationView> View(InboxNotification row, CancellationToken ct)
    {
        var destination = await access.Destination(row, ct);
        return new(row.Id, destination is null ? "context.unavailable" : row.EventType, row.CreatedAt, row.ReadAt, row.Historical, destination);
    }
    public async Task<NotificationPage> List(Guid actor, int offset, int limit, bool unreadOnly, bool historical, CancellationToken ct)
    {
        Require(offset is >= 0 and <= 10000 && limit is >= 1 and <= 100, "invalid_pagination", 400);
        var rows = await access.Visible(actor).AsNoTracking().Where(n => n.Historical == historical && (!unreadOnly || n.ReadAt == null))
            .OrderByDescending(n => n.CreatedAt).ThenBy(n => n.Id).Skip(offset).Take(limit + 1).ToArrayAsync(ct);
        var views = new List<NotificationView>();
        foreach (var row in rows.Take(limit)) views.Add(await View(row, ct));
        return new(views.ToArray(), rows.Length > limit ? offset + limit : null, (await Count(actor, ct)).UnreadCount);
    }
    public async Task<NotificationCount> Count(Guid actor, CancellationToken ct) => new(await access.Visible(actor).CountAsync(n => !n.Historical && n.ReadAt == null, ct));
    private async Task<InboxNotification> Load(Guid actor, Guid id, CancellationToken ct)
    {
        var row = await access.Visible(actor).SingleOrDefaultAsync(n => n.Id == id, ct);
        Require(row is not null, "notification_unavailable", 404); return row!;
    }
    public async Task<NotificationView> Detail(Guid actor, Guid id, CancellationToken ct) => await View(await Load(actor, id, ct), ct);
    public async Task<NotificationView> Read(Guid actor, Guid id, bool read, CancellationToken ct)
    {
        // Setting a boolean is idempotent. It never calls a business mutation/acknowledgement.
        var row = await Load(actor, id, ct);
        if (read && row.ReadAt == null) row.ReadAt = clock.GetUtcNow();
        if (!read) row.ReadAt = null;
        await db.SaveChangesAsync(ct); return await View(row, ct);
    }
    private async Task<Member> Member(Guid actor, CancellationToken ct)
    {
        var member = await db.Members.AsNoTracking().SingleOrDefaultAsync(m => m.Id == actor && m.Active, ct);
        Require(member is not null, "forbidden", 403); return member!;
    }
    public async Task<DeviceRegistrationView> Register(Guid actor, DeviceRegistrationInput input, CancellationToken ct)
    {
        var member = await Member(actor, ct);
        Require(input.InstallationId != Guid.Empty && input.Provider != PushProvider.Disabled && input.Provider == options.Value.PushProvider, "push_not_configured", 400);
        Require(input.Address is { Length: >= 16 and <= 4096 } && input.Address.All(c => char.IsAsciiLetterOrDigit(c) || c is ':' or '-' or '_' or '.'), "invalid_device_address", 400);
        Require(input.Provider != PushProvider.Local || input.Address.StartsWith("local:", StringComparison.Ordinal), "invalid_device_address", 400);
        Require(input.Provider != PushProvider.Fcm || input.Address.Length == 22 && input.Address.All(c => char.IsAsciiLetterOrDigit(c) || c is '-' or '_'), "invalid_device_address", 400);
        var hash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(input.Address)));
        await using var tx = await db.Database.BeginTransactionAsync(ct);
        // Also serializes first registration. Namespace avoids collision with other advisory-lock uses.
        await db.Database.ExecuteSqlInterpolatedAsync($"SELECT pg_advisory_xact_lock(hashtextextended({input.InstallationId.ToString()}, 7007))", ct);
        member = await Member(actor, ct);
        var device = await db.Set<PushDevice>().SingleOrDefaultAsync(d => d.InstallationId == input.InstallationId, ct);
        if (device is not null)
        {
            Require(device.MemberId == actor && device.OrganizationId == member.OrganizationId, "device_owned_by_other_account", 409);
            Require(device.Active, "device_revoked", 409);
            if (device.AddressHash != hash || !device.Active) Version(input.ExpectedVersion, device.Version);
            if (device.AddressHash != hash || !device.Active) device.Version++;
        }
        else
        {
            Require(await db.Set<PushDevice>().CountAsync(d => d.MemberId == actor && d.Active, ct) < 10, "device_limit", 409);
            device = new() { InstallationId = input.InstallationId, MemberId = actor, OrganizationId = member.OrganizationId, RegisteredAt = clock.GetUtcNow() };
            db.Set<PushDevice>().Add(device);
        }
        Require(!await db.Set<PushDevice>().AnyAsync(d => d.Active && d.AddressHash == hash && d.InstallationId != input.InstallationId, ct), "device_address_in_use", 409);
        device.Provider = input.Provider; device.ProtectedAddress = Protector.Protect(input.Address); device.AddressHash = hash;
        device.Active = true; device.UpdatedAt = clock.GetUtcNow(); device.ExpiresAt = device.UpdatedAt.AddHours(options.Value.DeviceLeaseHours);
        try { await db.SaveChangesAsync(ct); await tx.CommitAsync(ct); }
        catch (DbUpdateException e) when (e.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation })
        { throw new PlanningException(409, "device_address_in_use"); }
        return new(device.InstallationId, device.Provider, device.Version, device.ExpiresAt);
    }
    public async Task RemoveDevice(Guid actor, Guid installation, CancellationToken ct)
    {
        Require(installation != Guid.Empty, "invalid_installation", 400);
        await using var tx = await db.Database.BeginTransactionAsync(ct);
        await db.Database.ExecuteSqlInterpolatedAsync($"SELECT pg_advisory_xact_lock(hashtextextended({installation.ToString()}, 7007))", ct);
        var member = await Member(actor, ct);
        var device = await db.Set<PushDevice>().SingleOrDefaultAsync(d => d.InstallationId == installation, ct);
        if (device is null)
        {
            // A delayed first registration cannot resurrect a binding removed during logout.
            var now = clock.GetUtcNow();
            db.Set<PushDevice>().Add(new()
            {
                InstallationId = installation,
                OrganizationId = member.OrganizationId,
                MemberId = actor,
                Active = false,
                Provider = PushProvider.Local,
                ProtectedAddress = "",
                AddressHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"revoked:{installation}"))),
                RegisteredAt = now,
                UpdatedAt = now,
                ExpiresAt = now
            });
        }
        else if (device.MemberId == actor && device.Active)
        { device.Active = false; device.Version++; device.ProtectedAddress = ""; device.UpdatedAt = clock.GetUtcNow(); }
        await db.SaveChangesAsync(ct); await tx.CommitAsync(ct);
    }
    public async Task DeviceReceipt(Guid actor, Guid notification, Guid installation, CancellationToken ct)
    {
        await Load(actor, notification, ct);
        Require(await db.Set<PushDevice>().AnyAsync(d => d.InstallationId == installation && d.MemberId == actor && d.Active, ct), "device_unavailable", 404);
        await db.Set<PushDelivery>().Where(d => d.NotificationId == notification && d.InstallationId == installation && d.RecipientId == actor && d.DeviceReportedAt == null && (d.State == PushState.ProviderAccepted || d.State == PushState.Leased))
            .ExecuteUpdateAsync(s => s.SetProperty(d => d.DeviceReportedAt, clock.GetUtcNow()), ct);
    }
    public async Task<NotificationOperations> Operations(Guid actor, CancellationToken ct)
    {
        var member = await Member(actor, ct); Require(member.IsAccountAdministrator, "forbidden", 403);
        var outbox = db.Set<PlanningOutbox>().Where(x => x.OrganizationId == member.OrganizationId);
        var push = db.Set<PushDelivery>().Where(x => x.OrganizationId == member.OrganizationId);
        return new(await outbox.CountAsync(x => x.State == ProcessingState.Pending || x.State == ProcessingState.Leased, ct), await outbox.CountAsync(x => x.State == ProcessingState.Failed, ct),
            await push.CountAsync(x => x.State == PushState.Pending || x.State == PushState.Leased, ct), await push.CountAsync(x => x.State == PushState.Failed, ct),
            await push.CountAsync(x => x.State == PushState.ProviderAccepted, ct), await push.CountAsync(x => x.State == PushState.Simulated, ct));
    }
    public async Task Retry(Guid actor, RetryNotificationInput input, CancellationToken ct)
    {
        var member = await Member(actor, ct); Require(member.IsAccountAdministrator, "forbidden", 403);
        var now = clock.GetUtcNow();
        var changed = input.Push
            ? await db.Set<PushDelivery>().Where(x => x.Id == input.Id && x.OrganizationId == member.OrganizationId && x.State == PushState.Failed)
                .ExecuteUpdateAsync(s => s.SetProperty(x => x.State, PushState.Pending).SetProperty(x => x.Attempts, 0).SetProperty(x => x.NextAttemptAt, now).SetProperty(x => x.LastError, (string?)null), ct)
            : await db.Set<PlanningOutbox>().Where(x => x.Id == input.Id && x.OrganizationId == member.OrganizationId && x.State == ProcessingState.Failed)
                .ExecuteUpdateAsync(s => s.SetProperty(x => x.State, ProcessingState.Pending).SetProperty(x => x.Attempts, 0).SetProperty(x => x.NextAttemptAt, now).SetProperty(x => x.LastError, (string?)null), ct);
        Require(changed == 1, "failed_delivery_unavailable", 404);
    }
}
