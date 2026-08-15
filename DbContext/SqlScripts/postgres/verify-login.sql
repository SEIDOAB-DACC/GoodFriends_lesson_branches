-- PostgreSQL Login Verification Script
-- Note: Make sure you are connected to the 'sql-friends' database before running this script

-- Test the login function
-- Make sure to get Password and UserNameOrEmail from dbo.Users table
SELECT 
    CASE 
        WHEN (result).userid IS NOT NULL THEN 'Login successful' 
        ELSE 'Login failed' 
    END AS Message,
    (result).userid,
    (result).username,
    (result).userrole
FROM (
    SELECT gstusr."spLogin"('user30', '8IbDMcvK0H175Z1ob9c27V9oZt7fCDlVfUXELAMY0sYG10dzlq1oHkhPvnvx/JwbUBqAIB8JxkHj/9+pZvRsGQ==') as result
) t;
