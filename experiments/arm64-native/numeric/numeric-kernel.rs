// Isolated numeric kernel. Not an AST backend or a language ABI.
// Input x0=a i64,x1=b i64. Output x0=payload,x1=kind:
// kind0 runtime i64, kind1 IEEE754 double bits, kind2 zero-divisor signal.
// No formatting/provenance/error runtime is implied by these internal tags.
use super::code::Code;
pub fn emit(c: &mut Code, op: char) -> Result<(), String> {
    c.copy(9, 0)?;
    c.copy(10, 1)?;
    match op {
        '+' | '-' => {
            c.addsub(0, 9, 10, op == '-', true)?;
            c.bc("numeric_float", 6)?;
        }
        '*' => {
            c.mul(0, 9, 10, false)?;
            c.mul(11, 9, 10, true)?;
            c.asr(12, 0, 63)?;
            c.addsub(31, 11, 12, true, true)?;
            c.bc("numeric_float", 1)?;
        }
        '/' => {
            c.imm(31, 10, 0, true, true)?;
            c.bc("numeric_zero", 0)?;
            c.b("numeric_float", false);
        }
        _ => return Err("numeric operation unavailable".into()),
    }
    c.mov(1, 0)?;
    c.b("numeric_done", false);
    c.label("numeric_float")?;
    c.scvtf(0, 9)?;
    c.scvtf(1, 10)?;
    c.fp64(0, 0, 1, op)?;
    c.fp_bits(0, 0, true)?;
    c.mov(1, 1)?;
    c.b("numeric_done", false);
    c.label("numeric_zero")?;
    c.mov(0, 0)?;
    c.mov(1, 2)?;
    c.label("numeric_done")?;
    c.ret();
    Ok(())
}

// Internal mixed-kind probe, not a language value or metadata ABI.
// x0/x1 payloads; x2/x3 kinds (0 signed integer, 1 raw binary64).
// Result x0 payload,x1 kind as above; kind3 signals invalid input kind.
// FPCR must select nearest-even and preserve subnormals (FPCR=0 in tests).
pub fn emit_mixed(c: &mut Code, op: char) -> Result<(), String> {
    if !matches!(op, '+' | '-' | '*' | '/') {
        return Err("numeric operation unavailable".into());
    }
    c.imm(31, 2, 1, true, true)?;
    c.bc("mixed_invalid", 8)?;
    c.imm(31, 3, 1, true, true)?;
    c.bc("mixed_invalid", 8)?;
    c.imm(31, 2, 0, true, true)?;
    c.bc("mixed_float", 1)?;
    c.imm(31, 3, 0, true, true)?;
    c.bc("mixed_float", 1)?;
    c.b("mixed_integer", false);
    c.label("mixed_float")?;
    c.imm(31, 2, 0, true, true)?;
    c.bc("mixed_a_bits", 1)?;
    c.scvtf(0, 0)?;
    c.b("mixed_a_done", false);
    c.label("mixed_a_bits")?;
    c.fp_bits(0, 0, false)?;
    c.label("mixed_a_done")?;
    c.imm(31, 3, 0, true, true)?;
    c.bc("mixed_b_bits", 1)?;
    c.scvtf(1, 1)?;
    c.b("mixed_b_done", false);
    c.label("mixed_b_bits")?;
    c.fp_bits(1, 1, false)?;
    c.label("mixed_b_done")?;
    if op == '/' {
        c.fcmp_zero(1)?;
        c.bc("numeric_zero", 0)?;
    }
    c.fp64(0, 0, 1, op)?;
    c.fp_bits(0, 0, true)?;
    c.mov(1, 1)?;
    c.ret();
    c.label("mixed_invalid")?;
    c.mov(0, 0)?;
    c.mov(1, 3)?;
    c.ret();
    c.label("mixed_integer")?;
    emit(c, op)
}
