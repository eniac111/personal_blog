---
title: "Running Wine apps in multi user environment"
author: "Blagovest Petrov"
date: 2020-10-11T16:31:34+03:00
draft: false
tags:
  - "Desktop"
  - "Wine"
categories:
  - "System Administration"
---

![wine](img/wine.gif) For the project I mentioned in the [last post](https://petrovs.info/post/2020-10-08-revival-of_the-bulgarian-villages/) 
there was a requirement for running some Windows games on the computers. Despite the challenge to maintain 20 years old Windows software in Linux,
the main challenge was to make it working in multi user environment with LDAP. 

[Wine](https://winehq.org) is a per-user app. Every user has their own Wine prefix with the apps directory and the emulated Windows root drive.

There were some solutions from internet but none was working and convenient for the case.

First I tried with the [Winepak](https://www.winepak.org/) project but it wasn't working. The project seems to be unmaintained on this date. They were providing libraries for "Flatpak-ing" Wine applications.

Other users tried with separate user for Wine and sudo-ing but it's also doesn't look stable enough for remote setup in different villages across the country.

Skel is a simple and working variant but the Wine directory is several gigabytes. If the library contains more than 30 users, the local disk wouldbe filled with skel copies of the Wine directory. It will also delay the first login with minutes. Symlinks won't work because the applications are using files and the Wine directory should have `Write` access.


## The variant that came to my mind was mounting the Wine directory with OverlayFS.

OverlayFS is a union mount file system which is a part of the Linux kernel since Linux 3.18. It combines upper and lower directory trees with files and subdirectories into one that combines their contents. It's used in Live CDs and mostly in Docker for the layering functionality of the images.

The upper and lower directory trees can be from different filesystems. In a case of a file that contains the same name in the lower overlay directories, it's version from the lower directory is hidden. In case of directories with the same name, their contents are merged.

The lower directory could be read only which is our case. It can also be overlay mount itself as in Docker layers and other container engines.

The file changes are commited to the upper directory and it should be writable in the case.

Work directory is required for temporary storing the files on atomic file operations. It must be on the same file system as the work directory.

Here is an example of using it:

[![asciicast](https://asciinema.org/a/HMynwKfkUcGmMQErXzwLIWiW8.svg)](https://asciinema.org/a/HMynwKfkUcGmMQErXzwLIWiW8)


In the current case, the `upper` and `workdir` will be created by Skel in the home directories of the users and the lower dir will be in `/opt`:

```bash
/opt/winedir # Lower
/home/$USER/.wine-upper
/home/$USER/.wine-workdir #The workdir must be empty directory!
```


Pam-mount module will mount the overlayfs when the user logs-in. It's not installed by default. For Debian/Ubuntu: 

```bash
apt-get install libpam-mount
```

pam-mount's configuration is in `/etc/security/pam_mount.conf.xml`. The code must be put after `<!-- Volume definitions -->`:

```xml
          <volume
            fstype="overlay"
            path="/home/%(USER)/.wine"
            mountpoint="~/.wine"
            options="lowerdir=/opt/winedir,upperdir=/home/%(USER)/.wine-upper,workdir=/opt/workdir"
            />
```

In this way, the `~/.wine` directory will be unique and it will contain only the file deltas.

Pam interactive login must also be disabled. Otherwise it will ask twice for password at login. It's used for mounting SSH, CIFS and other file systems with pam-mount. in `/etc/pam.d/common-auth` append `disable_interactive :

```csv
# and here are more per-package modules (the "Additional" block)
auth    optional        pam_mount.so  disable_interactive
```

The Ansible role for project "Za Selata" is [here](https://gitlab.com/zaselata/computer-cabinets/zsl-win-games/-/tree/master). It can be used for a reference.