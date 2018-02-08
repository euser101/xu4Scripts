OUTDATED_KERNEL=$(uname -r)
GIT_BRANCH="minimal-testing"

checkVersion() {
	if [ ! -d /boot/$OUTDATED_KERNEL ] ; then
	   mkdir /boot/$OUTDATED_KERNEL
	   cp /media/boot/* /boot/$OUTDATED_KERNEL/
	fi
	cd ~
	if [ ! -d linux ] ; then
	   apt install -y git build-essential
	   apt-mark hold bootini linux-image*
	   git clone --depth 1 --branch $GIT_BRANCH https://github.com/euser101/linux/tree/$GIT_BRANCH
	else
	   git pull origin $GIT_BRANCH
	   git clean -f
	   make clean
	fi

	compile
}

compile() {
	cd ~/linux
	make odroidxu4_defconfig
	make -j8

	installModules
}

installModules() {
	if [ make modules_install -eq 0 ]; then
	  updateImages
	else
	  echo "Could not compile" >&2
	fi	
}

updateImages() {
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
}

checkVersion
