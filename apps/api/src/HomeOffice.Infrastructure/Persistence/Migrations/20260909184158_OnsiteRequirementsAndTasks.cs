using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeOffice.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class OnsiteRequirementsAndTasks : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "RequirementId",
                table: "ChangeProposals",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RequirementRevision",
                table: "ChangeProposals",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "OnsiteRequirements",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    From = table.Column<DateOnly>(type: "date", nullable: false),
                    To = table.Column<DateOnly>(type: "date", nullable: false),
                    Reason = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    Location = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Reference = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    State = table.Column<int>(type: "integer", nullable: false),
                    Revision = table.Column<int>(type: "integer", nullable: false),
                    Version = table.Column<long>(type: "bigint", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OnsiteRequirements", x => x.Id);
                    table.UniqueConstraint("AK_OnsiteRequirements_OrganizationId_EmployeeId_Id", x => new { x.OrganizationId, x.EmployeeId, x.Id });
                    table.CheckConstraint("CK_Onsite", "\"To\" >= \"From\" AND \"Revision\" > 0 AND \"Version\" > 0 AND \"State\" BETWEEN 0 AND 2");
                    table.ForeignKey(
                        name: "FK_OnsiteRequirements_PlanningProfiles_OrganizationId_Employee~",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "AssignedTasks",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    Title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    Deadline = table.Column<DateOnly>(type: "date", nullable: false),
                    State = table.Column<int>(type: "integer", nullable: false),
                    RequiresOnsite = table.Column<bool>(type: "boolean", nullable: false),
                    RequirementId = table.Column<Guid>(type: "uuid", nullable: true),
                    ProgressNote = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    Version = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AssignedTasks", x => x.Id);
                    table.UniqueConstraint("AK_AssignedTasks_OrganizationId_EmployeeId_Id", x => new { x.OrganizationId, x.EmployeeId, x.Id });
                    table.CheckConstraint("CK_Task", "\"Version\" > 0 AND \"State\" BETWEEN 0 AND 3");
                    table.ForeignKey(
                        name: "FK_AssignedTasks_OnsiteRequirements_OrganizationId_EmployeeId_~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.RequirementId },
                        principalTable: "OnsiteRequirements",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AssignedTasks_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "OnsiteAcknowledgement",
                columns: table => new
                {
                    RequirementId = table.Column<Guid>(type: "uuid", nullable: false),
                    Revision = table.Column<int>(type: "integer", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    ReadAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OnsiteAcknowledgement", x => new { x.RequirementId, x.Revision });
                    table.ForeignKey(
                        name: "FK_OnsiteAcknowledgement_OnsiteRequirements_OrganizationId_Emp~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.RequirementId },
                        principalTable: "OnsiteRequirements",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_OnsiteAcknowledgement_PlanningProfiles_OrganizationId_Emplo~",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "WorkEntries",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    RequirementId = table.Column<Guid>(type: "uuid", nullable: true),
                    TaskId = table.Column<Guid>(type: "uuid", nullable: true),
                    AuthorId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    Action = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Text = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    SnapshotJson = table.Column<string>(type: "jsonb", nullable: false),
                    CalendarVersion = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkEntries", x => x.Id);
                    table.CheckConstraint("CK_WorkContext", "(\"RequirementId\" IS NULL) <> (\"TaskId\" IS NULL)");
                    table.ForeignKey(
                        name: "FK_WorkEntries_AssignedTasks_OrganizationId_EmployeeId_TaskId",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.TaskId },
                        principalTable: "AssignedTasks",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_WorkEntries_OnsiteRequirements_OrganizationId_EmployeeId_Re~",
                        columns: x => new { x.OrganizationId, x.EmployeeId, x.RequirementId },
                        principalTable: "OnsiteRequirements",
                        principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_WorkEntries_PlanningProfiles_OrganizationId_EmployeeId",
                        columns: x => new { x.OrganizationId, x.EmployeeId },
                        principalTable: "PlanningProfiles",
                        principalColumns: new[] { "OrganizationId", "EmployeeId" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ChangeProposals_OrganizationId_EmployeeId_RequirementId",
                table: "ChangeProposals",
                columns: new[] { "OrganizationId", "EmployeeId", "RequirementId" });

            migrationBuilder.CreateIndex(
                name: "IX_AssignedTasks_EmployeeId_Deadline_Id",
                table: "AssignedTasks",
                columns: new[] { "EmployeeId", "Deadline", "Id" });

            migrationBuilder.CreateIndex(
                name: "IX_AssignedTasks_OrganizationId_EmployeeId_RequirementId",
                table: "AssignedTasks",
                columns: new[] { "OrganizationId", "EmployeeId", "RequirementId" });

            migrationBuilder.CreateIndex(
                name: "IX_OnsiteAcknowledgement_OrganizationId_EmployeeId_Requirement~",
                table: "OnsiteAcknowledgement",
                columns: new[] { "OrganizationId", "EmployeeId", "RequirementId" });

            migrationBuilder.CreateIndex(
                name: "IX_OnsiteRequirements_EmployeeId_From_To",
                table: "OnsiteRequirements",
                columns: new[] { "EmployeeId", "From", "To" });

            migrationBuilder.CreateIndex(
                name: "IX_WorkEntries_OrganizationId_EmployeeId_RequirementId",
                table: "WorkEntries",
                columns: new[] { "OrganizationId", "EmployeeId", "RequirementId" });

            migrationBuilder.CreateIndex(
                name: "IX_WorkEntries_OrganizationId_EmployeeId_TaskId",
                table: "WorkEntries",
                columns: new[] { "OrganizationId", "EmployeeId", "TaskId" });

            migrationBuilder.CreateIndex(
                name: "IX_WorkEntries_RequirementId_CreatedAt_Id",
                table: "WorkEntries",
                columns: new[] { "RequirementId", "CreatedAt", "Id" });

            migrationBuilder.CreateIndex(
                name: "IX_WorkEntries_TaskId_CreatedAt_Id",
                table: "WorkEntries",
                columns: new[] { "TaskId", "CreatedAt", "Id" });

            migrationBuilder.AddForeignKey(
                name: "FK_ChangeProposals_OnsiteRequirements_OrganizationId_EmployeeI~",
                table: "ChangeProposals",
                columns: new[] { "OrganizationId", "EmployeeId", "RequirementId" },
                principalTable: "OnsiteRequirements",
                principalColumns: new[] { "OrganizationId", "EmployeeId", "Id" },
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChangeProposals_OnsiteRequirements_OrganizationId_EmployeeI~",
                table: "ChangeProposals");

            migrationBuilder.DropTable(
                name: "OnsiteAcknowledgement");

            migrationBuilder.DropTable(
                name: "WorkEntries");

            migrationBuilder.DropTable(
                name: "AssignedTasks");

            migrationBuilder.DropTable(
                name: "OnsiteRequirements");

            migrationBuilder.DropIndex(
                name: "IX_ChangeProposals_OrganizationId_EmployeeId_RequirementId",
                table: "ChangeProposals");

            migrationBuilder.DropColumn(
                name: "RequirementId",
                table: "ChangeProposals");

            migrationBuilder.DropColumn(
                name: "RequirementRevision",
                table: "ChangeProposals");
        }
    }
}
