 # TP3 : On va router des trucs

 ## I. ARP

### 1. Echange ARP

- Générer des requêtes ARP

```
[xouxou@marcel ~]$ ping 10.3.1.11
PING 10.3.1.11 (10.3.1.11) 56(84) bytes of data.
64 bytes from 10.3.1.11: icmp_seq=1 ttl=64 time=0.324 ms
64 bytes from 10.3.1.11: icmp_seq=2 ttl=64 time=0.177 ms
64 bytes from 10.3.1.11: icmp_seq=3 ttl=64 time=0.280 ms
64 bytes from 10.3.1.11: icmp_seq=4 ttl=64 time=0.441 ms
```
```
[xouxou@marcel ~]$ ip neigh show 10.3.1.11
10.3.1.11 dev enp0s8 lladdr 08:00:27:2e:14:11 STALE
```
l'adresse MAC de john est : 08:00:27:2e:14:11  
```
[xouxou@john ~]$ ip neigh show 10.3.1.12
10.3.1.12 dev enp0s8 lladdr 08:00:27:02:7f:a5 STALE
```
l'adresse MAC de marcel est : 08:00:27:02:7f:a5  

### 2. Analyse de trames

- Analyse de trames  
[tp2_arp.pcapng](./tp2_arp.pcapng)  
  
## II. Routage

### 1. Mise en place du routage

- Activer le routage sur le noeud router

```
[xouxou@localhost ~]$ sudo firewall-cmd --list-all
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
[xouxou@localhost ~]$ sudo firewall-cmd --get-active-zone
public
  interfaces: enp0s8 enp0s3
[xouxou@localhost ~]$ sudo firewall-cmd --add-masquerade --zone=public
success
[xouxou@localhost ~]$ sudo firewall-cmd --add-masquerade --zone=public --permanent
success
```

- Ajouter les routes statiques nécessaires pour que john et marcel puissent se ping
```
[xouxou@john ~]$ cat /etc/sysconfig/network-scripts/route-enp0s8
10.3.2.12 via 10.3.1.254 dev eth0
[xouxou@john ~]$ ip r s
default via 10.3.1.254 dev enp0s8 proto static metric 100
10.3.1.0/24 dev enp0s8 proto kernel scope link src 10.3.1.11 metric 100
10.3.2.12 via 10.3.1.254 dev enp0s8 proto static metric 100
[xouxou@john ~]$ ping 10.3.2.12
PING 10.3.2.12 (10.3.2.12) 56(84) bytes of data.
64 bytes from 10.3.2.12: icmp_seq=1 ttl=63 time=0.449 ms
64 bytes from 10.3.2.12: icmp_seq=2 ttl=63 time=1.34 ms
64 bytes from 10.3.2.12: icmp_seq=3 ttl=63 time=1.21 ms
64 bytes from 10.3.2.12: icmp_seq=4 ttl=63 time=0.727 ms
64 bytes from 10.3.2.12: icmp_seq=5 ttl=63 time=0.801 ms
^C
--- 10.3.2.12 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4064ms
rtt min/avg/max/mdev = 0.449/0.906/1.342/0.327 ms
```
```
[xouxou@marcel ~]$ cat /etc/sysconfig/network-scripts/route-enp0s8
10.3.1.11 via 10.3.2.254 dev eth0
[xouxou@marcel ~]$ ip r s
default via 10.3.2.254 dev enp0s8 proto static metric 100
10.3.1.11 via 10.3.2.254 dev enp0s8 proto static metric 100
10.3.2.0/24 dev enp0s8 proto kernel scope link src 10.3.2.12 metric 100
[xouxou@marcel ~]$ ping 10.3.2.12
PING 10.3.2.12 (10.3.2.12) 56(84) bytes of data.
64 bytes from 10.3.2.12: icmp_seq=1 ttl=64 time=0.078 ms
64 bytes from 10.3.2.12: icmp_seq=2 ttl=64 time=0.039 ms
64 bytes from 10.3.2.12: icmp_seq=3 ttl=64 time=0.049 ms
^C
--- 10.3.2.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2045ms
rtt min/avg/max/mdev = 0.039/0.055/0.078/0.016 ms
```

### 2. Analyse de trames

- Analyse des échanges ARP

