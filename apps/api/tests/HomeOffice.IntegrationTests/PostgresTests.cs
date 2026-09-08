using System.Net;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed class PostgresTests
{
    [Fact]
    public async Task ReadinessAndEfQueryUseRealPostgreSql()
    {
        var connection = Environment.GetEnvironmentVariable("HO_TEST_DATABASE");
        Assert.False(string.IsNullOrWhiteSpace(connection),
            "Set HO_TEST_DATABASE to a disposable PostgreSQL database. This test never silently skips.");
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.ConfigureAppConfiguration((_, config) => config.AddInMemoryCollection(
                new Dictionary<string, string?> { ["ConnectionStrings:Database"] = connection })));
        using var client = factory.CreateClient();
        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/health/ready")).StatusCode);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<HomeOfficeDbContext>();
        Assert.Equal("Npgsql.EntityFrameworkCore.PostgreSQL", db.Database.ProviderName);
        var value = await db.Database.SqlQueryRaw<int>("SELECT 1 AS \"Value\"").SingleAsync();
        Assert.Equal(1, value);
        Assert.Contains(db.Model.GetEntityTypes(), e => e.GetTableName() == "AspNetUsers");
    }
}
