# Explanation of DbContext, DbModels, and DbRepos Projects

## 1. DbContext Project

**Purpose:**
- The `DbContext` project contains the Entity Framework Core context class (`MainDbContext`).
- It manages the database connection, tracks changes, and coordinates CRUD operations between the application and the database.
- It is responsible for configuring the database schema, relationships, and migrations.

**Content:**
- `MainDbContext.cs`: Defines the DbContext class, DbSet properties for each entity, and configuration logic.
- Migrations folder: Contains EF Core migration files for schema changes.
- Project references: Typically references `DbModels` for entity definitions.

**Relationship to Other Projects:**
- Depends on `DbModels` for entity classes.
- Used by repositories and services to access and manipulate data.

---

## 2. DbModels Project

**Purpose:**
- The `DbModels` project defines the data model classes (entities) that represent tables in the database.
- These classes are plain C# objects (POCOs) with properties mapping to database columns.

**Content:**
- Entity classes such as `FriendDbM`, `AddressDbM`, `PetDbM`, `QuoteDbM`.
- Each class typically includes properties for columns and may include navigation properties for relationships.

**Relationship to Other Projects:**
- Referenced by `DbContext` to define the schema.
- Used by `DbRepos` for data access and by services for business logic.

**Note on Navigation Properties:**
- Navigation properties in `DbModels` are in this branch marked with `[NotMapped]`.
- **Reason:** In this architecture the DbModels inherit from Models, and as we want loosely coupled objects, Models define the relationship to other models using interfaces. Interfaces cannot be instatiated, so we need to modify the relationships in DbModels so EFC can instantiate. We will do this in the next branch. In this branch, we simply tell EFC not to implement the relationship.

---

## 3. DbRepos Project

**Purpose:**
- The `DbRepos` project implements repository classes for data access logic.
- Repositories encapsulate CRUD operations and queries for each entity.
- They provide an abstraction layer between the database and the business logic/services.

**Content:**
- Repository classes such as `FriendsDbRepos`, `AddressesDbRepos`, etc.
- Each repository uses the `DbContext` to perform operations on the database.

**Relationship to Other Projects:**
- Depends on `DbContext` for database access.
- Uses `DbModels` for entity types.
- Called by service layer (in `Services` project) to perform data operations.

---

## Summary of Relationships
- `DbModels` defines the entities.
- `DbContext` uses `DbModels` to define the schema and manage the database.
- `DbRepos` uses both `DbContext` and `DbModels` to implement data access logic.
- Other projects (like `Services` and `AppWebApi`) use `DbRepos` to interact with the data layer.

---

## Why Navigation Properties in DbModels are `[NotMapped]`
- Marking navigation properties as `[NotMapped]` tells Entity Framework not to create foreign key relationships or join tables for these properties. We will create the relationships in the next branch.
