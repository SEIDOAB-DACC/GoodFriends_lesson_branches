# DbRepos Project - ReadAsync Methods Explanation

## Overview

The DbRepos project contains repository classes that handle data access operations for the GoodFriends application. Each repository class implements a `ReadAsync` method that provides paginated, filtered, and optionally hierarchical data retrieval functionality.

## Common Pattern

All `ReadAsync` methods in the DbRepos project follow a consistent pattern:

- **Asynchronous operation** using `async/await`
- **Pagination support** with `pageNumber` and `pageSize` parameters
- **Filtering capability** with a `filter` string parameter
- **Flat vs. Hierarchical data** controlled by the `flat` boolean parameter
- **Seeded vs. Non-seeded data** filtering with the `seeded` boolean parameter
- **Return type**: `ResponsePageDto<T>` containing paginated results and metadata

## Method Signature Pattern

```csharp
public async Task<ResponsePageDto<T>> ReadAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize)
```

### Parameters:
- `seeded`: Filter for seeded (test/sample) vs non-seeded (user-created) data
- `flat`: When `true`, returns only the main entity without related data; when `false`, includes related entities via EF Core `Include()`
- `filter`: String used for case-insensitive filtering on relevant text fields
- `pageNumber`: Zero-based page number for pagination
- `pageSize`: Number of items per page

## Individual Repository Methods

### 1. AddressesDbRepos.ReadAddressesAsync

**Purpose**: Retrieves addresses with optional related friends, pets, and quotes data.

**Query Strategy**:
- **Flat mode**: Returns only address data using `_dbContext.Addresses.AsNoTracking()`
- **Hierarchical mode**: Includes related friends and their associated pets and quotes using:
  ```csharp
  .Include(i => i.FriendsDbM)
  .ThenInclude(i => i.PetsDbM)
  .Include(i => i.FriendsDbM)
  .ThenInclude(i => i.QuotesDbM)
  ```

**Filter Fields**: 
- `StreetAddress` (case-insensitive contains)
- `City` (case-insensitive contains)  
- `Country` (case-insensitive contains)

**Key Features**:
- Uses `AsNoTracking()` for read-only operations (performance optimization)
- Executes two separate queries: one for count, one for paginated data
- Returns `ResponsePageDto<IAddress>` with pagination metadata

---

### 2. FriendsDbRepos.ReadFriendsAsync

**Purpose**: Retrieves friends with optional related address, pets, quotes, and credit cards data.

**Query Strategy**:
- **Flat mode**: Returns only friend data using `_dbContext.Friends.AsNoTracking()`
- **Hierarchical mode**: Includes all related entities:
  ```csharp
  .Include(i => i.AddressDbM)
  .Include(i => i.PetsDbM)
  .Include(i => i.QuotesDbM)
  .Include(i => i.CreditCardsDbM)
  ```

**Filter Fields**:
- `FirstName` (case-insensitive contains)
- `LastName` (case-insensitive contains)

**Key Features**:
- Most comprehensive entity with relationships to all other main entities
- Central entity in the domain model (friends have addresses, pets, quotes, and credit cards)
- Returns `ResponsePageDto<IFriend>` with pagination metadata

---

### 3. PetsDbRepos.ReadPetsAsync

**Purpose**: Retrieves pets with optional related friend, address, and quotes data.

**Query Strategy**:
- **Flat mode**: Returns only pet data using `_dbContext.Pets.AsNoTracking()`
- **Hierarchical mode**: Includes friend and friend's related data:
  ```csharp
  .Include(i => i.FriendDbM)
  .ThenInclude(i => i.AddressDbM)
  .Include(i => i.FriendDbM)
  .ThenInclude(i => i.QuotesDbM)
  ```

**Filter Fields**:
- `Name` (case-insensitive contains)

**Key Features**:
- Accesses friend's related data through the pet-friend relationship
- Uses `ThenInclude()` to navigate through the friend to reach address and quotes
- Returns `ResponsePageDto<IPet>` with pagination metadata

