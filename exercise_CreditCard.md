# Exercise: Building a Layered WebApi with CreditCard Model and Encrypted Token

## Objective
Create a modern ASP.NET Core WebApi using Swagger, following a layered architecture as demonstrated in branches `0a-microsoft-template` to `7-dbcontext`. The stack should include the following layers:
- Application (WebApi)
- Service
- DbRepos
- DbContext
- DbModels
- Models
- Configuration

The main domain model is `CreditCard`, which includes an AES-encrypted token property. The configuration layer provides encryptions. The Service and DbRepos layers should support seeding the database with a specified number of randomly generated credit cards. The Application layer exposes an endpoint to trigger the seeding process.

---

## Step-by-Step Instructions

### 1. Project Structure
Organize your solution into the following projects:
- `AppWebApi` (Application)
- `Services` (Service layer)
- `DbRepos` (Repository layer)
- `DbContext` (EF Core context)
- `DbModels` (Database entities)
- `Models` (Domain models)
- `Configuration` (App configuration and encryption)

### 2. Models and DbModels
- Define a `CreditCard` class in `Models` with properties: `Id`, `CardNumber`, `CardHolder`, `ExpirationDate`, `EncryptedToken`.
- In `DbModels`, create a matching entity for EF Core.

### 3. Encryption Configuration
- In `Configuration`, use the Encryptions service and inject appropriately
- In appsettings.json store the connection string

### 4. DbContext
- Implement `MainDbContext` in the `DbContext` project, referencing `DbModels`.
- Configure the connection string and provider as in previous exercises.

### 5. Repository Layer (DbRepos)
- Implement a repository for `CreditCard`
- Provide a method to seed nrItems random credit cards.
- In the method generates nrItems random credit card data, encrypts the card using AES, and calls the repository to save the cards.

### 6. Service Layer
- Implement a service that calls the repository to seed nrItems cards.

### 7. Application Layer (WebApi)
- Add a controller endpoint to trigger the seeding process.
- Use Swagger for testing.

### 8. Dependency Injection
- Register all services, repositories, DbContext, and configuration in `Program.cs`.

### 9. Create EFC Migration and Update Database (using Docker)
- Ensure your Docker database container is running (e.g., using the provided scripts)

- Run the commands in the file EFC migration commands.txt" to create a migration and update the database. 
- These commands use the `DbContext` project for migrations and the `AppWebApi` project as the startup project.

- If you use a custom script (e.g., `_scripts/database-rebuild-all.sh postgresql docker`), follow the steps in readme-clr1.txt

### 10. Testing
- Use Swagger UI to call the seeding endpoint and verify that credit cards are added to the database with encrypted tokens.

---

## Example: CreditCard Model
```csharp
public class CreditCard
{
    public int Id { get; set; }
    public string CardNumber { get; set; }
    public string CardHolder { get; set; }
    public DateTime ExpirationDate { get; set; }
    public string EncryptedToken { get; set; }
}
```

---

## Example: Seeding Endpoint
```csharp
[ApiController]
[Route("api/[controller]")]
public class CreditCardsController : ControllerBase
{
    public AdminController(IOptions<VersionOptions> versionOptions, IAdminService service)
    {
        _versionOptions = versionOptions.Value;
        _service = service;
    }

    [HttpGet()]
    [ActionName("Seed")]
    public async Task<IActionResult> Seed(int count)
    {
        await _service.SeedAsync(count);
        return Ok($"Seeded {count} credit cards.");
    }
}
```

---

## Summary
This exercise guides you through building a full-stack, layered WebApi with:
- Modern architecture and separation of concerns
- AES encryption for sensitive data
- Random data seeding via a REST endpoint
- Swagger for API exploration

Follow the structure and best practices demonstrated in branches `0a-microsoft-template` to `7-dbcontext` for implementation details.
