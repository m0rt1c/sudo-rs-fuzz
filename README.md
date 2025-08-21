## Creating a VM

1. Install Nix
1. Create the vm `./init_vm.sh`
1. Manually start it with `./run_vm.sh` or `./result/bin/run-nixos-vm -display none -serial mon:stdio -enable-kvm -cpu host -m 4G`

### Building the fuzzer target (from inside the VM)

1. git clone this repo
1. cd `sudo-rs-fuzz` 
1. `cargo install cargo-afl`
1. `cargo afl build`

## Setup

You must:

1. to run this target with a user that is not in any sudoers rule
1. `chmod u+s` and `chown root:root` `./target/debug/fuzz_sudo` before running (and after every build) 
1. run this in a VM to not break your system
1. have an entry in `/etc/sudoers` that says `#includedir /root`, we will write a file with fuzzed rules to `/root/additional.sudoers`
1. run only one fuzzer instance, more will write on the same file an break everything

## Fuzzing commands

```
cargo afl fuzz -i in -o out ./target/debug/fuzz_sudo -l
```

Like this we can fuzz the `-l` option of sudo

## Todo

1. We could fuzz env vars too by setting them with `std::env:set_var`
1. Since this is run with `suid` and owned by `root` we could change user properties too (e.g. name, home path)

