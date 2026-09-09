using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using HomeOffice.Application.Notifications;
using HomeOffice.Application.Planning;
using HomeOffice.Domain.Notifications;
using HomeOffice.Domain.Planning;
using HomeOffice.Infrastructure.Notifications;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Npgsql;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed partial class PlanningTests
{
    private sealed class TestPush(PushResult result) : IPushSender
    {
        public int Calls;
        public Task<PushResult> Send(PushProvider provider, string address, Guid notificationId, CancellationToken ct)
        { Interlocked.Increment(ref Calls); return Task.FromResult(result); }
    }
    private static async Task<T> Notify<T>(Scenario f, Func<INotificationService, Task<T>> action)
    { await using var scope = f.Identity.Factory.Services.CreateAsyncScope(); return await action(scope.ServiceProvider.GetRequiredService<INotificationService>()); }
    private static async Task Notify(Scenario f, Func<INotificationService, Task> action)
    { await using var scope = f.Identity.Factory.Services.CreateAsyncScope(); await action(scope.ServiceProvider.GetRequiredService<INotificationService>()); }
    private static NotificationProcessor Processor(Scenario f, IServiceProvider services, IPushSender? sender = null)
    {
        var db = services.GetRequiredService<HomeOfficeDbContext>();
        return new(db, new(db), f.Identity.Clock, Options.Create(new NotificationOptions { PushProvider = PushProvider.Local }),
            services.GetRequiredService<IDataProtectionProvider>(), sender ?? new TestPush(new(false, Simulated: true)));
    }
    private static async Task<T> Process<T>(Scenario f, Func<NotificationProcessor, Task<T>> action, IPushSender? sender = null)
    { await using var scope = f.Identity.Factory.Services.CreateAsyncScope(); return await action(Processor(f, scope.ServiceProvider, sender)); }
    private static async Task Process(Scenario f, Func<NotificationProcessor, Task> action, IPushSender? sender = null)
    { await using var scope = f.Identity.Factory.Services.CreateAsyncScope(); await action(Processor(f, scope.ServiceProvider, sender)); }
    private static async Task Drain(Scenario f)
    {
        for (var batch = 0; batch < 20; batch++)
        {
            var claims = await Process(f, p => p.ClaimOutbox(default)); if (claims.Length == 0) return;
            foreach (var claim in claims) await Process(f, p => p.ProcessOutbox(claim, default));
        }
        Assert.Fail("Outbox did not drain within a bounded test batch.");
    }
    private static Task<NotificationPage> Inbox(Scenario f, Guid actor, bool historical = false) => Notify(f, s => s.List(actor, 0, 100, false, historical, default));
    private static Task<DeviceRegistrationView> Device(Scenario f, Guid actor, Guid? id = null, string? address = null, long? version = null) =>
        Notify(f, s => s.Register(actor, new(id ?? Guid.NewGuid(), PushProvider.Local, address ?? "local:" + Guid.NewGuid().ToString("N"), version), default));

    [Fact]
    public async Task AdditiveMigrationPreservesExistingAccountsPlansAndOutboxWithoutHistoricalPush()
    {
        // IdentityFixture owns a fresh disposable database. Never downgrade the user's local database.
        await using var f = new Scenario(); await f.Init(); await f.Submit((await f.Draft()).ContextId);
        var before = await f.Counts(); var members = await f.Db(db => db.Members.CountAsync());
        await f.Db(async db =>
        {
            var migrator = db.GetService<IMigrator>();
            await migrator.MigrateAsync("20260909184158_OnsiteRequirementsAndTasks");
            await db.Database.ExecuteSqlRawAsync("UPDATE \"PlanningOutbox\" SET \"Payload\" = jsonb_set(\"Payload\" - 'recipientId', ARRAY['schemaVersion'], '1')");
            await migrator.MigrateAsync(); return true;
        });
        Assert.Equal(before, await f.Counts()); Assert.Equal(members, await f.Db(db => db.Members.CountAsync()));
        await Device(f, f.Manager); await Drain(f);
        Assert.Single((await Inbox(f, f.Manager, true)).Items); Assert.Empty((await Inbox(f, f.Manager)).Items);
        Assert.Equal(0, await f.Db(db => db.Set<PushDelivery>().CountAsync()));
        Assert.True(await f.Db(db => db.Set<PlanningOutbox>().AllAsync(o => o.Historical)));
    }

    [Fact]
    public async Task LogoutTombstoneRejectsDelayedInitialRegistrationAndNewBindingCanReconnect()
    {
        await using var f = new Scenario(); await f.Init(); var installation = Guid.NewGuid();
        await Notify(f, s => s.RemoveDevice(f.Manager, installation, default));
        await Error(409, "device_revoked", () => Device(f, f.Manager, installation));
        await Error(409, "device_owned_by_other_account", () => Device(f, f.Employee, installation));
        var fresh = await Device(f, f.Manager); Assert.NotEqual(installation, fresh.InstallationId);
    }

    [Fact]
    public async Task InvalidProviderAddressDeactivatesDeviceAndReceiptDoesNotMarkNotificationRead()
    {
        await using var f = new Scenario(); await f.Init(); var device = await Device(f, f.Manager);
        await f.Submit((await f.Draft()).ContextId); await Drain(f);
        var notification = Assert.Single((await Inbox(f, f.Manager)).Items);
        var claim = await Process(f, p => p.ClaimPush(default));
        await Process(f, p => p.ProcessPush(claim!, default), new TestPush(new(true)));
        await Notify(f, s => s.DeviceReceipt(f.Manager, notification.Id, device.InstallationId, default));
        Assert.NotNull(await f.Db(db => db.Set<PushDelivery>().Select(p => p.DeviceReportedAt).SingleAsync()));
        Assert.Null((await Notify(f, s => s.Detail(f.Manager, notification.Id, default))).ReadAt);
        await Error(404, "notification_unavailable", () => Notify(f, s => s.DeviceReceipt(f.Employee, notification.Id, device.InstallationId, default)));
        await f.Db(db => db.Set<PushDelivery>().ExecuteUpdateAsync(s => s.SetProperty(p => p.State, PushState.Pending).SetProperty(p => p.NextAttemptAt, f.Identity.Clock.GetUtcNow())));
        claim = await Process(f, p => p.ClaimPush(default));
        await Process(f, p => p.ProcessPush(claim!, default), new TestPush(new(false, Permanent: true, InvalidDevice: true, Code: "unregistered")));
        Assert.False(await f.Db(db => db.Set<PushDevice>().Select(d => d.Active).SingleAsync()));
        Assert.Single((await Inbox(f, f.Manager)).Items);
    }

    [Fact]
    public async Task RepeatedWorkerCrashesExhaustLeasesAndExpiredDevicesNeverReceivePush()
    {
        await using var f = new Scenario(); await f.Init(); await Device(f, f.Manager); await f.Submit((await f.Draft()).ContextId);
        for (var i = 0; i < 5; i++) { Assert.NotEmpty(await Process(f, p => p.ClaimOutbox(default))); f.Identity.Clock.Advance(TimeSpan.FromSeconds(121)); }
        Assert.Empty(await Process(f, p => p.ClaimOutbox(default)));
        Assert.True(await f.Db(db => db.Set<PlanningOutbox>().AllAsync(o => o.State == ProcessingState.Failed)));
        var failed = await f.Db(db => db.Set<PlanningOutbox>().Where(o => o.Type == "planning.submitted").Select(o => o.Id).SingleAsync());
        await Notify(f, s => s.Retry(f.Identity.Admin.Id, new(failed, false), default));
        await Drain(f); var claim = await Process(f, p => p.ClaimPush(default)); Assert.NotNull(claim);
        await f.Db(db => db.Set<PushDevice>().ExecuteUpdateAsync(s => s.SetProperty(d => d.ExpiresAt, f.Identity.Clock.GetUtcNow().AddSeconds(-1))));
        var provider = new TestPush(new(true)); await Process(f, p => p.ProcessPush(claim!, default), provider);
        Assert.Equal(0, provider.Calls); Assert.Equal(PushState.Suppressed, await f.Db(db => db.Set<PushDelivery>().Select(p => p.State).SingleAsync()));
    }

    [Fact]
    public async Task CounterproposalRevisionAcceptanceAndOnsiteChangesKeepAuthoritativeRecipients()
    {
        await using var f = new Scenario(); await f.Init(); var request = await f.Submit((await f.Draft()).ContextId);
        var v = (await f.Calendar()).CalendarVersion;
        var proposal = await f.Run(s => s.Propose(f.Manager, f.Employee, request.Id, null,
            new(v, request.Version, request.Days.Select(d => new SelectedDay(d.Id, d.Version)).ToArray(), [new(f.Date.AddDays(2), WorkLocation.OfficeSwitzerland, Availability.Working)], "Synthetic proposal"), Key(), default));
        var revised = await f.Run(s => s.Propose(f.Manager, f.Employee, request.Id, proposal.ContextId,
            new(proposal.CalendarVersion, request.Version, request.Days.Select(d => new SelectedDay(d.Id, d.Version)).ToArray(), [new(f.Date.AddDays(3), WorkLocation.OfficeSwitzerland, Availability.Working)], "Synthetic revision"), Key(), default));
        var accepted = await f.Run(s => s.Accept(f.Employee, f.Employee, revised.ContextId, new(revised.CalendarVersion, 2), Key(), default));
        await Drain(f);
        Assert.Equal(2, (await Inbox(f, f.Employee)).Items.Count(n => n.EventType == "planning.counterproposed"));
        var manager = (await Inbox(f, f.Manager)).Items.Single(n => n.EventType == "planning.counterproposal-accepted");
        Assert.Equal(accepted.ContextId, manager.Destination!.ResourceId);
        var onsite = await Onsite(f, f.Date.AddDays(5)); v = (await f.Calendar()).CalendarVersion;
        await f.Run(s => s.SaveRequirement(f.Manager, f.Employee, onsite.Id, new(v, onsite.Version, onsite.From, onsite.To, "Changed synthetic reason", "Zurique", ""), Key(), default));
        await CancelOnsite(f, await GetOnsite(f, onsite.Id)); await Drain(f);
        Assert.Equal(new[] { "onsite.cancelled", "onsite.created", "onsite.edited" }, (await Inbox(f, f.Employee)).Items.Where(n => n.EventType.StartsWith("onsite.", StringComparison.Ordinal)).Select(n => n.EventType).Order().ToArray());
    }

    [Fact]
    public async Task NotificationsUseServerRecipientsAndReadDoesNotAcknowledgeOrDecideBusinessContext()
    {
        await using var f = new Scenario(); await f.Init();
        var request = await f.Submit((await f.Draft()).ContextId); await Drain(f);
        var manager = Assert.Single((await Inbox(f, f.Manager)).Items);
        Assert.Equal("planning.submitted", manager.EventType); Assert.Equal(request.Id, manager.Destination!.ResourceId);
        Assert.Empty((await Inbox(f, f.Employee)).Items); var before = await f.Counts();
        await Notify(f, s => s.Read(f.Manager, manager.Id, true, default)); await Notify(f, s => s.Read(f.Manager, manager.Id, true, default));
        Assert.Equal(0, (await Notify(f, s => s.Count(f.Manager, default))).UnreadCount); Assert.Equal(before, await f.Counts());
        await f.Decide(request.Id, request.Days); var onsite = await Onsite(f); var v = (await f.Calendar()).CalendarVersion;
        await f.Run(s => s.SaveTask(f.Manager, f.Employee, null, new(v, null, "XPTO", "", f.Date, AssignedTaskState.Todo, true, onsite.Id), Key(), default));
        await Drain(f); var employee = await Inbox(f, f.Employee);
        Assert.Equal(new[] { "onsite.created", "planning.decided", "task.assigned" }, employee.Items.Select(n => n.EventType).Order().ToArray());
        before = await f.Counts();
        await Notify(f, s => s.Read(f.Employee, employee.Items.Single(n => n.EventType == "onsite.created").Id, true, default));
        Assert.Null((await GetOnsite(f, onsite.Id)).ReadAt); Assert.Equal(before, await f.Counts());
        using var stranger = f.Identity.Client(); IdentityFixture.Bearer(stranger, await f.Identity.TokenLogin(stranger, "stranger"));
        Assert.Equal(HttpStatusCode.NotFound, (await stranger.GetAsync($"/api/v1/notifications/{manager.Id}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await stranger.PutAsJsonAsync($"/api/v1/notifications/{manager.Id}/read", new { read = true })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await stranger.PutAsJsonAsync("/api/v1/notifications/devices", new { installationId = Guid.NewGuid(), provider = "Local", address = "local:syntheticaddress", recipientId = f.Manager })).StatusCode);
    }

    [Fact]
    public async Task OutboxConcurrentWorkersHaveDisjointClaimsAndDuplicateProcessingDoesNotDuplicateEffects()
    {
        await using var f = new Scenario(); await f.Init(); await Device(f, f.Manager);
        await f.Submit((await f.Draft()).ContextId);
        await using var one = f.Identity.Factory.Services.CreateAsyncScope(); await using var two = f.Identity.Factory.Services.CreateAsyncScope();
        var db1 = one.ServiceProvider.GetRequiredService<HomeOfficeDbContext>(); var db2 = two.ServiceProvider.GetRequiredService<HomeOfficeDbContext>();
        await db1.Database.OpenConnectionAsync(); await db2.Database.OpenConnectionAsync();
        Assert.NotEqual(((NpgsqlConnection)db1.Database.GetDbConnection()).ProcessID, ((NpgsqlConnection)db2.Database.GetDbConnection()).ProcessID);
        var claims = await Task.WhenAll(Processor(f, one.ServiceProvider).ClaimOutbox(default), Processor(f, two.ServiceProvider).ClaimOutbox(default));
        var all = claims.SelectMany(x => x).ToArray(); Assert.Equal(all.Length, all.Select(x => x.Id).Distinct().Count());
        foreach (var claim in all) await Task.WhenAll(Process(f, p => p.ProcessOutbox(claim, default)), Process(f, p => p.ProcessOutbox(claim, default)));
        Assert.Single((await Inbox(f, f.Manager)).Items); Assert.Equal(1, await f.Db(db => db.Set<PushDelivery>().CountAsync()));
        Assert.All(await f.Db(db => db.Set<PlanningOutbox>().ToArrayAsync()), o => Assert.Contains(o.State, new[] { ProcessingState.Processed, ProcessingState.Ignored }));
        var duplicate = await f.Db(db => db.Set<InboxNotification>().AsNoTracking().SingleAsync()); duplicate.Id = Guid.NewGuid();
        var error = await Assert.ThrowsAsync<DbUpdateException>(() => f.Db(async db => { db.Add(duplicate); return await db.SaveChangesAsync(); }));
        Assert.Equal(PostgresErrorCodes.UniqueViolation, Assert.IsType<PostgresException>(error.InnerException).SqlState);
    }

    [Fact]
    public async Task ExpiredLeaseRecoversAfterCrashAndOldWorkerCannotCommit()
    {
        await using var f = new Scenario(); await f.Init(); await f.Submit((await f.Draft()).ContextId);
        var old = await Process(f, p => p.ClaimOutbox(default)); Assert.NotEmpty(old);
        Assert.Empty(await Process(f, p => p.ClaimOutbox(default)));
        f.Identity.Clock.Advance(TimeSpan.FromSeconds(121));
        var next = await Process(f, p => p.ClaimOutbox(default)); Assert.Equal(old.Length, next.Length);
        foreach (var claim in old) await Process(f, p => p.ProcessOutbox(claim, default)); Assert.Empty((await Inbox(f, f.Manager)).Items);
        foreach (var claim in next) await Process(f, p => p.ProcessOutbox(claim, default)); Assert.Single((await Inbox(f, f.Manager)).Items);
    }

    [Fact]
    public async Task NotificationAndPushIntentCreationRollBackTogetherThenRecover()
    {
        await using var f = new Scenario(); await f.Init(); await Device(f, f.Manager); await f.Submit((await f.Draft()).ContextId);
        await f.Db(db => db.Database.ExecuteSqlRawAsync("CREATE FUNCTION reject_push() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'synthetic'; END $$; CREATE TRIGGER reject_push BEFORE INSERT ON \"PushDelivery\" FOR EACH ROW EXECUTE FUNCTION reject_push();"));
        await Drain(f);
        Assert.Equal(0, await f.Db(db => db.Set<InboxNotification>().CountAsync())); Assert.Equal(0, await f.Db(db => db.Set<PushDelivery>().CountAsync()));
        var pending = await f.Db(db => db.Set<PlanningOutbox>().SingleAsync(x => x.Type == "planning.submitted")); Assert.Equal(ProcessingState.Pending, pending.State); Assert.Null(pending.ProcessedAt);
        await f.Db(db => db.Database.ExecuteSqlRawAsync("DROP TRIGGER reject_push ON \"PushDelivery\"; DROP FUNCTION reject_push();"));
        f.Identity.Clock.Advance(TimeSpan.FromSeconds(11)); await Drain(f);
        Assert.Equal(1, await f.Db(db => db.Set<InboxNotification>().CountAsync())); Assert.Equal(1, await f.Db(db => db.Set<PushDelivery>().CountAsync()));
        await Drain(f); Assert.Equal(1, await f.Db(db => db.Set<PushDelivery>().CountAsync()));
    }

    [Fact]
    public async Task ProviderFailureNeverLosesInboxAndRetryExhaustionIsObservableAndRecoverable()
    {
        await using var f = new Scenario(); await f.Init(); await Device(f, f.Manager); await f.Submit((await f.Draft()).ContextId); await Drain(f);
        var provider = new TestPush(new(false, Code: "synthetic_unavailable"));
        for (var attempt = 0; attempt < 5; attempt++)
        {
            var claim = await Process(f, p => p.ClaimPush(default)); Assert.NotNull(claim);
            await Process(f, p => p.ProcessPush(claim!, default), provider); f.Identity.Clock.Advance(TimeSpan.FromSeconds(161));
        }
        Assert.Equal(5, provider.Calls); var delivery = await f.Db(db => db.Set<PushDelivery>().SingleAsync());
        Assert.Equal(PushState.Failed, delivery.State); Assert.Single((await Inbox(f, f.Manager)).Items);
        Assert.Equal(1, (await Notify(f, s => s.Operations(f.Identity.Admin.Id, default))).PushFailed);
        await Error(403, "forbidden", () => Notify(f, s => s.Retry(f.Manager, new(delivery.Id, true), default)));
        await Notify(f, s => s.Retry(f.Identity.Admin.Id, new(delivery.Id, true), default));
        var retry = await Process(f, p => p.ClaimPush(default)); await Process(f, p => p.ProcessPush(retry!, default));
        delivery = await f.Db(db => db.Set<PushDelivery>().SingleAsync()); Assert.Equal(PushState.Simulated, delivery.State); Assert.Null(delivery.ProviderAcceptedAt); Assert.Null(delivery.DeviceReportedAt);
    }

    [Fact]
    public async Task ProviderAcceptanceAndCrashBeforeResultCanCauseRetryButNotDuplicateInternalNotification()
    {
        await using var f = new Scenario(); await f.Init(); await Device(f, f.Manager); await f.Submit((await f.Draft()).ContextId); await Drain(f);
        var first = await Process(f, p => p.ClaimPush(default)); Assert.NotNull(first);
        // Simulated external acceptance followed by process loss: no result is persisted by that worker.
        var provider = new TestPush(new(true)); await provider.Send(PushProvider.Local, "local:syntheticaddress", Guid.NewGuid(), default);
        f.Identity.Clock.Advance(TimeSpan.FromSeconds(121)); var second = await Process(f, p => p.ClaimPush(default)); Assert.NotNull(second);
        await Process(f, p => p.ProcessPush(first!, default), provider); Assert.Equal(1, provider.Calls);
        await Process(f, p => p.ProcessPush(second!, default), provider); Assert.Equal(2, provider.Calls);
        var delivery = await f.Db(db => db.Set<PushDelivery>().SingleAsync()); Assert.Equal(PushState.ProviderAccepted, delivery.State); Assert.NotNull(delivery.ProviderAcceptedAt); Assert.Null(delivery.DeviceReportedAt);
        Assert.Single((await Inbox(f, f.Manager)).Items);
    }

    [Fact]
    public async Task DeviceRotationOwnershipLogoutAndInvalidAddressPreventStaleDelivery()
    {
        await using var f = new Scenario(); await f.Init(); var device = await Device(f, f.Manager); await f.Submit((await f.Draft()).ContextId); await Drain(f);
        await Error(409, "device_owned_by_other_account", () => Device(f, f.Employee, device.InstallationId));
        await Error(400, "invalid_device_address", () => Device(f, f.Manager, address: "invalid address with spaces"));
        await Error(412, "stale_version", () => Device(f, f.Manager, device.InstallationId, version: 99));
        var rotated = await Device(f, f.Manager, device.InstallationId, version: device.Version); Assert.Equal(2, rotated.Version);
        var sender = new TestPush(new(true)); var claim = await Process(f, p => p.ClaimPush(default)); await Process(f, p => p.ProcessPush(claim!, default), sender); Assert.Equal(0, sender.Calls);
        await Notify(f, s => s.RemoveDevice(f.Employee, device.InstallationId, default)); Assert.True(await f.Db(db => db.Set<PushDevice>().Select(d => d.Active).SingleAsync()));
        await Notify(f, s => s.RemoveDevice(f.Manager, device.InstallationId, default)); await Notify(f, s => s.RemoveDevice(f.Manager, device.InstallationId, default));
        var row = await f.Db(db => db.Set<PushDevice>().SingleAsync()); Assert.False(row.Active); Assert.Empty(row.ProtectedAddress);
        var shared = "local:" + Guid.NewGuid().ToString("N"); await Device(f, f.Manager, address: shared);
        await Error(409, "device_address_in_use", () => Device(f, f.Employee, address: shared));
    }

    [Fact]
    public async Task RemovedRelationshipHidesNotificationsAndSuppressesPushAndMissingContextHasSafeFallback()
    {
        await using var f = new Scenario(); await f.Init(); await Device(f, f.Manager); var request = await f.Submit((await f.Draft()).ContextId); await Drain(f);
        var notification = Assert.Single((await Inbox(f, f.Manager)).Items);
        await f.Db(async db => { db.ReportingLines.Remove(await db.ReportingLines.SingleAsync(x => x.EmployeeId == f.Employee)); return await db.SaveChangesAsync(); });
        Assert.Empty((await Inbox(f, f.Manager)).Items); Assert.Equal(0, (await Notify(f, s => s.Count(f.Manager, default))).UnreadCount);
        await Error(404, "notification_unavailable", () => Notify(f, s => s.Read(f.Manager, notification.Id, true, default)));
        var sender = new TestPush(new(true)); var claim = await Process(f, p => p.ClaimPush(default)); await Process(f, p => p.ProcessPush(claim!, default), sender); Assert.Equal(0, sender.Calls);
        await f.Db(async db => { db.ReportingLines.Add(new() { EmployeeId = f.Employee, ManagerId = f.Manager, OrganizationId = f.Identity.Employee.OrganizationId }); return await db.SaveChangesAsync(); });
        // Simulate operationally missing linked data without deleting the notification/history.
        await f.Db(db => db.Database.ExecuteSqlInterpolatedAsync($"DELETE FROM \"RequestedDays\" WHERE \"RequestId\"={request.Id}; DELETE FROM \"PlanningRequests\" WHERE \"Id\"={request.Id}"));
        var unavailable = await Notify(f, s => s.Detail(f.Manager, notification.Id, default)); Assert.Null(unavailable.Destination); Assert.Equal("context.unavailable", unavailable.EventType);
    }

    [Fact]
    public async Task HistoricalEventsAreArchivedWithoutPushOrNewUnreadBadgeAndPoisonEventsRemainVisible()
    {
        await using var f = new Scenario(); await f.Init(); await Device(f, f.Manager); await f.Submit((await f.Draft()).ContextId);
        await f.Db(db => db.Set<PlanningOutbox>().ExecuteUpdateAsync(s => s.SetProperty(x => x.Historical, true)));
        await Drain(f); Assert.Empty((await Inbox(f, f.Manager)).Items); Assert.Single((await Inbox(f, f.Manager, true)).Items);
        Assert.Equal(0, (await Notify(f, s => s.Count(f.Manager, default))).UnreadCount); Assert.Equal(0, await f.Db(db => db.Set<PushDelivery>().CountAsync()));
        await f.Db(async db =>
        {
            db.Set<PlanningOutbox>().Add(new()
            {
                Id = Guid.NewGuid(),
                EmployeeId = f.Employee,
                OrganizationId = f.Identity.Employee.OrganizationId,
                CalendarVersion = 900,
                Type = "planning.submitted",
                CreatedAt = f.Identity.Clock.GetUtcNow(),
                NextAttemptAt = f.Identity.Clock.GetUtcNow(),
                Payload = "{}"
            }); return await db.SaveChangesAsync();
        });
        await Drain(f); Assert.Equal(1, (await Notify(f, s => s.Operations(f.Identity.Admin.Id, default))).OutboxFailed);
    }
}
