IO-Quake3
=========

A Quake 3 Arena client & server bult from latest [IOQuake3](http://ioquake3.org/) sources
for ARMHF architecture.

## Usage

The image does not include copyrighted game content, that means the files named `pak*.pk3`
under `/baseq3` directory. However symlinks are created to all of these to the volume
`/opt/q3a`. That means if you have `baseq3/pak*.pk3` files on the directory mounted to
that volume, it sohuld run fine.

    opt/q3a
    └── baseq3
        ├── pak0.pk3
        ├── pak1.pk3
        ├── pak2.pk3
        ├── pak3.pk3
        ├── pak4.pk3
        ├── pak5.pk3
        ├── pak6.pk3
        ├── pak7.pk3
        └── pak8.pk3

Example command line for running an OSP Clan Arena Server with default settings:

    docker run -d\
      -v /opt/q3a:/opt/q3a\
      -v /mnt/docker-volumes/ioq3-ca:/home/q3\
      -p 27960:27960/udp\
      zsoltm/ioq3-armhf ioq3ded\
        +set fs_game osp +set fs_basepath /usr/local/games/ioq3-linux-armv7l\
        +set vm_game 2 +exec clanarena.cfg
