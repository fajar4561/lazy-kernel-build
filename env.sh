#! /bin/bash

# Kernel Repo
KERNEL_REPO=https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/fajar4561/Kernel_Asus_SDM660

# Kernel Branch
KERNEL_BRANCH=R2/hmp

# The name of the device for which the kernel is built
MODEL="Asus Zenfone Max Pro M1"

# The codename of the device
DEVICE="X00TD"

# The defconfig which should be used. Get it from config.gz from
# your device or check source
DEFCONFIG=X00TD_defconfig

# Show manufacturer info
MANUFACTURERINFO="ASUSTek Computer Inc."

# tambahkan changelog di anykernel
CHANGELOGS=y

# opsi spectrum "y" atau "n"
SPECTRUM=y

# Kernel Variant

HMP=y

NAMA=Signature

JENIS=IV-HMP

VARIAN=r2

# Build Type
BUILD_TYPE="Nightly"

# Specify compiler.
# 'clang' or 'clangxgcc' or 'gcc' or 'gcc49' , 'linaro & 'gcc2', clang2
COMPILER=gcc49

# Message on anykernel when installatio
MESSAGE="just flash and forget"

# KBUILD ENV
K_USER=Thoreck
K_HOST=Github
K_VERSION=1


# arch & subarch
K_ARCH=arm64
K_SUBARCH=arm64
