#!/bin/bash

# ================= COLOR =================
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
white='\033[0m'

# ================= PATH =================
ROOTDIR=$(pwd)
OUTDIR="$ROOTDIR/out/arch/arm64/boot"
ANYKERNEL_DIR="$ROOTDIR/AnyKernel"

KIMG_DTB="$OUTDIR/Image-gz.dtb"
KIMG="$OUTDIR/Image.gz"

# ================= INFO =================
KERNEL_NAME="MyKernel"
DEVICE="rolex"
DATE=$(date +"%Y%m%d-%H%M")
ZIP_NAME="${KERNEL_NAME}-${DEVICE}-${DATE}.zip"

# ================= TOOLCHAIN =================
TC64="$ROOTDIR/linegcc49/bin/aarch64-linux-android-"
TC32="$ROOTDIR/linegcc49/bin/arm-linux-androideabi-"

# ================= FUNCTION =================
clone_anykernel() {
    if [ ! -d "$ANYKERNEL_DIR" ]; then
        echo -e "$yellow[+] Downloading AnyKernel...$white"
        git clone https://github.com/osm0sis/AnyKernel3.git "$ANYKERNEL_DIR" || exit 1
    fi
}

build_kernel() {
    echo -e "$yellow[+] Building kernel...$white"

    rm -rf out
    make O=out ARCH=arm64 rolex_defconfig

    make -j$(nproc) O=out ARCH=arm64 \
        CROSS_COMPILE=$TC64 \
        CROSS_COMPILE_ARM32=$TC32 \
        CROSS_COMPILE_COMPAT=$TC32
}

pack_kernel() {
    echo -e "$yellow[+] Packing AnyKernel...$white"

    clone_anykernel
    cd "$ANYKERNEL_DIR" || exit 1

    rm -f Image* *.zip

    if [ -f "$KIMG_DTB" ]; then
        cp "$KIMG_DTB" "$ANYKERNEL_DIR/Image-gz.dtb"
        IMG_USED="Image-gz.dtb"
    elif [ -f "$KIMG" ]; then
        cp "$KIMG" "$ANYKERNEL_DIR/Image.gz"
        IMG_USED="Image.gz"
    else
        echo -e "$red[-] Kernel image not found!$white"
        exit 1
    fi

    zip -r9 "$ZIP_NAME" . -x ".git*" "README.md"

    echo -e "$green[✓] Zip created: $ZIP_NAME ($IMG_USED)$white"
}

# ================= RUN =================
START=$(date +%s)

build_kernel
pack_kernel

END=$(date +%s)
echo -e "$green[✓] Done in $((END - START)) seconds$white"
