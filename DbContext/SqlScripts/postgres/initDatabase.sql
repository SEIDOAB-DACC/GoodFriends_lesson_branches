-- PostgreSQL Database Initialization Script
-- Note: Make sure you are connected to the 'sql-friends' database before running this script

-- Create schemas
CREATE SCHEMA IF NOT EXISTS gstusr;
CREATE SCHEMA IF NOT EXISTS usr;
CREATE SCHEMA IF NOT EXISTS supusr;

-- Create views
CREATE OR REPLACE VIEW gstusr."vwInfoDb" AS
    SELECT (SELECT COUNT(*) FROM supusr."Friends" WHERE "Seeded" = true) as "NrSeededFriends", 
        (SELECT COUNT(*) FROM supusr."Friends" WHERE "Seeded" = false) as "NrUnseededFriends",
        (SELECT COUNT(*) FROM supusr."Friends" WHERE "AddressId" IS NOT NULL) as "NrFriendsWithAddress",
        (SELECT COUNT(*) FROM supusr."Addresses" WHERE "Seeded" = true) as "NrSeededAddresses", 
        (SELECT COUNT(*) FROM supusr."Addresses" WHERE "Seeded" = false) as "NrUnseededAddresses",
        (SELECT COUNT(*) FROM supusr."Pets" WHERE "Seeded" = true) as "NrSeededPets", 
        (SELECT COUNT(*) FROM supusr."Pets" WHERE "Seeded" = false) as "NrUnseededPets",
        (SELECT COUNT(*) FROM supusr."Quotes" WHERE "Seeded" = true) as "NrSeededQuotes", 
        (SELECT COUNT(*) FROM supusr."Quotes" WHERE "Seeded" = false) as "NrUnseededQuotes";

CREATE OR REPLACE VIEW gstusr."vwInfoFriends" AS
    SELECT a."Country" as "Country", a."City" as "City", COUNT(*) as "NrFriends" FROM supusr."Friends" f
    INNER JOIN supusr."Addresses" a ON f."AddressId" = a."AddressId"
    GROUP BY ROLLUP(a."Country", a."City");

CREATE OR REPLACE VIEW gstusr."vwInfoPets" AS
    SELECT a."Country" as "Country", a."City" as "City", COUNT(p."PetId") as "NrPets" FROM supusr."Friends" f
    INNER JOIN supusr."Addresses" a ON f."AddressId" = a."AddressId"
    INNER JOIN supusr."Pets" p ON p."FriendId" = f."FriendId"
    GROUP BY ROLLUP(a."Country", a."City");

CREATE OR REPLACE VIEW gstusr."vwInfoQuotes" AS
    SELECT "Author" as "Author", COUNT("QuoteText") as "NrQuotes" FROM supusr."Quotes" 
    GROUP BY "Author";

-- Create the DeleteAll function (PostgreSQL uses functions instead of procedures for this pattern)
CREATE OR REPLACE FUNCTION supusr."spDeleteAll"(
    seededParam BOOLEAN DEFAULT true,
    OUT nrFriendsAffected INTEGER,
    OUT nrAddressesAffected INTEGER,
    OUT nrPetsAffected INTEGER,
    OUT nrQuotesAffected INTEGER
)
RETURNS RECORD
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT COUNT(*) INTO nrFriendsAffected FROM supusr."Friends" WHERE "Seeded" = seededParam;
    SELECT COUNT(*) INTO nrAddressesAffected FROM supusr."Addresses" WHERE "Seeded" = seededParam;
    SELECT COUNT(*) INTO nrPetsAffected FROM supusr."Pets" WHERE "Seeded" = seededParam;
    SELECT COUNT(*) INTO nrQuotesAffected FROM supusr."Quotes" WHERE "Seeded" = seededParam;

    DELETE FROM supusr."Friends" WHERE "Seeded" = seededParam;
    DELETE FROM supusr."Addresses" WHERE "Seeded" = seededParam;
    DELETE FROM supusr."Pets" WHERE "Seeded" = seededParam;
    DELETE FROM supusr."Quotes" WHERE "Seeded" = seededParam;

    -- Test to throw an error (uncomment if needed)
    -- RAISE EXCEPTION 'Error occurred in supusr.spDeleteAll';
END;
$$;

