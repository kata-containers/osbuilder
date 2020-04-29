#!/bin/bash
#
# Copyright (c) 2020 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

set -e
set -u

# NOTE: Some env variables are set in the Dockerfile - those that are
# intended to be over-rideable.
QAT_SRC=~/src/QAT
export GOPATH=~/src/go
export PATH=${PATH}:/usr/local/go/bin:${GOPATH}/bin

packagerepo=github.com/kata-containers/packaging
packagerepopath=${GOPATH}/src/${packagerepo}

osbrepo=github.com/kata-containers/osbuilder
osbrepopath=${GOPATH}/src/${osbrepo}

testsrepo=github.com/kata-containers/tests
testsrepopath=${GOPATH}/src/${testsrepo}

runtimerepo=github.com/kata-containers/runtime
runtimerepopath=${GOPATH}/src/${runtimerepo}

agentrepo=github.com/kata-containers/agent
agentrepopath=${GOPATH}/src/${agentrepo}

grab_kata_repos()
{
	# Check out all the repos we will use now, so we can try and ensure they use the specified branch
	# Only check out the branch needed, and make it shallow and thus space/bandwidth efficient
	git clone --single-branch --branch $KATA_VERSION --depth=1 https://${packagerepo} ${packagerepopath}
	git clone --single-branch --branch $KATA_VERSION --depth=1 https://${osbrepo} ${osbrepopath}
	git clone --single-branch --branch $KATA_VERSION --depth=1 https://${testsrepo} ${testsrepopath}
	git clone --single-branch --branch $KATA_VERSION --depth=1 https://${runtimerepo} ${runtimerepopath}
	git clone --single-branch --branch $KATA_VERSION --depth=1 https://${agentrepo} ${agentrepopath}
}

configure_kernel()
{
	cp /input/qat.conf ${packagerepopath}/kernel/configs/fragments/common/qat.conf
	# We need yq and go to grab kernel versions etc.
	${testsrepopath}/.ci/install_yq.sh
	${testsrepopath}/.ci/install_go.sh -p
	cd ${packagerepopath}
	./kernel/build-kernel.sh setup
}

build_kernel()
{
	cd ${packagerepopath}
	LINUX_VER=$(ls -d kata-linux-*)
	sed -i 's/EXTRAVERSION =/EXTRAVERSION = .qat.container/' $LINUX_VER/Makefile
	./kernel/build-kernel.sh build
}

build_rootfs()
{
	cd ${osbrepopath}/rootfs-builder
	# We default to using clearlinux for the QAT rootfs
	SECCOMP=no EXTRA_PKGS='kmod' ./rootfs.sh clearlinux
}

grab_qat_drivers()
{
	mkdir -p $QAT_SRC
	cd $QAT_SRC
	curl -L $QAT_DRIVER_URL | tar zx
}

build_qat_drivers()
{
	cd ${packagerepopath}
	linux_kernel_path=${packagerepopath}/${LINUX_VER}
	KERNEL_MAJOR_VERSION=$(awk '/^VERSION =/{print $NF}' ${linux_kernel_path}/Makefile)
	KERNEL_PATHLEVEL=$(awk '/^PATCHLEVEL =/{print $NF}' ${linux_kernel_path}/Makefile)
	KERNEL_SUBLEVEL=$(awk '/^SUBLEVEL =/{print $NF}' ${linux_kernel_path}/Makefile)
	KERNEL_EXTRAVERSION=$(awk '/^EXTRAVERSION =/{print $NF}' ${linux_kernel_path}/Makefile)
	KERNEL_ROOTFS_DIR=${KERNEL_MAJOR_VERSION}.${KERNEL_PATHLEVEL}.${KERNEL_SUBLEVEL}${KERNEL_EXTRAVERSION}
	cd $QAT_SRC
	KERNEL_SOURCE_ROOT=${linux_kernel_path} ./configure ${QAT_COMPILE_OPTIONS}
	make qat-driver-all quickassist-all -j$(nproc)
}

add_qat_to_rootfs()
{
	cd $QAT_SRC
	ROOTFS_DIR=${osbrepopath}/rootfs-builder/rootfs-Clear
	make INSTALL_MOD_PATH=$ROOTFS_DIR qat-driver-install -j$(nproc)

	cp $QAT_SRC/build/usdm_drv.ko $ROOTFS_DIR/usr/lib/modules/${KERNEL_ROOTFS_DIR}/updates/drivers
	depmod -a -b ${ROOTFS_DIR} ${KERNEL_ROOTFS_DIR}
	cd ${osbrepopath}/image-builder
	./image_builder.sh ${ROOTFS_DIR}
}

copy_outputs()
{
	mkdir -p ${OUTPUT_DIR} || true
	cp ${linux_kernel_path}/arch/x86/boot/bzImage $OUTPUT_DIR/vmlinuz-${LINUX_VER}_qat
	cp ${osbrepopath}/image-builder/kata-containers.img $OUTPUT_DIR
	mkdir -p ${OUTPUT_DIR}/configs || true
	cp $QAT_SRC/quickassist/utilities/adf_ctl/conf_files/*.conf.vm ${OUTPUT_DIR}/configs
}

help() {
	cat << EOF
Usage: $0 [-h] [options]
   Description:
        This script builds kernel and rootfs artifacts for Kata Containers,
        configured and built to support QAT hardware.
   Options:
        -d,         Enable debug mode
        -h,         Show this help
EOF
}

main()
{
	local check_in_container=${OUTPUT_DIR:-}
	if [ -z "${check_in_container}" ]; then
		echo "Error: 'OUTPUT_DIR' not set" >&2
		echo "$0 should be run using the Dockerfile supplied." >&2
		exit -1
	fi

	local OPTIND
	while getopts "dh" opt;do
		case ${opt} in
		d)
		    set -x
		    ;;
		h)
		    help
		    exit 0;
		    ;;
		?)
		    # parse failure
		    help
		    echo "ERROR: Failed to parse arguments"
		    exit -1
		    ;;
		esac
	done
	shift $((OPTIND-1))

	grab_kata_repos
	configure_kernel
	build_kernel
	build_rootfs
	grab_qat_drivers
	build_qat_drivers
	add_qat_to_rootfs
	copy_outputs
}

main "$@"
