TERMUX_PKG_HOMEPAGE=https://github.com/brailcom/speechd
TERMUX_PKG_DESCRIPTION="Common interface to speech synthesis"
TERMUX_PKG_VERSION=0.8.8
TERMUX_PKG_SHA256=f7a978b53eb116ce023dc7de643d164aac02be0cee2d20f21ac47338a7f61efc
TERMUX_PKG_SRCURL=https://github.com/brailcom/speechd/archive/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_DEPENDS="libtool, glib, pulseaudio, espeak, dotconf"
# Build fails to find src/api/c/libspeechd_version.h:
TERMUX_PKG_BUILD_IN_SRC=yes
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-pulse
--with-espeak-ng
"

termux_step_pre_configure () {
	./build.sh
}
