USE [sql-friends];
GO

-- Execute the test procedures using impersonation
PRINT 'Executing gstusr access test...';
EXECUTE AS USER = 'gstusrUser';
BEGIN TRY
    SELECT 'Testing access as gstusr' AS TestInfo;
    
    -- Test access to various objects
    SELECT * FROM [sql-friends].[gstusr].[vwInfoDb];

    --should fail
    SELECT TOP 5 * FROM [sql-friends].[supusr].[Friends];
    SELECT TOP 5 * FROM [sql-friends].[dbo].[Users];
END TRY
BEGIN CATCH
    SELECT 
        'gstusr' AS UserRole,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH
REVERT;

PRINT 'Executing usr access test...';
EXECUTE AS USER = 'usrUser';
BEGIN TRY
    SELECT 'Testing access as usr' AS TestInfo;
    
    -- Test access to various objects
    SELECT * FROM [sql-friends].[gstusr].[vwInfoDb];
    SELECT * FROM [sql-friends].[supusr].[Friends];

    --should fail
    SELECT TOP 5 * FROM [sql-friends].[dbo].[Users];
END TRY
BEGIN CATCH
    SELECT 
        'usr' AS UserRole,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH
REVERT;

PRINT 'Executing supusr access test...';
EXECUTE AS USER = 'supusrUser';
BEGIN TRY
    SELECT 'Testing access as supusr' AS TestInfo;
    
    -- Test access to various objects
    SELECT * FROM [sql-friends].[gstusr].[vwInfoDb];
    SELECT TOP 5 * FROM [sql-friends].[supusr].[Friends];

    -- should fail
    SELECT TOP 5 * FROM [sql-friends].[dbo].[Users];
END TRY
BEGIN CATCH
    SELECT 
        'supusr' AS UserRole,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH
REVERT;

PRINT 'Executing supusr access test...';
EXECUTE AS USER = 'dboUser';
BEGIN TRY
    SELECT 'Testing access as dbo' AS TestInfo;
    
    -- Test access to various objects
    SELECT * FROM [sql-friends].[gstusr].[vwInfoDb];
    SELECT TOP 5 * FROM [sql-friends].[supusr].[Friends];
    SELECT TOP 5 * FROM [sql-friends].[dbo].[Users];
    
END TRY
BEGIN CATCH
    SELECT 
        'supusr' AS UserRole,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH
REVERT;