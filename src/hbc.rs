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
enum Ty { I64, Str, Bool }

#[derive(Clone, PartialEq, Debug)]
enum Tok {
    Ident(String),
    Int(String),
    Str(String), // already unescaped content
    Plus, Minus, Star, Slash,
    LParen, RParen,
    Assign,   // :=
    Question, // ?
    Eq,       // =
    Ne,       // <> or !=
    Lt, Le, Gt, Ge,
    KwFunction, KwLocal, KwReturn, KwNil, KwIf, KwElse, KwEndif, KwWhile, KwEnddo, KwExit, KwLoop,
    KwFor, KwTo, KwStep, KwNext,
}

#[derive(Clone, Copy, PartialEq, Debug)]
enum CmpOp { Eq, Ne, Lt, Le, Gt, Ge }

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
                    "if" => Tok::KwIf,
                    "else" => Tok::KwElse,
                    "endif" => Tok::KwEndif,
                    "while" => Tok::KwWhile,
                    "enddo" => Tok::KwEnddo,
                    "exit" => Tok::KwExit,
                    "loop" => Tok::KwLoop,
                    "for" => Tok::KwFor,
                    "to" => Tok::KwTo,
                    "step" => Tok::KwStep,
                    "next" => Tok::KwNext,
                    _ => Tok::Ident(id),
                });
            }
            '=' => { toks.push(Tok::Eq); it.next(); }
            '!' => {
                it.next();
                match it.peek() {
                    Some(&(_, '=')) => { toks.push(Tok::Ne); it.next(); }
                    _ => return Err(format!("line {}: '!' without '=' (col {})", n, i + 1)),
                }
            }
            '<' => {
                it.next();
                match it.peek() {
                    Some(&(_, '=')) => { toks.push(Tok::Le); it.next(); }
                    Some(&(_, '>')) => { toks.push(Tok::Ne); it.next(); }
                    _ => toks.push(Tok::Lt),
                }
            }
            '>' => {
                it.next();
                match it.peek() {
                    Some(&(_, '=')) => { toks.push(Tok::Ge); it.next(); }
                    _ => toks.push(Tok::Gt),
                }
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
    Cmp(CmpOp, Box<Expr>, Box<Expr>), // i64 operands only (checked in analysis)
}

