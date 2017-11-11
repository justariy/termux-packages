TERMUX_PKG_HOMEPAGE=https://www.tug.org/texlive/
TERMUX_PKG_DESCRIPTION="TeX Live is a distribution of the TeX typesetting system."
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
_MAJOR_VERSION=20170524
TERMUX_PKG_VERSION=${_MAJOR_VERSION}
TERMUX_PKG_REVISION=5
TERMUX_PKG_SRCURL=("ftp://ftp.tug.org/texlive/historic/${TERMUX_PKG_VERSION:0:4}/texlive-$_MAJOR_VERSION-texmf.tar.xz" "ftp://ftp.tug.org/texlive/historic/${TERMUX_PKG_VERSION:0:4}/texlive-$_MAJOR_VERSION-extra.tar.xz")
TERMUX_PKG_SHA256=("3f63708b77f8615ec6f2f7c93259c5f584d1b89dd335a28f2362aef9e6f0c9ec"
"afe49758c26fb51c2fae2e958d3f0c447b5cc22342ba4a4278119d39f5176d7f")
TERMUX_PKG_DEPENDS="perl, texlive-bin (>= 20170524)"
TERMUX_PKG_RECOMMENDS="texlive-tlmgr"
TERMUX_PKG_FOLDERNAME=("texlive-$_MAJOR_VERSION-texmf"
"texlive-$_MAJOR_VERSION-extra")
TL_FILE_LISTS=("texlive-texmf.list"
"texlive-extra.list")
TERMUX_PKG_PLATFORM_INDEPENDENT=yes

TL_ROOT=$TERMUX_PREFIX/share/texlive
TL_BINDIR=$TERMUX_PREFIX/bin

termux_step_extract_package() {
	mkdir -p "$TERMUX_PKG_SRCDIR"
	
	cd "$TERMUX_PKG_TMPDIR"
	for index in $(seq 0 1); do
		local filename
		filename=$(basename "${TERMUX_PKG_SRCURL[$index]}")
		local file="$TERMUX_PKG_CACHEDIR/$filename"
		termux_download "${TERMUX_PKG_SRCURL[$index]}" "$file" "${TERMUX_PKG_SHA256[$index]}"
		
		folder=${TERMUX_PKG_FOLDERNAME[$index]}
		
		rm -Rf $folder
		echo "Extracting files from $folder"
		tar xf "$file"
		echo "Done."
	done
	cp -r ${TERMUX_PKG_FOLDERNAME[@]} "$TERMUX_PKG_SRCDIR"
}

