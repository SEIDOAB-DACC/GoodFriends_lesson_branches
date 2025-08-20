# Understanding Microsoft Logger and LoggerProvider Pattern

## Introduction
Logging is a crucial part of any application, especially for monitoring, debugging, and auditing. Microsoft provides a flexible logging infrastructure in .NET, which is based on the `ILogger` and `ILoggerProvider` interfaces. This pattern allows developers to write logs in a consistent way and to plug in different logging backends (like console, file, or cloud logging services).

## ILogger Interface
The `ILogger` interface is the main abstraction for logging in .NET. It provides methods to log messages at different severity levels (Information, Warning, Error, etc.). You typically inject an `ILogger<T>` into your classes using dependency injection.

**Example:**
```csharp
public class MyService
{
    private readonly ILogger<MyService> _logger;
    public MyService(ILogger<MyService> logger)
    {
        _logger = logger;
    }
    public void DoWork()
    {
        _logger.LogInformation("Doing work...");
    }
}
```

## ILoggerProvider Interface
The `ILoggerProvider` interface is responsible for creating logger instances. Each provider knows how to write logs to a specific destination (e.g., console, file, database). You can register multiple providers, and each log message will be sent to all of them.

**Example:**
- `ConsoleLoggerProvider` writes logs to the console.
- `FileLoggerProvider` (from third-party packages) writes logs to a file.

## How It Works Together
1. **Providers** are registered in the application's logging configuration.
2. When a logger is requested (e.g., `ILogger<MyService>`), the logging system asks each provider to create a logger for that category.
3. When you call a log method, the message is sent to all registered providers.

## Custom LoggerProvider
You can create your own provider by implementing `ILoggerProvider` and `ILogger`. This is useful if you want to log to a custom destination (like a special database or an external service).


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



## Summary
- Use `ILogger<T>` for logging in your classes.
- Register one or more `ILoggerProvider` implementations to control where logs go.
- The pattern is extensible and supports custom logging destinations.
- The `Logging` section in `appsettings.json` lets you control which log messages are recorded by each logger provider and for each part of your application. You can set global log levels, override them for specific providers, and filter by category. This makes it easy to adjust logging behavior for development, production, or testing—without changing your code.

**Further Reading:**
- [Microsoft Docs: Logging in .NET](https://learn.microsoft.com/en-us/dotnet/core/extensions/logging)
- [Custom logging providers](https://learn.microsoft.com/en-us/dotnet/core/extensions/custom-logging-provider)



