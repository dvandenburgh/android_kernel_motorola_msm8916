#
# Copyright � 2016,  Sultan Qasim Khan <sultanqasim@gmail.com>
# Copyright � 2016,  Zeeshan Hussain <zeeshanhussain12@gmail.com>
# Copyright � 2016,  Varun Chitre  <varun.chitre15@gmail.com>
# Copyright � 2016,  Aman Kumar  <firelord.xda@gmail.com>
# Copyright � 2016,  Kartik Bhalla <kartikbhalla12@gmail.com> 

# Custom build script
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#

#!/bin/bash
KERNEL_DIR=~/android/kernel/motorola/msm8916
KERN_IMG=$KERNEL_DIR/arch/arm/boot/zImage
DTBTOOL=$KERNEL_DIR/tools/dtbToolCM
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=~/android/kernel/toolchain/uber-6.0/bin/arm-eabi-
export KBUILD_BUILD_USER="haha"
export KBUILD_BUILD_HOST="FireLord"
rm -f arch/arm/boot/dts/*.dtb
rm -f arch/arm/boot/dt.img
rm -f flash_zip/boot.img

compile_kernel ()
{
  echo -e "$yellow ~~~~~~~~~~Initializing defconfig~~~~~~~~~~ $nocol"
  make osprey_defconfig
  echo -e "$red     ~~~~~~~~~~Building kernel~~~~~~~~~~      $nocol"
  make -j12 zImage
  if ! [ -a $KERN_IMG ];
  then
    echo -e "$blue Kernel Compilation failed! Fix the errors! $nocol"
    exit 1
  fi
  echo -e "$red     ~~~~~~~~~~Making DTB~~~~~~~~~~      $nocol"
  make -j12 dtbs
  $DTBTOOL -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
  echo -e "$red     ~~~~~~~~~~Building modules~~~~~~~~~~      $nocol"
  make -j12 modules
}

fire_kernel ()
{
  echo -e "$cyan***********************************************"
  echo "          Compiling FireKernel kernel          "
  echo -e "***********************************************$nocol"
  echo -e " "
  echo -e " SELECT ONE OF THE FOLLOWING TYPES TO BUILD : "
  echo -e " 1.DIRTY"
  echo -e " 2.CLEAN"
  echo -n " YOUR CHOICE : ? "
  read ch
  echo -n " VERSION : ? "
  read ver
  echo -n " OLD VERSION : ? "
  read old
  echo -n " Which device : ? "
  read dev
  echo -n " Which android mm or n : ? "
  read anv

replace $old $ver -- $KERNEL_DIR/arch/arm/configs/osprey_defconfig
replace $old $ver -- $KERNEL_DIR/flash_zip/META-INF/com/google/android/updater-script
case $ch in
  1) echo -e "$cyan     ~~~~~~~~~~Dirty~~~~~~~~~~ $nocol"
     echo -e "$cyan     ~~~~~~~~~~Building now~~~~~~~~~~ $nocol"
     compile_kernel ;;
  2) echo -e "$cyan     ~~~~~~~~~~Clean $nocol"
     echo -e "$cyan     ~~~~~~~~~~Building now~~~~~~~~~~ $nocol"
     make clean
     make mrproper
     compile_kernel ;;
  *) device ;;
esac

echo -e " Converting the output into a flashable zip"
rm -rf firekernel_install
mkdir -p firekernel_install
make -j4 modules_install INSTALL_MOD_PATH=firekernel_install INSTALL_MOD_STRIP=1
mkdir -p flash_zip/system/lib/modules/
find firekernel_install/ -name '*.ko' -type f -exec cp '{}' flash_zip/system/lib/modules/ \;
cp arch/arm/boot/zImage flash_zip/tools/
cp arch/arm/boot/dt.img flash_zip/tools/
rm -f ~/android/kernel/upload/osprey/fire_kernel.zip
cd flash_zip
zip -r ../arch/arm/boot/fire_kernel.zip ./
today=$(date +"-%d%m%Y")
mv ~/android/kernel/motorola/msm8916/arch/arm/boot/fire_kernel.zip ~/android/kernel/upload/osprey/FireKernel-$anv-$dev-v$ver$today.zip
}

fire_kernel
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
