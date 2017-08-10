TERMUX_PKG_HOMEPAGE=https://openvpn.net
TERMUX_PKG_DESCRIPTION="An easy-to-use, robust, and highly configurable VPN (Virtual Private Network)"
TERMUX_PKG_VERSION=2.4.2
TERMUX_PKG_DEPENDS="openssl, liblzo, net-tools"
TERMUX_PKG_SRCURL=https://swupdate.openvpn.net/community/releases/openvpn-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=df5c4f384b7df6b08a2f6fa8a84b9fd382baf59c2cef1836f82e2a7f62f1bff9
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-plugin-auth-pam
--disable-systemd
--disable-debug
--enable-iproute2
--enable-x509-alt-username
ac_cv_func_getpwnam=yes
ac_cv_func_getpass=yes
IFCONFIG=/system/bin/ifconfig
ROUTE=/system/bin/route
IPROUTE=/system/bin/ip
NETSTAT=/system/bin/netstat"
TERMUX_PKG_MAINTAINER="Vishal Biswas @vishalbiswas"

termux_step_pre_configure () {
    # need to provide getpass, else you "can't get console input"
    cp $TERMUX_PKG_BUILDER_DIR/getpass.{c,h} "$TERMUX_PKG_SRCDIR/src/openvpn/"

#    CFLAGS="$CFLAGS -DTARGET_ANDROID"
    LDFLAGS="$LDFLAGS -llog "
}

termux_step_post_make_install () {
    # helper script
    install -m700 "$TERMUX_PKG_BUILDER_DIR/termux-openvpn" "$TERMUX_PREFIX/bin/"
    # Install examples
    install -d -m755 "$TERMUX_PREFIX/share/openvpn/examples"
    cp "$TERMUX_PKG_SRCDIR"/sample/sample-config-files/* "$TERMUX_PREFIX/share/openvpn/examples"
}
