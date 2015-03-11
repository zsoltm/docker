FROM debian:jessie

#ENV DEBIAN_FRONTEND="noninteractive"

ADD nightgate.key supervisord.conf /

RUN echo "deb http://shell.ninthgate.se/packages/debian wheezy main" >> /etc/apt/sources.list\
 && cat nightgate.key | apt-key add - && rm /nightgate.key\
 && apt-get -q update\
 && apt-get install -qy --force-yes plexmediaserver supervisor\
 && apt-get clean\
 && /etc/init.d/plexmediaserver stop\
 && /etc/init.d/avahi-daemon stop\
 && /etc/init.d/dbus stop\
 && mkdir -p /var/run/dbus && chown messagebus /var/run/dbus\
 && mv supervisord.conf /etc/supervisor/conf.d/\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*\
 && rm -rf /var/lib/plexmediaserver/*\
 && usermod -d /config plex\
 && mkdir -p /config/Library/Application Support && chown -R plex:nogroup /config

VOLUME /config
VOLUME /media

EXPOSE 32400

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
