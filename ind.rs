use std::io::{self, BufRead as _, Write as _};

fn get_indent() -> Vec<u8> {
    let mut indent = 4u16;
    for arg in std::env::args() {
        if let Ok(i) = arg.parse() {
            indent = i;
        }
    }
    std::iter::repeat(b' ').take(indent as usize).collect()
}

fn main() -> io::Result<()> {
    let indent = get_indent();

    let stdin = io::stdin();
    let stdout = io::stdout();

    let mut stdin = stdin.lock();
    let mut stdout = stdout.lock();

    let mut line = Vec::new();

    while stdin.read_until(b'\n', &mut line)? != 0 {
        stdout.write(&indent)?;
        stdout.write(&line)?;
        line.clear();
    }
    Ok(())
}
