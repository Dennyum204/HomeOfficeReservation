using System.Net;
using System.Net.Http.Json;
using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed class WebAdministrationTests
{
    private static async Task<HttpClient> Admin(IdentityFixture f)
    {
        var client = f.Client(); IdentityFixture.Bearer(client, await f.TokenLogin(client, "admin")); return client;
    }
    private static async Task<InvitationProfile> Read(HttpClient client, Guid id) =>
        (await client.GetFromJsonAsync<InvitationPage>("/api/v1/admin/invitations?limit=100"))!.Members.Single(m => m.MemberId == id);

    [Fact]
    public async Task RoleWritesRejectStaleVersionsAndExactReplayNeverRestoresAnOldState()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        var before = await Read(admin, f.Employee.Id);
        var path = $"/api/v1/admin/members/{f.Employee.Id}";
        var command = new UpdateMemberRequest(true, true, true, false, before.AccessVersion, Guid.NewGuid());
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync(path, command)).StatusCode);
        var updated = await Read(admin, f.Employee.Id);
        Assert.True(updated.AccessVersion > before.AccessVersion);
        Assert.Equal(HttpStatusCode.Conflict, (await admin.PutAsJsonAsync(path, command with { CommandId = Guid.NewGuid() })).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await admin.PutAsJsonAsync(path, command with { IsAccountAdministrator = true })).StatusCode);
        var suspend = command with { Active = false, ExpectedAccessVersion = updated.AccessVersion, CommandId = Guid.NewGuid() };
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync(path, suspend)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync(path, command)).StatusCode);
        Assert.False((await Read(admin, f.Employee.Id)).Active);
        Assert.Equal(HttpStatusCode.Unauthorized, (await f.Client().PostAsJsonAsync("/api/v1/auth/token/login", new { email = "employee@test.example", password = f.Password })).StatusCode);
    }

    [Fact]
    public async Task ConcurrentRoleEditsHaveOneWinnerAndLegacyEditsAlsoAdvanceVersion()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        var member = await Read(admin, f.Employee.Id);
        var path = $"/api/v1/admin/members/{f.Employee.Id}";
        var command = new UpdateMemberRequest(true, true, true, false, member.AccessVersion, Guid.NewGuid());
        var results = await Task.WhenAll(admin.PutAsJsonAsync(path, command), admin.PutAsJsonAsync(path, command with { IsAccountAdministrator = true, CommandId = Guid.NewGuid() }));
        Assert.Single(results, r => r.StatusCode == HttpStatusCode.NoContent);
        Assert.Single(results, r => r.StatusCode == HttpStatusCode.Conflict);
        member = await Read(admin, f.Employee.Id);
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync(path, new UpdateMemberRequest(false, true, false, false))).StatusCode);
        Assert.True((await Read(admin, f.Employee.Id)).AccessVersion > member.AccessVersion);
        Assert.Equal(HttpStatusCode.BadRequest, (await admin.PutAsJsonAsync(path, command with { ExpectedAccessVersion = null })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{f.Admin.Id}", command with { ExpectedAccessVersion = (await Read(admin, f.Admin.Id)).AccessVersion, CommandId = Guid.NewGuid() })).StatusCode);
    }

    [Fact]
    public async Task ManagerRemovalIsVersionedAuditedAndReplaysCannotUndoLaterReassignment()
    {
        await using var f = new IdentityFixture(); await f.InitializeAsync(); using var admin = await Admin(f);
        var member = await Read(admin, f.Employee.Id);
        Assert.Equal(f.Manager.Id, member.ManagerId);
        var path = $"/api/v1/admin/members/{member.MemberId}/manager";
        var remove = new SetManagerRequest(null, member.AccessVersion, Guid.NewGuid());
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync(path, remove)).StatusCode);
        var removed = await Read(admin, member.MemberId);
        Assert.Null(removed.ManagerId); Assert.False(removed.ManagerRelationshipValid);
        Assert.Equal(HttpStatusCode.Conflict, (await admin.PutAsJsonAsync(path, remove with { CommandId = Guid.NewGuid() })).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync(path, new SetManagerRequest(f.Manager.Id, removed.AccessVersion, Guid.NewGuid()))).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await admin.PutAsJsonAsync(path, remove)).StatusCode);
        Assert.Equal(f.Manager.Id, (await Read(admin, member.MemberId)).ManagerId);
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.PutAsJsonAsync($"/api/v1/admin/members/{f.Stranger.Id}/manager", new SetManagerRequest(null))).StatusCode);
        using var employee = f.Client(); IdentityFixture.Bearer(employee, await f.TokenLogin(employee, "employee"));
        Assert.Equal(HttpStatusCode.Forbidden, (await employee.PutAsJsonAsync(path, remove)).StatusCode);
        await using var scope = f.Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<HomeOfficeDbContext>();
        Assert.Equal(2, await db.Set<AccessAudit>().CountAsync(a => a.Action == "access.manager_assigned" && a.MemberId == member.MemberId));
    }
}
