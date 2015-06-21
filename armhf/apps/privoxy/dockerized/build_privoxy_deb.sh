#! /bin/bash

echo 'deb-src http://ftp.ch.debian.org/debian/ jessie main' >> /etc/apt/sources.list
apt-get update
apt-get build-dep -y privoxy
mkdir -p /usr/src/privoxy
pushd /usr/src
curl -LO http://http.debian.net/debian/pool/main/p/privoxy/privoxy_3.0.23.orig.tar.gz
cd privoxy
tar xvf ../privoxy_3.0.23.orig.tar.gz --strip-components=1
cp -R /mnt/host/deb/* .
dpkg-buildpackage -rfakeroot -uc -b
cd ..
mv *.deb /tmp/out
popd
