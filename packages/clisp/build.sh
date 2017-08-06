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

	unset CC
	unset CPPFLAGS
	unset CFLAGS
	unset LDFLAGS

	#export CC=gcc

	env $AVOID_GNULIB HOS=unix $TERMUX_PKG_SRCDIR/configure \
		--host=$TERMUX_HOST_PLATFORM \
		--prefix=$TERMUX_PREFIX \
		--enable-shared \
		--disable-static \
		--srcdir=$TERMUX_PKG_SRCDIR \
		--with-libreadline-prefix=$TERMUX_PREFIX \
		--with-libiconv-prefix=$TERMUX_PREFIX \
		ac_cv_func_select=yes
}

termux_step_post_configure () {
	ln -s ~/termux-packages/clisp/interpreted.mem $TERMUX_PKG_BUILDDIR/
	ln -s ~/termux-packages/clisp/halfcompiled.mem $TERMUX_PKG_BUILDDIR/
	ln -s ~/termux-packages/clisp/lispinit.mem $TERMUX_PKG_BUILDDIR/
}
