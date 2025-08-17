using Configuration;
using Configuration.Options;
using DbContext;
using DbRepos;
using Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// NOTE: global cors policy needed for JS and React frontends
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(builder =>
    {
        builder.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddControllers().AddNewtonsoftJson(options =>
    options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

//using user secrets in development
var currentDir = Directory.GetCurrentDirectory();
var assembly = System.Reflection.Assembly.Load("Configuration");
builder.Configuration.SetBasePath(Path.Combine(currentDir, "../AppWebApi"))
        .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
        .AddUserSecrets(assembly);

// adding options patterns to read appsettings and user secrets
builder.Services.Configure<AesEncryptionOptions>(
    options => builder.Configuration.GetSection(AesEncryptionOptions.Position).Bind(options));

builder.Services.Configure<JwtOptions>(
    options => builder.Configuration.GetSection(JwtOptions.Position).Bind(options));

// adding options and service for multiple Database connections and their respective DbContexts
builder.Services.Configure<DbConnectionSetsOptions>(
    options => builder.Configuration.GetSection(DbConnectionSetsOptions.Position).Bind(options));

// adding verion info
builder.Services.Configure<VersionOptions>(options =>VersionOptions.ReadFromAssembly(options));

// Registering database connections service
builder.Services.AddSingleton<DatabaseConnections>();

// adding DbContexts
builder.Services.AddDbContext<MainDbContext>((serviceProvider, options) => 
{ 
    var configuration = serviceProvider.GetRequiredService<IConfiguration>(); 
    var databaseConnections = serviceProvider.GetRequiredService<DatabaseConnections>(); 
    
    var userRole = configuration["DatabaseConnections:DefaultDataUser"];                      
    var conn = databaseConnections.GetDataConnectionDetails(userRole);
    if (databaseConnections.SetupInfo.DataConnectionServer == DatabaseServer.SQLServer)
    {
        options.UseSqlServer(conn.DbConnectionString, options => options.EnableRetryOnFailure());
    }
    else if (databaseConnections.SetupInfo.DataConnectionServer == DatabaseServer.MySql)
    {
        options.UseMySql(conn.DbConnectionString,ServerVersion.AutoDetect(conn.DbConnectionString),
            b => b.SchemaBehavior(Pomelo.EntityFrameworkCore.MySql.Infrastructure.MySqlSchemaBehavior.Translate, (schema, table) => $"{schema}_{table}"));
    }
    else if (databaseConnections.SetupInfo.DataConnectionServer == DatabaseServer.PostgreSql)
    {
        options.UseNpgsql(conn.DbConnectionString);
    }
    else
    {
        //unknown database type
        throw new InvalidDataException($"DbContext for {databaseConnections.SetupInfo.DataConnectionServer} not existing");
    }
});


// adding encryption
builder.Services.AddTransient<Encryptions>();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new()
    {
        Title = "Seido Friends API",
#if DEBUG
        Version = "v2.0 DEBUG",
#else
        Version = "v2.0",
#endif
        Description = "This is an API used in Seido's various software developer training courses."
        + $"<br>DataSet: {builder.Configuration["DatabaseConnections:UseDataSetWithTag"]}"
        + $"<br>DefaultDataUser: {builder.Configuration["DatabaseConnections:DefaultDataUser"]}"
    });
});



//Inject Custom logger, this will also register the InMemoryLoggerProvider logger
//hence, AddLogging should not be used here
builder.Services.AddSingleton<ILoggerProvider, InMemoryLoggerProvider>();

//Inject DbRepos and Services
builder.Services.AddScoped<AdminDbRepos>();

builder.Services.AddScoped<IAdminService, AdminServiceDb>();

var app = builder.Build();

// Configure the HTTP request pipeline.
// for the purpose of this example, we will use Swagger also in production
//if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Seido Friends API v2.0");
    });
}

app.UseHttpsRedirection();
app.UseCors(); 

app.UseAuthorization();
app.MapControllers();

app.Run();
