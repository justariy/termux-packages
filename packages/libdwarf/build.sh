TERMUX_PKG_HOMEPAGE=https://www.prevanders.net/dwarf.html
TERMUX_PKG_DESCRIPTION="Library of functions to provide creation of DWARF debugging information records, DWARF line number information, DWARF address range and pubnames information, weak names information, and DWARF frame description information."
TERMUX_PKG_VERSION=20180129
TERMUX_PKG_SRCURL=https://www.prevanders.net/libdwarf-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=8bd91b57064b0c14ade5a009d3a1ce819f1b6ec0e189fc876eb8f42a8720d8a6
TERMUX_PKG_DEPENDS="elfutils"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS=" --disable-nonshared"

termux_step_post_configure () {
	# These files doesn't seem to be possible to build on host.
	# See also removed stuff in dwarfdump-Makefile.patch
	if [ -d "$TERMUX_PKG_BUILDER_DIR/$TERMUX_ARCH" ]; then
		cp $TERMUX_PKG_BUILDER_DIR/$TERMUX_ARCH/* $TERMUX_PKG_BUILDDIR/dwarfdump/
	else
		echo "Error, dwarfdump files for $TERMUX_ARCH doesn't seem to exist in the builder directory. Exiting."
		exit 1
	fi
}

termux_step_make_install () {
	cd dwarfdump
	make -j 1 install
	cd ../libdwarf
	install -dm755 $TERMUX_PREFIX/lib
	install -m644 libdwarf.so.1 $TERMUX_PREFIX/lib
	ln -sf $TERMUX_PREFIX/lib/libdwarf.so.1 $TERMUX_PREFIX/lib/libdwarf.so
	install -dm755 $TERMUX_PREFIX/include/libdwarf
	install -m644 libdwarf.h $TERMUX_PREFIX/include/libdwarf/
	# Should we really install dwarf.h? archlinux does it but for an older version of libdwarf.
	# Remember to check if frida really needs it..
	install -m644 $TERMUX_PKG_SRCDIR/libdwarf/dwarf.h $TERMUX_PREFIX/include/libdwarf/
}
