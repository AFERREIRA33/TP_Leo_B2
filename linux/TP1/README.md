# TP1 : (re)Familiaration avec un système GNU/Linux

## 0. Préparation de la machine

- Setup de deux machines Rocky Linux configurées de façon basique

node1.tp1.b2 :  
```
[xouxou@node1 ~]$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=54 time=24.4 ms
[...]
[xouxou@node1 ~]$ ping 10.101.1.12
PING 10.101.1.12 (10.101.1.12) 56(84) bytes of data.
64 bytes from 10.101.1.12: icmp_seq=1 ttl=64 time=0.843 ms
[...]
[xouxou@node1 ~]$ dig ynov.com
[...]
;; ANSWER SECTION:
ynov.com.               150     IN      A       104.26.10.233
ynov.com.               150     IN      A       172.67.74.226
ynov.com.               150     IN      A       104.26.11.233
[...]
;; SERVER: 1.1.1.1#53(1.1.1.1)
[xouxou@node1 ~]$ ping node2.tp1.b2
PING node2.tp1.b2 (10.101.1.12) 56(84) bytes of data.
64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=1 ttl=64 time=0.409 ms
[xouxou@node1 ~]$ sudo firewall-cmd --list-all
[sudo] password for xouxou:
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
node2.tp1.b2 :  
```
[xouxou@node2 ~]$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=54 time=20.6 ms
[...]
[xouxou@node2 ~]$ dig ynov.com
[...]
;; ANSWER SECTION:
ynov.com.               300     IN      A       104.26.10.233
ynov.com.               300     IN      A       104.26.11.233
ynov.com.               300     IN      A       172.67.74.226
[...]
;; SERVER: 1.1.1.1#53(1.1.1.1)
[xouxou@node2 ~]$ ping node1.tp1.b2
PING node1.tp1.b2 (10.101.1.11) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=1 ttl=64 time=0.509 ms
[xouxou@node2 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

### I. Utilisateurs

- Ajouter un utilisateur à la machine, qui sera dédié à son administration

```
[xouxou@node1 ~]$ useradd toto -m -s /bin/bash
[xouxou@node1 ~]$ sudo cat /etc/passwd | grep "toto"
toto:x:1001:1001::/home/toto:/bin/bash
```
```
[xouxou@node2 ~]$ useradd toto -m -s /bin/bash
[xouxou@node2 ~]$ sudo cat /etc/passwd | grep "toto"
[sudo] password for xouxou:
toto:x:1001:1001::/home/toto:/bin/bash
```

- Créer un nouveau groupe admins

```
[xouxou@node1 ~]$ sudo cat /etc/sudoers | grep "admins"
## Allows people in group admins to run all commands
%admins  ALL=(ALL)       ALL
```
```
[xouxou@node2 ~]$ sudo cat /etc/sudoers | grep "admins"
%admins  ALL=(ALL)       ALL
```
-  Ajouter votre utilisateur à ce groupe admins  
```
[toto@node1 home]$ sudo ls
toto  xouxou
```
```
[toto@node2 home]$ sudo ls
toto  xouxou
```

### 2. SSH
-  Pour cela...
```
PS C:\Users\xouxo> ssh toto@10.101.1.11
toto@10.101.1.11's password:
Last login: Mon Nov 14 18:13:37 2022
[toto@node1 ~]$
```
```
PS C:\Users\xouxo> ssh toto@10.101.1.12
toto@10.101.1.12's password:
Last login: Mon Nov 14 18:15:31 2022
[toto@node2 ~]$
```
## II. Partitionnement

### 2. Partitionnement

- Utilisez LVM pour...
```
[toto@node1 ~]$ sudo vgdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBcbdc3ae0-217cf4b4_ PVID kuj5VROBYsWFfOduHtmE5Ih4p9Sq3px8 last seen on /dev/sda2 not found.
  --- Volume group ---
  VG Name               mygroup
  System ID
[...]
  Cur PV                2
  Act PV                2
[...]
[toto@node1 ~]$ sudo lvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBcbdc3ae0-217cf4b4_ PVID kuj5VROBYsWFfOduHtmE5Ih4p9Sq3px8 last seen on /dev/sda2 not found.
  --- Logical volume ---
  LV Path                /dev/mygroup/firstLV
  LV Name                firstLV
  VG Name                mygroup
[...]
  LV Size                1.00 GiB
[...]

  --- Logical volume ---
  LV Path                /dev/mygroup/secondLV
  LV Name                secondLV
  VG Name                mygroup
[...]
  LV Size                1.00 GiB
[...]

  --- Logical volume ---
  LV Path                /dev/mygroup/thirdLV
  LV Name                thirdLV
  VG Name                mygroup
[...]
  LV Size                1.00 GiB
[toto@node1 ~]$ mount | grep mnt
/dev/mapper/mygroup-firstLV on /mnt/part1 type ext4 (rw,relatime,seclabel)
/dev/mapper/mygroup-secondLV on /mnt/part2 type ext4 (rw,relatime,seclabel)
/dev/mapper/mygroup-thirdLV on /mnt/part3 type ext4 (rw,relatime,seclabel)
```
- Grâce au fichier /etc/fstab, faites en sorte que cette partition soit montée automatiquement au démarrage du système.
```
[toto@node1 ~]$ sudo cat /etc/fstab | grep "part"
[sudo] password for toto:
/dev/mygroup/firstLV /mnt/part1 ext4 defaults 0 0
/dev/mygroup/secondLV /mnt/part2 ext4 defaults 0 0
/dev/mygroup/thirdLV /mnt/part3 ext4 defaults 0 0
```
## III. Gestion de services

### 1. Interaction avec un service existant

- Assurez-vous que...
```
[toto@node1 ~]$ systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2022-11-14 18:43:08 CET; 1h 18min ago
       Docs: man:firewalld(1)
   Main PID: 656 (firewalld)
      Tasks: 2 (limit: 5907)
     Memory: 42.2M
        CPU: 348ms
     CGroup: /system.slice/firewalld.service
             └─656 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid
```

### 2. Création de service

-  Créer un fichier qui définit une unité de service
```
[toto@node1 ~]$ sudo systemctl status web
● web.service - Very simple web service
     Loaded: loaded (/etc/systemd/system/web.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2022-11-14 20:10:24 CET; 9min ago
[...]
```
- Une fois le service démarré, assurez-vous que pouvez accéder au serveur web
```
[toto@node2 ~]$ curl 10.101.1.11:8888
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
[...]
```

### B. Modification de l'unité

- Préparez l'environnement pour exécuter le mini serveur web Python
```
[toto@node1 ~]$ ls -al /var/www/meow/t
-rw-r--r--. 1 web root 5 Nov 14 20:27 /var/www/meow/t
```

- Modifiez l'unité de service web.service créée précédemment en ajoutant les clauses
```
[toto@node2 ~]$ curl 10.101.1.11:8888
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="t">t</a></li>
</ul>
<hr>
</body>
</html>
```

