#
# Copyright (c) 2018 Luis Chamberlain <mcgrof@kernel.org>
#
# SPDX-License-Identifier: Apache-2.0

OS_NAME="Debian"

OS_VERSION=${OS_VERSION:-testing}

# If set, we'll use this to do the debootstrap. The sources.list
# file however will get MIRROR_LIST. If you want to use the local
# mirror for both set both to the same value. To set up a local
# mirror look at apt-move.
LOCAL_FILE_MIRROR=""
MIRROR_LIST="http://mirrors.edge.kernel.org/debian/"

PACKAGES="iptables"
