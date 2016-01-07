title: Example of MySQL incremental backup with XtraBackup
date: 2016-01-07 11:54:27
tags: MySQL MariaDB XtraBAckup Percona
---

Percona's [XtraBackup](https://www.percona.com/doc/percona-xtrabackup/2.3/index.html) is really good solution for incremental backups if small or large MySQL/MariaDB databases. Mysqldump is really slow and is not downtimeless.
In our case, we need two week history of every day. Every Sunday the backup will be full and the rest of the days, backups will be incremental, based on Sunday's full backup. The backups will be placed in a folder named *current_week*. Every Sunday, the folder will be renamed to *last_week* and new, empty *current_week* will be created before the full backup.

<!-- more -->

Here is the script: 

{% gist eniac111/b37297e83cd5fa99e59e %}

It "wants" the day of the week as the first parameter, and the mysql password as a second parameter, like this:

{% codeblock lang:bash %}
./backup-mysql.sh Sunday 12345
./backup-mysql.sh Monday 12345
{% endcodeblock %}

Put it in */usr/local/bin/backup-mysql* for example and make it executable. Here is an example cron config, running every day at 2:00 AM:

{% codeblock lang:bash %}
0 2 * * 0 /usr/local/bin/backup-mysql Sunday 12345 >/dev/null 2>&1
0 2 * * 1 /usr/local/bin/backup-mysql Monday 12345 >/dev/null 2>&1
0 2 * * 2 /usr/local/bin/backup-mysql Tuesday 12345 >/dev/null 2>&1
0 2 * * 3 /usr/local/bin/backup-mysql Wednesday 12345 >/dev/null 2>&1
0 2 * * 4 /usr/local/bin/backup-mysql Thursday 12345 >/dev/null 2>&1
0 2 * * 5 /usr/local/bin/backup-mysql Friday 12345 >/dev/null 2>&1
0 2 * * 6 /usr/local/bin/backup-mysql Saturday 12345 >/dev/null 2>&1
{% endcodeblock %}

