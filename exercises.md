# Exercises: Custom Controller, Dependency Injection, and Encryption Endpoint

## Exercise 1: Add Your Own Controller
Create a new controller in the `AppWebApi/Controllers` folder. Name it `EncryptionController`.

- Make sure your controller class is decorated with `[ApiController]` and `[Route("api/[controller]/[action]")]`.
- Add a simple GET endpoint that returns a welcome message or your name.

## Exercise 2: Inject the `Encryptions` Service
Modify your new controller to use dependency injection for the `Encryptions` service.

- Add a private readonly field for `Encryptions`.
- Add a constructor parameter for `Encryptions` and assign it to your field.
- (Tip: See how `AdminController` injects its dependencies for reference.)

## Exercise 3: Create an Endpoint to Encrypt a Password
Add a new endpoint to your controller that accepts a password as a parameter and returns the encrypted (hashed) version.

- Add a `GET` endpoint, e.g., `[HttpGet()] [ActionName("EncryptPassword")]`.
- Accept a string parameter, e.g., `string password`.
- Use the injected `Encryptions` service to call `EncryptPasswordToBase64(password)`.
- Return the encrypted password as the response.

**Bonus:** Add error handling for empty or null passwords.

---

By completing these exercises, you'll practice creating controllers, using dependency injection, and building secure endpoints in ASP.NET Core.
