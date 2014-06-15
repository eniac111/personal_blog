---
layout: post
title: "Photosphere of the Slaveykov Hall"
date: 2014-06-16 00:27
comments: true
categories: Images
---

Click on the link below to view the image:

<!-- more -->

The newest (restored) concert and cinema hall in Sofia. It's located inside the French Institut in Sofia.

##Drag the image with the mouse to change the view and zoom in/out with the scroll


<div id="sphere" style="width: 100%; height: 600px;"></div>
<script type="text/javascript" src="http://threejs.org/build/three.min.js"></script>
<script async="true" onload="setup();" type="text/javascript" src="https://raw.githubusercontent.com/kennydude/photosphere/a7bcc83aa1262811d028d647bd0d629bcff2b995/lib/sphere.js"></script>
<script type="text/javascript">
			function setup(){
					sphere = new Photosphere("http://petrovs.info/images/Posts/SlaveykovHall/salle.jpg")
					sphere.loadPhotosphere(document.getElementById("sphere"));
					return false;
			}
</script>
