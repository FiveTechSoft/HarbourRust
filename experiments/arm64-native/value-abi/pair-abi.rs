// Isolated native pair ABI, explicit status propagation and bounded trace snapshot.
// x0/x1,x2/x3,x4/x5 hold numeric payload/format args. x8 context pointer.
// Result x0payload,x1format,x2status. Not a source AST/TRY or diagnostic contract.
use super::code::Code;
fn enter(c: &mut Code, name: &str, line: u64) -> Result<(), String> {
    c.prologue(192)?;
    for (r, o) in [(0, 0), (1, 8), (2, 16), (3, 24), (4, 32), (5, 40), (8, 48)] {
        c.ldst(r, 31, o, false)?;
    }
    // frame record at SP+64: prev,nameptr,namelen,line. Context first word=top.
    c.ldst(9, 8, 0, true)?;
    c.ldst(9, 31, 64, false)?;
    c.adr(9, name)?;
    c.ldst(9, 31, 72, false)?;
    c.mov(9, name.len() as u64)?;
    c.ldst(9, 31, 80, false)?;
    c.mov(9, line)?;
    c.ldst(9, 31, 88, false)?;
    c.imm(9, 31, 64, false, false)?;
    c.ldst(9, 8, 0, false)?;
    Ok(())
}
fn leave(c: &mut Code) -> Result<(), String> {
    c.ldst(8, 31, 48, true)?;
    c.ldst(9, 31, 64, true)?;
    c.ldst(9, 8, 0, false)?;
    c.epilogue()
}
pub fn emit(c: &mut Code, op: char) -> Result<(), String> {
    for n in ["outer", "middle", "leaf"] {
        c.data(n, n.as_bytes())?;
    }
    c.prologue(32)?;
    c.fp_env(9, false, false)?;
    c.fp_env(10, true, false)?;
    c.ldst(9, 31, 0, false)?;
    c.ldst(10, 31, 8, false)?;
    c.mov(9, 0)?;
    c.fp_env(9, false, true)?;
    c.fp_env(9, true, true)?;
    c.isb();
    // Caller owns the context; start a new result snapshot, retain its frame top.
    for off in [8, 16, 24] {
        c.ldst(9, 8, off, false)?;
    }
    c.b("outer_call", true);
    c.ldst(9, 31, 0, true)?;
    c.ldst(10, 31, 8, true)?;
    c.fp_env(9, false, true)?;
    c.fp_env(10, true, true)?;
    c.isb();
    c.epilogue()?;
    c.label("outer_call")?;
    enter(c, "outer", 10)?;
    c.b("middle_call", true);
    leave(c)?;
    c.label("middle_call")?;
    enter(c, "middle", 20)?;
    // First op runs in leaf; second op uses local copied pair from original third arg.
    c.b("leaf_call", true);
    c.imm(31, 2, 0, true, true)?;
    c.bc("middle_return", 1)?;
    c.ldst(2, 31, 32, true)?;
    c.ldst(3, 31, 40, true)?;
    c.ldst(8, 31, 48, true)?;
    c.b("leaf_call", true);
    c.label("middle_return")?;
    leave(c)?;
    c.label("leaf_call")?;
    enter(c, "leaf", 30)?;
    c.b("abi_arithmetic", true);
    c.imm(31, 2, 0, true, true)?;
    c.bc("leaf_return", 0)?;
    // Keep error pair while snapshot helper copies the active native records.
    c.ldst(0, 31, 96, false)?;
    c.ldst(1, 31, 104, false)?;
    c.ldst(2, 31, 112, false)?;
    c.ldst(8, 31, 48, true)?;
    c.b("snapshot", true);
    c.ldst(0, 31, 96, true)?;
    c.ldst(1, 31, 104, true)?;
    c.ldst(2, 31, 112, true)?;
    c.label("leaf_return")?;
    leave(c)?;
    c.label("snapshot")?;
    // Context offsets: top0,error8,count16,truncated24, four {name,len,line} at32.
    c.ldst(2, 8, 8, false)?;
    c.mov(10, 0)?;
    c.ldst(10, 8, 24, false)?;
    c.ldst(9, 8, 0, true)?;
    c.imm(11, 8, 32, false, false)?;
    c.label("snapshot_loop")?;
    c.imm(31, 9, 0, true, true)?;
    c.bc("snapshot_done", 0)?;
    c.imm(31, 10, 4, true, true)?;
    c.bc("snapshot_truncated", 0)?;
    for (src, dst) in [(8, 0), (16, 8), (24, 16)] {
        c.ldst(12, 9, src, true)?;
        c.ldst(12, 11, dst, false)?;
    }
    c.imm(11, 11, 24, false, false)?;
    c.imm(10, 10, 1, false, false)?;
    c.ldst(9, 9, 0, true)?;
    c.b("snapshot_loop", false);
    c.label("snapshot_truncated")?;
    c.mov(12, 1)?;
    c.ldst(12, 8, 24, false)?;
    c.label("snapshot_done")?;
    c.ldst(10, 8, 16, false)?;
    c.ret();
    c.label("abi_arithmetic")?;
    super::values::emit(c, op)
}

// Three native identity calls and stack spills preserve every payload/format bit.
// No arithmetic is requested here: integer literal/copy provenance must survive.
pub fn emit_copy(c: &mut Code) -> Result<(), String> {
    for label in ["copy_entry", "copy_middle", "copy_leaf"] {
        c.label(label)?;
        c.prologue(32)?;
        c.ldst(0, 31, 0, false)?;
        c.ldst(1, 31, 8, false)?;
        c.mov(0, 0)?;
        c.mov(1, 0)?;
        c.ldst(0, 31, 0, true)?;
        c.ldst(1, 31, 8, true)?;
        if label == "copy_entry" {
            c.b("copy_middle", true);
        }
        if label == "copy_middle" {
            c.b("copy_leaf", true);
        }
        c.epilogue()?;
    }
    Ok(())
}
