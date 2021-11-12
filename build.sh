#! /bin/bash
# shellcheck disable=SC2154
 # Script For Building Android arm64 Kernel
 #
 # Copyright (c) 2018-2021 Panchajanya1999 <rsk52959@gmail.com>
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 #      http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #
 
#Kernel building script

# Function to show an informational message
msg() {
	echo
    echo -e "\e[1;32m$*\e[0m"
    echo
}

err() {
    echo -e "\e[1;41m$*\e[0m"
}

cdir() {
	cd "$1" 2>/dev/null || \
		err "The directory $1 doesn't exists !"
}

##------------------------------------------------------##
##----------Basic Informations, COMPULSORY--------------##

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

JENIS=CAF

VARIAN=LTO
# Build Type
BUILD_TYPE="Nightly"

# Specify compiler.
# 'clang' or 'clangxgcc' or 'gcc' or 'gcc49'
COMPILER=gcc

# Message on anykernel when installation
MESSAGE="don't blame me if u get poor battery backup or weak performance . i'm not responsible . Do with Your Own Risk."

# Kernel is LTO
LTO=0

# Specify linker.
# 'ld.lld'(default)
LINKER=ld.lld

# Clean source prior building. 1 is NO(default) | 0 is YES
INCREMENTAL=1

# Push ZIP to Telegram. 1 is YES | 0 is NO(default)
PTTG=1
	if [ $PTTG = 1 ]
	then
		# Set Telegram Chat ID
		CHATID=$TG_CHAT_ID
	fi

# Generate a full DEFCONFIG prior building. 1 is YES | 0 is NO(default)
DEF_REG=0

# Files/artifacts
FILES=Image.gz-dtb

# Build dtbo.img (select this only if your source has support to building dtbo.img)
# 1 is YES | 0 is NO(default)
BUILD_DTBO=0

# Sign the zipfile
# 1 is YES | 0 is NO
SIGN=1
	if [ $SIGN = 1 ]
	then
		#Check for java
		if command -v java > /dev/null 2>&1; then
			SIGN=1
		else
			SIGN=0
		fi
	fi

# Silence the compilation
# 1 is YES(default) | 0 is NO
SILENCE=0

# Debug purpose. Send logs on every successfull builds
# 1 is YES | 0 is NO(default)
LOG_DEBUG=1

##------------------------------------------------------##
##---------Do Not Touch Anything Beyond This------------##

# Check if we are using a dedicated CI ( Continuous Integration ), and
# set KBUILD_BUILD_VERSION and KBUILD_BUILD_HOST and CI_BRANCH

#Check Kernel Version
LINUXVER=$(make kernelversion)

# Set a commit head
COMMIT_HEAD=$(git log --pretty=format:'%s' -n1)

# Set Date
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d_%H%M")
DATE2=$(TZ=Asia/Jakarta date +"%Y%m%d")
#Now Its time for other stuffs like cloning, exporting, etc

 clone() {
	echo " "
	if [ $COMPILER = "clang" ]
	then
		msg "|| Cloning toolchain ||"
		git clone --depth=1 https://github.com/fajar4561/SignatureTC_Clang -b master clang

	elif [ $COMPILER = "gcc49" ]
	then
		msg "|| Cloning GCC  ||"
		git clone --depth=1 https://github.com/Thoreck-project/aarch64-linux-android-4.9 $KERNEL_DIR/gcc64
		git clone --depth=1 https://github.com/Thoreck-project/arm-linux-androideabi-4.9 $KERNEL_DIR/gcc32
	elif [ $COMPILER = "gcc" ]
	then
		msg "|| Cloning GCC  ||"
		git clone https://github.com/fajar4561/gcc-arm64.git $KERNEL_DIR/gcc64 --depth=1
        git clone https://github.com/fajar4561/gcc-arm.git $KERNEL_DIR/gcc32 --depth=1

	elif [ $COMPILER = "clangxgcc" ]
	then
		msg "|| Cloning toolchain ||"
		git clone --depth=1 https://github.com/Thoreck-project/DragonTC -b 10.0 clang

		msg "|| Cloning GCC ||"
		git clone --depth=1 https://github.com/Thoreck-project/aarch64-linux-gnu-gcc9.git -b stable-gcc gcc64
		git clone --depth=1 https://github.com/Thoreck-project/arm-linux-gnueabi-gcc9.git -b stable-gcc gcc32
	fi

	# Toolchain Directory defaults to clang-llvm
		TC_DIR=$KERNEL_DIR/clang

	# GCC Directory
		GCC64_DIR=$KERNEL_DIR/gcc64
		GCC32_DIR=$KERNEL_DIR/gcc32

	msg "|| Cloning Anykernel ||"
        git clone https://github.com/fajar4561/Anykernel.git -b master AnyKernel3

	if [ $BUILD_DTBO = 1 ]
	then
		msg "|| Cloning libufdt ||"
		git clone https://android.googlesource.com/platform/system/libufdt "$KERNEL_DIR"/scripts/ufdt/libufdt
	fi
}

##----------------------------------------------------------##

