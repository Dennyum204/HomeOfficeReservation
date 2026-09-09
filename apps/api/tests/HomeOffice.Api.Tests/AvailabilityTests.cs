using System.Net;
using System.Net.Http.Json;
using HomeOffice.Application.Workspace;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace HomeOffice.Api.Tests;

public sealed class AvailabilityTests
{
    [Fact]
    public async Task LiveAndWorkspaceRemainAvailableWhenPostgresIsUnavailable()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.ConfigureAppConfiguration((_, config) => config.AddInMemoryCollection(
                new Dictionary<string, string?>
                {
                    ["ConnectionStrings:Database"] =
                        "Host=127.0.0.1;Port=1;Database=unavailable;Username=test;Password=synthetic;Timeout=1"
                })));
        using var client = factory.CreateClient();
        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/health/live")).StatusCode);
        var before = DateTimeOffset.UtcNow;
        var workspace = await client.GetFromJsonAsync<WorkspaceInfo>("/api/v1/workspace");
        Assert.NotNull(workspace);
        Assert.InRange(workspace.ServerTimeUtc, before.AddSeconds(-1), DateTimeOffset.UtcNow.AddSeconds(1));
        Assert.Equal(["Europe/Lisbon", "Europe/Zurich"], workspace.PlanningTimeZones);
        var readiness = await client.GetAsync("/health/ready");
        Assert.Equal(HttpStatusCode.ServiceUnavailable, readiness.StatusCode);
        Assert.Equal("Unhealthy", await readiness.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task PublicRegistrationAndAmbiguousLoginRoutesAreNotExposed()
    {
        await using var factory = new WebApplicationFactory<Program>();
        using var client = factory.CreateClient();
        Assert.Equal(HttpStatusCode.NotFound,
            (await client.PostAsJsonAsync("/register", new { })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound,
            (await client.PostAsJsonAsync("/api/v1/auth/login", new { })).StatusCode);
    }
}
