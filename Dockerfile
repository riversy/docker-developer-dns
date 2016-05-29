FROM alpine
MAINTAINER Ike Devolder, ike.devolder@gmail.com

RUN apk add --update dnsmasq supervisor \
    && for user in $(cat /etc/passwd | awk -F':' '{print $1}' | grep -v root); do deluser "$user"; done \
    && for group in $(cat /etc/group | awk -F':' '{print $1}' | grep -v root); do delgroup "$group"; done \
    && mkdir /work

ADD https://github.com/jwilder/docker-gen/releases/download/0.7.1/docker-gen-alpine-linux-amd64-0.7.1.tar.gz /tmp/docker-gen-alpine-linux-amd64-0.7.1.tar.gz
RUN tar -C /usr/bin -zxvf /tmp/docker-gen-alpine-linux-amd64-0.7.1.tar.gz \
    && rm /tmp/docker-gen-alpine-linux-amd64-0.7.1.tar.gz

ADD ./supervisord.conf /work/supervisord.conf
ADD ./dnsmasq.tmpl /work/dnsmasq.tmpl
WORKDIR /work/

ENV DOCKER_HOST unix:///var/run/docker.sock

EXPOSE 53/udp

CMD ["supervisord", "-c", "supervisord.conf"]
