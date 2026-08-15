using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

using Configuration;
using DbModels;
using Microsoft.Extensions.Hosting.Internal;

namespace DbContext;

//DbContext namespace is a fundamental EFC layer of the database context and is
//used for all Database connection as well as for EFC CodeFirst migration and database updates 
public class MainDbContext : Microsoft.EntityFrameworkCore.DbContext
{
    #region C# model of database tables
    public DbSet<QuoteDbM> Quotes { get; set; }
    #endregion

    public MainDbContext() { }
    public MainDbContext(DbContextOptions options) : base(options)
    { }

    //Used only for CodeFirst Database Migration and database update commands
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            var connectionString = GetConnectionString("SqlServerDocker");
            optionsBuilder.UseSqlServer(connectionString, options => options.EnableRetryOnFailure());
        }

        base.OnConfiguring(optionsBuilder);
    }

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        configurationBuilder.Properties<decimal>().HaveColumnType("money");
        configurationBuilder.Properties<string>().HaveColumnType("varchar(200)");

        base.ConfigureConventions(configurationBuilder);
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        //Add your own modelling based on done migrations
        base.OnModelCreating(modelBuilder);
    }

    //used by the child DbContexts to retrieve the connection string
    protected string GetConnectionString(string connectionStringName)
    {
        // Design time: manually create configuration to read appsettings.json
        var configBuilder = new ConfigurationBuilder()
            .SetBasePath(System.IO.Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);

        var config = configBuilder.Build();
        var connectionString = config.GetConnectionString(connectionStringName);
        System.Console.WriteLine($"Design time Connection String from appsettings.json: {connectionString}");

        return connectionString;
    }
}
