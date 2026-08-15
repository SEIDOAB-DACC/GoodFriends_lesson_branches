# SQL Database Scripts and Cross-Database Compatibility Guide

This document provides a comprehensive explanation of the SQL scripts in the `DbContext/SqlScripts` directory, database schema handling differences across SQL Server, MySQL, and PostgreSQL, and how views and stored procedures are integrated into the .NET application.

## Table of Contents

1. [SQL Scripts Overview](#sql-scripts-overview)
2. [Database Schema Handling Differences](#database-schema-handling-differences)
3. [SQL Views Integration](#sql-views-integration)
4. [Stored Procedures Integration](#stored-procedures-integration)
5. [Cross-Database Implementation Patterns](#cross-database-implementation-patterns)

## SQL Scripts Overview

The project contains SQL scripts organized by database provider in the `DbContext/SqlScripts` directory:

```
SqlScripts/
├── sqlserver/
│   ├── initDatabase.sql
│   └── clearDatabase.sql
├── mysql/
│   ├── initDatabase.sql
│   └── clearDatabase.sql
└── postgres/
    ├── initDatabase.sql
    └── clearDatabase.sql
```

### Common Script Purpose

Each database provider has two main scripts:
- **`initDatabase.sql`**: Creates database schemas, views, and stored procedures
- **`clearDatabase.sql`**: Removes all database objects (cleanup script)

### Key Database Objects Created

All database versions create the following objects:

1. **Schemas**: Logical namespaces for organizing database objects
2. **Views**: Read-only virtual tables for reporting and aggregated data
3. **Stored Procedures/Functions**: Executable database routines for data manipulation

## Database Schema Handling Differences

Schema handling varies significantly across database platforms:

### SQL Server
```sql
-- SQL Server uses true schemas as namespaces
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gstusr')
    EXEC('CREATE SCHEMA gstusr');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'usr')
    EXEC('CREATE SCHEMA usr');
GO

-- Views are created with schema prefix
CREATE OR ALTER VIEW gstusr.vwInfoDb AS ...

-- Stored procedures use schema prefix
CREATE OR ALTER PROC supusr.spDeleteAll ...
```

**SQL Server Schema Features:**
- True schema namespaces supported
- Object names include schema prefix (e.g., `gstusr.vwInfoDb`)
- Schema-based security and permissions
- Multiple schemas per database

### MySQL/MariaDB
```sql
-- MySQL doesn't support schemas as namespaces
-- Uses naming convention with underscores instead
-- Schema = Database in MySQL terminology

-- Views use underscore naming convention
CREATE OR REPLACE VIEW gstusr_vwInfoDb AS ...

-- Procedures use underscore naming convention  
CREATE OR REPLACE PROCEDURE supusr_spDeleteAll(...) ...
```

**MySQL Schema Limitations:**
- No true schema support (schema = database)
- Uses naming conventions with underscores as schema simulation
- Object names: `gstusr_vwInfoDb` instead of `gstusr.vwInfoDb`
- Single "schema" (database) per connection

### PostgreSQL
```sql
-- PostgreSQL has robust schema support
CREATE SCHEMA IF NOT EXISTS gstusr;
CREATE SCHEMA IF NOT EXISTS usr;
CREATE SCHEMA IF NOT EXISTS supusr;

-- Views use quoted identifiers and schema prefix
CREATE OR REPLACE VIEW gstusr."vwInfoDb" AS ...

-- Functions (not procedures) with schema prefix
CREATE OR REPLACE FUNCTION supusr."spDeleteAll"(...) 
RETURNS RECORD ...
```

**PostgreSQL Schema Features:**
- Full schema namespace support
- Case-sensitive identifiers require quotes
- Uses functions instead of stored procedures
- Advanced schema-based security model

## SQL Views Integration

Views provide read-only access to aggregated data and are integrated through Entity Framework Core.

### View Definitions

All databases create four main views:

#### 1. Database Info View (`vwInfoDb`)
```sql
-- Provides overview of database content
SELECT 
    (SELECT COUNT(*) FROM supusr.Friends WHERE Seeded = 1) as NrSeededFriends,
    (SELECT COUNT(*) FROM supusr.Friends WHERE Seeded = 0) as NrUnseededFriends,
    -- ... more counts for addresses, pets, quotes
```

#### 2. Friends Info View (`vwInfoFriends`)
```sql
-- Groups friends by country and city
SELECT a.Country, a.City, COUNT(*) as NrFriends 
FROM supusr.Friends f
INNER JOIN supusr.Addresses a ON f.AddressId = a.AddressId
GROUP BY a.Country, a.City WITH ROLLUP;
```

#### 3. Pets Info View (`vwInfoPets`)
```sql
-- Groups pets by location
SELECT a.Country, a.City, COUNT(p.PetId) as NrPets 
FROM supusr.Friends f
INNER JOIN supusr.Addresses a ON f.AddressId = a.AddressId
INNER JOIN supusr.Pets p ON p.FriendId = f.FriendId
GROUP BY a.Country, a.City WITH ROLLUP;
```

#### 4. Quotes Info View (`vwInfoQuotes`)
```sql
-- Groups quotes by author
SELECT Author, COUNT(QuoteText) as NrQuotes 
FROM supusr.Quotes 
GROUP BY Author;
```

### EF Core View Integration

Views are integrated in `MainDbContext.cs` through:

#### 1. DbSet Properties
```csharp
#region model the Views
public DbSet<GstUsrInfoDbDto> InfoDbView { get; set; }
public DbSet<GstUsrInfoFriendsDto> InfoFriendsView { get; set; }
public DbSet<GstUsrInfoPetsDto> InfoPetsView { get; set; }
public DbSet<GstUsrInfoQuotesDto> InfoQuotesView { get; set; }
#endregion
```

#### 2. Model Configuration
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    #region model the Views
    modelBuilder.Entity<GstUsrInfoDbDto>().ToView("vwInfoDb", "gstusr").HasNoKey();
    modelBuilder.Entity<GstUsrInfoFriendsDto>().ToView("vwInfoFriends", "gstusr").HasNoKey();
    modelBuilder.Entity<GstUsrInfoPetsDto>().ToView("vwInfoPets", "gstusr").HasNoKey();
    modelBuilder.Entity<GstUsrInfoQuotesDto>().ToView("vwInfoQuotes", "gstusr").HasNoKey();        
    #endregion
}
```

#### 3. DTO Mapping
Views map to C# DTOs in `Models/DTO/GstUsrDto.cs`:
```csharp
public class GstUsrInfoDbDto
{
    public int NrSeededFriends { get; set; } = 0;
    public int NrUnseededFriends { get; set; } = 0;
    public int NrFriendsWithAddress { get; set; } = 0;
    // ... other properties
}
```

#### 4. Repository Usage
Views are accessed in `AdminDbRepos.cs`:
```csharp
private async Task<ResponseItemDto<GstUsrInfoAllDto>> DbInfo()
{
    var info = new GstUsrInfoAllDto();
    info.Db = await _dbContext.InfoDbView.FirstAsync();
    info.Friends = await _dbContext.InfoFriendsView.ToListAsync();
    info.Pets = await _dbContext.InfoPetsView.ToListAsync();
    info.Quotes = await _dbContext.InfoQuotesView.ToListAsync();
    // ...
}
```

## Stored Procedures Integration

The application uses stored procedures/functions for complex data operations, specifically the `spDeleteAll` routine.

### Cross-Database Procedure Definitions

#### SQL Server Stored Procedure
```sql
CREATE OR ALTER PROC supusr.spDeleteAll
    @seededParam BIT = 1,
    @nrFriendsAffected INT OUTPUT,
    @nrAddressesAffected INT OUTPUT,
    @nrPetsAffected INT OUTPUT,
    @nrQuotesAffected INT OUTPUT
AS
    -- Count affected records
    SELECT @nrFriendsAffected = COUNT(*) FROM supusr.Friends WHERE Seeded = @seededParam;
    -- ... similar for other tables
    
    -- Delete records
    DELETE FROM supusr.Friends WHERE Seeded = @seededParam;
    -- ... delete from other tables
    
    -- Return result set
    SELECT * FROM gstusr.vwInfoDb;
GO
```

#### MySQL Stored Procedure
```sql
CREATE OR REPLACE PROCEDURE supusr_spDeleteAll(
    IN seededParam BOOLEAN,
    OUT nrFriendsAffected INT,
    OUT nrAddressesAffected INT,
    OUT nrPetsAffected INT,
    OUT nrQuotesAffected INT
)
BEGIN
    -- Count and delete logic similar to SQL Server
    -- but with MySQL syntax
END;
```

#### PostgreSQL Function
```sql
CREATE OR REPLACE FUNCTION supusr."spDeleteAll"(
    seededParam BOOLEAN DEFAULT true,
    OUT nrFriendsAffected INTEGER,
    OUT nrAddressesAffected INTEGER,
    OUT nrPetsAffected INTEGER,
    OUT nrQuotesAffected INTEGER
)
RETURNS RECORD
LANGUAGE plpgsql
AS $$
BEGIN
    -- Function body with PostgreSQL-specific syntax
END;
$$;
```

### C# Stored Procedure Integration

The `AdminDbRepos.cs` class demonstrates cross-database stored procedure execution:

#### 1. Database Provider Detection
```csharp
var connection = _dbContext.Database.GetDbConnection();
using var command = connection.CreateCommand();
command.CommandType = CommandType.StoredProcedure;

List<DbParameter> parameters;
if (connection is MySqlConnection)
{
    // MySQL-specific parameter setup
    command.CommandText = "supusr_spDeleteAll";
    parameters = new List<DbParameter>
    {
        new MySqlParameter("seededParam", seeded),
        new MySqlParameter("nrFriendsAffected", MySqlDbType.Int32) { Direction = ParameterDirection.Output },
        // ... other parameters
    };
}
else if (connection is NpgsqlConnection)
{
    // PostgreSQL function call
    command.CommandText = "SELECT nrFriendsAffected, nrAddressesAffected, nrPetsAffected, nrQuotesAffected FROM supusr.\"spDeleteAll\"(@seededParam)";
    command.CommandType = CommandType.Text;
    // ... PostgreSQL parameters
}
else
{
    // SQL Server (default)
    command.CommandText = "supusr.spDeleteAll";
    parameters = new List<DbParameter>
    {
        new SqlParameter("seededParam", seeded),
        new SqlParameter("nrFriendsAffected", SqlDbType.Int) { Direction = ParameterDirection.Output },
        // ... other parameters
    };
}
```

#### 2. Parameter Handling
```csharp
command.Parameters.AddRange(parameters.ToArray());

if (connection.State != ConnectionState.Open)
    await connection.OpenAsync();

if (connection is NpgsqlConnection)
{
    // PostgreSQL function execution
    await command.ExecuteScalarAsync();
}
else
{
    // SQL Server/MySQL procedure execution with result set
    using var reader = await command.ExecuteReaderAsync();
    
    if (reader.HasRows)
    {
        await reader.ReadAsync();
        var result_set = new GstUsrInfoDbDto
        {
            NrSeededFriends = Convert.ToInt32(reader["NrSeededFriends"]),
            // ... map other fields
        };
    }
}
```

#### 3. Output Parameter Access
```csharp
// Extract output parameter values
int nrFriends = (int)parameters.First(p => p.ParameterName == "nrFriendsAffected").Value;
int nrAddresses = (int)parameters.First(p => p.ParameterName == "nrAddressesAffected").Value;
// ... other output parameters
```

## Cross-Database Implementation Patterns

### 1. Schema Abstraction
The application handles schema differences through:
- **SQL Server**: True schemas (`gstusr.vwInfoDb`)
- **MySQL**: Underscore naming (`gstusr_vwInfoDb`)
- **PostgreSQL**: Quoted schemas (`gstusr."vwInfoDb"`)

### 2. EF Core Database-Specific Contexts
```csharp
public class SqlServerDbContext : MainDbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseSqlServer(connectionString, options => 
            options.EnableRetryOnFailure());
    }
}

public class MySqlDbContext : MainDbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString),
            b => b.SchemaBehavior(Microting.EntityFrameworkCore.MySql.Infrastructure.MySqlSchemaBehavior.Translate, 
                (schema, table) => $"{schema}_{table}"));
    }
}
```

### 3. Provider-Specific Parameter Handling
The repository layer detects the database provider at runtime and adjusts:
- Parameter types and syntax
- Command execution methods
- Result set handling
- Error handling patterns

### 4. View Naming Strategy
- **SQL Server/PostgreSQL**: Schema.ViewName
- **MySQL**: Schema_ViewName (translated automatically by EF Core)

This architecture provides database portability while maintaining optimal performance and feature utilization for each database platform.

## Best Practices

1. **Use Views for Reporting**: Complex aggregations are better handled in database views rather than application code
2. **Performance-Critical Operations**: Use stored procedures/functions for performance-hungry SQL operations like bulk deletes (e.g., `spDeleteAll`) rather than Entity Framework Core operations, as database-native operations are significantly faster for large datasets
3. **Provider Detection**: Always detect the database provider at runtime for stored procedure calls
3. **Schema Abstraction**: Use EF Core's built-in schema translation features when possible
4. **Error Handling**: Implement database-specific error handling for stored procedures
5. **Output Parameters**: Handle output parameters differently based on database provider capabilities
6. **Case Sensitivity**: Be aware of case sensitivity differences, especially with PostgreSQL

This approach ensures the application remains database-agnostic while leveraging the specific strengths of each database platform.