#[derive(Debug)]
enum Stmt {
    Local(usize, String, Expr),
    Print(usize, Expr),
    Ret(usize, Option<Expr>),
    If(usize, Expr, Vec<Stmt>, Vec<Stmt>), // line, condition, then, else (possibly empty)
    While(usize, Expr, Vec<Stmt>), // line, condition, body
    Assign(usize, String, Expr),   // x := expr on an already-declared local
    Exit(usize),                 // exit: leave the innermost loop
    Loop(usize),                 // loop: jump to the next iteration of the innermost loop
    For(usize, String, Expr, Expr, i64, Vec<Stmt>), // line, var, start, end, step (non-zero literal), body
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
    fn peek_cmp(&self) -> Option<CmpOp> {
        match self.peek() {
            Some(Tok::Eq) => Some(CmpOp::Eq),
            Some(Tok::Ne) => Some(CmpOp::Ne),
            Some(Tok::Lt) => Some(CmpOp::Lt),
            Some(Tok::Le) => Some(CmpOp::Le),
            Some(Tok::Gt) => Some(CmpOp::Gt),
            Some(Tok::Ge) => Some(CmpOp::Ge),
            _ => None,
        }
    }
    // Comparison level: at most one comparison, non-associative. Produces a
    // Bool that only `if` accepts (locals/prints/returns reject it later).
    fn cmp_expr(&mut self) -> Result<Expr, String> {
        let lhs = self.expr()?;
        if let Some(op) = self.peek_cmp() {
            self.pos += 1;
            let rhs = self.expr()?;
            return Ok(Expr::Cmp(op, Box::new(lhs), Box::new(rhs)));
        }
        Ok(lhs)
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
    let e = p.cmp_expr()?;
    p.done()?;
    Ok(e)
}

const MAX_DEPTH: usize = 64;

// Parses statements until a line starting with else / endif / return /
// function (left unconsumed) or the end of input. Branch bodies recurse;
// locals declared inside a branch are scoped to that branch.
fn parse_stmts(lines: &[(usize, Vec<Tok>)], i: &mut usize, out: &mut Vec<Stmt>, depth: usize) -> Result<(), String> {
    if depth > MAX_DEPTH {
        return Err("nesting too deep (64 levels max)".to_string());
    }
    while *i < lines.len() {
        let (n, toks) = &lines[*i];
        let n = *n;
        match toks[0].clone() {
            Tok::KwFunction => return Ok(()),
            Tok::KwReturn if depth == 0 => return Ok(()),
            Tok::KwReturn => {
                // Early return inside an if/while block: an expression is
                // required, so every early exit carries a typed value.
                let stmt = match toks.len() {
                    1 => return Err(format!("line {}: an early `return` inside a block needs a value (`return <expr>`); only the closing top-level return may be bare or `nil`", n)),
                    2 if toks[1] == Tok::KwNil => return Err(format!("line {}: an early `return nil` inside a block is not in the PoC (it would leave the return value undefined); use `return <expr>`", n)),
                    _ => Stmt::Ret(n, Some(parse_expr_tokens(toks[1..].to_vec(), n)?)),
                };
                out.push(stmt);
                *i += 1;
            }
            Tok::KwElse | Tok::KwEndif => {
                if depth == 0 {
                    return Err(format!("line {}: `else`/`endif` without `if`", n));
                }
                return Ok(());
            }
            Tok::KwEnddo => {
                if depth == 0 {
                    return Err(format!("line {}: `enddo` without `while`", n));
                }
                return Ok(());
            }
            Tok::KwNext => {
                if depth == 0 {
                    return Err(format!("line {}: `next` without `for`", n));
                }
                return Ok(());
            }
            Tok::KwFor => {
                // for i := <start> to <end> [step <n>]
                // The step must be a non-zero integer literal in this PoC:
                // the counting direction is then fixed at compile time.
                let id = match toks.get(1) {
                    Some(Tok::Ident(id)) => { check_ident(id, n)?; id.clone() }
                    _ => return Err(format!("line {}: expected `for i := <start> to <end> [step <n>]`", n)),
                };
                if toks.len() < 6 || toks[2] != Tok::Assign {
                    return Err(format!("line {}: expected `for i := <start> to <end> [step <n>]`", n));
                }
                let to_pos = match toks[3..].iter().position(|t| *t == Tok::KwTo) {
                    Some(p) => p + 3,
                    None => return Err(format!("line {}: expected `for i := <start> to <end> [step <n>]`", n)),
                };
                let step_pos = toks[to_pos + 1..].iter().position(|t| *t == Tok::KwStep).map(|p| p + to_pos + 1);
                let end_slice_end = step_pos.unwrap_or(toks.len());
                if to_pos == 3 || end_slice_end == to_pos + 1 {
                    return Err(format!("line {}: expected `for i := <start> to <end> [step <n>]`", n));
                }
                let start = parse_expr_tokens(toks[3..to_pos].to_vec(), n)?;
                let end = parse_expr_tokens(toks[to_pos + 1..end_slice_end].to_vec(), n)?;
                let step = match step_pos {
                    None => 1,
                    Some(p) => {
                        let (neg, vtok) = match &toks[p + 1..] {
                            [Tok::Int(v)] => (false, v),
                            [Tok::Minus, Tok::Int(v)] => (true, v),
                            _ => return Err(format!("line {}: the `for` step must be a non-zero integer literal in this PoC", n)),
                        };
                        let mag = match vtok.parse::<u128>() {
                            Ok(k) if k <= i64::MAX as u128 => k as i64,
                            _ => return Err(format!("line {}: integer literal out of range (i64)", n)),
                        };
                        let s = if neg { -mag } else { mag };
                        if s == 0 {
                            return Err(format!("line {}: the `for` step must be a non-zero integer literal in this PoC", n));
                        }
                        s
                    }
                };
                *i += 1;
                let mut body = Vec::new();
                parse_stmts(lines, i, &mut body, depth + 1)?;
                if *i >= lines.len() || lines[*i].1[0] != Tok::KwNext {
                    return Err(format!("line {}: `for` without `next`", n));
                }
                if lines[*i].1.len() != 1 {
                    return Err(format!("line {}: `next` takes no expression", n));
                }
                *i += 1;
                out.push(Stmt::For(n, id, start, end, step, body));
            }
            Tok::KwWhile => {
                if toks.len() < 2 {
                    return Err(format!("line {}: expected `while <expr> <comparison> <expr>`", n));
                }
                let cond = parse_expr_tokens(toks[1..].to_vec(), n)?;
                *i += 1;
                let mut body = Vec::new();
                parse_stmts(lines, i, &mut body, depth + 1)?;
                if *i >= lines.len() || lines[*i].1[0] != Tok::KwEnddo {
                    return Err(format!("line {}: `while` without `enddo`", n));
                }
                if lines[*i].1.len() != 1 {
                    return Err(format!("line {}: `enddo` takes no expression", lines[*i].0));
                }
                *i += 1;
                out.push(Stmt::While(n, cond, body));
            }
            Tok::KwIf => {
                if toks.len() < 2 {
                    return Err(format!("line {}: expected `if <expr> <comparison> <expr>`", n));
                }
                let cond = parse_expr_tokens(toks[1..].to_vec(), n)?;
                *i += 1;
                let mut then_stmts = Vec::new();
                parse_stmts(lines, i, &mut then_stmts, depth + 1)?;
                let mut else_stmts = Vec::new();
                if *i < lines.len() && lines[*i].1[0] == Tok::KwElse {
                    if lines[*i].1.len() != 1 {
                        return Err(format!("line {}: `else` takes no expression", lines[*i].0));
                    }
                    *i += 1;
                    parse_stmts(lines, i, &mut else_stmts, depth + 1)?;
                }
                if *i >= lines.len() || lines[*i].1[0] != Tok::KwEndif {
                    return Err(format!("line {}: `if` without `endif`", n));
                }
                if lines[*i].1.len() != 1 {
                    return Err(format!("line {}: `endif` takes no expression", lines[*i].0));
                }
                *i += 1;
                out.push(Stmt::If(n, cond, then_stmts, else_stmts));
            }
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
                out.push(Stmt::Local(n, id, e));
                *i += 1;
            }
            Tok::Question => {
                let e = parse_expr_tokens(toks[1..].to_vec(), n)?;
                out.push(Stmt::Print(n, e));
                *i += 1;
            }
            Tok::KwExit => {
                if toks.len() != 1 {
                    return Err(format!("line {}: `exit` takes no expression", n));
                }
                out.push(Stmt::Exit(n));
                *i += 1;
            }
            Tok::KwLoop => {
                if toks.len() != 1 {
                    return Err(format!("line {}: `loop` takes no expression", n));
                }
                out.push(Stmt::Loop(n));
                *i += 1;
            }
            Tok::Ident(id) => {
                if toks.len() < 3 || toks[1] != Tok::Assign {
                    return Err(format!("line {}: statement not in the subset (identifier-led line is not an assignment; expected `name := expr`)", n));
                }
                check_ident(&id, n)?;
                let e = parse_expr_tokens(toks[2..].to_vec(), n)?;
                out.push(Stmt::Assign(n, id, e));
                *i += 1;
            }
            t => return Err(format!("line {}: statement not in the subset ({:?})", n, t)),
        }
    }
    Ok(())
}

