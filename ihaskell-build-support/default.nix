let
  # Read in the Niv sources
  sources = import ./nix/sources.nix {};
  # If ./nix/sources.nix file is not found run:
  #   niv init
  #   niv add input-output-hk/haskell.nix -n haskellNix

  # Fetch the haskell.nix commit we have pinned with Niv
  haskellNix = import sources.haskellNix {};
  # If haskellNix is not found run:
  #   niv add input-output-hk/haskell.nix -n haskellNix

  # Import nixpkgs and pass the haskell.nix provided nixpkgsArgs
  pkgs = import
    # haskell.nix provides access to the nixpkgs pins which are used by our CI,
    # hence you will be more likely to get cache hits when using these.
    # But you can also just use your own, e.g. '<nixpkgs>'.
    haskellNix.sources.nixpkgs-unstable
    # These arguments passed to nixpkgs, include some patches and also
    # the haskell.nix functionality itself as an overlay.
    haskellNix.nixpkgsArgs;


  projectDrv = pkgs.haskell-nix.project {
    # 'cleanGit' cleans a source directory based on the files known by git
    src = pkgs.haskell-nix.haskellLib.cleanGit {
      name = "ihaskell-DQ-workbench";
      src = ./.;
    };

    # Specify the GHC version to use.
    compiler-nix-name = "ghc94";

    # Index state (note best practice is to use this with cabal v2-update as well)
    index-state = "2023-10-13T21:48:44Z";
  };

  projectShell = projectDrv.shellFor {
    tools = {
      cabal = "latest";

    };
    # packages = p:
    #   [
    #   ];
    # buildInputs =
    #   [ projectDrv.cabal-install
    #     # Dev dependencies below:
    #     projectDrv.ghcid
    #     # Runtime dependencies below;
    #     pkgs.curl
    #     pkgs.git
    #     pkgs.gitAndTools.hub
    #     pkgs.niv
    #   ];
  };
in
if pkgs.lib.inNixShell then projectShell else projectDrv
