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

- Analyse de trames
[tp2_arp.pcapng](./tp2_arp.pcapng)  
  
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

| ordre | type trame  | IP source | MAC source              | IP destination | MAC destination            |
|-------|-------------|-----------|-------------------------|----------------|----------------------------|
| 1     | Requête ARP | x         | `john` `AA:BB:CC:DD:EE` | x              | Broadcast `FF:FF:FF:FF:FF` |
| 2     | Réponse ARP | x         | ?                       | x              | `john` `AA:BB:CC:DD:EE`    |
| ...   | ...         | ...       | ...                     |                |                            |
| ?     | Ping        | ?         | ?                       | ?              | ?                          |
| ?     | Pong        | ?         | ?                       | ?              | ?                          |

