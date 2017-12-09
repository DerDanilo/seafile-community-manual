[TOC]

---

# What is fail2ban?
Please check the [Wikipedia page](https://en.wikipedia.org/wiki/Fail2ban).

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
The config files can be found [here](/config_files/fail2ban/)