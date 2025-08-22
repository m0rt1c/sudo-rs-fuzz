#!/usr/bin/env bash

./result/bin/run-nixos-vm \
    -display none \
    -serial mon:stdio \
    -enable-kvm \
    -cpu host \
    -m 4G
