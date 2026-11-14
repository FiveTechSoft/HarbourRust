#[path = "../arm64-code.rs"]
mod code;
#[path = "decimal-compose.rs"]
mod compose;
#[path = "decimal-image.rs"]
mod decimal;
#[path = "numeric-metadata.rs"]
mod metadata;
#[path = "decimal-mixed.rs"]
mod mixedformat;
#[path = "numeric-kernel.rs"]
mod numeric;
#[path = "numeric-values.rs"]
mod values;
fn main() {
    for (op, name) in [('+', "add"), ('-', "sub"), ('*', "mul"), ('/', "div")] {
        let mut c = code::Code::default();
        values::emit(&mut c, op).unwrap();
        let (b, _) = c.finish().unwrap();
        std::fs::write(format!("values-{name}.bin"), b).unwrap();
    }

    let mut m = code::Code::default();
    mixedformat::emit(&mut m).unwrap();
    let (b, _) = m.finish().unwrap();
    std::fs::write("decimal-mixed.bin", b).unwrap();
    let mut f = code::Code::default();
    compose::emit(&mut f).unwrap();
    let (b, _) = f.finish().unwrap();
    std::fs::write("decimal-compose.bin", b).unwrap();
    let mut d = code::Code::default();
    decimal::emit(&mut d).unwrap();
    let (b, _) = d.finish().unwrap();
    std::fs::write("decimal-image.bin", b).unwrap();
    for (op, name) in [('+', "add"), ('-', "sub"), ('*', "mul"), ('/', "div")] {
        let mut c = code::Code::default();
        metadata::emit(&mut c, op).unwrap();
        let (b, _) = c.finish().unwrap();
        std::fs::write(format!("metadata-{name}.bin"), b).unwrap();
    }

    for (op, name) in [('+', "add"), ('-', "sub"), ('*', "mul"), ('/', "div")] {
        let mut c = code::Code::default();
        numeric::emit_mixed(&mut c, op).unwrap();
        let (b, _) = c.finish().unwrap();
        std::fs::write(format!("mixed-{name}.bin"), b).unwrap();
    }
    for (op, name) in [('+', "add"), ('-', "sub"), ('*', "mul"), ('/', "div")] {
        let mut c = code::Code::default();
        numeric::emit(&mut c, op).unwrap();
        let (b, _) = c.finish().unwrap();
        std::fs::write(format!("kernel-{name}.bin"), b).unwrap();
    }
    let mut c = code::Code::default();
    c.mul(0, 9, 10, false).unwrap();
    c.mul(11, 9, 10, true).unwrap();
    c.asr(12, 0, 63).unwrap();
    c.scvtf(0, 9).unwrap();
    c.scvtf(1, 10).unwrap();
    for op in ['+', '-', '*', '/'] {
        c.fp64(0, 0, 1, op).unwrap();
    }
    c.fp_bits(0, 0, true).unwrap();
    c.fp_bits(0, 0, false).unwrap();
    c.fcmp_zero(1).unwrap();
    c.fcmp(0, 1).unwrap();
    c.fabs(0, 0).unwrap();
    c.fcvtzu(9, 0).unwrap();
    c.fcvtzs(6, 0).unwrap();
    c.bits(9, 1, 16, 48).unwrap();
    c.bits(1, 9, 0, 16).unwrap();
    let (b, _) = c.finish().unwrap();
    std::fs::write("numeric-encodings.bin", b).unwrap();
}
