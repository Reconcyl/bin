/// Remove a file, but only if it is empty (the file analogue to `rmdir`).
/// This is not atomic - any data written to the file after the check will
/// be lost.

use std::ffi::OsStr;
use std::fs::{self, File};
use std::io::{self, Read as _};

fn is_empty(p: &OsStr) -> io::Result<bool> {
    match File::open(p)?.bytes().next() {
        Some(Ok(_)) => Ok(false),
        Some(Err(e)) => Err(e),
        None => Ok(true),
    }
}

fn rm_if_empty(p: &OsStr) -> io::Result<()> {
    if is_empty(p)? {
        fs::remove_file(p)
    } else {
        Err(io::Error::new(io::ErrorKind::InvalidData, "Not empty"))
    }
}

fn main() {
    let mut args = std::env::args_os();
    let mut any_files = false;

    let prog_name = args.next().and_then(|n| n.into_string().ok())
        .unwrap_or_else(|| String::from("rmfile"));

    for path in args {
        any_files = true;
        if let Err(e) = rm_if_empty(&path) {
            match path.into_string() {
                Ok(p) => eprintln!("{}: cannot remove '{}': {}", prog_name, p, e),
                Err(_) => eprintln!("{}: cannot remove file: {}", prog_name, e),
            }
        }
    }

    if !any_files {
        eprintln!("usage: {} file ...", prog_name);
    }
}
