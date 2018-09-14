#!/bin/bash
#
# Copyright (c) 2018 Luis Chamberlain <mcgrof@kernel.org>
#
# SPDX-License-Identifier: Apache-2.0

# - Arguments
# rootfs_dir=$1
#
# - Optional environment variables
#
# EXTRA_PKGS: Variable to add extra PKGS provided by the user
#
# BIN_AGENT: Name of the Kata-Agent binary
#
# Any other configuration variable for a specific distro must be added
# and documented on its own config.sh
#
# - Expected result
#
# rootfs_dir populated with rootfs pkgs
# It must provide a binary in /sbin/init
build_rootfs() {
	# Mandatory
	local ROOTFS_DIR=$1

	# In case of support EXTRA packages, use it to allow
	# users add more packages to the base rootfs
	local EXTRA_PKGS=${EXTRA_PKGS:-}

	# Populate ROOTFS_DIR
	check_root
	mkdir -p "${ROOTFS_DIR}"
	ADD_PKGS=""
	for i in ${EXTRA_PKGS} ; do
		if [ "$ADD_PKGS" = "" ]; then
			ADD_PKGS="$i"
		else
			ADD_PKGS="$ADD_PKGS,$i"
		fi
	done
	INCLUDE_EXTRA=""
	if [ "$ADD_PKGS" = "" ]; then
		INCLUDE_EXTRA="--include=$ADD_PKGS"
	fi

	DEBOOTSTRAP_MIRROR="$MIRROR_LIST"
	if [ "$LOCAL_FILE_MIRROR" != "" ]; then
		DEBOOTSTRAP_MIRROR="$LOCAL_FILE_MIRROR"
	fi

	/usr/sbin/debootstrap \
		$INCLUDE_EXTRA \
		${OS_VERSION} \
		$ROOTFS_DIR \
		$DEBOOTSTRAP_MIRROR

	mkdir -p ${ROOTFS_DIR}{/root,/etc/apt,/proc}
	echo "deb ${MIRROR}/${OS_VERSION} $OS_VERSION main contrib" >  ${ROOTFS_DIR}/etc/apt/sources.list
}
