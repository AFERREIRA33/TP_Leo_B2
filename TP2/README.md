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

[ping sur wireshark](./ping.pcapng) 

Le premier ICMP est de type "echo (ping) request"  
Le second ICMP est de type "echo (ping) reply"  


## II. ARP my bro

- Check the ARP table

```
PS C:\Users\xouxo> arp -a
[...]
Interface : 192.168.1.2 --- 0xa
  Adresse Internet      Adresse physique      Type
  192.168.1.1           ac-9e-17-bf-94-9d     dynamique
[...]
PS C:\Users\xouxo> ipconfig /all
[...]
Carte Ethernet Ethernet :

[...]
   Passerelle par défaut. . . . . . . . . : 192.168.1.1
```

- Manipuler la table ARP
```
PS C:\Users\xouxo> arp -a
[...]
Interface : 192.168.1.2 --- 0xa
  Adresse Internet      Adresse physique      Type
  192.168.1.1           ac-9e-17-bf-94-9d     dynamique
  192.168.1.63          ff-ff-ff-ff-ff-ff     statique
  224.0.0.22            01-00-5e-00-00-16     statique
  224.0.0.251           01-00-5e-00-00-fb     statique
  224.0.0.252           01-00-5e-00-00-fc     statique
  239.255.255.250       01-00-5e-7f-ff-fa     statique
PS C:\Users\xouxo> netsh interface IP delete arpcache
Ok.

PS C:\Users\xouxo> arp -a
[...]
Interface : 192.168.1.2 --- 0xa
  Adresse Internet      Adresse physique      Type
  224.0.0.22            01-00-5e-00-00-16     statique
  239.255.255.250       01-00-5e-7f-ff-fa     statique
```

- Wireshark it

[échange ARP](./ARP.pcapng)

source 1e : ASUSTekC_ac:92:58  / Destinataire: Broadcast
source 2e :ASUSTekC_bf:94:9d / Destnataire: ASUSTekC_ac:92:58
la premiere source est l'ordinateur envoyant la requete et la seconde est celle qui répond avec son adresse mac


