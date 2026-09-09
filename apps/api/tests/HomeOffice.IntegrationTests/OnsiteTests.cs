using System.Net;
using System.Net.Http.Json;
using HomeOffice.Application.Planning;
using HomeOffice.Domain.Planning;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed partial class PlanningTests
{
    private static async Task<OnsiteView> Onsite(Scenario f, DateOnly? from = null, DateOnly? to = null, string location = "Zurique")
    {
        var version = (await f.Calendar()).CalendarVersion;
        var receipt = await f.Run(s => s.SaveRequirement(f.Manager, f.Employee, null,
            new(version, null, from ?? f.Date, to ?? from ?? f.Date, "Instalação da máquina XPTO", location, "XPTO"), Key(), default));
        return await f.Run(s => s.Requirement(f.Employee, f.Employee, receipt.ContextId, default));
    }
    private static Task<OnsiteView> GetOnsite(Scenario f, Guid id) => f.Run(s => s.Requirement(f.Employee, f.Employee, id, default));
    private static async Task<OnsiteView> ReadOnsite(Scenario f, OnsiteView r)
    {
        var v = (await f.Calendar()).CalendarVersion;
        await f.Run(s => s.AcknowledgeRequirement(f.Employee, f.Employee, r.Id, new(v, r.Version, r.Revision), Key(), default));
        return await GetOnsite(f, r.Id);
    }
    private static async Task CancelOnsite(Scenario f, OnsiteView r)
    {
        var v = (await f.Calendar()).CalendarVersion;
        await f.Run(s => s.CancelRequirement(f.Manager, f.Employee, r.Id, new(v, r.Version), Key(), default));
    }
    private static async Task<MutationReceipt> Resolution(Scenario f, OnsiteView requirement, RequestView request)
    {
        var calendar = await f.Calendar();
        var days = request.Days.Where(d => d.Decision == DayDecision.Approved && d.LocalDate >= requirement.From && d.LocalDate <= requirement.To).ToArray();
        return await f.Run(s => s.Propose(f.Manager, f.Employee, request.Id, null, new(calendar.CalendarVersion, request.Version,
            Select(days), days.Select(d => new DayInput(d.LocalDate, WorkLocation.OfficeSwitzerland, Availability.Working, false, d.Id,
                calendar.EffectiveDays.Single(x => x.SourceDayId == d.Id).Version)).ToArray(), "Acordar instalação presencial", requirement.Id, requirement.Revision), Key(), default));
    }
    [Fact]
    public async Task OnsiteConflictPreservesApprovalAndReadIsNotAgreementThenResolutionCommitsBothSides()
    {
        await using var f = new Scenario(); await f.Init();
        var request = await f.Submit((await f.Draft()).ContextId); await f.Decide(request.Id, request.Days);
        var before = (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date);
        var r = await Onsite(f); Assert.Equal(OnsiteState.NeedsResolution, r.State);
        r = await ReadOnsite(f, r); Assert.NotNull(r.ReadAt); Assert.Equal(OnsiteState.NeedsResolution, r.State);
        Assert.Equal(before, (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date));
        var proposal = await Resolution(f, r, await f.Get(request.Id));
        var v = (await f.Calendar()).CalendarVersion;
        var accepted = await f.Run(s => s.Accept(f.Employee, f.Employee, proposal.ContextId, new(v, 1), Key(), default));
        Assert.Equal(before, (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date));
        var replacement = await f.Get(accepted.ContextId); await f.Decide(replacement.Id, replacement.Days);
        var final = await f.Calendar(); Assert.Equal(OnsiteState.Active, Assert.Single(final.Requirements).State);
        Assert.Equal(WorkLocation.OfficeSwitzerland, final.EffectiveDays.Single(x => x.LocalDate == f.Date).Location);
        Assert.Equal(DayDecision.Superseded, Assert.Single((await f.Get(request.Id)).Days).Decision);
        Assert.True(await f.Db(db => db.Set<PlanningOutbox>().AllAsync(x => x.DeliveredAt == null)));
    }
    [Fact]
    public async Task RequirementRevisionInvalidatesReadAndPreviouslyAcceptedResolution()
    {
        await using var f = new Scenario(); await f.Init();
        var request = await f.Submit((await f.Draft()).ContextId); await f.Decide(request.Id, request.Days);
        var r = await ReadOnsite(f, await Onsite(f));
        var proposal = await Resolution(f, r, await f.Get(request.Id)); var v = (await f.Calendar()).CalendarVersion;
        var accepted = await f.Run(s => s.Accept(f.Employee, f.Employee, proposal.ContextId, new(v, 1), Key(), default));
        v = (await f.Calendar()).CalendarVersion;
        await f.Run(s => s.SaveRequirement(f.Manager, f.Employee, r.Id, new(v, r.Version, r.From, r.To, "Nova razão", r.Location, r.Reference), Key(), default));
        var changed = await GetOnsite(f, r.Id); Assert.Equal(2, changed.Revision); Assert.Null(changed.ReadAt);
        v = (await f.Calendar()).CalendarVersion;
        await Error(412, "stale_version", () => f.Run(s => s.AcknowledgeRequirement(f.Employee, f.Employee, r.Id, new(v, changed.Version, r.Revision), Key(), default)));
        var pending = await f.Get(accepted.ContextId); var counts = await f.Counts();
        await Error(412, "stale_version", () => f.Decide(pending.Id, pending.Days)); Assert.Equal(counts, await f.Counts());
        Assert.Equal(WorkLocation.RemotePortugal, (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date).Location);
        Assert.Equal(1, await f.Db(db => db.Set<OnsiteAcknowledgement>().CountAsync()));
    }
    [Fact]
    public async Task RemoteApprovalRacesOnsiteAcrossConnectionsAndRetryCannotViolateActiveRequirement()
    {
        await using var f = new Scenario(); await f.Init();
        var request = await f.Submit((await f.Draft()).ContextId); var v = (await f.Calendar()).CalendarVersion;
        var input = new OnsiteInput(v, null, f.Date, f.Date, "XPTO", "Zurique", "");
        var race = await f.Race(s => s.SaveRequirement(f.Manager, f.Employee, null, input, Key(), default),
            s => s.Decide(f.Manager, f.Employee, request.Id, new(v, request.Version, Select(request.Days), true, null), Key(), default));
        Assert.Single(race.OfType<MutationReceipt>()); Assert.Equal(412, Assert.Single(race.OfType<PlanningException>()).Status);
        var calendar = await f.Calendar();
        if (calendar.Requirements.Length == 0)
        { Assert.Equal(OnsiteState.NeedsResolution, (await Onsite(f)).State); }
        else
        { await Error(409, "active_onsite_conflict", () => f.Decide(request.Id, request.Days)); }
        calendar = await f.Calendar();
        Assert.False(calendar.Requirements.Any(x => x.State == OnsiteState.Active) && calendar.EffectiveDays.Any(x => x.Location == WorkLocation.RemotePortugal && x.Origin == "ApprovedRequest"));
    }
    [Fact]
    public async Task OnsiteRetriesAndOutboxFailureDoNotDuplicateOrPartiallyPersist()
    {
        await using var f = new Scenario(); await f.Init(); await f.Draft();
        var v = (await f.Calendar()).CalendarVersion; var key = Key(); var input = new OnsiteInput(v, null, f.Date, f.Date, "XPTO", "Zurique", "");
        await f.Db(db => db.Database.ExecuteSqlRawAsync("CREATE FUNCTION reject_outbox() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'synthetic'; END $$; CREATE TRIGGER reject_outbox BEFORE INSERT ON \"PlanningOutbox\" FOR EACH ROW EXECUTE FUNCTION reject_outbox();"));
        var before = await f.Counts();
        await Assert.ThrowsAsync<DbUpdateException>(() => f.Run(s => s.SaveRequirement(f.Manager, f.Employee, null, input, key, default)));
        Assert.Equal(before, await f.Counts()); Assert.Equal(0, await f.Db(db => db.Set<OnsiteRequirement>().CountAsync())); Assert.Equal(0, await f.Db(db => db.Set<WorkEntry>().CountAsync()));
        await f.Db(db => db.Database.ExecuteSqlRawAsync("DROP TRIGGER reject_outbox ON \"PlanningOutbox\"; DROP FUNCTION reject_outbox();"));
        var results = await f.Race(s => s.SaveRequirement(f.Manager, f.Employee, null, input, key, default), s => s.SaveRequirement(f.Manager, f.Employee, null, input, key, default));
        Assert.Equal(results[0], results[1]); Assert.Equal(1, await f.Db(db => db.Set<OnsiteRequirement>().CountAsync())); Assert.Equal(1, await f.Db(db => db.Set<WorkEntry>().CountAsync()));
        await Error(409, "idempotency_payload_mismatch", () => f.Run(s => s.SaveRequirement(f.Manager, f.Employee, null, input with { Reason = "Different" }, key, default)));
    }
    [Fact]
    public async Task EditingAndCancellationPreserveOtherRequirementsDecisionsAndCurrentPattern()
    {
        await using var f = new Scenario(); await f.Init();
        var r1 = await Onsite(f, f.Date, f.Date.AddDays(1)); var r2 = await Onsite(f, f.Date.AddDays(1), f.Date.AddDays(2));
        var v = (await f.Calendar()).CalendarVersion;
        await f.Run(s => s.Pattern(f.Employee, f.Employee, new(v, f.Date, Enumerable.Repeat(WorkLocation.RemotePortugal, 7).ToArray()), Key(), default));
        var request = await f.Submit((await f.Draft([new(f.Date.AddDays(4), WorkLocation.OfficeSwitzerland, Availability.Working)])).ContextId);
        await f.Decide(request.Id, request.Days); var approved = (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date.AddDays(4));
        v = (await f.Calendar()).CalendarVersion;
        await f.Run(s => s.SaveRequirement(f.Manager, f.Employee, r1.Id, new(v, r1.Version, f.Date.AddDays(3), f.Date.AddDays(3), r1.Reason, r1.Location, ""), Key(), default));
        var calendar = await f.Calendar(); Assert.Equal(WorkLocation.RemotePortugal, calendar.EffectiveDays.Single(x => x.LocalDate == f.Date).Location);
        Assert.Equal("OnsiteRequirement", calendar.EffectiveDays.Single(x => x.LocalDate == f.Date.AddDays(1)).Origin);
        await CancelOnsite(f, await GetOnsite(f, r1.Id)); Assert.Equal(OnsiteState.Active, (await GetOnsite(f, r2.Id)).State);
        Assert.Equal(approved, (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date.AddDays(4)));
        await CancelOnsite(f, r2); Assert.Equal("WeeklyPattern", (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date.AddDays(1)).Origin);
    }
    [Fact]
    public async Task ManualUnavailabilityAndOtherLocationsConflictWhilePendingRequestIsPreservedAndBlockedAtApproval()
    {
        await using var f = new Scenario(); await f.Init();
        var leave = await f.Submit((await f.Draft([new(f.Date, WorkLocation.Unplanned, Availability.Leave)])).ContextId); await f.Decide(leave.Id, leave.Days);
        var r = await Onsite(f); Assert.Equal(OnsiteState.NeedsResolution, r.State);
        var pending = await f.Submit((await f.Draft([new(f.Date.AddDays(2), WorkLocation.RemotePortugal, Availability.Working)])).ContextId);
        var active = await Onsite(f, f.Date.AddDays(2)); Assert.Equal(OnsiteState.Active, active.State);
        Assert.Equal(DayDecision.Pending, Assert.Single((await f.Get(pending.Id)).Days).Decision);
        await Error(409, "active_onsite_conflict", () => f.Decide(pending.Id, pending.Days));
        var other = await Onsite(f, f.Date.AddDays(2), location: "Basileia"); Assert.Equal(OnsiteState.NeedsResolution, other.State);
        await CancelOnsite(f, active); Assert.Equal(OnsiteState.Active, (await GetOnsite(f, other.Id)).State);
        Assert.Equal(Availability.Leave, (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date).Availability);
    }
    [Fact]
    public async Task ExistingRevisionAndAcceptedCounterproposalCannotApproveRemoteOverActiveOnsite()
    {
        await using var f = new Scenario(); await f.Init();
        var request = await f.Submit((await f.Draft([new(f.Date, WorkLocation.OfficeSwitzerland, Availability.Working)])).ContextId); await f.Decide(request.Id, request.Days);
        var plan = (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date);
        var draft = await f.Draft([new(f.Date, WorkLocation.RemotePortugal, Availability.Working, false, plan.SourceDayId, plan.Version)], request.Id);
        var revision = await f.Submit(draft.ContextId); await Onsite(f);
        await Error(409, "active_onsite_conflict", () => f.Decide(revision.Id, revision.Days));
        Assert.Equal(WorkLocation.OfficeSwitzerland, (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date).Location);
        await f.Withdraw(revision.Id, revision.Days);
        var current = await f.Get(request.Id); var calendar = await f.Calendar();
        var proposal = await f.Run(s => s.Propose(f.Manager, f.Employee, current.Id, null,
            new(calendar.CalendarVersion, current.Version, Select(current.Days), [new(f.Date, WorkLocation.RemotePortugal, Availability.Working, false, plan.SourceDayId, plan.Version)], "Alternativa remota"), Key(), default));
        var v = (await f.Calendar()).CalendarVersion;
        var accepted = await f.Run(s => s.Accept(f.Employee, f.Employee, proposal.ContextId, new(v, 1), Key(), default));
        var replacement = await f.Get(accepted.ContextId);
        await Error(409, "active_onsite_conflict", () => f.Decide(replacement.Id, replacement.Days));
    }
    [Fact]
    public async Task TaskFieldsAreProtectedLinksStayHistoricalAndRequiresOnsiteNeverChangesPlanning()
    {
        await using var f = new Scenario(); await f.Init();
        var before = await f.Calendar();
        var input = new TaskInput(before.CalendarVersion, null, "Preparar XPTO", "Descrição", f.Date, AssignedTaskState.Todo, true, null);
        var created = await f.Run(s => s.SaveTask(f.Manager, f.Employee, null, input, Key(), default));
        Assert.Equal(before.EffectiveDays, (await f.Calendar()).EffectiveDays); Assert.Empty((await f.Calendar()).Requirements);
        var v = (await f.Calendar()).CalendarVersion;
        await Error(403, "forbidden", () => f.Run(s => s.SaveTask(f.Employee, f.Employee, created.ContextId, input with { ExpectedCalendarVersion = v, ExpectedVersion = 1 }, Key(), default)));
        await f.Run(s => s.TaskProgress(f.Employee, f.Employee, created.ContextId, new(v, 1, AssignedTaskState.InProgress, "Em preparação"), Key(), default));
        var r = await Onsite(f); v = (await f.Calendar()).CalendarVersion;
        await f.Run(s => s.SaveTask(f.Manager, f.Employee, created.ContextId, input with { ExpectedCalendarVersion = v, ExpectedVersion = 2, RequirementId = r.Id }, Key(), default));
        await CancelOnsite(f, r);
        var task = await f.Run(s => s.TaskDetail(f.Employee, f.Employee, created.ContextId, default));
        Assert.Equal(r.Id, task.RequirementId); Assert.Equal(OnsiteState.Cancelled, task.RequirementState); Assert.Equal(AssignedTaskState.Todo, task.State);
        var history = await f.Run(s => s.WorkEntries(f.Employee, f.Employee, WorkContext.Task, task.Id, 0, 25, default)); Assert.Equal(3, history.Items.Length);
        v = (await f.Calendar()).CalendarVersion;
        await f.Run(s => s.TaskProgress(f.Employee, f.Employee, task.Id, new(v, task.Version, AssignedTaskState.Done, "Concluído"), Key(), default));
        task = await f.Run(s => s.TaskDetail(f.Employee, f.Employee, task.Id, default)); v = (await f.Calendar()).CalendarVersion;
        await Error(409, "task_terminal", () => f.Run(s => s.TaskProgress(f.Employee, f.Employee, task.Id, new(v, task.Version, AssignedTaskState.InProgress, ""), Key(), default)));
    }
    [Fact]
    public async Task FailedFinalResolutionRollsBackRequirementPlanAndHistoryTogether()
    {
        await using var f = new Scenario(); await f.Init();
        var request = await f.Submit((await f.Draft()).ContextId); await f.Decide(request.Id, request.Days);
        var onsite = await Onsite(f); var proposal = await Resolution(f, onsite, await f.Get(request.Id));
        var v = (await f.Calendar()).CalendarVersion;
        var accepted = await f.Run(s => s.Accept(f.Employee, f.Employee, proposal.ContextId, new(v, 1), Key(), default));
        var pending = await f.Get(accepted.ContextId); var before = await f.Counts(); var entries = await f.Db(db => db.Set<WorkEntry>().CountAsync());
        await f.Db(db => db.Database.ExecuteSqlRawAsync("CREATE FUNCTION reject_outbox() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'synthetic'; END $$; CREATE TRIGGER reject_outbox BEFORE INSERT ON \"PlanningOutbox\" FOR EACH ROW EXECUTE FUNCTION reject_outbox();"));
        await Assert.ThrowsAsync<DbUpdateException>(() => f.Decide(pending.Id, pending.Days));
        Assert.Equal(before, await f.Counts()); Assert.Equal(entries, await f.Db(db => db.Set<WorkEntry>().CountAsync()));
        Assert.Equal(OnsiteState.NeedsResolution, (await GetOnsite(f, onsite.Id)).State);
        Assert.Equal(WorkLocation.RemotePortugal, (await f.Calendar()).EffectiveDays.Single(x => x.LocalDate == f.Date).Location);
        Assert.Equal(DayDecision.Pending, Assert.Single((await f.Get(pending.Id)).Days).Decision);
    }
    [Fact]
    public async Task ActualExistingForeignRequirementAndUnassignedDualRoleManagerAreDenied()
    {
        await using var f = new Scenario(); await f.Init(); await f.Draft();
        var foreign = Guid.NewGuid();
        await f.Db(async db =>
        {
            var stranger = f.Identity.Stranger;
            db.Set<PlanningProfile>().Add(new() { OrganizationId = stranger.OrganizationId, EmployeeId = stranger.Id });
            db.Set<OnsiteRequirement>().Add(new() { Id = foreign, OrganizationId = stranger.OrganizationId, EmployeeId = stranger.Id, From = f.Date, To = f.Date, Reason = "Private synthetic", Location = "CH", CreatedBy = stranger.Id, CreatedAt = f.Identity.Clock.GetUtcNow() });
            var employee = await db.Members.SingleAsync(x => x.Id == f.Employee); employee.IsManager = true;
            return await db.SaveChangesAsync();
        });
        var v = (await f.Calendar()).CalendarVersion;
        await Error(404, "requirement_not_found", () => f.Run(s => s.SaveTask(f.Manager, f.Employee, null, new(v, null, "Linked", "", f.Date, AssignedTaskState.Todo, true, foreign), Key(), default)));
        await Error(403, "forbidden", () => f.Run(s => s.SaveRequirement(f.Employee, f.Employee, null, new(v, null, f.Date, f.Date, "Self", "CH", ""), Key(), default)));
        await f.Db(async db => { db.ReportingLines.Remove(await db.ReportingLines.SingleAsync(x => x.EmployeeId == f.Employee)); return await db.SaveChangesAsync(); });
        await Error(403, "forbidden", () => f.Run(s => s.SaveRequirement(f.Manager, f.Employee, null, new(v, null, f.Date, f.Date, "Unassigned", "CH", ""), Key(), default)));
        await Error(403, "forbidden", () => f.Run(s => s.Tasks(f.Manager, f.Employee, 0, 25, null, default)));
    }
    [Fact]
    public async Task OnsiteDatesRemainDateOnlyAcrossLisbonZurichAndSpringAutumnBoundaries()
    {
        await using var f = new Scenario(); await f.Init();
        var year = f.Date.Year + 1;
        foreach (var from in new[] { new DateOnly(year, 3, 25), new DateOnly(year, 10, 25) })
        {
            var to = from.AddDays(6);
            var r = await Onsite(f, from, to);
            foreach (var zone in new[] { "Europe/Lisbon", "Europe/Zurich" })
            {
                await f.Db(async db => { var org = await db.Organizations.SingleAsync(x => x.Id == f.Identity.Employee.OrganizationId); org.PlanningTimeZone = zone; return await db.SaveChangesAsync(); });
                var calendar = await f.Run(s => s.Calendar(f.Employee, f.Employee, from, to, default));
                Assert.Equal(7, calendar.EffectiveDays.Length); Assert.Equal(from, calendar.EffectiveDays[0].LocalDate); Assert.Equal(to, calendar.EffectiveDays[^1].LocalDate);
                Assert.All(calendar.EffectiveDays, d => Assert.Equal("OnsiteRequirement", d.Origin)); Assert.Equal(r.Id, Assert.Single(calendar.Requirements).Id);
            }
        }
    }
    [Fact]
    public async Task OnsiteAndTaskHttpDenyUnassignedCrossOrganizationSelfManagementAndUnknownProgressFields()
    {
        await using var f = new Scenario(); await f.Init(); var r = await Onsite(f);
        using var employee = f.Identity.Client(); using var admin = f.Identity.Client(); using var stranger = f.Identity.Client();
        IdentityFixture.Bearer(employee, await f.Identity.TokenLogin(employee)); IdentityFixture.Bearer(admin, await f.Identity.TokenLogin(admin, "admin")); IdentityFixture.Bearer(stranger, await f.Identity.TokenLogin(stranger, "stranger"));
        var root = $"/api/v1/planning/{f.Employee}";
        foreach (var client in new[] { admin, stranger })
            foreach (var path in new[] { "/requirements", $"/requirements/{r.Id}", "/tasks", $"/work/Requirement/{r.Id}/entries", "/calendar?from=" + f.Date.ToString("yyyy-MM-dd") + "&to=" + f.Date.ToString("yyyy-MM-dd") })
                Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync(root + path)).StatusCode);
        var v = (await f.Calendar()).CalendarVersion;
        await Error(403, "forbidden", () => f.Run(s => s.SaveRequirement(f.Employee, f.Employee, null, new(v, null, f.Date, f.Date, "self", "CH", ""), Key(), default)));
        var task = await f.Run(s => s.SaveTask(f.Manager, f.Employee, null, new(v, null, "XPTO", "", f.Date, AssignedTaskState.Todo, false, r.Id), Key(), default));
        employee.DefaultRequestHeaders.Add("Idempotency-Key", Key());
        Assert.Equal(HttpStatusCode.BadRequest, (await employee.PostAsJsonAsync(root + $"/tasks/{task.ContextId}/progress", new { expectedCalendarVersion = task.CalendarVersion, expectedVersion = 1, state = "InProgress", note = "", requiresOnsite = true })).StatusCode);
        var otherId = Guid.NewGuid();
        await Error(404, "requirement_not_found", () => f.Run(s => s.SaveTask(f.Manager, f.Employee, null, new(task.CalendarVersion, null, "XPTO", "", f.Date, AssignedTaskState.Todo, true, otherId), Key(), default)));
    }
}
