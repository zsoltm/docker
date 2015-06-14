FROM zsoltm/debian-armhf:jessie

COPY assets/ app/

RUN apt-get update \
 && apt-get install --no-install-recommends supervisor logrotate locales curl\
    openssh-server postgresql-client redis-tools\
    git-core ruby2.1 python2.7 python-docutils\
    libpq5 libyaml-0-2 libssl1.0.0\
    libgdbm3 libffi6 libxml2 libxslt1.1 libcurl3 libicu52\
    ssmtp sudo nodejs nginx-light\
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX\
 && dpkg-reconfigure locales\
 && rm /etc/ssh/ssh_host_*_key*\
 && adduser --disabled-login --gecos 'GitLab' git\
 && ln -s /usr/bin/ruby2.1 /usr/bin/ruby\
 && ln -s /usr/bin/gem2.1 /usr/bin/gem\
 && gem install --no-document bundler\
 && rm -rf /var/lib/apt/lists/*\
 && /app/init/

EXPOSE 22
EXPOSE 80

VOLUME ["/home/git/data"]
VOLUME ["/var/log/gitlab"]

WORKDIR /home/git/gitlab
ENTRYPOINT ["/app/init"]
CMD ["app:start"]
