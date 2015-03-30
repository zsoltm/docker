FROM buildpack-deps:jessie

# https://gcc.gnu.org/mirrors.html
RUN gpg --keyserver pool.sks-keyservers.net --recv-key \
    B215C1633BCA0477615F1B35A5B3A004745C015A \
    B3C42148A44E6983B3E4CC0793FA9B1AB75C61B8 \
    90AA470469D3965A87A5DCB494D03953902C9419 \
    80F98B2E0DAB6C8281BDF541A7C8C3B2F71EDF1C \
    7F74F97C103468EE5D750B583AB00996FC26A641 \
    33C235A34C46AA3FFB293709A328C3A2C3C45C06

ENV GCC_VERSION 4.9.2
ENV INFRASTRUCTURE_MIRROR http://www.mirrorservice.org/sites/sourceware.org/pub/gcc
ENV RELEASE_MIRROR http://ftpmirror.gnu.org/gcc/

ADD download_prerequisites.sh /opt/

# "download_prerequisites" pulls down a bunch of tarballs and extracts them,
# but then leaves the tarballs themselves lying around
RUN apt-get update \
    && apt-get install -y curl flex wget \
    && rm -r /var/lib/apt/lists/* \
    && echo Downloading gcc $GCC_VERSION from $RELEASE_MIRROR\
    && curl -SL "$RELEASE_MIRROR/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2" -o gcc.tar.bz2 \
    && curl -SL "$RELEASE_MIRROR/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2.sig" -o gcc.tar.bz2.sig \
    && gpg --verify gcc.tar.bz2.sig \
    && mkdir -p /usr/src/gcc \
    && tar -xvf gcc.tar.bz2 -C /usr/src/gcc --strip-components=1 \
    && rm gcc.tar.bz2* \
    && cd /usr/src/gcc \
    && /opt/download_prerequisites.sh \
    && { rm *.tar.* || true; } \
    && dir="$(mktemp -d)" \
    && cd "$dir" \
    && /usr/src/gcc/configure \
	--disable-multilib \
	--enable-languages=c,c++ \
    && make -j"$(nproc)" \
    && make install-strip \
    && cd .. \
    && rm -rf "$dir" \
    && apt-get purge -y --auto-remove curl gcc g++ wget
