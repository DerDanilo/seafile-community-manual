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
```

**CentOS**

```sh
root@cloudserver:~# yum install mariadb-server
```

**Arch Linux | ARM**

```sh
root@cloudserver:~# pacman -S mariadb
root@cloudserver:~# mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
root@cloudserver:~# mysql_secure_installation
```

# Enable MariaDB autostart

**Debian/Ubuntu/Raspbian/CentOS/Arch Linux | ARM**
```sh
root@cloudserver:~# systemctl enable mariadb
```

