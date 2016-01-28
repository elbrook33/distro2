#!/bin/sh

installPath=$1

if [ `grep -c linux-kernel Installed.list` -gt 0 ] ; then
	echo "Skipping kernel"
else
	echo "Installing kernel"
	if [ ! -d linux-* ] ; then
		tar -xf ../Packages/linux-*
	fi
	cd linux-*
		# Config
		cp ../../Patches/kernel-config ./.config
		make oldconfig

		# Kernel
		make bzImage	>> Log
		mv arch/x86/boot/bzImage $installPath/System/Kernel

		# Modules
		make modules	>> Log
		make INSTALL_MOD_PATH=$installPath/System modules_install	>> Log
		mv $installPath/System/lib/* $installPath/System/Libraries
		rmdir $installPath/System/lib

		# Headers
		make INSTALL_HDR_PATH=$installPath/System headers_install	>> Log
		mv $installPath/System/include/* $installPath/System/Headers
		rmdir $installPath/System/include
	cd ..
	echo "linux-kernel" >> Installed.list
fi
