#! /bin/bash

# Kernel Repo
KERNEL_REPO=https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/fajar4561/Kernel_Asus_SDM660

# Kernel Branch
KERNEL_BRANCH=R1

# The name of the device for which the kernel is built
MODEL="Asus Zenfone Max Pro M1"

# The codename of the device
DEVICE="X00TD"

# The defconfig which should be used. Get it from config.gz from
# your device or check source
DEFCONFIG=X00TD_defconfig

# Show manufacturer info
MANUFACTURERINFO="ASUSTek Computer Inc."

# Kernel Variant
NAMA=Signature

JENIS=IV-R1

VARIAN=XPR

# Build Type
BUILD_TYPE="Nightly"

# Specify compiler.
# 'clang' or 'clangxgcc' or 'gcc' or 'gcc49' , 'linaro & 'gcc2', clang2
COMPILER=gcc49

# Message on anykernel when installatio
MESSAGE="Salam dari kota congyang"

# KBUILD ENV
K_USER=Thoreck
K_HOST=BOT_BUILDER
K_VERSION=636


# arch & subarch
K_ARCH=arm64
K_SUBARCH=arm64
