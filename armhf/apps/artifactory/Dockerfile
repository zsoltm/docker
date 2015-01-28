FROM zsoltm/ubuntu-java-armhf:8u33

ENV ARTIFACTORY_VERSION 3.4.2
WORKDIR /

RUN apt-get install -y unzip\
 && groupadd -r artifactory && useradd -r -g artifactory artifactory\
 && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4\
 && export GOSU_URL="https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)"\
 && wget -O /usr/local/bin/gosu.asc ${GOSU_URL}.asc\
 && wget -O /usr/local/bin/gosu ${GOSU_URL}\
 && gpg --verify /usr/local/bin/gosu.asc\
 && rm /usr/local/bin/gosu.asc\
 && chmod +x /usr/local/bin/gosu

RUN wget -O artifactory.zip http://dl.bintray.com/content/jfrog/artifactory/artifactory-${ARTIFACTORY_VERSION}.zip?direct\
 && unzip artifactory.zip && mv artifactory-${ARTIFACTORY_VERSION} artifactory\
 && rm artifactory.zip\
 && sed -i -e 's/Xmx2g/Xmx512m/g' -e 's/Xms512m/Xms128m/g' -e 's/-XX:PermSize=128m -XX:MaxPermSize=256m //'\
   artifactory/bin/artifactory.default\
 && mkdir -p artifactory/webapps/artifactory\
 && unzip artifactory/webapps/artifactory.war -d artifactory/webapps/artifactory\
 && rm artifactory/webapps/artifactory.war\
 && sed -i -e 's/\/artifactory.war/\/artifactory/g' artifactory/tomcat/conf/Catalina/localhost/artifactory.xml\
 && mkdir -p artifactory/data artifactory/backup\
 && ln -s /artifactory/logs/catalina /artifactory/tomcat/logs\
 && chown -R artifactory:artifactory artifactory/data artifactory/logs artifactory/tomcat/temp\
   artifactory/tomcat/work artifactory/backup artifactory/etc

EXPOSE 8081

VOLUME /artifactory/data

ENTRYPOINT gosu artifactory /artifactory/bin/artifactory.sh

