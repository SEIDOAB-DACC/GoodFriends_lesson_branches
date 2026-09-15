# Exercises: Nr of Pets per AnimalKind (View → DTO → DbContext → Repos → Service → Controller)

**Related branch:** `20-database-objects`

**Learning objective:** Practice adding a brand-new *read-only* feature as a
full vertical slice through every layer of the application — from a raw SQL
view all the way up to an HTTP endpoint — using the exact same pattern already
used for the existing `gstusr.vwInfoPets` / `GstUsrInfoPetsDto` view. Use
[DbRepos/AdminDbRepos.cs](DbRepos/AdminDbRepos.cs) (method `DbInfo()`) and
[AppWebApi/Controllers/AdminController.cs](AppWebApi/Controllers/AdminController.cs)
as your reference implementation of a similar view-backed feature — keep both
files open side by side while you work.

By the end you will have a new endpoint that returns the number of pets grouped
by `AnimalKind` (`Dog`, `Cat`, `Rabbit`, `Fish`, `Bird` — see the enum in
[Models/IPet.cs](Models/IPet.cs)), e.g.:

```json
[
  { "animalKind": "Dog", "nrPets": 12 },
  { "animalKind": "Cat", "nrPets": 9 },
  { "animalKind": "Fish", "nrPets": 3 }
]
```

The 5 steps below mirror the 5 layers of the application (database → DB model →
DbContext → repository → service/controller). Work through them **in order**
— each step builds on and depends on the previous one, and you won't be able to
compile or test a later step until the earlier ones are in place.

---

## Step 1 — Add the SQL Server view

**File to edit:** [DbContext/SqlScripts/sqlserver/initDatabase.sql](DbContext/SqlScripts/sqlserver/initDatabase.sql)
**Where:** add your new view directly below the existing `CREATE OR ALTER VIEW gstusr.vwInfoPets AS ...` block (and its `GO`), so all the `gstusr` views stay grouped together.

**Background:** The `Pets` table (schema `supusr`) already stores the animal
kind twice: `Kind` is the raw `int` enum value, while `strKind` is a computed
`varchar` column holding the human-readable name (`"Dog"`, `"Cat"`, ...) — see
`PetDbM.strKind` in [DbModels/PetDbM.cs](DbModels/PetDbM.cs). For a
human-readable report, group by `strKind` rather than the numeric `Kind`.

**Task:**
1. Create a new view named exactly `gstusr.vwInfoPetsPerKind`.
2. It must return **one row per distinct animal kind** with exactly two columns:
   - `AnimalKind` — the readable kind name (i.e. `strKind`)
   - `NrPets` — the count of pets that have that kind
3. Query from `supusr.Pets` and `GROUP BY` the kind column.
4. Use the same `CREATE OR ALTER VIEW <name> AS SELECT ... GROUP BY ...;` /
   `GO` style already used by `gstusr.vwInfoQuotes` further down in the same
   file (that view groups quotes by `Author` — yours groups pets by kind, the
   shape of the statement is otherwise identical).

**Verify before moving on:** re-run `initDatabase.sql` against your local
database (or however you normally apply these scripts), then run
`SELECT * FROM gstusr.vwInfoPetsPerKind;` directly in a SQL query tool. You
should see one row per animal kind that currently has at least one pet, with a
correct count. Fix any SQL errors here before writing any C# code — the rest
of the exercise depends on this view existing and returning the right shape.

---

## Step 2 — Add a matching DTO

**File to edit:** [Models/DTO/GstUsrDto.cs](Models/DTO/GstUsrDto.cs)
**Where:** add the new class directly below the existing `GstUsrInfoPetsDto` class, to keep the `Info*` DTOs grouped together.

**Background:** EF Core maps a database view to a C# class by matching
**property names to column names** (case-insensitive). There's no primary key
on a view, so these DTOs are always plain classes with simple properties — no
navigation properties, no `[Key]` attribute.

**Task:**
Add a new class `GstUsrInfoPetsPerKindDto` with exactly two auto-properties
whose **names match your view's column names from Step 1** and whose types
match the SQL column types:
- `string AnimalKind` (default it to `null`, matching the style used elsewhere in this file)
- `int NrPets` (default it to `0`)

Model the class layout/formatting after the existing `GstUsrInfoPetsDto` class
immediately above it (same file, same namespace `Models.DTO`) — don't invent a
different style.

**Verify before moving on:** the project should still build. This class has no
behavior yet, it's just a plain data holder.

---

## Step 3 — Wire up `MainDbContext` to read the view

**File to edit:** [DbContext/MainDbContext.cs](DbContext/MainDbContext.cs)

**Background:** `MainDbContext` currently exposes four views as `DbSet<T>`
properties in the `#region model the Views` block, and maps each one to its
database view name/schema inside `OnModelCreating`, also inside a `#region
model the Views` block. Both regions list the views in the same order
(`InfoDbView`, `InfoFriendsView`, `InfoPetsView`, `InfoQuotesView`) — keep that
convention and add your new view as a 5th entry in both places.

