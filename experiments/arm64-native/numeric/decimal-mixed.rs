// Isolated mixed-integral wrapper around own ARM64 decimal composer.
// Same x0..x3 ABI as composer; x4=0 ordinary/1 mixed-local integral fast path.
// No new language/AST admission. Reject metadata before writing output.
use super::code::Code;
pub fn emit(c: &mut Code) -> Result<(), String> {
    c.prologue(128)?;
    for (reg, off) in [(0, 0), (1, 8), (2, 16), (3, 24)] {
        c.ldst(reg, 31, off, false)?;
    }
    c.imm(31, 4, 1, true, true)?;
    c.bc("mixfmt_bad", 8)?;
    c.imm(31, 4, 0, true, true)?;
    c.bc("mixfmt_fallback", 0)?;
    c.imm(31, 1, 10, true, true)?;
    c.bc("mixfmt_width", 0)?;
    c.imm(31, 1, 20, true, true)?;
    c.bc("mixfmt_bad", 1)?;
    c.label("mixfmt_width")?;
    c.imm(31, 2, 435, true, true)?;
    c.bc("mixfmt_bad", 8)?;
    c.fp_bits(0, 0, false)?;
    // ARM FCVTZS saturates where x86 CVTTSD2SI returns the indefinite
    // MIN value. Check both bounds before converting, never trust equality
    // after saturation (2^63 converts back from I64MAX to the same double).
    c.mov(9, 9223372036854775808.0f64.to_bits())?;
    c.fp_bits(9, 1, false)?;
    c.fcmp(0, 1)?;
    c.bc("mixfmt_fallback", 10)?;
    c.mov(9, (-9223372036854775808.0f64).to_bits())?;
    c.fp_bits(9, 1, false)?;
    c.fcmp(0, 1)?;
    c.bc("mixfmt_fallback", 13)?;
    c.fcvtzs(6, 0)?;
    c.mov(9, 1 << 63)?;
    c.addsub(31, 6, 9, true, true)?;
    c.bc("mixfmt_fallback", 0)?;
    c.scvtf(1, 6)?;
    c.fcmp(0, 1)?;
    c.bc("mixfmt_fallback", 6)?;
    c.bc("mixfmt_fallback", 1)?;
    c.mov(9, 9999999999)?;
    c.addsub(31, 6, 9, true, true)?;
    c.bc("mixfmt_wide", 12)?;
    c.mov(9, (-999999999i64) as u64)?;
    c.addsub(31, 6, 9, true, true)?;
    c.bc("mixfmt_wide", 11)?;
    c.mov(9, 10)?;
    c.b("mixfmt_check_width", false);
    c.label("mixfmt_wide")?;
    c.mov(9, 20)?;
    c.label("mixfmt_check_width")?;
    c.addsub(31, 9, 1, true, true)?;
    c.bc("mixfmt_fallback", 1)?;
    c.imm(31, 6, 0, true, true)?;
    c.cset(5, 11)?;
    c.bc("mixfmt_abs", 10)?;
    c.addsub(6, 31, 6, true, false)?;
    c.label("mixfmt_abs")?;
    c.imm(7, 31, 96, false, false)?;
    c.mov(8, 0)?;
    c.mov(10, 10)?;
    c.label("mixfmt_digits")?;
    c.udiv(9, 6, 10)?;
    c.msub(11, 9, 10, 6)?;
    c.imm(11, 11, 48, false, false)?;
    c.imm(7, 7, 1, true, false)?;
    c.byte(11, 7, 0, false)?;
    c.imm(8, 8, 1, false, false)?;
    c.copy(6, 9)?;
    c.imm(31, 6, 0, true, true)?;
    c.bc("mixfmt_digits", 1)?;
    c.imm(31, 5, 0, true, true)?;
    c.bc("mixfmt_padding", 0)?;
    c.mov(11, 45)?;
    c.imm(7, 7, 1, true, false)?;
    c.byte(11, 7, 0, false)?;
    c.imm(8, 8, 1, false, false)?;
    c.label("mixfmt_padding")?;
    c.copy(12, 3)?;
    c.copy(13, 3)?;
    c.addsub(9, 1, 8, true, true)?;
    c.bc("mixfmt_copy", 13)?;
    c.mov(11, 32)?;
    c.label("mixfmt_spaces")?;
    c.byte(11, 12, 0, false)?;
    c.imm(12, 12, 1, false, false)?;
    c.imm(9, 9, 1, true, true)?;
    c.bc("mixfmt_spaces", 1)?;
    c.label("mixfmt_copy")?;
    c.byte(11, 7, 0, true)?;
    c.byte(11, 12, 0, false)?;
    c.imm(7, 7, 1, false, false)?;
    c.imm(12, 12, 1, false, false)?;
    c.imm(8, 8, 1, true, true)?;
    c.bc("mixfmt_copy", 1)?;
    c.imm(31, 2, 0, true, true)?;
    c.bc("mixfmt_done", 0)?;
    c.mov(11, 46)?;
    c.byte(11, 12, 0, false)?;
    c.imm(12, 12, 1, false, false)?;
    c.mov(11, 48)?;
    c.label("mixfmt_zeros")?;
    c.byte(11, 12, 0, false)?;
    c.imm(12, 12, 1, false, false)?;
    c.imm(2, 2, 1, true, true)?;
    c.bc("mixfmt_zeros", 1)?;
    c.label("mixfmt_done")?;
    c.addsub(0, 12, 13, true, false)?;
    c.mov(1, 0)?;
    c.epilogue()?;
    c.label("mixfmt_bad")?;
    c.mov(0, 0)?;
    c.mov(1, 1)?;
    c.epilogue()?;
    c.label("mixfmt_fallback")?;
    for (reg, off) in [(0, 0), (1, 8), (2, 16), (3, 24)] {
        c.ldst(reg, 31, off, true)?;
    }
    c.b("mixfmt_ordinary", true);
    c.epilogue()?;
    c.label("mixfmt_ordinary")?;
    super::compose::emit(c)
}
