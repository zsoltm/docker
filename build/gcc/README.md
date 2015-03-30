GCC
===

## Supported tags

+ [`4.9`, `4.9.2`, `latest` Dockerfile](https://github.com/zsoltm/docker/blob/gcc/build/gcc/Dockerfile)

## How to use this image

Compile your app inside the Docker container

    docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp zsoltm/gcc:4.9 gcc -o myapp myapp.c

[Repository link](https://registry.hub.docker.com/u/zsoltm/gcc/)
