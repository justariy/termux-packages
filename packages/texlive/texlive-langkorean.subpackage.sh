TERMUX_SUBPKG_DESCRIPTION="Texlive's collection-langkorean"
TERMUX_SUBPKG_DEPENDS="texlive, texlive-langjapanese, texlive-latexrecommended"
TERMUX_SUBPKG_INCLUDE=$(python3 $TERMUX_PKG_BUILDER_DIR/parse_tlpdb.py $(echo $SUB_PKG_NAME | awk -F"-" '{print $2}') $TERMUX_PKG_TMPDIR/texlive.tlpdb)
