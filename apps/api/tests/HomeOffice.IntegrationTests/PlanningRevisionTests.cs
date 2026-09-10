using HomeOffice.Application.Planning;
using HomeOffice.Domain.Planning;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed partial class PlanningTests
{
    [Fact]
    public async Task CounterproposalOnPendingApprovedRevisionCarriesOnlyItsExplicitOriginalBaseUntilFinalDecision()
    {
        await using var f = new Scenario(); await f.Init();
        var original = await f.Submit((await f.Draft()).ContextId);
        await f.Decide(original.Id, original.Days);
        var plan = (await f.Calendar()).EffectiveDays[0];
        DayInput cancellation = new(f.Date, WorkLocation.Unplanned, Availability.Working, true, plan.SourceDayId, plan.Version);
        var revision = await f.Submit((await f.Draft([cancellation], original.Id)).ContextId);
        var before = await f.Counts();
        await Error(409, "invalid_revision_base", () => f.Draft([cancellation with { BasePlanVersion = plan.Version + 1 }], revision.Id));
        Assert.Equal(before, await f.Counts());
        var proposal = await f.Run(s => s.Propose(f.Manager, f.Employee, revision.Id, null,
            new(before.Version, revision.Version, Select(revision.Days), [cancellation], "Synthetic revised cancellation"), Key(), default));
        Assert.Equal(plan, (await f.Calendar()).EffectiveDays[0]);
        var accepted = await f.Run(s => s.Accept(f.Employee, f.Employee, proposal.ContextId, new(proposal.CalendarVersion, 1), Key(), default));
        Assert.Equal(plan, (await f.Calendar()).EffectiveDays[0]);
        Assert.Equal(DayDecision.Superseded, (await f.Get(revision.Id)).Days[0].Decision);
        var final = await f.Get(accepted.ContextId);
        Assert.Equal(plan.SourceDayId, final.Days[0].BaseDayId);
        await f.Decide(final.Id, final.Days);
        Assert.DoesNotContain((await f.Calendar()).EffectiveDays, d => d.Origin == "ApprovedRequest");
        Assert.Equal(DayDecision.Cancelled, (await f.Get(final.Id)).Days[0].Decision);
        Assert.Equal(DayDecision.Cancelled, (await f.Get(original.Id)).Days[0].Decision);
    }
}
