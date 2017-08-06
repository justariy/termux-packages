TERMUX_PKG_HOMEPAGE=http://clisp.org/
TERMUX_PKG_DESCRIPTION="Common Lisp is a high-level, all-purpose programming language."
TERMUX_PKG_VERSION=2.49
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
TERMUX_PKG_DEPENDS="readline, libsigsegv, ndk-sysroot, libandroid-support, iconv, libunistring"
TERMUX_PKG_SRCURL=https://ftp.gnu.org/pub/gnu/clisp/release/${TERMUX_PKG_VERSION}/clisp-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=bd2f6252c681337c0b6aa949fae3f92d3202dee3998c98a88ec28c72b115e866
#TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--srcdir=$TERMUX_PKG_SRCDIR \
#--prefix=$TERMUX_PREFIX \
#--includedir=$TERMUX_PREFIX/include \
#ac_cv_func_select=yes"
TERMUX_PKG_CLANG=no
TERMUX_MAKE_PROCESSES=1

termux_step_pre_configure () {
	AVOID_GNULIB=" gl_cv_func_gettimeofday_clobber=no"
}

termux_step_configure () {
	cd $TERMUX_PKG_BUILDDIR
	
	export XCC="$CC"
	export XCPPFLAGS="$CPPFLAGS"
	export XCFLAGS="$CFLAGS -liconv -lunistring"
	export XLDFLAGS="$LDFLAGS"

	env $AVOID_GNULIB $TERMUX_PKG_SRCDIR/configure \
		--host=$TERMUX_HOST_PLATFORM \
		--build=arm-unknown-linux-androideabi \
		--prefix=$TERMUX_PREFIX \
		--enable-shared \
		--disable-static \
		--srcdir=$TERMUX_PKG_SRCDIR \
		--with-libreadline-prefix=$TERMUX_PREFIX \
		--with-libiconv-prefix=$TERMUX_PREFIX \
		--ignore-absence-of-libsigsegv \
		ac_cv_func_select=yes
}

termux_step_post_configure () {
	ln -s ~/termux-packages/clisp/clisp.h $TERMUX_PKG_BUILDDIR/
}

termux_step_make() {
	# Sort of following steps described in this article:
	# http://dancorkill.com/pubs/CNAS-ATSN08.pdf
	make -j $TERMUX_MAKE_PROCESSES init
	cd gllib
	make -j $TERMUX_MAKE_PROCESSES stdint.h
	make -j $TERMUX_MAKE_PROCESSES configmake.h
	make -j $TERMUX_MAKE_PROCESSES libgnu.a
	cd ..
	make -j $TERMUX_MAKE_PROCESSES allc
	make -j $TERMUX_MAKE_PROCESSES lisp.run
}

termux_step_make_install() {
	cp $TERMUX_PKG_BUILDDIR/lisp.run $TERMUX_PREFIX/bin/
	return
}