# Function to replace defconfig versioning
setversioning() {
    # For staging branch
    KERNELNAME="$NAMA-$JENIS-$VARIAN-$LINUXVER-$DATE"
    # Export our new localversion and zipnames
    export KERNELNAME
    export ZIPNAME="$KERNELNAME.zip"
}

##--------------------------------------------------------------##

exports() {
	export KBUILD_BUILD_USER="Nobody"
    export KBUILD_BUILD_HOST="Unknown"
    export KBUILD_BUILD_VERSION="1"
	export ARCH=arm64
	export SUBARCH=arm64

	if [ $COMPILER = "clang" ]
	then
		KBUILD_COMPILER_STRING=$("$TC_DIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
		PATH=$TC_DIR/bin/:$PATH
	elif [ $COMPILER = "clangxgcc" ]
	then
		KBUILD_COMPILER_STRING=$("$TC_DIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
		PATH=$TC_DIR/bin:$GCC64_DIR/bin:$GCC32_DIR/bin:/usr/bin:$PATH
	elif [ $COMPILER = "gcc49" ]
	then
		KBUILD_COMPILER_STRING=$("$GCC64_DIR"/bin/aarch64-linux-android-gcc --version | head -n 1)
		PATH=$GCC64_DIR/bin/:$GCC32_DIR/bin/:/usr/bin:$PATH
	elif [ $COMPILER = "gcc" ]
	then
		KBUILD_COMPILER_STRING=$("$GCC64_DIR"/bin/aarch64-elf-gcc --version | head -n 1)
		PATH=$GCC64_DIR/bin/:$GCC32_DIR/bin/:/usr/bin:$PATH
	fi

	if [ $LTO = "1" ];then
		export LD=ld.lld
        export LD_LIBRARY_PATH=$TC_DIR/lib
	fi

	export PATH KBUILD_COMPILER_STRING
	TOKEN=$TG_TOKEN
	PROCS=$(nproc --all)
	export PROCS
	BOT_MSG_URL="https://api.telegram.org/bot$TOKEN/sendMessage"
	BOT_BUILD_URL="https://api.telegram.org/bot$TOKEN/sendDocument"
	PROCS=$(nproc --all)

	export KBUILD_BUILD_USER ARCH SUBARCH PATH \
		KBUILD_COMPILER_STRING BOT_MSG_URL \
		BOT_BUILD_URL PROCS TOKEN
}

##---------------------------------------------------------##

tg_post_msg() {
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="$CHATID" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"

}

##---------------------------------------------------------##

tg_post_build() {
	#Post MD5Checksum alongwith for easeness
	MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

	#Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="$CHATID"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$2 | <b>MD5 Checksum : </b><code>$MD5CHECK</code>"
}

##----------------------------------------------------------##

##----------------------------------------------------------------##

tg_send_sticker() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendSticker" \
        -d sticker="$1" \
        -d chat_id="$CHATID"
}

##----------------------------------------------------------------##

tg_send_files(){
    KernelFiles="$KERNEL_DIR/AnyKernel3/$ZIP_RELEASE.zip"
	MD5CHECK=$(md5sum "$KernelFiles" | cut -d' ' -f1)
	SID="CAACAgUAAx0CR6Ju_gADT2DeeHjHQGd-79qVNI8aVzDBT_6tAAK8AQACwvKhVfGO7Lbi7poiIAQ"
	STICK="CAACAgUAAx0CR6Ju_gADT2DeeHjHQGd-79qVNI8aVzDBT_6tAAK8AQACwvKhVfGO7Lbi7poiIAQ"
    MSG="✅ <b>Build Done</b>
- <code>$((DIFF / 60)) minute(s) $((DIFF % 60)) second(s) </code>

<b>Build Type</b>
-<code>$BUILD_TYPE</code>

<b>MD5 Checksum</b>
- <code>$MD5CHECK</code>

<b>Zip Name</b>
- <code>$ZIP_RELEASE</code>"

        curl --progress-bar -F document=@"$KernelFiles" "https://api.telegram.org/bot$TOKEN/sendDocument" \
        -F chat_id="$CHATID"  \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$MSG"

			tg_send_sticker "$SID"
}

##----------------------------------------------------------##

build_kernel() {
	if [ $INCREMENTAL = 0 ]
	then
		msg "|| Cleaning Sources ||"
		make clean && make mrproper && rm -rf out
	fi

	if [ $SILENCE = "1" ]
	then
		MAKE+=( -s )
	fi

	msg "|| Started Compilation ||"
	make O=out $DEFCONFIG
	if [ $DEF_REG = 1 ]
	then
		cp .config arch/arm64/configs/$DEFCONFIG
		git add arch/arm64/configs/$DEFCONFIG
		git commit -m "$DEFCONFIG: Regenerate
						This is an auto-generated commit"
	fi

	BUILD_START=$(date +"%s")

	if [ $COMPILER = "clang" ]
	then
		make -j"$PROCS" O=out \
		CC=clang \
		CROSS_COMPILE=aarch64-linux-gnu- \
	    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
	    AR=llvm-ar \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        CLANG_TRIPLE=aarch64-linux-gnu- \
		STRIP=llvm-strip "${MAKE[@]}" 2>&1 | tee build.log
	elif [ $COMPILER = "gcc49" ]
	then
		make -j"$PROCS" O=out \
				CROSS_COMPILE_ARM32=arm-linux-androideabi- \
				CROSS_COMPILE=aarch64-linux-android- "${MAKE[@]}" 2>&1 | tee build.log
	elif [ $COMPILER = "gcc" ]
	then
		make -j"$PROCS" O=out \
				CROSS_COMPILE_ARM32=arm-eabi- \
				CROSS_COMPILE=aarch64-elf- \
				AR=aarch64-elf-ar \
				OBJDUMP=aarch64-elf-objdump \
				STRIP=aarch64-elf-strip  \
				LD="ld.lld" "${MAKE[@]}" 2>&1 | tee build.log
	elif [ $COMPILER = "clangxgcc" ]
	then
		make -j"$PROCS"  O=out \
					CC=clang \
					CROSS_COMPILE=aarch64-linux-gnu- \
					CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
					AR=llvm-ar \
                    NM=llvm-nm \
                    OBJCOPY=llvm-objcopy \
                    OBJDUMP=llvm-objdump \
                    CLANG_TRIPLE=aarch64-linux-gnu- \
				    STRIP=llvm-strip "${MAKE[@]}" 2>&1 | tee build.log
	fi

		BUILD_END=$(date +"%s")
		DIFF=$((BUILD_END - BUILD_START))

		if [ -f "$KERNEL_DIR"/out/arch/arm64/boot/$FILES ]
		then
			msg "|| Kernel successfully compiled ||"
			if [ $BUILD_DTBO = 1 ]
			then
				msg "|| Building DTBO ||"
				tg_post_msg "<code>Building DTBO..</code>"
				python2 "$KERNEL_DIR/scripts/ufdt/libufdt/utils/src/mkdtboimg.py" \
					create "$KERNEL_DIR/out/arch/arm64/boot/dtbo.img" --page_size=4096 "$KERNEL_DIR/out/arch/arm64/boot/dts/$DTBO_PATH"
			fi
				gen_zip
			else
			if [ "$PTTG" = 1 ]
 			then
				tg_post_build "build.log" "<b>Build failed to compile after $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds</b>"
			fi
		fi

}

##--------------------------------------------------------------##

gen_zip() {
	msg "|| Zipping into a flashable zip ||"
	mv "$KERNEL_DIR"/out/arch/arm64/boot/Image.gz-dtb AnyKernel3/Image.gz-dtb
	if [ $BUILD_DTBO = 1 ]
	then
		mv "$KERNEL_DIR"/out/arch/arm64/boot/dtbo.img AnyKernel3/dtbo.img
	fi
	cd AnyKernel3 || exit
        cp -af anykernel-real.sh anykernel.sh
	sed -i "s/kernel.string=.*/kernel.string=$NAMA-$VARIAN/g" anykernel.sh
	sed -i "s/kernel.for=.*/kernel.for=$JENIS/g" anykernel.sh
	sed -i "s/kernel.compiler=.*/kernel.compiler=$KBUILD_COMPILER_STRING/g" anykernel.sh
	sed -i "s/kernel.made=.*/kernel.made=$KBUILD_BUILD_USER@$KBUILD_BUILD_HOST/g" anykernel.sh
	sed -i "s/kernel.version=.*/kernel.version=$LINUXVER/g" anykernel.sh
	sed -i "s/message.word=.*/message.word=$MESSAGE/g" anykernel.sh
	sed -i "s/build.date=.*/build.date=$DATE2/g" anykernel.sh


	zip -r9 "$ZIPNAME" * -x .git README.md anykernel-real.sh .gitignore zipsigner* *.zip

	## Prepare a final zip variable
	ZIP_FINAL="$ZIPNAME"
	
	curl --progress-bar -F document=@"$ZIPNAME" "https://api.telegram.org/bot$TOKEN/sendDocument" \
        -F chat_id="$CHATID"  \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="✅<b>Build Done</b>
        - <code>$((DIFF / 60)) minute(s) $((DIFF % 60)) second(s) </code>
        
        <b>Date 📅 </b>
        -<code>$DATE2</code>
        
        <b>Linux Version 📜</b>
        -<code>$LINUXVER</code>
        
         <b>Compiler 💻 </b>
        -<code>$KBUILD_COMPILER_STRING</code>
        
        <b>Device 📱 </b>
        -<code>$DEVICE ($MANUFACTURERINFO)</code>

        <b>Changelog 📣 </b>
        - <code>$COMMIT_HEAD</code>
        <b></b>
        #$BUILD_TYPE #$JENIS #$VARIAN"
        
	cd ..
}

setversioning
clone
exports
build_kernel
if [ $LOG_DEBUG = "1" ]
then
	tg_post_build "build.log" "$CHATID" "<b>Build failed to compile after $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds</b>"
fi

##----------------*****-----------------------------##