fn parse(src: &str) -> Result<Vec<Func>, String> {
    let mut lines: Vec<(usize, Vec<Tok>)> = Vec::new();
    for (idx, raw) in src.lines().enumerate() {
        let n = idx + 1;
        let toks = tokenize(raw, n)?;
        if !toks.is_empty() { lines.push((n, toks)); }
    }

    let mut funcs: Vec<Func> = Vec::new();
    let mut i = 0usize;
    while i < lines.len() {
        let (n, toks) = &lines[i];
        if toks[0] != Tok::KwFunction {
            return Err(format!("line {}: code outside a function", n));
        }
        let name = match toks.as_slice() {
            [Tok::KwFunction, Tok::Ident(id), Tok::LParen, Tok::RParen] => {
                check_ident(id, *n)?;
                id.clone()
            }
            _ => return Err(format!("line {}: expected `function name()`", n)),
        };
        i += 1;
        let mut f = Func { name, ret: None, stmts: Vec::new() };
        parse_stmts(&lines, &mut i, &mut f.stmts, 0)?;
        if i >= lines.len() || lines[i].1[0] != Tok::KwReturn {
            return Err(format!("function `{}` without closing return", f.name));
        }
        let (n, toks) = &lines[i];
        let stmt = match toks.len() {
            1 => Stmt::Ret(*n, None),
            2 if toks[1] == Tok::KwNil => Stmt::Ret(*n, None),
            _ => Stmt::Ret(*n, Some(parse_expr_tokens(toks[1..].to_vec(), *n)?)),
        };
        f.stmts.push(stmt);
        funcs.push(f);
        i += 1;
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

#[derive(Clone)]
struct Local {
    name: String,
    ty: Ty,
    moved: bool,
    ro: bool, // read-only: the `for` loop variable cannot be assigned
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
        Expr::Cmp(_, a, b) => {
            let ta = type_expr(a, env, sigs, n)?;
            let tb = type_expr(b, env, sigs, n)?;
            if ta != Ty::I64 || tb != Ty::I64 {
                return Err(format!("line {}: comparisons require integers (string comparison is not in the PoC yet)", n));
            }
            Ok(Ty::Bool)
        }
    }
}

// Recursive statement checker: types + ownership/move tracking, including
// branch joining for `if`. Rust-like rule: a value moved on ANY reachable
// path counts as moved at the join (union of moved flags); a local declared
// inside a branch is scoped to that branch (sibling branches may reuse a
// name). This pass is OURS; nothing is delegated to another compiler.
// Returns whether the block can fall through to its end (false when every
// path exits via return / exit / loop). `loop_pre` is Some(moved flags of
// the outer env captured before the innermost `while`) inside a loop body;
// `exits` collects the outer-env moved flags at each `exit` of that loop.
fn check_stmts(stmts: &[Stmt], env: &mut Vec<Local>, sigs: &[(String, Ty)], ret: &mut Option<Ty>, loop_pre: Option<&Vec<bool>>, exits: &mut Vec<Vec<bool>>) -> Result<bool, String> {
    let mut falls = true;
    for s in stmts {
        match s {
            Stmt::Local(n, id, e) => {
                if env.iter().any(|v| v.name == *id) {
                    return Err(format!("line {}: duplicate local `{}`", n, id));
                }
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::Bool {
                    return Err(format!("line {}: booleans only exist in `if` conditions in this PoC", n));
                }
                apply_moves(e, t, env);
                env.push(Local { name: id.clone(), ty: t, moved: false, ro: false });
            }
            Stmt::Print(n, e) => {
                // Printing borrows the value; it never moves it.
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::Bool {
                    return Err(format!("line {}: cannot print a boolean in this PoC", n));
                }
            }
            Stmt::Ret(n, Some(e)) => {
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::Bool {
                    return Err(format!("line {}: cannot return a boolean in this PoC", n));
                }
                apply_moves(e, t, env);
                match *ret {
                    Some(prev) if prev != t => {
                        return Err(format!("line {}: return type mismatch (this function already returns {:?} elsewhere; all returns must agree)", n, prev));
                    }
                    _ => *ret = Some(t),
                }
                falls = false;
            }
            Stmt::Ret(n, None) => {
                if ret.is_some() {
                    return Err(format!("line {}: `return nil` in a function that returns a value elsewhere (all returns must agree)", n));
                }
                falls = false;
            }
            Stmt::If(n, cond, then_s, else_s) => {
                let ct = type_expr(cond, env, sigs, *n)?;
                if ct != Ty::Bool {
                    return Err(format!("line {}: `if` needs a comparison (e.g. `if x >= 1`); a bare value is not a condition in this PoC", n));
                }
                let outer = env.len();
                let mut env_then = env.clone();
                let ft = check_stmts(then_s, &mut env_then, sigs, ret, loop_pre, exits)?;
                let mut env_else = env.clone();
                let fe = check_stmts(else_s, &mut env_else, sigs, ret, loop_pre, exits)?;
                for k in 0..outer {
                    env[k].moved = env_then[k].moved || env_else[k].moved;
                }
                falls = ft || fe;
            }
            Stmt::While(n, cond, body) => {
                let ct = type_expr(cond, env, sigs, *n)?;
                if ct != Ty::Bool {
                    return Err(format!("line {}: `while` needs a comparison (e.g. `while x >= 1`); a bare value is not a condition in this PoC", n));
                }
                let outer = env.len();
                let pre: Vec<bool> = env.iter().map(|v| v.moved).collect();
                let mut env_body = env.clone();
                let mut wexits: Vec<Vec<bool>> = Vec::new();
                let fb = check_stmts(body, &mut env_body, sigs, ret, Some(&pre), &mut wexits)?;
                // A variable moved on a path that reaches the next
                // iteration must be live again there (Rust's loop rule).
                if fb {
                    for k in 0..outer {
                        if !pre[k] && env_body[k].moved {
                            return Err(format!("line {}: `{}` is moved inside the `while` body and not reassigned before `enddo` (the next iteration would use a moved value)", n, env[k].name));
                        }
                    }
                }
                // Post-loop state: the body may run zero times, may fall
                // through, and may leave via any `exit` - join them all.
                for k in 0..outer {
                    env[k].moved = pre[k] || (fb && env_body[k].moved) || wexits.iter().any(|xs| xs[k]);
                }
            }
            Stmt::For(n, var, start, end, _step, body) => {
                let ts = type_expr(start, env, sigs, *n)?;
                let te = type_expr(end, env, sigs, *n)?;
                if ts != Ty::I64 || te != Ty::I64 {
                    return Err(format!("line {}: `for` bounds must be integers", n));
                }
                if env.iter().any(|v| v.name == *var) {
                    return Err(format!("line {}: `for` loop variable `{}` is already declared in this scope (this PoC does not shadow)", n, var));
                }
                env.push(Local { name: var.clone(), ty: Ty::I64, moved: false, ro: true });
                let outer = env.len();
                let pre: Vec<bool> = env.iter().map(|v| v.moved).collect();
                let mut env_body = env.clone();
                let mut fexits: Vec<Vec<bool>> = Vec::new();
                let fb = check_stmts(body, &mut env_body, sigs, ret, Some(&pre), &mut fexits)?;
                if fb {
                    for k in 0..outer {
                        if !pre[k] && env_body[k].moved {
                            return Err(format!("line {}: `{}` is moved inside the `for` body and not reassigned before `next` (the next iteration would use a moved value)", n, env[k].name));
                        }
                    }
                }
                for k in 0..outer {
                    env[k].moved = pre[k] || (fb && env_body[k].moved) || fexits.iter().any(|xs| xs[k]);
                }
                env.truncate(outer - 1);
            }
            Stmt::Exit(n) => {
                let pre = match loop_pre {
                    Some(p) => p,
                    None => return Err(format!("line {}: `exit` outside a `while` loop or `for` loop", n)),
                };
                exits.push(env[..pre.len()].iter().map(|v| v.moved).collect());
                falls = false;
            }
            Stmt::Loop(n) => {
                let pre = match loop_pre {
                    Some(p) => p,
                    None => return Err(format!("line {}: `loop` outside a `while` loop or `for` loop", n)),
                };
                for k in 0..pre.len() {
                    if !pre[k] && env[k].moved {
                        return Err(format!("line {}: `{}` is moved inside the `while` body and not reassigned before `loop` (the next iteration would use a moved value)", n, env[k].name));
                    }
                }
                falls = false;
            }
            Stmt::Assign(n, id, e) => {
                // RHS is evaluated first; a Str source variable moves.
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::Bool {
                    return Err(format!("line {}: booleans only exist in conditions in this PoC", n));
                }
                apply_moves(e, t, env);
                let idx = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[idx].ro {
                    return Err(format!("line {}: cannot assign to the `for` loop variable `{}` (it advances only via the loop itself)", n, id));
                }
                if env[idx].ty != t {
                    return Err(format!("line {}: type mismatch in assignment to `{}`", n, id));
                }
                // Reassignment makes a moved variable live again (Rust too).
                env[idx].moved = false;
            }
        }
    }
    Ok(falls)
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
    match t { Ty::I64 => 8, Ty::Str => 16, Ty::Bool => unreachable!("booleans rejected in analysis") }
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
        Expr::Cmp(..) => unreachable!("comparisons are emitted via cg_cond_jump"),
        Expr::Var(id) => {
            let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
            match v.ty {
                Ty::I64 => out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off)),
                Ty::Str => {
                    // ptr at -(off), len at -(off-8) — same layout as the store
                    out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off));
                    out.push_str(&format!("    mov -{}(%rbp), %rdx\n", v.off - 8));
                }
                Ty::Bool => unreachable!("booleans rejected in analysis"),
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
        Expr::Cmp(..) => Ty::Bool,
    }
}

