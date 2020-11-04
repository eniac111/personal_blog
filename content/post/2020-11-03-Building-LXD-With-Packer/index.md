---
title: "Building LXD images with Packer and Ansible"
author: "Blagovest Petrov"
date: 2020-11-03
tags:
  - "LXD"
  - "Packer"
  - "Automation"
categories:
  - "System Administration"
  - "DevOps"
---
Building from scratch machines with similar configuration is not very wise. Unless it's not often. Preparing at least LXD base images would be helpful. Small routine tasks like changing the default repositories, MOTD, adding ssh keys and base tools would take more than 5 minutes per machine. 5 new machines per week, that takes a lot. To be effective, system administrators should be lazy and rational.

Packer from Hashi corp is really good tool for building immutable infrastructure. It supports building of different images for the cloud, on-premise environments and desktop hypervisors simultaneously. 

LXD is a hypervisor for Linux containers and virtual machines (since version 4.0). The containers in LXD are stateful. This means that their files are persistent compared to Docker where storage mounts are necessary. Also, the  LXD containers are most likely full system virtualization. They run a full bootstrapped operating system userspace with the init system.
The key difference between LXD and LXC is that LXD is a hypervisor for LXC containers and KVM virtual machines. LXD is based on liblxc and contains REST api.

I won't cover the initial configuration of LXD in this post. Packer is written in GoLang and it's a single binary. It could be downloaded in arhive from the [official download page](https://www.packer.io/downloads). Alternatively, it can also be installed with [homebrew](https://formulae.brew.sh/formula-linux/packer). The binary could be put in `/usr/local/bin` or in another directory of the working machine which is in the PATH.

The Ansible provisioner is still not compatible with the LXD builder module. There is a known bug, it hangs on "collecting artifacts" ( [#PACKER-9034](https://github.com/hashicorp/packer/issues/9034) ). Ansible is not getting the correct IP of the container from Packer and it's stuck on trying to connect with SSH.

A workaround is using the `ansible-local` provisioner. The difference is that the Ansible runs locally inside the container. It must be installed in advance with the _shell_ provisioner. Now it's not necessary to copy the playbook inside the container with _file_ provisioner. _ansible-local_ provisioner does it automatically and creates a temporary directory.

Example Packer json (`lxd-ansible-local.json`):

```json
{
  "provisioners": [
    {
      "type": "shell",
      "inline": "[ \"$(ansible --version > /dev/null && echo ok)\" != 'ok' ] && apt update && apt -y install ansible || echo 'ansible already installed.'"
    },
    {
      "type": "ansible-local",
      "playbook_file": "./playbook/example-playbook.yml",
      "playbook_dir" : "./playbook"
    }
  ],


  "builders": [
    {
      "type": "lxd",
      "name": "acme-focal",
      "image": "ubuntu-daily:focal",
      "output_image": "acme_ubuntu-focal",
      "init_sleep": "10",
      "publish_properties": {
        "description": "Focal image by ACME corp."
      }
    }
  ]
}

```

Here we have the shell provisioner which is installing Ansible with bash one-liner.

`"playbook_file": "./playbook/example-playbook.yml"` - The exact name of the playbook file to be executed;

`"playbook_dir" : "./playbook"` - The playbook directory to be copied to the container. Have a look at the roles config in the playbook file below!;

`"name": "acme-focal"` - Name of the started temporary container and name of the task for logging;

`"image": "ubuntu-daily:focal"` - Our image is based on ubuntu-daily:focal ;

`"output_image": "acme_ubuntu-focal"` - The name of our new image;

`"init_sleep": "10"` - Seconds to sleep between launching the container and provisioning it. My DNS is slow. That's why the value is high.

Example playbook (`./playbook/example-playbook.yml`):

```yaml
---

  - hosts: 127.0.0.1
    connection: local
    roles:
      - playbook/roles/acme-firstfive
```

There is nothing special here. Only the roles path is important. Packer is copying this file to the root working directory. That's why the exact path to the role must be specified, including the playbook dir. 

`connection: local` parameter is used with `127.0.0.1` for host.

### The whole file tree is published [here](https://code.petrovs.info/blago/packer-lxd-demo) as example project.

## Building

To build the project, simply run:

```bash
git clone https://code.petrovs.info/blago/packer-lxd-demo.git && cd packer-lxd-demo

packer build lxd-ansible-local.json
```
The temporary container is deleted immediately after deployment and only the image is published. To keep the container running for debugging in case of failure, use the option `-on-error=abort`:

```bash
packer build -on-error=abort lxd-ansible-local.json
```

Let's have a look at the demo:

