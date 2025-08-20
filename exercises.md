# Logging Configuration Exercises

These exercises will help you practice configuring and testing logging in the AppWebApi and Configuration projects using `appsettings.json` and the custom `InMemoryLoggerProvider`.

---

## Exercise 1: Change Global Log Level
- Edit `appsettings.json` to set `"Default": "Warning"` in the `Logging:LogLevel` section.
- Run the application and verify that only warnings and errors are logged by all providers.

---

## Exercise 2: Category-Based Filtering
- In `appsettings.json`, set `"AppWebApi.Controllers": "None"` under the `Console` provider.
- Trigger actions in a controller and confirm that no controller logs appear in the console, but do appear in the in-memory logger (if enabled).

