TERMUX_PKG_HOMEPAGE=https://lame.sourceforge.net/
TERMUX_PKG_DESCRIPTION="High quality MPEG Audio Layer III (MP3) encoder"
TERMUX_PKG_LICENSE="LGPL-2.0"
TERMUX_PKG_VERSION=3.100
TERMUX_PKG_REVISION=1
TERMUX_PKG_SHA256=ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e
TERMUX_PKG_SRCURL=https://downloads.sourceforge.net/project/lame/lame/${TERMUX_PKG_VERSION}/lame-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--disable-frontend"
TERMUX_PKG_RM_AFTER_INSTALL="share/man"
