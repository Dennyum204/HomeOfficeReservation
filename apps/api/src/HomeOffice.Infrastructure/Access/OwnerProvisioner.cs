using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Access;

public sealed record BootstrapAccount(string OrganizationName, string Email, string DisplayName);
public sealed record EnableAdminEmployee(Guid OrganizationId, Guid MemberId, string Reason);
public sealed record OperatorReceipt(string Code, Guid OrganizationId, Guid MemberId, Guid? AuditId);

// Only the server maintenance dispatcher calls this service. It is deliberately not an HTTP endpoint.
public sealed class OwnerProvisioner(HomeOfficeDbContext db, UserManager<IdentityUser> users, InvitationService invitations, InvitationDelivery delivery, TimeProvider clock)
{
    public async Task<OperatorReceipt> BootstrapAsync(BootstrapAccount input, bool owner)
    {
        if (string.IsNullOrWhiteSpace(input.OrganizationName) || input.OrganizationName.Length > 120 ||
            string.IsNullOrWhiteSpace(input.DisplayName) || input.DisplayName.Length > 120 ||
            string.IsNullOrWhiteSpace(input.Email) || input.Email.Length > 254 ||
            !new System.ComponentModel.DataAnnotations.EmailAddressAttribute().IsValid(input.Email))
            throw new InvalidOperationException("Invalid bootstrap identity. Check the private organization, display name and email fields.");

        await using var tx = await db.Database.BeginTransactionAsync();
        // A new organization has no row to lock yet. The transaction-scoped name lock makes retries race-safe.
        await db.Database.ExecuteSqlInterpolatedAsync($"SELECT pg_advisory_xact_lock(hashtextextended({input.OrganizationName}, 0))");
        var organization = await db.Organizations.SingleOrDefaultAsync(o => o.Name == input.OrganizationName);
        if (organization is not null)
        {
            if (!owner) throw new InvalidOperationException("Organization already exists. Use its authenticated account administrator.");
            await AccessChanges.LockOrganization(db, organization.Id);
            var existingUser = await users.FindByEmailAsync(input.Email);
            var existing = await db.Members.AsNoTracking().SingleOrDefaultAsync(m => m.OrganizationId == organization.Id && m.IdentityUserId == (existingUser == null ? null : existingUser.Id));
            var audit = existing is null ? null : await db.Set<AccessAudit>().AsNoTracking().SingleOrDefaultAsync(a =>
                a.OrganizationId == organization.Id && a.MemberId == existing.Id && a.Action == "access.owner_bootstrapped");
            if (existing?.Active != true || !existing.IsAccountAdministrator || !existing.IsEmployee ||
                existing.DisplayName != input.DisplayName || audit is null)
                throw new InvalidOperationException("Existing organization does not match an unchanged owner bootstrap. No roles or identities changed; use the documented operator procedure.");
            return new("already_provisioned", organization.Id, existing.Id, audit.Id);
        }

        organization = new() { Name = input.OrganizationName };
        var user = new IdentityUser { Email = input.Email, UserName = input.Email, LockoutEnabled = true };
        if (!(await users.CreateAsync(user)).Succeeded)
            throw new InvalidOperationException("Provisioning rejected. Check private input validity and existing identities.");
        var member = new Member
        {
            OrganizationId = organization.Id,
            IdentityUserId = user.Id,
            DisplayName = input.DisplayName,
            IsAccountAdministrator = true,
            IsEmployee = owner
        };
        db.Organizations.Add(organization);
        db.Members.Add(member);
        var created = AccessChanges.Record(db, clock, member, null,
            owner ? "access.owner_bootstrapped" : "access.admin_bootstrapped", null, AccessChanges.State(member));
        await invitations.Create(member, user, null);
        await db.SaveChangesAsync();
        await tx.CommitAsync();
        // One best-effort attempt after commit; durable failure is recoverable even if the CLI exits.
        await delivery.TryNow(member.Id);
        return new("provisioned", organization.Id, member.Id, created.Id);
    }

    public async Task<OperatorReceipt> EnableEmployeeAsync(EnableAdminEmployee input)
    {
        if (input.OrganizationId == Guid.Empty || input.MemberId == Guid.Empty ||
            string.IsNullOrWhiteSpace(input.Reason) || input.Reason.Length > 500)
            throw new InvalidOperationException("Supply non-empty organizationId, memberId and a reason of up to 500 characters.");
        await using var tx = await db.Database.BeginTransactionAsync();
        if (!await AccessChanges.LockOrganization(db, input.OrganizationId))
            throw new InvalidOperationException("Organization/member selection is invalid. No changes made.");
        var member = await db.Members.SingleOrDefaultAsync(m => m.OrganizationId == input.OrganizationId && m.Id == input.MemberId);
        if (member is not null) await db.Entry(member).ReloadAsync();
        if (member?.Active != true || !member.IsAccountAdministrator ||
            !await db.Users.AnyAsync(u => u.Id == member.IdentityUserId))
            throw new InvalidOperationException("Select an existing active account administrator in that organization. No changes made.");
        if (member.IsEmployee) return new("already_employee", member.OrganizationId, member.Id, null);

        var before = AccessChanges.State(member);
        member.IsEmployee = true; // This is the only existing-account field this command may change.
        var audit = AccessChanges.Record(db, clock, member, null, "access.admin_employee_enabled", before, AccessChanges.State(member), input.Reason.Trim());
        await db.SaveChangesAsync();
        await tx.CommitAsync();
        return new("employee_enabled", member.OrganizationId, member.Id, audit.Id);
    }
}
