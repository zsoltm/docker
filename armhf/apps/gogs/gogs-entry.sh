#!/bin/bash

set -e

if [ "$1" = 'gogs' ]; then
    cd /opt/gogs

    chown -R gogs /data /repository

    for DIR in "/data/avatar" "/data/attachment" "/data/log"; do
        if [ ! -d "${DIR}" ]; then
            mkdir -p "${DIR}"
            chown gogs:gogs "${DIR}"
        fi
    done

    if [ -z "$(ls -A "/static/public")" ]; then
        echo "Restoring default static assets..."
        mkdir -p "${DIR}"
        cp -R public/. /static/public
    fi

    if [ -z "$(ls -A "/static/templates")" ]; then
        echo "Restoring default templates..."
        mkdir -p "${DIR}"
        cp -R templates/. /static/templates
    fi

    if [ ! -f "/data/app.ini" ]; then
        cp /opt/gogs/custom/conf/app.ini.default /data/app.ini
    fi

    sed -i -e 's/^PASSWD *=.*/'"PASSWD = ${POSTGRES_ENV_POSTGRES_PASSWORD}/g"\
     -e 's/^USER *=.*/'"USER = ${POSTGRES_ENV_POSTGRES_USER}/g"\
     -e 's/^HOST *=.*/'"HOST = ${POSTGRES_PORT_5432_TCP_ADDR}:${POSTGRES_PORT_5432_TCP_PORT}/g"\
     /data/app.ini

    export USER=gogs
    export HOME=/home/gogs
    exec gosu gogs /opt/gogs/gogs web
fi

exec "$@"
