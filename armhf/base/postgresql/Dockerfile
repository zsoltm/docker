FROM zsoltm/debian-armhf:jessie

## Prerequisites

RUN apt-get update && apt-get install -y --no-install-recommends curl

## GOSU

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4\
 && cd /usr/local/bin\
 && for suffix in "" ".asc"; do \
     curl -kLSo gosu${suffix}\
       "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture)${suffix}"; \
   done \
 && gpg --verify gosu.asc\
 && rm gosu.asc\
 && chmod +x gosu

## Locales

ENV LANG en_US.utf8
RUN apt-get install -y --no-install-recommends locales\
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

## Postgres

ENV PG_MAJOR 9.4
ENV PATH /usr/lib/postgresql/${PG_MAJOR}/bin:${PATH}
ENV PGDATA /var/lib/postgresql/data
RUN apt-get install -y --no-install-recommends postgresql-common\
 && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf\
 && apt-get install -y --no-install-recommends postgresql-${PG_MAJOR} postgresql-contrib\
 && apt-get clean && rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/postgresql/data
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]
