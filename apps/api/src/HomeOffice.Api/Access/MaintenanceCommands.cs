using System.Text.Json;
using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace HomeOffice.Api.Access;

public sealed record ProvisionedAccount(string Email, string Password, string DisplayName);
public sealed record DevelopmentAccounts(string OrganizationName, ProvisionedAccount Admin, ProvisionedAccount Manager, ProvisionedAccount Employee);
public sealed record BootstrapAdmin(string OrganizationName, string Email, string DisplayName);

public static class MaintenanceCommands
{
    public static async Task<bool> ExecuteAsync(string[] args, WebApplication app)
    {
        if (!args.Any(a => a is "--migrate" or "--provision-dev" or "--bootstrap-admin")) return false;
        await using var scope = app.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<HomeOfficeDbContext>();
        if (args.Contains("--migrate"))
        {
            await db.Database.MigrateAsync();
            Console.WriteLine("Explicit migrations applied. No accounts provisioned.");
            return true;
        }
        app.Services.GetService<IStartupValidator>()?.Validate();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<IdentityUser>>();
        var dev = args.Contains("--provision-dev");
        if (dev && !app.Environment.IsDevelopment()) throw new InvalidOperationException("Synthetic provisioning is Development-only.");
        var flag = dev ? "--provision-dev" : "--bootstrap-admin";
        var index = Array.IndexOf(args, flag);
        if (index + 1 >= args.Length) throw new InvalidOperationException("Supply the private provisioning JSON file path.");
        var json = await File.ReadAllTextAsync(args[index + 1]);
        var jsonOptions = new JsonSerializerOptions(JsonSerializerDefaults.Web);
        await using var transaction = await db.Database.BeginTransactionAsync();
        if (dev)
        {
            var accounts = JsonSerializer.Deserialize<DevelopmentAccounts>(json, jsonOptions) ?? throw new InvalidOperationException("Invalid development accounts file.");
            var organization = await db.Organizations.SingleOrDefaultAsync(o => o.Name == accounts.OrganizationName);
            if (organization is null) { organization = new() { Name = accounts.OrganizationName }; db.Organizations.Add(organization); await db.SaveChangesAsync(); }
            var admin = await EnsureDevelopmentMember(accounts.Admin, organization.Id, false, false, true, db, users);
            var manager = await EnsureDevelopmentMember(accounts.Manager, organization.Id, true, true, false, db, users);
            var employee = await EnsureDevelopmentMember(accounts.Employee, organization.Id, true, false, false, db, users);
            if (!await db.ReportingLines.AnyAsync(l => l.EmployeeId == employee.Id))
                db.ReportingLines.Add(new() { OrganizationId = organization.Id, ManagerId = manager.Id, EmployeeId = employee.Id });
            await db.SaveChangesAsync();
            await transaction.CommitAsync();
            Console.WriteLine("Synthetic development members prepared. Existing passwords/permissions preserved; credentials remain in the private input file.");
        }
        else
        {
            // Server operator only, never HTTP. Refuse to add an administrator to an existing organization.
            var input = JsonSerializer.Deserialize<BootstrapAdmin>(json, jsonOptions) ?? throw new InvalidOperationException("Invalid bootstrap file.");
            if (string.IsNullOrWhiteSpace(input.OrganizationName) || string.IsNullOrWhiteSpace(input.DisplayName))
                throw new InvalidOperationException("Organization and display name are required.");
            if (await db.Organizations.AnyAsync(o => o.Name == input.OrganizationName))
                throw new InvalidOperationException("Organization already exists. Use its authenticated account administrator.");
            var organization = new Organization { Name = input.OrganizationName };
            var user = new IdentityUser { Email = input.Email, UserName = input.Email, LockoutEnabled = true };
            Ensure(await users.CreateAsync(user));
            db.Organizations.Add(organization);
            db.Members.Add(new Member { OrganizationId = organization.Id, IdentityUserId = user.Id, DisplayName = input.DisplayName, IsAccountAdministrator = true });
            await db.SaveChangesAsync();
            await transaction.CommitAsync();
            await scope.ServiceProvider.GetRequiredService<IAccountEmail>().SendAsync(input.Email, "activate", await users.GenerateEmailConfirmationTokenAsync(user));
            Console.WriteLine("Initial administrator provisioned without a password. Complete activation using the configured delivery channel.");
        }
        return true;
    }

    private static async Task<Member> EnsureDevelopmentMember(ProvisionedAccount input, Guid organizationId,
        bool employee, bool manager, bool administrator, HomeOfficeDbContext db, UserManager<IdentityUser> users)
    {
        var user = await users.FindByEmailAsync(input.Email);
        if (user is not null)
        {
            var existing = await db.Members.SingleOrDefaultAsync(m => m.IdentityUserId == user.Id);
            if (existing?.OrganizationId != organizationId) throw new InvalidOperationException("Existing account belongs to a different setup; no changes made.");
            return existing;
        }
        user = new() { Email = input.Email, UserName = input.Email, EmailConfirmed = true, LockoutEnabled = true };
        Ensure(await users.CreateAsync(user, input.Password));
        var member = new Member
        {
            OrganizationId = organizationId,
            IdentityUserId = user.Id,
            DisplayName = input.DisplayName,
            IsEmployee = employee,
            IsManager = manager,
            IsAccountAdministrator = administrator
        };
        db.Members.Add(member);
        await db.SaveChangesAsync();
        return member;
    }

    private static void Ensure(IdentityResult result)
    {
        if (!result.Succeeded) throw new InvalidOperationException("Provisioning rejected. Check private input validity and the documented password policy.");
    }
}
