// Isolated own native diagnostic chain. No numeric AST or TRY admission.
use super::code::Code;
// Private generated convention x19=top of {previous,textptr,textlen} chain.
// All frame records are native-stack locals, borrowed for the active lifetime.
pub fn link(c: &mut Code, offset: u16) -> Result<(), String> {
    c.imm(17, 29, offset, true, false)?;
    init(c)
}
pub fn link_at_sp(c: &mut Code) -> Result<(), String> {
    c.imm(17, 31, 0, false, false)?;
    init(c)
}
fn init(c: &mut Code) -> Result<(), String> {
    c.ldst(19, 17, 0, false)?;
    c.mov(9, 0)?;
    c.ldst(9, 17, 8, false)?;
    c.ldst(9, 17, 16, false)?;
    c.copy(19, 17)
}
pub fn location(c: &mut Code, label: &str, text: &str) -> Result<(), String> {
    c.data(label, text.as_bytes())?;
    c.adr(9, label)?;
    c.ldst(9, 19, 8, false)?;
    c.mov(9, text.len() as u64)?;
    c.ldst(9, 19, 16, false)
}
pub fn unlink(c: &mut Code) -> Result<(), String> {
    c.ldst(19, 19, 0, true)
}
pub fn emit(c: &mut Code) -> Result<(), String> {
    c.data("rt_trace_header", b"Callstack:\n")?;
    c.data("rt_zero_message", b"Error: division by zero\n")?;
    c.label("rt_trace")?;
    c.prologue(32)?;
    c.ldst(20, 31, 0, false)?;
    c.copy(20, 19)?;
    c.imm(31, 20, 0, true, true)?;
    c.bc("rt_trace_end", 0)?;
    c.adr(0, "rt_trace_header")?;
    c.mov(1, 11)?;
    c.b("rt_write", true);
    c.label("rt_trace_next")?;
    c.ldst(1, 20, 16, true)?;
    c.imm(31, 1, 0, true, true)?;
    c.bc("rt_trace_skip", 0)?;
    c.ldst(0, 20, 8, true)?;
    c.b("rt_write", true);
    c.label("rt_trace_skip")?;
    c.ldst(20, 20, 0, true)?;
    c.imm(31, 20, 0, true, true)?;
    c.bc("rt_trace_next", 1)?;
    c.label("rt_trace_end")?;
    c.ldst(20, 31, 0, true)?;
    c.epilogue()?;
    // Match finalized current hbc uncaught division error: stdout + trace,exit1.
    // Does not pretend to throw a caught language exception.
    c.label("rt_zero_uncaught")?;
    c.adr(0, "rt_zero_message")?;
    c.mov(1, 24)?;
    c.b("rt_write", true);
    c.b("rt_panic", false);
    c.data("rt_inc_message", b"Limit: increment overflow needs numeric promotion\n")?;
    c.label("rt_inc_overflow")?;
    c.adr(0, "rt_inc_message")?;
    c.mov(1, 50)?;
    c.b("rt_write", true);
    c.b("rt_panic", false);
    c.label("rt_panic")?;
    c.b("rt_trace", true);
    c.mov(0, 1)?;
    c.mov(16, 1)?;
    c.svc();
    c.b("rt_panic", false);
    Ok(())
}
