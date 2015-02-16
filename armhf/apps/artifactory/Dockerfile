FROM zsoltm/ubuntu-java-armhf:8u33-16.02.2015

ENV ARTIFACTORY_VERSION 3.4.2
WORKDIR /

RUN groupadd -r artifactory && useradd -r -g artifactory artifactory\
 && wget -O artifactory.zip http://dl.bintray.com/content/jfrog/artifactory/artifactory-${ARTIFACTORY_VERSION}.zip?direct\
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

