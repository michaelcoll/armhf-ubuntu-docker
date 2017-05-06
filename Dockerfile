# ARMHF Version of Ubuntu Base Image 
#
# VERSION               0.0.3

FROM scratch
MAINTAINER Michael COLL <mick.coll@gmail.com>

# ADD http://cdimage.ubuntu.com/ubuntu-base/releases/17.04/release/ubuntu-base-17.04-base-armhf.tar.gz /
ADD ubuntu-base-17.04-base-armhf.tar.gz /
# TODO: you need this in the local directory and setup in binfmt
# ADD qemu-aarch64-static /usr/bin/qemu-aarch64-static
# ADD qemu-arm-static /usr/bin/qemu-arm-static
# RUN chmod ugo+x /usr/bin/qemu-aarch64-static
# RUN chmod ugo+x /usr/bin/qemu-arm-static

# a few minor docker-specific tweaks
# see https://github.com/dotcloud/docker/blob/master/contrib/mkimage/debootstrap
RUN echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
    && echo 'exit 101' >> /usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d \
    \
    && dpkg-divert --local --rename --add /sbin/initctl \
    && cp -a /usr/sbin/policy-rc.d /sbin/initctl \
    && sed -i 's/^exit.*/exit 0/' /sbin/initctl \
    \
    && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
    \
    && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
    && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
    && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
    \
    && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
    \
    && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes

# delete all the apt list files since they're big and get stale quickly
RUN rm -rf /var/lib/apt/lists/*
# this forces "apt-get update" in dependent images, which is also good

# enable the universe
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list

# upgrade packages for now, since the tarballs aren't updated frequently enough
RUN apt-get update && apt-get dist-upgrade -y && rm -rf /var/lib/apt/lists/*

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/sh"]