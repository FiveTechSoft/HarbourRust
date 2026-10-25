// hbc - PoC compiler: Harbour syntax (closed subset) -> x86-64 assembly.
//
// Pipeline: hbc does tokenizing, parsing, semantic analysis (types AND
// ownership/move checking) and code generation itself. The only external
// tools in the pipeline are the system assembler and linker (GNU binutils).
// The produced executables are freestanding: no VM, no libc, no external
// runtime; I/O is two small hand-written syscall helpers emitted into every
// binary. rustc is used to build hbc itself (the compiler's implementation
// language), never to compile Harbour programs.
//
// Targets: linux (default) emits freestanding ELF assembly (raw syscalls);
// windows emits Win64 assembly that calls kernel32 (GetStdHandle /
// WriteFile / ExitProcess) and is assembled/linked with mingw-w64
// binutils. The analysis passes and the internal value convention
// (i64 in rax, Str ptr+len in rax/rdx) are target-independent; only the
// process entry and the two print helpers change.
//
// Fail-closed: tokenizer + parser validate every token; only a known AST is
// ever analyzed or emitted. No raw user text ever reaches the output.
//
// Type contract: integers are i64 (Copy, like Rust), strings are (ptr, len)
// slices of .rodata (they move on assignment; they do not copy, like Rust's
// String ownership). Printing borrows; it does not move.

use std::env;
use std::fs;
use std::process;

#[derive(Clone, Copy, PartialEq, Debug)]
enum Ty { I64, Str }

#[derive(Clone, PartialEq, Debug)]
enum Tok {
    Ident(String),
    Int(String),
    Str(String), // already unescaped content
    Plus, Minus, Star, Slash,
    LParen, RParen,
    Assign,   // :=
    Question, // ?
    KwFunction, KwLocal, KwReturn, KwNil,
}

fn tokenize(line: &str, n: usize) -> Result<Vec<Tok>, String> {
    let mut toks = Vec::new();
    let mut it = line.char_indices().peekable();
    while let Some(&(i, c)) = it.peek() {
        match c {
            ' ' | '\t' => { it.next(); }
            '/' => {
                let mut look = it.clone();
                look.next();
                if look.peek().map(|&(_, c2)| c2) == Some('/') { break; } // comment
                toks.push(Tok::Slash);
                it.next();
            }
            '+' => { toks.push(Tok::Plus); it.next(); }
            '-' => { toks.push(Tok::Minus); it.next(); }
            '*' => { toks.push(Tok::Star); it.next(); }
            '(' => { toks.push(Tok::LParen); it.next(); }
            ')' => { toks.push(Tok::RParen); it.next(); }
            '?' => { toks.push(Tok::Question); it.next(); }
            ':' => {
                it.next();
                match it.peek() {
                    Some(&(_, '=')) => { toks.push(Tok::Assign); it.next(); }
                    _ => return Err(format!("line {}: ':' without '=' (col {})", n, i + 1)),
                }
            }
            '"' => {
                it.next();
                let mut s = String::new();
                let mut closed = false;
                while let Some(&(_, c2)) = it.peek() {
                    it.next();
                    match c2 {
                        '"' => { closed = true; break; }
                        '\\' => match it.next() {
                            Some((_, '"')) => s.push('"'),
                            Some((_, '\\')) => s.push('\\'),
                            Some((_, o)) => return Err(format!("line {}: unsupported escape \\{}", n, o)),
                            None => return Err(format!("line {}: unterminated string", n)),
                        },
                        c3 => s.push(c3),
                    }
                }
                if !closed { return Err(format!("line {}: unterminated string", n)); }
                toks.push(Tok::Str(s));
            }
            c if c.is_ascii_digit() => {
                let mut num = String::new();
                while let Some(&(_, c2)) = it.peek() {
                    if c2.is_ascii_digit() { num.push(c2); it.next(); } else { break; }
                }
                toks.push(Tok::Int(num));
            }
            c if c.is_ascii_alphabetic() || c == '_' => {
                let mut id = String::new();
                while let Some(&(_, c2)) = it.peek() {
                    if c2.is_ascii_alphanumeric() || c2 == '_' { id.push(c2); it.next(); } else { break; }
                }
                toks.push(match id.to_ascii_lowercase().as_str() {
                    "function" => Tok::KwFunction,
                    "local" => Tok::KwLocal,
                    "return" => Tok::KwReturn,
                    "nil" => Tok::KwNil,
                    _ => Tok::Ident(id),
                });
            }
            o => return Err(format!("line {}: character not allowed `{}` (U+{:04X})", n, o, o as u32)),
        }
    }
    Ok(toks)
}

