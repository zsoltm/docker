# Dockerfile for Core Ubuntu ARMHF
# https://wiki.ubuntu.com/Core

FROM scratch
ADD ubuntu-core-14.04.1-core-armhf.tar.gz /

RUN\
 && export DEBIAN_FRONTEND=noninteractive\
 && apt-get -q -y update\
 && apt-get -q -y upgrade\
 && apt-get clean

ENV LC_ALL C.UTF-8

CMD /bin/bash 
