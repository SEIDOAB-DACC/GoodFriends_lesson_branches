# Exercise Suggestions: User Secrets, IConfiguration, and IOptions

These exercises will help you practice working with user secrets, configuration, and the options pattern in ASP.NET Core.

## Exercise 1: Add Your Own User Secret Structure
- **Goal:** Create a custom user secret structure to store sensitive information (e.g., an API key or a secret message).
- **Steps:**
  1. Define a new class in Optionsfolder (e.g., `MySecrets`) with properties .
  2. Add your secrets class structure in json format in the Configurations user secret file, secrets.json

## Exercise 2: Create an Endpoint Using IConfiguration
- **Goal:** Build an endpoint that reads a value from your user secrets using `IConfiguration`.
- **Steps:**
  1. Inject the `IConfiguration` into your controller. If you use AdminCotroller it is already injected
  2. Read a secret value from your user secrets.
  3. Return the value from a new API endpoint.

## Exercise 3: Use the IOptions Pattern in an Endpoint
- **Goal:** Use the options pattern to bind your user secret structure and expose its values via an endpoint.
- **Steps:**
  1. Register your secret class with the `services.Configure<T>()` method in `Program.cs`.
  2. Inject `IOptions<MySecrets>` into your controller.
  3. Create an endpoint that returns the bound secret values as JSON.

---

**Tip:**
- Review the official documentation for [User Secrets](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets) and [Options pattern](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration/options) for more details.
- Remember to never commit real secrets to source control!

## Exercise 4: Explore DbConnectionSetsOptions Structure
- **Goal:** Understand the hierarchical structure of database connection configuration by creating an endpoint that queries specific connection sets.
- **Steps:**
  1. Study the `DbConnectionSetsOptions` class structure in the Configuration project (includes `DataSets` and `IdentitySets` lists).
  2. Examine the existing `api/admin/options1` endpoint in `AdminController.cs` to see how it returns all connection sets.
  3. Create a new endpoint `api/admin/connectionsetbytag` that accepts a `dbTag` parameter (e.g., "Production", "Development").
  4. Filter and return only the `DbSetDetailOptions` that matches the provided tag from either DataSets or IdentitySets.
  5. Handle cases where the tag doesn't exist (return 404 NotFound with a meaningful message).
- **Expected Result:** An endpoint that returns connection details for a specific database tag, demonstrating navigation through the options hierarchy.

## Exercise 5: Count Database Connections Across All Sets
- **Goal:** Practice working with nested collections in the options pattern by aggregating data from the `DbConnectionSetsOptions`.
- **Steps:**
  1. Create a new endpoint `api/admin/connectionstats` in the `AdminController`.
  2. Use the injected `DbConnectionSetsOptions` to calculate statistics:
     - Total number of DataSets
     - Total number of IdentitySets
     - Total number of database connections across all DataSets
     - Total number of database connections across all IdentitySets
     - List of all unique database servers (DbServer property)
  3. Return a custom object containing these statistics as JSON.
  4. Test your endpoint and verify the counts match the configuration in your appsettings or user secrets.
- **Expected Result:** A summary endpoint that demonstrates LINQ queries over complex nested option structures and provides useful diagnostic information about your database configuration.

---

**Advanced Challenge:**
- Extend Exercise 5 to include a breakdown showing which DbTags have the most connections configured.
- Add validation to ensure all DbConnectionDetailOptions have non-empty ConnectionStrings.
