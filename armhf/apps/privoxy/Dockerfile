FROM zsoltm/debian-armhf:jessie

ADD privoxy-3.0.23-local.tar.gz /

# GOSU

RUN apt-get update && apt-get install -y --no-install-recommends curl\
 && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4\
 && cd /usr/local/bin\
 && for suffix in "" ".asc"; do \
     curl -kLSo gosu${suffix}\
       "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture)${suffix}"; \
   done \
 && gpg --verify gosu.asc\
 && rm gosu.asc\
 && chmod +x gosu\
 && apt-get purge -y --auto-remove curl\
 && apt-get clean\
 && rm -rf /var/lib/apt/lists/*

VOLUME /usr/local/etc/privoxy

EXPOSE 8118

WORKDIR /usr/local/etc/privoxy

CMD gosu proxy /usr/local/sbin/privoxy --no-daemon
