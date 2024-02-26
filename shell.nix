{ withHLS ? false
, pkgs ? import ./nixpkgs.nix
}:
let
  u = import ./util.nix {};
  this = import ./default.nix {};
  ghc = pkgs.haskellPackages.ghcWithPackages
          (ps:  this.getCabalDeps.executableHaskellDepends
             ++ this.getCabalDeps.libraryHaskellDepends
             ++ u.whenFlag withHLS ps.haskell-language-server
          );
in
pkgs.stdenv.mkDerivation {
  name = "local-shell-" + (builtins.baseNameOf ./.)  ;
  buildInputs = [ ghc pkgs.ghcid this pkgs.cabal-install];
}

