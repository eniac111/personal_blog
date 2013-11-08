---
layout: post
title: "Virtualize a broken Windows XP machine with KVM or Xen, Part2"
date: 2013-11-08 12:39
comments: true
categories: KVM Windows Virtualization Recovery
---

It's time to convert the physical disk to a virtual image. I'm using KVM almost everywhere, so, this tutorial will be about KVM. You can use the images in Xen/VMWare almost the same way.

<!-- more -->

First, install the VirtIO drivers for a better performance. The Fedora team builds isos with binary executables. Check the <a href="http://www.linux-kvm.org/page/WindowsGuestDrivers/Download_Drivers" target="_BLANK">KVM documentation for the newest info.</a>

First, attache a new VirtIO disk image to the machine. You can use the previously generated image in the installation from Part 1 or create a new one. The size is not important. It's needed just to recognize the new storage format in Windows.

<div style="text-align:center">
<img id="7" src="{{ root_url }}/images/WinXPVirtRecovery/7.png" style="border-width:0px;" />
</div>
<br />
<div style="text-align:center">
<img id="8" src="{{ root_url }}/images/WinXPVirtRecovery/8.png" style="border-width:0px;" />
</div>
<br />
<div style="text-align:center">
<img id="9" src="{{ root_url }}/images/WinXPVirtRecovery/9.png" style="border-width:0px;" />
</div>
<br />
<div style="text-align:center">
<img id="10" src="{{ root_url }}/images/WinXPVirtRecovery/10.png" style="border-width:0px;" />
</div>

When it's installed, you can deattach and delete the temporary VirtIO disk.

And now, the converting. I use mostly three tools for this thing:

* <a href="http://www.vmware.com/products/converter/" target="_BLANK">VMWare vCenter Converter</a> which is a free tool by VmWare
* CloneZilla - Open Source Linuxdistribution for creating disk images
* Byte copy with dd. I don' recommend it because will copy all of the sectors of the disk, even the "empty" ones. The dd way is OK when you will use LVM for a storage format.

I will show you how to convert it with the VmWare tool because It's the easiest way, I think.

You need a free space somewhere to put the converted image from the tool. It's possible to mount a directory from the server, to mount a Samba share or if the physical disk is healthy and there's enough free space, you can put the image right in C:\.

<div style="text-align:center">
<img id="11" src="{{ root_url }}/images/WinXPVirtRecovery/11.png" style="border-width:0px;" />
<br/>
Click on "Convert machine"
</div>
<div style="text-align:center">
<img id="12" src="{{ root_url }}/images/WinXPVirtRecovery/12.png" style="border-width:0px;" />
<br/>
This local machine
</div>
<img id="13" src="{{ root_url }}/images/WinXPVirtRecovery/13.png" style="border-width:0px;" />
<br/>
VmWare Workstation or other VmWare virtual machine; choose a directory
</div>
<img id="14" src="{{ root_url }}/images/WinXPVirtRecovery/14.png" style="border-width:0px;" />
<br/>
Summary..
</div>
<img id="14" src="{{ root_url }}/images/WinXPVirtRecovery/14.png" style="border-width:0px;" />
<br/>
And the job is running
</div>

When it finnish, you will have a directory with the VMDK image in it. KVM supports VMDK, but it's better to convert it to QCOWp2 with:

{% codeblock lang:bash %}
$ kvm-img convert -O qcow2 WinXP.vmdk WinXP.qcow2
{% endcodeblock %}

Just put the QCOW2 image in KVM and your XP is virtual :) 