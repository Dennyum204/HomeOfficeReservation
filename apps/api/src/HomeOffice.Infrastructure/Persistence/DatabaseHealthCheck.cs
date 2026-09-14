using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Hosting;

namespace HomeOffice.Infrastructure.Persistence;

public sealed class DatabaseHealthCheck(HomeOfficeDbContext database, IHostEnvironment environment) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        // CanConnectAsync verifies the actual PostgreSQL connection. No migrations on startup.
        var connected = await database.Database.CanConnectAsync(cancellationToken);
        if (connected && !environment.IsDevelopment() && !environment.IsEnvironment("Testing"))
            connected = !(await database.Database.GetPendingMigrationsAsync(cancellationToken)).Any();
        return connected ? HealthCheckResult.Healthy() : HealthCheckResult.Unhealthy();
    }
}
