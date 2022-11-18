# Module 1 : Reverse Proxy

### II. Setup

sur le proxy : 
```
sudo dnf install nginx

sudo systemctl enable nginx

sudo firewall-cmd --add-port=80/tcp -- permanent

sudo vim /etc/nginx/conf.d/n.conf
sudo cat /etc/nginx/conf.d/n.conf
server {
    server_name web.tp2.linux;
    listen 80;

    location / {
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_pass http://10.102.1.11:80;
    }
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }
    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```
sur web :

```
sudo vim /var/www/tp2_nextcloud/config/config.php
sudo cat /var/www/tp2_nextcloud/config/config.php
<?php
$CONFIG = array (
  'instanceid' => 'oc8r862ul50q',
  'passwordsalt' => 'KwrvDUQK1JpJmgxoYDBiFnljH6MYCB',
  'secret' => 'iZdbQ25o7yqpdQQnkr6hgbetORqCFWSkqFlGjHMap+4JGByc',
  'trusted_domains' =>
  array (
     1 => 'web.tp2.linux',
  ),
  'datadirectory' => '/var/www/tp2_nextcloud/data',
  'dbtype' => 'mysql',
  'version' => '25.0.0.15',
  'overwrite.cli.url' => 'http://web.tp2.linux',
  'dbname' => 'nextcloud',
  'dbhost' => '10.102.1.12:3306',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => 'pewpewpew',
  'installed' => true,
);
```
sur votre pc dans le fichier hosts :

```
<IP du proxy> web.tp2.linux 
```

## III. HTTPS

```
[xouxou@proxy ~]$ sudo cat /etc/nginx/conf.d/n.conf
server {
    server_name web.tp2.linux;

    listen 443 ssl;
    listen [::]:443 ssl;
    include snippets/self-signed.conf;
    include snippets/ssl-params.conf;
    location / {
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_pass http://10.102.1.11:80;
    }
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }
    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
[xouxou@proxy ~]$ sudo mkdir /etc/ssl/private/
[xouxou@proxy ~]$ sudo mkdir /etc/ssl/private/nginx-selfsigned.key
[xouxou@proxy ~]$ sudo touch /etc/ssl/private/nginx-selfsigned.key
[xouxou@proxy ~]$ sudo mkdir /etc/nginx/snippets/
[xouxou@proxy ~]$ sudo touch /etc/nginx/snippets/self-signed.conf
[xouxou@proxy ~]$ sudo touch /etc/nginx/snippets/ssl-params.conf
[xouxou@proxy ~]$ sudo cat /etc/nginx/snippets/self-signed.conf
ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
[xouxou@proxy ~]$ sudo firewall-cm --add-port=443/tcp --permanent
[xouxou@proxy ~]$ sudo firewall-cmd --reload
[xouxou@proxy ~]$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
[xouxou@proxy ~]$ sudo systemctl restart nginx
```

```
[xouxou@web /]$ sudo cat /var/www/tp2_nextcloud/config/config.php
[sudo] password for xouxou:
<?php
$CONFIG = array (
  'instanceid' => 'oc8r862ul50q',
  'passwordsalt' => 'KwrvDUQK1JpJmgxoYDBiFnljH6MYCB',
  'secret' => 'iZdbQ25o7yqpdQQnkr6hgbetORqCFWSkqFlGjHMap+4JGByc',
  'trusted_domains' =>
  array (
    0  => 'web.tp2.linux',
  ),
  'datadirectory' => '/var/www/tp2_nextcloud/data',
  'dbtype' => 'mysql',
  'version' => '25.0.0.15',
  'overwrite.cli.url' => 'http://web.tp2.linux',
  'dbname' => 'nextcloud',
  'dbhost' => '10.102.1.12:3306',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => 'pewpewpew',
  'installed' => true,
  'overwriteprotocol' => 'https',
);
```