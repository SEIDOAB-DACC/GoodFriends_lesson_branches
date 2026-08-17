## Branch Differences: `0-microsoft-template` → `1-swagger`

### Overview
Branch `1-swagger` replaces the minimal built-in OpenAPI support with a fully configured Swashbuckle Swagger UI and adds Newtonsoft.Json serialization.

### `AppWebApi/AppWebApi.csproj`
Two NuGet packages are added:

```xml
<PackageReference Include="Swashbuckle.AspNetCore" Version="10.2.3" />
<PackageReference Include="Microsoft.AspNetCore.Mvc.NewtonsoftJson" Version="10.0.10" />
```

- **Swashbuckle.AspNetCore**: Generates the Swagger UI and OpenAPI JSON document at `/swagger`.
- **Microsoft.AspNetCore.Mvc.NewtonsoftJson**: Replaces the default `System.Text.Json` serializer with Newtonsoft.Json, enabling options such as circular-reference handling.

### `AppWebApi/Program.cs`

#### Service registration changes

| `0-microsoft-template` | `1-swagger` |
|---|---|
| `builder.Services.AddControllers()` | `builder.Services.AddControllers().AddNewtonsoftJson(...)` |
| *(not present)* | `builder.Services.AddEndpointsApiExplorer()` |
| *(not present)* | `builder.Services.AddSwaggerGen(...)` |

- **`.AddNewtonsoftJson()`** configures `ReferenceLoopHandling.Ignore` so that object graphs with circular references (e.g. navigation properties) serialize without throwing.
- **`AddEndpointsApiExplorer()`** makes minimal-API endpoints visible to Swashbuckle.
- **`AddSwaggerGen()`** registers a named OpenAPI document `v1` with a custom title, description, and a compile-time conditional version string (`v2.0 DEBUG` / `v2.0`).

#### Middleware pipeline changes

| `0-microsoft-template` | `1-swagger` |
|---|---|
| `if (IsDevelopment()) { app.MapOpenApi(); }` | `app.UseSwagger(); app.UseSwaggerUI(...)` |

- `MapOpenApi()` (ASP.NET Core built-in) is replaced by `UseSwagger()` + `UseSwaggerUI()` from Swashbuckle.
- The `IsDevelopment()` guard is commented out intentionally so the Swagger UI is available in all environments (including production) for this teaching example.
- `UseSwaggerUI()` points to `/swagger/v1/swagger.json` and labels the endpoint *"Seido Friends API v2.0"*.

---

## Security: Microsoft.OpenApi Vulnerability Fix (CVE-2026-49451)

### Issue
The project initially referenced `Microsoft.AspNetCore.OpenApi 10.0.10`, which transitively depended on vulnerable `Microsoft.OpenApi 2.0.0`. This version contained a high-severity vulnerability (GHSA-v5pm-xwqc-g5wc) that could cause process termination through stack overflow when parsing OpenAPI documents with circular schema references.

### Resolution
Added explicit package reference to override the vulnerable transitive dependency:

```xml
<PackageReference Include="Microsoft.OpenApi" Version="2.7.5" />
```

This explicit reference in `AppWebApi.csproj` overrides the vulnerable 2.0.0 version with the patched 2.7.5 version. The fix uses 2.7.5 (not 3.5.4) to maintain compatibility with the 2.x major version line expected by `Microsoft.AspNetCore.OpenApi 10.0.10`.

### Verification
- NU1903 warning eliminated after `dotnet restore`
- CVE-2026-49451 vulnerability patched
- Application remains fully compatible with existing ASP.NET Core OpenAPI functionality

**Reference**: [GitHub Advisory GHSA-v5pm-xwqc-g5wc](https://github.com/advisories/GHSA-v5pm-xwqc-g5wc)

