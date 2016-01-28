#!/bin/sh

qemu-system-x86_64 \
	-m 512M \
	-kernel $2/System/Kernel \
	-append "root=/dev/sda rootfstype=ext4 init=/System/Startup quiet video=vesa vga=0x303" \
	-drive file=$1,format=raw
