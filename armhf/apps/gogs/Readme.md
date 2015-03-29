# GoGS Container

Go GIT Server.

Run it like the example below:

    $ docker run -d\
      -p 3000:3000\
      -v /mnt/docker-volumes/gogs-repository:/repository\
      -v /mnt/docker-volumes/gogs-data:/data\
      -v /mnt/docker-volumes/gogs-static:/static\
      --link gogs-postgres:postgres\
      zsoltm/gogs

It expects a postgres container to be linked, an example command line for that would be:

    $ docker run --name gogs-postgres -d\
      -e POSTGRES_USER=gogs\
      -e POSTGRES_PASSWORD=<PWD>\
      -v /mnt/docker-volumes/gogs-pgdata:/var/lib/postgresql/data\
      zsoltm/postgresql

# Build GoGS

The binary tar for arm - as ARM has no official binary releases - is cross-compiled on an x86_64 PC with docker like this:

    $ docker run -it --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp\
     -e GOOS=linux\
     -e GOARCH=arm\
     -e GOARM=7\
     -e GOPATH=/usr/src/myapp\
     golang:1.4.2-cross /bin/bash

    $ go get github.com/gogits/gogs
    $ cd src/github.com/gogits/gogs
    $ go build
    $ cd ..
    $ tar czvf /usr/src/myapp/gogs-arm.tar.gz gogs/gogs gogs/public gogs/templates

After exiting the container, the tarball should be accessible in the current directory.

## Volumes

 + `/static` - static WEB assets and templates.
 + `/data` - various runtime data; logs, avatars and attachments
 + `/repository` - git repositories
