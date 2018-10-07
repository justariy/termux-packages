#!/usr/bin/python3

def parse_tlpdb_to_dict(tlpdb_path):
    """Reads given tlpdb database and creates dict with packages and their dependencies and files
    """

    with open(tlpdb, "r") as f:
        packages = f.read().split("\n\n")

    pkg_dict = {}
    for pkg in packages:
        if not pkg == "":
            pkg_lines = pkg.split("\n")
            pkg_name = pkg_lines[0].split(" ")[1]
            # We only care about getting all the files so only check for "depend" and files
            pkg_dict[pkg_name] = {"depends" : [], "files" : []}
            for line in pkg_lines:
                line_description = line.split(" ")[0]
                if line_description == "":
                    pkg_dict[pkg_name]["files"].append(line.split(" ")[1])
                elif line_description == "depend":
                    pkg_dict[pkg_name]["depends"].append(line.split(" ")[1])
    return pkg_dict

def get_files_in_package(package, files_in_package, visited_pkgs, visit_collections=False):
    """Prints files in package and then run itself on each dependency. Doesn't visit collections unless argument visit_collections=True is passed.
    """
    for f in pkg_dict[package]["files"]:
        files_in_package.append(f)
    for dep in pkg_dict[package]["depends"]:
        # skip arch dependent packages, which we lack since we build our own binaries:
        if not dep.split(".")[-1] == "ARCH":
            # skip collections unless explicitly told to go through them
            if not dep.split("-")[0] == "collection" or visit_collections:
                # avoid duplicates:
                if not dep in visited_pkgs:
                    visited_pkgs.append(dep)
                    files_in_package, visited_pkgs = get_files_in_package(dep, files_in_package, visited_pkgs)
    return files_in_package, visited_pkgs

def Files(*args, **kwargs):
    """Wrapper around function get_files. Prepends "collection-" to package unless prepend_collection=False is passed. Also uses visit_collections=False per default.
    """
    prefix = "collection-"
    bool_visit_collections = False
    for k,v in kwargs.items():
        if k == "prepend_collection" and not v:
            prefix = ""
        elif k == "visit_collections" and v:
            bool_visit_collections = True

    files = []
    for pkg in args[0]:
        files += get_files_in_package(prefix+pkg, [], [], visit_collections=bool_visit_collections)[0]
    return files

import sys
tlpdb = sys.argv[2]
pkg_dict = parse_tlpdb_to_dict(tlpdb)

def get_conflicting_pkgs(package):
    """Returns list of packages that contain some files that are also found in 'package'.
    These packages should be listed as dependencies.
    """
    if package in ["basic", "fontsrecommended", "games", "luatex",
                   "music", "plaingeneric", "publishers", "texworks", "wintools"]:
        return []
    elif package in ["latex", "langeuropean", "langenglish", "langfrench",
                     "langgerman", "binextra", "fontutils", "langarabic",
                     "langgreek", "langitalian", "langother", "langpolish",
                     "langportuguese", "langspanish", "metapost"]:
        return ["basic"]
    elif package == "langczechslovak":
        return ["basic", "latex", "fontsextra", "luatex"]
    elif package == "langcyrillic":
        return ["basic", "latex", "fontsextra", "fontsrecommended",
                "langgreek", "latexrecommended"]
    elif package == "formatsextra":
        return ["basic", "latex", "langcyrillic", "mathscience",
                "fontsrecommended", "plaingeneric"]
    elif package == "context":
        return ["basic", "latex", "mathscience", "fontsrecommended",
                "metapost", "xetex"]
    elif package == "langjapanese":
        return ["basic", "latex", "langcjk", "langchinese"]
    elif package == "langchinese":
        return ["basic", "langcjk", "fontutils"]
    elif package == "bibtexextra":
        return ["basic", "binextra"]
    elif package == "langcjk":
        return ["basic", "langkorean", "langother"]
    elif package == "latexrecommended":
        return ["basic", "fontsrecommended", "latexextra", "pictures", "plaingeneric"]
    elif package == "mathscience":
        return ["basic", "langgreek"]
    elif package == "langkorean":
        return ["langjapanese", "latexrecommended"]
    elif package == "latexextra":
        return ["fontsextra"]
    elif package == "humanities":
        return ["latexextra"]
    elif package == "pictures":
        return ["latexextra"]
    elif package == "fontsextra":
        return ["plaingeneric"]
    elif package == "pstricks":
        return ["plaingeneric"]
    elif package == "xetex":
        return ["latex"]
    else:
        raise ValueError(sys.argv[1]+" isn't a known package name")
print("\n".join(["share/texlive/"+line for line in
                 list( set(Files([sys.argv[1]])) - set(Files(get_conflicting_pkgs(sys.argv[1]))) )]))
