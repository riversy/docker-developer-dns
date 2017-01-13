#!/bin/sh

set -e

DOCKERGEN_VERSION=0.7.3

apk update
apk add --update ca-certificates wget dnsmasq supervisor inotify-tools
update-ca-certificates

touch /etc/dnsmasq.d/generated.conf

wget https://github.com/jwilder/docker-gen/releases/download/$DOCKERGEN_VERSION/docker-gen-alpine-linux-amd64-$DOCKERGEN_VERSION.tar.gz -O /tmp/docker-gen-alpine-linux-amd64-$DOCKERGEN_VERSION.tar.gz
tar -C /usr/bin -zxvf /tmp/docker-gen-alpine-linux-amd64-$DOCKERGEN_VERSION.tar.gz
rm /tmp/docker-gen-alpine-linux-amd64-$DOCKERGEN_VERSION.tar.gz

apk del wget ca-certificates

/container/user-cleanup.sh
/container/upgrade.sh
