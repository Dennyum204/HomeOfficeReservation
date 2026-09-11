using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeOffice.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AccessInvitations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_AccessAudit_Source",
                table: "AccessAudits");

            migrationBuilder.CreateTable(
                name: "AccessInvitations",
                columns: table => new
                {
                    MemberId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    CreationFingerprint = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    State = table.Column<int>(type: "integer", nullable: false),
                    Version = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    AcceptedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    CancelledAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    ProtectedCode = table.Column<string>(type: "character varying(16384)", maxLength: 16384, nullable: true),
                    CodeExpiresAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    LastRequestedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    WindowStartedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    RequestsInWindow = table.Column<int>(type: "integer", nullable: false),
                    DeliveryState = table.Column<int>(type: "integer", nullable: false),
                    Attempts = table.Column<int>(type: "integer", nullable: false),
                    NextAttemptAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    DeliveredAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    LastError = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    LeaseId = table.Column<Guid>(type: "uuid", nullable: true),
                    LeaseUntil = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccessInvitations", x => x.MemberId);
                    table.ForeignKey(
                        name: "FK_AccessInvitations_Members_OrganizationId_CreatedBy",
                        columns: x => new { x.OrganizationId, x.CreatedBy },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AccessInvitations_Members_OrganizationId_MemberId",
                        columns: x => new { x.OrganizationId, x.MemberId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "InvitationCommands",
                columns: table => new
                {
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    ActorId = table.Column<Guid>(type: "uuid", nullable: false),
                    CommandId = table.Column<Guid>(type: "uuid", nullable: false),
                    MemberId = table.Column<Guid>(type: "uuid", nullable: false),
                    Operation = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    ExpectedVersion = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_InvitationCommands", x => new { x.OrganizationId, x.ActorId, x.CommandId });
                    table.ForeignKey(
                        name: "FK_InvitationCommands_Members_OrganizationId_ActorId",
                        columns: x => new { x.OrganizationId, x.ActorId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_InvitationCommands_Members_OrganizationId_MemberId",
                        columns: x => new { x.OrganizationId, x.MemberId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.AddCheckConstraint(
                name: "CK_AccessAudit_Source",
                table: "AccessAudits",
                sql: "(\"Source\" IN ('operator', 'anonymous', 'worker') AND \"ActorMemberId\" IS NULL) OR (\"Source\" = 'administrator' AND \"ActorMemberId\" IS NOT NULL)");

            migrationBuilder.CreateIndex(
                name: "IX_AccessInvitations_DeliveryState_NextAttemptAt",
                table: "AccessInvitations",
                columns: new[] { "DeliveryState", "NextAttemptAt" });

            migrationBuilder.CreateIndex(
                name: "IX_AccessInvitations_OrganizationId_CreatedBy",
                table: "AccessInvitations",
                columns: new[] { "OrganizationId", "CreatedBy" });

            migrationBuilder.CreateIndex(
                name: "IX_AccessInvitations_OrganizationId_MemberId",
                table: "AccessInvitations",
                columns: new[] { "OrganizationId", "MemberId" });

            migrationBuilder.CreateIndex(
                name: "IX_InvitationCommands_OrganizationId_MemberId",
                table: "InvitationCommands",
                columns: new[] { "OrganizationId", "MemberId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AccessInvitations");

            migrationBuilder.DropTable(
                name: "InvitationCommands");

            migrationBuilder.DropCheckConstraint(
                name: "CK_AccessAudit_Source",
                table: "AccessAudits");

            migrationBuilder.AddCheckConstraint(
                name: "CK_AccessAudit_Source",
                table: "AccessAudits",
                sql: "(\"Source\" = 'operator' AND \"ActorMemberId\" IS NULL) OR (\"Source\" = 'administrator' AND \"ActorMemberId\" IS NOT NULL)");
        }
    }
}
