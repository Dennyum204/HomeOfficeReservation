using HomeOffice.Domain.Access;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Access;

internal static class InvitationModel
{
    internal static void Configure(ModelBuilder builder)
    {
        builder.Entity<AccessInvitation>(e =>
        {
            e.ToTable("AccessInvitations");
            e.HasKey(x => x.MemberId);
            e.Property(x => x.CreationFingerprint).HasMaxLength(64);
            e.Property(x => x.ProtectedCode).HasMaxLength(16384);
            e.Property(x => x.LastError).HasMaxLength(80);
            e.HasIndex(x => new { x.DeliveryState, x.NextAttemptAt });
            e.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.MemberId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.CreatedBy })
                .HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
        });
        builder.Entity<InvitationCommand>(e =>
        {
            e.ToTable("InvitationCommands");
            e.HasKey(x => new { x.OrganizationId, x.ActorId, x.CommandId });
            e.Property(x => x.Operation).HasMaxLength(20);
            e.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.MemberId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
            e.HasOne<Member>().WithMany().HasForeignKey(x => new { x.OrganizationId, x.ActorId })
                .HasPrincipalKey(x => new { x.OrganizationId, x.Id }).OnDelete(DeleteBehavior.Restrict);
        });
    }
}
