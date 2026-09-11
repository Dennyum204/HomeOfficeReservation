using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeOffice.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AccessAudit : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AccessAudits",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrganizationId = table.Column<Guid>(type: "uuid", nullable: false),
                    MemberId = table.Column<Guid>(type: "uuid", nullable: false),
                    ActorMemberId = table.Column<Guid>(type: "uuid", nullable: true),
                    Source = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Action = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    BeforeJson = table.Column<string>(type: "jsonb", nullable: false),
                    AfterJson = table.Column<string>(type: "jsonb", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccessAudits", x => x.Id);
                    table.CheckConstraint("CK_AccessAudit_Source", "(\"Source\" = 'operator' AND \"ActorMemberId\" IS NULL) OR (\"Source\" = 'administrator' AND \"ActorMemberId\" IS NOT NULL)");
                    table.ForeignKey(
                        name: "FK_AccessAudits_Members_OrganizationId_ActorMemberId",
                        columns: x => new { x.OrganizationId, x.ActorMemberId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AccessAudits_Members_OrganizationId_MemberId",
                        columns: x => new { x.OrganizationId, x.MemberId },
                        principalTable: "Members",
                        principalColumns: new[] { "OrganizationId", "Id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AccessAudits_OrganizationId_ActorMemberId",
                table: "AccessAudits",
                columns: new[] { "OrganizationId", "ActorMemberId" });

            migrationBuilder.CreateIndex(
                name: "IX_AccessAudits_OrganizationId_CreatedAt_Id",
                table: "AccessAudits",
                columns: new[] { "OrganizationId", "CreatedAt", "Id" });

            migrationBuilder.CreateIndex(
                name: "IX_AccessAudits_OrganizationId_MemberId",
                table: "AccessAudits",
                columns: new[] { "OrganizationId", "MemberId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AccessAudits");
        }
    }
}
