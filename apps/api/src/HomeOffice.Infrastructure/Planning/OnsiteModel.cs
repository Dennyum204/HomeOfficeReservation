using HomeOffice.Domain.Planning;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Planning;

internal static class OnsiteModel
{
    public static void Configure(ModelBuilder b)
    {
        b.Entity<OnsiteRequirement>(e =>
        {
            e.HasAlternateKey(x => new { x.OrganizationId, x.EmployeeId, x.Id });
            e.HasIndex(x => new { x.EmployeeId, x.From, x.To });
            e.Property(x => x.Reason).HasMaxLength(1000);
            e.Property(x => x.Location).HasMaxLength(200);
            e.Property(x => x.Reference).HasMaxLength(200);
            e.ToTable("OnsiteRequirements", t => t.HasCheckConstraint("CK_Onsite", "\"To\" >= \"From\" AND \"Revision\" > 0 AND \"Version\" > 0 AND \"State\" BETWEEN 0 AND 2"));
        });
        b.Entity<OnsiteAcknowledgement>(e =>
        {
            e.HasKey(x => new { x.RequirementId, x.Revision });
            e.HasOne<OnsiteRequirement>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.RequirementId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
        });
        b.Entity<AssignedTask>(e =>
        {
            e.HasAlternateKey(x => new { x.OrganizationId, x.EmployeeId, x.Id });
            e.HasIndex(x => new { x.EmployeeId, x.Deadline, x.Id });
            e.Property(x => x.Title).HasMaxLength(200);
            e.Property(x => x.Description).HasMaxLength(2000);
            e.Property(x => x.ProgressNote).HasMaxLength(1000);
            e.HasOne<OnsiteRequirement>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.RequirementId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.ToTable("AssignedTasks", t => t.HasCheckConstraint("CK_Task", "\"Version\" > 0 AND \"State\" BETWEEN 0 AND 3"));
        });
        b.Entity<WorkEntry>(e =>
        {
            e.Property(x => x.Action).HasMaxLength(80);
            e.Property(x => x.Text).HasMaxLength(2000);
            e.Property(x => x.SnapshotJson).HasColumnType("jsonb");
            e.HasIndex(x => new { x.RequirementId, x.CreatedAt, x.Id });
            e.HasIndex(x => new { x.TaskId, x.CreatedAt, x.Id });
            e.HasOne<OnsiteRequirement>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.RequirementId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.HasOne<AssignedTask>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.TaskId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.ToTable("WorkEntries", t => t.HasCheckConstraint("CK_WorkContext", "(\"RequirementId\" IS NULL) <> (\"TaskId\" IS NULL)"));
        });
        b.Entity<ChangeProposal>().HasOne<OnsiteRequirement>().WithMany()
            .HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.RequirementId })
            .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
        foreach (var type in new[] { typeof(OnsiteRequirement), typeof(OnsiteAcknowledgement), typeof(AssignedTask), typeof(WorkEntry) })
            b.Entity(type).HasOne(typeof(PlanningProfile)).WithMany().HasForeignKey("OrganizationId", "EmployeeId")
                .HasPrincipalKey("OrganizationId", "EmployeeId").OnDelete(DeleteBehavior.Restrict);
    }
}
