# TP5

Basé sur le projet [Black_candy](https://github.com/blackcandy-org/black_candy/tree/7f9202bd8a9777d439e95eabd0654e9b4a336be9)

## Installation de docker :
```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io -y

sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo dnf install docker-compose-plugin
```

Installation du projet :
```
git clone https://github.com/AFERREIRA33/TP_Leo_B2.git

mv -t /home/<user> /home/<user>/TP_Leo_B2/linux/TP5/conf/docker-compose.yml

sudo systemctl start docker

sudo systemctl enable docker

sudo firewall-cmd --add-port=80/tcp --permanent

docker compose up -d
```

## Partitionnage :

il vous faudra 2 disqu dur en plus

```
sudo vgcreate VGMusicFile /dev/sdb
sudo lvcreate -l 100%FREE VGMusicFile -n LVMusicFile
sudo mkfs -t ext4 /dev/VGMusicFile/LVMusicFile
sudo  mkdir /mnt/MusicFile
sudo mount /dev/VGMusicFile/LVMusicFile /mnt/MusicFile/


sudo vgcreate VGMusicBackup /dev/sdc
sudo lvcreate -l 100%FREE VGMusicBackup -n LVMusicBackup
sudo mkfs -t ext4 /dev/VGMusicBackup/LVMusicBackup/sdc
sudo mkdir /mnt/MusicBackup
sudo mount /dev/VGMusicBackup/LVMusicBackup /mnt/MusicBackup/
```

## Backup : 

- initialiser 
```
sudo borg init --encryption=repokey /mnt/MusicBackup
```
- Déplacer les fichier dans conf :
```

cd
sudo mv -t /etc/systemd/system /home/<user>/TP_Leo_B2/linux/TP5/conf/backup.service /home/<user>/TP_Leo_B2/linux/TP5/conf/backup.timer

sudo mkdir /etc/backups

sudo mv -t /etc/backups /home/<user>/TP_Leo_B2/linux/TP5/conf/run.sh

sudo systemctl start backup.timer
sudo systemctl enable backup.timer
```