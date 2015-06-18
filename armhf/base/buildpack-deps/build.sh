#! /bin/bash

docker build -t "zsoltm/buildpack-deps-curl-armhf:jessie" curl/\
 && docker build -t "zsoltm/buildpack-deps-scm-armhf:jessie" scm/\
 && docker build -t "zsoltm/buildpack-deps-armhf:jessie" .\
 && docker build -t "zsoltm/buildpack-deps-deb-armhf:jessie" deb/
 