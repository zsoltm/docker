FROM zsoltm/io-quake3-armhf

RUN cd /usr/local/games/quake3\
 && aria2c http://osp.dget.cc/orangesmoothie/downloads/osp-Quake3-1.03a_full.zip\
 && unzip osp-Quake3-1.03a_full.zip && rm osp-Quake3-1.03a_full.zip\
 && rm -Rf\
   "osp/Docs osp/voodoo osp/INSTALL.txt"\
   "osp/OSP Config Generator.exe" "osp/OSP Match Quick Start.txt"\
   "osp/VoodooStats-ReadME.txt osp/description.txt"\
 && find osp -type d -exec chmod 755 {} \; -print\
 && find osp -type f -exec chmod 644 {} \; -print

ENV GAME osp
ENV NAME "Dockerized ^2/ ^3Excessive ^2/ ^6ARMv7l"
