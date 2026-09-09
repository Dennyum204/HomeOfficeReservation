using System.Data;
using System.Text.Json;
using HomeOffice.Application.Planning;
using HomeOffice.Domain.Planning;
using Microsoft.EntityFrameworkCore;
using static HomeOffice.Domain.Planning.PlanningRules;

namespace HomeOffice.Infrastructure.Planning;

public sealed partial class PlanningService
{
    private async Task<T> Read<T>(Guid actor, Guid employee, Func<Task<T>> query, CancellationToken ct)
    {
        await using var tx = await db.Database.BeginTransactionAsync(IsolationLevel.RepeatableRead, ct);
        await Authorize(actor, employee, Permission.Read, false, ct);
        return await query(); // One consistent snapshot for the version and every projected row.
    }
    private async Task<long> CalendarVersion(Guid employee, CancellationToken ct) =>
        await db.Set<PlanningProfile>().Where(x => x.EmployeeId == employee).Select(x => (long?)x.CalendarVersion).SingleOrDefaultAsync(ct) ?? 0;
    public Task<CalendarView> Calendar(Guid actor, Guid employee, DateOnly from, DateOnly to, CancellationToken ct) => Read(actor, employee, async () =>
    {
        Require(to >= from && to.DayNumber - from.DayNumber < 366, "invalid_range", 400);
        var zone = await (from m in db.Members join o in db.Organizations on m.OrganizationId equals o.Id where m.Id == employee select o.PlanningTimeZone).SingleAsync(ct);
        var today = PlanningRules.Today(clock.GetUtcNow(), zone);
        Require(from >= today.AddDays(-365) && to <= today.AddDays(730), "calendar_window_exceeded", 400);
        var version = await CalendarVersion(employee, ct);
        var plans = await db.Set<PlanDay>().Where(x => x.EmployeeId == employee && x.LocalDate >= from && x.LocalDate <= to).ToDictionaryAsync(x => x.LocalDate, ct);
        var priorPattern = await db.Set<WeeklyPattern>().Where(x => x.EmployeeId == employee && x.EffectiveFrom <= from).OrderByDescending(x => x.EffectiveFrom).FirstOrDefaultAsync(ct);
        var patterns = await db.Set<WeeklyPattern>().Where(x => x.EmployeeId == employee && x.EffectiveFrom > from && x.EffectiveFrom <= to).ToListAsync(ct);
        if (priorPattern is not null) patterns.Add(priorPattern);
        var pending = await (from d in db.Set<RequestedDay>()
                             join r in db.Set<PlanningRequest>() on d.RequestId equals r.Id
                             where d.EmployeeId == employee && d.ReservesDate && d.LocalDate >= @from && d.LocalDate <= to
                             orderby d.LocalDate
                             select new { Day = d, Request = r }).ToListAsync(ct);
        var effective = Expand(from, to, true).Select(date =>
        {
            if (plans.TryGetValue(date, out var p)) return new EffectiveDay(date, p.Location, p.Availability, "ApprovedRequest", p.Version, p.SourceDayId, p.DecidedBy);
            var pattern = patterns.Where(x => x.EffectiveFrom <= date).OrderByDescending(x => x.EffectiveFrom).FirstOrDefault();
            var location = pattern is null ? DefaultLocation(date) : pattern.Locations[((int)date.DayOfWeek + 6) % 7];
            return new EffectiveDay(date, location, location == WorkLocation.Unplanned ? null : Availability.Working, "WeeklyPattern", pattern?.Version ?? 0, null, null);
        }).ToArray();
        return new CalendarView(employee, version, zone, from, to, effective, pending.Select(p => new PendingDay(p.Request.Id, p.Request.Version, DayView(p.Day))).ToArray());
    }, ct);
    public Task<RequestPage> Requests(Guid actor, Guid employee, int offset, int limit, CancellationToken ct) => Read(actor, employee, async () =>
    {
        Page(offset, limit);
        var rows = await db.Set<PlanningRequest>().Include(x => x.Days).Where(x => x.EmployeeId == employee && (actor == employee || x.State != RequestState.Draft))
            .OrderByDescending(x => x.CreatedAt).ThenBy(x => x.Id).Skip(offset).Take(limit + 1).ToListAsync(ct);
        return new RequestPage(rows.Take(limit).Select(View).ToArray(), rows.Count > limit ? offset + limit : null, await CalendarVersion(employee, ct));
    }, ct);
    public Task<RequestView> Request(Guid actor, Guid employee, Guid id, CancellationToken ct) => Read(actor, employee, async () =>
    { var r = await LoadRequest(employee, id, ct); Visible(r, actor); return View(r); }, ct);
    public Task<ProposalPage> Proposals(Guid actor, Guid employee, Guid request, int offset, int limit, CancellationToken ct) => Read(actor, employee, async () =>
    {
        Page(offset, limit); Visible(await LoadRequest(employee, request, ct), actor);
        var rows = await db.Set<ChangeProposal>().Where(x => x.EmployeeId == employee && x.RequestId == request).OrderByDescending(x => x.CreatedAt).ThenBy(x => x.Id).Skip(offset).Take(limit + 1).ToArrayAsync(ct);
        var ids = rows.Select(x => x.Id).ToArray();
        var acks = await db.Set<ProposalAcknowledgement>().Where(x => ids.Contains(x.ProposalId)).ToDictionaryAsync(x => x.ProposalId, ct);
        return new ProposalPage(rows.Take(limit).Select(p => new ProposalView(p.Id, p.GroupId, p.Revision, p.RequestId, p.AuthorId, p.Reason,
            p.AffectedDayIds, JsonSerializer.Deserialize<DayInput[]>(p.DaysJson, Json)!, p.State, p.CreatedAt, p.AcceptedRequestId,
            acks.GetValueOrDefault(p.Id)?.AcknowledgedAt)).ToArray(), rows.Length > limit ? offset + limit : null);
    }, ct);
    public Task<CommentPage> Comments(Guid actor, Guid employee, Guid request, int offset, int limit, CancellationToken ct) => Read(actor, employee, async () =>
    {
        Page(offset, limit); Visible(await LoadRequest(employee, request, ct), actor);
        var rows = await db.Set<PlanningComment>().Where(x => x.EmployeeId == employee && x.RequestId == request).OrderBy(x => x.CreatedAt).ThenBy(x => x.Id)
            .Skip(offset).Take(limit + 1).Select(x => new CommentView(x.Id, x.RequestId, x.ProposalId, x.AuthorId, x.Text, x.CreatedAt)).ToArrayAsync(ct);
        return new CommentPage(rows.Take(limit).ToArray(), rows.Length > limit ? offset + limit : null);
    }, ct);
    public Task<PatternPage> Patterns(Guid actor, Guid employee, int offset, int limit, CancellationToken ct) => Read(actor, employee, async () =>
    {
        Page(offset, limit);
        var rows = await db.Set<WeeklyPattern>().Where(x => x.EmployeeId == employee).OrderByDescending(x => x.EffectiveFrom).Skip(offset).Take(limit + 1)
            .Select(x => new PatternView(x.EffectiveFrom, x.Locations, x.Version)).ToArrayAsync(ct);
        return new PatternPage(await CalendarVersion(employee, ct), rows.Take(limit).ToArray(), rows.Length > limit ? offset + limit : null);
    }, ct);
}
