{ pkgs ? (import (builtins.fetchTarball {
  url = https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
}) {}) }:

pkgs.stdenv.mkDerivation {
  name = "site";
  src = ./.;

  buildInputs = with pkgs; [
    (emacsWithPackages (epkgs: with epkgs; [
      # Newer org-mode than built-in
      org

      # Generate RSS feeds
      webfeeder

      # Deps for syntax highlighting for some languages
      htmlize
      go-mode
      nix-mode
      php-mode
    ]))
  ];

  buildPhase = ''
    mkdir -p public/
    emacs -Q --script publish.el
  '';

  installPhase = ''
    cp -vr public/ $out
  '';
}
