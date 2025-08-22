
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers().AddNewtonsoftJson(options =>
    options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore);
builder.Services.AddEndpointsApiExplorer();

// configure OpenApi and scalar
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi("v1", options =>
{
    options.AddDocumentTransformer((document, context, cancellationToken) =>
    {
        document.Info = new()
        {
            Title = "Seido Friends API",
#if DEBUG
            Version = "v2.0 DEBUG",
#else
            Version = "v2.0",
#endif
            Description = "This is an API used in Seido's various software developer training courses."
        };
        return Task.CompletedTask;
    });
});


var app = builder.Build();

app.MapOpenApi();

//Here always use for teaching purposes, otherwise only during development
app.MapScalarApiReference();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
