using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using HomeOffice.Domain.Access;

namespace HomeOffice.Infrastructure.Persistence;

// Identity's store model is ready for HO-003. No users, login endpoints or schema are provisioned here.
public sealed class HomeOfficeDbContext(DbContextOptions<HomeOfficeDbContext> options)
    : IdentityDbContext<IdentityUser>(options)
{
    public DbSet<Organization> Organizations => Set<Organization>();
    public DbSet<Member> Members => Set<Member>();
    public DbSet<ReportingLine> ReportingLines => Set<ReportingLine>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        builder.Entity<Organization>().Property(x => x.Name).HasMaxLength(120);
        builder.Entity<Organization>().HasIndex(x => x.Name).IsUnique();
        builder.Entity<Member>(entity =>
        {
            entity.HasAlternateKey(x => new { x.OrganizationId, x.Id });
            entity.HasIndex(x => x.IdentityUserId).IsUnique();
            entity.Property(x => x.DisplayName).HasMaxLength(120);
            entity.HasOne<Organization>().WithMany().HasForeignKey(x => x.OrganizationId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<IdentityUser>().WithMany().HasForeignKey(x => x.IdentityUserId).OnDelete(DeleteBehavior.Restrict);
        });
        builder.Entity<ReportingLine>(entity =>
        {
            entity.HasKey(x => x.EmployeeId);
            entity.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.ManagerId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            entity.ToTable("ReportingLines", table => table.HasCheckConstraint("CK_ReportingLine_NoSelf", "\"EmployeeId\" <> \"ManagerId\""));
        });
    }
}
