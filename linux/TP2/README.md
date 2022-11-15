# TP2 : Gestion de service

## I. Un premier serveur web

### 1. Installation

- Installer le serveur Apache
```
[xouxou@localhost conf]$ pwd
/etc/httpd/conf
[xouxou@localhost conf]$ ls
httpd.conf  magic
```

- Démarrer le service Apache

```
[xouxou@localhost conf]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-11-15 10:11:17 CET; 5min ago
       Docs: man:httpd.service(8)
[...]
```

- TEST

```
[xouxou@localhost conf]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[xouxou@localhost conf]$ curl localhost
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
```
```
PS C:\Users\xouxo> curl 10.102.1.11:80
curl : HTTP Server Test Page
This page is used to test the proper operation of an HTTP server after it has been installed on a Rocky Linux system.
If you can read this page, it means that the software it working correctly.
Just visiting?
```

### 2. Avancer vers la maîtrise du service

- Le service Apache...

```
[xouxou@localhost /]$ sudo cat /usr/lib/systemd/system/httpd.service
[...]
[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)
[...]
```

- Déterminer sous quel utilisateur tourne le processus Apache

```
[xouxou@localhost /]$ sudo cat /etc/httpd/conf/httpd.conf | grep "apache"
User apache
Group apache
[xouxou@localhost /]$ ps -ef |grep apache
apache      1285    1284  0 10:11 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1286    1284  0 10:11 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1287    1284  0 10:11 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1288    1284  0 10:11 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
xouxou      1720     871  0 10:53 pts/0    00:00:00 grep --color=auto apache
[xouxou@localhost /]$ sudo ls -al /usr/share/testpage/ | grep "index"
-rw-r--r--.  1 root root 7620 Jul  6 04:37 index.html
```

- Changer l'utilisateur utilisé par Apache

```
[xouxou@localhost /]$ ps -ef | grep "toto"
toto        1817    1816  0 11:13 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1818    1816  0 11:13 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1819    1816  0 11:13 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1820    1816  0 11:13 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

- Faites en sorte que Apache tourne sur un autre port

```
[xouxou@localhost /]$ sudo ss -tulpn | grep LISTEN
tcp   LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=679,fd=3))
tcp   LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=679,fd=4))
tcp   LISTEN 0      511                *:6969            *:*    users:(("httpd",pid=2054,fd=4),("httpd",pid=2053,fd=4),("httpd",pid=2052,fd=4),("httpd",pid=2048,fd=4))
[...]
[xouxou@localhost /]$ curl localhost:6969
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
[...]
```
```
PS C:\Users\xouxo> curl 10.102.1.11:6969
curl : HTTP Server Test Page
This page is used to test the proper operation of an HTTP server after it has been installed on a Rocky Linux system.
If you can read this page, it means that the software it working correctly.
Just visiting?
```

[httpd.conf](./httpd.conf)

## II. Une stack web plus avancée

### 2. Setup

#### A. Base de données

- Install de MariaDB sur db.tp2.linux
```
[xouxou@db ~]$ sudo dnf install mariadb-server
Last metadata expiration check: 0:01:27 ago on Tue 15 Nov 2022 12:00:20 PM CET.
Dependencies resolved.
[...]
[xouxou@db ~]$ sudo !!
sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
[xouxou@db ~]$ sudo systemctl start mariadb
[xouxou@db ~]$ sudo !!
sudo mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] y
Enabled successfully!
Reloading privilege tables..
 ... Success!


You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] n
 ... skipping.

By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
[xouxou@db ~]$ sudo ss -tulpn | grep LISTEN | grep mariadb
tcp   LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=3154,fd=16))
```

- Préparation de la base pour NextCloud

```
[xouxou@db ~]$ sudo mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 18
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.102.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.102.1.11';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)
```

- Exploration de la base de données

```
[xouxou@web ~]$ mysql -u nextcloud -h 10.102.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 19
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW DATABASES;
E <DATABASE_NAME>+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE nextcloud;
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)
```

- Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données

```
MariaDB [(none)]> select user, host from mysql.user;
+-------------+-------------+
| User        | Host        |
+-------------+-------------+
| nextcloud   | 10.102.1.11 |
| mariadb.sys | localhost   |
| mysql       | localhost   |
| root        | localhost   |
+-------------+-------------+
4 rows in set (0.001 sec)
```

#### B. Serveur Web et NextCloud

-  Install de PHP

```
[xouxou@web ~]$ sudo dnf install -y php81-php
[...]
Installed:
  checkpolicy-3.3-1.el9.x86_64                             environment-modules-5.0.1-1.el9.x86_64
  libsodium-1.0.18-8.el9.x86_64                            libxslt-1.1.34-9.el9.x86_64
  oniguruma5php-6.9.8-1.el9.remi.x86_64                    php81-php-8.1.12-1.el9.remi.x86_64
  php81-php-cli-8.1.12-1.el9.remi.x86_64                   php81-php-common-8.1.12-1.el9.remi.x86_64
  php81-php-fpm-8.1.12-1.el9.remi.x86_64                   php81-php-mbstring-8.1.12-1.el9.remi.x86_64
  php81-php-opcache-8.1.12-1.el9.remi.x86_64               php81-php-pdo-8.1.12-1.el9.remi.x86_64
  php81-php-sodium-8.1.12-1.el9.remi.x86_64                php81-php-xml-8.1.12-1.el9.remi.x86_64
  php81-runtime-8.1-2.el9.remi.x86_64                      policycoreutils-python-utils-3.3-6.el9_0.noarch
  python3-audit-3.0.7-101.el9_0.2.x86_64                   python3-libsemanage-3.3-2.el9.x86_64
  python3-policycoreutils-3.3-6.el9_0.noarch               python3-setools-4.4.0-4.el9.x86_64
  python3-setuptools-53.0.0-10.el9.noarch                  scl-utils-1:2.0.3-2.el9.x86_64
  tcl-1:8.6.10-6.el9.x86_64
