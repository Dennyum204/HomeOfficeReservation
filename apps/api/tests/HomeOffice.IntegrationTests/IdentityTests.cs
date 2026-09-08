using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using HomeOffice.Application.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed class IdentityTests
{
    [Fact]
    public async Task EncryptedPersistentKeysAllowAnotherHostToReadExistingFrameworkTickets()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        using var first = f.Client(); var tokens = await f.TokenLogin(first);
        using var login = await f.WebLogin(first);
        var cookie = string.Join("; ", login.Headers.GetValues("Set-Cookie").Select(value => value.Split(';')[0]));
        var keyFiles = Directory.GetFiles(Path.Combine(f.DirectoryPath, "keys"), "key-*.xml");
        Assert.NotEmpty(keyFiles);
        foreach (var path in keyFiles) Assert.Contains("encryptedSecret", await File.ReadAllTextAsync(path));
        // A new host/DI container must recover the on-disk encrypted key ring, not an in-memory provider.
        await using var second = f.Factory.WithWebHostBuilder(_ => { });
        using var bearerClient = second.CreateClient(new() { BaseAddress = new Uri("https://localhost") });
        IdentityFixture.Bearer(bearerClient, tokens);
        Assert.Equal(HttpStatusCode.OK, (await bearerClient.GetAsync("/api/v1/me")).StatusCode);
        using var cookieClient = second.CreateClient(new() { BaseAddress = new Uri("https://localhost"), HandleCookies = false });
        cookieClient.DefaultRequestHeaders.Add("Cookie", cookie);
        Assert.Equal(HttpStatusCode.OK, (await cookieClient.GetAsync("/api/v1/me")).StatusCode);
    }

    [Fact]
    public async Task BrowserCookiesRequireCsrfAndExpireThroughTheFramework()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(production: true);
        using var client = f.Client();
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsJsonAsync("/api/v1/auth/web/login", new { email = "employee@test.example", password = f.Password })).StatusCode);
        using var login = await f.WebLogin(client);
        Assert.Equal(HttpStatusCode.NoContent, login.StatusCode);
        var cookie = string.Join(";", login.Headers.GetValues("Set-Cookie")).ToLowerInvariant();
        Assert.Contains("httponly", cookie); Assert.Contains("secure", cookie); Assert.Contains("samesite=lax", cookie);
        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsync("/api/v1/auth/logout", null)).StatusCode);
        using var logout = new HttpRequestMessage(HttpMethod.Post, "/api/v1/auth/logout"); logout.Headers.Add("X-CSRF-TOKEN", await f.Csrf(client));
        Assert.Equal(HttpStatusCode.NoContent, (await client.SendAsync(logout)).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await f.WebLogin(client)).StatusCode);
        f.Clock.Advance(TimeSpan.FromHours(7));
        using var activeSession = await client.GetAsync("/api/v1/me");
        Assert.Equal(HttpStatusCode.OK, activeSession.StatusCode);
        Assert.False(activeSession.Headers.Contains("Set-Cookie"));
        f.Clock.Advance(TimeSpan.FromHours(2));
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/v1/me")).StatusCode);
    }

    [Fact]
    public async Task BearerAndRefreshExpirationUseFrameworkTicketsAndBoundedLifetimes()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var client = f.Client();
        var original = await f.TokenLogin(client); IdentityFixture.Bearer(client, original);
        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/api/v1/me")).StatusCode);
        f.Clock.Advance(TimeSpan.FromMinutes(16));
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/v1/me")).StatusCode);
        using var refresh = await client.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = original.GetProperty("refreshToken").GetString() });
        Assert.Equal(HttpStatusCode.OK, refresh.StatusCode);
        var renewed = JsonDocument.Parse(await refresh.Content.ReadAsStringAsync()).RootElement;
        IdentityFixture.Bearer(client, renewed);
        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/api/v1/me")).StatusCode);
        f.Clock.Advance(TimeSpan.FromDays(8));
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = renewed.GetProperty("refreshToken").GetString() })).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = "invalid" })).StatusCode);
    }

    [Fact]
    public async Task CurrentMembershipAndRelationshipDenyIsolationAndPrivilegeEscalation()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        using var employee = f.Client(); using var manager = f.Client(); using var admin = f.Client();
        var employeeTokens = await f.TokenLogin(employee);
        IdentityFixture.Bearer(employee, employeeTokens);
        using var browser = f.Client(); Assert.Equal(HttpStatusCode.NoContent, (await f.WebLogin(browser)).StatusCode);
        IdentityFixture.Bearer(manager, await f.TokenLogin(manager, "manager"));
        IdentityFixture.Bearer(admin, await f.TokenLogin(admin, "admin"));
        foreach (var client in new[] { employee, manager, admin })
            Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync($"/api/v1/members/{f.Stranger.Id}")).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await manager.GetAsync($"/api/v1/members/{f.Employee.Id}/management-access")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await manager.GetAsync($"/api/v1/members/{f.Manager.Id}/management-access")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.GetAsync($"/api/v1/members/{f.Employee.Id}/management-access")).StatusCode);
        var memberList = await employee.GetFromJsonAsync<MemberList>("/api/v1/members"); Assert.Single(memberList!.Members);
        var provision = new { email = "new@test.example", displayName = "New", isEmployee = true, isManager = true, isAccountAdministrator = true };
        Assert.Equal(HttpStatusCode.Forbidden, (await employee.PostAsJsonAsync("/api/v1/admin/members", provision)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await manager.PostAsJsonAsync("/api/v1/admin/members", provision)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{f.Stranger.Id}", new UpdateMemberRequest(false, true, true, true))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{f.Manager.Id}/manager", new SetManagerRequest(f.Manager.Id))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await admin.PostAsJsonAsync("/api/v1/admin/members", new { provision.email, provision.displayName, provision.isEmployee, provision.isManager, provision.isAccountAdministrator, organizationId = f.Stranger.OrganizationId })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await employee.PostAsJsonAsync("/api/v1/auth/register", provision)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{f.Employee.Id}", new UpdateMemberRequest(false, true, false, false))).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await employee.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await browser.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await employee.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = employeeTokens.GetProperty("refreshToken").GetString() })).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await manager.GetAsync($"/api/v1/members/{f.Employee.Id}/management-access")).StatusCode);
    }

    [Fact]
    public async Task ActivationRecoveryAndSecurityStampRejectReuseWithoutInventingAccessTokenRevocation()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync();
        using var admin = f.Client(); IdentityFixture.Bearer(admin, await f.TokenLogin(admin, "admin"));
        using var anon = f.Client(); var address = "invited@test.example";
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsJsonAsync("/api/v1/admin/members", new ProvisionMemberRequest(address, "Invited", true, false, false))).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await anon.PostAsJsonAsync("/api/v1/auth/token/login", new { email = address, password = f.Password })).StatusCode);
        var code = f.Email.Messages[address].Code;
        Assert.Equal(HttpStatusCode.BadRequest, (await anon.PostAsJsonAsync("/api/v1/auth/activation/complete", new { email = address, code, password = "weak" })).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await anon.PostAsJsonAsync("/api/v1/auth/activation/complete", new { email = address, code, password = f.Password })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await anon.PostAsJsonAsync("/api/v1/auth/activation/complete", new { email = address, code, password = f.Password })).StatusCode);
        using var browser = f.Client(); Assert.Equal(HttpStatusCode.NoContent, (await f.WebLogin(browser)).StatusCode);
        using var mobile = f.Client(); var oldTokens = await f.TokenLogin(mobile); IdentityFixture.Bearer(mobile, oldTokens);
        using var known = await anon.PostAsJsonAsync("/api/v1/auth/recovery/request", new { email = "employee@test.example" });
        using var unknown = await anon.PostAsJsonAsync("/api/v1/auth/recovery/request", new { email = "absent@test.example" });
        Assert.Equal(known.StatusCode, unknown.StatusCode); Assert.Equal(await known.Content.ReadAsStringAsync(), await unknown.Content.ReadAsStringAsync());
        code = f.Email.Messages["employee@test.example"].Code;
        var nextPassword = "Changed9!" + Guid.NewGuid().ToString("N");
        Assert.Equal(HttpStatusCode.NoContent, (await anon.PostAsJsonAsync("/api/v1/auth/recovery/complete", new { email = "employee@test.example", code, password = nextPassword })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await anon.PostAsJsonAsync("/api/v1/auth/recovery/complete", new { email = "employee@test.example", code, password = nextPassword })).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await browser.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await mobile.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = oldTokens.GetProperty("refreshToken").GetString() })).StatusCode);
        // The built-in access handler does not query the security stamp; the 15-minute window is explicit.
        Assert.Equal(HttpStatusCode.OK, (await mobile.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await mobile.PostAsync("/api/v1/auth/logout", null)).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await mobile.GetAsync("/api/v1/me")).StatusCode); // Copied bearer is not server-revoked by local logout.
        f.Clock.Advance(TimeSpan.FromMinutes(16));
        Assert.Equal(HttpStatusCode.Unauthorized, (await mobile.GetAsync("/api/v1/me")).StatusCode);
    }

    [Fact]
    public async Task WrongCredentialsLockOutAndAnonymousAccountOperationsAreRateLimited()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var client = f.Client();
        for (var i = 0; i < 5; i++)
            Assert.Equal(HttpStatusCode.Unauthorized, (await client.PostAsJsonAsync("/api/v1/auth/token/login", new { email = "employee@test.example", password = "wrong" })).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.PostAsJsonAsync("/api/v1/auth/token/login", new { email = "employee@test.example", password = f.Password })).StatusCode);
        await using var scope = f.Factory.Services.CreateAsyncScope(); var users = scope.ServiceProvider.GetRequiredService<UserManager<IdentityUser>>();
        Assert.True(await users.IsLockedOutAsync((await users.FindByIdAsync(f.Employee.IdentityUserId))!));
        await using var limited = new IdentityFixture(); await limited.InitializeAsync(requestLimit: 2); using var attacker = limited.Client();
        for (var i = 0; i < 2; i++) Assert.Equal(HttpStatusCode.Accepted, (await attacker.PostAsJsonAsync("/api/v1/auth/recovery/request", new { email = "unknown@test.example" })).StatusCode);
        Assert.Equal(HttpStatusCode.TooManyRequests, (await attacker.PostAsJsonAsync("/api/v1/auth/recovery/request", new { email = "unknown@test.example" })).StatusCode);
    }

    [Fact]
    public async Task ExpiredSinglePurposeCodesCannotChangePasswords()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(shortCodes: true); using var client = f.Client();
        Assert.Equal(HttpStatusCode.Accepted, (await client.PostAsJsonAsync("/api/v1/auth/recovery/request", new { email = "employee@test.example" })).StatusCode);
        await Task.Delay(100); // Real framework wall-clock token expiry, separate from virtual session time tests.
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsJsonAsync("/api/v1/auth/recovery/complete", new { email = "employee@test.example", code = f.Email.Messages["employee@test.example"].Code, password = f.Password })).StatusCode);
    }
}
