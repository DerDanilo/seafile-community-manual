#!/bin/bash
# BackupSeafileInstall
# Backup Seafile Server and related configurations
VERSION="20170715"

# Set backup location and filename
BACKUP_DIR="/srv/Backup/SeafileInstall"
BACKUP_NAME="SeafileInstall`date '+%Y%m%d%H%M'`.tgz"

# Set what to backup (some are determined dynamically: only if installed)
BACKUP_FILES="etc/systemd/system/seafile.service etc/systemd/system/seahub.service var/lib/mysql opt/Seafile/Server"
[ -d /var/log/nginx ] && BACKUP_FILES="var/log/nginx $BACKUP_FILES"
[ -d /etc/nginx ] && BACKUP_FILES="etc/nginx $BACKUP_FILES"
[ -d /var/log/letsencrypt ] && BACKUP_FILES="var/log/letsencrypt $BACKUP_FILES"

# Services to stop before backup
SERVICES="mariadb seafile seahub nginx"

Version () {
# give version information if requested
  echo "${0##*/} Version $VERSION"
}

if [ "$1" = "-V" -o "$1" = "--version" ]; then
  Version
  exit 0
fi

Usage() {
# give some usage information
cat <<EOF
Usage: ${0##*/}
 
Creates a Backup of
  Installation:             Seafile Server
  Configurations and Logs:  Seafile Server, Nginx, Let's Encrypt

Backups go to:              $BACKUP_DIR
EOF
}

if [ "$1" = "-h" -o "$1" = "--help" ]; then
  Usage
  exit 0
fi

if [ "$1" != "" ]; then
  echo "Error: unknown option $1"
  echo
  Usage
  exit 1
fi

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Stop services and keep info to start them after backup
ACTIVE=""
for S in $SERVICES; do
  if [ "`systemctl is-active $S`" = "active" ]; then
    ACTIVE="$ACTIVE $S"
    systemctl stop $S
  fi
done

# use pigz instead of gzip if installed
I="-z"
[ -x /usr/bin/pigz ] && I="-I pigz"

# do the backup
tar -C / -cf "$BACKUP_DIR/$BACKUP_NAME" $I --warning='no-file-ignored' $BACKUP_FILES

# tell user if backup failed
RC=$?
if [ $RC -ne 0 ]; then
  echo "tar exited with error code $RC"
fi

# start services if they were active befor backup
for S in $ACTIVE; do
  systemctl start $S
done

# return result of tar
exit $RC
