using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

using Configuration;
using Models;
using Microsoft.Extensions.Hosting.Internal;

namespace DbContext;

//DbContext namespace is a fundamental EFC layer of the database context and is
//used for all Database connection as well as for EFC CodeFirst migration and database updates 
public class MainDbContext : Microsoft.EntityFrameworkCore.DbContext
{
    #region C# model of database tables
    public DbSet<Quote> Quotes { get; set; }
    #endregion

    public MainDbContext() { }
    public MainDbContext(DbContextOptions options) : base(options)
    { }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            var connectionString = "Data Source=localhost,14333;Initial Catalog=sql-friends;Persist Security Info=True;User ID=sa;Pwd=skYhgS@83#aQ;Encrypt=False;";
            optionsBuilder.UseSqlServer(connectionString, options => options.EnableRetryOnFailure());
        }
        base.OnConfiguring(optionsBuilder);
    }
}