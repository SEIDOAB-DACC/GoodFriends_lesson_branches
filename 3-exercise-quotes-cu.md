# Exercise: Implement Create & Update (CU) for `Quote`

This mirrors the exact pattern already used for `Friend`. Work top-down through the layers, mirroring each file 1:1. The real working `Update` code lives in `DbRepos/FriendsDbRepos.cs`, and the intended `Create` design is documented in `explanations.md` (Friends doesn't have `Create` implemented in this branch — you'll write it for `Quote` by following that spec).

Key difference to note before you start: `Quote` ↔ `Friend` is a **many-to-many** relationship (both `QuoteDbM.FriendsDbM` and `FriendDbM.QuotesDbM` are collections, so EF Core configures a join table by convention — there's no FK column on either entity). This is structurally the same shape as the `PetsId`/`QuotesId` lists already used inside `FriendCuDto`, so `QuoteCuDto` should hold a `FriendsId` list the same way.

## Step 1 — Add `QuoteCuDto` (Models/DTO/CuDto.cs)

**Purpose:** the API must never accept or return the full `Quote` domain model for writes — that would expose navigation objects and invite over-posting. A dedicated CU DTO exposes only the fields a client is allowed to set, with the many-to-many relationship flattened to a list of ids (`FriendsId`) instead of full `Friend` objects.

Add a new class next to `FriendCuDto` in the same file:

```csharp
public class QuoteCuDto
{
    public virtual Guid? QuoteId { get; set; }   // null on create, must match route id on update

    public virtual string QuoteText { get; set; }
    public virtual string Author { get; set; }

    public virtual List<Guid> FriendsId { get; set; } = null;

    public QuoteCuDto() { }
    public QuoteCuDto(IQuote org)
    {
        // TODO: map scalar fields + org.Friends -> FriendsId (mirror FriendCuDto's constructor)
    }
}
```

## Step 2 — Add `UpdateFromDTO` to `QuoteDbM` (DbModels/QuoteDbM.cs)

**Purpose:** centralizes the DTO → entity scalar-property mapping in one place so both `Create` and `Update` in the repo layer can reuse it instead of duplicating assignment code.

Mirror `FriendDbM.UpdateFromDTO`:

```csharp
public QuoteDbM UpdateFromDTO(QuoteCuDto org)
{
    // TODO: assign QuoteText, Author
    return this;
}
```

## Step 3 — Add a single-item read to `QuotesDbRepos` (DbRepos/QuotesDbRepos.cs)

**Purpose:** after a create/update writes to the database, the caller expects the fully populated, up-to-date item back (with its related friends included) rather than the raw DTO it sent in. A reusable single-item read gives `Create`/`Update` (and later a `ReadItem` controller action) one consistent way to fetch that.

`QuotesDbRepos` currently only has the paged `ReadQuotesAsync`. Add a single-item version, mirroring `ReadFriendAsync`:

```csharp
public async Task<ResponseItemDto<IQuote>> ReadQuoteAsync(Guid id, bool flat)
{
    // TODO: mirror ReadFriendAsync — query _dbContext.Quotes.AsNoTracking(),
    // .Include(i => i.FriendsDbM) when !flat, filter by QuoteId, throw ArgumentException if not found,
    // wrap in ResponseItemDto<IQuote>
}
```

## Step 4 — Add `CreateQuoteAsync` to `QuotesDbRepos`

**Purpose:** this is the actual "C" in CRUD — turning a validated DTO into a new row (plus join-table rows for any `FriendsId` supplied). The guard clause enforces that clients can't dictate an existing id.

Follow the documented pattern from `explanations.md`:

```csharp
public async Task<ResponseItemDto<IQuote>> CreateQuoteAsync(QuoteCuDto itemDto)
{
    // 1. Guard: QuoteId must be null when creating
    if (itemDto.QuoteId != null) throw new ArgumentException($"{nameof(itemDto.QuoteId)} must be null when creating a new object");

    // 2. Create a new QuoteDbM and populate scalar props (new QuoteDbM().UpdateFromDTO(itemDto))
    //    (QuoteId is DB-generated — do not set it manually)

    // 3. Populate the FriendsDbM navigation list (Step 6 helper)

    // 4. _dbContext.Quotes.Add(item); await _dbContext.SaveChangesAsync();

    // 5. return await ReadQuoteAsync(item.QuoteId, false);
}
```

## Step 5 — Add `UpdateQuoteAsync` to `QuotesDbRepos`

**Purpose:** this is the "U" in CRUD — loading the tracked entity (with its related friends included), applying the incoming scalar and relationship changes, then persisting them in a single unit of work. EF Core will diff the incoming `FriendsDbM` list against the join table and add/remove rows as needed.

Mirror the real, working `UpdateFriendAsync`:

```csharp
public async Task<ResponseItemDto<IQuote>> UpdateQuoteAsync(QuoteCuDto itemDto)
{
    // 1. Find existing QuoteDbM by itemDto.QuoteId, .Include(i => i.FriendsDbM)
    // 2. throw ArgumentException if not found
    // 3. item.UpdateFromDTO(itemDto)
    // 4. update the FriendsDbM navigation list (Step 6 helper)
    // 5. _dbContext.Quotes.Update(item); await _dbContext.SaveChangesAsync();
    // 6. return await ReadQuoteAsync(item.QuoteId, false);
}
```

## Step 6 — Navigation property helper

**Purpose:** converts the flat `FriendsId` list on the DTO into actual tracked `FriendDbM` entities EF Core can wire up as the many-to-many relationship. Validating that every id exists before attaching it prevents silently creating dangling/incorrect relationships. Sharing one helper between `Create` and `Update` avoids duplicating this lookup logic.

```csharp
private async Task navProp_QuoteCuDto_to_QuoteDbM(QuoteCuDto itemDtoSrc, QuoteDbM itemDst)
{
    // if itemDtoSrc.FriendsId != null: look up each FriendDbM by id (throw if missing), build List<FriendDbM>
    // else: set itemDst.FriendsDbM = null
}
```

Call this helper from both `CreateQuoteAsync` and `UpdateQuoteAsync`, just like Friends does.

## Step 7 — Extend `IQuotesService` and `QuotesServiceDb`

**Purpose:** the controller depends on the `IQuotesService` abstraction, not on `QuotesDbRepos` directly, so the new repo methods must be exposed through the service interface and its implementation before a controller can call them.

`Services/IQuotesService.cs`:
```csharp
public Task<ResponseItemDto<IQuote>> ReadQuoteAsync(Guid id, bool flat);
public Task<ResponseItemDto<IQuote>> CreateQuoteAsync(QuoteCuDto item);
public Task<ResponseItemDto<IQuote>> UpdateQuoteAsync(QuoteCuDto item);
```

`Services/QuotesServiceDb.cs` — thin 1:1 pass-throughs, matching the existing style:
```csharp
public Task<ResponseItemDto<IQuote>> ReadQuoteAsync(Guid id, bool flat) => _repo.ReadQuoteAsync(id, flat);
public Task<ResponseItemDto<IQuote>> CreateQuoteAsync(QuoteCuDto item) => _repo.CreateQuoteAsync(item);
public Task<ResponseItemDto<IQuote>> UpdateQuoteAsync(QuoteCuDto item) => _repo.UpdateQuoteAsync(item);
```

## Step 8 — Extend `QuotesController`

**Purpose:** exposes the new service methods as HTTP endpoints — `POST` for create and `PUT {id}` for update — and adds the `ReadItem`/`ReadItemDto` actions needed to fetch a single quote (and its CU-DTO shape) for testing.

```csharp
[HttpGet()]
[ActionName("ReadItem")]
public async Task<IActionResult> ReadItem(string id = null, string flat = "false") { /* mirror FriendsController */ }

[HttpGet()]
[ActionName("ReadItemDto")]
public async Task<IActionResult> ReadItemDto(string id = null) { /* return new QuoteCuDto(item.Item) */ }

[HttpPost()]
[ActionName("CreateItem")]
public async Task<IActionResult> CreateItem([FromBody] QuoteCuDto item) { /* call _service.CreateQuoteAsync(item) */ }

[HttpPut("{id}")]
[ActionName("UpdateItem")]
public async Task<IActionResult> UpdateItem(string id, [FromBody] QuoteCuDto item)
{
    // Guid.Parse(id), verify item.QuoteId == idArg, call _service.UpdateQuoteAsync(item)
}
```

## Step 9 — Verify

**Purpose:** confirms the full round trip works end-to-end and that the guard clauses actually reject bad input, not just that the code compiles.

1. Build the solution (`dotnet build`).
2. Run and open Swagger:
   - `GET api/Friends/Read` → grab a couple of `FriendId`s.
   - `POST api/Quotes/CreateItem` with `QuoteId: null`, a valid `QuoteText`/`Author`, and a `FriendsId` list → confirm a new `QuoteId` is returned and the quote appears under those friends.
   - `PUT api/Quotes/UpdateItem/{id}` with matching `QuoteId` and a changed `FriendsId` list → confirm the relationship set changes (added/removed friends).
   - Try `CreateItem` with a non-null `QuoteId` → should return 400 (guard clause).
   - Try assigning a bogus `FriendId` in `FriendsId` → should return 400 (navigation lookup guard).

Once this passes, you've reproduced the `17-cu-in-crud` pattern for `Quote`.
