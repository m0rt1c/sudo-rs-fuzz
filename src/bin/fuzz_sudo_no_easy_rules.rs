#[macro_use]
extern crate afl;
extern crate sudo_rs;

use std::{fs::File, io::Write, path::PathBuf};
const BASE_PATH: &'static str = "/var/run/sudo-rs/ts";

fn has_skip_pattern(data: &[u8]) -> bool {
    for line in data.split(|&b| b == b'\n') {
        if line.starts_with(b"test ") {
            return true;
        }
        if line.starts_with(b"#include") {
            return true;
        }
        if line.starts_with(b"User_Alias") {
            if let Ok(s) = std::str::from_utf8(line) {
                if s.contains("ALL") {
                    return true;
                }
            }
        }
    }
    false
}

fn main() {
    fuzz!(|data: &[u8]| {
        if has_skip_pattern(data) {
            return;
        }

        let path = "/root/additional";

        if let Ok(mut output) = File::create(path) {
            match output.write_all(data) {
                Ok(_) => {
                    sudo_rs::sudo_main();

                    let uid;
                    unsafe {
                        uid = libc::getuid();
                    }

                    // a succeful login will create a session file
                    // that might create false positives
                    let mut path = PathBuf::from(BASE_PATH);
                    path.push(uid.to_string());
                    let _ = std::fs::remove_file(path);

                    panic!("User passed after sudo -l {}", uid);
                }
                Err(_) => {
                    return;
                }
            }
        }
        // }
    });
}
