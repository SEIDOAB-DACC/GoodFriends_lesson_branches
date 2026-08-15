USE `sql-friends`;

DELIMITER $$

/* Test as gstusr */
CREATE OR REPLACE DEFINER='gstusr'@'%' PROCEDURE gstusr_TestAccessRights()
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;

        SELECT 'gstUsrRole', @sqlstate, @errno, @text;
    END;

    /* SELECT * FROM `sql-friends`.`gstusr_vwInfoDb`; */
    SELECT * FROM `sql-friends`.`supusr_Friends`;
    SELECT * FROM `sql-friends`.`dbo_Users`;

END$$

/* Test as usr */
CREATE OR REPLACE DEFINER='usr'@'%' PROCEDURE usr_TestAccessRights()
BEGIN
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;

        SELECT 'usrRole', @sqlstate, @errno, @text;
    END;

    /* SELECT * FROM `sql-friends`.`gstusr_vwInfoDb`; */
    /* SELECT * FROM `sql-friends`.`supusr_Friends`; */
    SELECT * FROM `sql-friends`.`dbo_Users`;
END$$

/* Test as supusr */
CREATE OR REPLACE DEFINER='supusr'@'%' PROCEDURE supusr_TestAccessRights()
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;

        SELECT 'supUsrRole', @sqlstate, @errno, @text;
    END;

    /* SELECT * FROM `sql-friends`.`gstusr_vwInfoDb`; */
    /* SELECT * FROM `sql-friends`.`supusr_Friends`; */
    SELECT * FROM `sql-friends`.`dbo_Users`;
END$$

/* Test as dbo */
CREATE OR REPLACE DEFINER='dbo'@'%' PROCEDURE dbo_TestAccessRights()
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;

        SELECT 'dboRole', @sqlstate, @errno, @text;
    END;

    /* SELECT * FROM `sql-friends`.`gstusr_vwInfoDb`; */
    /* SELECT * FROM `sql-friends`.`supusr_Friends`; */
    SELECT * FROM `sql-friends`.`dbo_Users`;
END$$

DELIMITER ;

GRANT EXECUTE ON PROCEDURE `sql-friends`.`gstusr_TestAccessRights` TO 'gstUsrRole';
GRANT EXECUTE ON PROCEDURE `sql-friends`.`usr_TestAccessRights` TO 'usrRole';
GRANT EXECUTE ON PROCEDURE `sql-friends`.`supusr_TestAccessRights` TO 'supUsrRole';
GRANT EXECUTE ON PROCEDURE `sql-friends`.`dbo_TestAccessRights` TO 'dboRole';
FLUSH PRIVILEGES;

CALL gstusr_TestAccessRights(); /* should cause access error */
CALL usr_TestAccessRights(); /* should cause access error */
CALL supusr_TestAccessRights(); /* should access cause error */
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