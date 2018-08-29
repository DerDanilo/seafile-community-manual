## Backup using Rsync

### Introduction to rsync

> Rsync is a fast and extraordinarily versatile file copying tool. It can copy
> locally, to/from another host over any remote shell, or to/from a remote
> rsync daemon. It offers a large number of options that control every aspect
> of its behavior and permit very flexible specification of the set of files
> to be copied. It is famous for its delta-transfer algorithm, which reduces
> the amount of data sent over the network by sending only the differences
> between the source files and the existing files in the destination. Rsync is
> widely used for backups and mirroring and as an improved copy command for
> everyday use.

Rsync's main advantage over other backup/copying methods is it's
delta-transfer algorithm. It ensures that only the modified parts of certain
files are copied, thus reducing bandwidth use and the time required to
complete the transfer operation.

### Preparation

For the purpose of this guide, we will assume that you intend to copy the
remote contents of the `seafile_data` folder to a local drive, as well as the
database dump.

The remote `seafile_data` directory will be located at
`/srv/seafile/haiwen/seafile-data` . The local drive will be mounted
at `/run/media/foo/seafbackup/`.

We will copy the database dumps from the server to our local directory
`/run/media/foo/seafbackup/seafile_databases` using a tool of your choosing,
for example SFTP. The remote `seafile_data` folder will be copied to
`/run/media/foo/seafbackup/seafile_data_backup/` using rsync.

Before you begin the next steps, Install the `rsync` package via your
distribution's package manager.

### Backup steps

#### 1. Stop Seafile and Seahub

As a systemd service:

```bash
systemctl stop seafile && systemctl stop seahub
```

Or using only the script:
```bash
./seahub.sh stop && ./seafile.sh stop
```

#### 2. Backup the databases

SSH into the seafile/database host and backup the databases. You will be asked
for the MySQL root password:

```bash
mysqldump -u root -p --opt ccnet-db > ccnet-db.sql.`date +"%Y-%m-%d-%H-%M-%S"` &&
mysqldump -u root -p --opt seafile-db > seafile-db.sql.`date +"%Y-%m-%d-%H-%M-%S"` &&
mysqldump -u root -p --opt seahub-db > seahub-db.sql.`date +"%Y-%m-%d-%H-%M-%S"`

```
Use SFTP to copy them over to a location of your choosing, for example
to `/run/media/foo/seafbackup/seafile_databases/` on our local drive.

#### 3. Seafile GC

In order to avoid backing up deleted libraries or data, we shall run seafile
garbage collection first.

We can do a dry run first, without actually deleting any data. Depending on
your configuration, running it as the `seafile user` might be preferable:

```bash
runuser -l seafile -c 'cd /srv/seafile/haiwen/seafile-server-latest && ./seaf-gc.sh --dry-run
```

To run the real garbage collection, remove the `--dry-run` parameter.

```bash
runuser -l seafile -c 'cd /srv/seafile/haiwen/seafile-server-latest && ./seaf-gc.sh
```

#### 4. Rsync data backup

It's time to start the actual data synchronization. Go to the directory where
you would like the data to be copied to. Create the directory if it doesn't
exist.

```bash
mkdir /run/media/foo/seafbackup/seafile_data_backup/
cd /run/media/foo/seafbackup/seafile_data_backup/
```
The contents of the remote `seafile_data` folder will be synced here.

If you are using a private key to connect to the server over SSH or if you're
using a non-standard port, define the following variables:

```bash
ssh_key='/your/private/key/location/id_rsa'
remote_port='xxxx'
```
Replace the strings with your port/private key location.

Now, replace the user/server domain and issue the rsync command for a dry run
(nothing will be copied yet):

```bash
rsync -avzP --dry-run --delete --human-readable --stats -e  "ssh -p $remote_port -i $ssh_key" root@example.com:/srv/seafile/haiwen/seafile-data/ ./
```

NOTE: Preserving the `.../seafile-data/` trailing slash means that we wish to
copy only the directory contents, not the directory itself.

The arguments are as follows:

```
 -a, --archive      archive mode (preserves permissions)
 -v, --verbose      increase verbosity
 -z, --compress     compress file data during the transfer
 -P                 show progress
 -n, --dry-run      doesn't make any changes
 --delete           delete extraneous local files
 --human-readable    output in a human-readable format
 --stats             give some file-transfer stats
 -e                  alternative remote shell
```

The output should look something like this:
```
Number of files: 89,298 (reg: 80,773, dir: 8,525)
Number of created files: 4,803 (reg: 4,345, dir: 458)
Number of deleted files: 0
Number of regular files transferred: 4,349
Total file size: 86.94G bytes
Total transferred file size: 23.91G bytes
Literal data: 0 bytes
Matched data: 0 bytes
File list size: 1.66M
File list generation time: 0.001 seconds
File list transfer time: 0.000 seconds
Total bytes sent: 26.16K
Total bytes received: 4.57M

sent 26.16K bytes  received 4.57M bytes  612.17K bytes/sec
total size is 86.94G  speedup is 18,934.93 (DRY RUN)
```
The `Total file size: 86.94G bytes` and
`Total transferred file size: 23.91G bytes` are interesting to look at. The
first tells us that the remote directory is 86.96 GB in size, but the second
tell us that only 23.91 GB will be copied to our local drive. Herein lies the
advantage of rsync: because in our example the files were already synchronized
beforehand, this new sync will only pull the modified data, not all of it. If
you run the sync for the first time, however, you will have to download all
the files with their full size.

When you're ready to begin synching, issues the above command without the
--dry-run parameter.

```bash
rsync -avzP --delete --human-readable --stats -e  "ssh -p $remote_port -i $ssh_key" root@example.com:/srv/seafile/haiwen/seafile-data/ ./
```

### Conclusion

If everything went according to plan, we have retrieved a copy of the
`seafile`, `seahub` and `ccnet` databases and placed them in
`/run/media/foo/seafbackup/seafile_databases` .

The contents of the `seafile_data` folder are now synchronized to
`/run/media/foo/seafbackup/seafile_databases/` .

Recovering from a data loss will just be a matter of restoring the databases
and the data directory.

As the sync will only pull the modified files from the remote host, the more
often backups are run, the less data will need to be copied. A possible
solution for automating the backup is using `CRON` to run a script with all
the above-mentioned commands.