---

### 4. QuotesDbRepos.ReadQuotesAsync

**Purpose**: Retrieves quotes with optional related friends, pets, and addresses data.

**Query Strategy**:
- **Flat mode**: Returns only quote data using `_dbContext.Quotes.AsNoTracking()`
- **Hierarchical mode**: Includes related friends and their associated data:
  ```csharp
  .Include(i => i.FriendsDbM)
  .ThenInclude(i => i.PetsDbM)
  .Include(i => i.FriendsDbM)
  .ThenInclude(i => i.AddressDbM)
  ```

**Filter Fields**:
- `QuoteText` (case-insensitive contains)
- `Author` (case-insensitive contains)

**Key Features**:
- Quotes can be associated with multiple friends (many-to-many relationship)
- Accesses friends' related data through the quote-friends relationship
- Returns `ResponsePageDto<IQuote>` with pagination metadata

## ResponsePageDto Structure

All methods return a `ResponsePageDto<T>` object containing:

```csharp
public class ResponsePageDto<T>
{
    public List<T> PageItems { get; init; }        // Current page items
    public int DbItemsCount { get; init; }         // Total items in database (after filtering)
    public int PageNr { get; init; }               // Current page number
    public int PageSize { get; init; }             // Items per page
    public int PageCount => ...;                   // Calculated total pages
    
#if DEBUG
    public string ConnectionString { get; init; }  // Debug info only
#endif
}
```

## Performance Considerations

1. **AsNoTracking()**: Used in all queries for read-only operations, improving performance by not tracking entity changes
2. **Separate Count Query**: Total count is calculated separately from the paginated data query
3. **Eager Loading**: `Include()` and `ThenInclude()` are used strategically to load related data in a single query when `flat = false`
4. **Pagination**: `Skip()` and `Take()` are used to implement server-side pagination, reducing memory usage

## Usage Pattern

These methods are typically called from the corresponding service layer classes:
- `AddressesServiceDb.ReadAddressesAsync()`
- `FriendsServiceDb.ReadFriendsAsync()`
- `PetsServiceDb.ReadPetsAsync()`
- `QuotesServiceDb.ReadQuotesAsync()`

The service layer then exposes these to the API controllers, which handle HTTP requests and parameter validation.

## Entity Relationships

The GoodFriends domain model has the following key relationships:
- **Friend** is the central entity
- **Address** → **Friends** (one-to-many)
- **Friend** → **Pets** (one-to-many)
- **Friend** → **CreditCards** (one-to-many)
- **Friends** ↔ **Quotes** (many-to-many)

This relationship structure is reflected in the Include strategies used by each repository method.

## MainDbContext.OnModelCreating

The `OnModelCreating` method in `MainDbContext` is a crucial part of Entity Framework Core's Code First approach. This method allows developers to customize the database model configuration using the Fluent API, providing fine-grained control over how entities are mapped to database tables and relationships.

### Purpose and Role

The `OnModelCreating` method is called during the model building process and serves several key purposes:

1. **Override Conventions**: Customize EF Core's default mapping conventions
2. **Configure Relationships**: Define complex relationships between entities
3. **Set Constraints**: Add database-level constraints and validations
4. **Database-Specific Customizations**: Handle database provider-specific configurations

