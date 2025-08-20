# Exercises: Custom Controller, Dependency Injection, and Encryption Endpoint

## Exercise 1: Add Your Own Controller
Create a new controller in the `AppWebApi/Controllers` folder. Name it `EncryptionController`.

- Make sure your controller class is decorated with `[ApiController]` and `[Route("api/[controller]/[action]")]`.
- Add a simple GET endpoint that returns a welcome message or your name.

## Exercise 2: Add and Use Custom Configuration with Options Pattern
Add a simple configuration structure to your `appsettings.json` (for example, a section called `MySettings` with a few properties).

- Create a C# options class (e.g., `MySettingsOptions`) that matches your configuration structure.
- Register the options class in `Program.cs` using `builder.Services.Configure<MySettingsOptions>(...)`.
- Inject `IOptions<MySettingsOptions>` into your controller.
- Add an endpoint that returns the values from your custom configuration section.

## Exercise 3: Inject the `Encryptions` Service
Modify your new controller to use dependency injection for the `Encryptions` service.

- Add a private readonly field for `Encryptions`.
- Add a constructor parameter for `Encryptions` and assign it to your field.
- (Tip: See how `AdminController` injects its dependencies for reference.)

## Exercise 4: Encrypt MySettingsOption with AES
Add an endpoint to your controller that uses the injected `Encryptions` service to AES-encrypt your `MySettingsOption` object and return the result as a Base64 string.

- Use the options instance from `IOptions<MySettingsOptions>`.
- Call `_encryptions.AesEncryptToBase64(mySettingsOptions.Value)`.
- Return the encrypted Base64 string in the response.

## Exercise 5: Decrypt MySettingsOption from Base64
Add an endpoint that accepts an encrypted Base64 string (as a parameter), decrypts it using the `Encryptions` service, and returns the resulting `MySettingsOptions` object.

- Accept the encrypted string as a parameter (e.g., `string encrypted`).
- Call `_encryptions.AesDecryptFromBase64<MySettingsOptions>(encrypted)`.
- Return the decrypted object in the response.

## Exercise 6: Create an Endpoint to Encrypt a Password
Add a new endpoint to your controller that accepts a password as a parameter and returns the encrypted (hashed) version.

- Add a `GET` endpoint, e.g., `[HttpGet()] [ActionName("EncryptPassword")]`.
- Accept a string parameter, e.g., `string password`.
- Use the injected `Encryptions` service to call `EncryptPasswordToBase64(password)`.
- Return the encrypted password as the response.


**Bonus:** Add error handling for empty or null passwords.



---

By completing these exercises, you'll practice creating controllers, using dependency injection, and building secure endpoints in ASP.NET Core.
