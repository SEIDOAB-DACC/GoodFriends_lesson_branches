# Configuration Project Overview

## Purpose
The `Configuration` project in this solution is responsible for centralizing and managing application configuration logic. It provides a structured way to access configuration settings, bind them to strongly-typed objects, and expose them throughout the application using best practices. This separation of concerns improves maintainability, testability, and clarity in the codebase.

## Architecture
- **Centralized Configuration Logic:** The project encapsulates all configuration-related code, such as reading from `appsettings.json`, environment variables, and user secrets.
- **Strongly-Typed Options:** It defines POCO (Plain Old CLR Object) classes that represent configuration sections, which are then bound using the options pattern.
- **Integration with ASP.NET Core:** The project is designed to be consumed by the main web API and other projects, providing a single source of truth for configuration.

## Microsoft IConfiguration
`IConfiguration` is a core interface in ASP.NET Core for accessing key-value application settings. It supports hierarchical configuration from multiple sources (JSON files, environment variables, user secrets, etc.). In this solution, `IConfiguration` is injected into services and used to bind configuration sections to options classes.

## Options Pattern (IOptions<T>)
The options pattern is used to bind configuration sections to strongly-typed classes. This is achieved by:
1. Defining a POCO class for a configuration section.
2. Registering it in the DI container with `services.Configure<T>(configuration.GetSection("SectionName"))`.
3. Injecting `IOptions<T>` or `IOptionsSnapshot<T>` into dependent services.

This pattern provides type safety, IntelliSense, and validation for configuration settings.

## User Secrets
User secrets are a secure way to store sensitive configuration data (like API keys or connection strings) during development. They are not checked into source control and are specific to the developer's machine. In this solution:
- User secrets are enabled for the project.
- Sensitive settings are stored in the user secrets store and loaded into the configuration at runtime.
- This ensures that secrets are not exposed in code or configuration files committed to the repository.

## Usage in This Solution
- The `Configuration` project defines and registers options classes for various configuration sections.
- The main web API project consumes these options via dependency injection, using `IOptions<T>`.
- User secrets are used for local development to keep sensitive data out of source control.

This approach ensures secure, maintainable, and scalable configuration management across the solution.
## Why a Separate Project?
Instead of placing configuration code in a folder within the `AppWebApi` project, the `Configuration` project is structured as a standalone class library for several reasons:

- **Separation of Concerns:** Isolating configuration logic keeps the web API focused on its core responsibilities, making the codebase easier to understand and maintain.
- **Reusability:** Other projects in the solution (such as background services, console apps, or tests) can reference the `Configuration` project and share the same configuration logic and options classes.
- **Testability:** Configuration logic can be tested independently from the web API, improving code quality and enabling more focused unit tests.
- **Scalability:** As the solution grows, configuration needs may become more complex. A dedicated project allows for easier scaling and organization of configuration-related code.
- **Cleaner Dependencies:** The web API only needs to reference the configuration abstractions it uses, reducing coupling and making dependencies explicit.
- **Avoids Circular References:** By keeping configuration logic in a separate project, the solution avoids circular dependencies between `AppWebApi` and `Configuration`, which could occur if configuration code in a folder needed to reference types from both directions. This is not possible with a folder structure inside `AppWebApi`.

This modular approach aligns with best practices for large or evolving .NET solutions.

## NuGet Package Dependencies

The `Configuration` project includes several essential NuGet packages that enable its functionality:

### Core Configuration Packages
- **Microsoft.Extensions.Configuration.Binder (9.0.8):** Provides the ability to bind configuration sections to strongly-typed POCO classes using the options pattern.
- **Microsoft.Extensions.Configuration.FileExtensions (9.0.8):** Enables reading configuration from file-based sources like JSON, XML, and INI files.
- **Microsoft.Extensions.Configuration.Json (9.0.8):** Specifically handles JSON configuration sources, essential for reading `appsettings.json` files.
- **Microsoft.Extensions.Configuration.UserSecrets (9.0.8):** Provides support for the user secrets feature, allowing secure storage of sensitive configuration during development.

### Options Pattern Support
- **Microsoft.Extensions.Options (9.0.8):** Core package for implementing the options pattern, providing `IOptions<T>`, `IOptionsSnapshot<T>`, and `IOptionsMonitor<T>` interfaces for accessing strongly-typed configuration.

### Logging Infrastructure
- **Microsoft.Extensions.Logging (9.0.8):** Core logging framework for .NET applications.
- **Microsoft.Extensions.Logging.Abstractions (9.0.8):** Provides abstractions for logging, allowing the configuration project to log operations without depending on specific logging implementations.

### Security and Cryptography
- **Microsoft.AspNetCore.Cryptography.KeyDerivation (9.0.8):** Provides key derivation functions for secure password hashing and cryptographic operations, used in conjunction with AES encryption configuration.

### Azure Integration
- **Azure.Identity (1.15.0):** Provides Azure Active Directory authentication capabilities for accessing Azure resources.
- **Azure.Security.KeyVault.Secrets (4.8.0):** Enables secure retrieval of secrets from Azure Key Vault.
- **Azure.Extensions.AspNetCore.Configuration.Secrets (1.4.0):** Integrates Azure Key Vault as a configuration source in ASP.NET Core applications.

### JSON Processing
- **Newtonsoft.Json (13.0.3):** Popular JSON serialization library for .NET, providing flexible JSON parsing and serialization capabilities.

### Legacy Support
- **Microsoft.AspNetCore.Hosting.Abstractions (2.3.0):** Provides hosting abstractions for compatibility with older ASP.NET Core patterns and interfaces.

These packages work together to create a comprehensive configuration system that supports multiple sources, strong typing, security, cloud integration, and proper logging.

## Code Explanations: Configuration/Options Classes

### AesEncryptionOptions
This class represents configuration settings for AES encryption. It includes properties for the encryption key, IV (initialization vector), salt, and iteration count. The `HashKeyIv` method allows hashing of the key and IV using a provided hashing function, storing the results in `KeyHash` and `IvHash`. This is useful for securely handling encryption parameters loaded from configuration.


### DbConnectionDetailOptions
Represents the details for a single database connection, including the user login, connection name, and connection string. Used as part of more complex connection configuration.

### DbConnectionSetsOptions & DbSetDetailOptions
`DbConnectionSetsOptions` groups together multiple sets of database connection details, typically for different data or identity stores. Each set is represented by a `DbSetDetailOptions` object, which includes a tag, server, and a list of connection details.

### JwtOptions
Holds configuration for JWT (JSON Web Token) authentication, such as token lifetime, signing key, issuer, audience, and validation flags. These settings are used to configure authentication middleware in the web API which will be done in the branch 17-jwt-security

### VersionOptions
Encapsulates version and build metadata for the application, such as assembly version, file version, informational version, git commit hash, build time, and company/product info. Includes a static method to populate these properties from the current assembly.
