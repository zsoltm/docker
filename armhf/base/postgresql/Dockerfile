FROM zsoltm/ubuntu-armhf:14.01.2015

# install gosu

RUN\
 groupadd -r postgres && useradd -r -g postgres postgres &&\
 apt-get -y install wget &&\
 gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 &&\
 export GOSU_URL="https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" &&\
 wget -O /usr/local/bin/gosu.asc ${GOSU_URL}.asc &&\
 wget -O /usr/local/bin/gosu ${GOSU_URL} &&\
 gpg --verify /usr/local/bin/gosu.asc &&\
 rm /usr/local/bin/gosu.asc &&\
 chmod +x /usr/local/bin/gosu

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV PG_MAJOR 9.3

RUN apt-get install -y postgresql-common\
 && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf\
 && apt-get install -y postgresql-${PG_MAJOR} postgresql-contrib\
 && mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/${PG_MAJOR}/bin:${PATH}
ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]

