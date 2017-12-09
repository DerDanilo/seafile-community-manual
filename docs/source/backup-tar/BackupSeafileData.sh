#!/bin/bash
# BackupSeafileData
# Backup Seafile Server Data 
VERSION="20170715"

# Number of old Backups to keep e.g. KEEP_OLD=20. A value of 0 keeps them all.
KEEP_OLD=0

# Set backup location and filename
BACKUP_DIR="/srv/Backup/SeafileData"
BACKUP_NAME="SeafileData"
BACKUP_FILE="$BACKUP_DIR/$BACKUP_NAME`date '+%Y%m%d%H%M'`.tgz"

SEAFILE_INSTALL="/opt/Seafile/Server/"
SEAFILE_DATA="/srv/Seafile"

MYSQL_DUMP="$SEAFILE_DATA/seafile.sql"

MYSQL_USER=""
MYSQL_PASSWORD=""

Version () {
# give version information if requested
  echo "${0##*/} Version $VERSION"
}

Usage() {
# give some usage information
cat <<EOF
Usage: ${0##*/}

Creates a Backup of Seafile Server data. MySQL data is dumped to Seafile Server data directory ($MYSQL_DUMP) before backing up data. Therefore it's contained in the backup file.
Backups go to: $BACKUP_DIR
EOF
}

if [ "$1" = "-V" -o "$1" = "--version" ]; then
  Version
  exit 0
fi

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

# use pigz instead of gzip if installed
I="-z"
[ -x /usr/bin/pigz ] && I="-I pigz"

# if not set, get database user and password from Seafile config
if [ -z "$MYSQL_USER" ]; then
  MYSQL_USER="`sed '/^\[database\]/,/^\[/ !d' $SEAFILE_INSTALL/conf/seafile.conf | sed '/^user/ !d; s/.*= *//'`"
fi
if [ -z "$MYSQL_PASSWORD" ]; then
  MYSQL_PASSWORD="`sed '/^\[database\]/,/^\[/ !d' $SEAFILE_INSTALL/conf/seafile.conf | sed '/^password/ !d; s/.*= *//'`"
fi

# do the database backup
mysqldump --user=$MYSQL_USER --password=$MYSQL_PASSWORD --all-databases > $MYSQL_DUMP
RC=$?
if [ $RC -ne 0 ]; then
  echo "Backup failed. mysqldump exited with error code $RC"
  rm -f $MYSQL_DUMP
  exit $RC
fi

# create backup directory if not exists
mkdir -p $BACKUP_DIR

# Delete old Backups if requested
if [ $KEEP_OLD -ne 0 ]; then
  for OLD in `ls $BACKUP_DIR/$BACKUP_NAME* 2>/dev/null | head -n -$KEEP_OLD`; do
    rm $OLD
  done
fi

# do the backup
tar -C ${SEAFILE_DATA%/*} -cf "$BACKUP_FILE" $I ${SEAFILE_DATA##*/}

# tell user if backup failed
RC=$?
if [ $RC -ne 0 ]; then
  echo "Backup failed. tar exited with error code $RC"
fi

# remove database backup
rm -f $MYSQL_DUMP

# return result of tar
exit $RC
