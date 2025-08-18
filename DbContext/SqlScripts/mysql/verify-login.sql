USE `sql-friends`;

-- Session variables for stored procedure output
SET @UserId = NULL;
SET @UserName = NULL;
SET @UserRole = NULL;

-- Call the stored procedure with proper variable assignment
CALL gstusr_spLogin('user30', '8IbDMcvK0H175Z1ob9c27V9oZt7fCDlVfUXELAMY0sYG10dzlq1oHkhPvnvx/JwbUBqAIB8JxkHj/9+pZvRsGQ==', @UserId, @UserName, @UserRole);

-- Display results
SELECT 
    CASE 
        WHEN @UserId IS NOT NULL THEN 'Login successful' 
        ELSE 'Login failed' 
    END AS Message, 
    @UserId AS UserId, 
    @UserName AS UserName, 
    @UserRole AS UserRole;