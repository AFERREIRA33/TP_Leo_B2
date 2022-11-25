# TP4 : Conteneurs

## I. Docker

### 1. Install

- Installer Docker sur la machine

```
[xouxou@Docker ~]$ sudo systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
     Active: active (running) since Thu 2022-11-24 11:11:00 CET; 1s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
[...]
[xouxou@Docker ~]$ sudo usermod -aG docker xouxou
```

### 3. Lancement de conteneurs

- Utiliser la commande docker run

```
[xouxou@Docker ~]$ docker run --name proot -d -p 8888:80 -m 6m --cpus="0.3" -v /home/xouxou/index.html:/usr/share/nginx/html/ -v /home/xouxou/menzi.conf:/usr/share/nginx/conf/ nginx
bc52895212b30c325e7051df49ace74096544e33ba4beec494327f846a8c7ce6
[xouxou@Docker ~]$ docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS    PORTS                                   NAMES
bc52895212b3   nginx     "/docker-entrypoint.…"   2 minutes ago   Created   0.0.0.0:8888->80/tcp, :::8888->80/tcp   proot
```

## III. docker-compose

### 1. Intro

[Dockerfile](./Dockerfile)

```
[xouxou@Docker ~]$ docker build . -t dockerfile
Sending build context to Docker daemon  17.92kB
Step 1/8 : FROM debian
[...]
Successfully built a13a0e82b5be
Successfully tagged dockerfile:latest
[xouxou@Docker ~]$ docker run -d --name aaab -p80:80 dockerfile
f46e8d455b7ec3cc190878556d32029fc627bc337b63ca838fe26c4a08ac1c06
[xouxou@Docker ~]$ curl localhost
yo
```

## III. docker-compose

### 1. Intro

### 2. Make your own meow

- Conteneurisez votre application

```
[xouxou@Docker ~]$ git clone https://github.com/AFERREIRA33/Scanner_reseau.git
[xouxou@Docker ~]$ docker build . -t dockerfile
[xouxou@Docker ~]$ docker compose up
```
[docker-compose](./app/docker-compose.yml)  
[dockerfile](./app/Dockerfile)