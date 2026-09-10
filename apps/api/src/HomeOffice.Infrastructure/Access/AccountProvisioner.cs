using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Access;

public sealed class AccountProvisioner(HomeOfficeDbContext db, UserManager<IdentityUser> users, IAccountEmail email, TimeProvider clock)
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
        if (await users.FindByEmailAsync(request.Email) is not null) return new(false, "account_exists");
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
        await db.SaveChangesAsync();
        await transaction.CommitAsync();
        // Delivery is outside the transaction. A failed delivery can be retried through the activation request endpoint.
        await email.SendAsync(user.Email, "activate", await users.GenerateEmailConfirmationTokenAsync(user));
        return new(true, "provisioned");
    }
}
