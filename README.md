# ∆QSD workbench
A iHaskell-based (Juypter) notebook based workbench for the ∆QSD framework

## Installation

It is assumed that you are either running `NixOS` or have [`nix`
installed](https://nixos.org/download) on your machine, the workbench is known
to work under linux and macOS on X86 and ARM hardware.

This project makes use of the [`haskell.nix`](https://input-output-hk.github.io/haskell.nix/index.html) framework.
It is recommended to [add the build cache](https://input-output-hk.github.io/haskell.nix/tutorials/getting-started)
to your nix installation to speed up the workbench install.

Although some example juypter notebooks are supplied - it is recommended that
you clone this repository (dqdq-workbench) in a directory structure that looks
like:

```
├── Notebooks
│   ├── ...
│   └── ...
├── dqsd-workbench
└── run-my-workbench
```

You will need to create the directory `Notebooks` and the wrapper script `run-my-workbench`

### Installation steps

In your target directory clone the repository
```
git clone https://github.com/DeltaQ-SD/dqsd-workbench.git
```

Make the `Notebooks` directory
```
mkdir Notebooks
```

At this point you might wish to copy the example notebooks from
`dqsd-workbench/ExampleNotebooks` into your own notebook directory.

You then want to create a wrapper script (example below).

## Example wrapper script

```
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
```

## Upgrading

Note that the build scripts use a symbolic link to cache built notebook. After upgrading the repository:
```
cd dqsd-workbench; git pull
```

you will want to remove the `iHaskell` symbolic link in the `dqsd-workbenc`,
this will cause the updated version to be built when your wrapper script is next
run.
