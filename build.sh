#!/bin/bash

# setup color
red='\033[0;31m'
green='\e[0;32m'
white='\033[0m'
yellow='\033[0;33m'

WORK_DIR=$(pwd)
KERN_IMG="${WORK_DIR}/out/arch/arm64/boot/Image-gz.dtb"
KERN_IMG2="${WORK_DIR}/out/arch/arm64/boot/Image.gz"

# PATH toolchain GCC 4.9 (pakai path relatif, aman untuk GitHub Actions)
TC64="$(pwd)/linegcc49/bin/aarch64-linux-android-"
TC32="$(pwd)/linegcc49/bin/arm-linux-androideabi-"

function build_kernel() {
    echo -e "\n"
    echo -e "$yellow << building kernel >> \n$white"
    echo -e "\n"

    START_TIME=$(date +%s)

    rm -rf out

    make -j$(nproc --all) O=out ARCH=arm64 rolex_defconfig

    make -j$(nproc --all) ARCH=arm64 O=out \
        CROSS_COMPILE=${TC64} \
        CROSS_COMPILE_ARM32=${TC32} \
        CROSS_COMPILE_COMPAT=${TC32}

    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))

    if [ -e "$KERN_IMG" ] || [ -e "$KERN_IMG2" ]; then
        echo -e "\n"
        echo -e "$green << compile kernel success! >>$white"
        echo -e "$yellow Waktu build: $BUILD_TIME detik $white\n"
    else
        echo -e "\n"
        echo -e "$red << compile kernel failed! >>$white"
        echo -e "$yellow Waktu build: $BUILD_TIME detik $white\n"
    fi
}

# execute
build_kernel
