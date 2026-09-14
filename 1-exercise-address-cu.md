# Exercise: Implement Create & Update (CU) for `Address`

This mirrors the exact pattern already used for `Friend`. Work top-down through the layers, mirroring each file 1:1. The real working `Update` code lives in `DbRepos/FriendsDbRepos.cs`, and the intended `Create` design is documented in `explanations.md` (Friends doesn't have `Create` implemented in this branch — you'll write it for `Address` by following that spec).

Key difference to note before you start: `Address` only has one navigation collection (`Friends`), and it's the "many" side of a one-to-many (a `Friend` owns the FK to `Address`, not the reverse). Follow the `PetsId`/`QuotesId` pattern from `FriendCuDto` for it.

## Step 1 — Add `AddressCuDto` (Models/DTO/CuDto.cs)

**Purpose:** the API must never accept or return the full `Address` domain model for writes — that would expose navigation objects and invite over-posting. A dedicated CU DTO exposes only the fields a client is allowed to set, with relationships flattened to plain IDs (`FriendsId`) instead of full objects, exactly like `FriendCuDto` does for `PetsId`/`QuotesId`.

Add a new class next to `FriendCuDto` in the same file (that's the existing convention — one file holding all CU DTOs).

```csharp
public class AddressCuDto
{
    public virtual Guid? AddressId { get; set; }   // null on create, must match route id on update

    public virtual string StreetAddress { get; set; }
    public virtual int? ZipCode { get; set; }
    public virtual string City { get; set; }
    public virtual string Country { get; set; }

    public virtual List<Guid> FriendsId { get; set; } = null;

    public AddressCuDto() { }
    public AddressCuDto(IAddress org)
    {
        // TODO: map scalar fields + org.Friends -> FriendsId (mirror FriendCuDto's constructor)
    }
}
```

## Step 2 — Add `UpdateFromDTO` to `AddressDbM` (DbModels/AddressDbM.cs)

**Purpose:** centralizes the DTO → entity scalar-property mapping in one place so both `Create` and `Update` in the repo layer can reuse it instead of duplicating assignment code.

Mirror `FriendDbM.UpdateFromDTO`:

```csharp
public AddressDbM UpdateFromDTO(AddressCuDto org)
{
    // TODO: assign StreetAddress, ZipCode, City, Country
    return this;
}
```

## Step 3 — Add a single-item read to `AddressesDbRepos` (DbRepos/AddressesDbRepos.cs)

**Purpose:** after a create/update writes to the database, the caller expects the fully populated, up-to-date item back (with navigation properties included) rather than the raw DTO it sent in. A reusable single-item read gives `Create`/`Update` (and later a `ReadItem` controller action) one consistent way to fetch that.

`AddressesDbRepos` currently only has the paged `ReadAddressesAsync`. Both `Create` and `Update` need to return a single populated item afterward, exactly like `ReadFriendAsync` does for Friends — so add it first:

```csharp
public async Task<ResponseItemDto<IAddress>> ReadAddressAsync(Guid id, bool flat)
{
    // TODO: mirror ReadFriendAsync — query _dbContext.Addresses.AsNoTracking(),
    // .Include(i => i.FriendsDbM) when !flat, filter by AddressId, throw ArgumentException if not found,
    // wrap in ResponseItemDto<IAddress>
}
```

## Step 4 — Add `CreateAddressAsync` to `AddressesDbRepos`

**Purpose:** this is the actual "C" in CRUD — turning a validated DTO into a new row. The guard clause enforces that clients can't dictate an existing id (that would blur the line between create and update), and the DB-generated key keeps id assignment consistent with how every other entity in this project is created.

Follow the documented pattern from `explanations.md`:

```csharp
public async Task<ResponseItemDto<IAddress>> CreateAddressAsync(AddressCuDto itemDto)
{
    // 1. Guard: AddressId must be null when creating
    if (itemDto.AddressId != null) throw new ArgumentException($"{nameof(itemDto.AddressId)} must be null when creating a new object");

    // 2. Create a new AddressDbM and populate scalar props (new AddressDbM().UpdateFromDTO(itemDto))
    //    (AddressId is DB-generated — do not set it manually, see ValueGeneratedOnAdd in the migrations)

    // 3. Populate navigation properties (Step 6 helper)

    // 4. _dbContext.Addresses.Add(item); await _dbContext.SaveChangesAsync();

    // 5. return await ReadAddressAsync(item.AddressId, false);
}
```

## Step 5 — Add `UpdateAddressAsync` to `AddressesDbRepos`

**Purpose:** this is the "U" in CRUD — loading the tracked entity (with its navigation collections included), applying the incoming scalar and relationship changes, then persisting them in a single unit of work.

Mirror the real, working `UpdateFriendAsync` exactly:

```csharp
public async Task<ResponseItemDto<IAddress>> UpdateAddressAsync(AddressCuDto itemDto)
{
    // 1. Find existing AddressDbM by itemDto.AddressId, .Include(i => i.FriendsDbM)
    // 2. throw ArgumentException if not found
    // 3. item.UpdateFromDTO(itemDto)
    // 4. update navigation properties (Step 6 helper)
    // 5. _dbContext.Addresses.Update(item); await _dbContext.SaveChangesAsync();
    // 6. return await ReadAddressAsync(item.AddressId, false);
}
```

## Step 6 — Navigation property helper

**Purpose:** converts the flat `FriendsId` list on the DTO into actual tracked `FriendDbM` entities EF Core can wire up as a relationship. Validating that every id exists before attaching it prevents silently creating dangling/incorrect relationships. Sharing one helper between `Create` and `Update` avoids duplicating this lookup logic.

Add a private helper analogous to `navProp_FriendCUdto_to_FriendDbM`, but for the `FriendsId` list only:

```csharp
private async Task navProp_AddressCuDto_to_AddressDbM(AddressCuDto itemDtoSrc, AddressDbM itemDst)
{
    // if itemDtoSrc.FriendsId != null: look up each FriendDbM by id (throw if missing), build List<FriendDbM>
    // else: set itemDst.FriendsDbM = null
}
```

Call this helper from both `CreateAddressAsync` and `UpdateAddressAsync`, just like Friends does.

## Step 7 — Extend `IAddressesService` and `AddressesServiceDb`

**Purpose:** the controller depends on the `IAddressesService` abstraction, not on `AddressesDbRepos` directly, so the new repo methods must be exposed through the service interface and its implementation before a controller can call them. Keeping these calls 1:1 pass-throughs matches how thin this service layer is elsewhere in the project.

`Services/IAddressesService.cs`:
```csharp
public Task<ResponseItemDto<IAddress>> ReadAddressAsync(Guid id, bool flat);
public Task<ResponseItemDto<IAddress>> CreateAddressAsync(AddressCuDto item);
public Task<ResponseItemDto<IAddress>> UpdateAddressAsync(AddressCuDto item);
```

`Services/AddressesServiceDb.cs` — add the same thin 1:1 pass-through calls used for Friends:
```csharp
public Task<ResponseItemDto<IAddress>> ReadAddressAsync(Guid id, bool flat) => _repo.ReadAddressAsync(id, flat);
public Task<ResponseItemDto<IAddress>> CreateAddressAsync(AddressCuDto item) => _repo.CreateAddressAsync(item);
public Task<ResponseItemDto<IAddress>> UpdateAddressAsync(AddressCuDto item) => _repo.UpdateAddressAsync(item);
```

## Step 8 — Extend `AddressesController`

**Purpose:** exposes the new service methods as HTTP endpoints — `POST` for create and `PUT {id}` for update, following standard REST conventions — and adds the `ReadItem`/`ReadItemDto` actions needed to fetch a single address (and its CU-DTO shape) for testing and for client edit forms.

Mirror `FriendsController`'s `ReadItem`, `ReadItemDto`, `UpdateItem` and add a `CreateItem`:

```csharp
[HttpGet()]
[ActionName("ReadItem")]
public async Task<IActionResult> ReadItem(string id = null, string flat = "false") { /* mirror FriendsController */ }

[HttpGet()]
[ActionName("ReadItemDto")]
public async Task<IActionResult> ReadItemDto(string id = null) { /* return new AddressCuDto(item.Item) */ }

[HttpPost()]
[ActionName("CreateItem")]
public async Task<IActionResult> CreateItem([FromBody] AddressCuDto item) { /* call _service.CreateAddressAsync(item) */ }

[HttpPut("{id}")]
[ActionName("UpdateItem")]
public async Task<IActionResult> UpdateItem(string id, [FromBody] AddressCuDto item)
{
    // Guid.Parse(id), verify item.AddressId == idArg, call _service.UpdateAddressAsync(item)
}
```

## Step 9 — Verify

**Purpose:** confirms the full round trip works end-to-end and that the guard clauses actually reject bad input, not just that the code compiles.

1. Build the solution (`dotnet build`).
2. Run and open Swagger:
   - `GET api/Addresses/Read` → grab an existing `AddressId` and a couple of `FriendId`s.
   - `POST api/Addresses/CreateItem` with `AddressId: null` and valid `StreetAddress/ZipCode/City/Country` → confirm a new `AddressId` is returned.
   - `PUT api/Addresses/UpdateItem/{id}` with matching `AddressId` → confirm scalar fields update.
   - Try `CreateItem` with a non-null `AddressId` → should return 400 (guard clause).
   - Try assigning a bogus `FriendId` in `FriendsId` → should return 400 (navigation lookup guard).

Once this passes, you've reproduced the `17-cu-in-crud` pattern for `Address`.