// Layout pass: assigns stack slots in declaration order and computes the
// total frame size. Branch locals get their own slots and are scoped: the
// env is truncated at each branch join. The codegen walk below rebuilds
// the exact same env, so offsets match.
fn layout_locals(stmts: &[Stmt], env: &mut Vec<CgLocal>, sigs: &[(String, Ty)], frame: &mut usize) {
    for s in stmts {
        match s {
            Stmt::Local(_, id, e) => {
                let t = expr_ty(e, env, sigs);
                *frame += size_of(t);
                env.push(CgLocal { name: id.clone(), ty: t, off: *frame });
            }
            Stmt::If(_, _, then_s, else_s) => {
                let mark = env.len();
                layout_locals(then_s, env, sigs, frame);
                env.truncate(mark);
                layout_locals(else_s, env, sigs, frame);
                env.truncate(mark);
            }
            Stmt::While(_, _, body) => {
                let mark = env.len();
                layout_locals(body, env, sigs, frame);
                env.truncate(mark);
            }
            Stmt::For(_, var, _, _, _, body) => {
                let mark = env.len();
                *frame += 8; // hidden slot holding the evaluated end bound
                *frame += 8;
                env.push(CgLocal { name: var.clone(), ty: Ty::I64, off: *frame });
                layout_locals(body, env, sigs, frame);
                env.truncate(mark);
            }
            _ => {}
        }
    }
}

