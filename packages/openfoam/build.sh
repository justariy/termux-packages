TERMUX_PKG_HOMEPAGE=https://www.openfoam.org
TERMUX_PKG_DESCRIPTION="OpenFOAM is the free, open source CFD software"
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
TERMUX_PKG_VERSION=1706
TERMUX_PKG_SRCURL="https://sourceforge.net/projects/openfoamplus/files/v$TERMUX_PKG_VERSION/OpenFOAM-v$TERMUX_PKG_VERSION.tgz"
TERMUX_PKG_SHA256="7779048bb53798d9a5bd2b2be0bf302c5fd3dff98e29249d6e0ef7eeb83db79a"
TERMUX_PKG_DEPENDS="openmpi, flex, boost"
TERMUX_PKG_BUILD_IN_SRC=yes
TERMUX_PKG_HOSTBUILD=yes

termux_step_host_build() {
	(
		cd $TERMUX_PKG_SRCDIR
		set +u
		source etc/bashrc
		set -u
		cd wmake/src
		make
	)
	mkdir -p wmake/platforms
	mv $TERMUX_PKG_SRCDIR/wmake/platforms/linux64Gcc wmake/platforms/
}

termux_step_pre_configure() {
	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		ARCH_FOLDER="linuxAArch64Clang"
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		ARCH_FOLDER="linuxARM7Clang"
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		ARCH_FOLDER="linuxClang"
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		ARCH_FOLDER="linux64Clang"
	fi
	sed -i "s%\@TERMUX_COMPILER\@%$CC%g" "$TERMUX_PKG_SRCDIR/etc/bashrc"
	#Lots and lots of unset env. variables that "set -u" complains about
	set +u
	USER=TERMUX source "$TERMUX_PKG_SRCDIR/etc/bashrc"
	set -u
	mkdir -p wmake/platforms
	cp -r $TERMUX_PKG_HOSTBUILD_DIR/wmake/platforms/linux64Gcc wmake/platforms/${ARCH_FOLDER}
}

termux_step_post_configure() {
	export WM_CC=$CC
	export WM_CXX=$CXX
}

termux_step_make() {
	./Allwmake
}
