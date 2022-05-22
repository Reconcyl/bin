fn main() {
    let mut s = String::new();
    let mut args = std::env::args();
    let prog_name = args.next().unwrap();
    let mut encode_mode = true;
    for arg in args {
        if encode_mode {
            if let Ok(n) = arg.parse() {
                s.push(char::from_u32(n).unwrap_or(char::REPLACEMENT_CHARACTER));
            } else if arg == "-d" {
                encode_mode = false;
            }
        } else {
            if !s.is_empty() {
                s.push(' ');
            }
            for c in arg.chars() {
                s.push_str(&(c as u32).to_string());
            }
        }
    }
    if s.is_empty() {
        eprintln!("usage: {} [characters...]", prog_name);
    } else {
        println!("{}", s);
    }
}
