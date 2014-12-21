---
layout: post
title: "Quick utility for enterprise security"
date: 2014-12-21 16:35
comments: true
categories: [IT, Security, Cloud, Utilites]
---

{% img center http://petrovs.info/images/security_usability.png Schematic of the setup %}

Security and usability are almost never mutually inclusive concepts. Expecially in the cloud apps. They are really useful but the security is controversial. Highest security means no internet and even computers..

<!-- more -->

In our company, we use OwnCloud. It's an open source application for cloud file synchronization, like DropBox and Google Drive.
OwnCloud can be used with private SSL keys but it's still not secure because it's written on PHP. I make updates regularly but a security flaw may be undiscovered for weeks or even years ([Heartbleed](http://heartbleed.com/) and [Shellshock](http://en.wikipedia.org/wiki/Shellshock_%28software_bug%29) for example).
VPN is not a solution because it separates from the point in the middle when OwnCloud is used on a smartphone or tablet.
I wrote a small application for usage inside our company. It generates an unique string from the filename and the metadata of the office documents.

{% img center http://petrovs.info/images/nebopassgen.png Schematic of the setup %}

The string can be set for a password of the document. This is not a strong security solution, but a small accurance. It's a matter of CPU time for the password to be cracked. But it's even closer to the point in the middle because nobody have to remember the passwords. Maybe it would be good if it uses Kde's Wallet, Gnome Keyring or something other in Windows, but it's still under consideration.

It's sad but I cannot make it Open Source :D