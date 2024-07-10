#! /bin/bash

# Kernel Repo
KERNEL_REPO=https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/fajar4561/sunfish_kernel

# Kernel Branch
KERNEL_BRANCH=3

# The name of the device for which the kernel is built
MODEL="Google Pixel 4a"

# The codename of the device
DEVICE="Sunfish"

# The defconfig which should be used. Get it from config.gz from
# your device or check source
DEFCONFIG=blu_spark_defconfig

# Show manufacturer info
MANUFACTURERINFO="ASUSTek Computer Inc."

# tambahkan changelog di anykernel
CHANGELOGS=n

# opsi spectrum "y" atau "n"
SPECTRUM=n

# Kernel Variant

HMP=y

NAMA=Signature

JENIS=I

VARIAN=Beta

# Build Type
BUILD_TYPE="Nightly"

# Specify compiler.
# 'clang' or 'clangxgcc' or 'gcc' or 'gcc49' , 'linaro & 'gcc2', clang2
COMPILER=clang

# Message on anykernel when installatio
MESSAGE="just flash and forget"

# KBUILD ENV
K_USER=Thoreck
K_HOST=Github
K_VERSION=1


# arch & subarch
K_ARCH=arm64
K_SUBARCH=arm64
