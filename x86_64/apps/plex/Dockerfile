FROM debian:jessie

ENV DEBIAN_FRONTEND="noninteractive"\
 LANG="en_US.UTF-8"\
 LC_ALL="C.UTF-8"\
 LANGUAGE="en_US.UTF-8"

ADD ./start.sh /start.sh

RUN echo "deb http://shell.ninthgate.se/packages/debian wheezy main" >> /etc/apt/sources.list\
 && echo '-----BEGIN PGP PUBLIC KEY BLOCK-----\nVersion: GnuPG v1.4.10 (GNU/Linux)\n'\
'\nmQENBE/VqlEBCADSISintDfmSFU0BkQKX2tojp/1DEXNZ6gjJbRB1yfoVMqsB2zJ'\
'\nB7td06slWvoDn+CGzj5Hxoerj7WZN95B4tX7XscdIIR9zAMR8L6Lsb416SOBIAmp'\
'\nY4SZgSAzYF88Xc/i/Ht1vI7UfkhuOzEHt2Vn8bws3jWmB+UuM2y6uKa1coXW4GxJ'\
'\nPUtwPcSYyX70e72RekowisCu5xG9Ooh0GB/OyvAz+2M3y/1xGLG8TzZy4SRy7sso'\
'\nUhZIYw/dCgDO8NOGiwEJVtallY52bJfIDKdcPkfgKRA3bxT2VS0USr8a3bscm7QL'\
'\nbQYGu++BIAPCdPgpeSueJS8vuqTOn6kzHLMTABEBAAG0NUNocmlzdGlhbiBTdmVk'\
'\naW4gKGd1cmthKSA8Y2hyaXN0aWFuLnN2ZWRpbkBnbWFpbC5jb20+iQE4BBMBAgAi'\
'\nBQJP1apRAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRDmOb/LcnQBmeVa'\
'\nB/wNYufEgKMmExhDljmPhFsbSCW43Ga0O09a3M0GpKOxV5CzH1VeVTFYOEH7yCvi'\
'\n1sEHvBMAWSDCrEcj7m/mlr+6CIsOqxWvgELKG8yGvg9hxxIrfHkGWQPpt+aSO3hC'\
'\nIdi2jrsDkZpSRcwDeyiqsbxlswZCVYJsaCIFlCKlwG1aGMU04v5sLUOTeIQ9iVvH'\
'\nim21abDmpP91j9VqGu98v9K0pTrCdgcsQ18EPAi4XCiVQRTXaFL/yzNb+SMMDFDd'\
'\n4Z78qXOQVk4sD3fR6WUKmi5SRmLfYDaPh3IYSubNxHaP/R1Gwte+kwvZ00PoVt32'\
'\nnlD6CRh9tBgHPEiTCryRqim6uQENBE/VqlEBCACeQtmqhTukZNR8CZk11RhnRgdP'\
'\njILrEqDE6vZoUgxX4acMX56QFTxYWDpaPMKKxibWZej07JTiVO00dOD7gR5jo1u5'\
'\npiE6yIymLkMv3EcEN2XZqkDMuDmV66gXpZoKSQAWD6CmQrLUZvVra2O30zSZchBG'\
'\nkL0m9MDiv2U31QEbPEFBoPjI/jHouQUSVxWa14JEKqdG5EZZ0/x2zIvJgZzVejjH'\
'\n3YIlxGuDYMsGcAvqwiK26THnh0OyWD9KXch5VmiZSDFEfcCYzHH51VYFG8R/LQsW'\
'\naJsK9Tl1Fp7O+JzLEPX6QRWMutZdkXClVH2JqCLa3QAuCX6+X+93levnnS8vABEB'\
'\nAAGJAR8EGAECAAkFAk/VqlECGwwACgkQ5jm/y3J0AZmxSgf/QpuBZ47OFa/e1QkE'\
'\nlpyH0h1SiHiql+0M1lzsWMcG20ylYe8mqdTTA6VC4Y97gCvD5fAHtw5BPkSFuDAO'\
'\nQ0ec3WcJHwNilg7iGLbgp42AAKZuIz/VJahxl07h4mjiI7KXhJ7oQDX8G0vE4tCi'\
'\nX8xKA8QE6vhspAygCBJZjkgV81B7JcM66YBXf/xdkhIiJaLhXWhQAIqj6hDemH6V'\
'\nO5ipY1ws2W90lntxtR8uIjWhqspfH5jEH5cqnSji2nGkWx2cx33ctVxnwvzq7rQe'\
'\n1EtGs2Pbvrm+TYYw+OVI4xtLff9qhUVcQnA57+sfrlgCYseilW7Swf+LbesopNYc'\
'\n78QPnA=='\
'\n=oJJu'\
'\n-----END PGP PUBLIC KEY BLOCK-----\n' | apt-key add -\
 && apt-get -q update\
 && apt-get install -qy --force-yes plexmediaserver\
 && apt-get clean\
 && /etc/init.d/dbus stop\
 && /etc/init.d/avahi-daemon stop\
 && /etc/init.d/plexmediaserver stop\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /var/lib/plexmediaserver
VOLUME /media

EXPOSE 32400

CMD ["/start.sh"]
