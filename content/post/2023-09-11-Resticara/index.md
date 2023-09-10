---
title: "Resticara - a wrapper of Restic"
author: "Blagovest Petrov"
date: 2023-09-11T00:54:19+02:00
tags:
  - "Backup"
  - "Projects"
categories:
  - "DevOps"
draft: false
---

![Resticara](https://repository-images.githubusercontent.com/683147638/770302ee-0cd8-4394-a039-7250d003a0a0)

Hey folks, hope you're all doing well! If you've ever had to deal with backups, you know it can be a chore. Enter Restic — an excellent command-line tool for backups. But wouldn't it be nice to skip the bash scripting for simple projects? That's exactly why I decided to build Resticara over a weekend. I was working with a client and realized that both of us needed a more streamlined way to use Restic.

# [[>>GitHub page<<](https://github.com/VuteTech/Resticara)


## What is Resticara?

Simply put, Resticara is a wrappera around [Restic](https://restic.readthedocs.io/en/stable/020_installation.html) .  If you're not yet acquainted with Restic, I highly recommend checking it out. But even though Restic is powerful, it can be cumbersome to use at times. That's where Resticara steps in. It provides an easy-to-use interface for Restic, aiming to make your backup process more straightforward.

Currently, it supports backup of directories and MySQL/MariaDB databases. PostgreSQL support is on the TODO and pull requests with more functionality will be highly appreciated!

## Simplicity

The configuration is made in a single INI file, no complex scripting involved. This is an example config:

```ini
[general]
; if hostID=hostname, the actual hostname of the machine will be shown
hostID=hostname

[smtp]
enabled = false
;from = "user@example.com"
;username = "user@example.com"
;pass = "#################3"
;to = "admin@example.com"
;server = "mail.example.com"
;port = "587"

[dir:website]
bucket = s3:s3.amazonaws.com/mysitebackup204:wpsites/
directory = /var/www
retention_daily = 4
retention_weekly = 7
retention_monthly = 3

[mysql:maindb]
bucket = b2:bucket:mariadb/
database = --all-databases
retention_daily = 4
retention_weekly = 7
retention_monthly = 3
```
As the saying goes, a good system administrator should be lazy—in a smart way, of course! The idea is to reduce repetitive tasks to a minimum for maximum effectiveness. And what could be lazier, in the best sense of the word, than putting all your backup configurations in a single, straightforward INI file? No intricate scripts, no lengthy commands—just pure, unadulterated simplicity. It's also easier for automating with tools like Ansible!

## Reporting
As you see, Resticara already supports integrated reports through SMTP and it's pushing the logs to Syslog.

# Example usage with SystemD timers

First, install [Restic](https://restic.readthedocs.io) independently. Here is the official documentation: https://restic.readthedocs.io/en/stable/020_installation.html
<br/>
Then, install Resticara from an RPM or a DEB package or extract it from a ZIP.  It can be downloaded from the [GitHub Releases page](https://github.com/VuteTech/Resticara/releases)

<br/>
Once the two packages are both installed. initialize the repositories with `restic init`. This functionality is not included inside Resticara. You might need some secrets given as ENV variables, depending on the cloud provider. For MySQL/MariaDB backups, the user which is running Resticara will also need credentials to the database. They must be set in the ~/.my.cnf file.

<br/>
When the repositories are initialized, configure them in `/etc/resticara/config.ini`, as it is described in the file.

<br/>

## SystemD setup

Create a service file config but don't enable it, it's not a daemon. The service will be triggered by the SystemD timer: 
`/etc/systemd/system/resticara.service`:

```
[Unit]
Description=Run Resticara

[Service]
Environment="B2_ACCOUNT_ID=MyB2Account"
Environment="B2_ACCOUNT_KEY=010101"
Environment="RESTIC_PASSWORD=u4U0ECIjqJxD56g9Ra63XuYgHnwjYvVMbw7nEAR4zWX5dvZHnUvkeXXbVbcC"
ExecStart=/usr/local/bin/resticara run
```

The required secrets will be stored in the service (RESTOC_PASSWORD is the key for encrypting the Restic repositoies). This might be not the best practice but it works for me for now.
<br />

Create the timer configuration `/etc/systemd/system/resticara.timer`:

```
[Unit]
Description=Run Resticara twice daily

[Timer]
OnCalendar=*-*-* 12,18:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

The current config will run the backup twice a day - at 12:00PM and 6:00PM. Also, you will need to enable the timer (Only the timer, not the service!):

```bash
systemctl enable resticara.timer
```

This is everyting for now. Any contributions welcome!