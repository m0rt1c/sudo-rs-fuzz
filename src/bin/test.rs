#[macro_use]
extern crate afl;
extern crate sudo_rs;

use std::io::{self, Write};
const NEW_LINE: [u8; 1] = [0x0a];

fn main() {
    unsafe {
        let uid = libc::getuid();
        print!("before {}", uid);
    }

    fuzz!(|data: &[u8]| {
        let _ = io::stdout().write(data);
        let _ = io::stdout().write(&NEW_LINE);

        sudo_rs::sudo_main();
        unsafe {
            let uid = libc::getuid();
            print!("after {}", uid);
        }
    });
}
