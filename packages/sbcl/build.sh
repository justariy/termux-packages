TERMUX_PKG_HOMEPAGE=http://www.sbcl.org/
TERMUX_PKG_DESCRIPTION="Steel Bank Common Lisp"
TERMUX_PKG_VERSION=1.4.1
TERMUX_PKG_SRCURL=http://prdownloads.sourceforge.net/sbcl/sbcl-${TERMUX_PKG_VERSION}-source.tar.bz2
TERMUX_PKG_SHA256=e8c7c6068241b13941d357a0a1f5a04ba04c7c83a52b00f0fbe296770872aae1

termux_step_pre_configure () {
	local SBCL_HOST_TARFILE=$TERMUX_PKG_CACHEDIR/sbcl-host-${TERMUX_PKG_VERSION}.tar.bz2
	if [ ! -f $SBCL_HOST_TARFILE ]; then
		# curl -o $SBCL_HOST_TARFILE -L http://downloads.sourceforge.net/project/sbcl/sbcl/${TERMUX_PKG_VERSION}/sbcl-${TERMUX_PKG_VERSION}-x86-64-linux-binary.tar.bz2
		termux_download http://downloads.sourceforge.net/project/sbcl/sbcl/${TERMUX_PKG_VERSION}/sbcl-${TERMUX_PKG_VERSION}-x86-64-\
linux-binary.tar.bz2 $TERMUX_PKG_TMPDIR/sbcl-${TERMUX_PKG_VERSION}-x86-64-linux.tar.bz2
		cd $TERMUX_PKG_TMPDIR
		tar xf $SBCL_HOST_TARFILE
		cd sbcl-${TERMUX_PKG_VERSION}-x86-64-linux
		INSTALL_ROOT=$TERMUX_PKG_CACHEDIR/sbcl-host sh install.sh
	fi
	export PATH=$PATH:$TERMUX_PKG_CACHEDIR/sbcl-host/bin
	export SBCL_HOME=$TERMUX_PKG_CACHEDIR/sbcl-host/lib/sbcl
}

termux_step_make_install () {
	cd $TERMUX_PKG_SRCDIR

	# On both device and host: 
	# sh make-config.sh

	# On host:
	# Patch away nl_langinfo
	# sh make-host-1.sh --arch=arm

	#rsync -e "ssh -p 8022" -r ./src/runtime/genesis/*.h u0_a146@130.229.183.150:~/projects/sbcl/sbcl-1.4.1/src/runtime/genesis/
	#rsync -e "ssh -p 8022" -r ./src/runtime/genesis/Makefile.features u0_a146@130.229.183.150:~/projects/sbcl/sbcl-1.4.1/src/runtime/genesis/
	#rsync -e "ssh -p 8022" -r ./src/runtime/genesis/thread-init.inc u0_a146@130.229.183.150:~/projects/sbcl/sbcl-1.4.1/src/runtime/genesis/
	#rsync -e "ssh -p 8022" -r ./src/runtime/ldso-stubs.S u0_a146@130.229.183.150:~/projects/sbcl/sbcl-1.4.1/src/runtime/
	
	# On device: 
	# Patch away nl_langinfo
	# sh make-target-1.sh

	#rsync -e "ssh -p 8022" -r u0_a146@130.229.183.150:~/projects/sbcl/sbcl-1.4.1/src/runtime/sbcl.nm ./src/runtime/
	#rsync -e "ssh -p 8022" -r u0_a146@130.229.183.150:~/projects/sbcl/sbcl-1.4.1/output/stuff-groveled-from-headers.lisp ./output/

	# On host: 
	# make sure ./output/build-id.inc on host matches ./output/build-id.inc on device
	# sh make-host-2.sh --arch=arm
	# rsync -e "ssh -p 8022" -r ./output/cold-sbcl.core u0_a146@130.229.183.150:~/projects/sbcl/sbcl-1.4.1/output/

	# On device:
	# sh make-target-2.sh # Fails with: 
#bash-4.4$ sh make-target-2.sh 
#//entering make-target-2.sh
#//doing warm init - compilation phase
#WARNING: linker: ./src/runtime/sbcl has text relocations. This is wasting memory and prevents security hardening. Please fix.
#This is SBCL 1.4.1, an implementation of ANSI Common Lisp.
#More information about SBCL is available at <http://www.sbcl.org/>.
#
#SBCL is free software, provided as is, with absolutely no warranty.
#It is mostly in the public domain; some portions are provided under
#BSD-style licenses.  See the CREDITS and COPYING files in the
#distribution for more information.
#CORRUPTION WARNING in SBCL pid 25666:
#Memory fault at 0x416a8 (pc=0x40001f0, sp=0x0)
#The integrity of this image is possibly compromised.
#Exiting.
#Welcome to LDB, a low-level debugger for the Lisp runtime environment.
#ldb>
	# sh make-target-contrib.sh
}
