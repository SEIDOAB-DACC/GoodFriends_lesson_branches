# Exercise: Dynamic DbContext Configuration Based on appsettings.json

## Objective
Modify the application to read an `ActiveDbConnection` key from `appsettings.json` and use its value to select the appropriate connection string and database provider for the `DbContext` in `Program.cs`.

---

## Step 1: Update appsettings.json
Add a new key `ActiveDbConnection` under the `ConnectionStrings` section or at the root level of your configuration. Example:

```json
"ActiveDbConnection": "PostgreSqlDocker"
```

Your `appsettings.json` should now include:

```json
{
  // ...existing code...
  "ActiveDbConnection": "PostgreSqlDocker",
  "ConnectionStrings": {
    "SqlServerDocker": "...",
    "MySqlDocker": "...",
    "PostgreSqlDocker": "..."
  }
  // ...existing code...
}
```

---

## Step 2: Modify Program.cs to Use ActiveDbConnection
1. **Read the `ActiveDbConnection` value from configuration.**
2. **Select the corresponding connection string.**
3. **Configure the `DbContext` with the correct provider:**
   - Use `UseSqlServer` for SQL Server
   - Use `UseMySql` for MySQL
   - Use `UseNpgsql` for PostgreSQL

### Hint
```csharp
var builder = WebApplication.CreateBuilder(args);

// Read ActiveDbConnection from configuration. 
var activeDb = builder.Configuration["ActiveDbConnection"] ?? "SqlServerDocker";
var connectionString = builder.Configuration.GetConnectionString(activeDb);
```

---

## Step 3: Swagger Description
- In Program.cs modify the Description in Swagger, to also show the ActiveDb
- This way the Swagger page will show database connection used


## Step 4: Test
- Change the value of `ActiveDbConnection` in `appsettings.json` to test different database providers.
- Ensure the application connects to the correct database based on your selection.

---

## Summary
This exercise demonstrates how to:
- Add a configuration key to select the active database connection.
- Dynamically configure the `DbContext` provider in `Program.cs` based on configuration.
- Easily switch between SQL Server, MySQL, and PostgreSQL by changing a single value in `appsettings.json`.
