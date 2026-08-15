# N-tier Layers

Number prefix to get right sort order in VS Code.

> **Note:** This course uses the **Inheritance** approach so students get hands-on practice with inheritance and interfaces — two concepts fundamental to C# and .NET.

## Using Inheritance (`DataAccess.EntryModels` :: `Domain.Models`)

| Original      | Alternative name            | Description |
|---------------|-----------------------------|-----------------------------------------|
| AppWebApi     | 0.Pres.WebApi               | Presentation layer — controllers, HTTP endpoints, Swagger |
| Services      | 1.App.Services              | Application layer — business logic and use-case orchestration |
| DbRepos       | 2a.DataAccess.Repos         | Repository layer — CRUD operations via EF Core |
| DbContext     | 2b.DataAccess.DbContext     | EF Core DbContext — database connection and change tracking |
| DbModels      | 2c.DataAccess.EntryModels   | Database entry models — map directly to database tables |
| Models        | 3.Domain.Models             | Domain models — DTOs and shared data structures |
| Configuration | 4.CrossCut.Concerns         | Cross-cutting concerns — settings, logging, DI extensions |

## Using AutoMapper (`DataAccess.EntryModels` <=> `Domain.Models`)

| Original      | Alternative name            | Description |
|---------------|-----------------------------|-----------------------------------------|
| AppWebApi     | 0.Pres.WebApi               | Presentation layer — controllers, HTTP endpoints, Swagger |
| Services      | 1.App.Services              | Application layer — business logic and use-case orchestration |
| Models        | 2.Domain.Models             | Domain models — DTOs mapped to/from database entry models via AutoMapper |
| DbRepos       | 3a.DataAccess.Repos         | Repository layer — CRUD operations via EF Core |
| DbContext     | 3b.DataAccess.DbContext     | EF Core DbContext — database connection and change tracking |
| Configuration | 4.CrossCut.Concerns         | Cross-cutting concerns — settings, logging, DI extensions |

## Lesson Branches

Each branch takes a step-by-step approach, gradually adding code across the N-tier layers to cover a specific topic. No branch skips ahead — every piece of functionality is introduced incrementally so the reasoning behind each decision is clear. By the final branch, the cumulative result is an industrial-strength Web API application built one layer at a time.

| Branch | Topic |
|--------|-------|
| `0-microsoft-template` | Default Microsoft Web API project template — starting point |
| `1-swagger` | Adding Swagger / OpenAPI documentation |
| `2-version` | API versioning |
| `3-configuration` | Dedicated `Configuration` project for centralised, strongly-typed app settings |
| `4-dependency-injection` | ASP.NET Core built-in dependency injection setup |
| `5-logger` | Microsoft `ILogger` / `ILoggerProvider` pattern |
| `6-models` | Domain model definitions — introducing the `Models` project |
| `7-services` | Business logic layer — introducing the `Services` project |
| `7a-creditcard-exAnsw` | Exercise answer: credit card example |
| `7b-creditcard-exAnsw-best` | Exercise answer: improved credit card example |
| `8-dbcontext-simple` | Introducing `DbContext`, `DbModels`, and `DbRepos` projects |
| `9-dbcontext` | Extended `DbContext` with connection string and provider configuration |
| `10-extensions` | Extension methods in `Configuration/Extensions` and `DbContext/Extensions` |
| `10a-creditcard-exAnsw` | Exercise answer: credit card with extensions |
| `10b-zoo-exAnsw` | Exercise answer: zoo example with extensions |
| `11-model-context` | Deeper look at `DbContext`, `DbModels`, and `DbRepos` relationships |
| `12-navigation-props` | Navigation properties and EF Core mapping strategies |
| `12a-creditcard-exAnsw` | Exercise answer: credit card with navigation properties |
| `13-schema-annotations` | Data annotations for schema control and validation in `DbModels` |
| `14-seeding-reading` | Database seeding and reading data via `DbRepos` |
| `15-modelbuilder-linq` | `ModelBuilder` Fluent API configuration and LINQ in `ReadAsync` methods |
| `16-rd-in-crud` | Read and Delete operations in the CRUD pattern |
| `17-cu-in-crud` | Create and Update operations in the CRUD pattern |
| `18-crud-complete` | Complete CRUD implementation across all layers |
| `19-input-validation` | Input validation using RegEx patterns and data annotations |
| `20-database-objects` | SQL views and stored procedures across SQL Server, MySQL, and PostgreSQL |
| `21-database-security` | Database roles, schemas, and login stored procedure security |
| `22-jwt-security` | JWT token generation, validation, and Swagger integration |
| `23-optional-publish-azure` | Optional: publishing the Web API to Azure |