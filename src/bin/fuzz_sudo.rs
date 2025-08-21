#[macro_use]
extern crate afl;
extern crate sudo_rs;

use std::{fs::File, io::Write};

fn main() {
    fuzz!(|data: &[u8]| {
        let path = "/root/additional.sudoers";
        if let Ok(mut output) = File::create(path) {
            if let Ok(s) = std::str::from_utf8(data) {
                match write!(output, "{}", s) {
                    Ok(_) => {
                        sudo_rs::sudo_main();
                        unsafe {
                            let uid = libc::getuid();
                            panic!("User passed after sudo -l {}", uid);
                        }
                    }
                    Err(_) => {
                        return;
                    }
                }
            }
        }
    });
}
