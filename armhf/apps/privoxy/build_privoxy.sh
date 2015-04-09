#! /bin/sh

rel=3.0.23
srcdir=privoxy-${rel}-stable
tarball=${srcdir}-src.tar.gz

pushd /usr/src
curl -SLko ${tarball} http://sourceforge.net/projects/ijbswa/files/Sources/3.0.23%20%28stable%29/${tarball}/download\
 && tar xvf ${tarball}\
 && rm ${tarball}\
 && cd ${srcdir} || exit 1

autoheader\
 && autoconf\
 && ./configure\
 && make -j2 || exit 1

make install USER=proxy GROUP=proxy

tar czvf /target/privoxy-${rel}-local.tar.gz\
 /usr/local/sbin /usr/local/etc/privoxy /usr/local/share/doc/privoxy /var/log/privoxy

popd
