//! Rust functions to convert unsigned 32-bit numbers to and
//! from short alphabetical strings (e.g. spreadsheet column
//! indexes) using bijective base 26.

fn to_bijective_alpha_string(mut n: u32) -> impl AsRef<str> {
    // accumulate the ASCII letters for the digits into a small buffer
    // (in reverse order to avoid having to reverse it at the end)
    let mut digits = [0u8; 7];
    let mut n_digits = 0u8;

    while n > 0 {
        n -= 1;
        digits[6 - n_digits as usize] = b'a' + (n % 26) as u8;
        n_digits += 1;
        n /= 26;
    }

    // dummy struct implementing `AsRef<str>`
    // safety invariant: `digits` must be entirely ASCII
    struct Res {
        n_digits: u8,
        digits: [u8; 7],
    }

    impl AsRef<str> for Res {
        fn as_ref(&self) -> &str {
            let digits = &self.digits[7 - self.n_digits as usize..];
            unsafe {
                std::str::from_utf8_unchecked(digits)
            }
        }
    }

    Res { n_digits, digits }
}

fn from_bijective_alpha_string(s: &str) -> Option<u32> {
    let digits = s.as_bytes();
    let mut res = 0u32;
    let mut i = 1u32;
    for &d in digits.iter().rev() {
        if !(b'a' ..= b'z').contains(&d) {
            return None;
        }
        let digit_val = (d - b'a') as u32;
        res = i.checked_mul(digit_val + 1)?.checked_add(res)?;
        // don't bother to check for overflow here - if it matters, it
        // will be caught by the above statement in the next iteration
        i = i.wrapping_mul(26);
    }
    Some(res)
}

fn test(n: u32) {
    let s = to_bijective_alpha_string(n);
    let m = from_bijective_alpha_string(s.as_ref());
    println!("{} -> {} -> {:?}", n, s.as_ref(), m);
}

fn main() {
    test(std::u32::MAX);
}
