OUTDATED_KERNEL=$(uname -r)
GIT_BRANCH="stable"

checkVersion() {
	if [ ! -d /boot/$OUTDATED_KERNEL ] ; then
	   mkdir /boot/$OUTDATED_KERNEL
	   cp /media/boot/* /boot/$OUTDATED_KERNEL/
	fi
	cd ~
	if [ ! -d linux ] ; then
	   apt install -y git build-essential
	   apt-mark hold bootini linux-image*
	   if [ -z "$1" ]
	   then
	    git clone --depth 1 -b $GIT_BRANCH https://github.com/euser101/linux/tree/$GIT_BRANCH
	   else
	    git clone --depth 1 $1
	   fi
	else
	   git pull origin $GIT_BRANCH
	   git clean -f
	fi

	compile
}

compile() {
	cd ~/linux
	make clean
	make odroidxu4_defconfig
	make -j$(nproc)

	installModules
}

installModules() {
	if [ make modules_install -eq 0 ] ; then
	  make INSTALL_MOD_STRIP=1 modules_install
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
	sync
	sync
	echo "Fresh Kernel compiled and installed"
}

if [[ $EUID -ne 0 ]] ; then
  echo "You must be root" 2>&1
  exit 1
else
  checkVersion
fi
