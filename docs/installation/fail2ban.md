[TOC]

---

# What is fail2ban?
We install fail2ban to protect the server from attacks and automatically block IP adresses.
If you want further information please check the [Wikipedia page](https://en.wikipedia.org/wiki/Fail2ban).

# Tasks
* Install Fail2ban
* Enable Fail2ban autostart
* Configure Fail2ban

---

# Install Fail2ban

**Debian/Ubuntu/Raspbian**

```sh
root@cloudserver:~# apt-get update && apt-get install Fail2ban
root@cloudserver:~# systemctl enable Fail2ban
```

**CentOS**

```sh
root@cloudserver:~# yum install Fail2ban
root@cloudserver:~# systemctl enable Fail2ban
```

# Enable Fail2ban autostart

**Debian/Ubuntu/Raspbian/CentOS**
```sh
root@cloudserver:~# systemctl enable Fail2ban
```

# Configure Fail2ban
Now proceed to configure fail2ban.
The config files can be found [here](/config/fail2ban/)