#! /bin/bash
set -e

if [ "$1" = 'ioq3ded' ]; then
    workdir="/home/q3/.q3a"
    if [ ! -d "${workdir}" ]; then
        mkdir -p "${workdir}"
        chown q3:q3 "${workdir}"
    fi

    shift
    exec gosu q3 /usr/local/games/ioq3-linux-armv7l/ioq3ded $@
fi

exec $@
