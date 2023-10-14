{ sources ? import ./ihaskell-build-support/nix/sources.nix {}
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
  iHaskellSrc = sources.IHaskell;

  myHaskellPackages = hp: [
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

in
import "${iHaskellSrc}/release.nix" {
  compiler = ghcNixVersion;
  nixpkgs = pkgs;
  packages= myHaskellPackages;
  pythonPackages = (_: []);
  rtsopts = "-Iw15 -H64m -M8G -N2"; # added to the iHaskell command line.
  staticExecutable = false;
  systemPackages = mySystemPackages;
}
