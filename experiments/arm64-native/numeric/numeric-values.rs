// Isolated value/format glue. No language AST or error/trace integration.
// x0payloadA,x1formatA,x2payloadB,x3formatB ->x0payload,x1format,x2status.
// format0=runtime i64,1=literal/copy i64,otherwise (10/20<<16)|dec<=435.
// status0ok,1zero-divisor,2invalid metadata,3decimal limit.
use super::code::Code;
pub fn emit(c: &mut Code, op: char) -> Result<(), String> {
    c.prologue(64)?;
    for (r, o) in [(0, 0), (1, 8), (2, 16), (3, 24)] {
        c.ldst(r, 31, o, false)?;
    }
    for (formatreg, kindreg, next) in [(1, 6, "value_a_valid"), (3, 7, "value_b_valid")] {
        c.mov(kindreg, 0)?;
        c.imm(31, formatreg, 1, true, true)?;
        c.bc(next, 9)?;
        c.bits(9, formatreg, 16, 48)?;
        c.imm(31, 9, 10, true, true)?;
        let width_ok = format!("{next}_width");
        c.bc(&width_ok, 0)?;
        c.imm(31, 9, 20, true, true)?;
        c.bc("value_invalid", 1)?;
        c.label(&width_ok)?;
        c.bits(9, formatreg, 0, 16)?;
        c.imm(31, 9, 435, true, true)?;
        c.bc("value_invalid", 8)?;
        c.mov(kindreg, 1)?;
        c.label(next)?;
    }
    c.copy(1, 2)?;
    c.copy(2, 6)?;
    c.copy(3, 7)?;
    c.b("value_arithmetic", true);
    c.imm(31, 1, 2, true, true)?;
    c.bc("value_zero", 0)?;
    c.imm(31, 1, 3, true, true)?;
    c.bc("value_invalid", 0)?;
    c.imm(31, 1, 0, true, true)?;
    c.bc("value_done", 0)?;
    c.ldst(9, 31, 8, true)?;
    c.bits(1, 9, 0, 16)?;
    c.imm(31, 9, 1, true, true)?;
    c.bc("value_a_dec", 8)?;
    c.mov(1, 0)?;
    c.label("value_a_dec")?;
    c.ldst(9, 31, 24, true)?;
    c.bits(2, 9, 0, 16)?;
    c.imm(31, 9, 1, true, true)?;
    c.bc("value_b_dec", 8)?;
    c.mov(2, 0)?;
    c.label("value_b_dec")?;
    c.b("value_metadata", true);
    c.imm(31, 2, 0, true, true)?;
    c.bc("value_decimal_error", 1)?;
    c.label("value_done")?;
    c.mov(2, 0)?;
    c.epilogue()?;
    c.label("value_zero")?;
    c.mov(0, 0)?;
    c.mov(1, 0)?;
    c.mov(2, 1)?;
    c.epilogue()?;
    c.label("value_invalid")?;
    c.mov(0, 0)?;
    c.mov(1, 0)?;
    c.mov(2, 2)?;
    c.epilogue()?;
    c.label("value_decimal_error")?;
    c.mov(0, 0)?;
    c.mov(1, 0)?;
    c.mov(2, 3)?;
    c.epilogue()?;
    c.label("value_arithmetic")?;
    super::numeric::emit_mixed(c, op)?;
    c.label("value_metadata")?;
    super::metadata::emit(c, op)
}
