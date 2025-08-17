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
