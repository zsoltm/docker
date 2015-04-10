#! /bin/bash

BUILD_DIR=/tmp/build
DEBOOTSTRAP_DIR=`mktemp -d`
ROOT_FS_TAR=${BUILD_DIR}/rootfs.tar.xz

# privileged:
mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

apt-get update
apt-get install -y qemu-user-static debootstrap binfmt-support xz-utils

debootstrap\
 --variant=minbase\
 --arch=armhf\
 --components=main\
 --include=inetutils-ping,iproute2,xz-utils,bzip2,unzip,psmisc\
 --foreign\
 ${DISTRO} ${DEBOOTSTRAP_DIR} ${DEBIAN_MIRROR}

cp /usr/bin/qemu-arm-static ${DEBOOTSTRAP_DIR}/usr/bin/
chroot ${DEBOOTSTRAP_DIR} /bin/bash -c "/debootstrap/debootstrap --second-stage\
 && apt-get clean\
 && rm -rf /var/lib/apt/lists/*\
 && echo \"deb ${DEBIAN_MIRROR} jessie main\" > /etc/apt/sources.list"

mkdir -p ${DEBOOTSTRAP_DIR}/etc
cat > ${DEBOOTSTRAP_DIR}/etc/resolv.conf <<'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

touch "${ROOT_FS_TAR}"

(
    set -x
    tar --numeric-owner -caf "${ROOT_FS_TAR}" -C "${DEBOOTSTRAP_DIR}" --transform='s,^./,,' .
)
