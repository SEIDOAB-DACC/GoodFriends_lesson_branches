-- PostgreSQL Database Clear Script
-- Note: Make sure you are connected to the 'sql-friends' database before running this script

-- Remove functions (PostgreSQL stored procedures)
-- DROP FUNCTION IF EXISTS supusr."spDeleteAll"(BOOLEAN);

-- -- Remove views
-- DROP VIEW IF EXISTS gstusr."vwInfoDb";
-- DROP VIEW IF EXISTS gstusr."vwInfoFriends";
-- DROP VIEW IF EXISTS gstusr."vwInfoPets";
-- DROP VIEW IF EXISTS gstusr."vwInfoQuotes";

-- Drop tables in the right order to avoid FK conflicts
-- DROP TABLE IF EXISTS supusr."FriendDbMQuoteDbM";
-- DROP TABLE IF EXISTS supusr."Pets";
-- DROP TABLE IF EXISTS supusr."Quotes";
-- DROP TABLE IF EXISTS supusr."Friends";
-- DROP TABLE IF EXISTS supusr."Addresses";
DROP TABLE IF EXISTS public."__EFMigrationsHistory";

-- Drop schemas will remove all objects within them
DROP SCHEMA IF EXISTS gstusr CASCADE;
DROP SCHEMA IF EXISTS usr CASCADE;
DROP SCHEMA IF EXISTS supusr CASCADE;
