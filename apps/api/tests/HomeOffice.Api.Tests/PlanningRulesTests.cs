using HomeOffice.Domain.Planning;
using Xunit;

namespace HomeOffice.Api.Tests;

public sealed class PlanningRulesTests
{
    [Fact]
    public void InclusiveRangesExcludeWeekendsUnlessExplicitlySelectedAndDoNotShiftAcrossDst()
    {
        var from = new DateOnly(2027, 3, 26); var to = new DateOnly(2027, 3, 29);
        Assert.Equal(new[] { from, to }, PlanningRules.Expand(from, to, false));
        Assert.Equal(4, PlanningRules.Expand(from, to, true).Length);
        foreach (var zone in new[] { "Europe/Lisbon", "Europe/Zurich" })
            foreach (var instant in new[] { "2027-03-28T12:00:00Z", "2027-10-31T12:00:00Z" })
                Assert.Equal(DateOnly.Parse(instant[..10]), PlanningRules.Today(DateTimeOffset.Parse(instant), zone));
        Assert.Equal(new DateOnly(2027, 3, 29), PlanningRules.Today(DateTimeOffset.Parse("2027-03-28T22:30:00Z"), "Europe/Zurich"));
        Assert.Equal(new DateOnly(2027, 3, 28), PlanningRules.Today(DateTimeOffset.Parse("2027-03-28T22:30:00Z"), "Europe/Lisbon"));
    }
    [Fact]
    public void DimensionsAndVersionsAreExplicitAndPartialSummaryKeepsPendingDays()
    {
        PlanningRules.Dimensions(WorkLocation.RemotePortugal, Availability.Working, false);
        Assert.Throws<PlanningException>(() => PlanningRules.Dimensions(WorkLocation.RemotePortugal, Availability.Leave, false));
        Assert.Equal(428, Assert.Throws<PlanningException>(() => PlanningRules.Version(null, 1)).Status);
        Assert.Equal(412, Assert.Throws<PlanningException>(() => PlanningRules.Version(1, 2)).Status);
        Assert.Equal(RequestState.Submitted, PlanningRules.Summary([new() { Decision = DayDecision.Approved }, new() { Decision = DayDecision.Pending }]));
    }
}
