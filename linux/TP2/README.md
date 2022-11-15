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

httpd.conf[./httpd.conf]