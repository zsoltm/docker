FROM zsoltm/ubuntu-java-armhf:8u33-16.02.2015

ENV NEXUS_VERSION 2.11.2-03
ENV PIDDIR /opt/nexus/tmp

WORKDIR /

RUN export NEXUS_ARCHIVE=nexus-${NEXUS_VERSION}-bundle.tar.gz\
 && wget --progress=dot:mega https://sonatype-download.global.ssl.fastly.net/nexus/oss/${NEXUS_ARCHIVE}\
 && tar xf ${NEXUS_ARCHIVE} -C opt\
 && rm ${NEXUS_ARCHIVE}\
 && groupadd nexus && useradd -m -g nexus nexus\
 && mv opt/nexus-${NEXUS_VERSION} /opt/nexus\
 && chown -R nexus:nexus opt/nexus/logs opt/nexus/tmp opt/sonatype-work\
 && wget --progress=dot:mega http://wrapper.tanukisoftware.com/download/3.5.26/wrapper-linux-armhf-32-3.5.26.tar.gz\
 && tar xf wrapper-linux-armhf-32-3.5.26.tar.gz -C opt\
 && rm wrapper-linux-armhf-32-3.5.26.tar.gz\
 && mkdir opt/nexus/bin/jsw/linux-armv7l-32\
 && mv opt/wrapper-linux-armhf-32-3.5.26/bin/wrapper opt/nexus/bin/jsw/linux-armv7l-32/\
 && rm -Rf opt/wrapper-linux-armhf-32-3.5.26

EXPOSE 8081

VOLUME /opt/sonatype-work
VOULME /opt/nexus/conf
VOULME /home/nexus

CMD gosu nexus opt/nexus/bin/nexus console
