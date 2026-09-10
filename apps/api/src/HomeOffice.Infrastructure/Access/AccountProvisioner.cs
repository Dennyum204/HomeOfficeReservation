using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Access;

public sealed class AccountProvisioner(HomeOfficeDbContext db, UserManager<IdentityUser> users, InvitationService invitations, InvitationDelivery delivery, TimeProvider clock)
{
    public async Task<OperationResult> ProvisionAsync(Member actor, ProvisionMemberRequest request)
    {
        if (!actor.Active || !actor.IsAccountAdministrator) return new(false, "forbidden");
        if (string.IsNullOrWhiteSpace(request.DisplayName) || request.DisplayName.Length > 120 ||
            string.IsNullOrWhiteSpace(request.Email) || request.Email.Length > 254 ||
            !new System.ComponentModel.DataAnnotations.EmailAddressAttribute().IsValid(request.Email))
            return new(false, "invalid_member");
        await using var transaction = await db.Database.BeginTransactionAsync();
        if (!await AccessChanges.LockOrganization(db, actor.OrganizationId) ||
            await AccessChanges.Administrator(db, actor) is null) return new(false, "forbidden");
        var normalizedEmail = users.NormalizeEmail(request.Email);
        var fingerprint = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(
            System.Text.Json.JsonSerializer.Serialize(request with { Email = normalizedEmail, DisplayName = request.DisplayName.Trim() }))));
        // Cross-organization creates of the same address are serialized before Identity uniqueness is evaluated.
        await db.Database.ExecuteSqlInterpolatedAsync($"SELECT pg_advisory_xact_lock(hashtextextended({normalizedEmail}, 1))");
        var existingUser = await users.FindByEmailAsync(request.Email);
        if (existingUser is not null)
        {
            var existing = await (from m in db.Members
                                  join i in db.Set<AccessInvitation>() on m.Id equals i.MemberId
                                  where m.OrganizationId == actor.OrganizationId && m.IdentityUserId == existingUser.Id
                                  select i).AsNoTracking().SingleOrDefaultAsync();
            return existing?.CreatedBy == actor.Id && existing.CreationFingerprint == fingerprint
                ? new(true, "already_provisioned") : new(false, "account_exists");
        }
        if (await db.Set<AccessInvitation>().CountAsync(i => i.OrganizationId == actor.OrganizationId && i.CreatedAt > clock.GetUtcNow().AddHours(-1)) >= 20)
            return new(false, "invitation_limit");
        var user = new IdentityUser { UserName = request.Email, Email = request.Email, LockoutEnabled = true };
        var result = await users.CreateAsync(user); // No password until the account owner activates it.
        if (!result.Succeeded) return new(false, "invalid_member");
        var member = new Member
        {
            IdentityUserId = user.Id,
            OrganizationId = actor.OrganizationId,
            DisplayName = request.DisplayName.Trim(),
            IsEmployee = request.IsEmployee,
            IsManager = request.IsManager,
            IsAccountAdministrator = request.IsAccountAdministrator
        };
        db.Members.Add(member);
        AccessChanges.Record(db, clock, member, actor.Id, "access.member_provisioned", null, AccessChanges.State(member));
        await invitations.Create(member, user, actor.Id, fingerprint);
        await db.SaveChangesAsync();
        await transaction.CommitAsync();
        await delivery.TryNow(member.Id);
        return new(true, "provisioned");
    }
}
