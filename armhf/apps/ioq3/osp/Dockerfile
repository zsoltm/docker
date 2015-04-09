FROM zsoltm/ioq3

RUN cd /usr/local/games/ioq3-linux-armv7l/\
 && curl -LO http://osp.dget.cc/orangesmoothie/downloads/osp-Quake3-1.03a_full.zip\
 && unzip osp-Quake3-1.03a_full.zip\
 && rm -Rf osp-Quake3-1.03a_full.zip osp/Docs osp/voodoo osp/INSTALL.txt\
   "osp/OSP Config Generator.exe" "osp/OSP Match Quick Start.txt"\
   osp/VoodooStats-ReadME.txt osp/description.txt\
 && find osp -type d -exec chmod 755 {} \; -print\
 && find osp -type f -exec chmod 644 {} \; -print
