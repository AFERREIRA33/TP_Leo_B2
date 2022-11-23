#!/bin/bash

dnf install httpd -y

dnf config-manager --set-enabled crb -y
dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
dnf module list php -y
dnf module enable php:remi-8.1 -y
dnf install -y php81-phpdnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
mkdir /var/www

curl -o /nextcloud.zip https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip

dnf install unzip -y

unzip /nextcloud.zip -d /var/www/
echo "<VirtualHost *:80>
  DocumentRoot /var/www/nextcloud/
  ServerName $HOSTNAME
  <Directory /var/www/nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>" > /etc/httpd/conf.d/nextcloud.conf
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload
systemctl restart httpd
