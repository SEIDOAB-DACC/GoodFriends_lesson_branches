USE [sql-friends];
--GO

-- remove stored procedures
DROP PROCEDURE IF EXISTS supusr.spDeleteAll
GO


-- remove views
DROP VIEW IF EXISTS [gstusr].[vwInfoDb]
DROP VIEW IF EXISTS [gstusr].[vwInfoFriends]
DROP VIEW IF EXISTS [gstusr].[vwInfoPets]
DROP VIEW IF EXISTS [gstusr].[vwInfoQuotes]
GO
    
-- Drop tables in the right order to avoid FK conflicts
DROP TABLE IF EXISTS supusr.FriendDbMQuoteDbM;
DROP TABLE IF EXISTS supusr.Pets;
DROP TABLE IF EXISTS supusr.Quotes;
DROP TABLE IF EXISTS supusr.Friends;
DROP TABLE IF EXISTS supusr.Addresses;
DROP TABLE IF EXISTS dbo.Users;
DROP TABLE IF EXISTS __EFMigrationsHistory;


-- drop schemas
DROP SCHEMA IF EXISTS gstusr;
DROP SCHEMA IF EXISTS usr;
DROP SCHEMA IF EXISTS supusr;
GO