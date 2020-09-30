+++
author = "Blagovest Petrov"
title = "My way to auto update Let's Encrypt certs without downtime"
date = "2015-12-27"

tags = [
    "Let's encrypt",
    "Security"
]
categories = [
    "System Administration"
]
+++  

It's been a while since my last post here. This is my first post with the new platform - [Hexo](https://hexo.io). It's faster and simpler than Octopress and it's not Ruby but nevermind...

The whole concept with the Certification Authorities is completely broken but we don't have something better which is working. A world with fully encrypted web is a really a good idea since the whole internet traffic is monitored by governments and other private organizations. [Let's encrypt](https://letsencrypt.org) is an attempt for that. It's a colaborative project between Linux foundation, EFF and some other organizations.

They are providing free (completely free!) certificates with 3 months of validity. After that time, the certificates can be updated again.

## Signing and delivery of the certificates

Let's encrypt is using the [ACME](https://github.com/letsencrypt/acme-spec) (Automated Certificate Management Environment) protocol which defines automatically obtaining of certificates. More information about the protocol can be found at the [Let's Encrypt - How it works page](https://letsencrypt.org/howitworks/technology/).

## So, let's start the technical part

In this setup I'll use Ubuntu 14.04 with HAProxy for load balancing and managing the traffic for all of the domains.

### Install HAProxy:

HAProxy will directly deliver bind the HTTPS content but we need SNI checks for the Acme client. So, it's a bit bizzare. We will have a loop inside HAPproxy. A TCP proxy frontend which is proxying a backend from localhost to the HTTPS proxy frontend.

TCP frontend -> HTTPS backend/ACME client backend -> HTTPS frontend -> Application Servers HTTP backends

```bash
sudo apt-get install -y software-properties-common
sudo apt-add-repository ppa:vbernat/haproxy-1.5
sudo apt-get update
sudo apt-get install -y haproxy
```

#### Configure HAProxy:

Let's start with the default global config (`/etc/haproxy/haproxy.cfg`):

```
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        tune.bufsize 131072
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /srv/certs
        crt-base /srv/certs

        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL).
        ssl-default-bind-ciphers kEECDH+aRSA+AES:kRSA+AES:+AES256:!RC4-SHA:!kEDH:!LOW:!EXP:!MD5:!aNULL:!eNULL

        # tunning
        maxconn 16384

```

Then, append the default configuration for the http/s frontends (`/etc/haproxy/haproxy.cfg`):

```
defaults http
        log     global
        mode    http
        option  httplog
        option  dontlognull
        option forwardfor
        option http-server-close
        timeout connect 5s
        timeout client  310s
        timeout server  310s
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http
```

Setup the HTTP frontend. It will only refer the http requests to https:

```
frontend www-http
        bind 0.0.0.0:80
        reqadd X-Forwarded-Proto:\ http
        option forwardfor
	
	#ACLs
	acl example_sites hdr(host) -i example.com www.example.com

	#Redirects
	redirect prefix https://cloud.grandcity-property.com if example_sites
```

Now, create the HTTPS frontend. The port must be different than 443.

```

frontend www-https
	bind 0.0.0.0:4443 ssl crt example.com.pem crt www.example.com.pem crt ./ no-sslv3
	reqadd X-Forwarded-Proto:\ https
	option forwardfor

	#ACLs
	acl example_sites hdr(host) -i example.com www.example.com
	
	use_backend examplecom if example_sites
```

Create the backend for example.com:

```
backend examplecom
	timeout server 30m
	balance leastconn
	option httpclose
	option forwardfor
	cookie JSESSIONID prefix
	server node1 192.168.0.10:80 cookie A check
```

Now, the TCP Proxy part. TCP defaults:

```
#### TCP Section

defaults tcp
        log     global
        mode tcp
        option tcplog
        timeout connect 10s
        timeout client  600s
        timeout server  600s
```

The TCP frontend (listening on port 443):

```
frontend www-https-tcp
        log global
        mode tcp
        option tcplog
        bind 0.0.0.0:443
        tcp-request inspect-delay 5s
        tcp-request content accept if { req.ssl_hello_type 1 }
        # Matching all SNI names with *.acme.invalid
        acl app_letsencrypt req.ssl_sni -m end .acme.invalid

        use_backend letsencrypt if app_letsencrypt

        # sending everything that doesn't match *.acme.invalid to the HTTPS backend
        default_backend bk_frontend_https_loop
```

And the backends for www-https-tcp:

```
backend bk_frontend_https_loop
        log global
        mode tcp
        option tcplog
        server localserver 0.0.0.0:4443

backend letsencrypt
        log global
        mode tcp
        option tcplog
        server letsencrypt 0.0.0.0:63443 #By default, Let's encrypt works on 443.
```

The whole haproxy.cfg is in [this](https://gist.github.com/eniac111/95ef382b545aa2d43dff) gist.

### Now, install the official Let's encrypt client:

Install git: 
```
sudo apt-get install -y git
```

Download the client:
```
git clone https://github.com/letsencrypt/letsencrypt /root/letsencrypt
```

And create the certificate for example.com and wwww.example.com:
```
/root/letsencrypt/letsencrypt-auto --email admin@example.com -d example.com -d www.example.com --authenticator standalone --tls-sni-01-port 63443 --text auth  --http-01-port 8099
```

Now, download ssl-cert-check from Prefetch.net. This is very useful script because it calculates the time difference between the current time and the certification expiration date:

```
sudo wget -O http://prefetch.net/code/ssl-cert-check /usr/local/bin/ssl-cert-check
sudo chmod +x /usr/local/bin/ssl-cert-check
```

Put this script to /etc/cron.daily/updatessl and make it executable :

```bash
#!/bin/bash

########################################################################
## Script for updating Let's encrypt certs
## http://petrovs.info/2015/12/27/My-way-to-auto-update-Lets-Encrypt/
## (C) 2015 Blagovest Petrov (blagovest <at> petrovs dot info)
## Released under the GPL
########################################################################

cd /etc/letsencrypt/live

for DIRS in *; do
  if ssl-cert-check -c $DIRS/fullchain.pem | grep -q "Valid"; then
    echo On `date`, $DIRS is Valid. >> /var/log/letsencrypt-update.log
    #cat $DIRS/fullchain.pem > /srv/certs/$DIRS.pem
    #cat $DIRS/privkey.pem >> /srv/certs/$DIRS.pem
  else
    echo On `date`, $DIRS is NOT Valid. Generating a new certificate from Let\'s encrypt... >> /var/log/letsencrypt-update.log
    /root/letsencrypt/letsencrypt-auto --email it@veriosoft.com -d $DIRS --authenticator standalone --tls-sni-01-port 63443 --renew-by-default --text auth  --http-01-port 8099 >> /var/log/letsencrypt-update.log
    echo Generating fullchain token for $DIRS to be used for HAProxy... >> /var/log/letsencrypt-update.log
    cat $DIRS/fullchain.pem > /srv/certs/$DIRS.pem
    cat $DIRS/privkey.pem >> /srv/certs/$DIRS.pem
    echo Reloading the HAProxy configuration... >> /var/log/letsencrypt-update.log
    service haproxy reload
    echo Done :\) >> /var/log/letsencrypt-update.log
  fi
done
```

```bash
sudo wget -O https://gist.githubusercontent.com/eniac111/c7146b3e59c7eff27fbe/raw/506643d797811ec99ce6e32d8f9e23ea3a9200d4/updatessl.sh /etc/cron.daily/updatessl
sudo chmod +x /etc/cron.daily/updatessl
```

### The last thing is to create logrotate config for the update log:

Install logrotate it it's not installed:

```bash
sudo apt-get update && sudo apt-get install -y logrotate
```

Put this to `/etc/logrotate/letsencrypt-update`:

```
/var/log/letsencrypt-update.log {
	monthly
	rotate 12
	compress
	delaycompress
	missingok
	notifempty
	create 644 root root
}
```

Correct me if there is a better way. The double loop inside HAProxy is really bizzare.