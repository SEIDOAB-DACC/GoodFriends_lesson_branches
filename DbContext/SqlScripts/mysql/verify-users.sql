USE `sql-friends`;

-- Remove Users with no wildcard %
DROP USER IF EXISTS 'gstusr'@localhost;
DROP USER IF EXISTS 'gstusr'@'192.168.65.1';
DROP USER IF EXISTS 'usr'@localhost;
DROP USER IF EXISTS 'usr'@'192.168.65.1';
DROP USER IF EXISTS 'supusr'@localhost;
DROP USER IF EXISTS 'supusr'@'192.168.65.1';
DROP USER IF EXISTS 'dbo'@localhost;
DROP USER IF EXISTS 'dbo'@'192.168.65.1';

-- Show users
SELECT Host, User FROM mysql.user;

-- Show grants
SHOW GRANTS FOR 'gstusr'@'%';
SHOW GRANTS FOR 'usr'@'%';
SHOW GRANTS FOR 'supusr'@'%';
SHOW GRANTS FOR 'dbo'@'%';

SHOW GRANTS FOR 'gstUsrRole';
SHOW GRANTS FOR 'usrRole';
SHOW GRANTS FOR 'supUsrRole';
SHOW GRANTS FOR 'dboRole';