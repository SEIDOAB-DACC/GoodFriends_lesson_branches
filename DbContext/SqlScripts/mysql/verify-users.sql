USE `sql-friends`;

/* Remove Users with no wildcard % */
DROP USER IF EXISTS 'gstusr'@'localhost';
DROP USER IF EXISTS 'gstusr'@'192.168.68.53';
DROP USER IF EXISTS 'usr'@'localhost';
DROP USER IF EXISTS 'usr'@'192.168.68.53';
DROP USER IF EXISTS 'supusr'@'localhost';
DROP USER IF EXISTS 'supusr'@'192.168.68.53';
DROP USER IF EXISTS 'dbo'@'localhost';
DROP USER IF EXISTS 'dbo'@'192.168.68.53';

/* Flush privileges after user changes */
FLUSH PRIVILEGES;

/* Show users */
SELECT Host, User FROM mysql.user WHERE User IN ('gstusr', 'usr', 'supusr', 'dbo') ORDER BY User, Host;

/* Show grants for users */
SHOW GRANTS FOR 'gstusr'@'%';
SHOW GRANTS FOR 'usr'@'%';
SHOW GRANTS FOR 'supusr'@'%';
SHOW GRANTS FOR 'dbo'@'%';

/* Show grants for roles */
SHOW GRANTS FOR 'usrRole';
SHOW GRANTS FOR 'supUsrRole';
SHOW GRANTS FOR 'dboRole';