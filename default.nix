{ sources ? import ./workbench-support/nix/sources.nix {}
, haskellNix ? import sources.haskellNix {}
, ghcNixVersion ? "ghc94"
, index-state ? "2023-10-13T21:48:44Z"
}:
let
  pkgs =
    let pkgs' = import haskellNix.sources.nixpkgs-unstable {};
        lib = pkgs'.lib;
        args' = lib.recursiveUpdate haskellNix.nixpkgsArgs {config = myOverlay;};
    in import haskellNix.sources.nixpkgs-unstable args';

  myOverlay = {
    packageOverrides = pkgs': rec {
      haskell = pkgs'.haskell // {
        packages = pkgs'.haskell.packages // {
          "${ghcNixVersion}" = pkgs'.haskell.packages."${ghcNixVersion}".override {
            overrides = self: super: let
              localAddPkg = n: s: c: haskell.lib.dontCheck (self.callCabal2nix n s c);
            in rec {
 #
 # This is where the additional packages are brought into scope
 #
              workbench-support = localAddPkg "workbench-support" ./workbench-support {};
              dqsd-classes      = localAddPkg "dqsq-classes" sources.dqsd-classes {};
              dqsd-piecewise-poly = localAddPkg "dqsq-piecewise-poly" sources.dqsd-piecewise-poly {};
 #
            };
          };
        };
      };
    };
  };



  myHaskellPackages = hp: [
   hp.workbench-support

   hp.contra-tracer
   hp.Chart
   hp.HaTeX
   hp.diagrams

   hp.ihaskell-basic
   hp.ihaskell-blaze
   hp.ihaskell-charts
   hp.ihaskell-diagrams
   hp.ihaskell-graphviz
   hp.ihaskell-hatex
   hp.ihaskell-juicypixels
   # ihaskell-widgets can cause compilation issues
   # hp.ihaskell-widgets
   ];

  mySystemPackages = sp: [
    (sp.texlive.combine {
      inherit (sp.texlive)
        scheme-medium
        adjustbox
        collectbox
        environ
        enumitem
        tcolorbox
        titling
        ucs
        upquote
      ;
    })
    sp.inkscape
    sp.pandoc
    sp.graphviz
  ];

  myPythonPackages = pp: [
  ];

  iHaskellSrc = sources.IHaskell;
in
import "${iHaskellSrc}/release.nix" {
  compiler = ghcNixVersion;
  nixpkgs = pkgs;
  packages= myHaskellPackages;
  pythonPackages = myPythonPackages;
  rtsopts = "-Iw15 -H64m -M8G -N2"; # added to the iHaskell command line.
  staticExecutable = false;
  systemPackages = mySystemPackages;
}
