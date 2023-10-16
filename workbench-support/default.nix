{ sources ? import ./nix/sources.nix {}
, haskellNix ? import sources.haskellNix {}
, pkgs ? import
  # haskell.nix provides access to the nixpkgs pins which are used by our CI,
  # hence you will be more likely to get cache hits when using these.
  # But you can also just use your own, e.g. '<nixpkgs>'.
  haskellNix.sources.nixpkgs-unstable
  # These arguments passed to nixpkgs, include some patches and also
  # the haskell.nix functionality itself as an overlay.
  haskellNix.nixpkgsArgs
, ghcNixVersion ? "ghc94"
, index-state ? "2023-10-13T21:48:44Z"
}:
let
  projectDrv = pkgs.haskell-nix.project {
    # 'cleanGit' cleans a source directory based on the files known by git
    src = pkgs.haskell-nix.haskellLib.cleanGit {
      name = "ihaskell-DQ-workbench";
      src = ./.;
    };

    # Specify the GHC version to use.
    compiler-nix-name = ghcNixVersion;

    # Index state (note best practice is to use this with cabal v2-update as well)
    index-state = index-state;
  };

  projectShell = projectDrv.shellFor {
    tools = {
      cabal = "latest";
      ghcid = "latest";
    };
    buildInputs =
      [ # dependencies for development below
        pkgs.curl
        pkgs.git
        pkgs.gitAndTools.hub
        pkgs.niv
      ];
  };
in
if pkgs.lib.inNixShell then projectShell else projectDrv
