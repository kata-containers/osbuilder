#!/bin/bash
#
# Copyright (c) 2018 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

cidir=$(dirname "$0")
bash "${cidir}/static-checks.sh"

#Note: If add clearlinux as supported CI use a stateless os-release file
source /etc/os-release

if [ "$ID" == fedora ];then
	sudo -E dnf -y install automake bats yamllint coreutils moreutils
elif [ "$ID" == centos ];then
	sudo -E dnf -y install automake yamllint coreutils moreutils

	echo "Installing BATS from sources"
	go get -d github.com/sstephenson/bats || true
	pushd $GOPATH/src/github.com/sstephenson/bats
	sudo -E PATH=$PATH sh -c "./install.sh /usr"
	popd
elif [ "$ID" == ubuntu ];then
	#bats isn't available for Ubuntu trusty, need for travis
	sudo add-apt-repository -y ppa:duggan/bats
	sudo apt-get -qq update
	sudo apt-get install -y -qq automake bats qemu-utils python-pip coreutils moreutils
	sudo pip install yamllint
else 
	echo "Linux distribution not supported"
fi
