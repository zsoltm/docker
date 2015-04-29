FROM zsoltm/io-quake3-armhf

ADD excessiveplus.metalink entrypoint.sh /

# RUN apt-get update && apt-get install -y --no-install-recommends unzip\
#  && apt-get clean && rm -rf /var/lib/apt/lists/*\
RUN cd /usr/local/games/quake3\
 && aria2c --check-certificate=false /excessiveplus.metalink && rm /excessiveplus.metalink\
 && unzip xp-2.3.zip && rm xp-2.3.zip\
 && rm -Rf xp_dedicated.bat xp_server.bat xp_singleplayer.bat excessiveplus/tools

ENV GAME excessiveplus
ENV NAME "Dockerized ^2/ ^3Excessive ^2/ ^6ARMv7l"
