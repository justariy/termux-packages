TERMUX_PKG_HOMEPAGE=http://x265.org/
TERMUX_PKG_DESCRIPTION="H.265/HEVC video stream encoder library"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_VERSION=3.0
TERMUX_PKG_SHA256=c5b9fc260cabbc4a81561a448f4ce9cad7218272b4011feabc3a6b751b2f0662
TERMUX_PKG_SRCURL=http://ftp.videolan.org/pub/videolan/x265/x265_${TERMUX_PKG_VERSION}.tar.gz

termux_step_pre_configure() {
	if [ $TERMUX_ARCH = "i686" ]; then
		# Avoid text relocations.
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DENABLE_ASSEMBLY=OFF"
	fi
	TERMUX_PKG_SRCDIR="$TERMUX_PKG_SRCDIR/source"
}

