[TOC]

---

# What is MariaDB?
We install MariaDB as database server.  
If you want further information please check the [Wikipedia page](https://en.wikipedia.org/wiki/MariaDB).

# Tasks
* Install MariaDB
* Enable MariaDB autostart


---

# Install MariaDB

**Debian/Ubuntu/Raspbian**

```sh
root@cloudserver:~# apt-get update && apt-get install mariadb-server
root@cloudserver:~# systemctl enable mariadb
```

**CentOS**

```sh
root@cloudserver:~# yum install mariadb-server
root@cloudserver:~# systemctl enable mariadb
```

# Enable MariaDB autostart

**Debian/Ubuntu/Raspbian/CentOS**
```sh
root@cloudserver:~# systemctl enable mariadb
```