using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Access;

public sealed class InvitationService(HomeOfficeDbContext db, UserManager<IdentityUser> users,
    IDataProtectionProvider protection, TimeProvider clock)
{
    internal IDataProtector Protector(Guid memberId) => protection.CreateProtector("HomeOffice.InvitationDelivery.v1", memberId.ToString());
    private static object State(AccessInvitation i) => new { i.State, i.Version, i.DeliveryState };

    // Caller owns the organization transaction. Generating a code is local Identity work, not email delivery.
    internal async Task<AccessInvitation> Create(Member member, IdentityUser user, Guid? actor, string fingerprint = "", bool rotateExisting = false, string? source = null)
    {
        var invitation = new AccessInvitation
        {
            MemberId = member.Id,
            OrganizationId = member.OrganizationId,
            CreatedBy = actor,
            CreationFingerprint = fingerprint,
            CreatedAt = clock.GetUtcNow()
        };
        db.Set<AccessInvitation>().Add(invitation);
        await Queue(invitation, user, rotate: rotateExisting);
        AccessChanges.Record(db, clock, member, actor, "access.invitation_created", null, State(invitation), source: source);
        return invitation;
    }

    private async Task Queue(AccessInvitation invitation, IdentityUser user, bool rotate)
    {
        if (rotate)
        {
            if (!(await users.UpdateSecurityStampAsync(user)).Succeeded) throw new InvalidOperationException("Identity update rejected.");
            invitation.Version++;
        }
        var now = clock.GetUtcNow();
        if (invitation.WindowStartedAt <= now.AddDays(-1)) { invitation.WindowStartedAt = now; invitation.RequestsInWindow = 0; }
        invitation.RequestsInWindow++;
        invitation.LastRequestedAt = now;
        invitation.ProtectedCode = Protector(invitation.MemberId).Protect(await users.GenerateEmailConfirmationTokenAsync(user));
        invitation.CodeExpiresAt = now.AddHours(1);
        invitation.DeliveryState = InvitationDeliveryState.Pending;
        invitation.Attempts = 0; invitation.NextAttemptAt = now; invitation.DeliveredAt = null;
        invitation.LeaseId = null; invitation.LeaseUntil = null; invitation.LastError = null;
    }

    private DateTimeOffset AvailableAt(AccessInvitation i) =>
        i.RequestsInWindow >= 5 && i.WindowStartedAt > clock.GetUtcNow().AddDays(-1)
            ? i.WindowStartedAt.AddDays(1) : i.LastRequestedAt.AddMinutes(1);

    public async Task<OperationResult> Change(Member actor, Guid memberId, InvitationChangeRequest request, bool cancel)
    {
        if (request.CommandId == Guid.Empty || request.ExpectedVersion < 0) return new(false, "invalid_command");
        await using var tx = await db.Database.BeginTransactionAsync();
        if (!await AccessChanges.LockOrganization(db, actor.OrganizationId) ||
            await AccessChanges.Administrator(db, actor) is null) return new(false, "forbidden");
        var member = await db.Members.SingleOrDefaultAsync(m => m.Id == memberId && m.OrganizationId == actor.OrganizationId);
        if (member is null || member.Id == actor.Id) return new(false, "forbidden");
        await db.Entry(member).ReloadAsync();
        var operation = cancel ? "cancel" : "resend";
        var receipt = await db.Set<InvitationCommand>().FindAsync(actor.OrganizationId, actor.Id, request.CommandId);
        if (receipt is not null) return receipt.MemberId == memberId && receipt.Operation == operation && receipt.ExpectedVersion == request.ExpectedVersion
            ? new(true, "already_applied") : new(false, "idempotency_conflict");
        var user = await users.FindByIdAsync(member.IdentityUserId);
        if (user is null) return new(false, "invitation_unavailable");
        await db.Entry(user).ReloadAsync();
        var invitation = await db.Set<AccessInvitation>().FindAsync(memberId);
        if (invitation is not null) await db.Entry(invitation).ReloadAsync();
        if ((invitation?.Version ?? 0) != request.ExpectedVersion) return new(false, "stale_invitation");
        if (user.EmailConfirmed || user.PasswordHash is not null || invitation?.State is InvitationState.Accepted or InvitationState.Cancelled)
            return new(false, "invitation_unavailable");
        if (!cancel && !member.Active) return new(false, "invitation_unavailable");
        if (cancel)
        {
            if (member.Active && member.IsAccountAdministrator && !await db.Members.AnyAsync(m =>
                m.OrganizationId == member.OrganizationId && m.Id != member.Id && m.Active && m.IsAccountAdministrator))
                return new(false, "last_active_administrator");
            await CancelPending(member, actor.Id);
            var before = AccessChanges.State(member);
            member.Active = false;
            if (before != AccessChanges.State(member))
                AccessChanges.Record(db, clock, member, actor.Id, "access.member_updated", before, AccessChanges.State(member));
        }
        else if (invitation is null) await Create(member, user, actor.Id, rotateExisting: true);
        else
        {
            if (AvailableAt(invitation) > clock.GetUtcNow()) return new(false, "resend_limited");
            var before = State(invitation);
            await Queue(invitation, user, rotate: true);
            AccessChanges.Record(db, clock, member, actor.Id, "access.invitation_resent", before, State(invitation));
        }
        db.Set<InvitationCommand>().Add(new()
        {
            OrganizationId = actor.OrganizationId,
            ActorId = actor.Id,
            CommandId = request.CommandId,
            MemberId = memberId,
            Operation = operation,
            ExpectedVersion = request.ExpectedVersion,
            CreatedAt = clock.GetUtcNow()
        });
        await db.SaveChangesAsync(); await tx.CommitAsync();
        return new(true, "applied");
    }

    // Used by both explicit cancellation and existing administrative deactivation, under the same organization lock.
    internal async Task CancelPending(Member member, Guid actorId)
    {
        var user = await users.FindByIdAsync(member.IdentityUserId);
        if (user is null) return;
        await db.Entry(user).ReloadAsync();
        if (user.EmailConfirmed) return;
        var invitation = await db.Set<AccessInvitation>().FindAsync(member.Id);
        if (invitation is null)
        {
            invitation = new() { MemberId = member.Id, OrganizationId = member.OrganizationId, CreatedAt = clock.GetUtcNow() };
            db.Set<AccessInvitation>().Add(invitation);
        }
        if (invitation.State == InvitationState.Cancelled) return;
        var before = State(invitation);
        if (!(await users.UpdateSecurityStampAsync(user)).Succeeded) throw new InvalidOperationException("Identity update rejected.");
        invitation.State = InvitationState.Cancelled; invitation.Version++; invitation.CancelledAt = clock.GetUtcNow();
        Stop(invitation);
        AccessChanges.Record(db, clock, member, actorId, "access.invitation_cancelled", before, State(invitation));
    }

    internal static void Stop(AccessInvitation invitation)
    {
        invitation.ProtectedCode = null; invitation.LeaseId = null; invitation.LeaseUntil = null;
        invitation.DeliveryState = InvitationDeliveryState.Stopped; invitation.LastError = null;
    }

    public async Task<Guid?> RequestAnonymous(string email)
    {
        if (string.IsNullOrWhiteSpace(email) || email.Length > 254) return null;
        var user = await users.FindByEmailAsync(email);
        var member = user is null ? null : await db.Members.AsNoTracking().SingleOrDefaultAsync(m => m.IdentityUserId == user.Id);
        if (member is null) return null;
        await using var tx = await db.Database.BeginTransactionAsync();
        if (!await AccessChanges.LockOrganization(db, member.OrganizationId)) return null;
        member = await db.Members.AsNoTracking().SingleAsync(m => m.Id == member.Id);
        await db.Entry(user!).ReloadAsync();
        var invitation = await db.Set<AccessInvitation>().FindAsync(member.Id);
        if (!member.Active || user!.EmailConfirmed || user.PasswordHash is not null ||
            invitation?.State is InvitationState.Cancelled or InvitationState.Accepted) return null;
        if (invitation is null)
        {
            // Legacy accounts were already admitted administratively. This never creates a user or member.
            invitation = await Create(member, user, null, rotateExisting: true, source: "anonymous");
        }
        else
        {
            if (AvailableAt(invitation) > clock.GetUtcNow()) return null;
            var before = State(invitation);
            await Queue(invitation, user, rotate: true);
            AccessChanges.Record(db, clock, member, null, "access.invitation_resent", before, State(invitation), source: "anonymous");
        }
        await db.SaveChangesAsync(); await tx.CommitAsync();
        return member.Id;
    }

    public async Task<bool> Complete(string email, string code, string password)
    {
        if (string.IsNullOrWhiteSpace(email) || email.Length > 254 || string.IsNullOrEmpty(code) || code.Length > 16384 ||
            string.IsNullOrEmpty(password) || password.Length > 512) return false;
        var user = await users.FindByEmailAsync(email);
        var member = user is null ? null : await db.Members.AsNoTracking().SingleOrDefaultAsync(m => m.IdentityUserId == user.Id);
        if (member is null) return false;
        await using var tx = await db.Database.BeginTransactionAsync();
        if (!await AccessChanges.LockOrganization(db, member.OrganizationId)) return false;
        member = await db.Members.AsNoTracking().SingleAsync(m => m.Id == member.Id);
        await db.Entry(user!).ReloadAsync();
        var invitation = await db.Set<AccessInvitation>().FindAsync(member.Id);
        if (!member.Active || user!.EmailConfirmed || user.PasswordHash is not null ||
            invitation is not null && (invitation.State != InvitationState.Pending || invitation.CodeExpiresAt <= clock.GetUtcNow())) return false;
        if (!(await users.ConfirmEmailAsync(user, code)).Succeeded || !(await users.AddPasswordAsync(user, password)).Succeeded) return false;
        if (invitation is null)
        {
            invitation = new() { MemberId = member.Id, OrganizationId = member.OrganizationId, CreatedAt = clock.GetUtcNow() };
            db.Set<AccessInvitation>().Add(invitation);
        }
        var before = State(invitation);
        invitation.State = InvitationState.Accepted; invitation.AcceptedAt = clock.GetUtcNow(); invitation.Version++;
        Stop(invitation);
        AccessChanges.Record(db, clock, member, null, "access.invitation_accepted", before, State(invitation), source: "anonymous");
        await db.SaveChangesAsync(); await tx.CommitAsync();
        return true;
    }

    public async Task<InvitationPage?> List(Member actor, Guid? after, int limit)
    {
        if (limit is < 1 or > 100 || await AccessChanges.Administrator(db, actor) is null) return null;
        var members = await db.Members.AsNoTracking().Where(m => m.OrganizationId == actor.OrganizationId &&
            (after == null || m.Id.CompareTo(after.Value) > 0)).OrderBy(m => m.Id).Take(limit + 1).ToArrayAsync();
        var ids = members.Take(limit).Select(m => m.Id).ToArray();
        var identities = await db.Users.AsNoTracking().Where(u => members.Select(m => m.IdentityUserId).Contains(u.Id)).ToDictionaryAsync(u => u.Id);
        var invites = await db.Set<AccessInvitation>().AsNoTracking().Where(i => ids.Contains(i.MemberId)).ToDictionaryAsync(i => i.MemberId);
        var lines = await db.ReportingLines.AsNoTracking().Where(l => l.OrganizationId == actor.OrganizationId && ids.Contains(l.EmployeeId)).ToDictionaryAsync(l => l.EmployeeId);
        var managerIds = lines.Values.Select(l => l.ManagerId).ToArray();
        var managers = await db.Members.AsNoTracking().Where(m => m.OrganizationId == actor.OrganizationId && managerIds.Contains(m.Id)).ToDictionaryAsync(m => m.Id);
        var profiles = members.Take(limit).Select(m =>
        {
            var user = identities[m.IdentityUserId]; invites.TryGetValue(m.Id, out var i); lines.TryGetValue(m.Id, out var line);
            var valid = line is not null && managers.TryGetValue(line.ManagerId, out var manager) && AccessRules.CanManage(manager, m, line);
            return new InvitationProfile(m.Id, user.Email!, m.DisplayName, m.Active, m.IsEmployee, m.IsManager, m.IsAccountAdministrator,
                line?.ManagerId, valid, user.EmailConfirmed, i?.State.ToString() ?? (user.EmailConfirmed ? "Accepted" : "Pending"),
                i?.Version ?? 0, i?.DeliveryState.ToString() ?? "Unknown", i?.Attempts ?? 0, i?.LastError,
                i?.CodeExpiresAt, i?.DeliveredAt, i?.AcceptedAt, i?.CancelledAt,
                m.Active && !user.EmailConfirmed && i?.State != InvitationState.Cancelled ? i is null ? clock.GetUtcNow() : AvailableAt(i) : null);
        }).ToArray();
        return new(profiles, members.Length > limit ? ids[^1] : null);
    }
}
