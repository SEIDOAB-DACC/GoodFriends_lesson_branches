using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DbContext.Migrations.PostgresDbContext
{
    /// <inheritdoc />
    public partial class miInitial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Owners",
                columns: table => new
                {
                    OwnerId = table.Column<Guid>(type: "uuid", nullable: false),
                    FirstName = table.Column<string>(type: "varchar(200)", nullable: true),
                    LastName = table.Column<string>(type: "varchar(200)", nullable: true),
                    Seeded = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Owners", x => x.OwnerId);
                });

            migrationBuilder.CreateTable(
                name: "CreditCards",
                columns: table => new
                {
                    CreditCardId = table.Column<Guid>(type: "uuid", nullable: false),
                    OwnerDbMOwnerId = table.Column<Guid>(type: "uuid", nullable: true),
                    Issuer = table.Column<int>(type: "integer", nullable: false),
                    Number = table.Column<string>(type: "varchar(200)", nullable: true),
                    ExpirationYear = table.Column<string>(type: "varchar(200)", nullable: true),
                    ExpirationMonth = table.Column<string>(type: "varchar(200)", nullable: true),
                    EncryptedToken = table.Column<string>(type: "varchar(200)", nullable: true),
                    Seeded = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CreditCards", x => x.CreditCardId);
                    table.ForeignKey(
                        name: "FK_CreditCards_Owners_OwnerDbMOwnerId",
                        column: x => x.OwnerDbMOwnerId,
                        principalTable: "Owners",
                        principalColumn: "OwnerId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_CreditCards_OwnerDbMOwnerId",
                table: "CreditCards",
                column: "OwnerDbMOwnerId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CreditCards");

            migrationBuilder.DropTable(
                name: "Owners");
        }
    }
}
