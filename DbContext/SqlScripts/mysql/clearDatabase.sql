USE `sql-friends`;

-- Remove stored procedures
DROP PROCEDURE IF EXISTS gstusr_spLogin;
DROP PROCEDURE IF EXISTS supusr_spDeleteAll;

-- Remove roles
DROP ROLE IF EXISTS 'gstUsrRole';
DROP ROLE IF EXISTS 'usrRole';
DROP ROLE IF EXISTS 'supUsrRole';
DROP ROLE IF EXISTS 'dboRole';

-- Remove users
DROP USER IF EXISTS 'gstusr'@'%';
DROP USER IF EXISTS 'usr'@'%';
DROP USER IF EXISTS 'supusr'@'%';
DROP USER IF EXISTS 'dbo'@'%';

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

