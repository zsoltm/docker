IO-Quake3 Arena for ARMv7l
=======================

A Quake 3 Arena client & server bult from latest [IOQuake3][ioquake3]
[sources][ioq3-arm-src].

<p align="center">
  <img src="https://raw.githubusercontent.com/zsoltm/ioq3/REL-1.36-2/misc/quake3-tango.png" alt="Q3 Logo"/>
</p>

## Supported Tags

+ [`1.36-3`, `latest` Dockerfile][dockerfile]

## Usage

Example command line for running a server with default settings:

    docker run -dt\
     -v `pwd`:/home/q3\
     --net="host"\
     --name="quake3"\
     zsoltm/io-quake3

That's it, you should be able to connect from Quake 3 by entering `/connect
your-host-ip` into the game console. In your `pwd` a `.q3a` subdir is created
with a default configuration on first start.

## Known issues

If it doesn't get started with `--net="host"` but with regular port mapping
like `-p 27960:27960/udp` then after the container gets restarted and it gets
a new internal IP address Docker fails to clean up conntrack tables, that
means the server becomes unreachable from the outside world. As of now this is
a known, yet to be solved [Docker issue][udp-bug] with UDP port mapping.

A dirty workaround to the problem above would be:

    sudo iptables --table raw --append PREROUTING\
     --protocol udp --source-port 27960 --destination-port 27960 --jump NOTRACK

Be sure the source-port and destination-port matches your actual configuration.

Another workaround is cleaning up the conntrack table manually after restart:

    sudo conntrack -D -p udp

Conntrack should be installed of course (`sudo apt-get install conntrack`).

[dockerfile]: https://github.com/zsoltm/docker/blob/ioq3-x86_64-1.36-3/armhf/apps/ioq3/Dockerfile "Dockerfile"
[udp-bug]: https://github.com/zsoltm/docker/blob/ioq3-x86-64-1.36-3/armhf/apps/ioq3/Dockerfile "Dockerfile"
[ioquake3]: http://ioquake3.org/
[ioq3-arm-src]: https://github.com/zsoltm/ioq3/releases
