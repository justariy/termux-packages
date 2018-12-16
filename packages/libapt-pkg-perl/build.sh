TERMUX_PKG_HOMEPAGE=https://tracker.debian.org/pkg/libapt-pkg-perl
TERMUX_PKG_DESCRIPTION="A Perl interface to APT's libapt-pkg which provides modules for configuration file/command line parsing, version comparison, inspection of the binary package cache and source package details"x
TERMUX_PKG_VERSION=0.1.34
TERMUX_PKG_SHA256=a7998d741c8b4dcee07ff9803415ebe00ccefadb0ad7971c492f41fe6a4927c9
TERMUX_PKG_SRCURL=http://deb.debian.org/debian/pool/main/liba/libapt-pkg-perl/libapt-pkg-perl_${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_DEPENDS="perl, libapt-pkg"
TERMUX_PKG_EXTRA_MAKE_ARGS="
CC=$TERMUX_HOST_PLATFORM-clang++ 
LD=$TERMUX_HOST_PLATFORM-clang++ 
INC=-I$TERMUX_PREFIX/include"
TERMUX_PKG_MAKE_PROCESSES=1
TERMUX_PKG_BUILD_IN_SRC=yes

termux_step_pre_configure () {
	export PERL5LIB="$TERMUX_PREFIX/lib/perl5/5.28.1:$TERMUX_PREFIX/lib/perl5/5.28.1/${TERMUX_ARCH}-android"
	$TERMUX_TOPDIR/perl/src/miniperl_top Makefile.PL INSTALLDIRS=perl INSTALLMAN1DIR=$TERMUX_PREFIX/share/man/man1 INSTALLMAN3DIR=$TERMUX_PREFIX/share/man/man3
}

