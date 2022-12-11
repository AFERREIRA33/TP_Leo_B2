#!/bin/bash
#
# Ferreira Alex 8/12/2022

[ ! -d "/log" ] && mkdir /log
[ ! -f "/log/BacupMusic.log" ] && touch /log/BacupMusic.log
borg create /mnt/MusicBackup::`date +%Y%m%d-%H%M%S` /mnt/MusicFile
cmd="borg create ::`date +%Y%m%d%-H%M%S`-BackuMusic --stats"
echo $cmd >> /log/BacupMusic.log