
# AppWebApi Project Overview

## AppWebApi Project Structure and Content

The **AppWebApi** project is the main Web API application built with ASP.NET Core 10.0. 
It serves as the entry point for the GoodFriends application, providing RESTful API endpoints for client applications. 
This project demonstrates modern ASP.NET Core development practices including dependency injection, middleware configuration, and API documentation.

The `GoodFriends` solution is architected for clarity, maintainability, and scalability. 
In the following branches, the solution structure follows ASP.NET Core best practices and provides a solid foundation for a scalable Web API application 
with proper separation of concerns, comprehensive logging, and robust configuration management.


### Project Configuration (AppWebApi.csproj)

The project file defines:
- **Target Framework**: .NET 10.0 with implicit using statements enabled
- **Key Dependencies**:
  - `Microsoft.AspNetCore.OpenApi` (10.0.10) - OpenAPI specification support
  - `Swashbuckle.AspNetCore` (10.2.3) - Swagger UI for API documentation
  - `Microsoft.AspNetCore.Mvc.NewtonsoftJson` (10.0.10) - JSON serialization with Newtonsoft
- **Assembly Metadata**: Versioning, build timestamps, company information, and build environment details
- **Product Information**: "Seido Friends Api" by Seido AB for training purposes

### Core Files

#### Program.cs - Application Entry Point
The main entry point configures:
- **CORS Policy**: Global policy allowing any origin, header, and method for frontend integration
- **JSON Serialization**: Configured to ignore reference loops (essential for Entity Framework navigation properties)
- **Swagger/OpenAPI**: API documentation with dynamic versioning and environment-specific titles
- **Logging**: Console and debug providers for development and production diagnostics
- **Middleware Pipeline**: HTTPS redirection, CORS, authorization, and controller routing

#### Controllers/AdminController.cs
Provides administrative and diagnostic endpoints:
- `GET: api/admin/helloworld` - Connectivity test endpoint returning a greeting with timestamp
- `GET: api/admin/version` - Returns detailed version information from assembly metadata
- Demonstrates dependency injection, structured error handling, and logging practices

#### SeedGenerator.cs
A comprehensive utility class (900+ lines) providing:
- **ISeed<T> Interface**: Contract for seeded data generation
- **Data Generation**: Random names, addresses, dates, Latin text, and various data types
- **Localization Support**: Multiple languages and cultural contexts
- **JSON Serialization**: Integrated with Newtonsoft.Json for data export

#### app-seeds.json
Contains seed data for application initialization and testing purposes using the SeedGenerator

#### VersionInfo.cs
Version information model containing:
- Assembly versions (AssemblyVersion, FileVersion, InformationalVersion)
- Build metadata (BuildTime, BuildMachine, BuildUser)
- Product information (Company, Product, Description, Copyright)
- Git commit tracking and company URL

### Configuration Files

#### appsettings.json
Configures application settings:
- **Logging Configuration**: Different log levels for various providers (Console, InMemory)
- **Database Connections**: Settings for data set tags and default users
- **Environment-specific**: Separate configurations for development and production


### Build Outputs

#### bin/ and obj/ Directories
Standard .NET build outputs containing compiled assemblies, dependencies, and temporary build files.

#### publish/ Directory
Production deployment artifacts including:
- Main application files (AppWebApi.dll, configuration files)
- Referenced project assemblies (Configuration.dll, DbContext.dll, DbModels.dll, DbRepos.dll)
- Third-party dependencies (Entity Framework, Azure libraries, JWT authentication)
- Runtime configuration and static web assets

### Properties/launchSettings.json
Development environment configuration for:
- Development server profiles
- Environment variables
- Launch URLs and ports
- SSL settings



## Microsoft Controller Architecture in ASP.NET Core

In ASP.NET Core, the Controller architecture is based on the Model-View-Controller (MVC) pattern, which separates application logic into three main components:

- **Model:** Represents the application's data and business logic. Models are typically classes that define the structure of data and may include validation or domain logic.