termux_step_make() {
	for index in $( seq 0 1 ); do
		echo "Installing ${TERMUX_PKG_FOLDERNAME[$index]}"
		(cd $TERMUX_PKG_SRCDIR/${TERMUX_PKG_FOLDERNAME[$index]}
		rm -Rf $TERMUX_PKG_RM_AFTER_EXTRACT)
		cp -r $TERMUX_PKG_SRCDIR/${TERMUX_PKG_FOLDERNAME[$index]}/* $TL_ROOT/
	done
}

termux_step_create_debscripts () {
	# Clean texlive's folder if needed (run on upgrade)
	echo "#!$TERMUX_PREFIX/bin/bash" > preinst
	echo "if [ ! -d $TERMUX_PREFIX/opt/texlive ]; then exit 0; else echo 'Removing residual files from old version of TeX Live for Termux'; fi" >> preinst
	echo "rm -rf $TERMUX_PREFIX/opt/texlive" >> preinst
	echo "exit 0" >> preinst
	chmod 0755 preinst
	
	echo "#!$TERMUX_PREFIX/bin/bash" > postinst
	echo "mkdir -p $TL_ROOT/texmf-var/{web2c,tex/generic/config}" >> postinst
	echo "echo Updating texmf-dist/ls-R and setting up texlinks" >> postinst
	echo "mktexlsr $TL_ROOT/texmf-dist" >> postinst
	echo "export TMPDIR=$TERMUX_PREFIX/tmp" >> postinst
	echo "texlinks" >> postinst
	echo "echo ''" >> postinst
	echo "echo Welcome to TeX Live!" >> postinst
	echo "echo ''" >> postinst
	echo "echo 'TeX Live is a joint project of the TeX user groups around the world;'" >> postinst
	echo "echo 'please consider supporting it by joining the group best for you.'" >> postinst
	echo "echo 'The list of groups is available on the web at http://tug.org/usergroups.html.'" >> postinst
	echo "exit 0" >> postinst
	chmod 0755 postinst

	# Remove all files installed through tlmgr on removal
	echo "#!$TERMUX_PREFIX/bin/bash" > prerm
	echo 'if [ $1 != "remove" ]; then exit 0; fi' >> prerm
	echo "echo Running texlinks --unlink" >> prerm
	echo "texlinks --unlink" >> prerm
	echo "echo Removing texmf-dist" >> prerm
	echo "rm -rf $TL_ROOT/texmf-dist" >> prerm
	echo "echo Removing texmf-var" >> prerm
	echo "rm -rf $TL_ROOT/texmf-var" >> prerm
	echo "exit 0" >> prerm
	chmod 0755 prerm
}

# Removing after extract instead of after install to avoid elf cleaner output
# Files to rm, first from texlive-$_MAJOR_VERSION-extra and then from install-tl-unx
TERMUX_PKG_RM_AFTER_EXTRACT="
autorun.inf
doc.html
index.html
install-tl
install-tl-advanced.bat
install-tl-windows.bat
readme-html.dir/readme.ja.html
readme-html.dir/readme.ru.html
readme-html.dir/readme.zh-cn.html
readme-html.dir/readme.it.html
readme-html.dir/readme.es.html
readme-html.dir/readme.pl.html
readme-html.dir/readme.de.html
readme-html.dir/readme.fr.html
readme-html.dir/readme.sr.html
readme-html.dir/readme.pt-br.html
readme-html.dir/readme.en.html
readme-html.dir/readme.cs.html
readme-txt.dir/README.RU-koi8
readme-txt.dir/README.EN
readme-txt.dir/README.FR
readme-txt.dir/README.SK-il2
readme-txt.dir/README.SK-ascii
readme-txt.dir/README.RU
readme-txt.dir/README.IT
readme-txt.dir/README.CS
readme-txt.dir/README.JA
readme-txt.dir/README.ES
readme-txt.dir/README.ZH-CN
readme-txt.dir/README.DE
readme-txt.dir/README.PL
readme-txt.dir/README.SK-cp1250
readme-txt.dir/README.SR
readme-txt.dir/README.PT-BR
readme-txt.dir/README.RU-cp1251
tl-tray-menu.exe
tlpkg/tlpostcode/xetex.pl
tlpkg/tlpostcode/xetex/conf/fonts.conf
tlpkg/tlpostcode/xetex/conf/fonts.dtd
tlpkg/tlpostcode/xetex/conf/conf.d/51-local.conf
tlpkg/tlpostcode/xetex/cache/readme.txt
tlpkg/tlpostcode/ptex2pdf-tlpost.pl
tlpkg/installer/tl-cmd.bat
tlpkg/installer/xz/xzdec.armhf-linux
tlpkg/installer/xz/xzdec.x86_64-solaris
tlpkg/installer/xz/xzdec.amd64-netbsd
tlpkg/installer/xz/xzdec.i386-solaris
tlpkg/installer/xz/xzdec.x86_64-darwin
tlpkg/installer/xz/xzdec.sparc-solaris
tlpkg/installer/xz/xzdec.i386-linux
tlpkg/installer/xz/xzdec.x86_64-linux
tlpkg/installer/xz/xzdec.i386-darwin
tlpkg/installer/xz/xzdec.i386-netbsd
tlpkg/installer/xz/xzdec.powerpc-darwin
tlpkg/installer/xz/xzdec.x86_64-cygwin.exe
tlpkg/installer/xz/xzdec.amd64-freebsd
tlpkg/installer/xz/xzdec.armel-linux
tlpkg/installer/xz/xzdec.i386-freebsd
tlpkg/installer/xz/xzdec.i386-cygwin.exe
tlpkg/installer/xz/xzdec.powerpc-linux
tlpkg/installer/xz/xzdec.x86_64-darwinlegacy
tlpkg/installer/install-tl.html
tlpkg/installer/installer-options.txt
tlpkg/installer/install-menu-text.pl
tlpkg/installer/tracked-install.pl
tlpkg/installer/tl-tray-menu.ini
tlpkg/installer/texlive.png
tlpkg/installer/install-menu-wizard.pl
tlpkg/installer/wget/wget.i386-solaris
tlpkg/installer/wget/wget.amd64-netbsd
tlpkg/installer/wget/wget.x86_64-solaris
tlpkg/installer/wget/wget.x86_64-darwin
tlpkg/installer/wget/wget.i386-netbsd
tlpkg/installer/wget/wget.i386-darwin
tlpkg/installer/wget/wget.amd64-freebsd
tlpkg/installer/wget/wget.x86_64-darwinlegacy
tlpkg/installer/wget/wget.powerpc-darwin
tlpkg/installer/wget/wget.sparc-solaris
tlpkg/installer/wget/wget.i386-freebsd
tlpkg/installer/COPYING.MinGW-runtime.txt
tlpkg/installer/install-menu-perltk.pl
tlpkg/installer/ctan-mirrors.pl
tlpkg/translations/cs.po
tlpkg/translations/nl.po
tlpkg/translations/translators
tlpkg/translations/uk.po
tlpkg/translations/zh_TW.po
tlpkg/translations/ja.po
tlpkg/translations/sl.po
tlpkg/translations/pt_BR.po
tlpkg/translations/vi.po
tlpkg/translations/messages.pot
tlpkg/translations/sk.po
tlpkg/translations/ru.po
tlpkg/translations/de.po
tlpkg/translations/it.po
tlpkg/translations/fr.po
tlpkg/translations/pl.po
tlpkg/translations/es.po
tlpkg/translations/sr.po
tlpkg/translations/zh_CN.po
release-texlive.txt
LICENSE.CTAN
install-tl
texmf-dist/scripts/texlive/tlmgrgui.pl
texmf-dist/scripts/texlive/uninstall-win32.pl
texmf-dist/web2c/updmap-hdr.cfg
texmf-dist/web2c/fmtutil-hdr.cnf
texmf-dist/web2c/texmf.cnf
tlpkg/TeXLive
texmf-dist/scripts/texlive/tlmgr.pl"
