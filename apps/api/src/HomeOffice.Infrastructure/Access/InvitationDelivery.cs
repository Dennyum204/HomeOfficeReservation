using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Access;

public sealed record InvitationLease(Guid MemberId, Guid LeaseId, long Version);

public sealed class InvitationDelivery(HomeOfficeDbContext db, InvitationService invitations, IAccountEmail email, TimeProvider clock)
{
    public async Task<InvitationLease?> Claim(Guid? memberId = null, CancellationToken ct = default)
    {
        var now = clock.GetUtcNow(); var lease = Guid.NewGuid(); var until = now.AddMinutes(2);
        await db.Set<AccessInvitation>().Where(i => i.State == InvitationState.Pending &&
            (i.DeliveryState == InvitationDeliveryState.Pending || i.DeliveryState == InvitationDeliveryState.Sending && i.LeaseUntil <= now) &&
            (i.Attempts >= 5 || i.CodeExpiresAt <= now))
            .ExecuteUpdateAsync(s => s.SetProperty(i => i.DeliveryState, InvitationDeliveryState.Failed)
                .SetProperty(i => i.LastError, "delivery_expired_or_exhausted").SetProperty(i => i.ProtectedCode, (string?)null)
                .SetProperty(i => i.LeaseId, (Guid?)null).SetProperty(i => i.LeaseUntil, (DateTimeOffset?)null), ct);
        // Same PostgreSQL lease pattern as the notification worker; only one item is claimed immediately before I/O.
        var rows = await db.Set<AccessInvitation>().FromSqlInterpolated($"""
            WITH candidate AS (
              SELECT "MemberId" FROM "AccessInvitations"
              WHERE "State"=0 AND ("DeliveryState"=0 OR ("DeliveryState"=1 AND "LeaseUntil"<={now}))
                AND "NextAttemptAt"<={now} AND "Attempts"<5 AND "CodeExpiresAt">{now}
                AND ({memberId}::uuid IS NULL OR "MemberId"={memberId})
              ORDER BY "NextAttemptAt", "MemberId" LIMIT 1 FOR UPDATE SKIP LOCKED
            ) UPDATE "AccessInvitations" i SET "DeliveryState"=1, "LeaseId"={lease}, "LeaseUntil"={until}, "Attempts"=i."Attempts"+1
            FROM candidate c WHERE i."MemberId"=c."MemberId" RETURNING i.*
            """).AsNoTracking().ToArrayAsync(ct);
        var row = rows.SingleOrDefault();
        return row is null ? null : new(row.MemberId, lease, row.Version);
    }

    public async Task Process(InvitationLease claim, CancellationToken ct = default)
    {
        var invitation = await db.Set<AccessInvitation>().AsNoTracking().SingleOrDefaultAsync(i => i.MemberId == claim.MemberId &&
            i.LeaseId == claim.LeaseId && i.Version == claim.Version && i.State == InvitationState.Pending && i.LeaseUntil > clock.GetUtcNow(), ct);
        if (invitation is null) return;
        var recipient = await (from member in db.Members.AsNoTracking()
                               join user in db.Users.AsNoTracking() on member.IdentityUserId equals user.Id
                               where member.Id == invitation.MemberId && member.OrganizationId == invitation.OrganizationId && member.Active && !user.EmailConfirmed
                               select user.Email).SingleOrDefaultAsync(ct);
        string? error = null;
        if (recipient is null) error = "recipient_unavailable";
        else if (invitation.CodeExpiresAt <= clock.GetUtcNow()) error = "code_expired";
        else
        {
            try
            {
                var code = invitations.Protector(invitation.MemberId).Unprotect(invitation.ProtectedCode!);
                // No organization/database lock during SMTP. A concurrent cancel/resend makes this code invalid.
                await email.SendAsync(recipient, "activate", code);
            }
            catch (System.Security.Cryptography.CryptographicException) { error = "code_unavailable"; }
            catch (Exception) { error = "delivery_failed"; } // Provider exceptions can contain credentials or recipients.
        }
        var now = clock.GetUtcNow();
        var failed = error is not null && (error != "delivery_failed" || invitation.Attempts >= 5);
        var state = error is null ? InvitationDeliveryState.Sent : failed ? InvitationDeliveryState.Failed : InvitationDeliveryState.Pending;
        // A late result cannot overwrite acceptance, cancellation, a newer code or another worker's lease.
        await db.Set<AccessInvitation>().Where(i => i.MemberId == claim.MemberId && i.LeaseId == claim.LeaseId &&
            i.Version == claim.Version && i.State == InvitationState.Pending)
            .ExecuteUpdateAsync(s => s.SetProperty(i => i.DeliveryState, state).SetProperty(i => i.LastError, error)
                .SetProperty(i => i.DeliveredAt, error == null ? now : (DateTimeOffset?)null)
                .SetProperty(i => i.NextAttemptAt, now.AddSeconds(30 * (1 << Math.Min(invitation.Attempts, 5))))
                .SetProperty(i => i.ProtectedCode, error == null || failed ? null : invitation.ProtectedCode)
                .SetProperty(i => i.LeaseId, (Guid?)null).SetProperty(i => i.LeaseUntil, (DateTimeOffset?)null), ct);
    }

    public async Task TryNow(Guid memberId)
    {
        try { var claim = await Claim(memberId); if (claim is not null) await Process(claim); }
        catch (Exception) { /* Already committed durable work is recovered by the worker. Do not lose the creation response. */ }
    }
}
