# Exercise: Implement Create & Update (CU) for `Pet`

This mirrors the exact pattern already used for `Friend`. Work top-down through the layers, mirroring each file 1:1. The real working `Update` code lives in `DbRepos/FriendsDbRepos.cs`, and the intended `Create` design is documented in `explanations.md` (Friends doesn't have `Create` implemented in this branch — you'll write it for `Pet` by following that spec).

Key difference to note before you start: unlike `Address`/`Friend`, the FK for `Pet` → `Friend` is **required and non-nullable** (`PetDbM.FriendId` is `Guid`, not `Guid?`, configured with `OnDelete(DeleteBehavior.Cascade)` in `MainDbContext`). A `Pet` cannot exist without an owning `Friend`, so `FriendId` on the DTO must always be supplied — there's no "clear the relationship" case like `AddressId` had for Friends.

## Step 1 — Add `PetCuDto` (Models/DTO/CuDto.cs)

**Purpose:** the API must never accept or return the full `Pet` domain model for writes — that would expose the navigation object and invite over-posting. A dedicated CU DTO exposes only the fields a client is allowed to set, with the owning relationship flattened to a plain id (`FriendId`) instead of a full `Friend` object.

Add a new class next to `FriendCuDto` in the same file:

```csharp
public class PetCuDto
{
    public virtual Guid? PetId { get; set; }   // null on create, must match route id on update

    public virtual string Name { get; set; }
    public virtual AnimalKind? Kind { get; set; }
    public virtual AnimalMood? Mood { get; set; }

    public virtual Guid FriendId { get; set; }  // required — a Pet must always have an owner

    public PetCuDto() { }
    public PetCuDto(IPet org)
    {
        // TODO: map scalar fields + org.Friend.FriendId -> FriendId (mirror FriendCuDto's constructor)
    }
}
```

## Step 2 — Add `UpdateFromDTO` to `PetDbM` (DbModels/PetDbM.cs)

**Purpose:** centralizes the DTO → entity scalar-property mapping in one place so both `Create` and `Update` in the repo layer can reuse it instead of duplicating assignment code.

Mirror `FriendDbM.UpdateFromDTO`:

```csharp
public PetDbM UpdateFromDTO(PetCuDto org)
{
    // TODO: assign Name, Kind, Mood
    return this;
}
```

## Step 3 — Add a single-item read to `PetsDbRepos` (DbRepos/PetsDbRepos.cs)

**Purpose:** after a create/update writes to the database, the caller expects the fully populated, up-to-date item back (with navigation properties included) rather than the raw DTO it sent in. A reusable single-item read gives `Create`/`Update` (and later a `ReadItem` controller action) one consistent way to fetch that.

`PetsDbRepos` currently only has the paged `ReadPetsAsync`. Both `Create` and `Update` need to return a single populated item afterward, exactly like `ReadFriendAsync` does for Friends — so add it first:

```csharp
public async Task<ResponseItemDto<IPet>> ReadPetAsync(Guid id, bool flat)
{
    // TODO: mirror ReadFriendAsync — query _dbContext.Pets.AsNoTracking(),
    // .Include(i => i.FriendDbM) when !flat, filter by PetId, throw ArgumentException if not found,
    // wrap in ResponseItemDto<IPet>
}
```

## Step 4 — Extend `IPetsService` and `PetsServiceDb`

**Purpose:** the controller depends on the `IPetsService` abstraction, not on `PetsDbRepos` directly, so the new repo methods must be exposed through the service interface and its implementation before a controller can call them. Keeping these calls 1:1 pass-throughs matches how thin this service layer is elsewhere in the project.

`Services/IPetsService.cs`:
```csharp
public Task<ResponseItemDto<IPet>> ReadPetAsync(Guid id, bool flat);
```

`Services/PetsServiceDb.cs` — add the same thin 1:1 pass-through calls used for Friends:
```csharp
public Task<ResponseItemDto<IPet>> ReadPetAsync(Guid id, bool flat) => _repo.ReadPetAsync(id, flat);
```

## Step 5 — Extend `PetsController`

**Purpose:** exposes the new service methods as HTTP endpoints — `POST` for create and `PUT {id}` for update, following standard REST conventions — and adds the `ReadItem`/`ReadItemDto` actions needed to fetch a single pet (and its CU-DTO shape) for testing and for client edit forms.

Mirror `FriendsController`'s `ReadItem`, `ReadItemDto`, `UpdateItem` and add a `CreateItem`:

```csharp
[HttpGet()]
[ActionName("ReadItem")]
public async Task<IActionResult> ReadItem(string id = null, string flat = "false") { /* mirror FriendsController */ }

[HttpGet()]
[ActionName("ReadItemDto")]
public async Task<IActionResult> ReadItemDto(string id = null) { /* return new PetCuDto(item.Item) */ }
```

## Step 6 — Add `UpdatePetAsync` to `PetsDbRepos`

**Purpose:** this is the "U" in CRUD — loading the tracked entity (with its owner included), applying the incoming scalar and relationship changes, then persisting them in a single unit of work.

Mirror the real, working `UpdateFriendAsync` exactly:

