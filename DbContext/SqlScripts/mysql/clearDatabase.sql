USE `sql-friends`;

/* Remove stored procedures */
DROP PROCEDURE IF EXISTS `sql-friends`.`supusr_spDeleteAll`;

/* Remove views */
DROP VIEW IF EXISTS `sql-friends`.`gstusr_vwInfoDb`;
DROP VIEW IF EXISTS `sql-friends`.`gstusr_vwInfoFriends`;
DROP VIEW IF EXISTS `sql-friends`.`gstusr_vwInfoPets`;
DROP VIEW IF EXISTS `sql-friends`.`gstusr_vwInfoQuotes`;

/* Drop tables in the right order to avoid FK conflicts */
DROP TABLE IF EXISTS `sql-friends`.`supusr_FriendDbMQuoteDbM`;
DROP TABLE IF EXISTS `sql-friends`.`supusr_Pets`;
DROP TABLE IF EXISTS `sql-friends`.`supusr_Quotes`;
DROP TABLE IF EXISTS `sql-friends`.`supusr_Friends`;
DROP TABLE IF EXISTS `sql-friends`.`supusr_Addresses`;
DROP TABLE IF EXISTS `sql-friends`.`dbo_Users`;
DROP TABLE IF EXISTS `sql-friends`.`__EFMigrationsHistory`;

