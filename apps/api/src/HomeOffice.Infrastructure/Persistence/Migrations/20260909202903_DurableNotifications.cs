using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeOffice.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class DurableNotifications : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Attempts",
                table: "PlanningOutbox",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "Historical",
                table: "PlanningOutbox",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "LastError",
                table: "PlanningOutbox",
                type: "character varying(80)",
                maxLength: 80,
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "LeaseId",
                table: "PlanningOutbox",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "LeaseUntil",
                table: "PlanningOutbox",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "NextAttemptAt",
                table: "PlanningOutbox",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTimeOffset(new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 0, 0, 0, 0)));

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "ProcessedAt",
                table: "PlanningOutbox",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "State",
                table: "PlanningOutbox",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "InboxNotification",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EventId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    RecipientId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    EventType = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Context = table.Column<int>(type: "integer", nullable: false),
                    ContextId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ReadAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    Historical = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_InboxNotification", x => x.Id);
                    table.UniqueConstraint("AK_InboxNotification_OrganizationId_RecipientId_Id", x => new { x.OrganizationId, x.RecipientId, x.Id });
                    table.ForeignKey(
                        name: "FK_InboxNotification_Members_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_InboxNotification_Members_OrganizationId_RecipientId",
                        columns: x => new { x.OrganizationId, x.RecipientId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_InboxNotification_PlanningOutbox_EventId",
                        column: x => x.EventId,
                        principalTable: "PlanningOutbox",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PushDevice",
                columns: table => new
                {
                    InstallationId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    MemberId = table.Column<Guid>(type: "uuid", nullable: false),
                    Provider = table.Column<int>(type: "integer", nullable: false),
                    ProtectedAddress = table.Column<string>(type: "character varying(8192)", maxLength: 8192, nullable: false),
                    AddressHash = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    Version = table.Column<long>(type: "bigint", nullable: false),
                    Active = table.Column<bool>(type: "boolean", nullable: false),
                    RegisteredAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ExpiresAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PushDevice", x => x.InstallationId);
                    table.UniqueConstraint("AK_PushDevice_OrganizationId_MemberId_InstallationId", x => new { x.OrganizationId, x.MemberId, x.InstallationId });
                    table.CheckConstraint("CK_PushDevice", "\"Version\" > 0 AND \"Provider\" IN (1,2)");
                    table.ForeignKey(
                        name: "FK_PushDevice_Members_OrganizationId_MemberId",
                        columns: x => new { x.OrganizationId, x.MemberId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PushDelivery",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    NotificationId = table.Column<Guid>(type: "uuid", nullable: false),
                    InstallationId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    RecipientId = table.Column<Guid>(type: "uuid", nullable: false),
                    DeviceVersion = table.Column<long>(type: "bigint", nullable: false),
                    State = table.Column<int>(type: "integer", nullable: false),
                    Attempts = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    NextAttemptAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    LeaseId = table.Column<Guid>(type: "uuid", nullable: true),
                    LeaseUntil = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    ProviderAcceptedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    DeviceReportedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    LastError = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PushDelivery", x => x.Id);
                    table.CheckConstraint("CK_PushDelivery", "\"State\" BETWEEN 0 AND 5 AND \"Attempts\" >= 0 AND \"DeviceVersion\" > 0 AND (\"State\" <> 1 OR (\"LeaseId\" IS NOT NULL AND \"LeaseUntil\" IS NOT NULL))");
                    table.ForeignKey(
                        name: "FK_PushDelivery_InboxNotification_OrganizationId_RecipientId_N~",
                        columns: x => new { x.OrganizationId, x.RecipientId, x.NotificationId },
                        principalTable: "InboxNotification",
                        principalColumns: new[] { "OrganizationId", "RecipientId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PushDelivery_Members_OrganizationId_RecipientId",
                        columns: x => new { x.OrganizationId, x.RecipientId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PushDelivery_PushDevice_OrganizationId_RecipientId_Installa~",
                        columns: x => new { x.OrganizationId, x.RecipientId, x.InstallationId },
                        principalTable: "PushDevice",
                        principalColumns: new[] { "OrganizationId", "MemberId", "InstallationId" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PlanningOutbox_State_NextAttemptAt_LeaseUntil",
                table: "PlanningOutbox",
                columns: new[] { "State", "NextAttemptAt", "LeaseUntil" });

            migrationBuilder.AddCheckConstraint(
                name: "CK_OutboxProcessing",
                table: "PlanningOutbox",
                sql: "\"State\" BETWEEN 0 AND 4 AND \"Attempts\" >= 0 AND (\"State\" <> 1 OR (\"LeaseId\" IS NOT NULL AND \"LeaseUntil\" IS NOT NULL))");

            migrationBuilder.CreateIndex(
                name: "IX_InboxNotification_EventId_RecipientId",
                table: "InboxNotification",
                columns: new[] { "EventId", "RecipientId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_InboxNotification_OrganizationId_EmployeeId",
                table: "InboxNotification",
                columns: new[] { "OrganizationId", "EmployeeId" });

            migrationBuilder.CreateIndex(
                name: "IX_InboxNotification_RecipientId_Historical_CreatedAt_Id",
                table: "InboxNotification",
                columns: new[] { "RecipientId", "Historical", "CreatedAt", "Id" });

            migrationBuilder.CreateIndex(
                name: "IX_PushDelivery_NotificationId_InstallationId",
                table: "PushDelivery",
                columns: new[] { "NotificationId", "InstallationId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PushDelivery_OrganizationId_RecipientId_InstallationId",
                table: "PushDelivery",
                columns: new[] { "OrganizationId", "RecipientId", "InstallationId" });

            migrationBuilder.CreateIndex(
                name: "IX_PushDelivery_OrganizationId_RecipientId_NotificationId",
                table: "PushDelivery",
                columns: new[] { "OrganizationId", "RecipientId", "NotificationId" });

            migrationBuilder.CreateIndex(
                name: "IX_PushDelivery_State_NextAttemptAt_LeaseUntil",
                table: "PushDelivery",
                columns: new[] { "State", "NextAttemptAt", "LeaseUntil" });

            migrationBuilder.CreateIndex(
                name: "IX_PushDevice_AddressHash",
                table: "PushDevice",
                column: "AddressHash",
                unique: true,
                filter: "\"Active\"");

            migrationBuilder.CreateIndex(
                name: "IX_PushDevice_MemberId_Active_ExpiresAt",
                table: "PushDevice",
                columns: new[] { "MemberId", "Active", "ExpiresAt" });
            // Existing rows are archived; never push the pre-HO007 backlog after migration.
            migrationBuilder.Sql("""
                UPDATE "PlanningOutbox" SET "Historical" = TRUE, "NextAttemptAt" = "CreatedAt",
                  "ProcessedAt" = "DeliveredAt", "State" = CASE WHEN "DeliveredAt" IS NULL THEN 0 ELSE 2 END;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PushDelivery");

            migrationBuilder.DropTable(
                name: "InboxNotification");

            migrationBuilder.DropTable(
                name: "PushDevice");

            migrationBuilder.DropIndex(
                name: "IX_PlanningOutbox_State_NextAttemptAt_LeaseUntil",
                table: "PlanningOutbox");

            migrationBuilder.DropCheckConstraint(
                name: "CK_OutboxProcessing",
                table: "PlanningOutbox");

            migrationBuilder.DropColumn(
                name: "Attempts",
                table: "PlanningOutbox");

            migrationBuilder.DropColumn(
                name: "Historical",
                table: "PlanningOutbox");

            migrationBuilder.DropColumn(
                name: "LastError",
                table: "PlanningOutbox");

            migrationBuilder.DropColumn(
                name: "LeaseId",
                table: "PlanningOutbox");

            migrationBuilder.DropColumn(
                name: "LeaseUntil",
                table: "PlanningOutbox");

            migrationBuilder.DropColumn(
                name: "NextAttemptAt",
                table: "PlanningOutbox");

            migrationBuilder.DropColumn(
                name: "ProcessedAt",
                table: "PlanningOutbox");

            migrationBuilder.DropColumn(
                name: "State",
                table: "PlanningOutbox");
        }
    }
}
