#!/bin/sh

if [ -z $2 ] ; then
	installDevice=/dev/sda7
	installPath=~/Desmond/Mount
else
	installDevice=$1
	installPath=$2
fi

echo "Installing to $installDevice (via $installPath)"
sudo mount $installDevice $installPath

cd Build
	echo > Log
	touch Installed.list
	
	
	# Set up partition
	
	# Make directories
	mkdir $installPath	2>>Log

	mkdir $installPath/Apps	2>>Log

	mkdir $installPath/Documents		2>>Log
	mkdir $installPath/Documents/Temporary	2>>Log
	mkdir $installPath/Documents/Trash	2>>Log

	mkdir $installPath/Shell	2>>Log
	mkdir $installPath/Shell/Apps	2>>Log
	mkdir $installPath/Shell/Documents	2>>Log
	mkdir $installPath/Shell/Software	2>>Log
	mkdir $installPath/Shell/System	2>>Log
	mkdir $installPath/Shell/bin	2>>Log
	mkdir $installPath/Shell/dev	2>>Log
	mkdir $installPath/Shell/etc	2>>Log
	mkdir $installPath/Shell/lib	2>>Log
	mkdir $installPath/Shell/proc	2>>Log
	mkdir $installPath/Shell/sys	2>>Log

	mkdir $installPath/Software	2>>Log

	mkdir $installPath/System	2>>Log
	mkdir $installPath/System/Headers	2>>Log
	mkdir $installPath/System/Libraries	2>>Log
	mkdir $installPath/System/Settings	2>>Log

	# Symlink (Shell)	
	ln -sf .	$installPath/Shell/Shell	2>>Log

	# Symlinks (Shell/bin)
	ln -sf bash	$installPath/Shell/bin/sh	2>>Log

	# Symlinks (Shell/lib)
	ln -s /Software/Core/C-compiler/Libraries/libc.so $installPath/Shell/lib/ld-musl-x86_64.so.1	2>>Log
	ln -sf /System/Libraries/firmware	$installPath/Shell/lib/firmware	2>>Log
	ln -sf /System/Libraries/modules	$installPath/Shell/lib/modules	2>>Log

	# Symlinks (Shell/tmp)
	ln -sf Documents/Temporary	$installPath/Shell/tmp	2>>Log

	# Copy settings
	cp ../Patches/etc-fstab	$installPath/System/Settings/fstab	2>>Log
	cp ../Patches/etc-group	$installPath/System/Settings/group	2>>Log
	ln -sf /System/Settings/fstab	$installPath/Shell/etc/fstab	2>>Log
	ln -sf /System/Settings/group	$installPath/Shell/etc/group	2>>Log

	# Copy startup scripts
	cp ../Patches/system-Startup	$installPath/System/Startup	2>>Log
	cp ../Patches/system-Services	$installPath/System/Services	2>>Log
	chmod +x $installPath/System/Startup
	chmod +x $installPath/System/Services


	# Install kernel
	../Build-kernel.sh $installPath


	# Cross-compile the base system, enough to run bash and make
	
	../Cross.sh $installPath


	# Chroot into partition and build some extras

	mkdir $installPath/Documents/Build

	sudo mount --bind /dev		$installPath/Shell/dev
	sudo mount --bind /dev/pts	$installPath/Shell/dev/pts
	sudo mount --bind /proc		$installPath/Shell/proc
	sudo mount --bind /sys		$installPath/Shell/sys
	sudo mount --bind $installPath/Apps		$installPath/Shell/Apps
	sudo mount --bind $installPath/Documents	$installPath/Shell/Documents
	sudo mount --bind $installPath/Software	$installPath/Shell/Software
	sudo mount --bind $installPath/System		$installPath/Shell/System
	sudo mount --bind ..	$installPath/Shell/Documents/Build
		sudo chroot $installPath /Shell/bin/env -i /Shell/bin/chroot /Shell /bin/sh -l
	sudo umount $installPath/Shell/Documents/Build
	sudo umount $installPath/Shell/System
	sudo umount $installPath/Shell/Software
	sudo umount $installPath/Shell/Documents
	sudo umount $installPath/Shell/Apps
	sudo umount $installPath/Shell/sys
	sudo umount $installPath/Shell/proc
	sudo umount $installPath/Shell/dev/pts
	sudo umount $installPath/Shell/dev

cd ..


# Boot

sudo ./Boot.sh $installDevice $installPath
