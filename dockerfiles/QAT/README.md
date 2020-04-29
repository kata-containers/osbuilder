
  * [Introduction](#introduction)
  * [Building](#building)
  * [Options](#options)

## Introduction

The files in this directory can be used to build a modified Kata Containers rootfs
and kernel with modifications to support Intel QAT hardware.

The generated files will need to be copied and configured into your Kata Containers
setup.

Please see the
[Kata QAT documentation](https://github.com/kata-containers/documentation/blob/master/use-cases/using-Intel-QAT-and-kata.md)
for more specific QAT details.

## Building

The image build and run are executed using Docker, from within this `QAT` folder. You
require **all** the files in this directory to build the Docker image:

```sh
$ docker build --label kataqat --tag kataqat:latest . 
$ mkdir ./output
$ docker run -ti --rm --privileged -v /dev:/dev -v $(pwd)/output:/output kataqat
```

> **Note:** The use of the `--privileged` and `-v /dev:/dev` arguments to the `docker run` are
> necessary, to enable the scripts within the container to generate a roofs file system.

When complete, the generated files will be placed into the output directory. Example QAT config
files are also placed into the `config` subdirectory for references. These files may need
modification before use, as documented in the Kata QAT
[use-case document](https://github.com/kata-containers/documentation/blob/master/use-cases/using-Intel-QAT-and-kata.md#copy-intel-qat-configuration-files-and-enable-virtual-functions):

```sh
# ls -lR output
output:
total 267316
drwxr-xr-x 2 root root      4096 Apr  6 14:02 configs
-rw-r--r-- 1 root root 268435456 Apr  6 14:02 kata-containers.img
-rw-r--r-- 1 root root   5284400 Apr  6 14:02 vmlinuz-kata-linux-5.4.15-71_qat

output/configs:
total 16
-rw-r--r-- 1 root root 4081 Apr  6 14:02 c3xxxvf_dev0.conf.vm
-rw-r--r-- 1 root root 4081 Apr  6 14:02 c6xxvf_dev0.conf.vm
-rw-r--r-- 1 root root 4081 Apr  6 14:02 d15xxvf_dev0.conf.vm
-rw-r--r-- 1 root root 4081 Apr  6 14:02 dh895xccvf_dev0.conf.vm
```

## Options

A number of parameters to the scripts are configured in the `Dockerfile`, and thus can be modified
on the commandline.


| Variable | Definition | Default value |
| -------- | ---------- | ------------- |
| KATA_VERSION | Kata Branch or Tag to build from | `master` |
| OUTPUT_DIR | Directory inside container where results are stored | `/output` |
| QAT_COMPILE_OPTIONS | `configure` options for QAT driver | `--disable-qat-lkcf --enable-icp-sriov=guest` |
| QAT_DRIVER_URL | URL to curl QAT driver from | `https://01.org/sites/default/files/downloads/${QAT_DRIVER_VER}` |
| QAT_DRIVER_VER | QAT driver version to use | `qat1.7.l.4.9.0-00008.tar.gz` |

Variables can be set on the `docker run` commandline, for example:

```sh
$ docker run -ti --rm --privileged -e "KATA_VERSION=1.11.0" -v /dev:/dev -v ${PWD}/output:/output kataqat
```
