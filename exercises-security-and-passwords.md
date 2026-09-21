# Exercises: SQL Server Roles, Connection Users & Password Encryption

These exercises use the GoodFriends solution to explore how the app authenticates to SQL
Server, how SQL Server role grants limit access, and how user passwords are hashed and
validated. They reference:

- [DbContext/SqlScripts/sqlserver/initDatabase.sql](DbContext/SqlScripts/sqlserver/initDatabase.sql) — creates logins `gstusr`, `usr`, `supusr`, `dbo`, the roles `gstUsrRole`, `usrRole`, `supUsrRole`, the `gstusr.spLogin` procedure, and grants.
- [DbRepos/AdminDbRepos.cs](DbRepos/AdminDbRepos.cs) — `SeedUsersAsync` (seeds `user{n}`, `superuser{n}`, `dbo{n}` with per-user passwords).
- [DbRepos/LoginDbRepos.cs](DbRepos/LoginDbRepos.cs) — `LoginUserAsync` calls `gstusr.spLogin`.
- [AppWebApi/appsettings.json](AppWebApi/appsettings.json) — `DatabaseConnections:DefaultDataUser` selects which SQL login (`gstusr`|`usr`|`supusr`|`dbo`|`root`) the app connects as.
- [AppWebApi/Controllers/GuestController.cs](AppWebApi/Controllers/GuestController.cs) — `LoginUser` action, password/username regex validation.

> All exercises assume a local Dockerized SQL Server rebuilt with the scripts in `_scripts/database-rebuild-all.sh` (or `.ps1`), which runs `initDatabase.sql`.

---

## Exercise 1 — Change `DefaultDataUser` and observe SQL Server role limits

**Concept:** The app connects to SQL Server as whichever login `DatabaseConnections:DefaultDataUser` names. Each login is a member of a role (`gstUsrRole`, `usrRole`, `supUsrRole`, or `db_owner`) with different grants:

```sql
GRANT SELECT, EXECUTE ON SCHEMA::gstusr to gstUsrRole;
GRANT SELECT, UPDATE, INSERT ON SCHEMA::supusr to usrRole;
GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE ON SCHEMA::supusr to supUsrRole;
```

`gstUsrRole` only has grants **on the `gstusr` schema itself** — `gstusr.vwInfoDb`, `gstusr.vwInfoFriends`, `gstusr.vwInfoPets`, `gstusr.vwInfoQuotes` and `gstusr.spLogin`. It has **no grant at all on the `supusr` schema**, so a `gstusr` connection can never read `supusr.Friends`, `supusr.Addresses`, `supusr.Pets` or `supusr.Quotes` directly — only indirectly, by going through one of the `gstusr` views, which are allowed to read `supusr` tables via SQL Server's ownership-chaining (the view and the underlying tables share the same owner, so the view's *own* permissions apply, not the caller's).

**Steps:**
1. In [AppWebApi/appsettings.json](AppWebApi/appsettings.json), set `"DefaultDataUser": "gstusr"` and run the API.
2. Call `GET api/admin/Info` (backed by `AdminDbRepos.DbInfo()`, which queries `gstusr.vwInfoDb`/`vwInfoFriends`/`vwInfoPets`/`vwInfoQuotes`). Confirm this **succeeds** — these are all objects inside the `gstusr` schema, so `SELECT` is granted directly, and the views can read the `supusr` tables on `gstusr`'s behalf via ownership chaining.
3. Now try to read a `supusr` table **directly**, bypassing the views — e.g. connect to SQL Server as the `gstusr` login itself and run:
   ```sql
   SELECT * FROM supusr.Friends;
   ```
   Confirm this **fails** with a permission-denied error, even though the exact same data was readable a moment ago through `gstusr.vwInfoFriends`. This is the key lesson: a schema-level grant on `gstusr` does not extend to `supusr` — only the views do, and only because of ownership chaining.
4. Call an endpoint that writes data, e.g. `POST api/admin/Seed` (uses `supusr.Friends` etc., requires INSERT on `supusr`). Confirm it fails — `gstusr` only has `SELECT, EXECUTE` on the `gstusr` schema, nothing on `supusr`.
5. Change `DefaultDataUser` to `"usr"` and retry step 4. It should now succeed for INSERT/UPDATE/SELECT on `supusr`, but still fail for anything requiring `DELETE` or `EXECUTE` on `supusr` (e.g. `RemoveSeedAsync`, which calls `supusr.spDeleteAll`). Also confirm `usr` **can** now `SELECT * FROM supusr.Friends` directly, unlike `gstusr`.
6. Change `DefaultDataUser` to `"supusr"` and confirm `RemoveSeedAsync` now works (has `EXECUTE` on `supusr`).
7. Change `DefaultDataUser` to `"dbo"` and confirm everything works (member of built-in `db_owner`).

**Deliverable:** A short table of `DefaultDataUser` value → which endpoints/queries succeed/fail (including the direct `supusr.Friends` table query vs. the `gstusr.vwInfoFriends` view) → the exact SQL Server error message (permission denied on object/schema) captured from the API's `BadRequest` response or SSMS.

