#!/bin/bash
#
# Copyright (c) 2018 Yash Jain
#
# SPDX-License-Identifier: Apache-2.0

set -e

check_program(){
	type "$1" >/dev/null 2>&1
}



build_rootfs()
{
	# Mandatory
	local ROOTFS_DIR=$1

	# In case of support EXTRA packages, use it to allow
	# users add more packages to the base rootfs
	local EXTRA_PKGS=${EXTRA_PKGS:-""}


	check_root
	mkdir -p "${ROOTFS_DIR}"

	if [ -n "${PKG_MANAGER}" ]; then
		info "debootstrap path provided by user: ${PKG_MANAGER}"
	elif check_program $DEBOOTSTRAP ; then
		PKG_MANAGER=$DEBOOTSTRAP
	else
		die "$DEBOOTSTRAP is not installed"
	fi

    # trim whitespace
    PACKAGES=$(echo $PACKAGES |xargs )
    EXTRA_PKGS=$(echo $EXTRA_PKGS |xargs)

    # add comma as debootstrap needs , separated package names.
    # Don't change $PACKAGES in config.sh to include ','
    # This is done to maintain consistency
    PACKAGES=$(echo $PACKAGES | sed  -e 's/ /,/g' )
    EXTRA_PKGS=$(echo $EXTRA_PKGS | sed  -e 's/ /,/g' )

    # extra packages are added to packages and finally passed to debootstrap
    if [ "${EXTRA_PKGS}" = "" ]; then
        echo "no extra packages"
    else
        PACKAGES="${PACKAGES},${EXTRA_PKGS}"
    fi

    ${PKG_MANAGER} --variant=minbase \
                --arch="${ARCH}" \
                --include="$PACKAGES" \
                "${OS_NAME}" \
                "${ROOTFS_DIR}"\
                "${ARCHIVE_URL}"
}


check_root()
{
	if [ "$(id -u)" != "0" ]; then
		echo "Root is needed"
		exit 1
	fi
}
