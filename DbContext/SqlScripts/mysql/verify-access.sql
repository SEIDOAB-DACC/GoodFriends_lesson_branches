USE `sql-friends`;

-- Test as gstusr
CREATE OR REPLACE DEFINER='gstUsrRole' PROCEDURE gstusr_TestAccessRights()
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;

        SELECT 'gstUsrRole', @errno, @errno, @text;
    END;

    --SELECT * FROM `sql-friends`.`gstusr_vwInfoDb`;
    SELECT * FROM `sql-friends`.`supusr_Friends`;
    SELECT * FROM `sql-friends`.`dbo_Users`;

END;

-- Test as usr
CREATE OR REPLACE DEFINER='usrRole' PROCEDURE usr_TestAccessRights()
BEGIN
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;

        SELECT 'usrRole', @errno, @errno, @text;
    END;

    --SELECT * FROM `sql-friends`.`gstusr_vwInfoDb`;
    --SELECT * FROM `sql-friends`.`supusr_Friends`;
    SELECT * FROM `sql-friends`.`dbo_Users`;
END;

-- Test as supusr
CREATE OR REPLACE DEFINER='supUsrRole' PROCEDURE supusr_TestAccessRights()
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;

        SELECT 'supUsrRole', @errno, @errno, @text;
    END;

    --SELECT * FROM `sql-friends`.`gstusr_vwInfoDb`;
    --SELECT * FROM `sql-friends`.`supusr_Friends`;
    SELECT * FROM `sql-friends`.`dbo_Users`;
END;

-- Test as dbo
CREATE OR REPLACE DEFINER='dboRole' PROCEDURE dbo_TestAccessRights()
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;

        SELECT 'dboRole', @errno, @errno, @text;
    END;

    --SELECT * FROM `sql-friends`.`gstusr_vwInfoDb`;
    --SELECT * FROM `sql-friends`.`supusr_Friends`;
    SELECT * FROM `sql-friends`.`dbo_Users`;
END;

GRANT EXECUTE ON PROCEDURE `sql-friends`.`gstusr_TestAccessRights` TO 'gstUsrRole';
GRANT EXECUTE ON PROCEDURE `sql-friends`.`usr_TestAccessRights` TO 'usrRole';
GRANT EXECUTE ON PROCEDURE `sql-friends`.`supusr_TestAccessRights` TO 'supUsrRole';
GRANT EXECUTE ON PROCEDURE `sql-friends`.`dbo_TestAccessRights` TO 'dboRole';
FLUSH PRIVILEGES;

CALL gstusr_TestAccessRights();
CALL usr_TestAccessRights();
CALL supusr_TestAccessRights();
CALL dbo_TestAccessRights();

REVOKE EXECUTE ON PROCEDURE `sql-friends`.`gstusr_TestAccessRights` FROM 'gstUsrRole';
REVOKE EXECUTE ON PROCEDURE `sql-friends`.`usr_TestAccessRights` FROM 'usrRole';
REVOKE EXECUTE ON PROCEDURE `sql-friends`.`supusr_TestAccessRights` FROM 'supUsrRole';
REVOKE EXECUTE ON PROCEDURE `sql-friends`.`dbo_TestAccessRights` FROM 'dboRole';
FLUSH PRIVILEGES;

DROP PROCEDURE IF EXISTS `sql-friends`.`gstusr_TestAccessRights`;
DROP PROCEDURE IF EXISTS `sql-friends`.`usr_TestAccessRights`;
DROP PROCEDURE IF EXISTS `sql-friends`.`supusr_TestAccessRights`;
DROP PROCEDURE IF EXISTS `sql-friends`.`dbo_TestAccessRights`;