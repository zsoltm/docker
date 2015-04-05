FROM zsoltm/debian-armhf:jessie

ADD ioq3-linux-armv7l.tar.bz2 /usr/local/games/
ADD entrypoint.sh /

# Install required packages

RUN apt-get update && apt-get -y --no-install-recommends install unzip wget\
 && rm -rf /var/lib/apt/lists/*

# Prepare IOQ3

RUN useradd -m q3\
 && mkdir /home/q3/.q3a\
 && chown q3:q3 /home/q3/.q3a\
 && mkdir -p /opt/q3a\
 && cd /usr/local/games/ioq3-linux-armv7l/baseq3\
 && for i in `seq 0 8`; do ln -s /opt/q3a/baseq3/pak${i}.pk3; done\
 && cd ..\
 && ln -s ioq3ded.armv7l ioq3ded\
 && ln -s ioquake3.armv7l ioquake3

# GOSU

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4\
 && cd /usr/local/bin\
 && for suffix in "" ".asc"; do \
     wget -O gosu${suffix} --no-check-certificate\
       "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture)${suffix}"; \
   done \
 && gpg --verify gosu.asc\
 && rm gosu.asc\
 && chmod +x gosu

# OSP

RUN cd /usr/local/games/ioq3-linux-armv7l/\
 && wget http://osp.dget.cc/orangesmoothie/downloads/osp-Quake3-1.03a_full.zip\
 && unzip osp-Quake3-1.03a_full.zip\
 && rm osp-Quake3-1.03a_full.zip

EXPOSE 27960/udp

VOLUME /home/q3
VOLUME /opt/q3a

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ioq3ded"]
