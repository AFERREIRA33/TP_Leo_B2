# Module 7 : Fail2Ban

```
[xouxou@Proxy ~]$ sudo dnf install epel-release -y
Complete!
[xouxou@Proxy ~]$ sudo dnf install fail2ban -y
Complete!
```

```
[xouxou@Proxy jail.d]$ cat 00-firewalld.conf
# This file is part of the fail2ban-firewalld package to configure the use of
# the firewalld actions as the default actions.  You can remove this package
# (along with the empty fail2ban meta-package) if you do not use firewalld
[DEFAULT]
banaction = firewallcmd-rich-rules
banaction_allports = firewallcmd-rich-rules
[sshd]
enabled = true
maxretry = 3
findtime = 60
bantime = 1200
```
