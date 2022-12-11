# TP5

Installation de docker :
```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io -y

sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo dnf install docker-compose-plugin
```

Installation du projet :
```
curl https://raw.githubusercontent.com/blackcandy-org/black_candy/v2.1.1/docker-compose.yml > docker-compose.yml

sudo systemctl start docker

sudo systemctl enable docker

sudo firewall-cmd --add-port=80/tcp --permanent

docker compose up -d
```
