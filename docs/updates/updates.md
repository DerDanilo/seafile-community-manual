# Updates

[TOC]

---

## Update MUST READ

* Don't forget to stop Seafile Server before the upgrade
e.g.: `service seafile-server stop` or `service seahub stop && service seafile stop` or or `systemctl stop seahub seafile`
* Don't forget to apply the upgrade script/s according your start release with the properly user which in normal case should be `seafile` 
e.g. change to seafile user: `su seafile` or `sudo su seafile`
* Don't forget to change the directory rights of Seafile after unpacking it
e.g.: `chown -R seafile:nogroup ./seafile-server-6.2.1` or `sudo chown -R seafile:seafile ./seafile-server-6.2.1`
* After upgrading, you may need to clean [seahub cache](add_memcached.md) if it doesn't behave as expect.
* Please check the [upgrade notes](upgrade_notes.md) for any special configuration or changes before/while upgrading.


## Updating

### Download latest stable server version

### Stop seafile services
`service seafile-server stop` or `service seahub stop && service seafile stop` or or `systemctl stop seahub seafile`

### Untar seafile server package

### Apply update


#### Minor update

#### Major update


### Start services
`service seafile-server start` or `service seahub start && service seafile start` or or `systemctl start seafile && systemctl start seahub`

### Verify update

### Move old server package

`mv ./seafile-server-6.2.1 ./oldversions` and `mv ./seafile-server_6.2.1.tar.gz ./oldversions`


---

## Upgrade notes


--- 

## Major version upgrade (like from 4.x.x to 5.y.y)


Suppose you are using version 4.3.0 and like to upgrade to version 5.0.0. First download and extract the new version. You should have a directory layout similar to this:


```
haiwen
   -- seafile-server-4.3.0
   -- seafile-server-5.0.0
   -- ccnet
   -- seafile-data
```


Now upgrade to version 5.0.0.

1. Shutdown Seafile server if it's running

   ```sh
   cd haiwen/seafile-server-4.3.0
   ./seahub.sh stop
   ./seafile.sh stop
   # or via service
   /etc/init.d/seafile-server stop
   ```
2. Check the upgrade scripts in seafile-server-5.0.0 directory.

   ```sh
   cd haiwen/seafile-server-5.0.0
   ls upgrade/upgrade_*
   ```

   You will get a list of upgrade files:

   ```
   ...
   upgrade/upgrade_4.0_4.1.sh
   upgrade/upgrade_4.1_4.2.sh
   upgrade/upgrade_4.2_4.3.sh
   upgrade/upgrade_4.3_4.4.sh
   upgrade/upgrade_4.4_5.0.sh
   ```

3. Start from your current version, run the script(s one by one)

   ```
   upgrade/upgrade_4.3_4.4.sh
   upgrade/upgrade_4.4_5.0.sh
   ```

4. Start the new server version as for any upgrade

   ```sh
   cd haiwen/seafile-server-5.0.0/
   ./seafile.sh start
   ./seahub.sh start # or "./seahub.sh start-fastcgi" if you're using fastcgi
   # or via service
   /etc/init.d/seafile-server start
   ```
5. If the new version works fine, the old version can be removed

   ```sh
   rm -rf seafile-server-4.3.0/
   ```
   or alternatively be moved to the directory installed (in case you set it up)
   
    ```sh
   mv seafile-server-4.3.0/ installed/
   ```

## Minor version upgrade (like from 5.0.x to 5.1.y)

Suppose you are using version 5.0.0 and like to upgrade to version 5.1.0. First download and extract the new version. You should have a directory layout similar to this:


```
haiwen
   -- seafile-server-5.0.0
   -- seafile-server-5.1.0
   -- ccnet
   -- seafile-data
```


Now upgrade to version 5.1.0.

1. Shutdown Seafile server if it's running

   ```sh
   cd haiwen/seafile-server-5.0.0
   ./seahub.sh stop
   ./seafile.sh stop
   # or via service
   /etc/init.d/seafile-server stop
   ```
2. Check the upgrade scripts in seafile-server-5.1.0 directory.

   ```sh
   cd haiwen/seafile-server-5.1.0
   ls upgrade/upgrade_*
   ```

   You will get a list of upgrade files:

   ```
   ...
   upgrade/upgrade_4.0_4.1.sh
   upgrade/upgrade_4.1_4.2.sh
   upgrade/upgrade_4.2_4.3.sh
   upgrade/upgrade_4.3_4.4.sh
   upgrade/upgrade_4.4_5.0.sh
   upgrade/upgrade_5.0_5.1.sh
   ```

3. Start from your current version, run the script(s one by one)

   ```
   upgrade/upgrade_5.0_5.1.sh
   ```

4. Start the new server version as for any upgrade

   ```sh
   cd haiwen/seafile-server-5.1.0/
   ./seafile.sh start
   ./seahub.sh start # or "./seahub.sh start-fastcgi" if you're using fastcgi
   # or via service
   /etc/init.d/seafile-server start
   ```
5. If the new version works file, the old version can be removed

   ```sh
   rm -rf seafile-server-5.0.0/
   ```
   or alternatively be moved to the directory installed (in case you set it up)
   
    ```sh
   mv seafile-server-5.0.0/ installed/
   ```

## Maintenance version upgrade (like from 5.1.2 to 5.1.3)

Maintenance upgrade is like an upgrade from 5.1.2 to 5.1.3.


1. Stop the current server first as for any other upgrade
2. For this type of upgrade, you only need to update the symbolic links (for avatar and a few other folders). 
We provide a script for you, just run it (For history reason, the script called `minor-upgrade.sh`):

   ```sh
   cd seafile-server-5.1.2
   upgrade/minor-upgrade.sh
   ```

3. Start the new server version as for any other upgrade

4. If the new version works file, the old version can be removed

   ```sh
   rm -rf seafile-server-5.1.2/
   ```
   or alternatively be moved to the directory installed (in case you set it up)
   
    ```sh
   mv seafile-server-5.1.2/ installed/
   ```