#[derive(Debug)]
enum Expr {
    Int(String),
    Str(String),
    Var(String),
    Call(String), // 0-arg only
    Bin(char, Box<Expr>, Box<Expr>),
}

#[derive(Debug)]
enum Stmt {
    Local(usize, String, Expr),
    Print(usize, Expr),
    Ret(usize, Option<Expr>),
}

struct Func {
    name: String,
    ret: Option<Ty>,
    stmts: Vec<Stmt>,
}

struct P {
    toks: Vec<Tok>,
    pos: usize,
    n: usize,
}

impl P {
    fn peek(&self) -> Option<&Tok> { self.toks.get(self.pos) }
    fn bump(&mut self) -> Option<Tok> {
        let t = self.toks.get(self.pos).cloned();
        if t.is_some() { self.pos += 1; }
        t
    }
    fn expr(&mut self) -> Result<Expr, String> {
        let mut lhs = self.term()?;
        loop {
            let op = match self.peek() {
                Some(Tok::Plus) => '+',
                Some(Tok::Minus) => '-',
                _ => break,
            };
            self.pos += 1;
            let rhs = self.term()?;
            lhs = Expr::Bin(op, Box::new(lhs), Box::new(rhs));
        }
        Ok(lhs)
    }
    fn term(&mut self) -> Result<Expr, String> {
        let mut lhs = self.factor()?;
        loop {
            let op = match self.peek() {
                Some(Tok::Star) => '*',
                Some(Tok::Slash) => '/',
                _ => break,
            };
            self.pos += 1;
            let rhs = self.factor()?;
            lhs = Expr::Bin(op, Box::new(lhs), Box::new(rhs));
        }
        Ok(lhs)
    }
    fn factor(&mut self) -> Result<Expr, String> {
        match self.bump() {
            Some(Tok::Int(v)) => {
                match v.parse::<u128>() {
                    Ok(k) if k <= i64::MAX as u128 => Ok(Expr::Int(v)),
                    _ => Err(format!("line {}: integer literal out of range (i64)", self.n)),
                }
            }
            Some(Tok::Str(s)) => Ok(Expr::Str(s)),
            Some(Tok::Ident(id)) => {
                if self.peek() == Some(&Tok::LParen) {
                    self.pos += 1;
                    if self.bump() != Some(Tok::RParen) {
                        return Err(format!("line {}: calls take no arguments in this PoC", self.n));
                    }
                    Ok(Expr::Call(id))
                } else {
                    Ok(Expr::Var(id))
                }
            }
            Some(Tok::LParen) => {
                let e = self.expr()?;
                if self.bump() != Some(Tok::RParen) {
                    return Err(format!("line {}: missing )", self.n));
                }
                Ok(e)
            }
            other => Err(format!("line {}: unexpected token {:?}", self.n, other)),
        }
    }
    fn done(&self) -> Result<(), String> {
        if self.pos != self.toks.len() {
            Err(format!("line {}: trailing tokens after expression", self.n))
        } else {
            Ok(())
        }
    }
}

const ASM_RESERVED: &[&str] = &[
    // Not backend keywords (there is no textual backend anymore), but labels
    // hbc itself emits; a user function with one of these names would
    // collide with a helper symbol.
    "print_i64", "print_str",
];

fn check_ident(id: &str, n: usize) -> Result<(), String> {
    if id.is_empty() || id.len() > 64 {
        return Err(format!("line {}: invalid identifier length", n));
    }
    if ASM_RESERVED.contains(&id) {
        return Err(format!("line {}: `{}` is reserved by the code generator", n, id));
    }
    Ok(())
}

