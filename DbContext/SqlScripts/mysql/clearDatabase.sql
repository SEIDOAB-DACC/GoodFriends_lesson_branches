USE `sql-friends`;

-- Remove stored procedures
DROP PROCEDURE IF EXISTS supusr_spDeleteAll;

-- Remove views
DROP VIEW IF EXISTS gstusr_vwInfoDb;
DROP VIEW IF EXISTS gstusr_vwInfoFriends;
DROP VIEW IF EXISTS gstusr_vwInfoPets;
DROP VIEW IF EXISTS gstusr_vwInfoQuotes;

-- Drop tables in the right order to avoid FK conflicts
DROP TABLE IF EXISTS supusr_FriendDbMQuoteDbM;
DROP TABLE IF EXISTS supusr_Pets;
DROP TABLE IF EXISTS supusr_Quotes;
DROP TABLE IF EXISTS supusr_Friends;
DROP TABLE IF EXISTS supusr_Addresses;
DROP TABLE IF EXISTS dbo_Users;
DROP TABLE IF EXISTS __EFMigrationsHistory;

