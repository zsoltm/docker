#!/bin/bash

set -e
gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
cd /usr/local/bin

for suffix in "" ".asc"; do
 curl -kLSo gosu${suffix}\
 "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture)${suffix}";
done

gpg --verify gosu.asc
rm gosu.asc
chmod +x gosu
mv gosu /tmp/out