- **View:** Handles the presentation layer. In Web APIs, views are often replaced by data returned in JSON or XML format, rather than HTML.

- **Controller:** Acts as the intermediary between models and views. Controllers handle incoming HTTP requests, process user input, interact with models, and return responses. In Web APIs, controllers inherit from the `ControllerBase` or `Controller` class and use attributes (such as `[ApiController]`, `[Route]`, `[HttpGet]`, etc.) to define routing and behavior.

Key features of the controller architecture include:
- **Routing:** Controllers use attribute routing to map HTTP requests to specific action methods.
- **Dependency Injection:** Services such as logging, database contexts, or custom services are injected into controllers via constructor injection, promoting loose coupling and testability.
- **Action Methods:** Each public method in a controller that responds to HTTP requests is called an action. These methods return data (e.g., `IActionResult`, `ActionResult<T>`) to the client.
- **Filters and Middleware:** Controllers can leverage filters (e.g., for authorization, exception handling) and the broader middleware pipeline for cross-cutting concerns.
- **Automatic Model Binding and Validation:** ASP.NET Core automatically binds incoming request data to action parameters and validates them based on data annotations.

This architecture promotes separation of concerns, maintainability, and scalability, making it suitable for both small and large enterprise applications.

The `Program.cs` file is the main entry point for the AppWebApi application. 
It configures services, middleware, and the HTTP request pipeline using the minimal hosting model introduced in .NET 6+. 

Below is a breakdown of its key sections:

1. **WebApplication Builder Initialization**
  - `var builder = WebApplication.CreateBuilder(args);` initializes the application builder with default settings and command-line arguments.

2. **CORS Policy Configuration**
  - The global CORS policy allows any origin, header, and method. 
  This is essential for enabling frontend applications (such as React or Angular) to interact with the API during development and production.

3. **Controller and JSON Serialization Setup**
  - Controllers are registered, and JSON serialization is configured to ignore reference loops, preventing serialization errors with complex object graphs (e.g., Entity Framework navigation properties).

4. **Swagger/OpenAPI Configuration**
  - Swagger is set up for API documentation and testing. The configuration includes dynamic versioning and descriptive metadata, 
    making it easier for developers and students to understand and test the API endpoints.

5. **Logging**
  - Logging providers are configured to output to both the console and debug window, aiding diagnostics and monitoring.

6. **Middleware Pipeline**
  - The HTTP request pipeline is configured to:
    - Enable Swagger UI for API documentation
    - Enforce HTTPS redirection
    - Enable CORS
    - Enable authorization
    - Map controller endpoints
  - The application is then started with `app.Run();`.



### AdminController.cs – Administrative Endpoints and Controller Architecture

The `AdminController` provides endpoints for administrative and diagnostic purposes. 
It demonstrates basic controller structure, dependency injection, and error handling in ASP.NET Core.

#### AdminController Structure and Endpoints

1. **Controller Attributes**
  - `[ApiController]` and `[Route("api/[controller]/[action]")]` define routing conventions and enable automatic model validation and response formatting.

2. **Dependency Injection**
  - The constructor injects `ILogger<AdminController>` for logging and `IWebHostEnvironment` for environment-specific logic.

3. **HelloWorld Endpoint**
  - `GET: api/admin/helloworld` returns a simple greeting object with a timestamp. This endpoint is useful for connectivity tests and as a template for further endpoints.

4. **Version Endpoint**
  - `GET: api/admin/version` returns version information extracted from assembly metadata. It demonstrates structured error handling and logging.

## .NET Application Versioning Explained

.NET applications use three main version types, each serving different purposes in the software development and deployment lifecycle.

### Three Main Version Types

#### 1. AssemblyVersion
- **Purpose**: Compile-time version for .NET runtime assembly binding
- **Format**: Major.Minor.Build.Revision (all 4 parts required)
- **Example**: 1.0.0.0
- **Usage**: Used by .NET runtime for assembly resolution; referenced assemblies must match this version exactly; controls assembly loading compatibility
- **Best Practice**: Only change for breaking changes to avoid binding issues

