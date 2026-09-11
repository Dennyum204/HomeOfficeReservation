using System.Text.Json;
using System.Text.Json.Serialization;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace HomeOffice.Api.Access;

public sealed record ProvisionedAccount(string Email, string Password, string DisplayName);
public sealed record DevelopmentAccounts(string OrganizationName, ProvisionedAccount Admin, ProvisionedAccount Manager, ProvisionedAccount Employee);

public static class MaintenanceCommands
{
    public static Task<bool> ExecuteAsync(string[] args, WebApplication app) => ExecuteAsync(args, app.Services, app.Environment);

    public static async Task<bool> ExecuteAsync(string[] args, IServiceProvider services, IHostEnvironment environment)
    {
        var commands = args.Where(a => a is "--migrate" or "--provision-dev" or "--bootstrap-admin" or "--bootstrap-owner" or "--enable-admin-employee").ToArray();
        if (commands.Length == 0) return false;
        if (commands.Length != 1) throw new InvalidOperationException("Run exactly one maintenance command at a time.");
        await using var scope = services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<HomeOfficeDbContext>();
        if (args.Contains("--migrate"))
        {
            await db.Database.MigrateAsync();
            Console.WriteLine("Explicit migrations applied. No accounts provisioned.");
            return true;
        }
        services.GetService<IStartupValidator>()?.Validate();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<IdentityUser>>();
        var dev = args.Contains("--provision-dev");
        if (dev && !environment.IsDevelopment()) throw new InvalidOperationException("Synthetic provisioning is Development-only.");
        var flag = commands[0];
        var index = Array.IndexOf(args, flag);
        if (index + 1 >= args.Length) throw new InvalidOperationException("Supply the private provisioning JSON file path.");
        var json = await File.ReadAllTextAsync(args[index + 1]);
        var jsonOptions = new JsonSerializerOptions(JsonSerializerDefaults.Web);
        if (dev)
        {
            await using var transaction = await db.Database.BeginTransactionAsync();
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
            var provisioner = scope.ServiceProvider.GetRequiredService<OwnerProvisioner>();
            // New commands reject misspelled/unrecognized fields. The legacy input shape is unchanged.
            if (flag != "--bootstrap-admin") jsonOptions.UnmappedMemberHandling = JsonUnmappedMemberHandling.Disallow;
            OperatorReceipt receipt;
            if (flag == "--enable-admin-employee")
                receipt = await provisioner.EnableEmployeeAsync(JsonSerializer.Deserialize<EnableAdminEmployee>(json, jsonOptions)
                    ?? throw new InvalidOperationException("Invalid operator file."));
            else
                receipt = await provisioner.BootstrapAsync(JsonSerializer.Deserialize<BootstrapAccount>(json, jsonOptions)
                    ?? throw new InvalidOperationException("Invalid bootstrap file."), owner: flag == "--bootstrap-owner");
            // IDs and outcome only: never print the private input, delivery address, code or password.
            Console.WriteLine($"{receipt.Code}: organizationId={receipt.OrganizationId}; memberId={receipt.MemberId}; auditId={receipt.AuditId}");
            if (receipt.Code == "provisioned") Console.WriteLine("Account has no password. Complete Identity activation using the configured delivery channel.");
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
