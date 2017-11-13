TERMUX_PKG_HOMEPAGE=https://www.tug.org/texlive/
TERMUX_PKG_DESCRIPTION="TeX Lives package manager"
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
TERMUX_PKG_VERSION=20170524
TERMUX_PKG_SHA256="d4e07ed15dace1ea7fabe6d225ca45ba51f1cb7783e17850bc9fe3b890239d6d"
TERMUX_PKG_SRCURL="ftp://ftp.tug.org/texlive/historic/${TERMUX_PKG_VERSION:0:4}/install-tl-unx.tar.gz"
TERMUX_PKG_CONFLICTS="texlive-full"
TERMUX_PKG_BREAKS="texlive (<< 20170524-5), texlive-bin (<< 20170524-8)"
TERMUX_PKG_DEPENDS="perl, wget, gnupg2, xz-utils"
TERMUX_PKG_PLATFORM_INDEPENDENT=yes
TERMUX_PKG_FOLDERNAME=install-tl-$TERMUX_PKG_VERSION

TL_ROOT=$TERMUX_PREFIX/share/texlive
TL_BINDIR=$TERMUX_PREFIX/bin

TERMUX_PKG_RM_AFTER_INSTALL="share/texlive/tlpkg/installer/wget
share/texlive/tlpkg/installer/xz
share/texlive/tlpkg/installer/COPYING.MinGW-runtime.txt
share/texlive/tlpkg/installer/install-menu-perltk.pl
share/texlive/tlpkg/installer/install-menu-text.pl
share/texlive/tlpkg/installer/install-menu-wizard.pl
share/texlive/tlpkg/installer/install-tl.html
share/texlive/tlpkg/installer/installer-options.txt
share/texlive/tlpkg/installer/texlive.png
share/texlive/tlpkg/installer/tl-cmd.bat
share/texlive/tlpkg/installer/tl-tray-menu.ini
share/texlive/tlpkg/installer/tracked-install.pl
share/texlive/tlpkg/translations
share/texlive/install-tl
share/texlive/LICENSE.TL"

termux_step_make () {
	mkdir -p $TL_ROOT/{tlpkg/{backups,tlpobj},texmf-var/web2c}
	cp -r $TERMUX_PKG_SRCDIR/* $TL_ROOT
	cp $TERMUX_PKG_BUILDER_DIR/texlive.tlpdb $TL_ROOT/tlpkg/
}

termux_step_post_make_install () {
	# Replace tlmgr link with a small wrapper that prevents common break on "tlmgr update --self"
	if [ -f $TL_BINDIR/tlmgr.ln ]; then
		unlink $TL_BINDIR/tlmgr.ln
	fi
	ln -s ../share/texlive/texmf-dist/scripts/texlive/tlmgr.pl $TL_BINDIR/tlmgr.ln
	echo "#!$TERMUX_PREFIX/bin/sh" > $TL_BINDIR/tlmgr
	echo "termux-fix-shebang $TL_ROOT/texmf-dist/scripts/texlive/tlmgr.pl" >> $TL_BINDIR/tlmgr
	echo "sed -i 's%\`kpsewhich -var-value=SELFAUTOPARENT\`);%\`kpsewhich -var-value=TEXMFROOT\`);%g' $TL_ROOT/texmf-dist/scripts/texlive/tlmgr.pl" >> $TL_BINDIR/tlmgr
	echo "sed -E -i '"'s@`/bin/sh@`'$TERMUX_PREFIX"/bin/sh@g' ${TL_ROOT}/tlpkg/TeXLive/TLUtils.pm" >> $TL_BINDIR/tlmgr
	echo 'tlmgr.ln "$@"' >> $TL_BINDIR/tlmgr
	chmod 0744 $TL_BINDIR/tlmgr
}

termux_step_create_debscripts () {
	echo "#!$TERMUX_PREFIX/bin/bash" > postinst
	echo "export TMPDIR=$TERMUX_PREFIX/tmp" >> postinst
	echo "mkdir -p $TL_ROOT/tlpkg/{backups,tlpobj}" >> postinst
	echo "echo Updating tlmgr" >> postinst
	echo "tlmgr update --self" >> postinst
	echo "echo Generating language files and setting up symlinks" >> postinst
	echo "tlmgr -q generate language" >> postinst
	echo "mktexlsr $TL_ROOT/texmf-var" >> postinst
	echo "mktexlsr $TL_ROOT/texmf-dist" >> postinst
	echo "texlinks" >> postinst
	echo "exit 0" >> postinst
	chmod 0755 postinst

	# Don't remove installed stuff on removal, do that in the pkg texlive instead. Remove backup files though:
	echo "#!$TERMUX_PREFIX/bin/bash" > prerm
	echo "echo Removing temporary and backup files" >> prerm
	echo "rm -rf $TL_ROOT/tlpkg/{texlive.tlpdb.*,tlpobj,backups}" >> prerm
	echo "" >> prerm
	echo "exit 0" >> prerm
	chmod 0755 prerm
}
