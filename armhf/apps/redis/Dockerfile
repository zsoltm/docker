FROM zsoltm/debian-armhf:jessie

ENV REDIS_VERSION 3.0.2

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gcc libc6-dev make\
    && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4\
    && curl -SLo /usr/local/bin/gosu\
      "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && curl -SLo /usr/local/bin/gosu.asc\
      "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu\
    && set -x \
    && mkdir -p /usr/src/redis \
    && curl -sSL "http://download.redis.io/releases/redis-3.0.2.tar.gz" -o redis.tar.gz \
    && echo "a38755fe9a669896f7c5d8cd3ebbf76d59712002 *redis.tar.gz" | sha1sum -c - \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && rm -rf /usr/src/redis \
    && apt-get purge -y --auto-remove ca-certificates curl gcc libc6-dev make curl\
    && apt-get clean && rm -rf /var/lib/apt/lists/*\
    && mkdir /data && chown redis:redis /data

VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 6379
CMD [ "redis-server" ]
