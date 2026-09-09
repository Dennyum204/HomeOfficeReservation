using HomeOffice.Domain.Access;
using HomeOffice.Domain.Planning;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Planning;

internal static class PlanningModel
{
    public static void Configure(ModelBuilder b)
    {
        b.Entity<Organization>().Property(x => x.PlanningTimeZone).HasMaxLength(64);
        b.Entity<PlanningProfile>(e =>
        {
            e.HasKey(x => x.EmployeeId);
            e.HasAlternateKey(x => new { x.OrganizationId, x.EmployeeId });
            e.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.ToTable("PlanningProfiles", t => t.HasCheckConstraint("CK_ProfileVersion", "\"CalendarVersion\" >= 0"));
        });
        b.Entity<WeeklyPattern>(e =>
        {
            e.HasIndex(x => new { x.EmployeeId, x.EffectiveFrom }).IsUnique();
            e.Property(x => x.Locations).HasColumnType("integer[]");
            e.ToTable("WeeklyPatterns", t => t.HasCheckConstraint("CK_Pattern", "cardinality(\"Locations\") = 7 AND \"Locations\" <@ ARRAY[0,1,2] AND \"Version\" > 0"));
        });
        b.Entity<PlanningRequest>(e =>
        {
            e.HasAlternateKey(x => new { x.OrganizationId, x.EmployeeId, x.Id });
            e.HasIndex(x => new { x.RootId, x.Revision }).IsUnique();
            e.HasIndex(x => new { x.EmployeeId, x.CreatedAt, x.Id });
            e.Property(x => x.Note).HasMaxLength(2000);
            e.HasOne<PlanningRequest>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.ParentRevisionId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.HasMany(x => x.Days).WithOne().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.RequestId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.ToTable("PlanningRequests", t => t.HasCheckConstraint("CK_Request", "\"Version\" > 0 AND \"Revision\" > 0 AND \"State\" BETWEEN 0 AND 3"));
        });
        b.Entity<RequestedDay>(e =>
        {
            e.HasAlternateKey(x => new { x.OrganizationId, x.EmployeeId, x.Id });
            e.HasIndex(x => new { x.RequestId, x.LocalDate }).IsUnique();
            e.HasIndex(x => new { x.EmployeeId, x.LocalDate }).IsUnique().HasFilter("\"ReservesDate\"");
            e.Property(x => x.Reason).HasMaxLength(1000);
            e.HasOne<RequestedDay>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.BaseDayId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.ToTable("RequestedDays", t =>
            {
                t.HasCheckConstraint("CK_Day", "\"Version\" > 0 AND \"Location\" BETWEEN 0 AND 2 AND \"Availability\" BETWEEN 0 AND 2 AND \"Decision\" BETWEEN 0 AND 5 AND (NOT \"ReservesDate\" OR \"Decision\" = 0)");
                t.HasCheckConstraint("CK_DayBase", "(\"BaseDayId\" IS NULL) = (\"BasePlanVersion\" IS NULL) AND (NOT \"Cancel\" OR \"BaseDayId\" IS NOT NULL)");
            });
        });
        b.Entity<PlanDay>(e =>
        {
            e.HasKey(x => new { x.EmployeeId, x.LocalDate });
            e.HasOne<RequestedDay>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.SourceDayId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.ToTable("PlanDays", t => t.HasCheckConstraint("CK_PlanDay", "\"Version\" > 0 AND ((\"Availability\" = 0 AND \"Location\" IN (1,2)) OR (\"Availability\" IN (1,2) AND \"Location\" = 0))"));
        });
        b.Entity<ChangeProposal>(e =>
        {
            e.HasAlternateKey(x => new { x.OrganizationId, x.EmployeeId, x.Id });
            e.HasIndex(x => new { x.GroupId, x.Revision }).IsUnique();
            e.Property(x => x.Reason).HasMaxLength(1000);
            e.Property(x => x.DaysJson).HasColumnType("jsonb");
            e.HasOne<PlanningRequest>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.RequestId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.ToTable("ChangeProposals", t => t.HasCheckConstraint("CK_Proposal", "\"Revision\" > 0 AND \"State\" BETWEEN 0 AND 2"));
        });
        b.Entity<ProposalAcknowledgement>(e =>
        {
            e.HasKey(x => x.ProposalId);
            e.HasOne<ChangeProposal>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.ProposalId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
        });
        b.Entity<PlanningComment>(e =>
        {
            e.Property(x => x.Text).HasMaxLength(2000);
            e.HasIndex(x => new { x.RequestId, x.CreatedAt, x.Id });
            e.HasOne<PlanningRequest>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.RequestId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.HasOne<ChangeProposal>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId, x.ProposalId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.EmployeeId, x.Id }).OnDelete(DeleteBehavior.Restrict);
        });
        b.Entity<PlanningAudit>(e =>
        {
            e.Property(x => x.Action).HasMaxLength(80);
            e.Property(x => x.ChangedDaysJson).HasColumnType("jsonb");
            e.HasIndex(x => new { x.EmployeeId, x.CalendarVersion }).IsUnique();
        });
        b.Entity<PlanningOutbox>(e =>
        {
            e.Property(x => x.Type).HasMaxLength(80);
            e.Property(x => x.Payload).HasColumnType("jsonb");
            e.HasIndex(x => new { x.EmployeeId, x.CalendarVersion }).IsUnique();
        });
        b.Entity<PlanningReceipt>(e =>
        {
            e.HasKey(x => new { x.ActorId, x.Operation, x.Key });
            e.Property(x => x.Operation).HasMaxLength(80);
            e.Property(x => x.Key).HasMaxLength(128);
            e.Property(x => x.PayloadHash).HasMaxLength(64);
            e.Property(x => x.ResponseJson).HasColumnType("jsonb");
            e.HasOne<Member>().WithMany().HasForeignKey(x => x.ActorId).OnDelete(DeleteBehavior.Restrict);
        });
        foreach (var type in new[] { typeof(WeeklyPattern), typeof(PlanningRequest), typeof(RequestedDay), typeof(PlanDay),
            typeof(ChangeProposal), typeof(ProposalAcknowledgement), typeof(PlanningComment), typeof(PlanningAudit), typeof(PlanningOutbox) })
        {
            b.Entity(type).HasOne(typeof(PlanningProfile)).WithMany().HasForeignKey("OrganizationId", "EmployeeId")
                .HasPrincipalKey("OrganizationId", "EmployeeId").OnDelete(DeleteBehavior.Restrict);
        }
    }
}