**Task:**
1. In the **first** `#region model the Views` block (near the top of the
   class, alongside the other `DbSet<...>` properties), add:
   `public DbSet<GstUsrInfoPetsPerKindDto> InfoPetsPerKindView { get; set; }`
   — right after the existing `InfoPetsView` line.
2. In `OnModelCreating`, inside the **second** `#region model the Views` block,
   add a line that maps your DTO to the view using `.ToView("<view name>",
   "<schema>")` followed by `.HasNoKey()` (views have no primary key, so EF
   Core must be told explicitly) — right after the existing line for
   `GstUsrInfoPetsDto`.
3. Double-check: the view name string and schema string you pass to `.ToView(...)`
   must match **exactly** (including casing) what you created in Step 1
   (`"vwInfoPetsPerKind"`, `"gstusr"`), otherwise EF Core will throw at runtime
   when the view is queried, not at compile time.

**Verify before moving on:** the project should still build — this step is
pure configuration, there's no way to "run" it in isolation yet, but a typo in
the view/schema name here is the single most common bug in this exercise, so
re-read it carefully against Step 1.

---

## Step 4 — Add a method in `PetsDbRepos` that reads the view

**File to edit:** [DbRepos/PetsDbRepos.cs](DbRepos/PetsDbRepos.cs)
**Where:** add the new method after `ReadPetsAsync(...)` and before `DeletePetAsync(...)`, keeping the "read" methods together.

**Background:** Repos methods that read views follow the same shape as
`AdminDbRepos.DbInfo()`: query the `DbSet` on `_dbContext`, materialize it with
`ToListAsync()` (or `FirstAsync()` for a single row), and wrap the result in a
`ResponseItemDto<T>` so the controller can optionally surface the (debug-only)
connection string.

**Task:**
Add a new `public async Task<...>` method, e.g. `ReadPetsPerAnimalKindAsync()`,
that:
1. Queries `_dbContext.InfoPetsPerKindView` (the `DbSet` you added in Step 3)
   and materializes it into a `List<GstUsrInfoPetsPerKindDto>` with `ToListAsync()`.
2. Returns it wrapped in a `ResponseItemDto<List<GstUsrInfoPetsPerKindDto>>`,
   setting the `Item` property to your list, and (inside `#if DEBUG` / `#endif`)
   setting `ConnectionString = _dbContext.dbConnection` — copy this
   `#if DEBUG` block verbatim from one of the other methods in this same file
   (e.g. `ReadPetAsync`).

**Verify before moving on:** the project should build. If you want to sanity
check the query works before wiring up the rest, temporarily call your new
method from a quick throwaway test or breakpoint — you should get back a list
matching what you saw in SQL in Step 1.

---

## Step 5 — Wire up Services and Controller for a new endpoint

**Files to edit (in this order):**
1. [Services/IPetsService.cs](Services/IPetsService.cs) — add the method signature.
2. [Services/PetsServiceDb.cs](Services/PetsServiceDb.cs) — implement it.
3. [AppWebApi/Controllers/PetsController.cs](AppWebApi/Controllers/PetsController.cs) — expose it as an endpoint.

**Task:**

1. **`IPetsService`:** add a new interface method with the same return type and
   name as your repos method from Step 4, e.g.
   `Task<ResponseItemDto<List<GstUsrInfoPetsPerKindDto>>> ReadPetsPerAnimalKindAsync();`

2. **`PetsServiceDb`:** implement the interface method as a one-line,
   expression-bodied pass-through to `_repo`, exactly like the other methods in
   this class (e.g. `public Task<...> ReadPetsPerAnimalKindAsync() =>
   _repo.ReadPetsPerAnimalKindAsync();`). Don't add any extra logic here — this
   class is intentionally a thin pass-through for now.

3. **`PetsController`:** add a new `[HttpGet()]` action, decorated the same way
   as the existing `Read` action:
   - `[ActionName("PetsPerKind")]` (or a name of your choice)
   - `[ProducesResponseType(200, Type = typeof(List<GstUsrInfoPetsPerKindDto>))]`
   - `[ProducesResponseType(400, Type = typeof(string))]`
   - Body: log entry via `_logger.LogInformation(...)`, call
     `await _service.ReadPetsPerAnimalKindAsync()`, return `Ok(resp)` on
     success, and on exception log the error and `return BadRequest(ex.Message)`
     — copy the try/catch structure from the existing `Read` action verbatim.

   Because the controller is routed with `[Route("api/[controller]/[action]")]`,
   an `ActionName` of `"PetsPerKind"` will be reachable at `GET
   api/Pets/PetsPerKind` (routes are case-insensitive).

**Verify — final test:** run the Web API (e.g. via the `watch` task) and open
Swagger, or call the endpoint directly, e.g.:

```
GET api/Pets/PetsPerKind
```

You should get back a 200 response with a JSON array shaped like the example
at the top of this document. If you get a 400, read the error message — it
usually points straight at a schema/view name typo from Step 3.

---

Stuck on exact syntax? Check
[answers-pets-per-animalkind-view.md](answers-pets-per-animalkind-view.md) for a
worked solution to each step.
