#!/usr/bin/env bash

set -ex

rm -f ./nixos.qcow2
nix-build '<nixpkgs/nixos>' -A vm -I nixos-config=./configuration.nix
./run_vm.sh
