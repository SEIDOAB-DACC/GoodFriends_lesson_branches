USE `sql-friends`;


-- MariaDB does not support CREATE SCHEMA as a namespace, but as a synonym for CREATE DATABASE.
-- If you want to use schemas as in SQL Server, use database prefixes or just ignore this step if all tables are in the same database.

-- Create a views
CREATE OR REPLACE VIEW gstusr_vwInfoDb AS
    SELECT (SELECT COUNT(*) FROM supusr_Friends WHERE Seeded = 1) as NrSeededFriends, 
        (SELECT COUNT(*) FROM supusr_Friends WHERE Seeded = 0) as NrUnseededFriends,
        (SELECT COUNT(*) FROM supusr_Friends WHERE AddressId IS NOT NULL) as NrFriendsWithAddress,
        (SELECT COUNT(*) FROM supusr_Addresses WHERE Seeded = 1) as NrSeededAddresses, 
        (SELECT COUNT(*) FROM supusr_Addresses WHERE Seeded = 0) as NrUnseededAddresses,
        (SELECT COUNT(*) FROM supusr_Pets WHERE Seeded = 1) as NrSeededPets, 
        (SELECT COUNT(*) FROM supusr_Pets WHERE Seeded = 0) as NrUnseededPets,
        (SELECT COUNT(*) FROM supusr_Quotes WHERE Seeded = 1) as NrSeededQuotes, 
        (SELECT COUNT(*) FROM supusr_Quotes WHERE Seeded = 0) as NrUnseededQuotes;

CREATE OR REPLACE VIEW gstusr_vwInfoFriends AS
    SELECT a.Country, a.City, COUNT(*) as NrFriends  FROM supusr_Friends f
    INNER JOIN supusr_Addresses a ON f.AddressId = a.AddressId
    GROUP BY a.Country, a.City WITH ROLLUP;

CREATE OR REPLACE VIEW gstusr_vwInfoPets AS
    SELECT a.Country, a.City, COUNT(p.PetId) as NrPets FROM supusr_Friends f
    INNER JOIN supusr_Addresses a ON f.AddressId = a.AddressId
    INNER JOIN supusr_Pets p ON p.FriendId = f.FriendId
    GROUP BY a.Country, a.City WITH ROLLUP;

CREATE OR REPLACE VIEW gstusr_vwInfoQuotes AS
    SELECT Author, COUNT(QuoteText) as NrQuotes FROM supusr_Quotes 
    GROUP BY Author;

-- Create the DeleteAll procedure
CREATE OR REPLACE PROCEDURE supusr_spDeleteAll(
    IN seededParam BOOLEAN,
    OUT nrFriendsAffected INT,
    OUT nrAddressesAffected INT,
    OUT nrPetsAffected INT,
    OUT nrQuotesAffected INT
)
BEGIN
    SELECT  COUNT(*) INTO nrFriendsAffected FROM supusr_Friends WHERE Seeded = seededParam;
    SELECT  COUNT(*) INTO nrAddressesAffected FROM supusr_Addresses WHERE Seeded = seededParam;
    SELECT  COUNT(*) INTO nrPetsAffected FROM supusr_Pets WHERE Seeded = seededParam;
    SELECT  COUNT(*) INTO nrQuotesAffected FROM supusr_Quotes WHERE Seeded = seededParam;

    DELETE FROM supusr_Friends WHERE Seeded = seededParam;
    DELETE FROM supusr_Addresses WHERE Seeded = seededParam;
    DELETE FROM supusr_Pets WHERE Seeded = seededParam;
    DELETE FROM supusr_Quotes WHERE Seeded = seededParam;

    --test to throw an error
    --SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error occurred in supusr_spDeleteAll';

    SELECT * FROM gstusr_vwInfoDb;
END;

-- Create Login procedure with supUser privilages
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
    WHERE (u.UserName = UserNameOrEmail OR (u.Email IS NOT NULL AND u.Email = UserNameOrEmail))
      AND u.Password = UserPassword
    LIMIT 1;

    IF UserId IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Login error: wrong user or password';
    END IF;
END;

