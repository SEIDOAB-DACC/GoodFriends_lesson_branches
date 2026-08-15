# Explanation of Projects: DbContext, DbModels, DbRepos

## Overview
This document explains the responsibilities and relationships of the `DbContext`, `DbModels`, and `DbRepos` projects in the software stack. It also describes how the connection string is read and used by the `DbContext`.

---

## 1. DbContext
**Responsibility:**
- The `DbContext` project contains the Entity Framework Core `DbContext` class, which manages the database connection and is responsible for querying and saving data.
- It acts as a bridge between the domain models (entities) and the database.

**Relationship to Other Layers:**
- References the `DbModels` project to access entity definitions.
- Used by the `DbRepos` project to perform data access operations.
- Reads the connection string from configuration files to establish a database connection.

---

## 2. DbModels
**Responsibility:**
- The `DbModels` project defines the data models (entities) that represent the structure of tables in the database.
- Contains classes with properties that map to database columns.

**Relationship to Other Layers:**
- Referenced by both `DbContext` (for model definitions) and `DbRepos` (for data transfer and manipulation).
- Does not contain any logic for data access or business rules.

---

## 3. DbRepos
**Responsibility:**
- The `DbRepos` project implements repository classes that encapsulate data access logic.
- Provides methods for CRUD (Create, Read, Update, Delete) operations and custom queries.

**Relationship to Other Layers:**
- Uses the `DbContext` to interact with the database.
- Works with `DbModels` to return and manipulate entity objects.
- Serves as a data access layer for higher-level services or controllers.

---

## How the Connection String is Read and Used by DbContext
1. **Configuration File:**
   - The connection string is typically stored in a user-secret file or cloud keyvault, but in this simple example the configuration file such as `appsettings.json` in the main application is used (e.g., `AppWebApi/appsettings.json`).

2. **Reading the Connection String:**
   - At application startup, the configuration system reads the connection string from the configuration file.
   - The `DbContext` is configured in the application's dependency injection setup, where it receives the connection string.

3. **Usage in DbContext:**
   - The `DbContext` uses the connection string to establish a connection to the database when performing data operations.
   - Example (in `Startup.cs` or `Program.cs`):
     ```csharp
     services.AddDbContext<MainDbContext>(options =>
         options.UseSqlServer(Configuration.GetConnectionString("DefaultConnection")));
     ```

---


---

## MainDbContext and Its Child Classes

### MainDbContext
`MainDbContext` is the base Entity Framework Core context class for the application. It manages the database connection, entity sets (such as `Quotes`), and provides shared logic for all database operations. It exposes a method to retrieve connection strings from configuration.

**Key responsibilities:**
- Defines the main `DbSet` properties for entities (e.g., `Quotes`).
- Provides constructors for dependency injection and direct instantiation.
- Contains shared logic for model building and connection string retrieval.

### Child DbContext Classes
To support multiple database providers, `MainDbContext` is subclassed for each supported database:

- **SqlServerDbContext**
   - Inherits from `MainDbContext`.
   - Configures the context to use SQL Server via `UseSqlServer`.
   - Sets up conventions for decimal and string properties.
   - Used for SQL Server-specific migrations and database updates.

- **MySqlDbContext**
   - Inherits from `MainDbContext`.
   - Configures the context to use MySQL via `UseMySql`.
   - Sets up conventions for string properties.
   - Used for MySQL-specific migrations and database updates.

- **PostgresDbContext**
   - Inherits from `MainDbContext`.
   - Configures the context to use PostgreSQL via `UseNpgsql`.
   - Sets up conventions for string properties.
   - Used for PostgreSQL-specific migrations and database updates.

**Purpose of this structure:**
- Allows the application to target different database engines with minimal code changes.
- Each child context can override configuration and conventions as needed for its database provider.
- Enables provider-specific migrations and connection handling.

---

## Explanation: Purpose and Usage of OnConfiguring, ConfigureConventions, and OnModelCreating in EF Core

### OnConfiguring
- **Purpose:** Sets up the database provider, connection string, and other context options.
- **Usage:** Override this method in your DbContext to configure how EF Core connects to the database. It is called every time a new context instance is created, unless options are already configured externally (e.g., via dependency injection).
- **When Used:** Both at design time (e.g., migrations) and runtime (when your app runs).

### ConfigureConventions
- **Purpose:** Defines global conventions for model building, such as default column types or property behaviors.
- **Usage:** Override this method to set up conventions that apply to all entities and properties in your model. This helps reduce repetitive configuration.
- **When Used:** During model creation, before OnModelCreating, at both design time and runtime.

### OnModelCreating
- **Purpose:** Customizes the model by configuring entity mappings, relationships, constraints, and more using the Fluent API.
- **Usage:** Override this method to fine-tune how your classes map to database tables, set up relationships, add constraints (like check constraints), and configure indexes.
- **When Used:** During model creation, at both design time (for migrations) and runtime (when the context is used).

---

**Summary Table**

| Method              | Main Purpose                        | When Called                |
|---------------------|-------------------------------------|----------------------------|
| OnConfiguring       | Set up context/database connection  | Design time & runtime      |
| ConfigureConventions| Set global model conventions        | Design time & runtime      |
| OnModelCreating     | Customize model (tables, relations) | Design time & runtime      |

These methods are essential for controlling how EF Core builds and configures your database model, both when running your application and when using EF Core tools (like migrations).

---

## Summary
- `DbModels` defines the entity data structure.
- `DbContext` manages the database connection and entity tracking.
- `DbRepos` provides data access methods using `DbContext` and `DbModels`.
- The connection string is read from configuration and injected into `DbContext` for database operations.
- `MainDbContext` is the base context, with child classes for each supported database provider (SQL Server, MySQL, PostgreSQL).
