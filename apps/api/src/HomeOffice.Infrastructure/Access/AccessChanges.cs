using System.Text.Json;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Access;

internal static class AccessChanges
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);
    internal sealed record Roles(bool Active, bool IsEmployee, bool IsManager, bool IsAccountAdministrator);
    internal static Roles State(Member member) => new(member.Active, member.IsEmployee, member.IsManager, member.IsAccountAdministrator);

    // All administrative writers acquire this lock before reloading authority and changing members.
    // NO KEY UPDATE serializes writers without blocking FK key-share locks from planning transactions.
    internal static async Task<bool> LockOrganization(HomeOfficeDbContext db, Guid organizationId)
    {
        if (db.Database.CurrentTransaction is null) throw new InvalidOperationException("An explicit access transaction is required.");
        var rows = await db.Organizations.FromSqlInterpolated(
            $"SELECT * FROM \"Organizations\" WHERE \"Id\" = {organizationId} FOR NO KEY UPDATE").AsNoTracking().ToListAsync();
        return rows.Count == 1;
    }

    internal static async Task<Member?> Administrator(HomeOfficeDbContext db, Member actor)
    {
        var current = await db.Members.AsNoTracking().SingleOrDefaultAsync(m => m.Id == actor.Id && m.OrganizationId == actor.OrganizationId);
        return current?.Active == true && current.IsAccountAdministrator && current.IdentityUserId == actor.IdentityUserId ? current : null;
    }

    internal static AccessAudit Record(HomeOfficeDbContext db, TimeProvider clock, Member member,
        Guid? actor, string action, object? before, object? after, string reason = "", string? source = null)
    {
        var audit = new AccessAudit
        {
            OrganizationId = member.OrganizationId,
            MemberId = member.Id,
            ActorMemberId = actor,
            Source = source ?? (actor is null ? "operator" : "administrator"),
            Action = action,
            Reason = reason,
            CreatedAt = clock.GetUtcNow(),
            BeforeJson = JsonSerializer.Serialize(before, Json),
            AfterJson = JsonSerializer.Serialize(after, Json)
        };
        db.Set<AccessAudit>().Add(audit);
        return audit;
    }
}