-- User and role management in MariaDB
-- Create users and logins if they do not exist
CREATE USER IF NOT EXISTS 'gstusr'@'%' IDENTIFIED BY 'pa$Word1';
CREATE USER IF NOT EXISTS 'usr'@'%' IDENTIFIED BY 'pa$Word1';
CREATE USER IF NOT EXISTS 'supusr'@'%' IDENTIFIED BY 'pa$Word1';
CREATE USER IF NOT EXISTS 'dbo'@'%' IDENTIFIED BY 'pa$Word1';

-- Grant database access privileges
GRANT USAGE ON `sql-friends`.* TO 'gstusr'@'%';
GRANT USAGE ON `sql-friends`.* TO 'usr'@'%';
GRANT USAGE ON `sql-friends`.* TO 'supusr'@'%';
GRANT ALL PRIVILEGES ON `sql-friends`.* TO 'dbo'@'%';

-- Create roles
CREATE ROLE IF NOT EXISTS 'gstUsrRole';
CREATE ROLE IF NOT EXISTS 'usrRole';
CREATE ROLE IF NOT EXISTS 'supUsrRole';
CREATE ROLE IF NOT EXISTS 'dboRole';

-- Grant role privileges (adjust as needed)
GRANT SELECT ON `sql-friends`.`gstusr_vwInfoDb` TO 'gstUsrRole';
GRANT SELECT ON `sql-friends`.`gstusr_vwInfoFriends` TO 'gstUsrRole';
GRANT SELECT ON `sql-friends`.`gstusr_vwInfoPets` TO 'gstUsrRole';
GRANT SELECT ON `sql-friends`.`gstusr_vwInfoQuotes` TO 'gstUsrRole';
GRANT EXECUTE ON PROCEDURE `sql-friends`.`gstusr_spLogin` TO 'gstUsrRole';

GRANT 'gstUsrRole' TO 'usrRole'; --usr is also a gstusr
GRANT SELECT, UPDATE, INSERT ON `sql-friends`.`supusr_Addresses` TO 'usrRole';
GRANT SELECT, UPDATE, INSERT ON `sql-friends`.`supusr_FriendDbMQuoteDbM` TO 'usrRole';
GRANT SELECT, UPDATE, INSERT ON `sql-friends`.`supusr_Friends` TO 'usrRole';
GRANT SELECT, UPDATE, INSERT ON `sql-friends`.`supusr_Pets` TO 'usrRole';
GRANT SELECT, UPDATE, INSERT ON `sql-friends`.`supusr_Quotes` TO 'usrRole';

GRANT 'usrRole' TO 'supUsrRole'; --supusr is also a usr
GRANT DELETE ON `sql-friends`.`supusr_Addresses` TO 'supUsrRole';
GRANT DELETE ON `sql-friends`.`supusr_FriendDbMQuoteDbM` TO 'supUsrRole';
GRANT DELETE ON `sql-friends`.`supusr_Friends` TO 'supUsrRole';
GRANT DELETE ON `sql-friends`.`supusr_Pets` TO 'supUsrRole';
GRANT DELETE ON `sql-friends`.`supusr_Quotes` TO 'supUsrRole';
GRANT EXECUTE ON PROCEDURE `sql-friends`.`supusr_spDeleteAll` TO 'supUsrRole';

-- Grant role privileges for dboRole (full privileges)
GRANT ALL PRIVILEGES ON `sql-friends`.* TO 'dboRole';

-- Assign users to Roles
GRANT 'gstUsrRole' TO 'gstusr'@'%';
GRANT 'usrRole' TO 'usr'@'%';
GRANT 'supUsrRole' TO 'supusr'@'%';
GRANT 'dboRole' TO 'dbo'@'%';

-- Set default roles for users
SET DEFAULT ROLE gstUsrRole FOR 'gstusr'@'%';
SET DEFAULT ROLE usrRole FOR 'usr'@'%';
SET DEFAULT ROLE supUsrRole FOR 'supusr'@'%';
SET DEFAULT ROLE dboRole FOR 'dbo'@'%';

-- Flush privileges to ensure changes take effect
FLUSH PRIVILEGES;
