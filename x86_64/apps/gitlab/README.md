Gitlab
======

This is based on official docker image but mostly the one by Sameer Naik.

Most notable modifications compared to the solutions mentioned above and differences in design:

+ Based on Debian Jessie.
+ Isolated build steps into a build-only container allowing a much smaller runtime image.
+ Clearly separated initialisation and startup actions need to be taken. Startup should be fast.
+ Cleaner volumes, isolated `data` and `repositiories` paths - the latter should be shareable accross multiple instances load-balanced instances.
+ Better directory structure - all relevant configurations are externalised.
+ Increased security a bit here and there by using more suitable permissions

Some features are removed for sake of simplicity and easier configuration / dependency management:

+ Only PostgreSQL is supported as a DB backend - Postgres is the recommended DB by Gitlab anyway.
+ Removed HTTPS support; use a load balancer or front-end proxy with HTTPS support.

Start like

    docker run -it -v `pwd`:/tmp/out --name=gitlab-runtest\
     --link=gitlab-redis:redis\
     --link=gitlab-postgres:postgres\
     -e 
     zsoltm/gitlab-armhf:7.11.4-1

It expects a Redis and a PostgreSQL container being linked named as "gitlab-redis" and "gitlab-postgresql"
respectively. Optionally external Postrges instance could be specified with `DB_*` environment variables
and / or Redis by REDIS_HOST and REDIS_PORT parameters.

# Requirements

A PostgreSQL DB container:

    docker run --name gitlab-postgres -e POSTGRES_USER=git -e POSTGRES_PASSWORD=6nPDNTxp -d zsoltm/postgresql-armhf

A Redis DB container:

    docker run --name gitlab-redis

# Environment variables

### Mandatory:

GITLAB_HOST -- gitlab host name
GITLAB_EMAIL_FROM -- email from address
SMTP_HOST -- mail server host
SMTP_PASSWORD -- mail server authentication password

### Optional:

GITLAB_PORT -- http port of gitlab for https use 443 (80)
DB_POOL -- number of pooled DB connections (10)
GITLAB_ROOT_PASSWORD -- initial root password  (check env.sh for default)
GITLAB_TIMEZONE -- (Europe/Zurich)
GITLAB_EMAIL_DISPLAY_NAME -- email display name at from field (Gitlab)
GITLAB_EMAIL_REPLY_TO -- reply-to address (`GITLAB_EMAIL_FROM`)
UNICORN_WORKERS -- number of worker processes (CPU cores +1 is the recommended)
UNICORN_TIMEOUT -- request timeout at unicorn, http level (60)
SIDEKIQ_CONCURRENCY -- sidekiq is the background task executor, this value specifies how much task could be xecuted in parallel (5)
DB_HOST -- Postgresql host if not linked
DB_PORT -- Postgresql port if not linked (5432)
DB_USER -- Postgresql username for authentication
DB_PASS -- Postgresql password for authentication
DB_NAME -- databse name
REDIS_HOST -- Redis host if not linked
REDIS_PORT -- Redis port if not linked (6379)
SMTP_PORT -- port for sending mail (587)
SMTP_USER -- mail server authentication username (`GITLAB_EMAIL_FROM`)
SMTP_DOMAIN -- domain name for authentication (domain part of `GITLAB_EMAIL_FROM`)
SMTP_AUTH -- authentication mode for remote host (plain)
SMTP_VERIFY -- SSL verification mode of remote mail host (none)

# TODO

+ Check `~/gitlab/tmp/cache/...` used by `assets:precompile`, `production` folder was created.
+ Create a separate volume for repositiories
