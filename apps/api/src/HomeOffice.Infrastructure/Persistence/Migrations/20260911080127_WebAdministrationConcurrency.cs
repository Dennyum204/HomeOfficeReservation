using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeOffice.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class WebAdministrationConcurrency : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "AccessVersion",
                table: "Members",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AlterColumn<string>(
                name: "Operation",
                table: "InvitationCommands",
                type: "character varying(80)",
                maxLength: 80,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(20)",
                oldMaxLength: 20);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AccessVersion",
                table: "Members");

            migrationBuilder.AlterColumn<string>(
                name: "Operation",
                table: "InvitationCommands",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(80)",
                oldMaxLength: 80);
        }
    }
}
