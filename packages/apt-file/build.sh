TERMUX_PKG_HOMEPAGE=https://wiki.debian.org/apt-file
TERMUX_PKG_DESCRIPTION="apt-file is a software package that indexes the contents of packages in your available repositories and allows you to search for a particular file among all available packages"
TERMUX_PKG_VERSION=3.1.4
TERMUX_PKG_SHA256=9383ae584cd475f776b852600342b3a24c1108662a67a4dd1b532c0df9adeadd
TERMUX_PKG_SRCURL=http://deb.debian.org/debian/pool/main/a/apt-file/apt-file_${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_BUILD_IN_SRC=yes
TERMUX_PKG_EXTRA_MAKE_ARGS="DESTDIR=$TERMUX_PREFIX"
TERMUX_PKG_PLATFORM_INDEPENDENT=yes
TERMUX_PKG_DEPENDS="apt, perl, libapt-pkg, libapt-pkg-perl"
