+++
author = "Blagovest Petrov"
title = "Example of MySQL incremental backup with XtraBackup"
date = "2016-01-07"

tags = [
    "Backup",
    "SQL",
]
categories = [
    "System Administration",
    "DevOps",
    "Databases"
]
+++  

Percona's [XtraBackup](https://www.percona.com/doc/percona-xtrabackup/2.3/index.html) is really good solution for incremental backups if small or large MySQL/MariaDB databases. Mysqldump is really slow and is not downtimeless.
In our case, we need two week history of every day. Every Sunday the backup will be full and the rest of the days, backups will be incremental, based on Sunday's full backup. The backups will be placed in a folder named `current_week`. Every Sunday, the folder will be renamed to *last_week* and new, empty `current_week` will be created before the full backup.

The script: 

```bash

#!/bin/bash
##
#####################################################################################
# "THE BEER-WARE LICENSE" (Revision 42):
# <blagovest@petrovs.info> wrote this file.  As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.   Blagovest Petrov
#####################################################################################
##

DAY=$1
MYSQL_PASS=$2
MYSQL_USER="bkpuser"

BACKUPS_DIR=/var/mysql-backups
THIS_WEEK=$BACKUPS_DIR/this_week
LAST_WEEK=$BACKUPS_DIR/last_week

function do_full_backup() {

  if [ -d $LAST_WEEK ]; then
    rm -rf $LAST_WEEK
    mkdir $LAST_WEEK
  fi

  if [ -d $THIS_WEEK ]; then
    mv $THIS_WEEK/* $LAST_WEEK
    mkdir -p $THIS_WEEK/Sunday
  fi

  xtrabackup --backup --target-dir=$THIS_WEEK/Sunday \
  --datadir=/var/lib/mysql \
  --user=$MYSQL_USER --password=$MYSQL_PASS
}

function do_incremental_backup() {

  if [ -d $THIS_WEEK/$DAY ]; then
    rm -rf $THIS_WEEK/$DAY
    mkdir $THIS_WEEK/$DAY
  fi


  xtrabackup --backup --target-dir=$THIS_WEEK/$DAY \
  --incremental-basedir=$THIS_WEEK/Sunday \
  --datadir=/var/lib/mysql \
  --user=$MYSQL_USER --password=$MYSQL_PASS
}

case $1 in 
  Sunday)
    do_full_backup
    ;;
  *)
    do_incremental_backup
esac
```

It "wants" the day of the week as the first parameter, and the mysql password as a second parameter, like this:

```bash
./backup-mysql.sh Sunday 12345
./backup-mysql.sh Monday 12345
```

Put it in `/usr/local/bin/backup-mysql` for example and make it executable. Here is an example cron config, running every day at 2:00 AM:

```
0 2 * * 0 /usr/local/bin/backup-mysql Sunday 12345 >/dev/null 2>&1
0 2 * * 1 /usr/local/bin/backup-mysql Monday 12345 >/dev/null 2>&1
0 2 * * 2 /usr/local/bin/backup-mysql Tuesday 12345 >/dev/null 2>&1
0 2 * * 3 /usr/local/bin/backup-mysql Wednesday 12345 >/dev/null 2>&1
0 2 * * 4 /usr/local/bin/backup-mysql Thursday 12345 >/dev/null 2>&1
0 2 * * 5 /usr/local/bin/backup-mysql Friday 12345 >/dev/null 2>&1
0 2 * * 6 /usr/local/bin/backup-mysql Saturday 12345 >/dev/null 2>&1
```

