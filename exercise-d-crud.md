# Exercise: Implementing DeleteItem Endpoint for Friends

## Objective
Implement the `DeleteItem` endpoint in the FriendsController to delete a single friend by ID, including proper cascade handling for related entities and returning the deleted friend data.

## Background
The `DeleteItem` endpoint is currently stubbed out in the FriendsController but lacks the underlying implementation in the service and repository layers. Your task is to complete the implementation chain from the controller down to the database repository, handling the deletion of a friend and all associated navigation properties.

## Current State
- ✅ Controller endpoint signature exists but is commented out
- ❌ Service interface method missing
- ❌ Service implementation missing  
- ❌ Repository method missing

## Requirements

### 1. Method Signature Requirements
The DeleteItem endpoint should:
- Accept a `Guid id` parameter for the friend to delete
- Return the deleted friend object (before deletion) for confirmation
- Handle cascade deletion of related entities (Address, Pets, Quotes, CreditCards)
- Return appropriate error responses for non-existent friends

### 2. Deletion Behavior
When deleting a friend:
- **Soft Delete Approach**: Mark as deleted but keep in database (recommended for audit trails)
- **Hard Delete Approach**: Permanently remove from database (we'll implement this)
- **Related Entities**: Entity Framework will handle cascade deletion based on relationship configuration

## Implementation Tasks

### Task 1: Update IFriendsService Interface
**File:** `Services/IFriendsService.cs`

Add the following method signature to the interface:
```csharp
public Task<IFriend> DeleteFriendAsync(Guid id);
```

**Hint:** Place this method after the existing methods in the interface.

### Task 2: Implement Service Method
**File:** `Services/FriendsServiceDb.cs`

Implement the `DeleteFriendAsync` method:
```csharp
public Task<IFriend> DeleteFriendAsync(Guid id) => _repo.DeleteFriendAsync(id);
```

**Note:** This follows the same pattern as existing methods - a simple pass-through to the repository layer.

### Task 3: Implement Repository Method
**File:** `DbRepos/FriendsDbRepos.cs`

Implement the `DeleteFriendAsync` method with the following logic:

```csharp
    public async Task<IFriend> DeleteFriendAsync(Guid id)
    {
        //Find the instance with matching id
        var query1 = _dbContext.Friends
            .Where(i => i.FriendId == id);
        var item = await query1.FirstOrDefaultAsync<FriendDbM>();

        //If the item does not exists
        if (item == null) throw new ArgumentException($"Item {id} is not existing");

        //delete in the database model
        _dbContext.Friends.Remove(item);

        //write to database in a UoW
        await _dbContext.SaveChangesAsync();
        return item;
    }
```

**Important Notes:**
- `SaveChangesAsync()` commits the transaction to the database

### Task 4: Uncomment Controller Code
**File:** `AppWebApi/Controllers/FriendsController.cs`

In the `DeleteItem` method, uncomment and update these lines:
```csharp
var item = await _service.DeleteFriendAsync(idArg);
if (item == null) throw new ArgumentException ($"Item with id {id} does not exist");

_logger.LogInformation($"item {idArg} deleted");
return Ok(item);
```

And remove/comment out the placeholder return:
```csharp
// return Ok();  // Remove this line
```

## Testing Your Implementation

### Test 1: Successful Deletion
**Request:** `DELETE /api/friends/deleteitem/{valid-guid}`
**Expected:** 
- 200 OK status
- Friend object with all navigation properties in response body
- Friend and related data removed from database

### Test 2: Invalid ID (Non-existent Friend)
**Request:** `DELETE /api/friends/deleteitem/{non-existent-guid}`
**Expected:** 
- 400 Bad Request status
- Error message: "Item with id {guid} does not exist"

### Test 3: Invalid GUID Format
**Request:** `DELETE /api/friends/deleteitem/invalid-guid-format`
**Expected:**
- 400 Bad Request status
- GUID parsing error message


## Database Verification
After deletion, verify in the database that:
1. The friend record is removed from the `Friends` table
3. Related Pets records are removed
5. Related CreditCards records are removed

## Key Learning Points

### Entity Framework Concepts
- **Cascade Deletion:** Automatic removal of related entities
- **Include() with Deletion:** Loading navigation properties before deletion
- **Remove() Method:** Marking entity for deletion
- **SaveChangesAsync():** Committing changes to database

### Architecture Patterns
- **Repository Pattern:** Data access encapsulation
- **Service Layer:** Business logic abstraction
- **Return Before Delete:** Providing confirmation data

### API Design Principles
- **HTTP DELETE Verb:** Proper REST verb usage
- **Confirmation Response:** Returning deleted data for verification
- **Error Handling:** Appropriate status codes (400, 404)
- **Logging:** Audit trail for deletion operations

## Advanced Considerations

### Transaction Handling
The current implementation uses Entity Framework's implicit transaction handling. For more complex scenarios, consider explicit transactions:

```csharp
using var transaction = await _dbContext.Database.BeginTransactionAsync();
try
{
    // Deletion logic here
    await _dbContext.SaveChangesAsync();
    await transaction.CommitAsync();
}
catch
{
    await transaction.RollbackAsync();
    throw;
}
```