// Emits the comparison and jumps to true_label when it holds.
// rcx = lhs, rax = rhs; cmp computes lhs - rhs. On Windows the lhs is kept
// in a 16-byte slot so a call inside either operand keeps ABI alignment.
fn cg_cond_jump(cond: &Expr, env: &[CgLocal], sigs: &[(String, Ty)], out: &mut String, target: Target, true_label: &str) {
    match cond {
        Expr::Cmp(op, a, b) => {
            cg_expr(a, env, sigs, out, target);
            match target {
                Target::Linux => out.push_str("    push %rax\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
            }
            cg_expr(b, env, sigs, out, target);
            match target {
                Target::Linux => out.push_str("    pop %rcx\n"),
                Target::Windows => out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n"),
            }
            out.push_str("    cmp %rax, %rcx\n");
            let j = match op {
                CmpOp::Lt => "jl", CmpOp::Le => "jle", CmpOp::Gt => "jg",
                CmpOp::Ge => "jge", CmpOp::Eq => "je", CmpOp::Ne => "jne",
            };
            out.push_str(&format!("    {} {}\n", j, true_label));
        }
        _ => unreachable!("analysis requires a comparison as the `if` condition"),
    }
}

fn cg_stmts(stmts: &[Stmt], env: &mut Vec<CgLocal>, frame: &mut usize, sigs: &[(String, Ty)], strs: &mut Vec<String>, out: &mut String, target: Target, fname: &str, label: &mut usize, ll: &Option<(String, String)>) {
    for s in stmts {
        match s {
            Stmt::Local(_, id, e) => {
                let t = expr_ty(e, env, sigs);
                cg_value(e, env, sigs, strs, out, target);
                *frame += size_of(t);
                let off = *frame;
                match t {
                    Ty::I64 => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off)),
                    Ty::Str => {
                        out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                        out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                    }
                    Ty::Bool => unreachable!("booleans rejected in analysis"),
                }
                env.push(CgLocal { name: id.clone(), ty: t, off });
            }
            Stmt::Print(_, e) => {
                let t = expr_ty(e, env, sigs);
                cg_value(e, env, sigs, strs, out, target);
                match t {
                    Ty::I64 => out.push_str("    call hbc_print_i64\n"),
                    Ty::Str => out.push_str("    call hbc_print_str\n"),
                    Ty::Bool => unreachable!("booleans rejected in analysis"),
                }
            }
            Stmt::Ret(_, Some(e)) => {
                cg_value(e, env, sigs, strs, out, target);
                out.push_str(&format!("    jmp .Lret_{}\n", fname));
            }
            Stmt::Ret(_, None) => {
                out.push_str(&format!("    jmp .Lret_{}\n", fname));
            }
            Stmt::If(_, cond, then_s, else_s) => {
                let id = *label;
                *label += 1;
                cg_cond_jump(cond, env, sigs, out, target, &format!(".Lthen_{}_{}", fname, id));
                out.push_str(&format!("    jmp .Lelse_{}_{}\n", fname, id));
                out.push_str(&format!(".Lthen_{}_{}:\n", fname, id));
                let mark = env.len();
                cg_stmts(then_s, env, frame, sigs, strs, out, target, fname, label, ll);
                env.truncate(mark);
                out.push_str(&format!("    jmp .Lend_{}_{}\n", fname, id));
                out.push_str(&format!(".Lelse_{}_{}:\n", fname, id));
                cg_stmts(else_s, env, frame, sigs, strs, out, target, fname, label, ll);
                env.truncate(mark);
                out.push_str(&format!(".Lend_{}_{}:\n", fname, id));
            }
            Stmt::While(_, cond, body) => {
                let id = *label;
                *label += 1;
                out.push_str(&format!(".Lwhile_{}_{}:\n", fname, id));
                cg_cond_jump(cond, env, sigs, out, target, &format!(".Lbody_{}_{}", fname, id));
                out.push_str(&format!("    jmp .Lendw_{}_{}\n", fname, id));
                out.push_str(&format!(".Lbody_{}_{}:\n", fname, id));
                let mark = env.len();
                let inner = Some((format!(".Lwhile_{}_{}", fname, id), format!(".Lendw_{}_{}", fname, id)));
                cg_stmts(body, env, frame, sigs, strs, out, target, fname, label, &inner);
                env.truncate(mark);
                out.push_str(&format!("    jmp .Lwhile_{}_{}\n", fname, id));
                out.push_str(&format!(".Lendw_{}_{}:\n", fname, id));
            }
            Stmt::For(_, var, start, end, step, body) => {
                let id = *label;
                *label += 1;
                let mark = env.len();
                // Evaluate the end bound once into a hidden slot (bounds
                // evaluate once, as in Rust ranges), then the start into
                // the loop variable. The step is a non-zero literal, so
                // the counting direction is fixed here at compile time.
                cg_value(end, env, sigs, strs, out, target);
                *frame += 8;
                let end_off = *frame;
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", end_off));
                cg_value(start, env, sigs, strs, out, target);
                *frame += 8;
                let i_off = *frame;
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", i_off));
                env.push(CgLocal { name: var.clone(), ty: Ty::I64, off: i_off });
                out.push_str(&format!(".Lforc_{}_{}:\n", fname, id));
                out.push_str(&format!("    mov -{}(%rbp), %rax\n", i_off));
                out.push_str(&format!("    cmp -{}(%rbp), %rax\n", end_off));
                if *step > 0 {
                    out.push_str(&format!("    jg .Lfore_{}_{}\n", fname, id));
                } else {
                    out.push_str(&format!("    jl .Lfore_{}_{}\n", fname, id));
                }
                let inner = Some((format!(".Lforn_{}_{}", fname, id), format!(".Lfore_{}_{}", fname, id)));
                cg_stmts(body, env, frame, sigs, strs, out, target, fname, label, &inner);
                env.truncate(mark);
                out.push_str(&format!(".Lforn_{}_{}:\n", fname, id));
                out.push_str(&format!("    mov -{}(%rbp), %rax\n", i_off));
                out.push_str(&format!("    add ${}, %rax\n", step));
                // Advancing past the i64 range would wrap the counter and
                // the loop would not terminate: overflow ends the loop.
                out.push_str(&format!("    jo .Lfore_{}_{}\n", fname, id));
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", i_off));
                out.push_str(&format!("    jmp .Lforc_{}_{}\n", fname, id));
                out.push_str(&format!(".Lfore_{}_{}:\n", fname, id));
            }
            Stmt::Exit(_) => {
                let (_, end) = ll.as_ref().expect("analysis checked `exit` is inside a loop");
                out.push_str(&format!("    jmp {}\n", end));
            }
            Stmt::Loop(_) => {
                let (cond, _) = ll.as_ref().expect("analysis checked `loop` is inside a loop");
                out.push_str(&format!("    jmp {}\n", cond));
            }
            Stmt::Assign(_, id, e) => {
                let t = expr_ty(e, env, sigs);
                cg_value(e, env, sigs, strs, out, target);
                let l = env.iter().find(|v| v.name == *id).expect("analysis checked the local exists");
                match t {
                    Ty::I64 => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", l.off)),
                    Ty::Str => {
                        out.push_str(&format!("    mov %rax, -{}(%rbp)\n", l.off));
                        out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", l.off - 8));
                    }
                    Ty::Bool => unreachable!("booleans rejected in analysis"),
                }
            }
        }
    }
}

