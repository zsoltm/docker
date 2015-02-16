# Dockerfile for Core Ubuntu ARMHF
# https://wiki.ubuntu.com/Core

FROM scratch
ADD ubuntu-core-14.04.1-core-armhf.tar.gz /

RUN export DEBIAN_FRONTEND=noninteractive\
 && apt-get -q -y update\
 && apt-get -q -y upgrade\
 && apt-get install -y unzip curl wget\
 && apt-get clean

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4\
 && export GOSU_URL="https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)"\
 && wget -O /usr/local/bin/gosu.asc ${GOSU_URL}.asc\
 && wget -O /usr/local/bin/gosu ${GOSU_URL}\
 && gpg --verify /usr/local/bin/gosu.asc\
 && rm /usr/local/bin/gosu.asc\
 && chmod +x /usr/local/bin/gosu

ENV LC_ALL C.UTF-8

WORKDIR /root

CMD /bin/bash --login