```
[xouxou@john ~]$ ping 10.3.2.12
PING 10.3.2.12 (10.3.2.12) 56(84) bytes of data.
64 bytes from 10.3.2.12: icmp_seq=1 ttl=63 time=0.747 ms
64 bytes from 10.3.2.12: icmp_seq=2 ttl=63 time=1.19 ms
64 bytes from 10.3.2.12: icmp_seq=3 ttl=63 time=0.479 ms
^C
--- 10.3.2.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2052ms
rtt min/avg/max/mdev = 0.479/0.806/1.193/0.294 ms
[xouxou@john ~]$ ip neigh show
10.3.1.254 dev enp0s8 lladdr 08:00:27:ed:14:6b REACHABLE
10.3.1.1 dev enp0s8 lladdr 0a:00:27:00:00:04 REACHABLE
```
```
[xouxou@marcel ~]$ ip neigh show
10.3.2.1 dev enp0s8 lladdr 0a:00:27:00:00:12 REACHABLE
10.3.2.254 dev enp0s8 lladdr 08:00:27:68:70:89 STALE
```
```
[xouxou@localhost ~]$ sudo ip neigh flush all
[sudo] password for xouxou:
[xouxou@localhost ~]$ ip neigh show
10.3.1.11 dev enp0s8 lladdr 08:00:27:2e:14:11 STALE
10.3.2.12 dev enp0s3 lladdr 08:00:27:02:7f:a5 STALE
10.3.2.1 dev enp0s3 lladdr 0a:00:27:00:00:12 REACHABLE
```

on peut voir qu sur les tables arp de john et de marcel ils n'ont que la gateway donc le ping est passé par la passerelle pour rejoindre l'autre apareil.  

| ordre | type trame  | IP source  | MAC source                   | IP destination | MAC destination              |
|-------|-------------|------------|------------------------------|----------------|------------------------------|
| 1     | Requête ARP | x          | `router` `08:00:27:68:70:89` | x              | Broadcast `FF:FF:FF:FF:FF`   |
| 2     | Réponse ARP | x          | `marcel` `08:00:27:02:7f:a5` | x              | `router` `08:00:27:68:70:89` |
| 3     | Ping        | 10.3.2.254 | `router` `08:00:27:68:70:89` | 10.3.2.12      | `marcel` `08:00:27:02:7f:a5` |
| 4     | Pong        | 10.3.2.12  | `marcel` `08:00:27:02:7f:a5` | 10.3.2.254     | `router` `08:00:27:68:70:89` |  

[routage marcel](./tp2_routage_marcel.pcapng)

### 3. Accès internet

- Donnez un accès internet à vos machines

```
[xouxou@john ~]$ cat /etc/sysconfig/network
GATEWAY=10.3.1.254
[xouxou@john ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=112 time=15.6 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=112 time=15.5 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=112 time=14.9 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=112 time=15.0 ms
^C
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 14.943/15.260/15.560/0.268 ms
```
```
[xouxou@marcel ~]$ cat /etc/sysconfig/network
GATEWAY=10.3.2.254
[xouxou@marcel ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=112 time=16.0 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=112 time=15.8 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=112 time=15.3 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=112 time=15.1 ms
^C
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 15.113/15.547/15.983/0.363 ms
```
```
[xouxou@marcel ~]$ cat /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
```
```
[xouxou@john ~]$ cat /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
```

- Analyse de trames

| ordre | type trame | IP source          | MAC source                 | IP destination     | MAC destination            |
|-------|------------|--------------------|----------------------------|--------------------|----------------------------|
| 1     | ping       | `john` `10.3.1.11` | `john` `08:00:27:2e:14:11` | `8.8.8.8`          | `08:00:27:ed:14:6b`        |
| 2     | pong       | `8.8.8.8`          | `08:00:27:ed:14:6b`        | `john` `10.3.1.11` | `john` `08:00:27:2e:14:11` |  

[routage internet](./tp2_routage_internet.pcapng)

## III. DHCP

### 1. Mise en place du serveur DHCP
- Sur la machine john, vous installerez et configurerez un serveur DHCP (go Google "rocky linux dhcp server").

