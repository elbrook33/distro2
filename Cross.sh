#!/bin/sh
. ../Env.sh

# Setup

installPath=$1
export crossTarget=x86_64-linux-musl
sudo ln -s $installPath/Software /


# Build (temporary) C-compiler

softwareType=Software/Temporary
setInstallPaths "C-compiler"
buildInTree musl "--syslibdir=/Software/Core/C-compiler/Libraries"


# Build (permanent) C-compiler

softwareType=Software/Core
setInstallPaths "C-compiler"

export CC=/Software/Temporary/C-compiler/musl-gcc
buildPkg gmp && findBuildPaths	2>>Log
buildPkg mpfr
buildPkg mpc

../Cross-compiler.sh $installPath


# Build basic (static) shell, enough to chroot and build

export CC=/Software/Temporary/C-compiler/musl-gcc

setInstallPaths "Archivers"
buildInTree bzip2
	# Fix absolute-path symlinks
	ln -sf bzdiff $installPath/Software/Core/Archivers/bzcmp
	ln -sf bzgrep $installPath/Software/Core/Archivers/bzegrep
	ln -sf bzgrep $installPath/Software/Core/Archivers/bzfgrep
	ln -sf bzmore $installPath/Software/Core/Archivers/bzless
buildPkg gzip
buildPkg tar
buildPkg xz

setInstallPaths "Build-tools"
buildPkg bison
buildPkg diffutils
buildPkg m4
buildPkg make
buildPkg patch
buildPkg pkg-config "--with-internal-glib"

setInstallPaths "Command-line"
buildPkg bash "--without-bash-malloc --enable-static-link"
	# Copy default profile
	cp ../Patches/bash-profile $installPath/Shell/etc/profile
	cp $installPath/Software/Core/Command-line/bash $installPath/Shell/bin/bash
buildPkg coreutils
buildPkg file
buildPkg findutils
buildPkg gawk
buildPkg grep
buildPkg sed


# Clean up

sudo rm /Software
