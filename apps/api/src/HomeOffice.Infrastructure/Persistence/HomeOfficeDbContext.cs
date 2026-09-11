using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using HomeOffice.Domain.Access;

namespace HomeOffice.Infrastructure.Persistence;

// Schema is applied only by the explicit maintenance command, never during normal startup.
public sealed class HomeOfficeDbContext(DbContextOptions<HomeOfficeDbContext> options)
    : IdentityDbContext<IdentityUser>(options)
{
    public DbSet<Organization> Organizations => Set<Organization>();
    public DbSet<Member> Members => Set<Member>();
    public DbSet<ReportingLine> ReportingLines => Set<ReportingLine>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        Planning.PlanningModel.Configure(builder);
        Planning.OnsiteModel.Configure(builder);
        Notifications.NotificationModel.Configure(builder);
        Access.InvitationModel.Configure(builder);
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
        builder.Entity<AccessAudit>(entity =>
        {
            entity.Property(x => x.Source).HasMaxLength(20);
            entity.Property(x => x.Action).HasMaxLength(80);
            entity.Property(x => x.Reason).HasMaxLength(500);
            entity.Property(x => x.BeforeJson).HasColumnType("jsonb");
            entity.Property(x => x.AfterJson).HasColumnType("jsonb");
            entity.HasIndex(x => new { x.OrganizationId, x.CreatedAt, x.Id });
            entity.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.MemberId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.ActorMemberId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            entity.ToTable("AccessAudits", table => table.HasCheckConstraint("CK_AccessAudit_Source",
                "(\"Source\" IN ('operator', 'anonymous', 'worker') AND \"ActorMemberId\" IS NULL) OR (\"Source\" = 'administrator' AND \"ActorMemberId\" IS NOT NULL)"));
        });
    }
}
