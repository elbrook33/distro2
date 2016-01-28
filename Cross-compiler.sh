#!/bin/sh
. ../Env.sh

installPath=$1

softwareType=Software/Core
setInstallPaths "C-compiler"

export crossTarget=x86_64-linux-musl


# C-compiler

if [ `grep -c gcc-static Installed.list` -gt 0 ] ; then
	echo "Skipping gcc-static"
else
	# Expand a pre-built compiler
	tar -xf ../Packages/crossx86-$crossTarget-*
		PATH=$PATH:`pwd`/$crossTarget/bin
	
	# Make some symlinks so the build can complete
	mkdir --parents $installPath/Software/Core/C-compiler/$crossTarget	2>>Log
	mkdir --parents $installPath/Software/Core/C-compiler/Headers	2>>Log
	mkdir --parents $installPath/Software/Core/C-compiler/Libraries	2>>Log
	ln -sf ../Headers $installPath/Software/Core/C-compiler/$crossTarget/include	2>>Log
	ln -sf ../Libraries $installPath/Software/Core/C-compiler/$crossTarget/lib	2>>Log
	
	# Get recipe for building a musl-gcc and run
	git clone https://github.com/GregorR/musl-cross
	cd musl-cross
		if [ ! -f .hasBeenPatched ] ; then
			patch -p1 < ../../Patches/gcc-static.patch && touch .hasBeenPatched
		fi
		mv config-static.sh config.sh
		sh build.sh
	cd ..
	
	echo "gcc-static" >> Installed.list
fi
