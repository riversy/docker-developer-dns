Docker developer DNS
====================

This DNS purpose is to allow for developers to run their development
environments without the need to update their `/etc/hosts` file. The additional
goal is to allow us to run a debug environment locally on the same domainname
as the 'live' environment. For now this DNS will be aimed at Linux users, over
time the goal is to provide a consistent platform for more operating systems.

This DNS will not try to create DNS entries for all running containers. You
must define what containers you want to be available in the DNS by using
`VIRTUAL_HOST` or `DOMAIN_NAME`.

Usage
-----

To run this DNS server we need access to the docker socket so the DNS entries
can be added dynamically.

run:

~~~ sh
$ docker run --name developer-dns \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 127.0.0.1:53:53/udp \
    blackikeeagle/developer-dns
~~~

systemd service:

~~~
[Unit]
Description=developer-dns
After=docker.service

[Service]
TimeoutSec=0
ExecStartPre=-/usr/bin/docker rm developer-dns
ExecStartPre=-/usr/bin/docker pull blackikeeagle/developer-dns
ExecStart=/usr/bin/docker run --name developer-dns -v /var/run/docker.sock:/var/run/docker.sock -p 127.0.0.1:53:53/udp blackikeeagle/developer-dns
ExecStop=/usr/bin/docker stop developer-dns

[Install]
WantedBy=multi-user.target
~~~

Let a container have a DNS entry
--------------------------------

You can use both `VIRTUAL_HOST` and `DOMAIN_NAME` environment variables to get
an entry or comma seperated to add entries to the developer-dns.

single dns entry:

~~~ sh
$ docker run --env VIRTUAL_HOST=test.dev nginx
$ docker run --env DOMAIN_NAME=memcached.test.dev memcached
~~~

When dealing with webservers you might want to add more:

~~~ sh
$ docker run --env VIRTUAL_HOST=mysite.dev,nl.mysite.dev,fr.mysite.dev,de.mysite.dev nginx
$ docker run --env DOMAIN_NAME=mysite.dev,nl.mysite.dev,fr.mysite.dev,de.mysite.dev nginx
~~~

Personally I would recommend to use `VIRTUAL_HOST` for http related entries and
`DOMAIN_NAME` for others. This way you can share you configuration with for
example OSX users using [dinghy](https://github.com/codekitchen/dinghy).

Resolve via developer-dns
-------------------------

On a system using resolveconf you can add this nameserver to the head.

~~~ sh
# echo "nameserver 127.0.0.1" > /etc/resolvconf/resolv.conf.d/head
~~~

On some systems this will not exist but you then can add it to
`/etc/resolvconf.conf`.

~~~
name_servers=127.0.0.1
~~~

You could also add it to your network configuration gui like NetworkManager.
