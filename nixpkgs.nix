let
  nixpkgs = import (builtins.fetchTarball {
    # Descriptive name to make the store path easier to identify
    name = "nixos-unstable-2023-11-26";
    # git ls-remote https://github.com/nixos/nixpkgs <channel>
    url = "https://github.com/nixos/nixpkgs/archive/5631ea37394bb38556cbb2b4142cd28ba49ff2d9.tar.gz";
    # nix-prefetch-url --unpack <url>
    sha256 = "11k114qrmg40mnm81x2hihs7apkffnkrichk3la90718pbb0da03";
  }) ;
  # local = import <nixpkgs> ;

  # Config to inport external packages
  config.packageOverrides = pkgs: rec { haskellPackages =
    let mkDerivation = expr: pkgs.haskellPackages.mkDerivation (expr // {
          enableSeparateDocOutput = true;
          doHaddock = true;
          doCheck = true;
        });
    in
    pkgs.haskellPackages.override { overrides = hpkgs: opkgs:{
         godot-ser = import ./local/godot-ser/default.nix { inherit pkgs hpkgs mkDerivation; };
         godot-lang = import ./local/godot-lang/default.nix { inherit pkgs hpkgs mkDerivation; };
      };
    };
  };
in nixpkgs { inherit config; }