fn parse_expr_tokens(toks: Vec<Tok>, n: usize) -> Result<Expr, String> {
    if toks.is_empty() {
        return Err(format!("line {}: missing expression", n));
    }
    let mut p = P { toks, pos: 0, n };
    let e = p.expr()?;
    p.done()?;
    Ok(e)
}

fn parse(src: &str) -> Result<Vec<Func>, String> {
    let mut funcs: Vec<Func> = Vec::new();
    let mut cur: Option<Func> = None;

    for (idx, raw) in src.lines().enumerate() {
        let n = idx + 1;
        let toks = tokenize(raw, n)?;
        if toks.is_empty() { continue; }

        if toks[0] == Tok::KwFunction {
            if cur.is_some() {
                return Err(format!("line {}: function inside function", n));
            }
            let name = match toks.as_slice() {
                [Tok::KwFunction, Tok::Ident(id), Tok::LParen, Tok::RParen] => {
                    check_ident(id, n)?;
                    id.clone()
                }
                _ => return Err(format!("line {}: expected `function name()`", n)),
            };
            cur = Some(Func { name, ret: None, stmts: Vec::new() });
            continue;
        }

        let f = cur.as_mut()
            .ok_or_else(|| format!("line {}: code outside a function", n))?;

        match toks[0].clone() {
            Tok::KwLocal => {
                if toks.len() < 4 {
                    return Err(format!("line {}: expected `local name := expr`", n));
                }
                let id = match &toks[1] {
                    Tok::Ident(id) => { check_ident(id, n)?; id.clone() }
                    t => return Err(format!("line {}: expected identifier, got {:?}", n, t)),
                };
                if toks[2] != Tok::Assign {
                    return Err(format!("line {}: expected :=", n));
                }
                let e = parse_expr_tokens(toks[3..].to_vec(), n)?;
                f.stmts.push(Stmt::Local(n, id, e));
            }
            Tok::Question => {
                let e = parse_expr_tokens(toks[1..].to_vec(), n)?;
                f.stmts.push(Stmt::Print(n, e));
            }
            Tok::KwReturn => {
                let stmt = match toks.len() {
                    1 => Stmt::Ret(n, None),
                    2 if toks[1] == Tok::KwNil => Stmt::Ret(n, None),
                    _ => Stmt::Ret(n, Some(parse_expr_tokens(toks[1..].to_vec(), n)?)),
                };
                f.stmts.push(stmt);
                funcs.push(cur.take().unwrap());
            }
            t => return Err(format!("line {}: statement not in the subset ({:?})", n, t)),
        }
    }

    if cur.is_some() {
        return Err("function without closing return".to_string());
    }
    if funcs.is_empty() {
        return Err("no functions found".to_string());
    }
    Ok(funcs)
}

// ---------------------------------------------------------------------------
// Semantic analysis: types + ownership/move tracking. This pass is OURS:
// nothing here is delegated to another compiler.
//
// Locals: (name, type, moved). Strings move on assignment / return (like a
// Rust String); integers are Copy (like a Rust i64). Printing borrows.
// ---------------------------------------------------------------------------

struct Local {
    name: String,
    ty: Ty,
    moved: bool,
}

fn type_expr(e: &Expr, env: &[Local], sigs: &[(String, Ty)], n: usize) -> Result<Ty, String> {
    match e {
        Expr::Int(_) => Ok(Ty::I64),
        Expr::Str(_) => Ok(Ty::Str),
        Expr::Var(id) => match env.iter().find(|v| v.name == *id) {
            None => Err(format!("line {}: undefined variable `{}`", n, id)),
            Some(v) if v.moved => Err(format!(
                "line {}: use of moved value `{}` (strings move on assignment; they do not copy)", n, id)),
            Some(v) => Ok(v.ty),
        },
        Expr::Call(id) => sigs.iter().find(|(v, _)| v == id).map(|(_, t)| *t)
            .ok_or_else(|| format!("line {}: unknown function `{}` (must be defined before use)", n, id)),
        Expr::Bin(_, a, b) => {
            let ta = type_expr(a, env, sigs, n)?;
            let tb = type_expr(b, env, sigs, n)?;
            if ta != Ty::I64 || tb != Ty::I64 {
                return Err(format!("line {}: arithmetic requires integers", n));
            }
            Ok(Ty::I64)
        }
    }
}

