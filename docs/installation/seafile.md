[TOC]

---

# Tasks
* Install Seafile Server
* Enable Seafile Server autostart

---

## Install Seafile Server
We will install Seafile Server in `/opt/seafile`, Seafile data in `/srv/seafile_data`.

### Install required packages

**Debian**
```sh
root@cloudserver:~# apt-get install python-setuptools python-imaging python-ldap python-mysqldb python-memcache python-urllib3
```

**Ubuntu**
```sh
root@cloudserver:~# apt-get install python-setuptools python-imaging python-ldap python-mysqldb python-memcache python-urllib3
```

**CentOS**
```sh
root@cloudserver:~# yum install python-setuptools python-imaging python-ldap python-mysqldb python-memcache python-urllib3
```

### Create system user
Create a user and his own group to run the Seafile Server. We choose the name `seafserver` for the user as well as for his group. `useradd -h` for a short help of the switches.
```sh
root@cloudserver:~# mkdir /opt/seafile
root@cloudserver:~# useradd -U -m -d /opt/seafile seafserver
```

You can check the result:
```sh
root@cloudserver:~#  ls -l /opt/seafile/
total 4
drwxr-xr-x 2 seafserver seafserver 4096 Jul  3 17:10 Server
root@cloudserver:~#  grep seafserver /etc/passwd
seafserver:x:1001:1001::/opt/seafile:
root@cloudserver:~#  grep seafserver /etc/group
seafserver:x:1001:
```