```csharp
public async Task<ResponseItemDto<IPet>> UpdatePetAsync(PetCuDto itemDto)
{
    // 1. Find existing PetDbM by itemDto.PetId, .Include(i => i.FriendDbM)
    // 2. throw ArgumentException if not found
    // 3. item.UpdateFromDTO(itemDto)
    // 4. reassign the owning Friend if FriendId changed (AFTER Step 10 — Navigation property helper)
    // 5. _dbContext.Pets.Update(item); await _dbContext.SaveChangesAsync();
    // 6. return await ReadPetAsync(item.PetId, false);
}
```

## Step 7 — Add `CreatePetAsync` to `PetsDbRepos`

**Purpose:** this is the actual "C" in CRUD — turning a validated DTO into a new row. The guard clause enforces that clients can't dictate an existing id (that would blur the line between create and update), and — because the owner FK is required — the create must also validate the referenced `Friend` actually exists before saving (otherwise EF Core will throw a less helpful DB-level error).

Follow the documented pattern from `explanations.md`, adapted for a single required relationship instead of `AddressId`:

```csharp
public async Task<ResponseItemDto<IPet>> CreatePetAsync(PetCuDto itemDto)
{
    // 1. Guard: PetId must be null when creating
    if (itemDto.PetId != null) throw new ArgumentException($"{nameof(itemDto.PetId)} must be null when creating a new object");

    // 2. Create a new PetDbM and populate scalar props (new PetDbM(){PetId = Guid.NewGuid()}.UpdateFromDTO(itemDto))

    // 3. Resolve and assign the owning Friend (DO STEP 10 NOW — Navigation property helper) — required, so missing/invalid FriendId must throw

    // 4. _dbContext.Pets.Add(item); await _dbContext.SaveChangesAsync();

    // 5. return await ReadPetAsync(item.PetId, false);
}
```

## Step 8 — Extend `IPetsService` and `PetsServiceDb`

**Purpose:** the controller depends on the `IPetsService` abstraction, not on `PetsDbRepos` directly, so the new repo methods must be exposed through the service interface and its implementation before a controller can call them. Keeping these calls 1:1 pass-throughs matches how thin this service layer is elsewhere in the project.

`Services/IPetsService.cs`:
```csharp
public Task<ResponseItemDto<IPet>> CreatePetAsync(PetCuDto item);
public Task<ResponseItemDto<IPet>> UpdatePetAsync(PetCuDto item);
```

`Services/PetsServiceDb.cs` — add the same thin 1:1 pass-through calls used for Friends:
```csharp
public Task<ResponseItemDto<IPet>> CreatePetAsync(PetCuDto item) => _repo.CreatePetAsync(item);
public Task<ResponseItemDto<IPet>> UpdatePetAsync(PetCuDto item) => _repo.UpdatePetAsync(item);
```

## Step 9 — Extend `PetsController`

**Purpose:** exposes the new service methods as HTTP endpoints — `POST` for create and `PUT {id}` for update, following standard REST conventions — and adds the `ReadItem`/`ReadItemDto` actions needed to fetch a single pet (and its CU-DTO shape) for testing and for client edit forms.

Mirror `FriendsController`'s `ReadItem`, `ReadItemDto`, `UpdateItem` and add a `CreateItem`:

```csharp
[HttpPost()]
[ActionName("CreateItem")]
public async Task<IActionResult> CreateItem([FromBody] PetCuDto item) { /* call _service.CreatePetAsync(item) */ }

[HttpPut("{id}")]
[ActionName("UpdateItem")]
public async Task<IActionResult> UpdateItem(string id, [FromBody] PetCuDto item)
{
    // Guid.Parse(id), verify item.PetId == idArg, call _service.UpdatePetAsync(item)
}
```

## Step 10 — Navigation property helper

**Purpose:** resolves the flat `FriendId` into an actual tracked `FriendDbM` entity EF Core can wire up as the owning relationship. Because the FK is required, this helper has no "set to null" branch like Address's — a missing or invalid `FriendId` must always throw.

Add a private helper analogous to `navProp_FriendCUdto_to_FriendDbM`, but for the single required `FriendId`:

```csharp
private async Task navProp_PetCuDto_to_PetDbM(PetCuDto itemDtoSrc, PetDbM itemDst)
{
    // look up FriendDbM by itemDtoSrc.FriendId, throw ArgumentException if not found
    // itemDst.FriendDbM = <the found friend>
}
```

Revisit Step 6 and 7 and call this helper from both `CreatePetAsync` and `UpdatePetAsync`, just like Friends does.

## Step 11 — Verify

**Purpose:** confirms the full round trip works end-to-end and that the guard clauses actually reject bad input, not just that the code compiles.

1. Build the solution (`dotnet build`).
2. Run and open Swagger:
   - `GET api/Friends/Read` → grab an existing `FriendId` to use as the owner.
   - `POST api/Pets/CreateItem` with `PetId: null`, a valid `Name`/`Kind`/`Mood`, and that `FriendId` → confirm a new `PetId` is returned and the pet appears under that friend.
   - `PUT api/Pets/UpdateItem/{id}` with matching `PetId` → confirm scalar fields update.
   - Try `CreateItem` with a non-null `PetId` → should return 400 (guard clause).
   - Try `CreateItem` with a random, non-existing `FriendId` → should return 400 (owner lookup guard), not a raw DB error.

Once this passes, you've reproduced the `17-cu-in-crud` pattern for `Pet`.
