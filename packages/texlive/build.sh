TERMUX_PKG_HOMEPAGE=https://www.tug.org/texlive/
TERMUX_PKG_DESCRIPTION="TeX Live is a distribution of the TeX typesetting system."
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
_MAJOR_VERSION=20170524
TERMUX_PKG_VERSION=${_MAJOR_VERSION}
TERMUX_PKG_REVISION=5
TERMUX_PKG_SRCURL=("ftp://ftp.tug.org/texlive/historic/${TERMUX_PKG_VERSION:0:4}/texlive-$_MAJOR_VERSION-texmf.tar.xz" "ftp://ftp.tug.org/texlive/historic/${TERMUX_PKG_VERSION:0:4}/texlive-$_MAJOR_VERSION-extra.tar.xz")
TERMUX_PKG_SHA256=("3f63708b77f8615ec6f2f7c93259c5f584d1b89dd335a28f2362aef9e6f0c9ec"
"afe49758c26fb51c2fae2e958d3f0c447b5cc22342ba4a4278119d39f5176d7f")
TERMUX_PKG_DEPENDS="perl, texlive-bin (>= 20170524-7)"
TERMUX_PKG_RECOMMENDS="texlive-tlmgr"
TERMUX_PKG_CONFLICTS="texlive (<< 20170524-5)"
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
# Files to rm, first from texlive-$_MAJOR_VERSION-extra
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
texmf-dist/scripts/texlive/tlmgr.pl
texmf-dist/bibtex/csf/base/88591lat.csf
texmf-dist/bibtex/csf/base/88591sca.csf
texmf-dist/bibtex/csf/base/ascii.csf
texmf-dist/bibtex/csf/base/cp437lat.csf
texmf-dist/bibtex/csf/base/cp850lat.csf
texmf-dist/bibtex/csf/base/cp850sca.csf
texmf-dist/bibtex/csf/base/cp866rus.csf
texmf-dist/bibtex/csf/base/csfile.txt
texmf-dist/chktex/chktexrc
texmf-dist/doc/bibtex8/00readme.txt
texmf-dist/doc/bibtex8/HISTORY
texmf-dist/doc/bibtex8/csfile.txt
texmf-dist/doc/bibtex8/file_id.diz
texmf-dist/doc/chktex/ChkTeX.pdf
texmf-dist/fonts/enc/ttf2pk/base/T1-WGL4.enc
texmf-dist/fonts/sfd/ttf2pk/Big5.sfd
texmf-dist/fonts/sfd/ttf2pk/EUC.sfd
texmf-dist/fonts/sfd/ttf2pk/HKSCS.sfd
texmf-dist/fonts/sfd/ttf2pk/KS-HLaTeX.sfd
texmf-dist/fonts/sfd/ttf2pk/SJIS.sfd
texmf-dist/fonts/sfd/ttf2pk/UBg5plus.sfd
texmf-dist/fonts/sfd/ttf2pk/UBig5.sfd
texmf-dist/fonts/sfd/ttf2pk/UGB.sfd
texmf-dist/fonts/sfd/ttf2pk/UGBK.sfd
texmf-dist/fonts/sfd/ttf2pk/UJIS.sfd
texmf-dist/fonts/sfd/ttf2pk/UKS-HLaTeX.sfd
texmf-dist/fonts/sfd/ttf2pk/UKS.sfd
texmf-dist/fonts/sfd/ttf2pk/Unicode.sfd
texmf-dist/hbf2gf/b5ka12.cfg
texmf-dist/hbf2gf/b5kr12.cfg
texmf-dist/hbf2gf/b5so12.cfg
texmf-dist/hbf2gf/c1so12.cfg
texmf-dist/hbf2gf/c2so12.cfg
texmf-dist/hbf2gf/c3so12.cfg
texmf-dist/hbf2gf/c4so12.cfg
texmf-dist/hbf2gf/c5so12.cfg
texmf-dist/hbf2gf/c6so12.cfg
texmf-dist/hbf2gf/c7so12.cfg
texmf-dist/hbf2gf/csso12.cfg
texmf-dist/hbf2gf/gsfs14.cfg
texmf-dist/hbf2gf/j2so12.cfg
texmf-dist/hbf2gf/jsso12.cfg
texmf-dist/hbf2gf/ksso17.cfg
texmf-dist/scripts/a2ping/a2ping.pl
texmf-dist/scripts/accfonts/mkt1font
texmf-dist/scripts/accfonts/vpl2ovp
texmf-dist/scripts/accfonts/vpl2vpl
texmf-dist/scripts/adhocfilelist/adhocfilelist.sh
texmf-dist/scripts/arara/arara.sh
texmf-dist/scripts/authorindex/authorindex
texmf-dist/scripts/bibexport/bibexport.sh
texmf-dist/scripts/bundledoc/arlatex
texmf-dist/scripts/bundledoc/bundledoc
texmf-dist/scripts/cachepic/cachepic.tlu
texmf-dist/scripts/checklistings/checklistings.sh
texmf-dist/scripts/chktex/chkweb.sh
texmf-dist/scripts/chktex/deweb.pl
texmf-dist/scripts/cjk-gs-integrate/cjk-gs-integrate.pl
texmf-dist/scripts/context/stubs/unix/context
texmf-dist/scripts/context/stubs/unix/contextjit
texmf-dist/scripts/context/stubs/unix/luatools
texmf-dist/scripts/context/stubs/unix/mtxrun
texmf-dist/scripts/context/stubs/unix/mtxrunjit
texmf-dist/scripts/context/stubs/unix/texexec
texmf-dist/scripts/context/stubs/unix/texmfstart
texmf-dist/scripts/convbkmk/convbkmk.rb
texmf-dist/scripts/crossrefware/bbl2bib.pl
texmf-dist/scripts/crossrefware/bibdoiadd.pl
texmf-dist/scripts/crossrefware/bibmradd.pl
texmf-dist/scripts/crossrefware/bibzbladd.pl
texmf-dist/scripts/crossrefware/ltx2crossrefxml.pl
texmf-dist/scripts/ctanify/ctanify
texmf-dist/scripts/ctanupload/ctanupload.pl
texmf-dist/scripts/de-macro/de-macro
texmf-dist/scripts/diadia/diadia.lua
texmf-dist/scripts/dosepsbin/dosepsbin.pl
texmf-dist/scripts/dtxgen/dtxgen
texmf-dist/scripts/dviasm/dviasm.py
texmf-dist/scripts/ebong/ebong.py
texmf-dist/scripts/epspdf/epspdf.tlu
texmf-dist/scripts/epspdf/epspdftk.tcl
texmf-dist/scripts/epstopdf/epstopdf.pl
texmf-dist/scripts/exceltex/exceltex
texmf-dist/scripts/fig4latex/fig4latex
texmf-dist/scripts/findhyph/findhyph
texmf-dist/scripts/fontools/afm2afm
texmf-dist/scripts/fontools/autoinst
texmf-dist/scripts/fontools/ot2kpx
texmf-dist/scripts/fragmaster/fragmaster.pl
texmf-dist/scripts/getmap/getmapdl.lua
texmf-dist/scripts/glossaries/makeglossaries
texmf-dist/scripts/glossaries/makeglossaries-lite.lua
texmf-dist/scripts/installfont/installfont-tl
texmf-dist/scripts/kotex-utils/jamo-normalize.pl
texmf-dist/scripts/kotex-utils/komkindex.pl
texmf-dist/scripts/kotex-utils/ttf2kotexfont.pl
texmf-dist/scripts/latex-git-log/latex-git-log
texmf-dist/scripts/latex-papersize/latex-papersize.py
texmf-dist/scripts/latex2man/latex2man
texmf-dist/scripts/latex2nemeth/latex2nemeth
texmf-dist/scripts/latexdiff/latexdiff-vc.pl
texmf-dist/scripts/latexdiff/latexdiff.pl
texmf-dist/scripts/latexdiff/latexrevise.pl
texmf-dist/scripts/latexfileversion/latexfileversion
texmf-dist/scripts/latexindent/latexindent.pl
texmf-dist/scripts/latexmk/latexmk.pl
texmf-dist/scripts/latexpand/latexpand
texmf-dist/scripts/lilyglyphs/lily-glyph-commands.py
texmf-dist/scripts/lilyglyphs/lily-image-commands.py
texmf-dist/scripts/lilyglyphs/lily-rebuild-pdfs.py
texmf-dist/scripts/listbib/listbib
texmf-dist/scripts/listings-ext/listings-ext.sh
texmf-dist/scripts/ltxfileinfo/ltxfileinfo
texmf-dist/scripts/ltximg/ltximg.pl
texmf-dist/scripts/lwarp/lwarpmk.lua
texmf-dist/scripts/m-tx/m-tx.lua
texmf-dist/scripts/make4ht/make4ht
texmf-dist/scripts/makedtx/makedtx.pl
texmf-dist/scripts/match_parens/match_parens
texmf-dist/scripts/mathspic/mathspic.pl
texmf-dist/scripts/mf2pt1/mf2pt1.pl
texmf-dist/scripts/mkgrkindex/mkgrkindex
texmf-dist/scripts/mkjobtexmf/mkjobtexmf.pl
texmf-dist/scripts/mkpic/mkpic
texmf-dist/scripts/multibibliography/multibibliography.pl
texmf-dist/scripts/musixtex/musixflx.lua
texmf-dist/scripts/musixtex/musixtex.lua
texmf-dist/scripts/pax/pdfannotextractor.pl
texmf-dist/scripts/pdfbook2/pdfbook2
texmf-dist/scripts/pdfcrop/pdfcrop.pl
texmf-dist/scripts/pdfjam/pdf180
texmf-dist/scripts/pdfjam/pdf270
texmf-dist/scripts/pdfjam/pdf90
texmf-dist/scripts/pdfjam/pdfbook
texmf-dist/scripts/pdfjam/pdfflip
texmf-dist/scripts/pdfjam/pdfjam
texmf-dist/scripts/pdfjam/pdfjam-pocketmod
texmf-dist/scripts/pdfjam/pdfjam-slides3up
texmf-dist/scripts/pdfjam/pdfjam-slides6up
texmf-dist/scripts/pdfjam/pdfjoin
texmf-dist/scripts/pdfjam/pdfnup
texmf-dist/scripts/pdfjam/pdfpun
texmf-dist/scripts/pdflatexpicscale/pdflatexpicscale.pl
texmf-dist/scripts/pdfxup/pdfxup
texmf-dist/scripts/pedigree-perl/pedigree.pl
texmf-dist/scripts/perltex/perltex.pl
texmf-dist/scripts/petri-nets/pn2pdf
texmf-dist/scripts/pfarrei/a5toa4.tlu
texmf-dist/scripts/pfarrei/pfarrei.tlu
texmf-dist/scripts/pkfix/pkfix.pl
texmf-dist/scripts/pkfix-helper/pkfix-helper
texmf-dist/scripts/pmxchords/pmxchords.lua
texmf-dist/scripts/ps2eps/ps2eps.pl
texmf-dist/scripts/pst-pdf/ps4pdf
texmf-dist/scripts/pst2pdf/pst2pdf.pl
texmf-dist/scripts/ptex-fontmaps/kanji-config-updmap-sys.sh
texmf-dist/scripts/ptex-fontmaps/kanji-config-updmap-user.sh
texmf-dist/scripts/ptex-fontmaps/kanji-config-updmap.pl
texmf-dist/scripts/ptex-fontmaps/kanji-fontmap-creator.pl
texmf-dist/scripts/ptex2pdf/ptex2pdf.lua
texmf-dist/scripts/purifyeps/purifyeps
texmf-dist/scripts/pygmentex/pygmentex.py
texmf-dist/scripts/pythontex/depythontex.py
texmf-dist/scripts/pythontex/pythontex.py
texmf-dist/scripts/rubik/rubikrotation.pl
texmf-dist/scripts/splitindex/splitindex.pl
texmf-dist/scripts/srcredact/srcredact.pl
texmf-dist/scripts/sty2dtx/sty2dtx.pl
texmf-dist/scripts/svn-multi/svn-multi.pl
texmf-dist/scripts/tex4ebook/tex4ebook
texmf-dist/scripts/tex4ht/ht.sh
texmf-dist/scripts/tex4ht/htcontext.sh
texmf-dist/scripts/tex4ht/htlatex.sh
texmf-dist/scripts/tex4ht/htmex.sh
texmf-dist/scripts/tex4ht/httex.sh
texmf-dist/scripts/tex4ht/httexi.sh
texmf-dist/scripts/tex4ht/htxelatex.sh
texmf-dist/scripts/tex4ht/htxetex.sh
texmf-dist/scripts/tex4ht/mk4ht.pl
texmf-dist/scripts/texcount/texcount.pl
texmf-dist/scripts/texdef/texdef.pl
texmf-dist/scripts/texdiff/texdiff
texmf-dist/scripts/texdirflatten/texdirflatten
texmf-dist/scripts/texdoc/texdoc.tlu
texmf-dist/scripts/texdoctk/texdoctk.pl
texmf-dist/scripts/texfot/texfot.pl
texmf-dist/scripts/texlive/e2pall.pl
texmf-dist/scripts/texlive/fmtutil-user.sh
texmf-dist/scripts/texlive/fontinst.sh
texmf-dist/scripts/texlive/ps2frag.sh
texmf-dist/scripts/texlive/pslatex.sh
texmf-dist/scripts/texlive/rubibtex.sh
texmf-dist/scripts/texlive/rumakeindex.sh
texmf-dist/scripts/texlive/rungs.tlu
texmf-dist/scripts/texlive/updmap-user.sh
texmf-dist/scripts/texliveonfly/texliveonfly.py
texmf-dist/scripts/texloganalyser/texloganalyser
texmf-dist/scripts/texosquery/texosquery-jre5.sh
texmf-dist/scripts/texosquery/texosquery-jre8.sh
texmf-dist/scripts/texosquery/texosquery.sh
texmf-dist/scripts/thumbpdf/thumbpdf.pl
texmf-dist/scripts/typeoutfileinfo/typeoutfileinfo.sh
texmf-dist/scripts/ulqda/ulqda.pl
texmf-dist/scripts/urlbst/urlbst
texmf-dist/scripts/vpe/vpe.pl
texmf-dist/scripts/yplan/yplan
texmf-dist/source/fonts/zhmetrics/ttfonts.map
texmf-dist/ttf2pk/VPS.rpl
texmf-dist/ttf2pk/ttf2pk.cfg"
