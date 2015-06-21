FROM zsoltm/debian-armhf:jessie

ADD privoxy_3.0.23-3_armhf.deb /
ADD gosu /usr/local/bin/
RUN dpkg -i --force-depends privoxy_3.0.23-3_armhf.deb

VOLUME /etc/privoxy
EXPOSE 8118
WORKDIR /etc/privoxy

CMD gosu proxy /usr/sbin/privoxy --no-daemon
