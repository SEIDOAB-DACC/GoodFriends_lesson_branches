

## General Explanation: ASP.NET Core Dependency Injection

ASP.NET Core has built-in support for dependency injection, a design pattern that allows classes to receive their dependencies from an external source rather than creating them directly. This promotes loose coupling, easier testing, and better maintainability.

- **Service Registration:** Services (classes, interfaces, etc.) are registered in the DI container in `Program.cs` (or `Startup.cs` in older versions) using methods like `AddSingleton`, `AddScoped`, or `AddTransient`.
- **Service Resolution:** ASP.NET Core automatically provides registered services to classes (like controllers) via constructor parameters.


# AdminController Endpoints and Dependency Injection

## Overview
---

## How `DatabaseConnections` is Registered and Used

### Registration in `Program.cs`

In `Program.cs`, the `DatabaseConnections` service is registered with the dependency injection (DI) container as a singleton:

```csharp
builder.Services.AddSingleton<DatabaseConnections>();
```

This means a single instance of `DatabaseConnections` is created and shared throughout the application's lifetime. This is suitable for services that are stateless or manage their own thread safety.

### Injection and Usage in `AdminController`

The `AdminController` receives an instance of `DatabaseConnections` via its constructor:
This instance is then used in endpoints such as `DefaultDataUserConnection` and `MigrationUserConnection`:

- The controller does not create or manage the `DatabaseConnections` instance itself; it simply requests it as a dependency.
- The DI system ensures the same singleton instance is injected wherever it is needed.

---

## Explanation of `DatabaseConnections` and `dbConnections`

### `DatabaseConnections` Class

The `DatabaseConnections` class is a configuration and utility service that manages information about available database connections in the application. It is responsible for:

- Reading connection settings from the application's configuration (such as `appsettings.json` and environment variables).
- Providing details about the current active data set and its users (e.g., default data user, migration user).
- Exposing methods to retrieve connection details for specific users, such as `GetDataConnectionDetails`.
- Exposing a `SetupInfo` property that summarizes the current environment, secret source, active data set, and database server type.

Key members include:

- `GetDataConnectionDetails(string user)`: Returns connection details for a given user in the active data set.
- `SetupInfo`: Returns a summary of the current database and environment configuration.

The class is constructed with `IConfiguration` and `IOptions<DbConnectionSetsOptions>`, allowing it to access all relevant configuration data and options.

### `dbConnections` in `AdminController`

In `AdminController`, the private field `_dbConnections` is an instance of the `DatabaseConnections` class, injected by the dependency injection system. It is used by endpoints to:

- Retrieve connection details for the default data user and migration user.
- Provide environment and setup information to API consumers.

This approach centralizes all database connection logic and configuration in a single, reusable service, making the controller code cleaner and easier to maintain.

---


## How `Encryptions` is Registered and Used

### Registration in `Program.cs`

In `Program.cs`, the `Encryptions` service is registered with the dependency injection (DI) container as a transient service:

This means a new instance of `Encryptions` is created each time it is requested. This is suitable for stateless services that do not need to maintain shared state between requests.

### Injection and Usage in `AdminController`

The `AdminController` receives an instance of `Encryptions` via its constructor:
This instance is then used in endpoints such as `EncryptedQuotes` and `DecryptedQuote`:

- The controller does not create or manage the `Encryptions` instance itself; it simply requests it as a dependency.
- The DI system ensures a new instance is injected for each request, as configured.

---


## Explanation of `EncryptedQuotes` and `DecryptedQuote` Endpoints

### `EncryptedQuotes` Endpoint

**Route:** `GET api/admin/encryptedquotes`

This endpoint returns a list of quotes, each encrypted using AES and encoded as a Base64 string. The process is as follows:

1. All quotes are generated and mapped to `Quote` objects.
2. Each quote is encrypted using the `Encryptions.AesEncryptToBase64<Quote>()` method.
3. The resulting list of encrypted Base64 strings is returned to the client.

**Purpose:**
- Demonstrates how to securely transmit sensitive data by encrypting it before sending it over the network.
- Useful for scenarios where quotes or similar data must be protected in transit.

### `DecryptedQuote` Endpoint

**Route:** `GET api/admin/decryptedquote?encryptedQuote=...`

This endpoint accepts an encrypted quote (as a Base64 string) as a query parameter, decrypts it, and returns the original quote object.

1. The encrypted Base64 string is received as the `encryptedQuote` parameter.
2. The string is decrypted using the `Encryptions.AesDecryptFromBase64<Quote>()` method.
3. The decrypted `Quote` object is returned to the client.

**Purpose:**
- Allows clients to send encrypted data to the server and have it decrypted securely.
- Demonstrates how the application can handle encrypted payloads and restore them to their original form.

---


## Explanation of `Encryptions` Class

The `Encryptions` class is a service responsible for handling encryption and decryption operations in the application. It is designed to:

- Provide AES-based encryption and decryption for objects, serializing them to and from Base64 strings.
- Hash and derive cryptographic keys using PBKDF2 (Password-Based Key Derivation Function 2) with configurable salt and iteration count.
- Hash passwords securely for storage or comparison.

Key members include:

- `AesEncryptToBase64<T>(T sourceToEncrypt)`: Serializes and encrypts an object to a Base64 string using AES.
- `AesDecryptFromBase64<T>(string encryptedBase64)`: Decrypts a Base64 string to an object of type T.
- `Pbkdf2HashToBytes(int nrBytes, string password)`: Derives a cryptographic key from a password using PBKDF2.
- `EncryptPasswordToBase64(string password)`: Hashes a password and returns the result as a Base64 string.

The class is constructed with `IOptions<AesEncryptionOptions>`, allowing it to use encryption settings from configuration. In `AdminController`, an instance of `Encryptions` is injected and used for endpoints that require encryption or decryption of data, such as handling encrypted quotes.

---


