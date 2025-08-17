-- PostgreSQL Database Clear Script
-- Note: Make sure you are connected to the 'sql-friends' database before running this script

-- Remove functions (PostgreSQL stored procedures)
-- DROP FUNCTION IF EXISTS gstusr."spLogin"(VARCHAR, VARCHAR);
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
-- DROP TABLE IF EXISTS dbo."Users";
DROP TABLE IF EXISTS public."__EFMigrationsHistory";

-- Drop schemas will remove all objects within them
DROP SCHEMA IF EXISTS gstusr CASCADE;
DROP SCHEMA IF EXISTS usr CASCADE;
DROP SCHEMA IF EXISTS supusr CASCADE;
DROP SCHEMA IF EXISTS dbo CASCADE;

-- Remove all privileges granted to roles
DO $BODY$
BEGIN
IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supusrrole') THEN
    REVOKE ALL PRIVILEGES ON SCHEMA public FROM supusrrole;
END IF;
IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'usrrole') THEN
    REVOKE ALL PRIVILEGES ON SCHEMA public FROM usrrole;
END IF;
IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'gstusrrole') THEN
    REVOKE ALL PRIVILEGES ON SCHEMA public FROM gstusrrole;
END IF;
IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'dborole') THEN
    REVOKE ALL PRIVILEGES ON DATABASE "sql-friends" FROM dborole;
    REVOKE ALL PRIVILEGES ON SCHEMA public FROM dborole;
END IF;
END
$BODY$;

-- Remove roles
DROP ROLE IF EXISTS gstusrrole;
DROP ROLE IF EXISTS usrrole;
DROP ROLE IF EXISTS supusrrole;
DROP ROLE IF EXISTS dborole;

-- Remove all privileges granted to users
DO $BODY$
BEGIN
    IF EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'gstusr') THEN
        REVOKE ALL PRIVILEGES ON DATABASE "sql-friends" FROM gstusr;
    END IF;
    IF EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'usr') THEN
        REVOKE ALL PRIVILEGES ON DATABASE "sql-friends" FROM usr;
    END IF;
    IF EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'supusr') THEN
        REVOKE ALL PRIVILEGES ON DATABASE "sql-friends" FROM supusr;
    END IF;
    IF EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'dbo') THEN
        REVOKE ALL PRIVILEGES ON DATABASE "sql-friends" FROM dbo;
    END IF;
END
$BODY$;

-- Remove users
DROP USER IF EXISTS gstusr;
DROP USER IF EXISTS usr;
DROP USER IF EXISTS supusr;
DROP USER IF EXISTS dbo;
