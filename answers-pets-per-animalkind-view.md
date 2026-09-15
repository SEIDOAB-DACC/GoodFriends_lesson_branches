### Answers: Nr of Pets per AnimalKind

Worked solution for [exercises-pets-per-animalkind-view.md](exercises-pets-per-animalkind-view.md).
Try each step yourself first.

## Step 1 — SQL Server view

```sql
CREATE OR ALTER VIEW gstusr.vwInfoPetsPerKind AS
    SELECT strKind as AnimalKind, COUNT(*) as NrPets FROM supusr.Pets
    GROUP BY strKind;
GO
```

## Step 2 — DTO

```csharp
public class GstUsrInfoPetsPerKindDto
{
    public string AnimalKind { get; set; } = null;
    public int NrPets { get; set; } = 0;
}
```

## Step 3 — `MainDbContext`

```csharp
// in the #region model the Views DbSet block
public DbSet<GstUsrInfoPetsPerKindDto> InfoPetsPerKindView { get; set; }

// in OnModelCreating, alongside the other .ToView(...) calls
modelBuilder.Entity<GstUsrInfoPetsPerKindDto>().ToView("vwInfoPetsPerKind", "gstusr").HasNoKey();
```

## Step 4 — `PetsDbRepos`

```csharp
public async Task<ResponseItemDto<List<GstUsrInfoPetsPerKindDto>>> ReadPetsPerAnimalKindAsync()
{
    var items = await _dbContext.InfoPetsPerKindView.ToListAsync();

    return new ResponseItemDto<List<GstUsrInfoPetsPerKindDto>>()
    {
#if DEBUG
        ConnectionString = _dbContext.dbConnection,
#endif
        Item = items
    };
}
```

## Step 5 — Services and Controller

`Services/IPetsService.cs`:
```csharp
public Task<ResponseItemDto<List<GstUsrInfoPetsPerKindDto>>> ReadPetsPerAnimalKindAsync();
```

`Services/PetsServiceDb.cs`:
```csharp
public Task<ResponseItemDto<List<GstUsrInfoPetsPerKindDto>>> ReadPetsPerAnimalKindAsync() => _repo.ReadPetsPerAnimalKindAsync();
```

`AppWebApi/Controllers/PetsController.cs`:
```csharp
//GET: api/pets/petsperkind
[HttpGet()]
[ActionName("PetsPerKind")]
[ProducesResponseType(200, Type = typeof(List<GstUsrInfoPetsPerKindDto>))]
[ProducesResponseType(400, Type = typeof(string))]
public async Task<IActionResult> PetsPerKind()
{
    try
    {
        _logger.LogInformation($"{nameof(PetsPerKind)}:");

        var resp = await _service.ReadPetsPerAnimalKindAsync();
        return Ok(resp);
    }
    catch (Exception ex)
    {
        _logger.LogError($"{nameof(PetsPerKind)}: {ex.Message}");
        return BadRequest(ex.Message);
    }
}
```
