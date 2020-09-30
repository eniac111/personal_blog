 +++
author = "Blagovest Petrov"
title = "Using Ansible with pass"
date = "2016-01-03"

tags = [
    "Automation",
    "Ansible",
    "Configuration"
]
categories = [
    "System Administration",
    "DevOps"
]
+++  

To work with the root user and ssh keys is a common practice in the Ansible community. Another variant is to use a "deploy" user with the same password on every machine.
Another option is to use [Ansible Vault to encrypt the yaml files](https://therealmarv.com/ansible-vault-file-handling). or to use a password manager. It's never a good idea to keep passwords, private keys and other sensual data to the source code repository.


## Pass

I use [Pass](http://www.passwordstore.org/) for all of my personal or company passwords for almost an year. It's like a Keepass but simpler. The project follows the UNIX philosophy "Do One Thing and Do It Well".
Pass stores every password in a PGP encrypted file in a directory tree. It has also Git integration and Bash/Zsh completion. Really cool! Check the project page or the Man for additional documentation. There was a lighting talk from the 32c3 congress this year. I'll append it when it appears online. 

## Reading sudo passwords from Pass with Ansible

It's really simple. Just use "Lookup" with pipe inside your host_vars/examplehost file, like this:

```yaml
ansible_sudo_pass: "{ { lookup('pipe', 'pass show Inventoryname/hosts/examplehost/myusername') }}"
```

And append `sudo: yes` to every command in the tasks, like this:

```
- name: Just a test task
  copy: src=/etc/passwd dest=/tmp/passwdfile
  sudo: yes
```

You should also use gpg-agent. Otherwise, Ansible will ask for the gpg key password for each operation.