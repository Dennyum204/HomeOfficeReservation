using System.Net;
using System.Net.Http.Json;
using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed class InvitationTests
{
    [Fact]
    public async Task RealMailKitLoopbackSmtpRecovers451AndLostAcknowledgementWithoutDuplicatingIdentity()
    {
        await using var smtp = new LocalSmtpCapture { Reject = true };
        await using var f = new IdentityFixture(); await f.InitializeAsync(smtpPort: smtp.Port); using var admin = await Admin(f);
        var i = await Invite(f, admin);
        Assert.Equal("delivery_failed", i.DeliveryError); Assert.Empty(smtp.Messages);
        smtp.Reject = false; smtp.LoseAcknowledgement = true; f.Clock.Advance(TimeSpan.FromMinutes(1));
        await Scope(f, async s => { await s.GetRequiredService<InvitationDelivery>().TryNow(i.MemberId); return true; });
        Assert.Single(smtp.Messages);
        Assert.Equal("delivery_failed", (await Page(admin)).Members.Single(m => m.MemberId == i.MemberId).DeliveryError);
        smtp.LoseAcknowledgement = false; f.Clock.Advance(TimeSpan.FromMinutes(2));
        await Scope(f, async s => { await s.GetRequiredService<InvitationDelivery>().TryNow(i.MemberId); return true; });
        Assert.Equal(2, smtp.Messages.Count); // SMTP has no exactly-once acknowledgement; a duplicate email is possible.
        var texts = smtp.Messages.Select(m => m.TextBody).ToArray(); var sameText = texts[0] == texts[1];
        Assert.True(sameText, "Ambiguous SMTP retry must keep the same code, without printing it.");
        Assert.Equal("Sent", (await Page(admin)).Members.Single(m => m.MemberId == i.MemberId).DeliveryState);
        Assert.Equal(1, await Db(f, db => db.Users.CountAsync(u => u.Email == Input().Email)));
        Assert.NotNull(texts[0]);
        var code = texts[0]!.Replace("\r\n", "\n", StringComparison.Ordinal).Split("\n\n")[1].Trim();
        Assert.Equal(HttpStatusCode.NoContent, (await Complete(f, code)).StatusCode);
    }

    private static ProvisionMemberRequest Input(string name = "invited") => new(name + "@test.example", "Synthetic invite", true, false, false);
    private static async Task<HttpClient> Admin(IdentityFixture f, string name = "admin")
    {
        var client = f.Client(); IdentityFixture.Bearer(client, await f.TokenLogin(client, name)); return client;
    }
    private static async Task<T> Scope<T>(IdentityFixture f, Func<IServiceProvider, Task<T>> action)
    {
        await using var scope = f.Factory.Services.CreateAsyncScope(); return await action(scope.ServiceProvider);
    }
    private static Task<T> Db<T>(IdentityFixture f, Func<HomeOfficeDbContext, Task<T>> action) => Scope(f, s => action(s.GetRequiredService<HomeOfficeDbContext>()));
    private static async Task<InvitationPage> Page(HttpClient admin, string query = "")
    {
        var response = await admin.GetAsync("/api/v1/admin/invitations" + query);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var text = await response.Content.ReadAsStringAsync();
        Assert.DoesNotContain("protectedCode", text); Assert.DoesNotContain("securityStamp", text); Assert.DoesNotContain("passwordHash", text);
        return (await response.Content.ReadFromJsonAsync<InvitationPage>())!;
    }
    private static async Task<InvitationProfile> Invite(IdentityFixture f, HttpClient admin, string name = "invited")
    {
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsJsonAsync("/api/v1/admin/members", Input(name))).StatusCode);
        return (await Page(admin)).Members.Single(m => m.Email == Input(name).Email);
    }
    private static Task<HttpResponseMessage> Change(HttpClient admin, InvitationProfile i, bool cancel, InvitationChangeRequest? command = null) =>
        admin.PostAsJsonAsync($"/api/v1/admin/members/{i.MemberId}/invitation/{(cancel ? "cancel" : "resend")}", command ?? new(Guid.NewGuid(), i.Version));
    private static Task<HttpResponseMessage> Complete(IdentityFixture f, string code, string name = "invited") =>
        f.Client().PostAsJsonAsync("/api/v1/auth/activation/complete", new { email = Input(name).Email, code, password = f.Password });

    [Fact]
    public async Task LostCreateResponseAndConcurrentRepeatsPreserveOneIdentityInvitationAndDelivery()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        var replies = await Task.WhenAll(Enumerable.Range(0, 3).Select(_ => admin.PostAsJsonAsync("/api/v1/admin/members", Input())));
        Assert.All(replies, r => Assert.Equal(HttpStatusCode.NoContent, r.StatusCode));
        var i = (await Page(admin)).Members.Single(m => m.Email == Input().Email);
        Assert.Equal("Pending", i.State); Assert.Equal("Sent", i.DeliveryState); Assert.Equal(1, i.DeliveryAttempts);
        Assert.Equal(1, f.Email.SentCount);
        Assert.Equal(1, await Db(f, db => db.Users.CountAsync(u => u.Email == Input().Email)));
        Assert.Equal(1, await Db(f, db => db.Set<AccessAudit>().CountAsync(a => a.Action == "access.member_provisioned")));
        var code = f.Email.Messages[Input().Email].Code;
        Assert.Equal(HttpStatusCode.NoContent, (await Complete(f, code)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await Complete(f, code)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsJsonAsync("/api/v1/admin/members", Input() with { Email = "INVITED@TEST.EXAMPLE" })).StatusCode);
        Assert.Equal(1, f.Email.SentCount);
        Assert.Equal(HttpStatusCode.BadRequest, (await admin.PostAsJsonAsync("/api/v1/admin/members", Input() with { IsAccountAdministrator = true })).StatusCode);
        i = (await Page(admin)).Members.Single(m => m.MemberId == i.MemberId);
        Assert.Equal("Accepted", i.State); Assert.True(i.EmailConfirmed); Assert.NotNull(i.AcceptedAt);
        Assert.Equal(HttpStatusCode.BadRequest, (await Change(admin, i, true)).StatusCode);
        using var browser = f.Client(); Assert.Equal(HttpStatusCode.NoContent, (await f.WebLogin(browser, "invited")).StatusCode);
        using var token = await Admin(f, "invited");
        Assert.Equal(HttpStatusCode.OK, (await token.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await token.GetAsync($"/api/v1/members/{i.MemberId}/management-access")).StatusCode);
    }

    [Fact]
    public async Task ResendRotatesIdentityCodeIsLimitedAndRecoversAnUncertainCommandWithoutAnotherSend()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        var i = await Invite(f, admin); var old = f.Email.Messages[i.Email].Code;
        Assert.Equal(HttpStatusCode.TooManyRequests, (await Change(admin, i, false)).StatusCode);
        f.Clock.Advance(TimeSpan.FromMinutes(1));
        var command = new InvitationChangeRequest(Guid.NewGuid(), i.Version);
        Assert.Equal(HttpStatusCode.NoContent, (await Change(admin, i, false, command)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Change(admin, i, false, command)).StatusCode);
        Assert.Equal(2, f.Email.SentCount);
        Assert.Equal(HttpStatusCode.Conflict, (await Change(admin, i, true, command)).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await Change(admin, i, true)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await Complete(f, old)).StatusCode);
        for (var n = 0; n < 3; n++)
        {
            f.Clock.Advance(TimeSpan.FromMinutes(1)); i = (await Page(admin)).Members.Single(m => m.Email == i.Email);
            Assert.Equal(HttpStatusCode.NoContent, (await Change(admin, i, false)).StatusCode);
        }
        f.Clock.Advance(TimeSpan.FromMinutes(1)); i = (await Page(admin)).Members.Single(m => m.Email == i.Email);
        Assert.Equal(HttpStatusCode.TooManyRequests, (await Change(admin, i, false)).StatusCode);
        using var anon = f.Client();
        Assert.Equal(HttpStatusCode.Accepted, (await anon.PostAsJsonAsync("/api/v1/auth/activation/request", new { email = i.Email })).StatusCode);
        Assert.Equal(5, f.Email.SentCount);
        Assert.Equal(4, await Db(f, db => db.Set<AccessAudit>().CountAsync(a => a.Action == "access.invitation_resent")));
        Assert.Equal(HttpStatusCode.NoContent, (await Complete(f, f.Email.Messages[i.Email].Code)).StatusCode);
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task CancellationOrDeactivationIsPermanentForTheInvitationAndAnonymousRequestsCannotRecoverIt(bool deactivate)
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        var i = await Invite(f, admin); var code = f.Email.Messages[i.Email].Code;
        var command = new InvitationChangeRequest(Guid.NewGuid(), i.Version);
        var response = deactivate ? await admin.PutAsJsonAsync($"/api/v1/admin/members/{i.MemberId}", new UpdateMemberRequest(false, true, false, false)) : await Change(admin, i, true, command);
        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
        if (!deactivate) Assert.Equal(HttpStatusCode.NoContent, (await Change(admin, i, true, command)).StatusCode);
        i = (await Page(admin)).Members.Single(m => m.MemberId == i.MemberId);
        Assert.Equal("Cancelled", i.State); Assert.False(i.Active); Assert.NotNull(i.CancelledAt);
        Assert.Equal(HttpStatusCode.BadRequest, (await Complete(f, code)).StatusCode);
        f.Clock.Advance(TimeSpan.FromDays(2));
        IdentityFixture.Bearer(admin, await f.TokenLogin(admin, "admin"));
        using var anon = f.Client();
        foreach (var email in new[] { i.Email, "never-created@test.example" })
            Assert.Equal(HttpStatusCode.Accepted, (await anon.PostAsJsonAsync("/api/v1/auth/activation/request", new { email })).StatusCode);
        Assert.Equal(1, f.Email.SentCount);
        Assert.Equal(HttpStatusCode.BadRequest, (await Change(admin, i, false)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{i.MemberId}", new UpdateMemberRequest(true, true, false, false))).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PostAsJsonAsync("/api/v1/admin/members", Input())).StatusCode); // Replay is a receipt, never reopening.
        Assert.Equal(1, await Db(f, db => db.Set<AccessInvitation>().CountAsync()));
        Assert.Null(await Db(f, db => db.Set<AccessInvitation>().Select(x => x.ProtectedCode).SingleAsync()));
        Assert.Equal(1, await Db(f, db => db.Set<AccessAudit>().CountAsync(a => a.Action == "access.invitation_cancelled")));
    }

    [Fact]
    public async Task ExpiredCodeDoesNotExpireTheInvitationAndNewCodeRecoversIt()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        var i = await Invite(f, admin); var code = f.Email.Messages[i.Email].Code;
        f.Clock.Advance(TimeSpan.FromHours(1));
        IdentityFixture.Bearer(admin, await f.TokenLogin(admin, "admin"));
        Assert.Equal(HttpStatusCode.BadRequest, (await Complete(f, code)).StatusCode);
        i = (await Page(admin)).Members.Single(m => m.MemberId == i.MemberId); Assert.Equal("Pending", i.State);
        Assert.Equal(HttpStatusCode.NoContent, (await Change(admin, i, false)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Complete(f, f.Email.Messages[i.Email].Code)).StatusCode);
    }

    [Fact]
    public async Task FrameworkTokenExpiryIsAlsoEnforcedIndependentlyOfInvitationClock()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(shortCodes: true); using var admin = await Admin(f);
        var i = await Invite(f, admin); await Task.Delay(50);
        Assert.Equal(HttpStatusCode.BadRequest, (await Complete(f, f.Email.Messages[i.Email].Code)).StatusCode);
        Assert.False(await Db(f, db => db.Users.Where(u => u.Email == i.Email).Select(u => u.EmailConfirmed).SingleAsync()));
    }

    [Fact]
    public async Task ProtectedDurableDeliveryRecoversFailureAbandonedLeaseAndCompetingWorkers()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        f.Email.FailDelivery = true; var i = await Invite(f, admin);
        Assert.Equal("Pending", i.DeliveryState); Assert.Equal("delivery_failed", i.DeliveryError);
        var row = await Db(f, db => db.Set<AccessInvitation>().AsNoTracking().SingleAsync());
        Assert.NotNull(row.ProtectedCode); Assert.Equal(1, row.Attempts);
        var originalCode = await Scope(f, s => Task.FromResult(s.GetRequiredService<IDataProtectionProvider>()
            .CreateProtector("HomeOffice.InvitationDelivery.v1", i.MemberId.ToString()).Unprotect(row.ProtectedCode!)));
        Assert.False(string.Equals(originalCode, row.ProtectedCode, StringComparison.Ordinal));
        f.Clock.Advance(TimeSpan.FromMinutes(1));
        var abandoned = await Scope(f, s => s.GetRequiredService<InvitationDelivery>().Claim()); Assert.NotNull(abandoned);
        Assert.Null(await Scope(f, s => s.GetRequiredService<InvitationDelivery>().Claim()));
        f.Clock.Advance(TimeSpan.FromMinutes(2)); f.Email.FailDelivery = false;
        var claims = await Task.WhenAll(Enumerable.Range(0, 2).Select(_ => Scope(f, s => s.GetRequiredService<InvitationDelivery>().Claim())));
        Assert.Single(claims, c => c is not null);
        await Scope(f, async s => { await s.GetRequiredService<InvitationDelivery>().Process(abandoned!); return true; });
        Assert.Equal(0, f.Email.SentCount);
        await Scope(f, async s => { await s.GetRequiredService<InvitationDelivery>().Process(claims.Single(c => c is not null)!); return true; });
        Assert.Equal(1, f.Email.SentCount);
        var sameCode = string.Equals(originalCode, f.Email.Messages[i.Email].Code, StringComparison.Ordinal);
        Assert.True(sameCode, "Retry must deliver the same protected Identity code; never print its value.");
        i = (await Page(admin)).Members.Single(m => m.MemberId == i.MemberId);
        Assert.Equal("Sent", i.DeliveryState); Assert.Equal(3, i.DeliveryAttempts); Assert.Null(i.DeliveryError);
        Assert.Null(await Db(f, db => db.Set<AccessInvitation>().Select(x => x.ProtectedCode).SingleAsync()));
        Assert.Equal(HttpStatusCode.NoContent, (await Complete(f, originalCode)).StatusCode);
    }

    [Fact]
    public async Task ExhaustedDeliveryIsVisibleAndAdministrativeResendRecoversWithoutAnotherMember()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        f.Email.FailDelivery = true; var i = await Invite(f, admin);
        for (var n = 0; n < 4; n++)
        {
            f.Clock.Advance(TimeSpan.FromMinutes(2 * (1 << n)));
            await Scope(f, async s => { await s.GetRequiredService<InvitationDelivery>().TryNow(i.MemberId); return true; });
        }
        IdentityFixture.Bearer(admin, await f.TokenLogin(admin, "admin"));
        i = (await Page(admin)).Members.Single(m => m.MemberId == i.MemberId);
        Assert.Equal("Failed", i.DeliveryState); Assert.Equal(5, i.DeliveryAttempts); Assert.NotNull(i.DeliveryError);
        f.Email.FailDelivery = false; Assert.Equal(HttpStatusCode.NoContent, (await Change(admin, i, false)).StatusCode);
        Assert.Equal(1, await Db(f, db => db.Set<AccessInvitation>().CountAsync()));
        Assert.Equal(HttpStatusCode.NoContent, (await Complete(f, f.Email.Messages[i.Email].Code)).StatusCode);
    }

    [Fact]
    public async Task AdministrativeStatesPaginationAndRelationshipsAreOrganizationScopedAndCurrent()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        var i = await Invite(f, admin);
        using var stranger = await Admin(f, "stranger"); using var employee = await Admin(f, "employee");
        Assert.Equal(HttpStatusCode.Forbidden, (await employee.GetAsync("/api/v1/admin/invitations")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await employee.PostAsJsonAsync("/api/v1/admin/members", Input("no-authority"))).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await Change(stranger, i, true)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await stranger.PostAsJsonAsync("/api/v1/admin/members", Input())).StatusCode);
        Assert.DoesNotContain((await Page(stranger)).Members, m => m.MemberId == i.MemberId);
        var first = await Page(admin, "?limit=2"); var second = await Page(admin, $"?limit=2&after={first.NextAfter}");
        Assert.NotNull(first.NextAfter); Assert.Null(second.NextAfter); Assert.Equal(4, first.Members.Concat(second.Members).Select(m => m.MemberId).Distinct().Count());
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{i.MemberId}/manager", new SetManagerRequest(f.Manager.Id))).StatusCode);
        i = (await Page(admin)).Members.Single(m => m.MemberId == i.MemberId);
        Assert.Equal(f.Manager.Id, i.ManagerId); Assert.True(i.ManagerRelationshipValid);
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{f.Manager.Id}", new UpdateMemberRequest(true, true, false, false))).StatusCode);
        Assert.False((await Page(admin)).Members.Single(m => m.MemberId == i.MemberId).ManagerRelationshipValid);
        // A stale in-memory actor cannot administer after current authority is removed.
        await Db(f, db => db.Members.Where(m => m.Id == f.Admin.Id).ExecuteUpdateAsync(s => s.SetProperty(m => m.Active, false)));
        Assert.False((await Scope(f, s => s.GetRequiredService<AccountProvisioner>().ProvisionAsync(f.Admin, Input("stale-admin")))).Succeeded);
        Assert.Equal(HttpStatusCode.Forbidden, (await Change(admin, i, true)).StatusCode);
    }

    [Fact]
    public async Task CancellationAndAcceptanceSerializeSoAnOldCodeCanNeverReopenACancelledMember()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        var i = await Invite(f, admin); var code = f.Email.Messages[i.Email].Code;
        var responses = await Task.WhenAll(Change(admin, i, true), Complete(f, code));
        Assert.Single(responses, r => r.StatusCode == HttpStatusCode.NoContent);
        i = (await Page(admin)).Members.Single(m => m.MemberId == i.MemberId);
        Assert.True(i.State is "Accepted" or "Cancelled");
        Assert.Equal(i.State == "Accepted", i.EmailConfirmed);
        Assert.Equal(HttpStatusCode.BadRequest, (await Complete(f, code)).StatusCode);
        Assert.Equal(1, await Db(f, db => db.Set<AccessAudit>().CountAsync(a => a.Action == "access.invitation_cancelled" || a.Action == "access.invitation_accepted")));
    }
}
