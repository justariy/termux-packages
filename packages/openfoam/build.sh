TERMUX_PKG_HOMEPAGE=https://www.openfoam.org
TERMUX_PKG_DESCRIPTION="OpenFOAM is the free, open source CFD software"
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
TERMUX_PKG_VERSION=1706
TERMUX_PKG_SRCURL="https://sourceforge.net/projects/openfoamplus/files/v$TERMUX_PKG_VERSION/OpenFOAM-v$TERMUX_PKG_VERSION.tgz"
TERMUX_PKG_SHA256="7779048bb53798d9a5bd2b2be0bf302c5fd3dff98e29249d6e0ef7eeb83db79a"
TERMUX_PKG_DEPENDS="openmpi, flex"
TERMUX_PKG_CLANG=no
TERMUX_PKG_BUILD_IN_SRC=yes

termux_step_pre_configure() {
	sed -i "s%\@TERMUX_COMPILER\@%$CC%g" "$TERMUX_PKG_SRCDIR/etc/bashrc"
	#Lots and lots of unset env. variables that "set -u" complains about
	set +u
	USER=TERMUX source "$TERMUX_PKG_SRCDIR/etc/bashrc"
	set -u
        cd $TERMUX_PKG_SRCDIR/wmake/src
        make
}

termux_step_post_configure() {
	export WM_CC=$CC
	export WM_CXX=$CXX
}

termux_step_make() {
        ./Allwmake
}
