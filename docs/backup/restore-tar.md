### Restore a backup
Stop the services. The last one of course only if installed.
```sh
root@cloudserver:~# systemctl stop seahub
root@cloudserver:~# systemctl stop seafile
root@cloudserver:~# systemctl stop mysql
root@cloudserver:~# systemctl stop nginx
```

Remove the current stuff you want to get rid of. Be sure to save anything you want to keep from the current installation like letsencrypt logfiles a.s.o.
```sh
root@cloudserver:~# rm -rf /etc/systemd/system/{seafile,seahub}.service /etc/nginx /etc/letsencrypt /opt/Seafile/Server /var/lib/mysql /var/log/letsencrypt /var/log/nginx
```

Restore a backup:
```sh
root@cloudserver:~# tar -C / -xzf /srv/Backup/SeafileInstall/SeafileInstall201707161242.tgz
```

Reboot the server.
