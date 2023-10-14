#! /usr/bin/env bash
BASEDIR=$(dirname $0)

# Use the symbolic link target, when present
if ! [ -e ${BASEDIR}/iHaskell ]
then PKGDIR=$(nix-build ${BASEDIR}/default.nix -o ${BASEDIR}/iHaskell)
else PKGDIR=$(readlink ${BASEDIR}/iHaskell)
fi

if [ "x${NOTEBOOKDIR}" == "x" ]
then echo must set the enviroment variable NOTEBOOKDIR to where you want your juypter notebooks
     exit 1
fi

(cd ${NOTEBOOKDIR}; ${PKGDIR}/bin/jupyter lab --no-browser $*)
