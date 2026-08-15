# AppWebApi Folder Structure and File Purpose

This document explains the structure of the `AppWebApi` folder and the purpose of each file in the project.

## Creating a Web API Project

To create a new ASP.NET Core Web API project, used in the branch, using the .NET CLI:

```bash
# Create a new Web API project
dotnet new webapi -n MyWebApi

```

## Folder Structure

```
AppWebApi/
├── appsettings.Development.json
├── appsettings.json
├── AppWebApi.csproj
├── AppWebApi.http
├── Program.cs
├── WeatherForecast.cs
├── bin/
├── Controllers/
│   └── WeatherForecastController.cs
├── obj/
├── Properties/
│   └── launchSettings.json
```

## File and Folder Purposes

- **appsettings.Development.json**: Configuration settings for the development environment.
- **appsettings.json**: Main configuration file for the application (connection strings, logging, etc.).
- **AppWebApi.csproj**: Project file defining dependencies, build settings, and project metadata.
- **AppWebApi.http**: HTTP request file for testing API endpoints directly from the editor. You will need VSC “REST Client” extension by Huachao Mao
- **Program.cs**: Entry point of the application; configures and starts the web server.
- **WeatherForecast.cs**: Model class used for the weather forecast example endpoint.
- **bin/**: Output directory for compiled binaries and runtime files.
- **Controllers/**: Contains API controller classes.
  - **WeatherForecastController.cs**: Example controller exposing weather forecast endpoints.
- **obj/**: Intermediate build files and project assets.
- **Properties/**: Contains project properties and settings.
  - **launchSettings.json**: Defines how the project is launched (profiles, environment variables, etc.).
---

This structure follows standard ASP.NET Core Web API conventions, supporting configuration, development, and deployment workflows.

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

