# JWT Security Implementation in GoodFriends AppWebApi

## Table of Contents
1. [What is JWT and How It Works](#what-is-jwt-and-how-it-works)
2. [JWT Token Generation in Configuration/JwtEncryptions](#jwt-token-generation)
3. [Swagger Integration with JWT](#swagger-integration-with-jwt)
4. [Role-Based Database Context Creation](#role-based-database-context-creation)
5. [Complete Authentication Flow](#complete-authentication-flow)

---

## What is JWT and How It Works

### What is JWT?
**JWT (JSON Web Token)** is a secure way to transmit information between parties as a JSON object. Think of it as a digital passport that proves who you are and what you're allowed to do.

### JWT Structure
A JWT token consists of three parts separated by dots (`.`):
```
header.payload.signature
```

1. **Header**: Contains metadata about the token (algorithm used, token type)
2. **Payload**: Contains claims (user information, roles, permissions)
3. **Signature**: Ensures the token hasn't been tampered with

### How JWT Works - Simple Explanation
1. **Login**: User provides username/password
2. **Verification**: Server checks credentials against database
3. **Token Creation**: If valid, server creates a JWT token with user information
4. **Token Return**: Server sends token back to client
5. **Future Requests**: Client includes token in HTTP headers
6. **Token Validation**: Server validates token and extracts user information
7. **Access Granted**: If valid, server processes the request

### Benefits of JWT
- **Stateless**: Server doesn't need to store session information
- **Secure**: Cryptographically signed to prevent tampering
- **Portable**: Can be used across different services
- **Self-contained**: Contains all necessary user information

---

## JWT Token Generation

### Configuration Structure
The JWT system is configured through the `JwtOptions` class in `Configuration/Options/JwtOptions.cs`:

```csharp
public class JwtOptions
{
    public int LifeTimeMinutes { get; set; }          // How long token is valid
    public string IssuerSigningKey { get; set; }     // Secret key for signing
    public string ValidIssuer { get; set; }          // Who issued the token
    public string ValidAudience { get; set; }        // Who can use the token
    public bool ValidateIssuerSigningKey { get; set; }
    public bool ValidateIssuer { get; set; }
    public bool ValidateAudience { get; set; }
    public bool RequireExpirationTime { get; set; }
}
```

### Token Creation Process in JwtEncryptions.cs

#### 1. Claims Creation
```csharp
private IEnumerable<Claim> CreateClaims(Guid TokenId, string Role, IDictionary<string, string> userClaims)
{
    // Start with custom user claims (UserId, UserName, etc.)
    IEnumerable<Claim> claims = new List<Claim>();
    foreach (var kvp in userClaims)
    {
        claims = claims.Append(new Claim(kvp.Key, kvp.Value));
    }

    // Add standard Microsoft claims for authentication pipeline
    claims = claims.Append(new Claim(ClaimTypes.Expiration, /*expiration time*/));
    claims = claims.Append(new Claim(ClaimTypes.NameIdentifier, TokenId.ToString()));
    claims = claims.Append(new Claim(ClaimTypes.Role, Role));  // Important for authorization
    
    return claims;
}
```

#### 2. Token Generation
```csharp
public JwtToken CreateToken(string Role, IDictionary<string, string> userClaims)
{
    // Generate unique token ID
    Guid tokenId = Guid.NewGuid();
    
    // Get secret key from configuration (stored in user-secrets)
    var encryptionKey = System.Text.Encoding.ASCII.GetBytes(_jwtOptions.IssuerSigningKey);
    
    // Set expiration time
    DateTime expireTime = DateTime.UtcNow.AddMinutes(_jwtOptions.LifeTimeMinutes);

    // Create the actual JWT token
    var JWToken = new JwtSecurityToken(
        issuer: _jwtOptions.ValidIssuer,           // Who created this token
        audience: _jwtOptions.ValidAudience,       // Who can use this token
        claims: CreateClaims(tokenId, Role, userClaims),  // User information
        notBefore: DateTime.UtcNow,                // When token becomes valid
        expires: expireTime,                       // When token expires
        signingCredentials: new SigningCredentials(
            new SymmetricSecurityKey(encryptionKey), 
            SecurityAlgorithms.HmacSha256)         // Cryptographic signature
    );

    // Convert to string format
    token.EncryptedToken = new JwtSecurityTokenHandler().WriteToken(JWToken);
    return token;
}
```

#### 3. Token Decryption
```csharp
public IDictionary<string, string> GetClaimsFromToken(string encryptedtoken)
{
    if (encryptedtoken == null) return null;

    // Parse the token and extract claims
    var decodedToken = new JwtSecurityTokenHandler().ReadJwtToken(encryptedtoken);
    return decodedToken?.Claims?.ToDictionary(c => c.Type, c => c.Value);
}
```

---

## Swagger Integration with JWT

### Swagger Configuration in Program.cs

The Swagger UI is enhanced to support JWT authentication, allowing developers to test protected endpoints:

```csharp
builder.Services.AddSwaggerGen(c =>
{
    // Basic Swagger configuration
    c.SwaggerDoc("v1", new() { Title = "Seido Friends API", Version = "v2.0" });

    // Add JWT Authentication to Swagger UI
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",                    // Header name
        Type = SecuritySchemeType.Http,           // HTTP authentication
        Scheme = "Bearer",                        // Bearer token scheme
        BearerFormat = "JWT",                     // Token format
        In = ParameterLocation.Header,            // Where to include token
        Description = "JWT Authorization header using the Bearer scheme."
    });

    // Require JWT for all endpoints that need authentication
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme {
                Reference = new OpenApiReference {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"              // References the definition above
                }
            },
            new string[] {}                // No specific scopes required
        }
    });
});
```

### How This Works in Swagger UI
1. **Authorize Button**: Swagger UI shows a green "Authorize" button
2. **Token Input**: Click the button to enter your JWT token
3. **Automatic Headers**: Swagger automatically adds `Authorization: Bearer <token>` to requests
4. **Testing Protected Endpoints**: You can now test endpoints that require authentication

### JWT Setup in ASP.NET Core Pipeline

The `JWTExtensions.cs` configures ASP.NET Core to use JWT authentication:

```csharp
public static void AddJwtToken(this IServiceCollection Services, IConfiguration configuration)
{
    // Configure ASP.NET Core Authentication
    Services.AddAuthentication(options => {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options => {
        var jwtOptions = configuration.GetSection(JwtOptions.Position).Get<JwtOptions>();
        
        // Configure how tokens are validated
        options.TokenValidationParameters = new TokenValidationParameters()
        {
            ValidateIssuerSigningKey = jwtOptions.ValidateIssuerSigningKey,
            IssuerSigningKey = new SymmetricSecurityKey(
                System.Text.Encoding.UTF8.GetBytes(jwtOptions.IssuerSigningKey)),
            ValidateIssuer = jwtOptions.ValidateIssuer,
            ValidIssuer = jwtOptions.ValidIssuer,
            ValidateAudience = jwtOptions.ValidateAudience,
            ValidAudience = jwtOptions.ValidAudience,
            RequireExpirationTime = jwtOptions.RequireExpirationTime,
            ValidateLifetime = jwtOptions.RequireExpirationTime,
            ClockSkew = TimeSpan.FromDays(1)  // Allow for time differences
        };
    });
}
```

---

## Role-Based Database Context Creation

### The Problem
Different users (Admin, User, Guest) should have access to different database connections with different permission levels. The system needs to:
1. Extract the user role from the JWT token
2. Select the appropriate database connection based on that role
3. Create a DbContext with the correct connection

### How JWT Decoding Works in DbContext Creation

The `DbContextExtensions.cs` implements this functionality:

```csharp
public static IServiceCollection AddUserBasedDbContext(this IServiceCollection serviceCollection)
{
    serviceCollection.AddDbContext<MainDbContext>((serviceProvider, options) => 
    { 
        // Get required services
        var configuration = serviceProvider.GetRequiredService<IConfiguration>(); 
        var databaseConnections = serviceProvider.GetRequiredService<DatabaseConnections>(); 
        var jwtEncryptions = serviceProvider.GetRequiredService<JwtEncryptions>(); 
        var httpContextAccessor = serviceProvider.GetRequiredService<IHttpContextAccessor>(); 
        
        // Default to configuration setting
        var userRole = configuration["DatabaseConnections:DefaultDataUser"];
        
        // Try to get user role from JWT token
        var httpContext = httpContextAccessor.HttpContext; 
        if (httpContext != null) 
        { 
            // Extract JWT token from HTTP request
            var token = httpContext.GetTokenAsync("access_token").Result;
            if (token != null)
            {
                // Decode the JWT token to get claims
                var claims = jwtEncryptions.GetClaimsFromToken(token);
                
                // Extract user role from claims
                userRole = claims["UserRole"];  // This was set during login
            }
        } 
        
        // Get database connection based on user role
        var conn = databaseConnections.GetDataConnectionDetails(userRole);
        
        // Configure Entity Framework with the appropriate connection
        if (databaseConnections.SetupInfo.DataConnectionServer == DatabaseServer.SQLServer)
        {
            options.UseSqlServer(conn.DbConnectionString, 
                options => options.EnableRetryOnFailure());
        }
        // ... other database types
    });
}
```

### Step-by-Step Process

1. **HTTP Request Arrives**: A request comes to a protected endpoint
2. **JWT Token Extraction**: System extracts JWT from `Authorization` header
3. **Token Decoding**: `JwtEncryptions.GetClaimsFromToken()` parses the token
4. **Role Extraction**: Gets `UserRole` claim from decoded token
5. **Connection Selection**: `DatabaseConnections.GetDataConnectionDetails(userRole)` returns appropriate connection
6. **DbContext Creation**: Entity Framework creates context with role-specific connection
7. **Data Access**: Repository uses this context for database operations

### Role-Based Security Benefits

- **Admin Role**: Gets connection with full database permissions
- **User Role**: Gets connection with limited read/write permissions
- **Guest Role**: Gets connection with read-only permissions
- **Security**: Database-level security enforced by connection permissions
- **Scalability**: Different roles can use different database servers if needed

---

## Complete Authentication Flow

### 1. Login Process (`LoginService.cs`)
```csharp
public async Task<ResponseItemDto<LoginUserSessionDto>> LoginUserAsync(LoginCredentialsDto usrCreds)
{
    // Verify credentials against database
    var usrSession = await _repo.LoginUserAsync(usrCreds);

    // Create claims with user information
    IDictionary<string, string> userClaims = new Dictionary<string, string>();
    userClaims["UserId"] = usrSession.Item.UserId.ToString();
    userClaims["UserRole"] = usrSession.Item.UserRole;        // Critical for DB context
    userClaims["UserName"] = usrSession.Item.UserName;

    // Generate JWT token with user claims
    usrSession.Item.JwtToken = _jwtEncryptions.CreateToken(
        usrSession.Item.UserRole, userClaims);

    return usrSession;
}
```

### 2. Controller Protection
Controllers use the `[Authorize]` attribute to require JWT authentication:
```csharp
[Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme, Roles = "Admin")]
[HttpGet("RemoveAllSeeds")]
public async Task<IActionResult> RemoveAllSeeds()
{
    // Only Admin role can access this endpoint
    // DbContext will automatically use Admin database connection
}
```

### 3. Request Processing Flow
1. **Client Request**: Includes `Authorization: Bearer <jwt-token>` header
2. **ASP.NET Core Middleware**: Validates JWT token signature and expiration
3. **Claims Extraction**: Populates `HttpContext.User` with claims from token
4. **Authorization Check**: Verifies user has required role for endpoint
5. **DbContext Creation**: Uses JWT claims to select appropriate database connection
6. **Repository Operations**: Execute with role-appropriate database permissions
7. **Response**: Returns data according to user's permission level

### 4. Security Layers
- **JWT Signature**: Prevents token tampering
- **Token Expiration**: Limits exposure time if token is compromised
- **Role-Based Authorization**: Controls endpoint access
- **Database-Level Security**: Enforces data access permissions
- **HTTPS**: Encrypts token transmission

---

## Configuration Requirements

### User Secrets (Development)
```json
{
  "JwtConfig": {
    "IssuerSigningKey": "your-secret-key-here-must-be-long-enough",
    "ValidIssuer": "https://yourdomain.com",
    "ValidAudience": "https://yourdomain.com",
    "LifeTimeMinutes": 60,
    "ValidateIssuerSigningKey": true,
    "ValidateIssuer": true,
    "ValidateAudience": true,
    "RequireExpirationTime": true
  }
}
```

### Database Connections by Role
The system supports different connection strings for different user roles, enabling fine-grained database security at the connection level.

---

## Best Practices Implemented

1. **Secure Key Storage**: JWT signing key stored in user secrets (development) or secure configuration (production)
2. **Token Expiration**: Tokens have limited lifetime to reduce security exposure
3. **Role-Based Access**: Different database connections for different user roles
4. **Stateless Authentication**: No server-side session storage required
5. **Swagger Integration**: Easy testing and documentation of protected endpoints
6. **Claim Validation**: Multiple validation layers for token integrity
7. **HTTPS Enforcement**: Secure token transmission

This JWT implementation provides a robust, scalable security system that protects both API endpoints and database access based on user roles.