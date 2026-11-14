#[path = "pair-abi.rs"]
mod abi;
#[path = "../arm64-code.rs"]
mod code;
#[path = "../numeric/numeric-metadata.rs"]
mod metadata;
#[path = "../numeric/numeric-kernel.rs"]
mod numeric;
#[path = "../numeric/numeric-values.rs"]
mod values;
fn main() {
    let mut c = code::Code::default();
    abi::emit_copy(&mut c).unwrap();
    let (b, d) = c.finish().unwrap();
    assert!(d.is_empty());
    std::fs::write("pair-copy.bin", b).unwrap();
    for (op, name) in [('+', "add"), ('-', "sub"), ('*', "mul"), ('/', "div")] {
        let mut c = code::Code::default();
        abi::emit(&mut c, op).unwrap();
        let (b, d) = c.finish().unwrap();
        let mut all = b.clone();
        all.extend(d);
        std::fs::write(format!("pair-{name}.bin"), all).unwrap();
        std::fs::write(format!("pair-{name}.code-size"), b.len().to_string()).unwrap();
    }
}
