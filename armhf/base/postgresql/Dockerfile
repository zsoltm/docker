FROM zsoltm/ubuntu-armhf:14.01-16.02.2015

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV PG_MAJOR 9.3

RUN apt-get install -y postgresql-common\
 && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf\
 && apt-get install -y postgresql-${PG_MAJOR} postgresql-contrib\
 && apt-get clean\
 && mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/${PG_MAJOR}/bin:${PATH}
ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]
