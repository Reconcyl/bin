/// A function to display part of a string with a maximum length
/// centered on a given location. If the string is smaller than
/// the maximum length it will be shown in its entirety.
/// Unfortunately, it does not support multi-line strings well
/// and breaks the input into a vector of characters for better
/// Unicode support, which is not efficient.

const CONTEXT_R: usize = 10;
const CONTEXT_W: usize = 2 * CONTEXT_R + 1;

fn print_context(s: &str, idx: usize) {
    let chars: Vec<_> = s.chars().collect();
    let range = if chars.len() < CONTEXT_W {
        0..chars.len()
    } else if idx < CONTEXT_R {
        0..CONTEXT_W
    } else if idx + CONTEXT_R > chars.len() - 1 {
        chars.len() - CONTEXT_W .. chars.len()
    } else {
        idx - CONTEXT_R .. idx + CONTEXT_R + 1
    };
    let offset = idx - range.start;
    print!("{}", if range.start == 0 { '(' } else { ' ' });
    for i in range.clone() {
        print!("{}", chars[i]);
    }
    if range.end == chars.len() { print!(")") };
    println!("\n{:1$}^", "", offset+1);
}

fn main() {
    for s in &["foo", "thequickbrownfoxjumpedoverthelazydog"] {
        for (i, _) in s.chars().enumerate() {
            print_context(s, i);
        }
    }
}
