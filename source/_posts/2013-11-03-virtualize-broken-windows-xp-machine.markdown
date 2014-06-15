---
layout: post
title: "Virtualize a broken Windows XP machine with KVM or Xen, Part1"
date: 2013-11-03 09:48
comments: true
categories: KVM Windows Virtualization Recovery IT
---

There are still online many dirty legacy PCs which cannot be reinstalled. The most common problems are that they are installed with a special software and the CDs are lost or a license problems.

<!-- more -->

<a href="http://www.flickr.com/photos/j_aroche/2423244723/" title="Maquinas sucias by Javier Aroche, on Flickr"><img src="http://farm4.staticflickr.com/3217/2423244723_f0cff8ddf1.jpg" width="220" height="294" alt="Maquinas sucias" align="left"></a>

But what will happen when your zombie Durom 1300 dies? And your boss wants to use the accounting software ASAP.. The best scenario is when your HDD is healthy :)

First, you shoud find a cheap HDD -> USB converter. This is the clearest solution because I don't want to turn off my virtual hypervisors and probably, the old machine would have an IDE HDDs. Chinese combined IDE/SATA -> USB converters can be found for 15-16$.

<br/> <br/><br/> <br/>

<div style="text-align:center">
<img id="converter" src="http://img.dxcdn.com/productimages/sku_226847_1.jpg" style="border-width:0px;" width="200" height="300" />
<br />
This is the one I'm using..
</div>

##IMPORTANT!!! The old PC's are too dirty and their cases are sharp and dangerous! You should have a <a href="http://en.wikipedia.org/wiki/DPT_vaccine" target="_BLANK">DPT vaccine</a> and suitable protective clothing!!!

The HDD must be put on a PC with a hardware acceleration and KVM installed. In my case, my personal laptop was the salvation. I prepared a dummy VM with virt-manager, just to generate the XML file for libvirt. Use the simplest configuration. WinXP runs on an old hardware... Here are some steps in images:

<div style="text-align:center">
<img id="Virt-Manager-1" src="{{ root_url }}/images/WinXPVirtRecovery/1.png" style="border-width:0px;" />
<br />
...
</div>

<br/>

<div style="text-align:center">
<img id="Virt-Manager-4" src="{{ root_url }}/images/WinXPVirtRecovery/4.png" style="border-width:0px;" />
<br />
Just one CPU with 1024Mb Ram is OK
</div>

<br/>

<div style="text-align:center">
<img id="Virt-Manager-2" src="{{ root_url }}/images/WinXPVirtRecovery/2.png" style="border-width:0px;" />
<br />
It's not necessary to have WinXP iso. Use something just to generate the XML for LibVirt.
</div>

<br/>

<div style="text-align:center">
<img id="Virt-Manager-3" src="{{ root_url }}/images/WinXPVirtRecovery/3.png" style="border-width:0px;" />
<br />
The disk is also not revelant. It will be removed after the configuration.
</div>

<br/>

<div style="text-align:center">
<img id="Virt-Manager-5" src="{{ root_url }}/images/WinXPVirtRecovery/5.png" style="border-width:0px;" />
<br />
Better use i686
</div>

<br/>

<div style="text-align:center">
<img id="Virt-Manager-5" src="{{ root_url }}/images/WinXPVirtRecovery/5.png" style="border-width:0px;" />
<br />
Force off the machine after this window and open the terminal.
</div>


In the terminal, type **$virsh dumpxml WinXp > WinXp.xml** . Open the generated text file with your text editor and find this stanzas:

{% codeblock lang:xml WinXp.xml Before.. %}
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/home/vms/WinXP.img'/>
      <target dev='hda' bus='ide'/>
      <alias name='ide0-0-0'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/home/vms/xp64.iso'/>
      <target dev='hdc' bus='ide'/>
      <readonly/>
      <alias name='ide0-1-0'/>
      <address type='drive' controller='0' bus='1' target='0' unit='0'/>
    </disk>
{% endcodeblock %}

Remove the whole stanza about the CD Rom and change the disk configuration like this:

{% codeblock lang:xml WinXp.xml After.. %}
    <disk type='block' device='disk'>
      <driver name='qemu' type='raw'/>
      <source dev='/dev/sdX'/>
      <target dev='hda' bus='ide'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
{% endcodeblock %}

**/dev/sdX** must be your hard drive, connected with the chinese gadget. Make sure it's not mounted on the host system. Now your XP machine should run directly from the hard drive.

###Converting the hard drive to a virtual image..
