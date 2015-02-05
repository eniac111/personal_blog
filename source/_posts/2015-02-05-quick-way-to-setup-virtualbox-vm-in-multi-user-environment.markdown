---
layout: post
title: "Quick way to setup VirtualBox VM in multi user environment"
date: 2015-01-14 12:07
comments: true
categories: [IT, Virtualization, Ubuntu, Tools, VirtualBox]
---

Let's assume that we need to setup VirtualBox VM with Windows XP and an old version of Microsoft Office. The machine must be used from everyone on a given number of Linux workstations. The workstations may work with LDAP and NFS/Cifs. The standard installation of the VM would be extremely space consuming and it would cost a lot of the personal life of the administrator.
I made an easy hack to solve this ( this is real setup in university labs).

<!-- more -->
Let's install a standard local Windows XP virtual machine and permanently mount the local directories */home/trendafil* and */media* .
In this example, the home directory of the user will be mounted on *X:\\* on Windows and media will be *Z:\\* .

The important directories are out of the VM. So, the virtual machine will be runned from snapshot on every boot.
The next useful step is to move the default user profile outside the VM. I don't need something different than *My Documents* but in other cases, everything from the profile can be exported to */home*, outside the VM. So, open *"regedit"* in Windows and go to the

{% codeblock %}
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell User Folders
{% endcodeblock %}

and change the key *"My Documents"* to *X:\\*

<img src="{{ root_url }}/images/winxpsnap/regedit.png" alt="Regedit" />

Turn off the VM and create an empty snapshot

<img src="{{ root_url }}/images/winxpsnap/snapshot.png" alt="Creating the snapshot" />

Next, move the VM from *~/VirtualBox VMs* to *~/.config/VirtualBox* if it's the official VirtualBox edition or *~/.VirtualBox* for the open source edition from the Ubuntu repositories. 

Open the file *~/.config/VirtualBox/VirtualBox.xml* and clean it from the needless stuff: 

{% codeblock %}
<ExtraDataItem name="GUI/RecentFolderHD"......;
<ExtraDataItem name="GUI/RecentListHD" ....... and etc..
{% endcodeblock%}

Change the location of the VM and replace your username with "_CURRENTUSR_" everywhere inside the file, like this:

{% codeblock lang:xml %}

 <MachineRegistry>
      <MachineEntry uuid="{64245cfc-36c6-4112-9869-d5b9da817fca}" src="/home/_CURRENTUSR_/.VirtualBox/WinXP/WinXP.vbox"/>
    </MachineRegistry>

...

    <SystemProperties defaultMachineFolder="/home/_CURRENTUSR_/VirtualBox VMs" defaultHardDiskFormat="VDI" VRDEAuthLibrary="VBoxAuth" webServiceAuthLibrary="VBoxAuth" LogHistoryCount="3" exclusiveHwVirt="true"/>
{% endcodeblock %}

Also, replace the username the same way in *"~/.VirtualBox/WinXP/WinXP.xml"*

Change the location of the harddisk image to */var/vbox/* like this: 

{% codeblock lang:xml %}
        <HardDisk uuid="{c052dc96-569b-4873-a799-2a75497404db}" location="/var/vbox/winxp.vmdk" format="VMDK" type="Normal">
{% endcodeblock %}

Create the directory */var/vbox/* and then move the harddisk image from *~/.VirtualBox/WinXp/winxp.vmdk* to */var/vbox* .

Then, move the whole *~/.VirtualBox* or *~/.config/VirtualBox* to */var/vbox*

Install Zenity if it's not installed:

{% codeblock lang:bash %}
$ sudo apt-get install zenity
{% endcodeblock %}

Download this file and put it on /usr/local/bin/startwin: 

<script src="https://gist.github.com/eniac111/00fcc0afd16e57172fce.js"></script>

and make it executable: 

{% codeblock lang:bash %}
# chmod +x /usr/local/bin/startwin
{% endcodeblock %}

It should work now. Every user of the system can start the VM from the script. 

Additionaly, you can create a desktop enry.
First, find an ugly Window$ logo with an open license and put it on */usr/share/icons/win.png*. Then, create the file */usr/share/applications/startwin.desktop* with this content: 

{% codeblock %}

[Desktop Entry]
Encoding=UTF-8
Version=1.0
Name=Windows XP
GenericName=Windows XP
Type=Application
Exec=/usr/lcal/bin/startwin
TryExec=/usr/local/bin/startwin
Icon=/usr/share/icons/win.png
Categories=Emulator;System;Application;
Comment=WindowsXP VirtualBox WM

{% endcodeblock %}