fn cg_func(f: &Func, sigs: &[(String, Ty)], strs: &mut Vec<String>, out: &mut String, target: Target) {
    let mut lenv: Vec<CgLocal> = Vec::new();
    let mut frame = 0usize;
    layout_locals(&f.stmts, &mut lenv, sigs, &mut frame);

    out.push_str(&format!("hbc_fn_{}:\n", f.name));
    out.push_str("    push %rbp\n    mov %rsp, %rbp\n");
    // Win64 ABI: rsp must be 16-byte aligned at every call. The Linux
    // frame only needs 8-byte slots (syscalls do not care); round up to 16
    // for Windows so the helper call sites keep ABI alignment.
    let frame = if target == Target::Windows { (frame + 15) & !15 } else { frame };
    if frame > 0 {
        out.push_str(&format!("    sub ${}, %rsp\n", frame));
    }
    let mut env: Vec<CgLocal> = Vec::new();
    let mut walk_frame = 0usize;
    let mut label = 0usize;
    cg_stmts(&f.stmts, &mut env, &mut walk_frame, sigs, strs, out, target, &f.name, &mut label, &None);
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
        let mut top_exits: Vec<Vec<bool>> = Vec::new();
        if let Err(m) = check_stmts(&f.stmts, &mut env, &sigs, &mut ret, None, &mut top_exits) {
            eprintln!("error: {}", m);
            process::exit(1);
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