### Download latest stable Seafile Server package
Download the lastest Seafile Server package from [here](https://www.seafile.com/en/download) and put it in `/opt/Seafile/Server/installed`. Adjust the version number.
```sh
root@cloudserver:~#  mkdir /opt/seafile/installed
root@cloudserver:~#  wget -P /opt/seafile/installed https://download.seadrive.org/seafile-server_6.2.2_x86-64.tar.gz
```

### Untar the package
```sh
root@cloudserver:~# tar -xz -C /opt/seafile -f /opt/seafile/installed/seafile-server_*
```

It should look something like this:
```sh
root@cloudserver:~# ls -l /opt/seafile
total 8
drwxr-xr-x 2 root root 4096 Jul  3 17:22 installed
drwxrwxr-x 6  500  500 4096 Jun 13 07:52 seafile-server-6.1.1
```

### Configure Seafile Server and databases.
```sh
root@cloudserver:~# mkdir /srv/seafile-data
root@cloudserver:~# /opt/seafile/seafile-server-*/setup-seafile-mysql.sh
```

- `[ server name ]` Cloud (whatever you like)
- `[ This server's ip or domain ]` 192.168.1.2 (Server's IP address)
- `[ default "/opt/seafile/seafile-data" ]` /srv/seafile-data
- `[ default "8082" ]` (leave the port as it is)
- `[ 1 or 2 ]` 1 (create new databases)
- `[ default "localhost" ]` (database runs on this server)
- `[ default "3306" ]` (standard port for mysql or mariadb)
- `[ root password ]` <enter root password>
- `[ default "seafile" ]` (it's the name of the user in mariadb)
- `[ password for seafile ]` (give the user a password, no need to remember)
- `[ default "ccnet-db" ]`
- `[ default "seafile-db" ]`
- `[ default "seahub-db" ]`

### Fix file and folder permission
Now the user seafserver needs to own the whole stuff:
```sh
root@cloudserver:~# chown -R seafserver:seafserver /opt/seafile  /srv/seafile-data
```

It should look like this:
```sh
root@cloudserver:~# ls -l /opt/seafile
total 20
drwx------ 2 seafserver seafserver 4096 Jul  3 17:59 ccnet
drwx------ 2 seafserver seafserver 4096 Jul  3 17:59 conf
drwxr-xr-x 2 seafserver seafserver 4096 Jul  3 17:22 installed
drwxrwxr-x 6 seafserver seafserver 4096 Jun 13 07:52 seafile-server-6.1.1
lrwxrwxrwx 1 seafserver seafserver   20 Jul  3 17:59 seafile-server-latest -> seafile-server-6.1.1
drwxr-xr-x 3 seafserver seafserver 4096 Jul  3 17:59 seahub-data
root@cloudserver:~# ls -l /srv
total 4
drwx------ 3 seafserver seafserver 4096 Jul  3 17:59 seafile-data
```

### First Start of Seafile Server
Now we can start Seafile Server as user 'seafserver'
```sh
root@cloudserver:~# su -l seafserver
$ seafile-server-latest/seafile.sh start
$ seafile-server-latest/seahub.sh start
```

- [ admin email ] (enter the mail address you'll use as admin account)
- [ admin password ] (give it a password)
- [ admin password again ] (password again)

--- 

## Verification
Use `nmap` to check the necessary ports are open. `22` is `SSH`, only open if you installed `SSH server`. `3306` is `mariadb`, only bound to `localhost`, 
not accessible from outside via network. `8000` is `seahub`, the `web interface`. `8082` is `seafile`, the `data service daemon`:
```sh
$ nmap localhost

Starting Nmap 7.40 ( https://nmap.org ) at 2017-07-04 06:53 EDT
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000025s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 996 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
3306/tcp open  mysql
8000/tcp open  http-alt
8082/tcp open  blackice-alerts

Nmap done: 1 IP address (1 host up) scanned in 0.03 seconds
$ nmap 192.168.1.2

Starting Nmap 7.40 ( https://nmap.org ) at 2017-07-04 06:59 EDT
Nmap scan report for 192.168.1.2
Host is up (0.000024s latency).
Not shown: 997 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
8000/tcp open  http-alt
8082/tcp open  blackice-alerts

Nmap done: 1 IP address (1 host up) scanned in 0.03 seconds
```
For a test open a web browser and log into your new Seafile Server:
```bash
http://192.168.1.2/8000/
```

Now stop Seafile Server
```sh
$ seafile-server-latest/seahub.sh stop
$ seafile-server-latest/seafile.sh stop
$ exit
```

There is some data located in the `/opt` directory. We should change this and move the data to `/srv`. A link will give Seafile Server access to its data:
```sh
root@cloudserver:~# mv /opt/seafile/seahub-data /srv/seahub-data/
root@cloudserver:~# ln -s /opt/seafile/seahub-data /srv/seahub-data
```

At least start your Seafile Server again as user 'seafserver' to check it's still working. Stop Seafile Server before proceeding to the next step.

--- 

## Enable Seafile Server autostart (systemd)

For a convenient start of Seafile Server we need some appropriate definition files for the operating system. Debian 9/Ubuntu/CentOS use systemd as 
init system, so we create service files for systemd. Create a file ` /etc/systemd/system/seafile.service` with the following contents:
```
[Unit]
Description=Seafile
# add mysql.service or postgresql.service depending on your database to the line below
After=network.target mysql.service

[Service]
Type=oneshot
ExecStart=/opt/seafile/seafile-server-latest/seafile.sh start
ExecStop=/opt/seafile/seafile-server-latest/seafile.sh stop
RemainAfterExit=yes
User=seafserver
Group=seafserver

[Install]
WantedBy=multi-user.target
```

Create another file `/etc/systemd/system/seahub.service` with this contents:
```
[Unit]
Description=Seafile hub
After=network.target seafile.service

[Service]
# change start to start-fastcgi if you want to run fastcgi
ExecStart=/opt/seafile/seafile-server-latest/seahub.sh start
ExecStop=/opt/seafile/seafile-server-latest/seahub.sh stop
User=seafserver
Group=seafserver
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Reload the systemd configuration:
```sh
root@cloudserver:~# systemctl daemon-reload
```

Now you should be able to start your Seafile Server like any other ordinary service:
```sh
root@cloudserver:~# systemctl start seafile
root@cloudserver:~# systemctl start seahub
```

Verify if it is working (web browser: `http://192.168.1.2:8000/`)

You can stop Seafile Server:
```sh
root@cloudserver:~# systemctl stop seahub
root@cloudserver:~# systemctl stop seafile
```

To start Seafile Server at system startup the services need to be enabled:
```sh
root@cloudserver:~# systemctl enable seafile
Created symlink /etc/systemd/system/multi-user.target.wants/seafile.service → /etc/systemd/system/seafile.service.
root@cloudserver:~# systemctl enable seahub
Created symlink /etc/systemd/system/multi-user.target.wants/seahub.service → /etc/systemd/system/seahub.service.
```

To verify the automatic startup you need to reboot your server and afterwards Seafile Server should be running.  
But you can do a reboot later. Continue with the next step.
