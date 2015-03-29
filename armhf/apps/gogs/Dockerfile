FROM zsoltm/ubuntu-armhf:14.01-16.02.2015

ADD gogs-armhf-0.6.1.tar.gz gogs-entry.sh app.ini /opt/

RUN apt-get install -y git && apt-get clean

RUN groupadd gogs && useradd -m -g gogs gogs\
 && mkdir -p /repository && chown gogs:gogs /repository\
 && mkdir -p /data && chown gogs:gogs /data\
 && mkdir -p /static/public\
 && mkdir -p /static/templates\
 && mkdir -p /opt/gogs/custom/conf && mv /opt/app.ini /opt/gogs/custom/conf/app.ini.default && ln -sf /data/app.ini /opt/gogs/custom/conf/app.ini

VOLUME /static
VOLUME /data
VOLUME /repository
EXPOSE 3000

ENTRYPOINT ["/opt/gogs-entry.sh"]
CMD ["gogs"]
