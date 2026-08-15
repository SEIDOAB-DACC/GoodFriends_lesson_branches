# Logging Configuration Exercises

These exercises will help you practice configuring and testing logging in the AppWebApi and Configuration projects using `appsettings.json` and the custom `InMemoryLoggerProvider`.

Start the AppWebAp in release mode. In folder GoodFriends_lesson_branches start a terminal and run

dotnet run --project AppWebApi/AppWebApi.csproj --configuration Release --environment Production

Open http://localhost:5106/swagger


---

## Exercise 1: Get to know Log output
- In AppWebApi AdminController invoke endpoints Environment, DefaultDataUserConnection, MigrationUserConnection 
- Verify that logged output in console as well as endpoint Log

---

## Exercise 2: Change Global Log Level
- In AppWebApi AdminController throw an error in endpoint Environment so the catch clause is invoked and error is logged.
- Edit `appsettings.json` to set `"Default": "Warning"` in the `Logging:LogLevel` section.
- Verify that only warnings and errors are logged by all providers.

---

## Exercise 3: Category-Based Filtering
- In `appsettings.json` set `"Default": "Information"` in the `Logging:LogLevel` section.
- In `appsettings.json`, set `"AppWebApi.Controllers": "None"` under the `Console` provider.
- Trigger actions in a controller and confirm that no controller logs appear in the console, but do appear in the in-memory logger (if enabled).

---

## Exercise 4: Add your own logging
- In Encryptions add a logger. Remember you have to inject a logger ILogger<Encryptions>
- Log at information level a message that confirms AesEncryptToBase64 and AesDecryptFromBase64 has been executed
- In `appsettings.json`, in Logging -> LogLevel set `"Configurations": "Information"
- Verify logging from Encryptions
- In `appsettings.json`, in Logging -> LogLevel set `"Configurations": "None"
- Verify that you no loger log anything from Encryptions
