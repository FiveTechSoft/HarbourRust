// Isolated scalar runtime experiment. Not part of hbc or a supported target.
// No libc/SDK: owns write retry/short-write loop, integer formatting and exit.
use super::code::Code;
pub fn emit(c: &mut Code) -> Result<(), String> {
    c.data("rt_spaces", b"                    ")?;
    c.data("rt_nl", b"\n")?;
    c.data("rt_sep", b" ")?;
    c.data("rt_true", b".T.")?;
    c.data("rt_false", b".F.")?;
    // write(x0=ptr,x1=len). x0/x1 are not assumed preserved across SVC.
    c.label("rt_write")?;
    c.prologue(32)?;
    c.ldst(0, 31, 0, false)?;
    c.ldst(1, 31, 8, false)?;
    c.label("rt_write_loop")?;
    c.ldst(2, 31, 8, true)?;
    c.imm(31, 2, 0, true, true)?;
    c.bc("rt_write_done", 0)?;
    c.mov(0, 1)?;
    c.ldst(1, 31, 0, true)?;
    c.mov(16, 4)?;
    c.svc();
    c.bc("rt_write_ok", 3)?; // carry clear
    c.imm(31, 0, 4, true, true)?;
    c.bc("rt_write_loop", 0)?; // EINTR
    c.b("rt_io_error", false);
    c.label("rt_write_ok")?;
    c.imm(31, 0, 0, true, true)?;
    c.bc("rt_io_error", 0)?; // no-progress write
    c.ldst(9, 31, 8, true)?;
    c.addsub(31, 0, 9, true, true)?;
    c.bc("rt_io_error", 8)?; // >remaining
    c.addsub(9, 9, 0, true, false)?;
    c.ldst(9, 31, 8, false)?;
    c.ldst(9, 31, 0, true)?;
    c.addsub(9, 9, 0, false, false)?;
    c.ldst(9, 31, 0, false)?;
    c.b("rt_write_loop", false);
    c.label("rt_write_done")?;
    c.epilogue()?;
    c.label("rt_io_error")?;
    c.mov(0, 74)?;
    c.mov(16, 1)?;
    c.svc();
    c.b("rt_io_error", false);
    // print_i64(x0): Harbour literal/copy width. Runtime arithmetic is NOT
    // admitted by the scalar AST experiment, so no computed-width confusion.
    c.label("rt_i64")?;
    c.prologue(96)?;
    c.copy(9, 0)?;
    c.mov(10, 0)?;
    c.imm(31, 9, 0, true, true)?;
    c.bc("rt_i64_abs", 10)?;
    c.mov(10, 1)?;
    c.addsub(9, 31, 9, true, false)?;
    c.label("rt_i64_abs")?;
    c.imm(11, 31, 32, false, false)?;
    c.mov(12, 10)?;
    c.label("rt_digit")?;
    c.udiv(13, 9, 12)?;
    c.msub(14, 13, 12, 9)?;
    c.imm(14, 14, 48, false, false)?;
    c.imm(11, 11, 1, true, false)?;
    c.byte(14, 11, 0, false)?;
    c.copy(9, 13)?;
    c.imm(31, 9, 0, true, true)?;
    c.bc("rt_digit", 1)?;
    c.imm(31, 10, 0, true, true)?;
    c.bc("rt_sign_done", 0)?;
    c.mov(14, 45)?;
    c.imm(11, 11, 1, true, false)?;
    c.byte(14, 11, 0, false)?;
    c.label("rt_sign_done")?;
    c.imm(9, 31, 32, false, false)?;
    c.addsub(2, 9, 11, true, false)?;
    c.mov(12, 10)?;
    c.imm(31, 10, 0, true, true)?;
    c.bc("rt_positive", 0)?;
    c.imm(31, 2, 10, true, true)?;
    c.bc("rt_width_done", 9)?;
    c.mov(12, 20)?;
    c.b("rt_width_done", false);
    c.label("rt_positive")?;
    c.imm(13, 2, 1, false, false)?;
    c.imm(31, 13, 10, true, true)?;
    c.bc("rt_width_done", 9)?;
    c.copy(12, 13)?;
    c.label("rt_width_done")?;
    c.ldst(11, 31, 40, false)?;
    c.ldst(2, 31, 48, false)?;
    c.addsub(1, 12, 2, true, false)?;
    c.adr(0, "rt_spaces")?;
    c.b("rt_write", true);
    c.ldst(0, 31, 40, true)?;
    c.ldst(1, 31, 48, true)?;
    c.b("rt_write", true);
    c.epilogue()?;
    c.label("rt_bool")?;
    c.prologue(0)?;
    c.imm(31, 0, 0, true, true)?;
    c.bc("rt_bool_false", 0)?;
    c.adr(0, "rt_true")?;
    c.b("rt_bool_go", false);
    c.label("rt_bool_false")?;
    c.adr(0, "rt_false")?;
    c.label("rt_bool_go")?;
    c.mov(1, 3)?;
    c.b("rt_write", true);
    c.epilogue()?;
    Ok(())
}
