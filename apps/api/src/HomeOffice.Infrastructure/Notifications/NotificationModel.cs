using HomeOffice.Domain.Access;
using HomeOffice.Domain.Notifications;
using HomeOffice.Domain.Planning;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Notifications;

internal static class NotificationModel
{
    public static void Configure(ModelBuilder b)
    {
        b.Entity<PlanningOutbox>(e =>
        {
            e.Property(x => x.LastError).HasMaxLength(80);
            e.HasIndex(x => new { x.State, x.NextAttemptAt, x.LeaseUntil });
            e.ToTable("PlanningOutbox", t => t.HasCheckConstraint("CK_OutboxProcessing", "\"State\" BETWEEN 0 AND 4 AND \"Attempts\" >= 0 AND (\"State\" <> 1 OR (\"LeaseId\" IS NOT NULL AND \"LeaseUntil\" IS NOT NULL))"));
        });
        b.Entity<InboxNotification>(e =>
        {
            e.HasAlternateKey(x => new { x.OrganizationId, x.RecipientId, x.Id });
            e.HasIndex(x => new { x.EventId, x.RecipientId }).IsUnique();
            e.HasIndex(x => new { x.RecipientId, x.Historical, x.CreatedAt, x.Id });
            e.Property(x => x.EventType).HasMaxLength(80);
            e.HasOne<PlanningOutbox>().WithMany().HasForeignKey(x => x.EventId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.RecipientId }).HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.EmployeeId }).HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
        });
        b.Entity<PushDevice>(e =>
        {
            e.HasKey(x => x.InstallationId);
            e.HasAlternateKey(x => new { x.OrganizationId, x.MemberId, x.InstallationId });
            e.Property(x => x.ProtectedAddress).HasMaxLength(8192);
            e.Property(x => x.AddressHash).HasMaxLength(64);
            e.HasIndex(x => x.AddressHash).IsUnique().HasFilter("\"Active\"");
            e.HasIndex(x => new { x.MemberId, x.Active, x.ExpiresAt });
            e.ToTable("PushDevice", t => t.HasCheckConstraint("CK_PushDevice", "\"Version\" > 0 AND \"Provider\" IN (1,2)"));
            e.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.MemberId }).HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
        });
        b.Entity<PushDelivery>(e =>
        {
            e.HasIndex(x => new { x.NotificationId, x.InstallationId }).IsUnique();
            e.HasIndex(x => new { x.State, x.NextAttemptAt, x.LeaseUntil });
            e.Property(x => x.LastError).HasMaxLength(80);
            e.HasOne<InboxNotification>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.RecipientId, x.NotificationId }).HasPrincipalKey(x => new { x.OrganizationId, x.RecipientId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.HasOne<PushDevice>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.RecipientId, x.InstallationId }).HasPrincipalKey(x => new { x.OrganizationId, x.MemberId, x.InstallationId }).OnDelete(DeleteBehavior.Restrict);
            e.ToTable("PushDelivery", t => t.HasCheckConstraint("CK_PushDelivery", "\"State\" BETWEEN 0 AND 5 AND \"Attempts\" >= 0 AND \"DeviceVersion\" > 0 AND (\"State\" <> 1 OR (\"LeaseId\" IS NOT NULL AND \"LeaseUntil\" IS NOT NULL))"));
            e.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.RecipientId }).HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
        });
    }
}
