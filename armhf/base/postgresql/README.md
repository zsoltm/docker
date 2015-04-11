PostgreSQL
==========

Loosely based on official [docker postgres](https://registry.hub.docker.com/_/postgres/) repository.

## Supported tags

+ [`9.4`, `9.4.1`, `latest` Dockerfile](https://github.com/zsoltm/docker/blob/postgresql-armhf-9.4.1-1/armhf/base/postgresql/Dockerfile)

## How to use this image

Primarily it's meant to be linked to an application that uses it.

Start a postgres instance:

    docker run --name postgres-for-shiny-app -e POSTGRES_PASSWORD=mysecretpassword -d zsoltm/postgresql-armhf

... and and start an application linked to it:

    docker run --name shiny-app-instance --link postgres-for-shiny-app:postgres -d your/shiny-app

Optionally if you need to thinker your PostgreSQL DB manually, you might run a `psql` connected to it easily:

    docker run -it --link postgres-for-shiny-app:postgres --rm \
     zsoltm/postgresql-armhf sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" \
     -p "$POSTGRES_PORT_5432_TCP_PORT" -U $POSTGRES_ENV_POSTGRES_USER'

## Environment Variables

It's highly recommended to specify these rather than going with the default values.

+ `POSTGRES_USER` - User to create a database for, defaults to `postgres`.
+ `POSTGRES_PASSWORD` - Pasword for `POSTGRES_USER` or postgres with superuser rights.
