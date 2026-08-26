# Step-by-step code changes: 7-services to 7m-services

Start in the `7-services` branch in VS Code.

The purpose of this change is to keep the existing service-oriented architecture, but add the database layer so the app can save quote data to SQL Server instead of only generating it in memory.

---

## 1. Open the starting branch

Switch to the starting branch in VS Code:

```bash
git checkout 7-services
```

Then confirm you are on the correct branch:

```bash
git branch --show-current
```

Purpose:
- This ensures you are starting from the service-layer version before adding persistence.
- The app already has the business logic in `Services`, but it does not yet write to a database.

---

## 2. Create the `DbContext` project folder and project file

Create a new folder named `DbContext` in the solution root.

Inside that folder, create a project file named `DbContext.csproj` with this exact content:

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>disable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\Configuration\Configuration.csproj" />
    <ProjectReference Include="..\Models\Models.csproj" />
  </ItemGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.Identity.EntityFrameworkCore" Version="10.0.10" />
    <PackageReference Include="Microsoft.EntityFrameworkCore" Version="10.0.10" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="10.0.10"/>
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="10.0.10" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="10.0.10"/>
    <PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="10.0.3" />
    <PackageReference Include="Microting.EntityFrameworkCore.MySql" Version="10.0.10" />
  </ItemGroup>
    <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="10.0.10" />
    <PackageReference Include="Microsoft.IdentityModel.JsonWebTokens" Version="8.22.0" />
    <PackageReference Include="System.IdentityModel.Tokens.Jwt" Version="8.22.0" />
  </ItemGroup>

</Project>
```

Purpose:
- This creates the dedicated project that will host the EF Core database context and migration tooling.
- It gives the app a clear separation between the business service layer and the data access layer.
- It includes the EF Core packages needed for SQL Server, migrations, and code-first database creation.

---

## 3. Inspect the current design before editing

Open these files:

- `Services/IAdminService.cs`
- `Services/AdminServiceDb.cs`
- `AppWebApi/Program.cs`
- `AppWebApi/Controllers/AdminController.cs`

Purpose:
- Confirm that the app is already using dependency injection and a service interface.
- Keep this design intact while adding EF Core.
- The database layer should be added as a new concern, not a replacement for the service layer.

---

## 4. Add the project reference to the database project

In `AppWebApi/AppWebApi.csproj`, add:

```xml
<ProjectReference Include="..\DbContext\DbContext.csproj" />
```

Purpose:
- The Web API needs access to `MainDbContext`.
- This is the first code change that connects the API to the database layer.

---

## 4. Create the EF Core context exactly as the project expects

Create a new file in the `DbContext` project: `MainDbContext.cs`

Use this exact implementation:

```csharp
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
```

Purpose:
- `MainDbContext` is the EF Core database access object for the app.
- `DbSet<Quote>` maps the `Quote` entity to a database table called `Quotes`.
- The parameterless constructor and `OnConfiguring` method allow EF Core tooling and runtime configuration to resolve the SQL Server connection string when no options are injected.
- The `DbContextOptions` constructor is used by ASP.NET Core dependency injection when the app registers `MainDbContext` in `Program.cs`.
- This remains separate from `IAdminService`; it adds persistence without replacing the service layer.

### Next: build the database schema before using it

Open a terminal in the `DbContext` project folder and run:

```bash
dotnet ef migrations add initial_migration
```

Then run:

```bash
dotnet ef database update
```

Purpose:
- This generates the migration files from the model and then applies them to SQL Server.
- It is the step that creates the database and the `Quotes` table so you can inspect the schema.
- After this, students can open the database or SQL Server tools to verify the actual structure created by EF Core.

---

## 5. Register the database context in dependency injection

In `AppWebApi/Program.cs`, add the namespaces:

```csharp
using DbContext;
using Microsoft.EntityFrameworkCore;
```

Then add this registration:

```csharp
builder.Services.AddDbContext<MainDbContext>(options =>
{
    var connectionString = "Data Source=localhost,14333;Initial Catalog=sql-friends;Persist Security Info=True;User ID=sa;Pwd=skYhgS@83#aQ;Encrypt=False;";
    options.UseSqlServer(connectionString, options => options.EnableRetryOnFailure());
});
```

Purpose:
- This makes `MainDbContext` available anywhere the app asks for it through constructor injection.
- It is the standard ASP.NET Core pattern for EF Core database access.

## 6. Inject the database context into the controller

In `AppWebApi/Controllers/AdminController.cs`, add a field:

```csharp
readonly MainDbContext _context;
```

Then update the constructor to include:

```csharp
MainDbContext context
```

and assign it:

```csharp
_context = context;
```

Purpose:
- The controller is now able to persist data through EF Core.
- The controller still depends on `IAdminService` for the business logic, which preserves separation of concerns.

---

## 7. Save quotes in the Quotes endpoint before returning them

Update the `Quotes()` method in `AdminController` to be asynchronous:

```csharp
public async Task<IActionResult> Quotes()
```

Then add the persistence block:

```csharp
var quotesdb = quotes.Select(q => new Quote
{
    QuoteId = q.QuoteId,
    QuoteText = q.QuoteText,
    Author = q.Author
});

_context.Quotes.AddRange(quotesdb);
await _context.SaveChangesAsync();
```

Then keep the response:

```csharp
return Ok(quotes);
```

Purpose:
- The service still creates the quote data.
- The controller now saves that data into the database.
- This keeps the business logic separate from the database write operation.

---

## 8. Run the app and verify the behavior

Start the API and test the endpoint that returns quotes.

Purpose:
- Confirm the app still returns the quote list.
- Confirm the records are actually stored in the database.
- This verifies the branch transition succeeded without breaking the service architecture.

---

## 10. Check the final result against 7m-services

Now compare your code with the target branch:

```bash
git --no-pager diff 7-services..7m-services
```

Purpose:
- This shows the exact code changes needed to move from service-only logic to service-plus-database persistence.
- The key idea is that the app keeps the service contract and dependency injection, while adding EF Core as the persistence layer.

---

## Why these changes matter

The real purpose of the `7m-services` update is not to reinvent the app. It is to add data persistence while preserving the clean architecture:

- `IAdminService` still defines the business contract
- `AdminServiceDb` still contains the business logic
- `Program.cs` still handles dependency injection
- `MainDbContext` adds the database layer
- the controller uses both the service and the context in a controlled way

This is the key transition from a service-based app to a database-aware service-based app.
