USE [sql-friends];
GO

--create a schemas
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gstusr')
    EXEC('CREATE SCHEMA gstusr');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'usr')
    EXEC('CREATE SCHEMA usr');
GO

--create a view that gives overview of the database content
CREATE OR ALTER VIEW gstusr.vwInfoDb AS
    SELECT (SELECT COUNT(*) FROM supusr.Friends WHERE Seeded = 1) as nrSeededFriends, 
        (SELECT COUNT(*) FROM supusr.Friends WHERE Seeded = 0) as nrUnseededFriends,
        (SELECT COUNT(*) FROM supusr.Friends WHERE AddressId IS NOT NULL) as nrFriendsWithAddress,
        (SELECT COUNT(*) FROM supusr.Addresses WHERE Seeded = 1) as nrSeededAddresses, 
        (SELECT COUNT(*) FROM supusr.Addresses WHERE Seeded = 0) as nrUnseededAddresses,
        (SELECT COUNT(*) FROM supusr.Pets WHERE Seeded = 1) as nrSeededPets, 
        (SELECT COUNT(*) FROM supusr.Pets WHERE Seeded = 0) as nrUnseededPets,
        (SELECT COUNT(*) FROM supusr.Quotes WHERE Seeded = 1) as nrSeededQuotes, 
        (SELECT COUNT(*) FROM supusr.Quotes WHERE Seeded = 0) as nrUnseededQuotes;
GO

CREATE OR ALTER VIEW gstusr.vwInfoFriends AS
    SELECT a.Country, a.City, COUNT(*) as NrFriends  FROM supusr.Friends f
    INNER JOIN supusr.Addresses a ON f.AddressId = a.AddressId
    GROUP BY a.Country, a.City WITH ROLLUP;
GO

CREATE OR ALTER VIEW gstusr.vwInfoPets AS
    SELECT a.Country, a.City, COUNT(p.PetId) as NrPets FROM supusr.Friends f
    INNER JOIN supusr.Addresses a ON f.AddressId = a.AddressId
    INNER JOIN supusr.Pets p ON p.FriendId = f.FriendId
    GROUP BY a.Country, a.City WITH ROLLUP;
GO

CREATE OR ALTER VIEW gstusr.vwInfoQuotes AS
    SELECT Author, COUNT(QuoteText) as NrQuotes FROM supusr.Quotes 
    GROUp BY Author;
GO

--create the DeleteAll procedure
CREATE OR ALTER PROC supusr.spDeleteAll
    @seededParam BIT = 1,

    @nrFriendsAffected INT OUTPUT,
    @nrAddressesAffected INT OUTPUT,
    @nrPetsAffected INT OUTPUT,
    @nrQuotesAffected INT OUTPUT
    
    AS

    SET NOCOUNT ON;

    SELECT  @nrFriendsAffected = COUNT(*) FROM supusr.Friends WHERE Seeded = @seededParam;
    SELECT  @nrAddressesAffected = COUNT(*) FROM supusr.Addresses WHERE Seeded = @seededParam;
    SELECT  @nrPetsAffected = COUNT(*) FROM supusr.Pets WHERE Seeded = @seededParam;
    SELECT  @nrQuotesAffected = COUNT(*) FROM supusr.Quotes WHERE Seeded = @seededParam;

    DELETE FROM supusr.Friends WHERE Seeded = @seededParam;
    DELETE FROM supusr.Addresses WHERE Seeded = @seededParam;
    DELETE FROM supusr.Pets WHERE Seeded = @seededParam;
    DELETE FROM supusr.Quotes WHERE Seeded = @seededParam;

    --throw our own error
    --;THROW 999999, 'Error occurred in supusr.spDeleteAll', 1

    SELECT * FROM gstusr.vwInfoDb;
GO



