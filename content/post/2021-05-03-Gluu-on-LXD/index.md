---
title: "Gluu on LXD"
author: "Blagovest Petrov"
date: 2021-06-03T17:43:51+03:00
tags:
  - "LXD"
categories:
  - "System Administration"
  - "DevOps"
draft: false
---

If you are experiencing errors when installing [Gluu](https://gluu.org/), the Open Source digital identity server in LXD, this is because Gluu works in a chrooted environment by default. Errors like these should appear on systems with deb or RPM packages installed: 

```log
Jun 03 14:05:10 gluu systemd[1]: Starting Container gluu-server...
Jun 03 14:05:10 gluu systemd-nspawn[1546]: Failed to mount n/a (type n/a) on /opt/gluu-server (MS_REC|MS_SHARED ""): Permission denied
Jun 03 14:05:10 gluu systemd[1]: systemd-nspawn@gluu-server.service: Main process exited, code=exited, status=1/FAILURE
Jun 03 14:05:10 gluu systemd[1]: systemd-nspawn@gluu-server.service: Failed with result 'exit-code'.
Jun 03 14:05:10 gluu systemd[1]: Failed to start Container gluu-server.
Jun 03 14:05:12 gluu dbus-daemon[94]: [system] Reloaded configuration
```

To resolve the problem, the container must be privileged and nesting must be enabled. The same profile settings are required for Docker and nested LXD containers: 

```json
  security.nesting: "true"
  security.privileged: "true"
```

It's a Java application. In some cases, it may also require tunning of the kernel ulimits!
Here is the documentation from from LXD: https://lxd.readthedocs.io/en/latest/production-setup/

