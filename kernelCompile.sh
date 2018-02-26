#!/bin/bash

#parameters: repo link; branch; .config file

OUTDATED_KERNEL=$(uname -r)
GIT_SOURCE=${1:-https://github.com/euser101/linux/}
GIT_BRANCH=${2:-odroidxu4-4.14.y}
KERNEL_CONFIG=${3:-~/xu4Scripts/files/kernel.config}
CONFIGURE_CONFIG=false

checkVersion() {
	if [ ! -d /boot/$OUTDATED_KERNEL ] ; then
	   echo "Backing up old kernel and ini files into /boot$OUTDATED_KERNEL"
	   mkdir /boot/$OUTDATED_KERNEL /boot/$OUTDATED_KERNEL/rootfsBoot/
	   cp -f -R /media/boot/* /boot/$OUTDATED_KERNEL/
	   cp -f -R /boot/* /boot/$OUTDATED_KERNEL/rootfsBoot/
	fi
	echo "Installing dependencies"
	apt install -y git build-essential libqt4-dev libssl-dev gcc g++
	apt-mark hold bootini linux-image*
	cd ~
	if [ ! -d linux ] ; then
	    git clone --depth 1 -b $GIT_BRANCH $GIT_SOURCE
	    if [ $? -eq 0 ]
	    then
	      getConfig
	    else
	      echo "Could not clone. Is $GIT_SOURCE $GIT_BRANCH a valid repository?" >&2
	    fi
	else
	   cd ~/linux
	   echo "Updating repo"
	   git pull origin $GIT_BRANCH
	   git clean -f
	   getConfig
	fi
}

getConfig() {
	echo "Copying config"
	cp -f $KERNEL_CONFIG ~/linux/.config
	if [ $? -eq 0 ]
	then
	  compile
	else
	  read -p "Copying config failed. Would you like to use the default Kernel config? " -n 1 -r
	  if [[ $REPLY =~ ^[Yy]$ ]]
	  then
	    cd ~/linux && make odroidxu4_defconfig
	  else
	    echo "Was not able to copy config $KERNEL_CONFIG. Use defaults?" >&2
	  fi
	fi
}

compile() {
	echo "Cleaning up and preparing for compilation"
	cd ~/linux
	make clean
	if [ "$CONFIGURE_CONFIG" = true ]
	then
	  su odroid -c "make xconfig"
	fi
	echo "Compiling"
	make -j$(nproc)
	installModules
}

installModules() {
	make INSTALL_MOD_STRIP=1 modules_install
	if [ $? -eq 0 ]
	then
	  updateImages
	else
	  echo "Could not compile modules" >&2
	fi
}

updateImages() {
	cd ~/linux
	cp arch/arm/boot/zImage arch/arm/boot/dts/exynos5422-odroidxu4.dtb /media/boot/
	NEW=$(make kernelrelease)
	cp arch/arm/boot/zImage /boot/zImage-$NEW

	updateInitrd
}

updateInitrd() {
	update-initramfs -c -k $NEW
	mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d /boot/initrd.img-$NEW /boot/uInitrd-$NEW
	cp /boot/uInitrd-$NEW /media/boot/uInitrd
	
	cleanup
}

cleanup() {
	sync
	echo "Fresh Kernel compiled and installed"
	
	promptReboot
}

promptReboot() {
	read -p "Would you like to reboot into the new Kernel? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	    reboot
	fi
}

if [[ $EUID -ne 0 ]] ; then
  echo "You must be root" 2>&1
  exit 1
else
  checkVersion
fi
