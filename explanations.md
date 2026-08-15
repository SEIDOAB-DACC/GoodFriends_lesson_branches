# CRUD Pattern Implementation in GoodFriends Project

## Overview

This document explains how the CRUD (Create, Read, Update, Delete) pattern is implemented in the GoodFriends project, specifically focusing on the layered architecture where Controllers use Services, which in turn use DbRepos (Database Repositories) to manage data access operations. The project demonstrates a clean separation of concerns with DTOs (Data Transfer Objects) managing the Create and Update operations with navigation property handling.

## Architecture Overview

The project follows a 3-layer architecture:

```
Controllers → Services → DbRepos → Database
     ↓           ↓          ↓
   HTTP API → Business → Data Access
```

### Key Components

1. **Controllers** (`AppWebApi/Controllers/`): Handle HTTP requests and responses
2. **Services** (`Services/`): Business logic layer (thin in this project)
3. **DbRepos** (`DbRepos/`): Data access layer with Entity Framework Core
4. **Models** (`Models/`): Domain models and DTOs
5. **DbModels** (`DbModels/`): Entity Framework database models

## CRUD Implementation Details

### Read Operations (R in CRUD)

#### 1. Read Multiple Items (Friends List)
**Flow**: `FriendsController.Read()` → `FriendsServiceDb.ReadFriendsAsync()` → `FriendsDbRepos.ReadFriendsAsync()`

**Controller Endpoint**:
```csharp
[HttpGet()]
[ActionName("Read")]
public async Task<IActionResult> Read(string seeded = "true", string flat = "true",
    string filter = null, string pageNr = "0", string pageSize = "10")
```

**Key Features**:
- **Pagination**: Supports page number and page size
- **Filtering**: Filter by first name or last name
- **Flat vs Deep Loading**: Choice between loading navigation properties or not
- **Seeded Data Toggle**: Filter between seeded and user-created data

**DbRepos Implementation**:
```csharp
public async Task<ResponsePageDto<IFriend>> ReadFriendsAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize)
{
    IQueryable<FriendDbM> query;
    if (flat)
    {
        query = _dbContext.Friends.AsNoTracking();
    }
    else
    {
        query = _dbContext.Friends.AsNoTracking()
            .Include(i => i.AddressDbM)
            .Include(i => i.PetsDbM)
            .Include(i => i.QuotesDbM);
    }
    // ... filtering, paging, and execution
}
```

**Performance Optimizations**:
- Uses `AsNoTracking()` for read-only operations
- Conditional `Include()` statements for navigation properties
- Server-side filtering and paging

#### 2. Read Single Item
**Flow**: `FriendsController.ReadItem()` → `FriendsServiceDb.ReadFriendAsync()` → `FriendsDbRepos.ReadFriendAsync()`

**Navigation Property Loading**:
- **Flat Mode**: Only loads the friend entity
- **Deep Mode**: Loads all related entities (Address, Pets, Quotes)


### Delete Operations (D in CRUD)

#### Simple Delete Process
**Flow**: `FriendsController.DeleteItem()` → `FriendsServiceDb.DeleteFriendAsync()` → `FriendsDbRepos.DeleteFriendAsync()`

**Controller Endpoint**:
```csharp
[HttpDelete("{id}")]
[ActionName("DeleteItem")]
public async Task<IActionResult> DeleteItem(string id)
```

**DbRepos Delete Process**:
```csharp
public async Task<ResponseItemDto<IFriend>> DeleteFriendAsync(Guid id)
{
    // 1. Find the entity
    var item = await _dbContext.Friends
        .Where(i => i.FriendId == id)
        .FirstOrDefaultAsync<FriendDbM>();

    if (item == null) throw new ArgumentException($"Item {id} is not existing");

    // 2. Remove from context
    _dbContext.Friends.Remove(item);

    // 3. Save changes
    await _dbContext.SaveChangesAsync();

    // 4. Return deleted item
    return new ResponseItemDto<IFriend>() { Item = item };
}
```

## Key Design Patterns and Features

### 1. Service Layer Pattern

**Thin Service Layer**:
- Currently acts as a pass-through to repositories
- Designed for future business logic expansion
- Maintains consistent interface contracts
- Enables dependency injection and testability

```csharp
public class FriendsServiceDb : IFriendsService
{
    private readonly FriendsDbRepos _repo;
    
    // Simple 1:1 calls, but expandable for business logic
    public Task<ResponsePageDto<IFriend>> ReadFriendsAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize) 
        => _repo.ReadFriendsAsync(seeded, flat, filter, pageNumber, pageSize);
}
```
