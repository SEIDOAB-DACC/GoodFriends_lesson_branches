using Configuration;
using Configuration.Extensions;
using DbContext.Extensions;
using DbRepos;

using Services;

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

//adding support for several secret sources and database sources
//to use either user secrets or azure key vault depending on UseAzureKeyVault tag in appsettings.json
builder.Configuration.AddSecrets(builder.Environment, "AppWebApi");

//use encryption and multiple Database connections and their respective DbContexts
builder.Services.AddEncryptions(builder.Configuration);
builder.Services.AddDatabaseConnections(builder.Configuration);
builder.Services.AddUserBasedDbContext();

// adding verion info
builder.Services.AddVersionInfo();

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



//Add InMemoryLoggerProvider logger
builder.Services.AddInMemoryLogger();

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
