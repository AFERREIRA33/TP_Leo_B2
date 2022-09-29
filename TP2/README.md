# TP2 : Ethernet, IP, et ARP

## I. Setup IP

- Mettez en place une configuration réseau fonctionnelle entre les deux machines

adresse ip des machines :  
    - 192.168.1.1  
    - 192.168.1.2  
masque :  
    - 255.255.255.192 = /26  
adresse réseau :  
    - 192.168.1.0  
adresse broadcast :  
    - 192.168.1.63

```
PS C:\Users\xouxo> netsh interface ipv4 set address name="Ethernet" static 192.168.1.2 255.255.255.192 192.168.1.1
```

- Prouvez que la connexion est fonctionnelle entre les deux machines

```
PS C:\Users\xouxo> netsh interface ipv4 set address name="Ethernet" static 192.168.1.2 255.255.255.192 192.168.1.1
```

- Wireshark it

[ping](./ping.pcapng)