#### 2. FileVersion  
- **Purpose**: Windows file system version shown in file properties
- **Format**: Major.Minor.Build.Revision (all 4 parts required)
- **Example**: 1.0.0.0
- **Usage**: Displayed in Windows Explorer file properties; used by Windows installers and deployment tools; can be incremented with every build
- **Best Practice**: Increment for every release, including patch releases

#### 3. InformationalVersion
- **Purpose**: Product marketing version - human-readable version string
- **Format**: Flexible format, supports Semantic Versioning (SemVer)
- **Examples**: 1.0.2, 1.0.2-alpha, 1.0.2-beta.1, 1.0.2+build.123
- **Usage**: Displayed to end users; used in logs, about dialogs, API responses; can include build metadata and pre-release identifiers
- **Best Practice**: Follow Semantic Versioning (SemVer) format

### Microsoft's Recommended Versioning Strategy

- **AssemblyVersion**: Change only for breaking changes (1.0.0.0 → 2.0.0.0)
- **FileVersion**: Increment for every build (1.0.0.1 → 1.0.0.2 → 1.0.0.3)
- **InformationalVersion**: Follow SemVer for user communication (1.0.0 → 1.0.1 → 1.1.0 → 2.0.0)

### Versioning Scenarios

#### Major Release with Breaking Changes:
```xml
<AssemblyVersion>2.0.0.0</AssemblyVersion>
<FileVersion>2.0.0.1</FileVersion>
<InformationalVersion>2.0.0</InformationalVersion>
```

#### Patch Release:
```xml
<AssemblyVersion>2.0.0.0</AssemblyVersion>     <!-- Unchanged -->
<FileVersion>2.0.1.15</FileVersion>            <!-- Build number -->
<InformationalVersion>2.0.1</InformationalVersion>
```

#### Pre-release Version:
```xml
<AssemblyVersion>2.0.0.0</AssemblyVersion>
<FileVersion>2.1.0.5</FileVersion>
<InformationalVersion>2.1.0-beta.1</InformationalVersion>
```

### Additional Metadata

The project includes comprehensive build metadata:
- **BuildTime**: Timestamp when assembly was compiled
- **BuildMachine**: Computer name where build occurred
- **BuildUser**: Username who performed the build
- **AssemblyTitle**: Human-readable title of the assembly
- **AssemblyDescription**: Description of what the assembly does
- **AssemblyCompany**: Company name
- **AssemblyProduct**: Product name
- **AssemblyCopyright**: Copyright information

### Implementation in Current Project

The AppWebApi.csproj configuration demonstrates Microsoft's recommended pattern:
```xml
<AssemblyVersion>1.0.0.0</AssemblyVersion>
<FileVersion>1.0.0.0</FileVersion>
<InformationalVersion>1.0.2</InformationalVersion>
```

Build metadata is automatically generated:
```xml
<AssemblyMetadata Include="BuildTime" Value="$([System.DateTime]::UtcNow.ToString(&quot;yyyy-MM-dd HH:mm:ss&quot;)) UTC" />
<AssemblyMetadata Include="BuildMachine" Value="$([System.Environment]::MachineName)" />
<AssemblyMetadata Include="BuildUser" Value="$([System.Environment]::UserName)" />
```

### API Endpoint

The `GET /api/admin/version` endpoint returns complete version information including:
- All three version types
- Build metadata (time, machine, user)
- Assembly information (title, description, company, etc.)
- Current server time
- Environment name

### Benefits

1. **Runtime Compatibility**: AssemblyVersion ensures proper assembly loading
2. **Deployment Tracking**: FileVersion helps track deployments and updates
3. **User Communication**: InformationalVersion provides clear release information
4. **Build Traceability**: Metadata tracks when, where, and by whom builds were created
5. **Debugging Support**: Complete version info aids in troubleshooting

