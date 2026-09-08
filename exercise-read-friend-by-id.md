# Exercise: Read a Specific Friend by Id

## 🎯 Goal

Add a new endpoint to the Web API that returns the **details of a single friend**, identified by its `FriendId` (a `Guid`).

The existing `Read` endpoint returns *all* friends. In this exercise you will add a new endpoint, e.g. `ReadItem`, that returns exactly **one** friend.

After completing the exercise, the following HTTP call should work:

```http
GET /api/friends/ReadItem?id=<a-friend-guid>
```

and return a `ResponseItemDto<IFriend>` in the response body.

---

## 📐 Architecture Recap

The change touches **every layer** of the N-tier architecture. Follow the layers from the **inside out** (database → API), so each layer you build on top of already compiles.

| Order | Layer         | Project          | What you add |
|-------|---------------|------------------|--------------|
| 1     | Repository    | `DbRepos`        | `ReadFriendAsync(Guid id)` |
| 2     | Service (abstraction) | `Services` | `ReadFriendAsync(Guid id)` in `IFriendsService` |
| 3     | Service (impl)| `Services`       | `ReadFriendAsync(Guid id)` in `FriendsServiceDb` |
| 4     | Controller    | `AppWebApi`      | `ReadItem(Guid id)` action in `FriendsController` |

The DTO type you will return is already defined in [Models/DTO/ResponseDto.cs](Models/DTO/ResponseDto.cs):

```csharp
public class ResponseItemDto<T>
{
#if DEBUG
    public string ConnectionString { get; init; }
#endif
    public T Item { get; init; }
}
```

---

## 🧪 Prerequisites

- The solution builds and runs (`dotnet build GoodFriends.slnx`).
- You have seeded the database at least once via the `Admin/Seed` endpoint so there is data to query.
- You have a valid `FriendId` at hand — call `GET /api/friends/Read` first and copy any `friendId` from the JSON response.

---

## 🪜 Step-by-Step Instructions

### Step 1 — Add the repository method

📄 File: [DbRepos/FriendsDbRepos.cs](DbRepos/FriendsDbRepos.cs)

Add a new method next to `ReadFriendsAsync`:

```csharp
public async Task<ResponseItemDto<IFriend>> ReadFriendAsync(Guid id)
{
    IQueryable<FriendDbM> query = _dbContext.Friends
        .AsNoTracking()
        .Where(f => f.FriendId == id);

    var item = await query.FirstOrDefaultAsync<IFriend>();

    return new ResponseItemDto<IFriend>
    {
#if DEBUG
        ConnectionString = _dbContext.dbConnection,
#endif
        Item = item,
    };
}
```

Points to notice:

- `AsNoTracking()` — same read-only optimisation used by `ReadFriendsAsync`.
- `.Where(...)` filters on the primary key.
- `FirstOrDefaultAsync<IFriend>()` returns `null` when no friend matches. You may decide later how to signal "not found" to the client.

---

### Step 2 — Extend the service interface

📄 File: [Services/IFriendsService.cs](Services/IFriendsService.cs)

Add the new method signature:

```csharp
public interface IFriendsService
{
    public Task<ResponsePageDto<IFriend>> ReadFriendsAsync();

    // NEW
    public Task<ResponseItemDto<IFriend>> ReadFriendAsync(Guid id);
}
```

---

### Step 3 — Implement it in the service

📄 File: [Services/FriendsServiceDb.cs](Services/FriendsServiceDb.cs)

The service is currently a thin pass-through to the repository. Keep the same pattern:

```csharp
public Task<ResponsePageDto<IFriend>> ReadFriendsAsync() => _repo.ReadFriendsAsync();

// NEW
public Task<ResponseItemDto<IFriend>> ReadFriendAsync(Guid id) => _repo.ReadFriendAsync(id);
```

---

### Step 4 — Add the controller action

📄 File: [AppWebApi/Controllers/FriendsController.cs](AppWebApi/Controllers/FriendsController.cs)

Add a new action next to `Read`:

```csharp
[HttpGet()]
[ActionName("ReadItem")]
[ProducesResponseType(200, Type = typeof(ResponseItemDto<IFriend>))]
[ProducesResponseType(400, Type = typeof(string))]
[ProducesResponseType(404, Type = typeof(string))]
public async Task<IActionResult> ReadItem(Guid id)
{
    try
    {
        _logger.LogInformation($"{nameof(ReadItem)}: {id}");
        var resp = await _service.ReadFriendAsync(id);

        if (resp.Item is null)
            return NotFound($"No friend found with id {id}");

        return Ok(resp);
    }
    catch (Exception ex)
    {
        _logger.LogError($"{nameof(ReadItem)}: {ex.Message}");
        return BadRequest(ex.Message);
    }
}
```

Points to notice:

- `[ActionName("ReadItem")]` combined with `[Route("api/[controller]/[action]")]` (declared on the class) gives the URL `api/friends/ReadItem`.
- `Guid id` is bound from the query string automatically (`?id=...`).
- Three response types are documented for Swagger: `200`, `400`, `404`.

---

## ✅ Verify Your Work

1. Build the solution:

    ```sh
    dotnet build GoodFriends.slnx
    ```

2. Run the Web API (F5 in VS Code, or `dotnet run --project AppWebApi`).

3. Open Swagger UI in your browser and locate the new `Friends / ReadItem` operation.

4. First, call `GET /api/friends/Read` and copy any `friendId` value.

5. Then call `GET /api/friends/ReadItem?id=<that-guid>` and confirm you get a `200 OK` with a single friend in the `item` property.

6. Try an unknown Guid, e.g. `00000000-0000-0000-0000-000000000000`, and confirm the API returns `404 Not Found`.

---

## 🚀 Stretch Goals (Optional)

Once the basic endpoint works, try one or more of the following:

1. **Include navigation properties.** Extend `ReadFriendAsync` in the repository to also load the friend's `Address`, `Pets`, and `Quotes` using `.Include(...)` / `.ThenInclude(...)`. Compare the JSON payload before and after.
2. **Route-based id.** Change the action to use a route parameter: `[HttpGet("{id:guid}")]`, so the URL becomes `api/friends/ReadItem/<guid>`. Test it in Swagger.
3. **Case for `null` in the service layer.** Move the "not found" decision from the controller into the service and let the service throw a custom exception (e.g. `KeyNotFoundException`). Catch it in the controller and translate to `404`.
4. **Repeat for another entity.** Apply the exact same four-step pattern to `Pets`, `Addresses`, or `Quotes`.

---

## 🧠 What You Practised

- Adding a feature that crosses **all N-tier layers** in the correct order.
- Reusing the existing DTO (`ResponseItemDto<T>`) instead of inventing a new one.
- Writing a filtered EF Core query with `AsNoTracking()` and `FirstOrDefaultAsync`.
- Translating a `null` result into a proper `404 Not Found` HTTP response.
- Documenting response types for Swagger with `[ProducesResponseType]`.
