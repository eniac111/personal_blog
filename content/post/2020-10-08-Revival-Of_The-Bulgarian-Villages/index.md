---
title: "Revival of the Bulgarian villages"
date: 2020-10-08T19:42:30+03:00
draft: false
---

![ZaSelata Logo](img/zsl-logo.png) Occasionally I'm giving technical support to foundation "Revival of the Bulgarian villages" (фондация [Възраждане на българските села](http://zaselata.org/)).
They are just a group of people with the noble mission to support the small places in our country with education and equipment. The children in these regions must have equal access to knowledge and technologies just like their peers from the big cities.

[Vasil Kendov](http://kendov.com/) is the founder of the idea and the main engine. More than a year ago a friend from Plovdiv (Ivan Dzheferov) mentioned to me about him and that they need some technical help. We drank a beer with Vasil and he told me the story about how everything started. The whole story is described in another interview. I'm not good enough in retelling stories, so it's in [actualno.com](https://www.actualno.com/umnomlado/digitalnoto-vyzrajdane-na-bylgarskite-sela-news_1458092.html) and [English translation](https://translate.google.bg/translate?sl=bg&tl=en&u=https%3A%2F%2Fwww.actualno.com%2Fumnomlado%2Fdigitalnoto-vyzrajdane-na-bylgarskite-sela-news_1458092.html) .

The institutions they support are mainly "[Chitalishta](https://en.wikipedia.org/wiki/Chitalishte)". Typical Bulgarian community centres. We have them since the "[National revival](https://en.wikipedia.org/wiki/Bulgarian_National_Revival) in the 19th century.

Currently they have computer cabinets in around 40 villages. Some of the places were equipped with tennis tables, sport roomms, libraries and study halls.

### The technical stuff

For operating system we choose Xubuntu with some modifications, Bulgarian localization and educational software. The most difficult part of the whole setup were some Windows games. Kendov requires them. It's a political idea. The children will visit the chitalishta more often if there are games. It's a topic for a whole new post!

I don't want to mention names because a lot of people were involved. I don't even know everyone. Although, Ardavast made the first provisioning setup with PXE and Debian Kickstart file. It was using the standard Debian terminal installer. There are some modifications but the same setup is still used. Ansible is used for the custom configuration. Kickstarter is running it as the last task.

There is a FreeIPA directory server for authentication but the setup is still not ready. When it's finished, the children will have single sign-on for the workstations and other online services in the network. 

The children and the other visitors have a cloud file store for keeping their data (Oblache). It's based on NextCloud. One of the former ideas was to setup an old PC as a NFS server for the home directories in every village but it's hard to maintain.

Matrix chat and private community social network are still some of the ideas in the backlog.

We have a main server with several LXD containers in Sofia. It's also the VPN server which is connecting the villages. Every place has a /24 IPv4 range. The VPN software is Wireguard and the client devices are routers with OpenWRT. Thanks to Kiril Zyapkov for the network setup :)

The configurations can be found on GitLab: [https://gitlab.com/zaselata](https://gitlab.com/zaselata)