// If `e` is a plain variable of type Str, using it as an initializer or a
// return value MOVES it (ownership transfer). Mark it moved.
fn apply_moves(e: &Expr, t: Ty, env: &mut [Local]) {
    if t != Ty::Str { return; } // i64 is Copy: the source stays usable
    if let Expr::Var(id) = e {
        if let Some(v) = env.iter_mut().find(|v| v.name == *id) {
            v.moved = true;
        }
    }
}

// ---------------------------------------------------------------------------
// Code generation: x86-64 assembly (AT&T syntax), freestanding.
//   i64 value  -> %rax
//   Str value  -> %rax = ptr, %rdx = len
// Locals live in the stack frame: i64 takes 8 bytes, Str takes 16.
// ---------------------------------------------------------------------------

fn size_of(t: Ty) -> usize {
    match t { Ty::I64 => 8, Ty::Str => 16 }
}

struct CgLocal {
    name: String,
    ty: Ty,
    off: usize, // offset below rbp of the FIRST slot (ptr for Str, value for i64)
}

fn cg_expr(e: &Expr, env: &[CgLocal], sigs: &[(String, Ty)], out: &mut String, target: Target) {
    match e {
        Expr::Int(v) => {
            out.push_str(&format!("    mov ${}, %rax\n", v));
        }
        Expr::Str(_) => unreachable!("string literals are emitted via cg_str_ref"),
        Expr::Var(id) => {
            let v = env.iter().find(|v| v.name == *id).expect("checked");
            match v.ty {
                Ty::I64 => out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off)),
                Ty::Str => {
                    // ptr at -(off), len at -(off-8) — same layout as the store
                    out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off));
                    out.push_str(&format!("    mov -{}(%rbp), %rdx\n", v.off - 8));
                }
            }
        }
        Expr::Call(id) => {
            let _ = sigs;
            out.push_str(&format!("    call hbc_fn_{}\n", id));
        }
        Expr::Bin(op, a, b) => {
            // arithmetic is i64-only (checked in analysis)
            cg_expr(a, env, sigs, out, target);
            // Keep the lhs on the stack while evaluating the rhs. On Windows
            // a plain push would break 16-byte alignment for any call inside
            // the rhs (e.g. `1 + valor()`), so reserve a full 16-byte slot.
            match target {
                Target::Linux => out.push_str("    push %rax\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
            }
            cg_expr(b, env, sigs, out, target);
            match target {
                Target::Linux => out.push_str("    pop %rcx\n"), // %rcx = lhs, %rax = rhs
                Target::Windows => out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n"),
            }
            match op {
                '+' => out.push_str("    add %rcx, %rax\n"),
                '-' => {
                    out.push_str("    sub %rax, %rcx\n");
                    out.push_str("    mov %rcx, %rax\n");
                }
                '*' => out.push_str("    imul %rcx, %rax\n"),
                '/' => {
                    out.push_str("    mov %rax, %r10\n");
                    out.push_str("    mov %rcx, %rax\n");
                    out.push_str("    cqo\n");
                    out.push_str("    idiv %r10\n");
                }
                _ => unreachable!(),
            }
        }
    }
}

// Evaluate any expression whose value might be a Str: string literals need a
// .rodata slot, so they are handled here with a label table.
fn cg_value(e: &Expr, env: &[CgLocal], sigs: &[(String, Ty)], strs: &mut Vec<String>, out: &mut String, target: Target) {
    if let Expr::Str(s) = e {
        let idx = strs.len();
        strs.push(s.clone());
        out.push_str(&format!("    lea .Lstr{}(%rip), %rax\n", idx));
        out.push_str(&format!("    mov ${}, %edx\n", s.as_bytes().len()));
    } else {
        cg_expr(e, env, sigs, out, target);
    }
}