```
-  Install de tous les modules PHP nécessaires pour NextCloud

```
Complete!
[xouxou@web ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
[...]
Upgraded:
  openssl-1:3.0.1-43.el9_0.x86_64                          openssl-libs-1:3.0.1-43.el9_0.x86_64
Installed:
  fontconfig-2.13.94-2.el9.x86_64                            fribidi-1.0.10-6.el9.x86_64
  gd3php-2.3.3-8.el9.remi.x86_64                             gdk-pixbuf2-2.42.6-2.el9.x86_64
  jbigkit-libs-2.1-23.el9.x86_64                             jxl-pixbuf-loader-0.6.1-8.el9.x86_64
  libX11-1.7.0-7.el9.x86_64                                  libX11-common-1.7.0-7.el9.noarch
  libXau-1.0.9-8.el9.x86_64                                  libXpm-3.5.13-7.el9.x86_64
  libaom-3.2.0-4.el9.x86_64                                  libavif-0.10.1-3.el9.x86_64
  libdav1d-0.9.2-1.el9.x86_64                                libicu71-71.1-2.el9.remi.x86_64
  libimagequant-2.17.0-1.el9.x86_64                          libjpeg-turbo-2.0.90-5.el9.x86_64
  libjxl-0.6.1-8.el9.x86_64                                  libraqm-0.8.0-1.el9.x86_64
  libtiff-4.2.0-3.el9.x86_64                                 libvmaf-2.3.0-2.el9.x86_64
  libwebp-1.2.0-3.el9.x86_64                                 libxcb-1.13.1-9.el9.x86_64
  php81-php-bcmath-8.1.12-1.el9.remi.x86_64                  php81-php-gd-8.1.12-1.el9.remi.x86_64
  php81-php-gmp-8.1.12-1.el9.remi.x86_64                     php81-php-intl-8.1.12-1.el9.remi.x86_64
  php81-php-mysqlnd-8.1.12-1.el9.remi.x86_64                 php81-php-pecl-zip-1.21.1-1.el9.remi.x86_64
  php81-php-process-8.1.12-1.el9.remi.x86_64                 remi-libzip-1.9.2-3.el9.remi.x86_64
  shared-mime-info-2.1-4.el9.x86_64                          svt-av1-libs-0.8.7-2.el9.x86_64
  xml-common-0.6.3-58.el9.noarch

Complete!
```

- Récupérer NextCloud

```
[xouxou@web ~]$ sudo ls -al /var/www/ | grep nextcloud
drwxr-xr-x.  3 root root   23 Nov 15 13:02 tp2_nextcloud[xouxou@web ~]$ sudo ls -al /var/www/ | grep nextcloud
drwxr-xr-x.  3 root root   23 Nov 15 13:02 tp2_nextcloud
```

- Adapter la configuration d'Apache

```
[xouxou@web ~]$ sudo cat /etc/httpd/conf.d/nextcloud.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp2_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp2.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp2_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

- Redémarrer le service Apache pour qu'il prenne en compte le nouveau fichier de conf

```
[xouxou@web ~]$ sudo cat /etc/httpd/conf.d/nextcloud.conf
<VirtualHost *:80>
[...]


[xouxou@web ~]$ sudo systemctl restart httpd
[xouxou@web ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
    Drop-In: /usr/lib/systemd/system/httpd.service.d
             └─php81-php-fpm.conf
     Active: active (running) since Tue 2022-11-15 12:32:48 CET; 2s ago
```
#### C. Finaliser l'installation de NextCloud

- Exploration de la base de données

```
MariaDB [(none)]> SELECT COUNT(*) as nextcloud FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'nextcloud';
+-----------+
| nextcloud |
+-----------+
|        95 |
+-----------+
1 row in set (0.001 sec)
```
