## Creating a VM

1. Install Nix
1. Create the vm `./init_vm.sh`
1. Manually start it with `./run_vm.sh` or `./result/bin/run-nixos-vm -display none -serial mon:stdio -enable-kvm -cpu host -m 4G`

### Leaving the VM

Login as root and run `poweroff`

## Building the fuzzer target (from inside the VM)

1. `git clone https://github.com/m0rt1c/sudo-rs-fuzz --depth 1`
1. cd `sudo-rs-fuzz` 
1. `rustup default stable`
1. `cargo install cargo-afl`
1. `RUSTFLAGS="-L /run/current-system/sw/lib" AFL_LLVM_CMPLOG=1 cargo afl build`
1.  Login as root and run `echo core | tee /proc/sys/kernel/core_pattern`

## Setup

You must:

1. to run this target with a user that is not in any sudoers rule
1. Login as root to `chmod u+s` and `chown root:root` `./target/debug/fuzz_sudo` before running (and after every build) 
1. run this in a VM to not break your system
1. have an entry in `/etc/sudoers` that says `#includedir /root`, we will write a file with fuzzed rules to `/root/additional.sudoers`
1. run only one fuzzer instance, more will write on the same file and make the results useless

## Fuzzing commands

I suggest running it in a `tmux` shell

```bash
cargo afl fuzz -a text -i in -o out ./target/debug/fuzz_sudo -l
```

Like this we can fuzz the `-l` option of sudo.
The important part here is that if the user is not in sudoers `sudo-rs` -l will just quit immediately after parsing `/etc/sudoers` and judging the policies for user `test`.

### Test crash

To test a crash see the following command. What this setup is looking for is any sudoers file that will allow the user `test` to run any command with sudo. Note, among them there will be legitimate files, but we might be able to catch parsing error too.

```bash
echo 'test ALL=(ALL:ALL) ALL' | ./target/debug/fuzz_sudo -l
```

## To do

1. Fix inode bugs, after fuzzing for a while the fs runs out of inodes
    1. Found the cause! `sudo-rs` is creating for each run a file in `/tmp/sudo-dev-[0-9]+.log` and we do not remove it
    1. as a workaround I am starting the fuzzer in the VM in a tmux session and on another tmux session I am deleting the logs
1. We could fuzz env vars too by setting them with `std::env:set_var`
1. Since this is run with `suid` and owned by `root` we could change user properties too (e.g. name, home path)
1. Share out folder with host
