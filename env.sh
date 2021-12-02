#! /bin/bash

# Kernel Repo
KERNEL_REPO=https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/fajar4561/Kernel_Asus_SDM660

# Kernel Branch
KERNEL_BRANCH=master

# The defult directory where the kernel should be placed
KERNEL_DIR=$PWD

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

JENIS=HMP

VARIAN=Part_III

# Build Type
BUILD_TYPE="Nightly"

# Specify compiler.
# 'clang' or 'clangxgcc' or 'gcc' or 'gcc49'
COMPILER=gcc49

# Message on anykernel when installation
MESSAGE="S I G N A T U R I F Y"