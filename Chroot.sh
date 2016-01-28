#!/bin/sh

cd Build

	. ../Env.sh

	export FORCE_UNSAFE_CONFIGURE=1

	findBuildPaths	2>>Log

	compilerPrefix=`uname -m`-linux-musl

	export AR=$compilerPrefix-ar
	export CC=$compilerPrefix-gcc
	export CXX=$compilerPrefix-g++
	export RANLIB=$compilerPrefix-ranlib

	softwareType=/Software/Core
	setInstallPaths "Device-tools"
	buildPkg e2fsprogs "--disable-nls"
	buildPkg kmod
		# Make links to kmod to get other functions
		ln -sf kmod /Software/Core/Device-tools/depmod
		ln -sf kmod /Software/Core/Device-tools/insmod
		ln -sf kmod /Software/Core/Device-tools/lsmod
		ln -sf kmod /Software/Core/Device-tools/modinfo
		ln -sf kmod /Software/Core/Device-tools/modprobe
		ln -sf kmod /Software/Core/Device-tools/rmmod
	buildPkg util-linux "--without-python --without-ncurses"

	$CC ../Patches/system-Shutdown.c -o /System/Shutdown

cd ..
