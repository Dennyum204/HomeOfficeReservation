using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using HomeOffice.Application.Planning;
using HomeOffice.Domain.Access;
using HomeOffice.Domain.Planning;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed class PlanningTests
{
    private sealed class Scenario : IAsyncDisposable
    {
        public IdentityFixture Identity { get; } = new();
        public Guid Employee => Identity.Employee.Id;
        public Guid Manager => Identity.Manager.Id;
        public DateOnly Date => PlanningRules.Today(Identity.Clock.GetUtcNow(), "Europe/Zurich").AddDays(14);
        public async Task Init() => await Identity.InitializeAsync();
        public async Task<T> Run<T>(Func<IPlanningService, Task<T>> action)
        { await using var scope = Identity.Factory.Services.CreateAsyncScope(); return await action(scope.ServiceProvider.GetRequiredService<IPlanningService>()); }
        public async Task<T> Db<T>(Func<HomeOfficeDbContext, Task<T>> action)
        { await using var scope = Identity.Factory.Services.CreateAsyncScope(); return await action(scope.ServiceProvider.GetRequiredService<HomeOfficeDbContext>()); }
        public Task<CalendarView> Calendar() => Run(s => s.Calendar(Employee, Employee, Date, Date.AddDays(30), default));
        public Task<RequestView> Get(Guid id) => Run(s => s.Request(Employee, Employee, id, default));
        public async Task<MutationReceipt> Draft(DayInput[]? days = null, Guid? parent = null)
        {
            var calendar = await Calendar();
            return await Run(s => s.Draft(Employee, Employee, null, new(calendar.CalendarVersion, null, parent, "Synthetic planning", days ?? [new(Date, WorkLocation.RemotePortugal, Availability.Working)]), Key(), default));
        }
        public async Task<RequestView> Submit(Guid id)
        {
            var r = await Get(id); var calendar = await Calendar();
            await Run(s => s.Submit(Employee, Employee, id, new(calendar.CalendarVersion, r.Version), Key(), default));
            return await Get(id);
        }
        public async Task Decide(Guid id, RequestedDayView[] days, bool approve = true)
        {
            var r = await Get(id); var calendar = await Calendar();
            await Run(s => s.Decide(Manager, Employee, id, new(calendar.CalendarVersion, r.Version, Select(days), approve, approve ? null : "Synthetic reason"), Key(), default));
        }
        public async Task Withdraw(Guid id, RequestedDayView[] days)
        {
            var r = await Get(id); var calendar = await Calendar();
            await Run(s => s.Withdraw(Employee, Employee, id, new(calendar.CalendarVersion, r.Version, Select(days)), Key(), default));
        }
        public Task<(int Plans, int Audits, int Outbox, int Receipts, long Version)> Counts() => Db(async db =>
            (await db.Set<PlanDay>().CountAsync(), await db.Set<PlanningAudit>().CountAsync(), await db.Set<PlanningOutbox>().CountAsync(), await db.Set<PlanningReceipt>().CountAsync(),
            await db.Set<PlanningProfile>().Select(x => x.CalendarVersion).SingleAsync()));
        public async Task<object[]> Race(Func<IPlanningService, Task<MutationReceipt>> a, Func<IPlanningService, Task<MutationReceipt>> b)
        {
            await using var first = Identity.Factory.Services.CreateAsyncScope();
            await using var second = Identity.Factory.Services.CreateAsyncScope();
            var db1 = first.ServiceProvider.GetRequiredService<HomeOfficeDbContext>(); var db2 = second.ServiceProvider.GetRequiredService<HomeOfficeDbContext>();
            await db1.Database.OpenConnectionAsync(); await db2.Database.OpenConnectionAsync();
            Assert.NotEqual(((NpgsqlConnection)db1.Database.GetDbConnection()).ProcessID, ((NpgsqlConnection)db2.Database.GetDbConnection()).ProcessID);
            static async Task<object> Capture(Func<Task<MutationReceipt>> call)
            { try { return await call(); } catch (PlanningException e) { return e; } }
            return await Task.WhenAll(Capture(() => a(first.ServiceProvider.GetRequiredService<IPlanningService>())), Capture(() => b(second.ServiceProvider.GetRequiredService<IPlanningService>())));
        }
        public ValueTask DisposeAsync() => Identity.DisposeAsync();
    }
    private static string Key() => Guid.NewGuid().ToString("N");
    private static SelectedDay[] Select(params RequestedDayView[] days) => days.Select(d => new SelectedDay(d.Id, d.Version)).ToArray();
    private static async Task Error(int status, string code, Func<Task> call)
    { var error = await Assert.ThrowsAsync<PlanningException>(call); Assert.Equal(status, error.Status); Assert.Equal(code, error.Code); }

    [Fact]
    public async Task DraftIsPrivateEditableAndSubmissionFreezesRevisionThenPartialDecisionAndWithdrawalPreserveApprovedDays()
    {
        await using var f = new Scenario(); await f.Init();
        var draft = await f.Draft([new(f.Date, WorkLocation.RemotePortugal, Availability.Working), new(f.Date.AddDays(1), WorkLocation.RemotePortugal, Availability.Working), new(f.Date.AddDays(2), WorkLocation.RemotePortugal, Availability.Working)]);
        await Error(403, "private_draft", () => f.Run(s => s.Request(f.Manager, f.Employee, draft.ContextId, default)));
        Assert.Empty((await f.Calendar()).PendingDays);
        var edit = new DraftInput(draft.CalendarVersion, draft.Version, null, "Edited synthetic note", (await f.Get(draft.ContextId)).Days.Select(d => new DayInput(d.LocalDate, d.Location, d.Availability)).ToArray());
        await f.Run(s => s.Draft(f.Employee, f.Employee, draft.ContextId, edit, Key(), default));
        var submitted = await f.Submit(draft.ContextId);
        await Error(409, "submitted_revision_is_frozen", () => f.Run(s => s.Draft(f.Employee, f.Employee, draft.ContextId, edit with { ExpectedCalendarVersion = 3, ExpectedRequestVersion = submitted.Version }, Key(), default)));
        await f.Decide(submitted.Id, [submitted.Days[0]]);
        await f.Decide(submitted.Id, [submitted.Days[1]], false);
        await f.Withdraw(submitted.Id, [submitted.Days[2]]);
        var result = await f.Get(submitted.Id);
        Assert.Equal(new[] { DayDecision.Approved, DayDecision.Rejected, DayDecision.Withdrawn }, result.Days.Select(d => d.Decision));
        Assert.Equal(RequestState.Closed, result.State);
        Assert.Single((await f.Calendar()).EffectiveDays, d => d.Origin == "ApprovedRequest");
        Assert.Empty((await f.Calendar()).PendingDays);
        Assert.Equal(6, (await f.Counts()).Audits);
        Assert.Equal(0, await f.Db(db => db.Set<PlanningOutbox>().CountAsync(x => x.DeliveredAt != null)));
    }

    [Fact]
    public async Task RejectedWithdrawnAndPendingRevisionsPreserveApprovalThenExplicitChangeAndCancellationResolveIt()
    {
        await using var f = new Scenario(); await f.Init();
        var original = await f.Submit((await f.Draft()).ContextId); await f.Decide(original.Id, original.Days);
        var plan = (await f.Calendar()).EffectiveDays[0];
        DayInput replacement = new(f.Date, WorkLocation.Unplanned, Availability.Leave, false, plan.SourceDayId, plan.Version);
        foreach (var action in new[] { "reject", "withdraw", "approve" })
        {
            var revision = await f.Submit((await f.Draft([replacement], original.Id)).ContextId);
            Assert.Equal(plan, (await f.Calendar()).EffectiveDays[0]);
            if (action == "withdraw") await f.Withdraw(revision.Id, revision.Days);
            else await f.Decide(revision.Id, revision.Days, action == "approve");
            if (action != "approve") Assert.Equal(plan, (await f.Calendar()).EffectiveDays[0]);
            else
            {
                var leave = (await f.Calendar()).EffectiveDays[0]; Assert.Equal(Availability.Leave, leave.Availability);
                var cancellation = await f.Submit((await f.Draft([new(f.Date, WorkLocation.Unplanned, Availability.Working, true, leave.SourceDayId, leave.Version)], revision.Id)).ContextId);
                await f.Decide(cancellation.Id, cancellation.Days);
                Assert.Equal("WeeklyPattern", (await f.Calendar()).EffectiveDays[0].Origin);
                Assert.Equal(DayDecision.Cancelled, (await f.Get(revision.Id)).Days[0].Decision);
            }
        }
        Assert.Equal(DayDecision.Superseded, (await f.Get(original.Id)).Days[0].Decision);
    }

    [Fact]
    public async Task CounterproposalRequiresAcceptanceAndFinalDecisionAndRevisionInvalidatesPriorAcknowledgement()
    {
        await using var f = new Scenario(); await f.Init();
        var r = await f.Submit((await f.Draft()).ContextId);
        var input = new ProposalInput((await f.Calendar()).CalendarVersion, r.Version, Select(r.Days), [new(f.Date.AddDays(2), WorkLocation.RemotePortugal, Availability.Working)], "Alternative dates");
        var proposal = await f.Run(s => s.Propose(f.Manager, f.Employee, r.Id, null, input, Key(), default));
        Assert.Equal(f.Date, Assert.Single((await f.Calendar()).PendingDays).Day.LocalDate);
        var accepted = await f.Run(s => s.Accept(f.Employee, f.Employee, proposal.ContextId, new(proposal.CalendarVersion, 1), Key(), default));
        Assert.DoesNotContain((await f.Calendar()).EffectiveDays, d => d.Origin == "ApprovedRequest");
        var oldRevision = await f.Get(accepted.ContextId);
        var currentParent = await f.Get(r.Id);
        var revised = await f.Run(s => s.Propose(f.Manager, f.Employee, r.Id, proposal.ContextId,
            input with
            {
                ExpectedCalendarVersion = accepted.CalendarVersion,
                ExpectedRequestVersion = currentParent.Version,
                AffectedDays = Select(currentParent.Days),
                Days = [new(f.Date.AddDays(3), WorkLocation.RemotePortugal, Availability.Working)]
            }, Key(), default));
        await Error(409, "proposal_not_open", () => f.Run(s => s.Accept(f.Employee, f.Employee, proposal.ContextId, new(revised.CalendarVersion, 1), Key(), default)));
        await Error(412, "stale_version", () => f.Run(s => s.Decide(f.Manager, f.Employee, oldRevision.Id, new(revised.CalendarVersion, oldRevision.Version, Select(oldRevision.Days), true, null), Key(), default)));
        Assert.Equal(DayDecision.Superseded, (await f.Get(oldRevision.Id)).Days[0].Decision);
        var next = await f.Run(s => s.Accept(f.Employee, f.Employee, revised.ContextId, new(revised.CalendarVersion, 2), Key(), default));
        var final = await f.Get(next.ContextId); await f.Decide(final.Id, final.Days);
        Assert.Equal(f.Date.AddDays(3), Assert.Single((await f.Calendar()).EffectiveDays, d => d.Origin == "ApprovedRequest").LocalDate);
        Assert.Equal(2, await f.Db(db => db.Set<ProposalAcknowledgement>().CountAsync()));
    }

    [Fact]
    public async Task ConcurrentDuplicateSubmissionAndDecisionReturnDurableReceiptWithoutDuplicateEffects()
    {
        await using var f = new Scenario(); await f.Init();
        var draft = await f.Draft(); var key = Key(); var submit = new SubmitInput(draft.CalendarVersion, draft.Version);
        var results = await f.Race(s => s.Submit(f.Employee, f.Employee, draft.ContextId, submit, key, default), s => s.Submit(f.Employee, f.Employee, draft.ContextId, submit, key, default));
        Assert.Equal(Assert.IsType<MutationReceipt>(results[0]), Assert.IsType<MutationReceipt>(results[1]));
        var r = await f.Get(draft.ContextId); var decision = new DecisionInput((await f.Calendar()).CalendarVersion, r.Version, Select(r.Days), true, null); key = Key();
        results = await f.Race(s => s.Decide(f.Manager, f.Employee, r.Id, decision, key, default), s => s.Decide(f.Manager, f.Employee, r.Id, decision, key, default));
        Assert.Equal(Assert.IsType<MutationReceipt>(results[0]), Assert.IsType<MutationReceipt>(results[1]));
        Assert.Equal((1, 3, 3, 3, 3L), await f.Counts());
        await Error(409, "idempotency_payload_mismatch", () => f.Run(s => s.Decide(f.Manager, f.Employee, r.Id, decision with { Reason = "Changed payload" }, key, default)));
        Assert.Equal((1, 3, 3, 3, 3L), await f.Counts());
    }

    [Fact]
    public async Task CompetingSubmissionsAndDecisionsSerializeAcrossRealConnections()
    {
        await using var f = new Scenario(); await f.Init();
        var first = await f.Draft(); var second = await f.Draft();
        var version = (await f.Calendar()).CalendarVersion;
        var race = await f.Race(s => s.Submit(f.Employee, f.Employee, first.ContextId, new(version, 1), Key(), default), s => s.Submit(f.Employee, f.Employee, second.ContextId, new(version, 1), Key(), default));
        Assert.Single(race.OfType<MutationReceipt>()); Assert.Equal(412, Assert.Single(race.OfType<PlanningException>()).Status);
        var winner = race.OfType<MutationReceipt>().Single().ContextId; var loser = winner == first.ContextId ? second.ContextId : first.ContextId;
        await Error(409, "pending_overlap", async () => await f.Submit(loser));
        var r = await f.Get(winner); version = (await f.Calendar()).CalendarVersion;
        race = await f.Race(s => s.Decide(f.Manager, f.Employee, r.Id, new(version, r.Version, Select(r.Days), true, null), Key(), default),
            s => s.Decide(f.Manager, f.Employee, r.Id, new(version, r.Version, Select(r.Days), false, "Reason"), Key(), default));
        Assert.Single(race.OfType<MutationReceipt>()); Assert.Equal(412, Assert.Single(race.OfType<PlanningException>()).Status);
        Assert.Equal(4, (await f.Counts()).Outbox);
    }

    [Fact]
    public async Task AnyStaleSelectedDayRollsBackWholeSelectionAndDatabaseFailureRollsBackPlanAuditOutboxAndReceipt()
    {
        await using var f = new Scenario(); await f.Init();
        var r = await f.Submit((await f.Draft([new(f.Date, WorkLocation.RemotePortugal, Availability.Working), new(f.Date.AddDays(1), WorkLocation.RemotePortugal, Availability.Working)])).ContextId);
        var before = await f.Counts();
        var invalid = new DecisionInput(before.Version, r.Version, [new(r.Days[0].Id, r.Days[0].Version), new(r.Days[1].Id, 999)], true, null);
        await Error(412, "stale_version", () => f.Run(s => s.Decide(f.Manager, f.Employee, r.Id, invalid, Key(), default)));
        Assert.Equal(before, await f.Counts());
        await f.Db(db => db.Database.ExecuteSqlRawAsync("CREATE FUNCTION reject_outbox() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'synthetic outbox failure'; END $$; CREATE TRIGGER reject_outbox BEFORE INSERT ON \"PlanningOutbox\" FOR EACH ROW EXECUTE FUNCTION reject_outbox();"));
        await Assert.ThrowsAsync<DbUpdateException>(() => f.Decide(r.Id, r.Days));
        Assert.Equal(before, await f.Counts());
        Assert.All((await f.Get(r.Id)).Days, d => Assert.Equal(DayDecision.Pending, d.Decision));
        await f.Db(db => db.Database.ExecuteSqlRawAsync("DROP TRIGGER reject_outbox ON \"PlanningOutbox\"; DROP FUNCTION reject_outbox();"));
        await f.Decide(r.Id, r.Days); Assert.Equal(2, (await f.Counts()).Plans);
    }

    [Fact]
    public async Task RealHttpUsesCurrentAuthorityCsrfStrictContractsAndProtectsComments()
    {
        await using var f = new Scenario(); await f.Init(); var r = await f.Submit((await f.Draft()).ContextId);
        var root = $"/api/v1/planning/{f.Employee}/requests/{r.Id}";
        using var employee = f.Identity.Client(); using var manager = f.Identity.Client(); using var admin = f.Identity.Client(); using var stranger = f.Identity.Client();
        IdentityFixture.Bearer(employee, await f.Identity.TokenLogin(employee)); IdentityFixture.Bearer(manager, await f.Identity.TokenLogin(manager, "manager"));
        IdentityFixture.Bearer(admin, await f.Identity.TokenLogin(admin, "admin")); IdentityFixture.Bearer(stranger, await f.Identity.TokenLogin(stranger, "stranger"));
        foreach (var client in new[] { admin, stranger }) Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync(root)).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await manager.GetAsync(root)).StatusCode);
        var decision = new DecisionInput((await f.Calendar()).CalendarVersion, r.Version, Select(r.Days), true, null);
        employee.DefaultRequestHeaders.Add("Idempotency-Key", Key());
        Assert.Equal(HttpStatusCode.Forbidden, (await employee.PostAsJsonAsync(root + "/decide", decision)).StatusCode);
        using var browser = f.Identity.Client(); await f.Identity.WebLogin(browser);
        Assert.Equal(HttpStatusCode.BadRequest, (await browser.PostAsJsonAsync(root + "/comments", new { expectedCalendarVersion = 2, text = "Safe comment" })).StatusCode);
        var comment = await f.Run(s => s.Comment(f.Manager, f.Employee, r.Id, new(decision.ExpectedCalendarVersion, "Synthetic contextual comment"), Key(), default));
        var comments = await f.Run(s => s.Comments(f.Employee, f.Employee, r.Id, 0, 25, default));
        Assert.Equal(f.Manager, Assert.Single(comments.Items).AuthorId); Assert.InRange((f.Identity.Clock.GetUtcNow() - comments.Items[0].CreatedAt).Duration(), TimeSpan.Zero, TimeSpan.FromMicroseconds(1));
        Assert.Equal(HttpStatusCode.BadRequest, (await employee.PostAsJsonAsync(root + "/comments", new { expectedCalendarVersion = comment.CalendarVersion, text = "Invalid", authorId = f.Manager })).StatusCode);
        await f.Db(async db => { var line = await db.ReportingLines.SingleAsync(x => x.EmployeeId == f.Employee); db.ReportingLines.Remove(line); return await db.SaveChangesAsync(); });
        Assert.Equal(HttpStatusCode.Forbidden, (await manager.GetAsync(root + "/comments")).StatusCode);
        await f.Db(async db => { var member = await db.Members.SingleAsync(x => x.Id == f.Employee); member.Active = false; return await db.SaveChangesAsync(); });
        Assert.Equal(HttpStatusCode.Forbidden, (await employee.GetAsync(root)).StatusCode);
    }

    [Fact]
    public async Task DateOnlyStoragePatternsAndManualAvailabilityRemainSeparateAcrossDst()
    {
        await using var f = new Scenario(); await f.Init();
        var days = new[] { new DateOnly(2026, 10, 25), new DateOnly(2027, 3, 28) };
        // Keep fixed DST dates in the allowed window even when this test is run later.
        f.Identity.Clock.Advance(new DateTimeOffset(2026, 9, 9, 12, 0, 0, TimeSpan.Zero) - f.Identity.Clock.GetUtcNow());
        foreach (var date in days)
        {
            var r = await f.Submit((await f.Draft([new(date, WorkLocation.RemotePortugal, Availability.Working)])).ContextId); await f.Decide(r.Id, r.Days);
            var view = await f.Run(s => s.Calendar(f.Employee, f.Employee, date, date, default)); Assert.Equal(date, Assert.Single(view.EffectiveDays).LocalDate);
        }
        var patternDate = f.Date;
        await f.Run(async s => await s.Pattern(f.Employee, f.Employee, new((await f.Calendar()).CalendarVersion, patternDate,
            [WorkLocation.RemotePortugal, WorkLocation.RemotePortugal, WorkLocation.RemotePortugal, WorkLocation.RemotePortugal, WorkLocation.RemotePortugal, WorkLocation.Unplanned, WorkLocation.Unplanned]), Key(), default));
        Assert.Equal(2, await f.Db(db => db.Set<PlanDay>().CountAsync()));
        var prior = await f.Run(s => s.Calendar(f.Employee, f.Employee, patternDate.AddDays(-1), patternDate, default));
        Assert.Equal(PlanningRules.DefaultLocation(patternDate.AddDays(-1)), prior.EffectiveDays[0].Location);
        var postgresType = await f.Db(db => db.Database.SqlQueryRaw<string>("SELECT data_type AS \"Value\" FROM information_schema.columns WHERE table_name = 'PlanDays' AND column_name = 'LocalDate'").SingleAsync());
        Assert.Equal("date", postgresType);
        await Error(400, "duplicate_dates", () => f.Draft([new(f.Date, WorkLocation.RemotePortugal, Availability.Working), new(f.Date, WorkLocation.RemotePortugal, Availability.Working)]));
        await Error(400, "date_outside_planning_window", () => f.Draft([new(f.Date.AddDays(-15), WorkLocation.RemotePortugal, Availability.Working)]));
        await Error(400, "invalid_range", () => f.Run(s => s.Calendar(f.Employee, f.Employee, f.Date, f.Date.AddDays(366), default)));
    }

    [Fact]
    public async Task ExplicitPendingRevisionReplacesOnlyLinkedOverlapsAndFailedAcceptanceRestoresIntermediateWrites()
    {
        await using var f = new Scenario(); await f.Init();
        var original = await f.Submit((await f.Draft()).ContextId);
        var revision = await f.Submit((await f.Draft(parent: original.Id)).ContextId);
        Assert.Equal(DayDecision.Superseded, (await f.Get(original.Id)).Days[0].Decision);
        Assert.Equal(revision.Id, Assert.Single((await f.Calendar()).PendingDays).RequestId);
        await f.Submit((await f.Draft([new(f.Date.AddDays(1), WorkLocation.RemotePortugal, Availability.Working)])).ContextId);
        var calendarVersion = (await f.Calendar()).CalendarVersion;
        var proposal = await f.Run(s => s.Propose(f.Manager, f.Employee, revision.Id, null,
            new(calendarVersion, revision.Version, Select(revision.Days),
                [new(f.Date.AddDays(1), WorkLocation.RemotePortugal, Availability.Working)], "Synthetic collision"), Key(), default));
        var before = await f.Counts();
        await Error(409, "pending_overlap", () => f.Run(s => s.Accept(f.Employee, f.Employee, proposal.ContextId, new(before.Version, 1), Key(), default)));
        Assert.Equal(before, await f.Counts());
        Assert.Equal(DayDecision.Pending, (await f.Get(revision.Id)).Days[0].Decision);
        Assert.Equal(0, await f.Db(db => db.Set<ProposalAcknowledgement>().CountAsync()));
        Assert.Equal(ProposalState.Open, (await f.Run(s => s.Proposals(f.Employee, f.Employee, revision.Id, 0, 25, default))).Items[0].State);
    }

    [Fact]
    public async Task ManagerProposalOnApprovedDayKeepsOriginalDecisionHistoryUntilExplicitFinalApproval()
    {
        await using var f = new Scenario(); await f.Init();
        var r = await f.Submit((await f.Draft()).ContextId); await f.Decide(r.Id, r.Days);
        r = await f.Get(r.Id); var original = r.Days[0]; var calendar = await f.Calendar(); var plan = calendar.EffectiveDays[0];
        var proposal = await f.Run(s => s.Propose(f.Manager, f.Employee, r.Id, null,
            new(calendar.CalendarVersion, r.Version, Select(r.Days), [new(f.Date, WorkLocation.OfficeSwitzerland, Availability.Working, false, plan.SourceDayId, plan.Version)], "Synthetic alternative"), Key(), default));
        Assert.Equal(plan, (await f.Calendar()).EffectiveDays[0]);
        var accepted = await f.Run(s => s.Accept(f.Employee, f.Employee, proposal.ContextId, new(proposal.CalendarVersion, 1), Key(), default));
        Assert.Equal(plan, (await f.Calendar()).EffectiveDays[0]);
        var revision = await f.Get(accepted.ContextId); await f.Decide(revision.Id, revision.Days);
        var superseded = (await f.Get(r.Id)).Days[0];
        Assert.Equal(original.DecidedAt, superseded.DecidedAt); Assert.Equal(original.DecidedBy, superseded.DecidedBy);
        Assert.Equal(DayDecision.Superseded, superseded.Decision);
        Assert.Equal(WorkLocation.OfficeSwitzerland, (await f.Calendar()).EffectiveDays[0].Location);
        var audit = await f.Db(db => db.Set<PlanningAudit>().OrderByDescending(x => x.CalendarVersion).FirstAsync());
        using var delta = JsonDocument.Parse(audit.ChangedDaysJson);
        Assert.Equal(2, delta.RootElement.GetArrayLength());
    }

    [Fact]
    public async Task DatabaseConstraintsRejectDuplicateEffectiveDatesPendingReservationsAndCrossOrganizationAssociations()
    {
        await using var f = new Scenario(); await f.Init();
        var r = await f.Submit((await f.Draft()).ContextId);
        var competing = await f.Draft();
        var duplicate = await Assert.ThrowsAsync<DbUpdateException>(() => f.Db(async db =>
        {
            var day = await db.Set<RequestedDay>().SingleAsync(x => x.RequestId == competing.ContextId);
            day.ReservesDate = true; return await db.SaveChangesAsync();
        }));
        Assert.Equal(PostgresErrorCodes.UniqueViolation, Assert.IsType<PostgresException>(duplicate.InnerException).SqlState);
        await f.Decide(r.Id, r.Days);
        Assert.Equal(PostgresErrorCodes.UniqueViolation, (await Assert.ThrowsAsync<PostgresException>(() => f.Db(db => db.Database.ExecuteSqlRawAsync("INSERT INTO \"PlanDays\" SELECT * FROM \"PlanDays\"")))).SqlState);
        await Assert.ThrowsAsync<DbUpdateException>(() => f.Db(async db =>
        {
            db.Set<PlanningProfile>().Add(new() { EmployeeId = f.Identity.Stranger.Id, OrganizationId = f.Identity.Employee.OrganizationId });
            return await db.SaveChangesAsync();
        }));
        Assert.Equal(1, (await f.Counts()).Plans);
    }
}
