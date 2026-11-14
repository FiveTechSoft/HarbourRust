// Isolated reversible floating-point environment boundary, not production entry.
#[path = "../arm64-code.rs"]
mod code;
use code::Code;
fn main() {
    let mut c = Code::default();
    c.prologue(32).unwrap();
    c.fp_env(9, false, false).unwrap();
    c.fp_env(10, true, false).unwrap();
    c.ldst(9, 31, 0, false).unwrap();
    c.ldst(10, 31, 8, false).unwrap();
    c.mov(9, 0).unwrap();
    c.fp_env(9, false, true).unwrap();
    c.fp_env(9, true, true).unwrap();
    c.isb();
    // Observable normalized state, intentionally creates FP invalid flag.
    c.fp_env(0, false, false).unwrap();
    c.fp_env(1, true, false).unwrap();
    c.mov(9, f64::NAN.to_bits()).unwrap();
    c.fp_bits(9, 0, false).unwrap();
    c.fcvtzs(9, 0).unwrap();
    c.ldst(9, 31, 0, true).unwrap();
    c.ldst(10, 31, 8, true).unwrap();
    c.fp_env(9, false, true).unwrap();
    c.fp_env(10, true, true).unwrap();
    c.isb();
    c.epilogue().unwrap();
    let (b, _) = c.finish().unwrap();
    std::fs::write("fp-env-probe.bin", b).unwrap();
    let mut c = Code::default();
    c.fp_env(9, false, false).unwrap();
    c.fp_env(9, false, true).unwrap();
    c.fp_env(10, true, false).unwrap();
    c.fp_env(10, true, true).unwrap();
    c.isb();
    let (b, _) = c.finish().unwrap();
    std::fs::write("fp-env-words.bin", b).unwrap();
}
