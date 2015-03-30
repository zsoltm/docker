#! /bin/sh

GRAPHITE_LOOP_OPT=yes
MIRROR=ftp://gcc.gnu.org/pub/gcc

if [ ! -z ${INFRASTRUCTURE_MIRROR} ]; then
  MIRROR=${INFRASTRUCTURE_MIRROR}
fi


# Necessary to build GCC.
MPFR=mpfr-2.4.2
GMP=gmp-4.3.2
MPC=mpc-0.8.1

wget ${MIRROR}/infrastructure/$MPFR.tar.bz2 || exit 1
tar xjf $MPFR.tar.bz2 || exit 1
ln -sf $MPFR mpfr || exit 1

wget ${MIRROR}/infrastructure/$GMP.tar.bz2 || exit 1
tar xjf $GMP.tar.bz2  || exit 1
ln -sf $GMP gmp || exit 1

wget ${MIRROR}/infrastructure/$MPC.tar.gz || exit 1
tar xzf $MPC.tar.gz || exit 1
ln -sf $MPC mpc || exit 1

# Necessary to build GCC with the Graphite loop optimizations.
if [ "$GRAPHITE_LOOP_OPT" = "yes" ] ; then
  ISL=isl-0.12.2
  CLOOG=cloog-0.18.1

  wget ${MIRROR}/infrastructure/$ISL.tar.bz2 || exit 1
  tar xjf $ISL.tar.bz2  || exit 1
  ln -sf $ISL isl || exit 1

  wget ${MIRROR}/infrastructure/$CLOOG.tar.gz || exit 1
  tar xzf $CLOOG.tar.gz || exit 1
  ln -sf $CLOOG cloog || exit 1
fi

