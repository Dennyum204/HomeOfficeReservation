using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeOffice.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class TransactionalPlanning : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PlanningTimeZone",
                table: "Organizations",
                type: "character varying(64)",
                maxLength: 64,
                nullable: false,
                defaultValue: "Europe/Zurich");

            migrationBuilder.CreateTable(
                name: "PlanningProfiles",
                columns: table => new
                {
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    CalendarVersion = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlanningProfiles", x => x.EmployeeId);
                    table.UniqueConstraint("AK_PlanningProfiles_OrganizationId_EmployeeId", x => new { x.OrganizationId, x.EmployeeId });
                    table.CheckConstraint("CK_ProfileVersion", "\"CalendarVersion\" >= 0");
                    table.ForeignKey(
                        name: "FK_PlanningProfiles_Members_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PlanningReceipt",
                columns: table => new
                {
                    ActorId = table.Column<Guid>(type: "uuid", nullable: false),
                    Operation = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Key = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    PayloadHash = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    ResponseJson = table.Column<string>(type: "jsonb", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlanningReceipt", x => new { x.ActorId, x.Operation, x.Key });
                    table.ForeignKey(
                        name: "FK_PlanningReceipt_Members_ActorId",
                        column: x => x.ActorId,
                        principalTable: "Members",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PlanningAudit",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    ActorId = table.Column<Guid>(type: "uuid", nullable: false),
                    ContextId = table.Column<Guid>(type: "uuid", nullable: false),
                    Action = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    CalendarVersion = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ChangedDaysJson = table.Column<string>(type: "jsonb", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlanningAudit", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PlanningAudit_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PlanningOutbox",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    Type = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Payload = table.Column<string>(type: "jsonb", nullable: false),
                    CalendarVersion = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    DeliveredAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlanningOutbox", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PlanningOutbox_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PlanningRequests",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    RootId = table.Column<Guid>(type: "uuid", nullable: false),
                    ParentRevisionId = table.Column<Guid>(type: "uuid", nullable: true),
                    Revision = table.Column<int>(type: "integer", nullable: false),
                    Version = table.Column<long>(type: "bigint", nullable: false),
                    State = table.Column<int>(type: "integer", nullable: false),
                    Note = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    SubmittedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    AcceptedProposalId = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlanningRequests", x => x.Id);
                    table.UniqueConstraint("AK_PlanningRequests_OrganizationId_EmployeeId_Id", x => new { x.OrganizationId, x.EmployeeId, x.Id });
                    table.CheckConstraint("CK_Request", "\"Version\" > 0 AND \"Revision\" > 0 AND \"State\" BETWEEN 0 AND 3");
                    table.ForeignKey(
                        name: "FK_PlanningRequests_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PlanningRequests_PlanningRequests_OrganizationId_EmployeeId~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.ParentRevisionId },
                        principalTable: "PlanningRequests",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "WeeklyPatterns",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    EffectiveFrom = table.Column<DateOnly>(type: "date", nullable: false),
                    Locations = table.Column<int[]>(type: "integer[]", nullable: false),
                    Version = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WeeklyPatterns", x => x.Id);
                    table.CheckConstraint("CK_Pattern", "cardinality(\"Locations\") = 7 AND \"Locations\" <@ ARRAY[0,1,2] AND \"Version\" > 0");
                    table.ForeignKey(
                        name: "FK_WeeklyPatterns_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ChangeProposals",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    GroupId = table.Column<Guid>(type: "uuid", nullable: false),
                    Revision = table.Column<int>(type: "integer", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    RequestId = table.Column<Guid>(type: "uuid", nullable: false),
                    AuthorId = table.Column<Guid>(type: "uuid", nullable: false),
                    Reason = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    AffectedDayIds = table.Column<Guid[]>(type: "uuid[]", nullable: false),
                    AffectedDayVersions = table.Column<long[]>(type: "bigint[]", nullable: false),
                    DaysJson = table.Column<string>(type: "jsonb", nullable: false),
                    State = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    AcceptedRequestId = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChangeProposals", x => x.Id);
                    table.UniqueConstraint("AK_ChangeProposals_OrganizationId_EmployeeId_Id", x => new { x.OrganizationId, x.EmployeeId, x.Id });
                    table.CheckConstraint("CK_Proposal", "\"Revision\" > 0 AND \"State\" BETWEEN 0 AND 2");
                    table.ForeignKey(
                        name: "FK_ChangeProposals_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ChangeProposals_PlanningRequests_OrganizationId_EmployeeId_~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.RequestId },
                        principalTable: "PlanningRequests",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "RequestedDays",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    RequestId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    LocalDate = table.Column<DateOnly>(type: "date", nullable: false),
                    Location = table.Column<int>(type: "integer", nullable: false),
                    Availability = table.Column<int>(type: "integer", nullable: false),
                    Cancel = table.Column<bool>(type: "boolean", nullable: false),
                    BaseDayId = table.Column<Guid>(type: "uuid", nullable: true),
                    BasePlanVersion = table.Column<long>(type: "bigint", nullable: true),
                    Decision = table.Column<int>(type: "integer", nullable: false),
                    ReservesDate = table.Column<bool>(type: "boolean", nullable: false),
                    Reason = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    DecidedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DecidedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    Version = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RequestedDays", x => x.Id);
                    table.UniqueConstraint("AK_RequestedDays_OrganizationId_EmployeeId_Id", x => new { x.OrganizationId, x.EmployeeId, x.Id });
                    table.CheckConstraint("CK_Day", "\"Version\" > 0 AND \"Location\" BETWEEN 0 AND 2 AND \"Availability\" BETWEEN 0 AND 2 AND \"Decision\" BETWEEN 0 AND 5 AND (NOT \"ReservesDate\" OR \"Decision\" = 0)");
                    table.CheckConstraint("CK_DayBase", "(\"BaseDayId\" IS NULL) = (\"BasePlanVersion\" IS NULL) AND (NOT \"Cancel\" OR \"BaseDayId\" IS NOT NULL)");
                    table.ForeignKey(
                        name: "FK_RequestedDays_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RequestedDays_PlanningRequests_OrganizationId_EmployeeId_Re~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.RequestId },
                        principalTable: "PlanningRequests",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RequestedDays_RequestedDays_OrganizationId_EmployeeId_BaseD~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.BaseDayId },
                        principalTable: "RequestedDays",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PlanningComment",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    RequestId = table.Column<Guid>(type: "uuid", nullable: false),
                    ProposalId = table.Column<Guid>(type: "uuid", nullable: true),
                    AuthorId = table.Column<Guid>(type: "uuid", nullable: false),
                    Text = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlanningComment", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PlanningComment_ChangeProposals_OrganizationId_EmployeeId_P~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.ProposalId },
                        principalTable: "ChangeProposals",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PlanningComment_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PlanningComment_PlanningRequests_OrganizationId_EmployeeId_~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.RequestId },
                        principalTable: "PlanningRequests",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ProposalAcknowledgement",
                columns: table => new
                {
                    ProposalId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    Revision = table.Column<int>(type: "integer", nullable: false),
                    AcknowledgedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProposalAcknowledgement", x => x.ProposalId);
                    table.ForeignKey(
                        name: "FK_ProposalAcknowledgement_ChangeProposals_OrganizationId_Empl~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.ProposalId },
                        principalTable: "ChangeProposals",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ProposalAcknowledgement_PlanningProfiles_OrganizationId_Emp~",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PlanDays",
                columns: table => new
                {
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    LocalDate = table.Column<DateOnly>(type: "date", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    Location = table.Column<int>(type: "integer", nullable: false),
                    Availability = table.Column<int>(type: "integer", nullable: false),
                    SourceDayId = table.Column<Guid>(type: "uuid", nullable: false),
                    DecidedBy = table.Column<Guid>(type: "uuid", nullable: false),
                    Version = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlanDays", x => new { x.EmployeeId, x.LocalDate });
                    table.CheckConstraint("CK_PlanDay", "\"Version\" > 0 AND ((\"Availability\" = 0 AND \"Location\" IN (1,2)) OR (\"Availability\" IN (1,2) AND \"Location\" = 0))");
                    table.ForeignKey(
                        name: "FK_PlanDays_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PlanDays_RequestedDays_OrganizationId_EmployeeId_SourceDayId",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.SourceDayId },
                        principalTable: "RequestedDays",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ChangeProposals_GroupId_Revision",
                table: "ChangeProposals",
                columns: new[] { "GroupId", "Revision" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ChangeProposals_OrganizationId_EmployeeId_RequestId",
                table: "ChangeProposals",
                columns: new[] { "OrganizationId", "EmployeeId", "RequestId" });

            migrationBuilder.CreateIndex(
                name: "IX_PlanDays_OrganizationId_EmployeeId_SourceDayId",
                table: "PlanDays",
                columns: new[] { "OrganizationId", "EmployeeId", "SourceDayId" });

            migrationBuilder.CreateIndex(
                name: "IX_PlanningAudit_EmployeeId_CalendarVersion",
                table: "PlanningAudit",
                columns: new[] { "EmployeeId", "CalendarVersion" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PlanningAudit_OrganizationId_EmployeeId",
                table: "PlanningAudit",
                columns: new[] { "OrganizationId", "EmployeeId" });

            migrationBuilder.CreateIndex(
                name: "IX_PlanningComment_OrganizationId_EmployeeId_ProposalId",
                table: "PlanningComment",
                columns: new[] { "OrganizationId", "EmployeeId", "ProposalId" });

            migrationBuilder.CreateIndex(
                name: "IX_PlanningComment_OrganizationId_EmployeeId_RequestId",
                table: "PlanningComment",
                columns: new[] { "OrganizationId", "EmployeeId", "RequestId" });

            migrationBuilder.CreateIndex(
                name: "IX_PlanningComment_RequestId_CreatedAt_Id",
                table: "PlanningComment",
                columns: new[] { "RequestId", "CreatedAt", "Id" });

            migrationBuilder.CreateIndex(
                name: "IX_PlanningOutbox_EmployeeId_CalendarVersion",
                table: "PlanningOutbox",
                columns: new[] { "EmployeeId", "CalendarVersion" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PlanningOutbox_OrganizationId_EmployeeId",
                table: "PlanningOutbox",
                columns: new[] { "OrganizationId", "EmployeeId" });

            migrationBuilder.CreateIndex(
                name: "IX_PlanningRequests_EmployeeId_CreatedAt_Id",
                table: "PlanningRequests",
                columns: new[] { "EmployeeId", "CreatedAt", "Id" });

            migrationBuilder.CreateIndex(
                name: "IX_PlanningRequests_OrganizationId_EmployeeId_ParentRevisionId",
                table: "PlanningRequests",
                columns: new[] { "OrganizationId", "EmployeeId", "ParentRevisionId" });

            migrationBuilder.CreateIndex(
                name: "IX_PlanningRequests_RootId_Revision",
                table: "PlanningRequests",
                columns: new[] { "RootId", "Revision" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProposalAcknowledgement_OrganizationId_EmployeeId_ProposalId",
                table: "ProposalAcknowledgement",
                columns: new[] { "OrganizationId", "EmployeeId", "ProposalId" });

            migrationBuilder.CreateIndex(
                name: "IX_RequestedDays_EmployeeId_LocalDate",
                table: "RequestedDays",
                columns: new[] { "EmployeeId", "LocalDate" },
                unique: true,
                filter: "\"ReservesDate\"");

            migrationBuilder.CreateIndex(
                name: "IX_RequestedDays_OrganizationId_EmployeeId_BaseDayId",
                table: "RequestedDays",
                columns: new[] { "OrganizationId", "EmployeeId", "BaseDayId" });

            migrationBuilder.CreateIndex(
                name: "IX_RequestedDays_OrganizationId_EmployeeId_RequestId",
                table: "RequestedDays",
                columns: new[] { "OrganizationId", "EmployeeId", "RequestId" });

            migrationBuilder.CreateIndex(
                name: "IX_RequestedDays_RequestId_LocalDate",
                table: "RequestedDays",
                columns: new[] { "RequestId", "LocalDate" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_WeeklyPatterns_EmployeeId_EffectiveFrom",
                table: "WeeklyPatterns",
                columns: new[] { "EmployeeId", "EffectiveFrom" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_WeeklyPatterns_OrganizationId_EmployeeId",
                table: "WeeklyPatterns",
                columns: new[] { "OrganizationId", "EmployeeId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PlanDays");

            migrationBuilder.DropTable(
                name: "PlanningAudit");

            migrationBuilder.DropTable(
                name: "PlanningComment");

            migrationBuilder.DropTable(
                name: "PlanningOutbox");

            migrationBuilder.DropTable(
                name: "PlanningReceipt");

            migrationBuilder.DropTable(
                name: "ProposalAcknowledgement");

            migrationBuilder.DropTable(
                name: "WeeklyPatterns");

            migrationBuilder.DropTable(
                name: "RequestedDays");

            migrationBuilder.DropTable(
                name: "ChangeProposals");

            migrationBuilder.DropTable(
                name: "PlanningRequests");

            migrationBuilder.DropTable(
                name: "PlanningProfiles");

            migrationBuilder.DropColumn(
                name: "PlanningTimeZone",
                table: "Organizations");
        }
    }
}
