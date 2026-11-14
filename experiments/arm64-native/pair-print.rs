use super::code::Code;
pub fn emit(c: &mut Code) -> Result<(), String> {
    c.label("pair_print_f64")?;
    c.prologue(480)?;
    c.bits(2, 1, 0, 16)?;
    c.bits(1, 1, 16, 48)?;
    c.imm(3, 31, 0, false, false)?;
    c.b("pair_compose", true);
    c.imm(31, 1, 0, true, true)?;
    c.bc("pair_format_bad", 1)?;
    c.copy(1, 0)?;
    c.imm(0, 31, 0, false, false)?;
    c.b("rt_write", true);
    c.epilogue()?;
    c.label("pair_format_bad")?;
    // Explicit experiment failure, not a Harbour language error.
    c.mov(0, 75)?;
    c.mov(16, 1)?;
    c.svc();
    c.b("pair_format_bad", false);
    c.label("pair_compose")?;
    super::compose::emit(c)
}
