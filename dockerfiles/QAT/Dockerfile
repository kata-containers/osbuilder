# Copyright (c) 2020 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

# Kata osbuilder 'works best' on Fedora
FROM fedora:latest

# Version of the Dockerfile - update if you change this file to avoid 'stale'
# images being pulled from the registry.
LABEL DOCKERFILE_VERSION="1.0"

ENV QAT_DRIVER_VER qat1.7.l.4.9.0-00008.tar.gz
ENV QAT_DRIVER_URL https://01.org/sites/default/files/downloads/${QAT_DRIVER_VER}
ENV QAT_COMPILE_OPTIONS --disable-qat-lkcf --enable-icp-sriov=guest

ENV KATA_VERSION master
ENV OUTPUT_DIR /output

RUN dnf install -y \
    bc \
    bison \
    curl \
    diffutils \
    e2fsprogs \
    elfutils-libelf-devel \
    findutils \
    flex \
    gcc \
    gcc-c++ \
    git \
    kmod \
    openssl-devel \
    make \
    parted \
    patch \
    qemu-img \
    systemd-devel \
    sudo \
    xz

# Pull in our local files
COPY ./run.sh /input/
COPY ./qat.conf /input/

# Output is placed in the /output directory.
# We could make this a VOLUME to force it to be attached to the host, but let's
# just leave it as a container dir that can then be over-ridden from a host commandline
# volume setup.
# VOLUME /output

# By default build everything
CMD ["/input/run.sh"]
