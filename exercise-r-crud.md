# Exercise: Implementing ReadItem Endpoint for Friends

## Objective
Implement the `ReadItem` endpoint in the FriendsController to retrieve a single friend by ID, with optional navigation property population based on the `flat` parameter.

## Background
The `ReadItem` endpoint is currently stubbed out in the FriendsController but lacks the underlying implementation in the service and repository layers. Your task is to complete the implementation chain from the controller down to the database repository.

## Current State
- ✅ Controller endpoint signature exists but is commented out
- ❌ Service interface method missing
- ❌ Service implementation missing  
- ❌ Repository method missing

## Requirements

### 1. Method Signature Requirements
The ReadItem endpoint should:
- Accept a `Guid id` parameter for the friend to retrieve
- Accept a `bool flat` parameter to control navigation property loading
- Return the friend with all details when `flat=false`
- Return the friend with minimal data when `flat=true`

### 2. Navigation Properties
When `flat=false`, include these related entities:
- Address (one-to-one relationship)
- Pets (one-to-many relationship)
- Quotes (one-to-many relationship)  
- CreditCards (one-to-many relationship)

## Implementation Tasks

### Task 1: Update IFriendsService Interface
**File:** `Services/IFriendsService.cs`

Add the following method signature to the interface:
```csharp
public Task<ResponseItemDto<IFriend>> ReadFriendAsync(Guid id, bool flat);
```

**Hint:** Place this method after the existing `ReadFriendsAsync` method.

### Task 2: Implement Service Method
**File:** `Services/FriendsServiceDb.cs`

Implement the `ReadFriendAsync` method:
```csharp
public Task<ResponseItemDto<IFriend>> ReadFriendAsync(Guid id, bool flat) => _repo.ReadFriendAsync(id, flat);
```

**Note:** This follows the same pattern as the existing `ReadFriendsAsync` method - a simple pass-through to the repository layer.

### Task 3: Implement Repository Method
**File:** `DbRepos/FriendsDbRepos.cs`

Implement the `ReadFriendAsync` method with the following logic:

```csharp
public async Task<ResponseItemDto<IFriend>> ReadFriendAsync(Guid id, bool flat)
{
    IQueryable<FriendDbM> query;
    
    if (flat)
    {
        // Create query without navigation properties
        query = _dbContext.Friends.AsNoTracking();
    }
    else
    {
        // Create query with all navigation properties included
        query = _dbContext.Friends.AsNoTracking()
            .Include(i => i.AddressDbM)
            .Include(i => i.PetsDbM)
            .Include(i => i.QuotesDbM)
            .Include(i => i.CreditCardsDbM);
    }

    // Find the friend by ID and return
    var friend = await query.FirstOrDefaultAsync(f => f.FriendId == id);
    return friend;
}
```

### Task 4: Uncomment Controller Code
**File:** `AppWebApi/Controllers/FriendsController.cs`

In the `ReadItem` method, uncomment these lines:
```csharp
var item = await _service.ReadFriendAsync(idArg, flatArg);
if (item == null) throw new ArgumentException ($"Item with id {id} does not exist");
```

And change the return statement from:
```csharp
return Ok();
```
to:
```csharp
return Ok(item);
```

## Testing Your Implementation

### Test 1: Flat Response
**Request:** `GET /api/friends/readitem?id={valid-guid}&flat=true`
**Expected:** Friend object without navigation properties populated

### Test 2: Full Response  
**Request:** `GET /api/friends/readitem?id={valid-guid}&flat=false`
**Expected:** Friend object with all navigation properties (Address, Pets, Quotes, CreditCards) populated

### Test 3: Invalid ID
**Request:** `GET /api/friends/readitem?id={invalid-guid}&flat=false`
**Expected:** 400 Bad Request with error message

### Getting Test Data
To get valid friend IDs for testing:
1. First call `GET /api/friends/read?pageSize=1` to get a friend
2. Copy the `FriendId` from the response
3. Use that ID in your ReadItem tests

## Key Learning Points

### Entity Framework Concepts
- **AsNoTracking():** Improves performance for read-only queries
- **Include():** Eager loading of navigation properties
- **FirstOrDefaultAsync():** Asynchronous single item retrieval

### Architecture Patterns
- **Repository Pattern:** Data access abstraction
- **Service Layer:** Business logic separation
- **Dependency Injection:** Loose coupling between layers

### API Design
- **Query Parameters:** Using optional parameters for behavior control
- **HTTP Status Codes:** Proper error responses (400, 404)
- **Async/Await:** Non-blocking I/O operations

## Troubleshooting

### Common Issues
1. **Null Reference Exception:** Ensure all layers are properly implemented before testing
2. **Missing Navigation Properties:** Verify Include statements match DbModel property names
3. **Invalid GUID Format:** Use proper GUID format in test requests

### Debug Tips
- Check logs for detailed error messages
- Use debugger breakpoints in each layer to trace execution
- Verify database connection and data exists


## File Locations Summary
- **Interface:** `Services/IFriendsService.cs`
- **Service:** `Services/FriendsServiceDb.cs`  
- **Repository:** `DbRepos/FriendsDbRepos.cs`
- **Controller:** `AppWebApi/Controllers/FriendsController.cs`
