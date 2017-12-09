## Backup Installation
It is advised to have a Backup of the configuration. A little script will do this task. If you have the possibility to perform an easy backup of the whole server you can do it that way as well.
### Download the backup script
Download the script [BackupSeafileInstall](https://raw.githubusercontent.com/DerDanilo/Seafile-Best-Practise/master/BackupSeafileInstall "BackupSeafileInstall") and save it in `/usr/local/sbin/`.

Make it executable:
```sh
root@cloudserver:~# chmod 764 /usr/local/sbin/BackupSeafileInstall
```

### How it works
The script will save the configuration of Seafile Server, MariaDB (MySQL), Nginx and Let's Encrypt. The last two only if installed. Seafile Server installation is backed up completely, but no data.
The backups are tarballs (gzipped tar files). By default they go to `/srv/Backup/SeafileInstall/` and contain the creation date and time in their filenames. You can configure the backup location within the script.
Before performing the backup, the affected services will be stopped and started afterwards if they have been running before. This is needed because the database (MySQL od MariaDB) is saved on filesystem basis, which needs the service to be stopped!
### Parameters
Get it from the script itself:
```sh
root@cloudserver:~# BackupSeafileInstall --help
```

### Configuration
Edit the script and see what's in there to be configurable.
### Perform the backup
```sh
root@cloudserver:~# BackupSeafileInstall
```

### Test the result
See if it is there:
```sh
root@cloudserver:~# ls -l /srv/Backup/SeafileInstall
total 49740
-rw-r--r-- 1 root root 50932569 Jul 16 12:42 SeafileInstall201707161242.tgz
```

Verify its contents:
```sh
root@cloudserver:~# tar -tzf /srv/Backup/SeafileInstall/SeafileInstall201707161242.tgz | less
```

It should contain:
```
etc/systemd/system/seafile.service
etc/systemd/system/seahub.service
var/lib/mysql/
var/lib/mysql/seahub@002ddb/
var/lib/mysql/seahub@002ddb/base_userlastlogin.frm
...
var/lib/mysql/performance_schema/
var/lib/mysql/performance_schema/db.opt
opt/Seafile/Server/
opt/Seafile/Server/.bashrc
opt/Seafile/Server/seafile-server-latest
opt/Seafile/Server/seafile-server-6.1.1/
opt/Seafile/Server/seafile-server-6.1.1/setup-seafile.sh
...
opt/Seafile/Server/logs/seafile.log
opt/Seafile/Server/logs/seahub_django_request.log
opt/Seafile/Server/.bash_logout
opt/Seafile/Server/pids/
```

Of course if you have installed Nginx or Let's Encrypt later on, you should also see entries for that.
### Verify it's working
Just do a restore and verify it is working afterwards. If you want to be really sure not to lose something you might copy the current installation to a save location.
Stop the services. The last one of course only if installed.
```sh
root@cloudserver:~# systemctl stop seahub
root@cloudserver:~# systemctl stop seafile
root@cloudserver:~# systemctl stop mysql
root@cloudserver:~# systemctl stop nginx
```

Create a temporary directory to save the current installation and configuration:
```sh
root@cloudserver:~# mkdir -p /srv/SavedBeforeRestore/{etc,opt,var/log}
```

Move the current installation and configuration to the save area. Omit the parts which are not installed:
```sh
root@cloudserver:~# mv /etc/systemd/system/seafile.service /srv/SavedBeforeRestore/etc/
root@cloudserver:~# mv /etc/systemd/system/seahub.service /srv/SavedBeforeRestore/etc/
root@cloudserver:~# mv /var/lib/mysql /srv/SavedBeforeRestore/var/
root@cloudserver:~# mv /opt/Seafile/Server /srv/SavedBeforeRestore/opt/
root@cloudserver:~# mv /etc/nginx /srv/SavedBeforeRestore/etc/
root@cloudserver:~# mv /etc/letsencrypt /srv/SavedBeforeRestore/etc/
root@cloudserver:~# mv /var/log/nginx /srv/SavedBeforeRestore/var/log/
root@cloudserver:~# mv /var/log/letsencrypt /srv/SavedBeforeRestore/var/log/
```

Restore a backup:
```sh
root@cloudserver:~# tar -C / -xzf /srv/Backup/SeafileInstall/SeafileInstall201707161242.tgz
```

Reboot the server and see if everything ist working as before. If it does not, you can recover your last installation from the files in `/srv/SavedBeforeRestore/`. If it works well you can remove the saved files:
```sh
root@cloudserver:~# rm -rf /srv/SavedBeforeRestore
```


## Backup Data
To have a Backup of the data in Seafile Server a little script will do this task.
### Download the backup script
Download the script [BackupSeafileData](https://raw.githubusercontent.com/DerDanilo/Seafile-Best-Practise/master/BackupSeafileData "BackupSeafileData") and save it in `/usr/local/sbin/`.

Make it executable:
```sh
root@cloudserver:~# chmod 764 /usr/local/sbin/BackupSeafileData
```

### How it works
The script dumps the Seafile database into a file in the Seafile Server data area `/srv/Seafile`. If requested the oldest backups will be deleted until a maximum number of backups is kept. This is configurable, the default is to keep everything and delete nothing. Then a tarball (gzipped tar file) will be created. The default location is `/srv/Backup/SeafileData/` and can be configured within the script. Finally the database dump will be removed. There is no need to stop any service, you can perform the backup on the fly.
### Parameters
Get it from the script itself:
```sh
root@cloudserver:~# BackupSeafileData --help
```

### Configuration
Edit the script and see what's in there to be configurable. You may set the database user and his password. If you don't do so, the script tries to get these values from the Seafile Server configuration.
```sh
MYSQL_USER=""
MYSQL_PASSWORD=""
```

The most interesting parameter might be:
```sh
KEEP_OLD=0
```

which disabled deletion of old backups completely. Change it to your needs, e.g. `KEEP_OLD=20` will keep 20 old backups (21 backups including the current) and removes all older ones. Keep in mind that you need plenty of space in the backup area to save o lot of backups. Watch out not to run out of disk space!
### Perform the backup
```sh
root@cloudserver:~# BackupSeafileData
```

### Test the result
See if it is there:
```sh
root@cloudserver:~# ls -l /srv/Backup/SeafileData
total 540
-rw-r--r-- 1 root root 550485 Jul 16 15:29 SeafileData201707161529.tgz
```

Verify its contents:
```sh
root@cloudserver:~# tar -tzf /srv/Backup/SeafileData/SeafileData201707161529.tgz | less
```

It should contain something like (important is `Seafile/seafile.sql`, the database backup):
```sh
Seafile/
Seafile/seahub-data/
Seafile/seahub-data/avatars/
Seafile/seahub-data/avatars/groups/
Seafile/seahub-data/avatars/groups/default.png
...
Seafile/seahub-data/avatars/default.png
Seafile/seafile-data/
Seafile/seafile-data/commits/
Seafile/seafile-data/library-template/
Seafile/seafile-data/library-template/seafile-tutorial.doc
Seafile/seafile-data/fs/
Seafile/seafile-data/storage/
...
Seafile/seafile-data/httptemp/
Seafile/seafile-data/tmpfiles/
Seafile/seafile.sql
```
### Verify it's working
Log via webbrowser into your Seafile Server. Modify something (upload a file, add a library or whatever).

Just do a restore of your backup and verify it is working afterwards and its state is reset to the time of the backup.

If you want to be really sure not to lose something you might copy the current data to a save location.

Stop the Seafile services, keep everything else running.
```sh
root@cloudserver:~# systemctl stop seahub
root@cloudserver:~# systemctl stop seafile
```

Move Seafile Data to a save location:
```sh
root@cloudserver:~# mv /srv/Seafile /srv/SavedBeforeRestore
```

Unpack the backup:
```sh
root@cloudserver:~# tar -C /srv -xzf /srv/Backup/SeafileData/SeafileData201707161529.tgz 
```

Verify the database backup contains reasonable data:
```sh
root@cloudserver:~# head /srv/Seafile/seafile.sql
-- MySQL dump 10.16  Distrib 10.1.23-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: 
-- ------------------------------------------------------
-- Server version	10.1.23-MariaDB-9+deb9u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
```

Restore the database (assume 'seafile' is the name of your database user):
```sh
root@cloudserver:~# mysql -u seafile -p < /srv/Seafile/seafile.sql
Enter password:
```

Remove the database backup:
```sh
root@cloudserver:~# rm /srv/Seafile/seafile.sql
```

Start Seafile Server
```sh
root@cloudserver:~# systemctl start seafile
root@cloudserver:~# systemctl start seahub
```

Log via webbrowser into your Seafile Server and verify it's how it should be.

Remove the saved Data:
```sh
root@cloudserver:~# rm -rf /srv/SavedBeforeRestore
```

### Restore a backup
Stop the services, remove current data, restore a backup, restore database backup, remove database backup and start services again:
```sh
root@cloudserver:~# systemctl stop seahub
root@cloudserver:~# systemctl stop seafile
root@cloudserver:~# rm -rf /srv/Seafile
root@cloudserver:~# tar -C /srv -xzf /srv/Backup/SeafileData/SeafileData201707161529.tgz 
root@cloudserver:~# mysql -u seafile -p < /srv/Seafile/seafile.sql
Enter password: 
root@cloudserver:~# rm /srv/Seafile/seafile.sql
root@cloudserver:~# systemctl start seafile
root@cloudserver:~# systemctl start seahub
```

### Speed it up
If your server is able to run multiple threads in parallel, i.e. it has more than one core available or Intel's Hyper-Threading Technology you might be interested in speeding up your backup jobs. Normally tarballs are generated using gzip, which utilizes only one core. `pigz` is a fully functional replacement for gzip which utilizes multiple processors and multiple cores. If 'pigz' is installed, the backup scripts will use it to speed up the creation of backups.

Optionally you might want to install pigz:
```sh
root@cloudserver:~# apt-get install pigz
```

### Create a cronjob for a daily data backup
Edit crontab for user root and add a line at the end:
```sh
root@cloudserver:~# crontab -u root -e
# Edit this file to introduce tasks to be run by cron.
...
# m h  dom mon dow   command
0 3 * * * /usr/local/sbin/BackupSeafileData
```

This will create a Seafile data backup every day at 3:00 am. Adjust it to your needs.

**Watch your disk space!**