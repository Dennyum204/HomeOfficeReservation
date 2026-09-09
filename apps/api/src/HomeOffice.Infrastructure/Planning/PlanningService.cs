using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using HomeOffice.Application.Planning;
using HomeOffice.Domain.Access;
using HomeOffice.Domain.Planning;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using static HomeOffice.Domain.Planning.PlanningRules;

namespace HomeOffice.Infrastructure.Planning;

public sealed partial class PlanningService(HomeOfficeDbContext db, TimeProvider clock) : IPlanningService
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    { Converters = { new JsonStringEnumConverter() } };
    private enum Permission { Read, Employee, Manager }
    private sealed record DayAuditDelta(Guid DayId, Guid RequestId, string State, DayDecision? Before, DayDecision? After, long Version);
    private readonly List<DayAuditDelta> dayChanges = [];
    private void CaptureDayChanges()
    {
        db.ChangeTracker.DetectChanges();
        dayChanges.AddRange(db.ChangeTracker.Entries<RequestedDay>().Where(e => e.State is EntityState.Added or EntityState.Modified or EntityState.Deleted)
            .Select(e => new DayAuditDelta(e.Entity.Id, e.Entity.RequestId, e.State.ToString(),
                e.State == EntityState.Added ? null : e.OriginalValues.GetValue<DayDecision>(nameof(RequestedDay.Decision)),
                e.State == EntityState.Deleted ? null : e.Entity.Decision, e.Entity.Version)));
    }
    private async Task SaveIntermediate(CancellationToken ct)
    { CaptureDayChanges(); await db.SaveChangesAsync(ct); }
    private async Task<Member> Authorize(Guid actorId, Guid employeeId, Permission permission, bool locked, CancellationToken ct)
    {
        var members = locked
            ? await db.Members.FromSqlInterpolated($"SELECT * FROM \"Members\" WHERE \"Id\" IN ({actorId}, {employeeId}) ORDER BY \"Id\" FOR SHARE").AsNoTracking().ToListAsync(ct)
            : await db.Members.AsNoTracking().Where(x => x.Id == actorId || x.Id == employeeId).ToListAsync(ct);
        var actor = members.SingleOrDefault(x => x.Id == actorId);
        var employee = members.SingleOrDefault(x => x.Id == employeeId);
        Require(actor?.Active == true && employee?.Active == true && employee.IsEmployee && actor.OrganizationId == employee.OrganizationId, "forbidden", 403);
        var line = locked
            ? (await db.ReportingLines.FromSqlInterpolated($"SELECT * FROM \"ReportingLines\" WHERE \"EmployeeId\" = {employeeId} FOR SHARE").AsNoTracking().ToListAsync(ct)).SingleOrDefault()
            : await db.ReportingLines.AsNoTracking().SingleOrDefaultAsync(x => x.EmployeeId == employeeId, ct);
        Require(permission switch
        {
            Permission.Employee => actorId == employeeId,
            Permission.Manager => AccessRules.CanManage(actor!, employee!, line),
            _ => actorId == employeeId || AccessRules.CanManage(actor!, employee!, line)
        }, "forbidden", 403);
        return employee!;
    }

    private async Task<MutationReceipt> Mutate(Guid actor, Guid employee, Permission permission, string operation,
        Guid? context, object input, string key, long? expected, Func<PlanningProfile, Task<(Guid Id, long Version)>> change, CancellationToken ct)
    {
        Require(key.Length is >= 8 and <= 128 && key.All(c => char.IsAsciiLetterOrDigit(c) || c is '-' or '_' or '.'), "idempotency_key_required", 400);
        dayChanges.Clear();
        var hash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(new { employee, context, input }, Json))));
        await using var tx = await db.Database.BeginTransactionAsync(ct);
        var target = await Authorize(actor, employee, permission, false, ct);
        // INSERT is race-safe for a newly provisioned member. No inferred PlanDays are created.
        await db.Database.ExecuteSqlInterpolatedAsync($"INSERT INTO \"PlanningProfiles\" (\"EmployeeId\", \"OrganizationId\", \"CalendarVersion\") VALUES ({employee}, {target.OrganizationId}, 0) ON CONFLICT (\"EmployeeId\") DO NOTHING", ct);
        var profile = (await db.Set<PlanningProfile>().FromSqlInterpolated($"SELECT * FROM \"PlanningProfiles\" WHERE \"EmployeeId\" = {employee} FOR UPDATE").ToListAsync(ct)).Single();
        await Authorize(actor, employee, permission, true, ct); // Fresh authority after waiting for the profile lock.
        var previous = await db.Set<PlanningReceipt>().SingleOrDefaultAsync(x => x.ActorId == actor && x.Operation == operation && x.Key == key, ct);
        if (previous is not null)
        {
            Require(previous.PayloadHash == hash, "idempotency_payload_mismatch");
            return JsonSerializer.Deserialize<MutationReceipt>(previous.ResponseJson, Json)!;
        }
        Version(expected, profile.CalendarVersion);
        profile.CalendarVersion++;
        var changed = await change(profile);
        if (operation is "planning.decided" or "onsite.created" or "onsite.edited" or "onsite.cancelled")
        {
            await SaveIntermediate(ct);
            await ReconcileRequirements(profile, actor, ct);
            if (operation.StartsWith("onsite.", StringComparison.Ordinal))
                changed = (changed.Id, (await LoadRequirement(employee, changed.Id, ct)).Version);
        }
        var eventId = Guid.NewGuid();
        var now = clock.GetUtcNow();
        var receipt = new MutationReceipt(changed.Id, changed.Version, profile.CalendarVersion, eventId);
        CaptureDayChanges();
        db.Set<PlanningAudit>().Add(new()
        {
            Id = eventId,
            OrganizationId = profile.OrganizationId,
            EmployeeId = employee,
            ActorId = actor,
            ContextId = changed.Id,
            Action = operation,
            CalendarVersion = profile.CalendarVersion,
            CreatedAt = now,
            ChangedDaysJson = JsonSerializer.Serialize(dayChanges, Json)
        });
        db.Set<PlanningOutbox>().Add(new()
        {
            Id = eventId,
            OrganizationId = profile.OrganizationId,
            EmployeeId = employee,
            Type = operation,
            CalendarVersion = profile.CalendarVersion,
            CreatedAt = now,
            Payload = JsonSerializer.Serialize(new { schemaVersion = 1, eventId, employeeId = employee, contextId = changed.Id, actorId = actor, calendarVersion = profile.CalendarVersion }, Json)
        });
        db.Set<PlanningReceipt>().Add(new()
        {
            ActorId = actor,
            Operation = operation,
            Key = key,
            PayloadHash = hash,
            ResponseJson = JsonSerializer.Serialize(receipt, Json),
            CreatedAt = now
        });
        try
        {
            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);
        }
        catch (DbUpdateException e) when (e.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation })
        { throw new PlanningException(409, "concurrent_conflict"); }
        return receipt;
    }

    private async Task<DateOnly> Today(Guid organization, CancellationToken ct) => PlanningRules.Today(clock.GetUtcNow(),
        await db.Organizations.Where(x => x.Id == organization).Select(x => x.PlanningTimeZone).SingleAsync(ct));
    private async Task<PlanningRequest> LoadRequest(Guid employee, Guid id, CancellationToken ct)
    {
        var request = await db.Set<PlanningRequest>().Include(x => x.Days).SingleOrDefaultAsync(x => x.EmployeeId == employee && x.Id == id, ct);
        Require(request is not null, "request_not_found", 404);
        return request!;
    }
    private static RequestedDayView DayView(RequestedDay d) => new(d.Id, d.LocalDate, d.Location, d.Availability, d.Cancel,
        d.BaseDayId, d.BasePlanVersion, d.Decision, d.Version, d.Reason, d.DecidedBy, d.DecidedAt);
    private static RequestView View(PlanningRequest r) => new(r.Id, r.EmployeeId, r.RootId, r.ParentRevisionId, r.Revision,
        r.Version, r.State, r.Note, r.CreatedAt, r.SubmittedAt, r.AcceptedProposalId, r.Days.OrderBy(d => d.LocalDate).Select(DayView).ToArray());
    private static void Page(int offset, int limit) => Require(offset is >= 0 and <= 10000 && limit is > 0 and <= 100, "invalid_pagination", 400);
    private static void Text(string? text, int max, bool required = false) => Require(text is not null && text.Length <= max && (!required || !string.IsNullOrWhiteSpace(text)), "invalid_text", 400);
    private static void Visible(PlanningRequest r, Guid actor) => Require(r.State != RequestState.Draft || r.EmployeeId == actor, "private_draft", 403);
    private static SelectedDay[] Selection(SelectedDay[]? selected)
    {
        Require(selected is { Length: > 0 and <= 366 } && selected.All(x => x is not null), "invalid_selection", 400);
        Require(selected!.Select(x => x.DayId).Distinct().Count() == selected.Length, "duplicate_selection", 400);
        return selected;
    }
    private static RequestedDay[] Pending(PlanningRequest r, SelectedDay[] selected)
    {
        Require(r.State == RequestState.Submitted, "request_not_pending");
        return Selection(selected).Select(s =>
        {
            var d = r.Days.SingleOrDefault(d => d.Id == s.DayId);
            Require(d?.Decision == DayDecision.Pending, "day_not_pending");
            Version(s.ExpectedVersion, d!.Version);
            return d;
        }).ToArray();
    }
    private void Resolve(RequestedDay day, DayDecision decision, Guid actor, string? reason)
    {
        day.Decision = decision; day.ReservesDate = false; day.Version++;
        day.DecidedAt = clock.GetUtcNow(); day.DecidedBy = actor; day.Reason = reason;
    }
}
