// Host-side decimal-format design model, NOT emitted ARM64 runtime.
// No std float formatting: build the measured 16-digit image explicitly.
// This model remains a development oracle, not a new language admission.
pub fn format(bits: u64, length: usize, dec: usize, mixed: bool) -> Result<Vec<u8>, String> {
    if !matches!(length, 10 | 20) || dec > 435 {
        return Err("format metadata outside bounded profile".into());
    }
    let value = f64::from_bits(bits);
    let width = length + if dec > 0 { 1 + dec } else { 0 };
    if !value.is_finite() {
        return Ok(vec![b'*'; width]);
    }
    if mixed && value >= i64::MIN as f64 && value < 9223372036854775808.0 {
        let i = value as i64;
        if i != i64::MIN && i as f64 == value {
            let actual = if i > 9999999999 || i < -999999999 {
                20
            } else {
                10
            };
            if actual == length {
                let mut digits = unsigned(i.unsigned_abs());
                if i < 0 {
                    digits.insert(0, b'-');
                }
                let mut out = vec![b' '; length.saturating_sub(digits.len())];
                out.extend(digits);
                if dec > 0 {
                    out.push(b'.');
                    out.resize(out.len() + dec, b'0');
                }
                return Ok(out);
            }
        }
    }
    let mut neg = bits >> 63 != 0;
    let mut m = value.abs();
    let mut exponent = 0i32;
    let mut image = [b'0'; 16];
    let mut nonzero = false;
    if m == 0.0 {
        neg = false;
    } else {
        while m >= 10.0 {
            m /= 10.0;
            exponent += 1;
        }
        while m < 1.0 {
            m *= 10.0;
            exponent -= 1;
        }
        let mut n = (m * 1e15 + 0.5) as u64;
        if n == 10000000000000000 {
            n = 1000000000000000;
            exponent += 1;
        }
        nonzero = n != 0;
        for i in (0..16).rev() {
            image[i] = b'0' + (n % 10) as u8;
            n /= 10;
        }
    }
    // Compose a digit-only image through the rounding position. Leading zeros
    // below one and zeros beyond the sixteen significant digits are explicit.
    let intlen = if exponent < 0 {
        1
    } else {
        exponent as usize + 1
    };
    let source = |pos: usize| -> u8 {
        if exponent >= 0 {
            if pos < 16 {
                image[pos]
            } else {
                b'0'
            }
        } else if pos == 0 {
            b'0'
        } else {
            let idx = pos as i32 + exponent;
            if idx < 0 || idx >= 16 {
                b'0'
            } else {
                image[idx as usize]
            }
        }
    };
    let mut digits: Vec<u8> = (0..intlen + dec).map(source).collect();
    if source(intlen + dec) >= b'5' {
        let mut carry = true;
        for d in digits.iter_mut().rev() {
            if *d == b'9' {
                *d = b'0';
            } else {
                *d += 1;
                carry = false;
                break;
            }
        }
        if carry {
            digits.insert(0, b'1');
        }
    }
    // Existing zero/nonzero behavior does not print stale normalized digits.
    if !nonzero && value == 0.0 {
        digits.fill(b'0');
    }
    let integer = digits.len() - dec;
    let mut text = Vec::new();
    if neg {
        text.push(b'-');
    }
    text.extend_from_slice(&digits[..integer]);
    if dec > 0 {
        text.push(b'.');
        text.extend_from_slice(&digits[integer..]);
    }
    if text.len() > 456 {
        return Err("bounded compose scratch exceeded".into());
    }
    let mut out = vec![b' '; width.saturating_sub(text.len())];
    out.extend(text);
    Ok(out)
}
fn unsigned(mut n: u64) -> Vec<u8> {
    let mut v = Vec::new();
    loop {
        v.push(b'0' + (n % 10) as u8);
        n /= 10;
        if n == 0 {
            break;
        }
    }
    v.reverse();
    v
}
fn main() {
    use std::io::{Read, Write};
    let mut b = Vec::new();
    std::io::stdin().read_to_end(&mut b).unwrap();
    assert_eq!(b.len() % 17, 0);
    let mut out = Vec::new();
    for c in b.chunks_exact(17) {
        let bits = u64::from_le_bytes(c[..8].try_into().unwrap());
        let length = u32::from_le_bytes(c[8..12].try_into().unwrap()) as usize;
        let dec = u32::from_le_bytes(c[12..16].try_into().unwrap()) as usize;
        let text = format(bits, length, dec, c[16] != 0).unwrap();
        out.extend_from_slice(&(text.len() as u32).to_le_bytes());
        out.extend(text);
    }
    std::io::stdout().write_all(&out).unwrap();
}
