# Module 5 : Monitoring

```
dnf install epel-release -y

sudo dnf install wget

sudo wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh

sudo systemctl start netdata

sudo systemctl enable netdata

firewall-cmd --permanent --add-port=19999/tcp

firewall-cmd --reload

sudo cat /etc/netdata/health_alarm_notify.conf
SEND_DISCORD="YES"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1043109335443710002/qXIjXWn2YloeyFj-n15hncNUHU_WWDrmmZ0HVpYGUdC5izXZAvAlQUKXGGVZWvB-_ipA"
DEFAULT_RECIPIENT_DISCORD="netdata"

[xouxou@db /]$ sudo cat /etc/netdata/health.d/cpu_usage.conf
alarm: cpu_usage
on: system.cpu
lookup: average -3s percentage foreach user,system
units: %
every: 10s
warn: $this > 50
crit: $this > 80
info: CPU utilization of users on the system itself.

sudo systemctl restart netdata
```

