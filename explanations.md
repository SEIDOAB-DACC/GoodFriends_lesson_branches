# Database Scripts and Security Documentation

This document provides comprehensive documentation for the SQL scripts in `DbContext/SqlScripts`, database role management across different database systems, and the authentication mechanism implemented through `gstusr.spLogin`.

## Table of Contents
1. [Overview](#overview)
2. [SQL Scripts Structure](#sql-scripts-structure)
3. [Database Role Management by Platform](#database-role-management-by-platform)
4. [Login System Architecture](#login-system-architecture)
5. [Security Implementation](#security-implementation)
6. [Cross-Platform Compatibility](#cross-platform-compatibility)

## Overview

The GoodFriends application implements a comprehensive database security model that works across three major database platforms:
- **SQL Server** - Full schema-based security with stored procedures
- **MySQL/MariaDB** - User-based permissions with prefixed naming conventions
- **PostgreSQL** - Schema-based security with functions and advanced role management

## SQL Scripts Structure

### Directory Organization
```
DbContext/SqlScripts/
├── sqlserver/
│   ├── initDatabase.sql       # Main initialization script
│   ├── clearDatabase.sql      # Database cleanup
│   ├── verify-access.sql      # Access verification
│   ├── verify-login.sql       # Login testing
│   └── verify-users.sql       # User management verification
├── mysql/
│   ├── initDatabase.sql       # MySQL-specific initialization
│   ├── clearDatabase.sql      # MySQL cleanup
│   ├── verify-access.sql      # MySQL access verification
│   ├── verify-login.sql       # MySQL login testing
│   └── verify-users.sql       # MySQL user verification
└── postgres/
    ├── initDatabase.sql       # PostgreSQL initialization
    ├── clearDatabase.sql      # PostgreSQL cleanup
    ├── verify-access.sql      # PostgreSQL access verification
    ├── verify-login.sql       # PostgreSQL login testing
    └── verify-users.sql       # PostgreSQL user verification
```


## Database Role Management by Platform

### SQL Server Role Management

SQL Server uses a hierarchical security model with **schemas**, **users**, **logins**, and **roles**.

#### Key Concepts:
- **Logins**: Server-level security principals
- **Users**: Database-level security principals mapped to logins
- **Schemas**: Logical containers for database objects
- **Roles**: Security groups that can be assigned permissions

#### Implementation:
```sql
-- Create logins at server level
CREATE LOGIN gstusr WITH PASSWORD=N'pa$Word1', DEFAULT_DATABASE=[sql-friends]

-- Create users in database
CREATE USER gstusrUser FROM LOGIN gstusr;

-- Create roles
CREATE ROLE gstUsrRole;

-- Grant schema-level permissions
GRANT SELECT, EXECUTE ON SCHEMA::gstusr to gstUsrRole;

-- Assign users to roles
ALTER ROLE gstUsrRole ADD MEMBER gstusrUser;
```

#### Schema Structure:
- `gstusr` - Guest user schema (read-only access to views and procedures)
- `usr` - Regular user schema (read/write access to data)
- `supusr` - Super user schema (full access including delete operations)
- `dbo` - Database owner schema (administrative access)

### MySQL/MariaDB Role Management

MySQL uses a **user-based** permission system with **host-based** access control. Since MySQL doesn't have true schemas like SQL Server, the application uses **naming prefixes** to simulate schema separation.

#### Key Concepts:
- **Users**: Combined with host specification (user@host)
- **Roles**: Available in MySQL 8.0+ and MariaDB 10.0.5+
- **Privileges**: Granted at database, table, or column level
- **Definer Rights**: Procedures can run with elevated privileges

#### Implementation:
```sql
-- Create users with host specification
CREATE USER IF NOT EXISTS 'gstusr'@'%' IDENTIFIED BY 'pa$Word1';

-- Create roles (if supported)
CREATE ROLE IF NOT EXISTS 'gstUsrRole';

-- Grant privileges at database level
GRANT USAGE ON `sql-friends`.* TO 'gstusr'@'%';
GRANT SELECT ON `sql-friends`.gstusr_* TO 'gstUsrRole';

-- Grant role to user
GRANT 'gstUsrRole' TO 'gstusr'@'%';
```

#### Naming Convention:
- `gstusr_*` - Guest user objects (views, procedures)
- `usr_*` - Regular user objects
- `supusr_*` - Super user objects (tables, admin procedures)
- `dbo_*` - Database owner objects

### PostgreSQL Role Management

PostgreSQL has the most sophisticated role system, where **roles can be both users and groups**. It supports **schema-based** security similar to SQL Server but with more flexibility.

#### Key Concepts:
- **Roles**: Unified concept for users and groups
- **Schemas**: Logical containers with full namespace support
- **Inheritance**: Roles can inherit permissions from other roles
- **Row-Level Security**: Advanced security features (not used in this project)

#### Implementation:
```sql
-- Create login roles (users)
CREATE ROLE gstusr WITH LOGIN PASSWORD 'pa$Word1';

-- Create group roles
CREATE ROLE gstusrrole;

-- Grant schema permissions
GRANT USAGE ON SCHEMA gstusr TO gstusrrole;
GRANT SELECT ON ALL TABLES IN SCHEMA gstusr TO gstusrrole;

-- Grant role membership
GRANT gstusrrole TO gstusr;
```

#### Schema Structure:
- `gstusr` - Guest user schema (read-only views and functions)
- `usr` - Regular user schema
- `supusr` - Super user schema (data tables and admin functions)
- `public` - Default schema (used for shared objects)

## Login System Architecture

### gstusr.spLogin Stored Procedure/Function

The login system is implemented through platform-specific stored procedures or functions that validate user credentials and return user information.

#### SQL Server Implementation:
```sql
CREATE OR ALTER PROC gstusr.spLogin
    @UserNameOrEmail NVARCHAR(100),
    @UserPassword NVARCHAR(200),
    @UserId UNIQUEIDENTIFIER OUTPUT,
    @UserName NVARCHAR(100) OUTPUT,
    @UserRole NVARCHAR(100) OUTPUT
AS
BEGIN
    SET @UserId = NULL;
    SET @UserName = NULL;
    SET @UserRole = NULL;
    
    SELECT Top 1 @UserId = UserId, @UserName = UserName, @UserRole = UserRole 
    FROM dbo.Users 
    WHERE ((UserName = @UserNameOrEmail) OR (Email = @UserNameOrEmail)) 
      AND ([Password] = @UserPassword);

    IF (@UserId IS NULL)
        THROW 999999, 'Login error: wrong user or password', 1
END
```

#### MySQL Implementation:
```sql
CREATE OR REPLACE DEFINER='dbo'@'%' PROCEDURE gstusr_spLogin(
    IN UserNameOrEmail VARCHAR(100),
    IN UserPassword VARCHAR(200),
    OUT UserId CHAR(36),
    OUT UserName VARCHAR(100),
    OUT UserRole VARCHAR(100)
)
BEGIN
    SET UserId = NULL;
    SET UserName = NULL;
    SET UserRole = NULL;

    SELECT u.UserId, u.UserName, u.UserRole INTO UserId, UserName, UserRole
    FROM `sql-friends`.dbo_Users u
    WHERE (u.UserName = UserNameOrEmail OR u.Email = UserNameOrEmail)
      AND u.Password = UserPassword
    LIMIT 1;

    IF UserId IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Login error: wrong user or password';
    END IF;
END;
```

#### PostgreSQL Implementation:
```sql
CREATE OR REPLACE FUNCTION gstusr."spLogin"(
    usernameoremail VARCHAR(100),
    userpassword VARCHAR(200),
    OUT userid UUID,
    OUT username VARCHAR(100),
    OUT userrole VARCHAR(100)
)
RETURNS RECORD
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    userid := NULL;
    username := NULL;
    userrole := NULL;

    SELECT u."UserId", u."UserName", u."UserRole" 
    INTO userid, username, userrole
    FROM dbo."Users" u
    WHERE (u."UserName" = usernameoremail OR u."Email" = usernameoremail)
      AND u."Password" = userpassword
    LIMIT 1;

    IF userid IS NULL THEN
        RAISE EXCEPTION 'Login error: wrong user or password';
    END IF;
END;
$$;
```

### LoginDbRepos Integration

The `LoginDbRepos` class in `DbRepos/LoginDbRepos.cs` provides a unified interface to the login system across all database platforms.

#### Key Features:
1. **Database Detection**: Automatically detects the database type using connection types
2. **Parameter Mapping**: Maps .NET parameters to database-specific parameter types
3. **Password Encryption**: Encrypts passwords before sending to database
4. **Output Parameter Handling**: Manages output parameters differently for each platform

#### Implementation Example:
```csharp
public async Task<ResponseItemDto<LoginUserSessionDto>> LoginUserAsync(LoginCredentialsDto usrCreds)
{
    using (var cmd1 = _dbContext.Database.GetDbConnection().CreateCommand())
    {
        var connection = _dbContext.Database.GetDbConnection();
        
        if (connection is MySqlConnection)
        {
            cmd1.CommandText = "gstusr_spLogin";
            // MySQL-specific parameter setup
        }
        else if (connection is NpgsqlConnection)
        {
            cmd1.CommandText = "SELECT userid, username, userrole FROM gstusr.\"spLogin\"(@usernameoremail, @userpassword)";
            cmd1.CommandType = CommandType.Text;
            // PostgreSQL-specific parameter setup
        }
        else
        {
            cmd1.CommandText = "gstusr.spLogin";
            // SQL Server-specific parameter setup
        }
        
        // Execute and return results
    }
}
```

## Security Implementation

### Authentication Flow
1. **Client Request**: User submits username/email and password
2. **Password Encryption**: `LoginDbRepos` encrypts password using `Encryptions` service
3. **Database Validation**: Encrypted password is validated against stored hash
4. **User Information Retrieval**: Valid login returns UserId, UserName, and UserRole
5. **Session Creation**: Application creates session based on returned user information

### Security Features

#### Password Security:
- **Encryption**: Passwords are encrypted before database transmission
- **No Plain Text**: Passwords never transmitted or stored in plain text
- **Base64 Encoding**: Uses Base64 encoding for encrypted password storage

#### Database Security:
- **Principle of Least Privilege**: Each role has minimum required permissions
- **Schema Separation**: Different privilege levels isolated by schemas/prefixes
- **Stored Procedure Security**: Login logic encapsulated in database procedures
- **SQL Injection Prevention**: Parameterized queries prevent injection attacks

#### Role-Based Access:
- **gstusr**: Read-only access to informational views
- **usr**: Standard CRUD operations on user data
- **supusr**: Administrative operations including delete
- **dbo**: Full database administrative access

### Error Handling
Each platform implements consistent error handling:
- **SQL Server**: `THROW` statement with custom error codes
- **MySQL**: `SIGNAL SQLSTATE` with custom messages
- **PostgreSQL**: `RAISE EXCEPTION` with descriptive messages

## Cross-Platform Compatibility

### Design Patterns

#### 1. Abstraction Layer
The application uses Entity Framework Core as an abstraction layer, with platform-specific implementations for advanced features like stored procedures.

#### 2. Naming Conventions
- **SQL Server**: Uses schemas (`gstusr.spLogin`)
- **MySQL**: Uses prefixes (`gstusr_spLogin`)
- **PostgreSQL**: Uses quoted schemas (`gstusr."spLogin"`)

#### 3. Data Type Mapping
```csharp
// SQL Server
new SqlParameter("UserId", SqlDbType.UniqueIdentifier)

// MySQL
new MySqlParameter("UserId", MySqlDbType.Guid)

// PostgreSQL
new NpgsqlParameter("userid", NpgsqlTypes.NpgsqlDbType.Uuid)
```

#### 4. Procedure vs Function Handling
- **SQL Server**: Uses stored procedures with OUTPUT parameters
- **MySQL**: Uses stored procedures with OUT parameters
- **PostgreSQL**: Uses functions with RETURNS RECORD

### Migration Considerations

When migrating between database platforms:
1. **Schema Structure**: Update table and object names according to platform conventions
2. **Permission Model**: Adjust role assignments based on platform capabilities
3. **Stored Procedures**: Convert procedures to appropriate platform syntax
4. **Connection Strings**: Update connection parameters for target platform
5. **Entity Framework**: Update provider packages and configurations

### Testing and Verification

Each platform includes verification scripts:
- **verify-users.sql**: Validates user creation and role assignments
- **verify-access.sql**: Tests permission levels for each role
- **verify-login.sql**: Tests the login functionality

This comprehensive approach ensures consistent security and functionality across all supported database platforms while leveraging each platform's specific strengths and capabilities.