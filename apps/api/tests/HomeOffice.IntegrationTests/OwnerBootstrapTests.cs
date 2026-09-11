using System.Diagnostics;
using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using HomeOffice.Api.Access;
using HomeOffice.Application.Access;
using HomeOffice.Application.Planning;
using HomeOffice.Domain.Access;
using HomeOffice.Domain.Planning;
using HomeOffice.Infrastructure.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Npgsql;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed class OwnerBootstrapTests
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web) { Converters = { new JsonStringEnumConverter() } };
    private static readonly BootstrapAccount Owner = new("HO-013 synthetic organization", "owner-ho013@test.example", "Synthetic owner");

    private static async Task Command(IdentityFixture f, string command, object input)
    {
        var file = Path.Combine(f.DirectoryPath, Guid.NewGuid() + ".json");
        await File.WriteAllTextAsync(file, JsonSerializer.Serialize(input, Json));
        Assert.True(await MaintenanceCommands.ExecuteAsync([command, file], f.Factory.Services, f.Factory.Services.GetRequiredService<IHostEnvironment>()));
    }

    private static async Task<T> Db<T>(IdentityFixture f, Func<HomeOfficeDbContext, Task<T>> action)
    {
        await using var scope = f.Factory.Services.CreateAsyncScope();
        return await action(scope.ServiceProvider.GetRequiredService<HomeOfficeDbContext>());
    }

    private static Task<Member> Find(IdentityFixture f, string email) => Db(f, db =>
        (from m in db.Members.AsNoTracking() join u in db.Users on m.IdentityUserId equals u.Id where u.Email == email select m).SingleAsync());

    private static async Task Activate(IdentityFixture f, string address)
    {
        using var anon = f.Client();
        var result = await anon.PostAsJsonAsync("/api/v1/auth/activation/complete", new { email = address, code = f.Email.Messages[address].Code, password = f.Password });
        Assert.Equal(HttpStatusCode.NoContent, result.StatusCode);
    }

    private static async Task<HttpResponseMessage> Write(IdentityFixture f, HttpClient client, string path, object body)
    {
        using var message = new HttpRequestMessage(HttpMethod.Post, path) { Content = JsonContent.Create(body, options: Json) };
        message.Headers.Add("Idempotency-Key", Guid.NewGuid().ToString("N"));
        message.Headers.Add("X-CSRF-TOKEN", await f.Csrf(client));
        return await client.SendAsync(message);
    }

    private static async Task<T> Read<T>(HttpResponseMessage response)
    {
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        return (await response.Content.ReadFromJsonAsync<T>(Json))!;
    }

    [Fact]
    public async Task ExplicitOwnerBootstrapReplaysWithoutDuplicateIdentityAuditOrEmailThenBrowserOwnerAndBearerChiefPlan()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        await Task.WhenAll(Command(f, "--bootstrap-owner", Owner), Command(f, "--bootstrap-owner", Owner));
        Assert.Equal(1, f.Email.SentCount);
        var owner = await Find(f, Owner.Email);
        Assert.True(owner.Active && owner.IsEmployee && owner.IsAccountAdministrator);
        Assert.False(owner.IsManager);
        Assert.False(await Db(f, db => db.Users.Where(u => u.Id == owner.IdentityUserId).Select(u => u.EmailConfirmed).SingleAsync()));
        await Activate(f, Owner.Email);
        var identityBefore = await IdentityFingerprint(f, owner.Id);
        var emailCount = f.Email.SentCount;
        // Two independent scopes/connections also exercise a replay after activation/password creation.
        await Task.WhenAll(Command(f, "--bootstrap-owner", Owner), Command(f, "--bootstrap-owner", Owner));
        Assert.Equal(emailCount, f.Email.SentCount);
        Assert.Equal(identityBefore, await IdentityFingerprint(f, owner.Id));
        Assert.Equal(owner.Id, (await Find(f, Owner.Email)).Id);
        Assert.Equal(1, await Db(f, db => db.Set<AccessAudit>().CountAsync(a => a.Action == "access.owner_bootstrapped")));

        using var ownerToken = f.Client(); IdentityFixture.Bearer(ownerToken, await f.TokenLogin(ownerToken, "owner-ho013"));
        using var ownerBrowser = f.Client(); Assert.Equal(HttpStatusCode.NoContent, (await f.WebLogin(ownerBrowser, "owner-ho013")).StatusCode);
        var profile = await Read<MemberProfile>(await ownerBrowser.GetAsync("/api/v1/me"));
        Assert.True(profile.IsEmployee && profile.IsAccountAdministrator && !profile.IsManager);
        Assert.Equal(HttpStatusCode.BadRequest, (await ownerToken.PutAsJsonAsync($"/api/v1/admin/members/{owner.Id}", new UpdateMemberRequest(true, true, true, true))).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await ownerToken.PostAsJsonAsync("/api/v1/admin/members",
            new ProvisionMemberRequest("chief-ho013@test.example", "Synthetic chief", false, true, false))).StatusCode);
        await Activate(f, "chief-ho013@test.example");
        var chief = await Find(f, "chief-ho013@test.example");
        using var chiefToken = f.Client(); IdentityFixture.Bearer(chiefToken, await f.TokenLogin(chiefToken, "chief-ho013"));
        // Having the manager role alone does not confer a relationship or access.
        Assert.Equal(HttpStatusCode.Forbidden, (await chiefToken.GetAsync($"/api/v1/members/{owner.Id}/management-access")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await ownerToken.PutAsJsonAsync($"/api/v1/admin/members/{owner.Id}/manager", new SetManagerRequest(chief.Id))).StatusCode);

        var day = PlanningRules.Today(f.Clock.GetUtcNow(), "Europe/Zurich").AddDays(14);
        var url = $"/api/v1/planning/{owner.Id}";
        var calendar = await Read<CalendarView>(await ownerBrowser.GetAsync($"{url}/calendar?from={day:yyyy-MM-dd}&to={day:yyyy-MM-dd}"));
        var draft = await Read<MutationReceipt>(await Write(f, ownerBrowser, url + "/requests",
            new DraftInput(calendar.CalendarVersion, null, null, "Synthetic owner request", [new(day, WorkLocation.RemotePortugal, Availability.Working)])));
        var submitted = await Read<MutationReceipt>(await Write(f, ownerBrowser, $"{url}/requests/{draft.ContextId}/submit", new SubmitInput(draft.CalendarVersion, draft.Version)));
        var request = await Read<RequestView>(await chiefToken.GetAsync($"{url}/requests/{draft.ContextId}"));
        var decision = new DecisionInput(submitted.CalendarVersion, request.Version, request.Days.Select(d => new SelectedDay(d.Id, d.Version)).ToArray(), true, null);
        Assert.Equal(HttpStatusCode.Forbidden, (await Write(f, ownerBrowser, $"{url}/requests/{draft.ContextId}/decide", decision)).StatusCode);
        await Read<MutationReceipt>(await Write(f, chiefToken, $"{url}/requests/{draft.ContextId}/decide", decision));
        var approved = await Read<CalendarView>(await ownerToken.GetAsync($"{url}/calendar?from={day:yyyy-MM-dd}&to={day:yyyy-MM-dd}"));
        Assert.Equal(WorkLocation.RemotePortugal, approved.EffectiveDays.Single().Location);
        Assert.Equal(draft.ContextId, approved.EffectiveDays.Single().SourceRequestId);
        using var stranger = f.Client(); IdentityFixture.Bearer(stranger, await f.TokenLogin(stranger, "stranger"));
        Assert.Equal(HttpStatusCode.Forbidden, (await stranger.GetAsync($"{url}/calendar?from={day:yyyy-MM-dd}&to={day:yyyy-MM-dd}")).StatusCode);
        using var anon = f.Client();
        Assert.Equal(HttpStatusCode.Unauthorized, (await anon.GetAsync($"{url}/calendar?from={day:yyyy-MM-dd}&to={day:yyyy-MM-dd}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await anon.PostAsJsonAsync("/api/v1/admin/bootstrap-owner", Owner)).StatusCode);
    }

    [Fact]
    public async Task FailedActivationDeliveryKeepsCommittedOwnerAndRecoversThroughExistingActivationRequest()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        f.Email.FailDelivery = true;
        await Command(f, "--bootstrap-owner", Owner);
        Assert.Equal("delivery_failed", await Db(f, db => db.Set<AccessInvitation>().Select(i => i.LastError).SingleAsync()));
        var owner = await Find(f, Owner.Email);
        var identityBefore = await IdentityFingerprint(f, owner.Id);
        f.Email.FailDelivery = false;
        await Command(f, "--bootstrap-owner", Owner);
        Assert.Equal(0, f.Email.SentCount); // Replaying a committed bootstrap never resends or replaces an identity.
        Assert.Equal(identityBefore, await IdentityFingerprint(f, owner.Id));
        Assert.Equal(1, await Db(f, db => db.Set<AccessAudit>().CountAsync(a => a.Action == "access.owner_bootstrapped")));
        using var anon = f.Client();
        f.Clock.Advance(TimeSpan.FromMinutes(1)); // HO-014 persists resend cooldown, including anonymous requests.
        Assert.Equal(HttpStatusCode.Accepted, (await anon.PostAsJsonAsync("/api/v1/auth/activation/request", new { email = Owner.Email })).StatusCode);
        await Activate(f, Owner.Email);
        Assert.Equal(HttpStatusCode.NoContent, (await f.WebLogin(anon, "owner-ho013")).StatusCode);
    }

    [Fact]
    public async Task LegacyBootstrapStaysAdministratorOnlyAndEmployeeUpgradePreservesPendingActivation()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        await Command(f, "--bootstrap-admin", Owner);
        var owner = await Find(f, Owner.Email);
        Assert.True(owner.IsAccountAdministrator); Assert.False(owner.IsEmployee || owner.IsManager);
        var before = await IdentityFingerprint(f, owner.Id);
        var emailCount = f.Email.SentCount;
        await Assert.ThrowsAsync<InvalidOperationException>(() => Command(f, "--bootstrap-admin", Owner));
        await Assert.ThrowsAsync<InvalidOperationException>(() => Command(f, "--bootstrap-owner", Owner));
        await Command(f, "--enable-admin-employee", new EnableAdminEmployee(owner.OrganizationId, owner.Id, "Synthetic legacy owner upgrade"));
        await Command(f, "--enable-admin-employee", new EnableAdminEmployee(owner.OrganizationId, owner.Id, "Repeated operation"));
        Assert.Equal(before, await IdentityFingerprint(f, owner.Id));
        Assert.Equal(emailCount, f.Email.SentCount);
        var upgraded = await Find(f, Owner.Email);
        Assert.True(upgraded.IsEmployee && upgraded.IsAccountAdministrator && upgraded.Active); Assert.False(upgraded.IsManager);
        var audit = await Db(f, db => db.Set<AccessAudit>().SingleAsync(a => a.Action == "access.admin_employee_enabled"));
        Assert.Null(audit.ActorMemberId); Assert.Equal("operator", audit.Source);
        Assert.Equal("Synthetic legacy owner upgrade", audit.Reason);
        Assert.False(JsonDocument.Parse(audit.BeforeJson).RootElement.GetProperty("isEmployee").GetBoolean());
        Assert.True(JsonDocument.Parse(audit.AfterJson).RootElement.GetProperty("isEmployee").GetBoolean());
        await Activate(f, Owner.Email); // The exact code captured before the role change remains valid.
        using var browser = f.Client(); Assert.Equal(HttpStatusCode.NoContent, (await f.WebLogin(browser, "owner-ho013")).StatusCode);
        using var mobile = f.Client(); IdentityFixture.Bearer(mobile, await f.TokenLogin(mobile, "owner-ho013"));
        Assert.Equal(HttpStatusCode.OK, (await mobile.GetAsync("/api/v1/me")).StatusCode);
    }

    [Fact]
    public async Task UpgradingExistingAdministratorPreservesCalendarRelationshipsPasswordsAndLiveSessions()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        using var admin = f.Client(); IdentityFixture.Bearer(admin, await f.TokenLogin(admin, "admin"));
        // Synthetic legacy scenario: this employee had planned days before their employee capability was removed.
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{f.Employee.Id}", new UpdateMemberRequest(true, true, false, true))).StatusCode);
        await using (var scope = f.Factory.Services.CreateAsyncScope())
        {
            var planning = scope.ServiceProvider.GetRequiredService<IPlanningService>();
            var day = PlanningRules.Today(f.Clock.GetUtcNow(), "Europe/Zurich").AddDays(14);
            var draft = await planning.Draft(f.Employee.Id, f.Employee.Id, null, new(0, null, null, "Existing synthetic data", [new(day, WorkLocation.RemotePortugal, Availability.Working)]), Guid.NewGuid().ToString("N"), default);
            var submitted = await planning.Submit(f.Employee.Id, f.Employee.Id, draft.ContextId, new(draft.CalendarVersion, draft.Version), Guid.NewGuid().ToString("N"), default);
            var request = await planning.Request(f.Manager.Id, f.Employee.Id, draft.ContextId, default);
            await planning.Decide(f.Manager.Id, f.Employee.Id, request.Id, new(submitted.CalendarVersion, request.Version, request.Days.Select(d => new SelectedDay(d.Id, d.Version)).ToArray(), true, null), Guid.NewGuid().ToString("N"), default);
        }
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{f.Employee.Id}", new UpdateMemberRequest(true, false, false, true))).StatusCode);
        using var browser = f.Client(); Assert.Equal(HttpStatusCode.NoContent, (await f.WebLogin(browser)).StatusCode);
        using var mobile = f.Client(); var tokens = await f.TokenLogin(mobile); IdentityFixture.Bearer(mobile, tokens);
        var identityBefore = await IdentityFingerprint(f, f.Employee.Id);
        var dataBefore = await PlanningFingerprint(f);
        var memberBefore = await Find(f, "employee@test.example");
        var emailCount = f.Email.SentCount;
        var input = new EnableAdminEmployee(f.Employee.OrganizationId, f.Employee.Id, "Restore employee capability only");
        await Task.WhenAll(Command(f, "--enable-admin-employee", input), Command(f, "--enable-admin-employee", input));
        Assert.Equal(identityBefore, await IdentityFingerprint(f, f.Employee.Id));
        Assert.Equal(dataBefore, await PlanningFingerprint(f));
        Assert.Equal(emailCount, f.Email.SentCount);
        memberBefore.IsEmployee = true;
        Assert.Equal(JsonSerializer.Serialize(memberBefore), JsonSerializer.Serialize(await Find(f, "employee@test.example")));
        Assert.Equal(1, await Db(f, db => db.Set<AccessAudit>().CountAsync(a => a.Action == "access.admin_employee_enabled")));
        var profile = await Read<MemberProfile>(await browser.GetAsync("/api/v1/me"));
        Assert.True(profile.IsEmployee && profile.IsAccountAdministrator);
        Assert.Equal(HttpStatusCode.OK, (await mobile.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await mobile.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = tokens.GetProperty("refreshToken").GetString() })).StatusCode);
    }

    [Fact]
    public async Task InvalidOperatorSelectionsAndUnknownFieldsNeverElevateOrCreateAccounts()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        var input = new EnableAdminEmployee(f.Admin.OrganizationId, f.Admin.Id, "Synthetic reason");
        foreach (var invalid in new[] { input with { OrganizationId = Guid.Empty }, input with { MemberId = Guid.Empty },
            input with { OrganizationId = f.Stranger.OrganizationId }, input with { MemberId = f.Employee.Id },
            input with { MemberId = Guid.NewGuid() }, input with { Reason = " " }, input with { Reason = new string('x', 501) } })
            await Assert.ThrowsAsync<InvalidOperationException>(() => Command(f, "--enable-admin-employee", invalid));
        await Db(f, async db => { var other = await db.Members.FindAsync(f.Stranger.Id); other!.Active = false; return await db.SaveChangesAsync(); });
        await Assert.ThrowsAsync<InvalidOperationException>(() => Command(f, "--enable-admin-employee", input with { OrganizationId = f.Stranger.OrganizationId, MemberId = f.Stranger.Id }));
        await Assert.ThrowsAsync<JsonException>(() => Command(f, "--bootstrap-owner", new { Owner.OrganizationName, Owner.Email, Owner.DisplayName, isManager = true }));
        await Assert.ThrowsAsync<InvalidOperationException>(() => MaintenanceCommands.ExecuteAsync(["--migrate", "--bootstrap-owner", "unused.json"], f.Factory.Services, f.Factory.Services.GetRequiredService<IHostEnvironment>()));
        Assert.False((await Find(f, "admin@test.example")).IsEmployee);
        Assert.Equal(4, await Db(f, db => db.Members.CountAsync()));
        Assert.Equal(2, await Db(f, db => db.Organizations.CountAsync()));
        Assert.Equal(0, f.Email.SentCount);
        Assert.Equal(0, await Db(f, db => db.Set<AccessAudit>().CountAsync()));
    }

    [Fact]
    public async Task AllRolesStillDenySelfApprovalSelfAdministrationAndCrossOrganizationAccess()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        using var admin = f.Client(); IdentityFixture.Bearer(admin, await f.TokenLogin(admin, "admin"));
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{f.Manager.Id}", new UpdateMemberRequest(true, true, true, true))).StatusCode);
        using var allRoles = f.Client(); IdentityFixture.Bearer(allRoles, await f.TokenLogin(allRoles, "manager"));
        Assert.Equal(HttpStatusCode.BadRequest, (await allRoles.PutAsJsonAsync($"/api/v1/admin/members/{f.Manager.Id}", new UpdateMemberRequest(true, true, true, true))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await allRoles.PutAsJsonAsync($"/api/v1/admin/members/{f.Manager.Id}/manager", new SetManagerRequest(f.Manager.Id))).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await allRoles.GetAsync($"/api/v1/members/{f.Manager.Id}/management-access")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await allRoles.PutAsJsonAsync($"/api/v1/admin/members/{f.Stranger.Id}", new UpdateMemberRequest(false, false, false, false))).StatusCode);
        var own = $"/api/v1/planning/{f.Manager.Id}";
        var day = PlanningRules.Today(f.Clock.GetUtcNow(), "Europe/Zurich").AddDays(14);
        var draft = await Read<MutationReceipt>(await Write(f, allRoles, own + "/requests", new DraftInput(0, null, null, "Self decision denied", [new(day, WorkLocation.RemotePortugal, Availability.Working)])));
        var submitted = await Read<MutationReceipt>(await Write(f, allRoles, $"{own}/requests/{draft.ContextId}/submit", new SubmitInput(draft.CalendarVersion, draft.Version)));
        var request = await Read<RequestView>(await allRoles.GetAsync($"{own}/requests/{draft.ContextId}"));
        Assert.Equal(HttpStatusCode.Forbidden, (await Write(f, allRoles, $"{own}/requests/{request.Id}/decide",
            new DecisionInput(submitted.CalendarVersion, request.Version, request.Days.Select(d => new SelectedDay(d.Id, d.Version)).ToArray(), true, null))).StatusCode);
        Assert.Equal(0, await Db(f, db => db.Set<PlanDay>().CountAsync()));
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task ConcurrentAdministratorsCannotRemoveEachOthersLastActiveAuthority(bool deactivate)
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        using var adminClient = f.Client(); IdentityFixture.Bearer(adminClient, await f.TokenLogin(adminClient, "admin"));
        Assert.Equal(HttpStatusCode.NoContent, (await adminClient.PutAsJsonAsync($"/api/v1/admin/members/{f.Manager.Id}", new UpdateMemberRequest(true, true, true, true))).StatusCode);
        var a = await Find(f, "admin@test.example"); var b = await Find(f, "manager@test.example");
        await using var first = f.Factory.Services.CreateAsyncScope(); await using var second = f.Factory.Services.CreateAsyncScope();
        var db1 = first.ServiceProvider.GetRequiredService<HomeOfficeDbContext>(); var db2 = second.ServiceProvider.GetRequiredService<HomeOfficeDbContext>();
        await db1.Database.OpenConnectionAsync(); await db2.Database.OpenConnectionAsync();
        var pids = new[] { ((NpgsqlConnection)db1.Database.GetDbConnection()).ProcessID, ((NpgsqlConnection)db2.Database.GetDbConnection()).ProcessID };
        Assert.NotEqual(pids[0], pids[1]);
        // Hold the real DB lock until both independent commands are blocked with their old actor snapshots.
        await using var guard = f.Factory.Services.CreateAsyncScope(); var dbGuard = guard.ServiceProvider.GetRequiredService<HomeOfficeDbContext>();
        await using var tx = await dbGuard.Database.BeginTransactionAsync();
        await dbGuard.Organizations.FromSqlInterpolated($"SELECT * FROM \"Organizations\" WHERE \"Id\"={a.OrganizationId} FOR NO KEY UPDATE").ToListAsync();
        var edit = new UpdateMemberRequest(!deactivate, true, true, deactivate);
        var one = first.ServiceProvider.GetRequiredService<IMemberDirectory>().UpdateAsync(a, b.Id, edit);
        var two = second.ServiceProvider.GetRequiredService<IMemberDirectory>().UpdateAsync(b, a.Id, edit);
        var deadline = Stopwatch.StartNew(); var waiting = 0L;
        while (waiting != 2 && deadline.Elapsed < TimeSpan.FromSeconds(10))
        {
            waiting = await dbGuard.Database.SqlQuery<long>($"SELECT count(*) AS \"Value\" FROM pg_stat_activity WHERE pid = ANY({pids}) AND wait_event_type = 'Lock'").SingleAsync();
            if (waiting != 2) await Task.Delay(20);
        }
        Assert.Equal(2L, waiting);
        await tx.CommitAsync();
        var results = await Task.WhenAll(one, two).WaitAsync(TimeSpan.FromSeconds(10));
        Assert.Single(results, r => r.Succeeded);
        Assert.Equal("forbidden", Assert.Single(results, r => !r.Succeeded).Code);
        Assert.Equal(1, await Db(f, db => db.Members.CountAsync(m => m.OrganizationId == a.OrganizationId && m.Active && m.IsAccountAdministrator)));
        var winner = await Db(f, db => db.Members.AsNoTracking().SingleAsync(m => m.OrganizationId == a.OrganizationId && m.Active && m.IsAccountAdministrator));
        await using var scope = f.Factory.Services.CreateAsyncScope();
        var self = await scope.ServiceProvider.GetRequiredService<IMemberDirectory>().UpdateAsync(winner, winner.Id, edit);
        Assert.False(self.Succeeded); Assert.Equal("self_administration_denied", self.Code);
        var loser = winner.Id == a.Id ? b : a;
        // A stale actor cannot create another administrator or change reporting lines after being revoked.
        var create = await scope.ServiceProvider.GetRequiredService<AccountProvisioner>().ProvisionAsync(loser, new("unexpected@test.example", "Rejected", true, true, true));
        Assert.False(create.Succeeded); Assert.Equal("forbidden", create.Code);
        var assign = await scope.ServiceProvider.GetRequiredService<IMemberDirectory>().AssignManagerAsync(loser, f.Employee.Id, winner.Id);
        Assert.False(assign.Succeeded); Assert.Equal("forbidden", assign.Code);
        Assert.Equal(2, await Db(f, db => db.Set<AccessAudit>().CountAsync(audit => audit.Action == "access.member_updated")));
    }

    private static Task<string> IdentityFingerprint(IdentityFixture f, Guid member) => Db(f, async db =>
        Hash(await (from m in db.Members where m.Id == member join u in db.Users.AsNoTracking() on m.IdentityUserId equals u.Id select u).SingleAsync()));

    private static Task<string> PlanningFingerprint(IdentityFixture f) => Db(f, async db => Hash(new
    {
        Profiles = await db.Set<PlanningProfile>().AsNoTracking().ToArrayAsync(),
        Requests = await db.Set<PlanningRequest>().AsNoTracking().Include(r => r.Days).ToArrayAsync(),
        Plans = await db.Set<PlanDay>().AsNoTracking().ToArrayAsync(),
        Relations = await db.ReportingLines.AsNoTracking().OrderBy(r => r.EmployeeId).ToArrayAsync(),
        Audits = await db.Set<PlanningAudit>().AsNoTracking().OrderBy(a => a.Id).ToArrayAsync(),
        Outbox = await db.Set<PlanningOutbox>().AsNoTracking().OrderBy(a => a.Id).ToArrayAsync()
    }));

    // Test failures show fingerprints, never password hashes, framework tickets or calendar payloads.
    private static string Hash(object value) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(value))));
}
