IO-Quake3 Arena for ARMv7l
=======================

A Quake 3 Arena client & server bult from latest [IOQuake3](http://ioquake3.org/)
[sources](https://github.com/zsoltm/ioq3/releases) for ARMv7l architecture.

<p align="center">
  <img src="https://raw.githubusercontent.com/zsoltm/ioq3/REL-1.36-2/misc/quake3-tango.png" alt="Q3 Logo"/>
</p>

## Supported Tags

+ [`1.36-3`, `latest` Dockerfile](https://github.com/zsoltm/docker/blob/ioq3-armhf-1.36-3/armhf/apps/ioq3/Dockerfile)

## Usage

Example command line for running a server with default settings:

    docker run -dt\
      -v `pwd`:/home/q3\
      -p 27960:27960/udp\
      --name="quake3"\
      zsoltm/ioq3-armhf

That's it, you should be able to connect from Quake 3 by entering `/connect your-host-ip` into the game console.

## Known issues

After an IOQ3 container is restarted, it gets a new internal IP address but Docker as of now (1.3) fails to clean up
conntrack tables, so connecting from the outside world is impossible. A dirty workaround would be:

    sudo iptables --table raw --append PREROUTING\
     --protocol udp --source-port 27960 --destination-port 27960 --jump NOTRACK

Be sure the source-port and destination-port matches your actual configuration.

Another workaround is cleaning up the conntrack table manually after restart:

    sudo conntrack -D -p udp

Conntrack should be installed of course (`sudo apt-get install conntrack`).
