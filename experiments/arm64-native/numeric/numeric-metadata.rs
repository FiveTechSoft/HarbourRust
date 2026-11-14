// Isolated HarbourRust metadata kernel, not its entire numeric ABI.
// x0=result binary64 bits, x1=left decimals,x2=right decimals.
// output x0 unchanged,x1=(length<<16)|decimals,x2=0 success/1 bad decimals.
// max decimals for +/-; sum for *; SET(2) for /. Width asymmetric 10/20.
// NaN width stays10; infinity follows the normal threshold comparisons.
use super::code::Code;
pub fn emit(c: &mut Code, op: char) -> Result<(), String> {
    if !matches!(op, '+' | '-' | '*' | '/') {
        return Err("metadata operation unavailable".into());
    }
    c.imm(31, 1, 435, true, true)?;
    c.bc("meta_bad", 8)?;
    c.imm(31, 2, 435, true, true)?;
    c.bc("meta_bad", 8)?;
    match op {
        '+' | '-' => {
            c.addsub(31, 1, 2, true, true)?;
            c.bc("meta_dec_done", 2)?;
            c.copy(1, 2)?;
        }
        '*' => {
            c.addsub(1, 1, 2, false, false)?;
            c.imm(31, 1, 435, true, true)?;
            c.bc("meta_bad", 8)?;
        }
        '/' => {
            c.mov(1, 2)?;
        }
        _ => unreachable!(),
    }
    c.label("meta_dec_done")?;
    c.mov(10, 10 << 16)?;
    c.fp_bits(0, 0, false)?;
    c.mov(9, 9999999999.0f64.to_bits())?;
    c.fp_bits(9, 1, false)?;
    c.fcmp(0, 1)?;
    c.bc("meta_width_done", 6)?; // unordered, NaN width10
    c.bc("meta_wide", 12)?; // greater-than (signed condition valid after ordered FP cmp)
    c.mov(9, (-999999999.0f64).to_bits())?;
    c.fp_bits(9, 1, false)?;
    c.fcmp(0, 1)?;
    c.bc("meta_width_done", 10)?; // >= lower threshold
    c.label("meta_wide")?;
    c.mov(10, 20 << 16)?;
    c.label("meta_width_done")?;
    c.addsub(1, 1, 10, false, false)?;
    c.mov(2, 0)?;
    c.ret();
    c.label("meta_bad")?;
    c.mov(1, 0)?;
    c.mov(2, 1)?;
    c.ret();
    Ok(())
}
