#! /bin/bash

BUILD_DIR=/tmp/build
DEBOOTSTRAP_DIR=${BUILD_DIR}/debootstrap
ROOT_FS_TAR=${BUILD_DIR}/rootfs.tar.xz
mkdir -p ${DEBOOTSTRAP_DIR}

# privileged:
mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

apt-get update
apt-get install -y qemu-user-static debootstrap binfmt-support xz-utils

debootstrap\
 --variant=minbase\
 --arch=armhf\
 --components=main\
 --include=inetutils-ping,iproute2,xz-utils\
 --foreign\
 ${DISTRO} ${DEBOOTSTRAP_DIR} ${DEBIAN_MIRROR}

cp /usr/bin/qemu-arm-static ${DEBOOTSTRAP_DIR}/usr/bin/
chroot ${DEBOOTSTRAP_DIR}\
 /bin/bash -c "/debootstrap/debootstrap --second-stage && apt-get clean"
rm ${DEBOOTSTRAP_DIR}/usr/bin/qemu-arm-static

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

cp /usr/src/jessie/Dockerfile "${BUILD_DIR}"

rm -Rf "${DEBOOTSTRAP_DIR}"
