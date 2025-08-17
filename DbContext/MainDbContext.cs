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
    IConfiguration _configuration;
    DatabaseConnections _databaseConnections;

    //used only for the easy demonstration purposes
    //string _databaseHost = "192.168.68.53"; //used only for databases on remote docker
    string _databaseHost = "localhost";


#if DEBUG
    // remove password from connection string in debug mode
    // this is useful for debugging and logging purposes, but should not be used in production code
    public string dbConnection => System.Text.RegularExpressions.Regex.Replace(
        this.Database.GetConnectionString() ?? "", @"(pwd|password)=[^;]*;?", "",
        System.Text.RegularExpressions.RegexOptions.IgnoreCase);
#endif

    #region C# model of database tables
    public DbSet<QuoteDbM> Quotes { get; set; }
    #endregion

    #region constructors
    public MainDbContext() { }
    public MainDbContext(DbContextOptions options, IConfiguration configuration, DatabaseConnections databaseConnections) : base(options)
    { 
        _databaseConnections = databaseConnections;
        _configuration = configuration;
    }
    #endregion

    //Here we can modify the migration building
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        #region override modelbuilder
        #endregion
        
        base.OnModelCreating(modelBuilder);
    }

    #region DbContext for some popular databases
    public class SqlServerDbContext : MainDbContext
    {
        public SqlServerDbContext() { }
        public SqlServerDbContext(DbContextOptions options, IConfiguration configuration, DatabaseConnections databaseConnections) 
            : base(options, configuration, databaseConnections) { }


        //Used only for CodeFirst Database Migration and database update commands
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                //services are not created by dependency injection when doing a dotnet ef code first migration.
                //We will create them manually in next branch
                //Therefore we used literal connect string in this example
                var connectionString = $"Data Source={_databaseHost},14333;Initial Catalog=sql-friends;Persist Security Info=True;User ID=sa;Pwd=skYhgS@83#aQ;Encrypt=False;";
                System.Console.WriteLine($"Connection String: {connectionString}");

                optionsBuilder.UseSqlServer(connectionString,options => options.EnableRetryOnFailure());}

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
    }

    public class MySqlDbContext : MainDbContext
    {
        public MySqlDbContext() { }
        public MySqlDbContext(DbContextOptions options) : base(options, null, null) { }


        //Used only for CodeFirst Database Migration
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                //services are not created by dependency injection when doing a dotnet ef code first migration.
                //We will create them manually in next branch
                //Therefore we used literal connect string in this example
                var connectionString = $"server={_databaseHost},14333;uid=root;pwd=skYhgS@83#aQ;database=sql-friends;";
                System.Console.WriteLine($"Connection String: {connectionString}");

                optionsBuilder.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString),
                    b => b.SchemaBehavior(Pomelo.EntityFrameworkCore.MySql.Infrastructure.MySqlSchemaBehavior.Translate, (schema, table) => $"{schema}_{table}"));
            }

            base.OnConfiguring(optionsBuilder);
        }

        protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
        {
            configurationBuilder.Properties<string>().HaveColumnType("varchar(200)");

            base.ConfigureConventions(configurationBuilder);

        }
    }

    public class PostgresDbContext : MainDbContext
    {
        public PostgresDbContext() { }
        public PostgresDbContext(DbContextOptions options) : base(options, null, null){ }


        //Used only for CodeFirst Database Migration
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                //services are not created by dependency injection when doing a dotnet ef code first migration.
                //We will create them manually in next branch
                //Therefore we used literal connect string in this example
                var connectionString = $"Server={_databaseHost};Port=5432;Database=sql-friends;Username=postgres;Password=skYhgS@83#aQ;";
                System.Console.WriteLine($"Connection String: {connectionString}");
                
                optionsBuilder.UseNpgsql(connectionString);
            }

            base.OnConfiguring(optionsBuilder);
        }

        protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
        {
            configurationBuilder.Properties<string>().HaveColumnType("varchar(200)");
            base.ConfigureConventions(configurationBuilder);
        }
    }
    #endregion
}
