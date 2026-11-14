// Emitted ARM64 normalization kernel, not the finished decimal formatter.
// Input x0 raw binary64. Output x0 sixteen-digit integer image,
// x1 signed decimal exponent,x2 sign0/1,x3 nonfinite0/1.
// Zero drops negative sign. Nonfinite returns no image, rather than looping.
use super::code::Code;
pub fn emit(c: &mut Code) -> Result<(), String> {
    c.fp_bits(0, 0, false)?;
    c.fabs(0, 0)?;
    c.mov(1, 0)?;
    c.mov(3, 0)?;
    c.imm(31, 0, 0, true, true)?;
    c.cset(2, 11)?;
    c.fcmp(0, 0)?;
    c.bc("image_nonfinite", 6)?;
    c.mov(9, f64::MAX.to_bits())?;
    c.fp_bits(9, 1, false)?;
    c.fcmp(0, 1)?;
    c.bc("image_nonfinite", 12)?;
    c.fcmp_zero(0)?;
    c.bc("image_zero", 0)?;
    c.mov(9, 10.0f64.to_bits())?;
    c.fp_bits(9, 1, false)?;
    c.label("image_div")?;
    c.fcmp(0, 1)?;
    c.bc("image_small", 11)?;
    c.fp64(0, 0, 1, '/')?;
    c.imm(1, 1, 1, false, false)?;
    c.b("image_div", false);
    c.label("image_small")?;
    c.mov(9, 1.0f64.to_bits())?;
    c.fp_bits(9, 2, false)?;
    c.label("image_mul")?;
    c.fcmp(0, 2)?;
    c.bc("image_round", 10)?;
    c.fp64(0, 0, 1, '*')?;
    c.imm(1, 1, 1, true, false)?;
    c.b("image_mul", false);
    c.label("image_round")?;
    c.mov(9, 1e15f64.to_bits())?;
    c.fp_bits(9, 2, false)?;
    c.fp64(0, 0, 2, '*')?;
    c.mov(9, 0.5f64.to_bits())?;
    c.fp_bits(9, 2, false)?;
    c.fp64(0, 0, 2, '+')?;
    c.fcvtzu(0, 0)?;
    c.mov(9, 10000000000000000)?;
    c.addsub(31, 0, 9, true, true)?;
    c.bc("image_done", 1)?;
    c.mov(0, 1000000000000000)?;
    c.imm(1, 1, 1, false, false)?;
    c.label("image_done")?;
    c.ret();
    c.label("image_zero")?;
    c.mov(0, 0)?;
    c.mov(2, 0)?;
    c.ret();
    c.label("image_nonfinite")?;
    c.mov(0, 0)?;
    c.mov(3, 1)?;
    c.ret();
    Ok(())
}
