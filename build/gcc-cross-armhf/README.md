GCC cross-compile-compile
=========================

## Preparations

    docker run -it --rm -v `pwd`:/usr/src/gcccross gcc:4.8 /bin/bash

    apt-get update
    apt-get install make gawk bison
    mkdir -p /opt/cross
    export PATH=/opt/cross/bin:$PATH

    wget http://mirror.switch.ch/ftp/mirror/gnu/binutils/binutils-2.25.tar.bz2
    wget http://mirrors.kernel.org/pub/linux/kernel/v3.x/linux-3.18.10.tar.xz
    wget http://ftpmirror.gnu.org/glibc/glibc-2.19.tar.xz

    # USE *.tar.*?
    tar xvf binutils-2.25.tar.bz2
    tar xvf linux-3.18.10.tar.xz
    tar xvf glibc-2.19.tar.xz

## Build binutils

    binutils_build_dir="$(mktemp -d)" && pushd $binutils_build_dir\
     && /usr/src/gcccross/binutils-2.25/configure --prefix=/opt/cross --target=arm-linux-gnueabihf --disable-multilib\
     && make MAKEINFO=true -j4\
     && make MAKEINFO=true install\
     && popd
    rm -Rf $binutils_build_dir

## Build Kernel Headers

Needed only when builing C standard library.

    pushd linux-3.18.10\
     && make ARCH=arm INSTALL_HDR_PATH=/opt/cross/arm-linux-gnueabihf headers_install\
     && popd

## C/C++ Compilers

    gcc_build_dir="$(mktemp -d)" && pushd $gcc_build_dir\
     && /usr/src/gcc/configure\
      --prefix=/opt/cross\
      --target=arm-linux-gnueabihf\
      --enable-languages=c,c++\
      --with-system-zlib\
      --with-arch=armv7-a\
      --with-fpu=vfpv3-d16\
      --with-float=hard\
      --disable-multilib\
     && make -j4 all-gcc\
     && make install-gcc\
     && popd

## Standard C Library Headers and Startup Files

    glibc_build_dir="$(mktemp -d)" && pushd $glibc_build_dir\
     && /usr/src/gcccross/glibc-2.19/configure\
      --prefix=/opt/cross/arm-linux-gnueabihf\
      --build=$MACHTYPE\
      --host=arm-linux-gnueabihf\
      --target=arm-linux-gnueabihf\
      --with-headers=/opt/cross/arm-linux-gnueabihf/include\
      --disable-multilib libc_cv_forced_unwind=yes\
     && make install-bootstrap-headers=yes install-headers\
     && make -j4 csu/subdir_lib\
     && install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross/arm-linux-gnueabihf/lib\
     && arm-linux-gnueabihf-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross/arm-linux-gnueabihf/lib/libc.so\
     && touch /opt/cross/arm-linux-gnueabihf/include/gnu/stubs.h\
     && popd

## Compiler Support Library

    pushd $gcc_build_dir\
     && make -j4 all-target-libgcc\
     && make install-target-libgcc\
     && popd

## Standard C Library

    pushd $glibc_build_dir\
     && make -j4\
     && make install\
     && popd

## Standard C++ Library

    pushd $gcc_build_dir\
     && make -j4\
     && make install\
     && popd

## Clean up

    rm -Rf $gcc_build_dir $glibc_build_dir


## References

+ [Old cross compiling manual with examples](https://www.ailis.de/~k/archives/19-ARM-cross-compiling-howto.html)
+ [OSDEV GCC Cross Compiler Pages](http://wiki.osdev.org/GCC_Cross-Compiler)
+ [Preshing: How to Build a GCC Cross-Compiler](http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/)

Postgresql Cross Compile
========================

    wget https://ftp.postgresql.org/pub/source/v9.4.1/postgresql-9.4.1.tar.bz2
    tar xvf postgresql-9.4.1.tar.bz2


    postgresql_build_dir="$(mktemp -d)" && pushd $postgresql_build_dir\
     && CC=arm-linux-gnueabihf-gcc /usr/src/gcccross/postgresql-9.4.1/configure\
      --host=arm-linux-gnueabihf\
      --without-zlib\
      --without-readline\
      --disable-spinlocks\
      --enable-depend\
     && make -j4
