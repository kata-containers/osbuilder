#
# Copyright (c) 2018 SUSE LLC
#
# SPDX-License-Identifier: Apache-2.0

# List of distros not to test, when running all tests with test_images.sh
typeset -a skipWhenTestingAll
typeset -a test_distros
arch="$(uname -m)"
sdir="${BASH_SOURCE[0]%/*}"
for distro in $(${sdir}/../rootfs-builder/rootfs.sh -l); do
	test_distros+=("${distro}")
done

skipForRustDistros=()
skipForRustDistros+=("alpine")
skipForRustDistros+=("euleros")

skipForRustArch=()
skipForRustArch+=("ppc64le")
skipForRustArch+=("s390x")

distro_in_set() {
	local d=$1
	shift
	local dt
	for dt in "$@"; do
		if [ "${dt}" == "${d}" ]; then
			return 0
		fi
	done
	return 1
}

if [ -n "${CI:-}" ]; then
	if [ "${RUST_AGENT:-}" == "yes" ]; then
		# add skipForRustDistros to skipWhenTestingAll if it is not
		for td in "${skipForRustDistros[@]}"; do
			if distro_in_set "${td}" "${skipWhenTestingAll[@]}"; then
				continue
			fi
			# not found in skipWhenTestingAll, add to it
			skipWhenTestingAll+=("${td}")
		done

		if distro_in_set "${arch}" "${skipForRustArch[@]}"; then
			for distro in "${test_distros[@]}"; do
				if distro_in_set "${distro}" "${skipWhenTestingAll[@]}"; then
					continue
				fi
				skipWhenTestingAll+=("${distro}")
			done
		fi
	fi
fi
