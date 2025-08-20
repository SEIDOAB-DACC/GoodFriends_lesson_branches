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
