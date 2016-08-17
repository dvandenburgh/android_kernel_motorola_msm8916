#
# Copyright � 2016,  Sultan Qasim Khan <sultanqasim@gmail.com> 	
# Copyright � 2016,  Zeeshan Hussain <zeeshanhussain12@gmail.com> 	      
# Copyright � 2016,  Varun Chitre  <varun.chitre15@gmail.com>	
# Copyright � 2016,  Aman Kumar  <firelord.xda@gmail.com>

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
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=/home/haha/android/kernel/toolchain/uber-4.8/bin/arm-eabi-
export KBUILD_BUILD_USER="haha"
export KBUILD_BUILD_HOST="FireLord"
echo -e "$cyan***********************************************"
echo "          Compiling FireKernel kernel          "
echo -e "***********************************************$nocol"
rm -f arch/arm/boot/dts/*.dtb
rm -f arch/arm/boot/dt.img
rm -f flash_zip/boot.img
echo -e " Initializing defconfig"
make osprey_defconfig
echo -e " Building kernel"
make -j12 zImage
make -j12 dtbs

/home/haha/android/kernel/osprey/source/tools/dtbToolCM -2 -o /home/haha/android/kernel/osprey/source/arch/arm/boot/dt.img -s 2048 -p /home/haha/android/kernel/osprey/source/scripts/dtc/ /home/haha/android/kernel/osprey/source/arch/arm/boot/dts/

make -j4 modules
echo -e " Converting the output into a flashable zip"
rm -rf firekernel_install
mkdir -p firekernel_install
make -j4 modules_install INSTALL_MOD_PATH=firekernel_install INSTALL_MOD_STRIP=1
mkdir -p flash_zip/system/lib/modules/
find firekernel_install/ -name '*.ko' -type f -exec cp '{}' flash_zip/system/lib/modules/ \;
cp arch/arm/boot/zImage flash_zip/tools/
cp arch/arm/boot/dt.img flash_zip/tools/
rm -f /home/haha/android/kernel/osprey/upload/fire_kernel.zip
cd flash_zip
zip -r ../arch/arm/boot/fire_kernel.zip ./
mv /home/haha/android/kernel/osprey/source/arch/arm/boot/fire_kernel.zip /home/haha/android/kernel/osprey/upload/fire_kernel.zip
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