fn expr_ty(e: &Expr, env: &[CgLocal], sigs: &[(String, Ty)]) -> Ty {
    match e {
        Expr::Int(_) | Expr::Bin(_, _, _) => Ty::I64,
        Expr::Str(_) => Ty::Str,
        Expr::Var(id) => env.iter().find(|v| v.name == *id).expect("checked").ty,
        Expr::Call(id) => sigs.iter().find(|(v, _)| v == id).expect("checked").1,
    }
}

fn cg_func(f: &Func, sigs: &[(String, Ty)], strs: &mut Vec<String>, out: &mut String, target: Target) {
    // Layout pass: assign stack slots in declaration order.
    // i64 local: value at -(off). Str local: ptr at -(off), len at -(off-8)
    // (off grew by 16 for a Str, so the len slot is 8 bytes above the ptr).
    let mut env: Vec<CgLocal> = Vec::new();
    let mut frame = 0usize;
    for s in &f.stmts {
        if let Stmt::Local(_, id, e) = s {
            let t = expr_ty(e, &env, sigs);
            frame += size_of(t);
            env.push(CgLocal { name: id.clone(), ty: t, off: frame });
        }
    }

    out.push_str(&format!("hbc_fn_{}:\n", f.name));
    out.push_str("    push %rbp\n    mov %rsp, %rbp\n");
    // Win64 ABI: rsp must be 16-byte aligned at every call. The Linux
    // frame only needs 8-byte slots (syscalls do not care); round up to 16
    // for Windows so the helper call sites keep ABI alignment.
    let frame = if target == Target::Windows { (frame + 15) & !15 } else { frame };
    if frame > 0 {
        out.push_str(&format!("    sub ${}, %rsp\n", frame));
    }
    for s in &f.stmts {
        match s {
            Stmt::Local(_, id, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("layout");
                cg_value(e, &env, sigs, strs, out, target);
                match v.ty {
                    Ty::I64 => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", v.off)),
                    Ty::Str => {
                        out.push_str(&format!("    mov %rax, -{}(%rbp)\n", v.off));
                        out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", v.off - 8));
                    }
                }
            }
            Stmt::Print(_, e) => {
                let t = expr_ty(e, &env, sigs);
                cg_value(e, &env, sigs, strs, out, target);
                match t {
                    Ty::I64 => out.push_str("    call hbc_print_i64\n"),
                    Ty::Str => out.push_str("    call hbc_print_str\n"),
                }
            }
            Stmt::Ret(_, Some(e)) => {
                cg_value(e, &env, sigs, strs, out, target);
                out.push_str(&format!("    jmp .Lret_{}\n", f.name));
            }
            Stmt::Ret(_, None) => {
                out.push_str(&format!("    jmp .Lret_{}\n", f.name));
            }
        }
    }
    out.push_str(&format!(".Lret_{}:\n", f.name));
    out.push_str("    leave\n    ret\n\n");
}

