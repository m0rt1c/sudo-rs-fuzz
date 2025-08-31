{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.rust-analyzer
    pkgs.rustup
    pkgs.rustc
    pkgs.cargo
    pkgs.python3
    pkgs.python3Packages.black
  ];
}

