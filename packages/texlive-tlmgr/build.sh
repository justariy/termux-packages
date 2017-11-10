TERMUX_DESCRIPTION="TeX Lives package manager"
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
TERMUX_PKG_VERSION=20170524
TERMUX_PKG_SHA256="d4e07ed15dace1ea7fabe6d225ca45ba51f1cb7783e17850bc9fe3b890239d6d"
TERMUX_PKG_SRCURL="ftp://ftp.tug.org/texlive/historic/${TERMUX_PKG_VERSION:0:4}/install-tl-unx.tar.gz"
TERMUX_CONFLICTS="texlive-full"
TERMUX_DEPENDS="perl, wget, gnupg2, xz-utils"
#TERMUX_RECOMMENDS=
TERMUX_PKG_PLATFORM_INDEPENDENT=yes
TERMUX_PKG_FOLDERNAME=install-tl-$TERMUX_PKG_VERSION

TL_ROOT=$TERMUX_PREFIX/share/texlive
TL_BINDIR=$TERMUX_PREFIX/bin

termux_step_make () {
	mkdir -p $TL_ROOT/{tlpkg/{backups,tlpobj},texmf-var/web2c}
	cp $TERMUX_PKG_BUILDER_DIR/texlive.tlpdb $TL_ROOT/tlpkg/
}

termux_step_post_make_install () {
	perl -I$TL_ROOT/tlpkg/ $TL_ROOT/texmf-dist/scripts/texlive/mktexlsr.pl $TL_ROOT/texmf-dist

	# Replace tlmgr link with a small wrapper that prevents common break on "tlmgr update --self"
	mv $TL_BINDIR/tlmgr $TL_BINDIR/tlmgr.ln
	echo "#!$TERMUX_PREFIX/bin/sh" > $TL_BINDIR/tlmgr
	echo "termux-fix-shebang $TL_ROOT/texmf-dist/scripts/texlive/tlmgr.pl" >> $TL_BINDIR/tlmgr
	echo "sed -i 's%`kpsewhich -var-value=SELFAUTOPARENT`);%`kpsewhich -var-value=TEXMFROOT`);%g' $TL_ROOT/texmf-dist/scripts/texlive/tlmgr.pl" >> $TL_BINDIR/tlmgr
	echo "sed -E -i '"'s@`/bin/sh@`'$TERMUX_PREFIX"/bin/sh@g' ${TL_ROOT}/tlpkg/TeXLive/TLUtils.pm" >> $TL_BINDIR/tlmgr
	echo 'tlmgr.ln "$@"' >> $TL_BINDIR/tlmgr
	chmod 0744 $TL_BINDIR/tlmgr
}

termux_step_create_debscript () {
	echo "#!$TERMUX_PREFIX/bin/bash" > postinst
	echo "export TMPDIR=$TERMUX_PREFIX/tmp"
	echo "echo Updating tlmgr" >> postinst
	echo "tlmgr update --self" >> postinst
	echo "echo Generating language files and setting up symlinks" >> postinst
	echo "tlmgr -q generate language" >> postinst
	echo "mktexlsr $TL_ROOT/texmf-var" >> postinst
	echo "texlinks" >> postinst
	echo "exit 0" >> postinst
	chmod 0755 postinst

	# Don't remove installed stuff on removal, do that in the pkg texlive instead.
}
