# InMemoryLoggerProvider and InMemoryLogger: Following the Microsoft Logger Pattern

## Overview
`InMemoryLoggerProvider` and its inner class `InMemoryLogger` are custom implementations that follow the Microsoft logging abstraction pattern. This pattern is based on two main interfaces: `ILoggerProvider` and `ILogger`.

## How the Pattern Works
- **ILoggerProvider**: Responsible for creating logger instances. Each provider can log to a different destination (console, file, memory, etc.).
- **ILogger**: Used by application code to write log messages. The logger sends these messages to the provider, which handles storage/output.

## InMemoryLoggerProvider
- Implements `ILoggerProvider`.
- Maintains a thread-safe in-memory list of log messages (`_messages`).
- When `CreateLogger` is called, it returns a new `InMemoryLogger` instance, passing itself and the log category.
- Provides access to the collected log messages for inspection or testing.

## InMemoryLogger
- Implements `ILogger`.
- For each log call, it delegates to the provider's `Log` method, which adds a new `LogMessage` to the shared list.
- Implements required methods (`Log`, `IsEnabled`, `BeginScope`) as per the Microsoft interface, but only `Log` is functionally used here.

## Why This Follows the Pattern
- **Separation of Concerns**: The provider manages storage, while the logger handles message creation and category.
- **Extensibility**: You can register multiple providers (e.g., in-memory, file, console) and log to all at once.
- **Dependency Injection**: Loggers are created per category and injected where needed, as in the Microsoft ecosystem.


## Registering the Logger Provider in Program.cs
To use the `InMemoryLoggerProvider` in your ASP.NET Core application, register it in the dependency injection container in `Program.cs`:

```csharp
// Inject custom logger provider
builder.Services.AddSingleton<ILoggerProvider, InMemoryLoggerProvider>();
```

This ensures that the custom logger provider is available throughout your application and that all logging will use it according to the Microsoft logger/provider pattern.

## Summary
- `InMemoryLoggerProvider` and `InMemoryLogger` are a textbook example of the Microsoft logger/provider pattern.
- They allow capturing logs in memory, which is useful for testing or diagnostics.
- The design is thread-safe and follows the required interfaces for easy integration with ASP.NET Core or other .NET apps.


## Configuring Logging with appsettings.json
The `Logging` section in `appsettings.json` allows you to configure logging behavior for your application and for each logger provider. This is a standard feature in ASP.NET Core and .NET applications.

### Example Structure
```json
"Logging": {
	"LogLevel": {
		"Default": "Information",
		"Microsoft": "Warning",
		"Microsoft.Hosting.Lifetime": "Information"
	},
	"Console": {
		"LogLevel": {
			"Services": "Information",
			"AppWebApi.Controllers": "None",
			"DbRepos": "None"
		}
	},
	"InMemory": {
		"LogLevel": {
			"Services": "Information",
			"AppWebApi.Controllers": "Information",
			"DbRepos": "Information"
		}
	}
}
```

### How It Works
- **LogLevel**: The top-level `LogLevel` section sets the minimum log level for all providers and for specific categories (like namespaces or classes).
- **Provider-specific settings**: Each provider (e.g., `Console`, `InMemory`) can have its own `LogLevel` section to override the global settings for specific categories.
- **Category-based filtering**: You can control which log messages are captured or ignored for each part of your application by adjusting the log level for categories (e.g., `AppWebApi.Controllers`).

### Example
- Setting `"AppWebApi.Controllers": "None"` under `Console` means no logs from controllers will appear in the console.
- Setting `"AppWebApi.Controllers": "Information"` under `InMemory` means informational logs from controllers will be captured by the in-memory logger.

This flexible configuration allows you to fine-tune logging output for different environments and providers without changing code.