### Main Configuration in MainDbContext

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Pet entity configuration
    modelBuilder.Entity("DbModels.PetDbM", b =>
    {
        b.HasOne("DbModels.FriendDbM", "FriendDbM")
            .WithMany("PetsDbM")
            .HasForeignKey("FriendId")
            .OnDelete(DeleteBehavior.Cascade);

        b.Navigation("FriendDbM");
        
        // Check constraint to enforce specific pet names
        b.ToTable(t => t.HasCheckConstraint("CK_PetDbM_Name", "\"Name\" IN ('Max', 'Charlie')"));
    });
    
    // Friend entity configuration
    modelBuilder.Entity("DbModels.FriendDbM", b =>
    {
        b.HasOne("DbModels.AddressDbM", "AddressDbM")
            .WithMany("FriendsDbM")
            .HasForeignKey("AddressId")
            .OnDelete(DeleteBehavior.SetNull);

        b.Navigation("AddressDbM");
    });
    
    base.OnModelCreating(modelBuilder);
}
```

### Key Configurations Explained

#### 1. Pet-Friend Relationship
- **Relationship Type**: One-to-Many (Friend → Pets)
- **Foreign Key**: `FriendId` in `PetDbM` table
- **Delete Behavior**: `Cascade` - When a friend is deleted, all their pets are automatically deleted
- **Business Logic**: Pets cannot exist without an owner (friend)

#### 2. Friend-Address Relationship  
- **Relationship Type**: Many-to-One (Friends → Address)
- **Foreign Key**: `AddressId` in `FriendDbM` table (nullable)
- **Delete Behavior**: `SetNull` - When an address is deleted, friends' `AddressId` is set to null
- **Business Logic**: Friends can exist without an address, but multiple friends can share the same address

#### 3. Check Constraint on Pet Names
- **Purpose**: Enforces business rule that pets can only be named 'Max' or 'Charlie'
- **Implementation**: Database-level check constraint
- **Note**: Uses quoted column names for PostgreSQL case-sensitivity compatibility

### Database-Specific Implementations

The project uses inheritance to provide database-specific configurations:

#### SqlServerDbContext
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Configure CreditCard EncryptedToken for SQL Server
    modelBuilder.Entity<CreditCardDbM>()
        .Property(a => a.EncryptedToken).HasColumnType("nvarchar(max)");
    
    base.OnModelCreating(modelBuilder);
}
```

#### MySqlDbContext  
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Configure CreditCard EncryptedToken for MySQL
    modelBuilder.Entity<CreditCardDbM>()
        .Property(a => a.EncryptedToken).HasColumnType("longtext");
    
    base.OnModelCreating(modelBuilder);
}
```

#### PostgresDbContext
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Configure CreditCard EncryptedToken for PostgreSQL
    modelBuilder.Entity<CreditCardDbM>()
        .Property(a => a.EncryptedToken).HasColumnType("text");
    
    base.OnModelCreating(modelBuilder);
}
```

### Additional Entity Attributes

The model also uses Data Annotations for simpler configurations:

- **Table Mapping**: `[Table("TableName", Schema = "schemaName")]`
- **Indexes**: `[Index(nameof(Property1), nameof(Property2), IsUnique = true)]`
- **Keys**: `[Key]` for primary keys
- **Foreign Keys**: `[ForeignKey("PropertyName")]`
- **Required Fields**: `[Required]`
- **Navigation Properties**: `[NotMapped]` for interface-based properties

### Impact on ReadAsync Methods

The `OnModelCreating` configurations directly impact how the repository `ReadAsync` methods work:

1. **Cascade Deletes**: Ensure data integrity when pets are included with friends
2. **SetNull Behavior**: Allows friends to be loaded even when their address is deleted
3. **Navigation Properties**: Enable the `Include()` and `ThenInclude()` operations
4. **Check Constraints**: Ensure data quality when filtering or displaying pets

### Best Practices Demonstrated

1. **Separation of Concerns**: Base configurations in `MainDbContext`, database-specific in derived classes
2. **Explicit Relationships**: Clearly defined foreign key relationships and delete behaviors
3. **Data Integrity**: Check constraints enforce business rules at the database level
4. **Cross-Database Compatibility**: Different column types for different database providers
5. **Interface Navigation**: Proper handling of interface-based navigation properties using `[NotMapped]`

This configuration ensures that the repository methods can safely perform complex queries with includes while maintaining referential integrity and supporting multiple database providers.