```
[xouxou@john ~]$ sudo systemctl enable dhcpd
Created symlink /etc/systemd/system/multi-user.target.wants/dhcpd.service → /usr/lib/systemd/system/dhcpd.service.
[xouxou@john ~]$ sudo systemctl status dhcpd
● dhcpd.service - DHCPv4 Server Daemon
     Loaded: loaded (/usr/lib/systemd/system/dhcpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-10-11 17:03:37 CEST; 17s ago
       Docs: man:dhcpd(8)
             man:dhcpd.conf(5)
   Main PID: 11048 (dhcpd)
     Status: "Dispatching packets..."
      Tasks: 1 (limit: 5907)
     Memory: 4.6M
        CPU: 6ms
     CGroup: /system.slice/dhcpd.service
             └─11048 /usr/sbin/dhcpd -f -cf /etc/dhcp/dhcpd.conf -user dhcpd -group dhcpd --no-pid
[...]
[xouxou@john ~]$ sudo cat /etc/dhcp/dhcpd.conf
[sudo] password for xouxou:
default-lease-time 900;
max-lease-time 10800;
ddns-update-style none;
authoritative;
subnet 10.3.1.0 netmask 255.255.255.0 {
  range 10.3.1.12 10.3.1.22;
  option routers 10.3.1.254;
  option subnet-mask 255.255.255.0;
  option domain-name-servers 8.8.8.8;
}
```
```
[xouxou@bob ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
NAME=enp0s8
DEVICE=enp0s8

BOOTPROTO=dhcp
ONBOOT=yes
[xouxou@bob ~]$ sudo dhclient -4 -s 10.3.1.11
[sudo] password for xouxou:
[xouxou@bob ~]$ ip a
[...]
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:07:d8:14 brd ff:ff:ff:ff:ff:ff
    inet 10.3.1.12/24 brd 10.3.1.255 scope global dynamic noprefixroute enp0s8
       valid_lft 809sec preferred_lft 809sec
    inet 10.3.1.13/24 brd 10.3.1.255 scope global secondary dynamic enp0s8
[...]
```
- Améliorer la configuration du DHCP
```
[xouxou@bob ~]$ ping 10.3.2.12
PING 10.3.2.12 (10.3.2.12) 56(84) bytes of data.
64 bytes from 10.3.2.12: icmp_seq=1 ttl=63 time=0.365 ms
64 bytes from 10.3.2.12: icmp_seq=2 ttl=63 time=0.489 ms
64 bytes from 10.3.2.12: icmp_seq=3 ttl=63 time=0.353 ms
64 bytes from 10.3.2.12: icmp_seq=4 ttl=63 time=0.392 ms
^C
--- 10.3.2.12 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3052ms
rtt min/avg/max/mdev = 0.353/0.399/0.489/0.053 ms
[xouxou@bob ~]$ ping 10.3.2.254
PING 10.3.2.254 (10.3.2.254) 56(84) bytes of data.
64 bytes from 10.3.2.254: icmp_seq=1 ttl=64 time=0.238 ms
64 bytes from 10.3.2.254: icmp_seq=2 ttl=64 time=0.281 ms
64 bytes from 10.3.2.254: icmp_seq=3 ttl=64 time=0.405 ms
^C
--- 10.3.2.254 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2035ms
rtt min/avg/max/mdev = 0.238/0.308/0.405/0.070 ms
[xouxou@bob ~]$ ip r s
default via 10.3.1.254 dev enp0s8
default via 10.3.1.254 dev enp0s8 proto dhcp src 10.3.1.12 metric 100
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 101
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 101
10.3.1.0/24 dev enp0s8 proto kernel scope link src 10.3.1.12 metric 100
[xouxou@bob ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=112 time=15.5 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=112 time=15.7 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=112 time=14.7 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 14.728/15.296/15.675/0.409 ms
[xouxou@bob ~]$ dig google.com

; <<>> DiG 9.16.23-RH <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3157
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             264     IN      A       142.250.178.142

;; Query time: 19 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Tue Oct 11 17:36:10 CEST 2022
;; MSG SIZE  rcvd: 55

[xouxou@bob ~]$ ping google.com
PING google.com (142.250.178.142) 56(84) bytes of data.
64 bytes from par21s22-in-f14.1e100.net (142.250.178.142): icmp_seq=1 ttl=112 time=15.3 ms
64 bytes from par21s22-in-f14.1e100.net (142.250.178.142): icmp_seq=2 ttl=112 time=14.9 ms
64 bytes from par21s22-in-f14.1e100.net (142.250.178.142): icmp_seq=3 ttl=112 time=15.0 ms
^C
--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 14.874/15.052/15.287/0.173 ms
```

2. Analyse de trames

- Analyse de trames  
[dhcp](./tp2_dhcp.pcapng)