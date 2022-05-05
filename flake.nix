{
  description = "Nix Blog";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        name = "nix-blog";
        emacs = (pkgs.emacsWithPackages (epkgs: [
          epkgs.org
        ])).overrideAttrs (old: {
          configureFlags = [
            "--disable-build-details"
            "--with-modules"
            "--without-ns"
            "--with-x=no"
            "--with-xpm=no"
            "--with-jpeg=no"
            "--with-png=no"
            "--with-gif=no"
            "--with-tiff=no"
            ];
        });
      in rec {
        packages."${name}" = pkgs.stdenv.mkDerivation {
          pname = name;
          version = "1.0";
          src = ./.;
          buildInputs = [ emacs ];
          buildPhase = ''
            mkdir -p public/
           
            emacs --script publish.el
          '';
          installPhase = "cp -r public $out";
        };
        defaultPackage = packages."${name}";
      });
}