fn emit_asm(funcs: &[Func], sigs: &[(String, Ty)], target: Target) -> String {
    let mut out = String::new();
    out.push_str("# generated by hbc (PoC: Harbour syntax -> x86-64 assembly)\n");
    match target {
        Target::Linux => out.push_str("# target: linux - no libc, I/O via own syscall helpers at the end\n"),
        Target::Windows => out.push_str("# target: windows - no CRT, I/O via own helpers calling kernel32 at the end\n"),
    }
    match target {
        Target::Linux => {
            out.push_str("    .text\n    .globl _start\n_start:\n");
            out.push_str("    call hbc_fn_main\n");
            out.push_str("    mov $60, %eax\n    xor %edi, %edi\n    syscall\n\n");
        }
        Target::Windows => {
            // Process entry: no CRT. rsp % 16 == 8 on entry (loader calls
            // the entry point); push rbp + sub 48 realigns to 16 and leaves
            // 32 bytes of shadow space for the Win64 calls.
            out.push_str("    .text\n    .globl _start\n_start:\n");
            out.push_str("    push %rbp\n    mov %rsp, %rbp\n");
            // The Win64 loader does not guarantee one specific rsp % 16 at
            // the entry point; align explicitly instead of assuming.
            out.push_str("    and $-16, %rsp\n    sub $48, %rsp\n");
            out.push_str("    call hbc_fn_main\n");
            out.push_str("    xor %ecx, %ecx\n");
            out.push_str("    call ExitProcess\n\n");
        }
    }

    let mut strs: Vec<String> = Vec::new();
    for f in funcs {
        cg_func(f, sigs, &mut strs, &mut out, target);
    }

    // Runtime helpers (ours, hand-written; syscall-only on linux, three
    // kernel32 calls on windows).
    match target {
        Target::Windows => {
            out.push_str(WIN_HELPERS);
            out.push_str("\n    .section .rdata,\"r\"\n");
            emit_strings(&mut out, &strs);
            return out;
        }
        Target::Linux => {}
    }
    out.push_str(r#"
# hbc_print_str: %rax = ptr, %rdx = len. Prints the bytes + newline.
hbc_print_str:
    mov %rax, %rsi
    mov $1, %eax
    mov $1, %edi
    syscall
    lea .Lnl(%rip), %rsi
    mov $1, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    ret

# hbc_print_i64: %rax = signed value. Prints decimal + newline.
hbc_print_i64:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    xor %r9d, %r9d
    test %rax, %rax
    jns 1f
    mov $1, %r9d
    neg %rax
1:
    lea -1(%rbp), %rsi
    mov $10, %r8
2:
    xor %edx, %edx
    div %r8
    add $48, %dl
    mov %dl, (%rsi)
    dec %rsi
    test %rax, %rax
    jnz 2b
    test %r9d, %r9d
    jz 3f
    movb $45, (%rsi)
    dec %rsi
3:
    lea 1(%rsi), %rsi
    lea -1(%rbp), %rdx
    sub %rsi, %rdx
    inc %rdx
    mov $1, %eax
    mov $1, %edi
    syscall
    lea .Lnl(%rip), %rsi
    mov $1, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    leave
    ret
"#);

    out.push_str("\n    .section .rodata\n");
    emit_strings(&mut out, &strs);
    out
}

fn emit_strings(out: &mut String, strs: &[String]) {
    for (i, s) in strs.iter().enumerate() {
        out.push_str(&format!(".Lstr{}:\n", i));
        for chunk in s.as_bytes().chunks(16) {
            let bytes: Vec<String> = chunk.iter().map(|b| b.to_string()).collect();
            out.push_str(&format!("    .byte {}\n", bytes.join(",")));
        }
    }
    out.push_str(".Lnl:\n    .byte 10\n");
}

// Win64 runtime helpers (ours): same internal convention as the linux ones
// (print_str takes ptr/len in rax/rdx, print_i64 takes the value in rax)
// but I/O and exit go through kernel32. Win64 calling convention: args in
// rcx, rdx, r8, r9, 32 bytes of shadow space, 16-byte stack alignment at
// every call. Only VOLATILE registers (rax, rcx, rdx, r8-r11) are touched;
// no callee-saved register needs preserving. Return values of kernel32
// calls are not checked (no I/O error handling in this PoC).
const WIN_HELPERS: &str = r#"
# hbc_print_str: %rax = ptr, %rdx = len. Prints the bytes + newline.
hbc_print_str:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rdx, -8(%rbp)
    mov %rax, -16(%rbp)
    mov $-11, %ecx
    call GetStdHandle
    mov %rax, %rcx
    mov -16(%rbp), %rdx
    mov -8(%rbp), %r8d
    lea -24(%rbp), %r9
    movq $0, 32(%rsp)
    call WriteFile
    mov $-11, %ecx
    call GetStdHandle
    mov %rax, %rcx
    lea .Lnl(%rip), %rdx
    mov $1, %r8d
    lea -24(%rbp), %r9
    movq $0, 32(%rsp)
    call WriteFile
    leave
    ret

# hbc_print_i64: %rax = signed value. Prints decimal + newline.
# The digit loop touches only volatile registers and calls nothing, so the
# Win64 call at the end is the only ABI-sensitive point.
hbc_print_i64:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    xor %r9d, %r9d
    test %rax, %rax
    jns 1f
    mov $1, %r9d
    neg %rax
1:
    lea -1(%rbp), %r10
    mov $10, %r8
2:
    xor %edx, %edx
    div %r8
    add $48, %dl
    mov %dl, (%r10)
    dec %r10
    test %rax, %rax
    jnz 2b
    test %r9d, %r9d
    jz 3f
    movb $45, (%r10)
    dec %r10
3:
    lea 1(%r10), %rax
    mov %rbp, %rdx
    sub %r10, %rdx
    dec %rdx
    call hbc_print_str
    leave
    ret
"#;

#[derive(Clone, Copy, PartialEq)]
enum Target { Linux, Windows }

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 && args.len() != 4 {
        eprintln!("usage: hbc <input.hb> <output.s> [--target=linux|windows]");
        process::exit(2);
    }
    let target = match args.get(3).map(|s| s.as_str()) {
        None | Some("--target=linux") => Target::Linux,
        Some("--target=windows") => Target::Windows,
        Some(_) => {
            eprintln!("usage: hbc <input.hb> <output.s> [--target=linux|windows]");
            process::exit(2);
        }
    };
    let src = fs::read_to_string(&args[1])
        .unwrap_or_else(|e| { eprintln!("cannot read {}: {}", args[1], e); process::exit(2); });

    let mut funcs = match parse(&src) {
        Ok(f) => f,
        Err(msg) => { eprintln!("error: {}", msg); process::exit(1); }
    };

    // Pass 1: semantic analysis - types, ownership/move, signatures.
    let mut sigs: Vec<(String, Ty)> = Vec::new();
    let mut has_main = false;
    for f in &mut funcs {
        if f.name == "main" { has_main = true; }
        let mut env: Vec<Local> = Vec::new();
        let mut ret = None;
        for s in &f.stmts {
            match s {
                Stmt::Local(n, id, e) => {
                    if env.iter().any(|v| v.name == *id) {
                        eprintln!("error: line {}: duplicate local `{}`", n, id);
                        process::exit(1);
                    }
                    match type_expr(e, &env, &sigs, *n) {
                        Ok(t) => {
                            apply_moves(e, t, &mut env);
                            env.push(Local { name: id.clone(), ty: t, moved: false });
                        }
                        Err(m) => { eprintln!("error: {}", m); process::exit(1); }
                    }
                }
                Stmt::Print(n, e) => {
                    // Printing borrows the value; it never moves it.
                    if let Err(m) = type_expr(e, &env, &sigs, *n) {
                        eprintln!("error: {}", m);
                        process::exit(1);
                    }
                }
                Stmt::Ret(n, Some(e)) => {
                    match type_expr(e, &env, &sigs, *n) {
                        Ok(t) => {
                            apply_moves(e, t, &mut env);
                            ret = Some(t);
                        }
                        Err(m) => { eprintln!("error: {}", m); process::exit(1); }
                    }
                }
                Stmt::Ret(_, None) => {}
            }
        }
        if f.name == "main" && ret.is_some() {
            eprintln!("error: main must end with `return` or `return nil` in this PoC");
            process::exit(1);
        }
        if let Some(t) = ret {
            sigs.push((f.name.clone(), t));
        }
        f.ret = ret;
    }
    if !has_main {
        eprintln!("error: no main function");
        process::exit(1);
    }
    {
        let mut names: Vec<&str> = funcs.iter().map(|f| f.name.as_str()).collect();
        names.sort();
        for w in names.windows(2) {
            if w[0] == w[1] {
                eprintln!("error: duplicate function `{}`", w[0]);
                process::exit(1);
            }
        }
    }

    // Pass 2: generate x86-64 assembly from the validated AST only.
    let out = emit_asm(&funcs, &sigs, target);

    fs::write(&args[2], out)
        .unwrap_or_else(|e| { eprintln!("cannot write {}: {}", args[2], e); process::exit(2); });
    println!("{} -> {} ({} functions)", args[1], args[2], funcs.len());
}

