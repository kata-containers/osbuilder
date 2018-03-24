#
# Copyright (c) 2018 Yash Jain
#
# SPDX-License-Identifier: Apache-2.0


# architecture to build the rootfs for
ARCH=${ARCH:-"amd64"}

# url to download rootfs from
ARCHIVE_URL=${ARCHIVE_URL:-"http://archive.ubuntu.com/ubuntu/"}

# this should be ubuntu's codename eg Xenial for 16.04
OS_NAME=${OS_NAME:-"xenial"}

# packages to be installed by default
PACKAGES="systemd iptables"

DEBOOTSTRAP=${PACKAGE_MANAGER:-"debootstrap"}