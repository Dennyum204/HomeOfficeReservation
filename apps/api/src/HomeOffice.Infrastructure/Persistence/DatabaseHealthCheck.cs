using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace HomeOffice.Infrastructure.Persistence;

public sealed class DatabaseHealthCheck(HomeOfficeDbContext database) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        // CanConnectAsync verifies the actual PostgreSQL connection. No migrations on startup.
        var connected = await database.Database.CanConnectAsync(cancellationToken);
        return connected ? HealthCheckResult.Healthy() : HealthCheckResult.Unhealthy();
    }
}