---

## Exercise 2 — Trace the active connection via `ResponseItemDto.ConnectionString`

**Concept:** In `#if DEBUG` builds, `AdminDbRepos` and `LoginDbRepos` both return `ConnectionString = _dbContext.dbConnection` inside their `ResponseItemDto`/`ResponseItemDto<T>` results, so a debug build exposes exactly which connection is in use.

**Steps:**
1. Run the API in a `Debug` configuration.
2. Call `GET api/admin/Info` (or `POST api/guest/LoginUser`) and inspect the JSON response body for the `ConnectionString` field.
3. Change `DatabaseConnections:DefaultDataUser` in `appsettings.json` (e.g. `gstusr` → `usr` → `dbo`) between calls and repeat, recording how `ConnectionString` changes each time (different SQL login embedded in the connection string).
4. **Question:** Why is this field wrapped in `#if DEBUG`? What security risk would exist if it also appeared in a `Release`/production build?
5. **Question:** `DatabaseConnections` resolves the connection string once per request via `GetDataConnectionDetails(user)` — is the DB connection re-resolved on every HTTP call, or cached for the lifetime of the app? Inspect how `MainDbContext` / `DatabaseConnections` are registered in DI (`Scoped` vs `Singleton`) to justify your answer.

---

## Exercise 3 — Revoke `EXECUTE` on `gstusr.spLogin` and attempt a login

**Concept:** `LoginDbRepos.LoginUserAsync` executes the stored procedure `gstusr.spLogin` while connected as whichever login is configured (commonly `gstusr`, a member of `gstUsrRole`). `gstUsrRole` currently has `EXECUTE` on the whole `gstusr` schema.

**Steps:**
1. Connect to SQL Server as `sa`/admin and run:
   ```sql
   USE [sql-friends];
   DENY EXECUTE ON OBJECT::gstusr.spLogin TO gstUsrRole;
   ```
2. Ensure `appsettings.json` has `"DefaultDataUser": "gstusr"` and restart the API.
3. Call `POST api/guest/LoginUser` with valid credentials (e.g. `user1` / `user1`, seeded by `SeedUsersAsync`).
4. Observe the response: `LoginUser`'s `catch` block returns `BadRequest($"Login Error: {ex.Message}")`. Record the underlying SQL Server error (permission denied on object `spLogin`).
5. **Question:** In `GuestController.LoginUser`, the username/password format is validated with regex *before* `LoginUserAsync` is called. Does that validation run and pass even though the SQL call is doomed to fail? Why is client-side/API-side validation still worth doing even when the database will also reject the call?
6. Restore access:
   ```sql
   GRANT EXECUTE ON OBJECT::gstusr.spLogin TO gstUsrRole;
   ```

---

## Exercise 4 — Seed one strong demo password and enforce strong-password validation

**Concept:** Today `SeedUsersAsync` gives every seeded user a distinct, weak password equal to their own username (e.g. `user1`'s password is `"user1"`), and `GuestController.LoginUser` validates passwords with a weak pattern:

```csharp
var pSimple = @"^([a-z]|[A-Z]|[0-9]){4,12}$";
```

**Steps:**
1. In [DbRepos/AdminDbRepos.cs](DbRepos/AdminDbRepos.cs), add a visible constant and use it for every seeded password:
   ```csharp
   public class AdminDbRepos
   {
       private const string _seedSource = "./app-seeds.json";
       private const string DemoPassword = "Str0ng!Pw#2026"; // visible on purpose for this exercise
       // ...
   ```
   Replace `_encryptions.EncryptPasswordToBase64($"user{i}")`, `$"superuser{i}"`, `$"dbo{i}"` with `_encryptions.EncryptPasswordToBase64(DemoPassword)` in all three seeding loops.
2. Re-seed the database so every user now shares `DemoPassword`.
3. In [AppWebApi/Controllers/GuestController.cs](AppWebApi/Controllers/GuestController.cs), replace `pSimple`'s use for password validation with a stronger rule — at least 8 characters, one upper-case, one lower-case, one digit, one special character:
   ```csharp
   var pStrongPassword = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!#$%&*_\-]).{8,20}$";
   // ...
   r = new Regex(pStrongPassword);
   if (!r.Match(userCreds.Password).Success) throw new ArgumentException("Password must be 8-20 characters with upper, lower, digit and special character");
   ```
   Leave the username/email pattern (`pUNoE`) as-is.
4. Call `POST api/guest/LoginUser` with `{ "userNameOrEmail": "user1", "password": "user1" }` — this must now fail the new regex (the old weak password no longer matches the stronger rule and is also no longer what's stored).
5. Call it again with `{ "userNameOrEmail": "user1", "password": "Str0ng!Pw#2026" }` (`DemoPassword`) — this must pass validation, reach `LoginUserAsync`, match the re-encrypted value in `dbo.Users`, and return a successful `LoginUserSessionDto`.
6. **Question:** Why must the regex change and the seeded-password change be made together? What happens if you only change the regex (old weak passwords still stored) or only change the seed password (old weak regex still accepts `"user1"`-style input but the stored password no longer matches it)?
