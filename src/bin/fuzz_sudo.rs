#[macro_use]
extern crate afl;
extern crate sudo_rs;

use std::{fs::File, io::Write, path::PathBuf};
const BASE_PATH: &'static str = "/var/run/sudo-rs/ts";

fn main() {
    fuzz!(|data: &[u8]| {
        let path = "/root/additional";
        if let Ok(mut output) = File::create(path) {
            if let Ok(s) = std::str::from_utf8(data) {
                match write!(output, "{}", s) {
                    Ok(_) => {
                        sudo_rs::sudo_main();
                        unsafe {
                            let uid = libc::getuid();
                
                            // a succeful login will create a session file
                            // that might create false positives
                            let mut path = PathBuf::from(BASE_PATH);
                            path.push(uid.to_string());
                            let _ = std::fs::remove_file(path);

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
