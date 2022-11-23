# Module 2 : Réplication de base de données

Master Machine:
```
[xouxou@Master /]$ cat /etc/my.cnf.d/mariadb-server.cnf
# Allow server to accept connections on all interfaces.
#
bind-address=0.0.0.0
#
[mariadb]
# This group is only read by MariaDB-10.5 servers.
# If you use the same .cnf file for MariaDB of different versions,
# use this group for options that older servers don't understand
log-bin
server_id=1
log-basename=master1
binlog-format=mixed
[mariadb-10.5]
```
```
MariaDB [(none)]> CREATE USER 'slave'@'10.102.1.14' identified by 'toto';
Query OK, 0 rows affected (0.003 sec)
MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'slave'@'10.102.1.14';
Query OK, 0 rows affected (0.003 sec)
MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)
MariaDB [(none)]> SHOW MASTER STATUS;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| master1-bin.000001 |     1369 |              |                  |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)
```
Slave Machine:
```
cat /etc/my.cnf.d/mariadb-server.cnf
# Allow server to accept connections on all interfaces.
#
bind-address=0.0.0.0
#
[mariadb]
# This group is only read by MariaDB-10.5 servers.
# If you use the same .cnf file for MariaDB of different versions,
# use this group for options that older servers don't understand
log-bin
server_id=2
log-basename=slave1
binlog-format=mixed
[mariadb-10.5]
```
```
MariaDB [(none)]> STOP SLAVE;
Query OK, 0 rows affected, 1 warning (0.000 sec)
MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST = '10.102.1.12', MASTER_USER = 'slave', MASTER_PASSWORD = 'toto', MASTER_LOG_FILE = 'master1-bin.000001', MAS
TER_LOG_POS = 1369;
Query OK, 0 rows affected (0.007 sec)
MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.001 sec)
```

Ajout Nexcloud to Slave:

```
[xouxou@Master ~]$ sudo mysqldump -u root nextcloud > toto.sql
[xouxou@Master ~]$ scp toto.sql xouxou@10.102.1.14:/tmp/
```
```
[xouxou@Slave ~]$ sudo mv /tmp/toto.sql ./
[xouxou@Slave /]$ cat nano ./toto.sql
cat: nano: No such file or directory
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
use nextcloud;
-- MariaDB dump 10.19  Distrib 10.5.16-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: nextcloud
-- ------------------------------------------------------
-- Server version       10.5.16-MariaDB-log
[xouxou@Slave /]$ sudo mysql -u root < toto.sql
```
```
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| nextcloud          |
| performance_schema |
+--------------------+
4 rows in set (0.000 sec)
```
