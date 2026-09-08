using HomeOffice.Domain;

namespace HomeOffice.Application.Workspace;

public sealed record WorkspaceInfo(
    string ProductName,
    string ApiVersion,
    DateTimeOffset ServerTimeUtc,
    string[] PlanningTimeZones);

/// <summary>Public metadata for checking connectivity; contains no accounts or calendar data.</summary>
public sealed class GetWorkspaceInfo(TimeProvider clock)
{
    public WorkspaceInfo Execute() => new(
        "HomeOfficeReservation", "v1", clock.GetUtcNow(),
        [Domain.PlanningTimeZones.Portugal, Domain.PlanningTimeZones.Switzerland]);
}
