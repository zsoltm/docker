FROM zsoltm/debian-armhf:jessie

ADD ioq3-linux-armv7l.tar.bz2 /usr/local/games/
ADD entrypoint.sh /

# Install required packages

RUN apt-get update && apt-get -y --no-install-recommends install unzip curl\
 && apt-get clean\
 && rm -rf /var/lib/apt/lists/*

# GOSU

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4\
 && cd /usr/local/bin\
 && for suffix in "" ".asc"; do \
     curl -kLSo gosu${suffix}\
       "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture)${suffix}"; \
   done \
 && gpg --verify gosu.asc\
 && rm gosu.asc\
 && chmod +x gosu

# IOQ3

RUN useradd -m q3\
 && mkdir /home/q3/.q3a\
 && chown q3:q3 /home/q3/.q3a\
 && mkdir -p /opt/q3a\
 && cd /usr/local/games/ioq3-linux-armv7l/baseq3\
 && for i in `seq 0 8`; do curl -OkLS https://github.com/nrempel/q3-server/raw/master/baseq3/pak${i}.pk3 ; done\
 && cd ..\
 && ln -s ioq3ded.armv7l ioq3ded\
 && ln -s ioquake3.armv7l ioquake3

EXPOSE 27960/udp

VOLUME /home/q3
VOLUME /opt/q3a

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ioq3ded"]
