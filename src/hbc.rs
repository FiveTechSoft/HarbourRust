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

// The preprocessor is part of hbc: every compile runs it automatically
// (shared engine in pp.rs; hpp is only a standalone debug frontend).
#[path = "pp.rs"]
mod pp;

#[derive(Clone, Copy, PartialEq, Debug)]
enum Ty { I64, Str, Bool, Arr(usize) }

#[derive(Clone, PartialEq, Debug)]
enum Tok {
    Ident(String),
    Int(String),
    Str(String), // already unescaped content
    Plus, Minus, Star, Slash,
    LParen, RParen, Comma,
    LBrace, RBrace, LBracket, RBracket,
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
            ',' => { toks.push(Tok::Comma); it.next(); }
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
            '{' => { toks.push(Tok::LBrace); it.next(); }
            '}' => { toks.push(Tok::RBrace); it.next(); }
            '[' => { toks.push(Tok::LBracket); it.next(); }
            ']' => { toks.push(Tok::RBracket); it.next(); }
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
    Call(String, Vec<Expr>),
    Bin(char, Box<Expr>, Box<Expr>),
    Cmp(CmpOp, Box<Expr>, Box<Expr>), // i64 operands only (checked in analysis)
    ArrLit(Vec<Expr>),             // {e1, ..., eN}; i64 elements, fixed size
    Index(String, Box<Expr>),      // a[i]; Harbour base 1 (probe a1)
}

#[derive(Debug)]
enum Stmt {
    Local(usize, String, Expr),
    Print(usize, Vec<Expr>),
    Ret(usize, Option<Expr>),
    If(usize, Expr, Vec<Stmt>, Vec<Stmt>), // line, condition, then, else (possibly empty)
    While(usize, Expr, Vec<Stmt>), // line, condition, body
    Assign(usize, String, Expr),   // x := expr on an already-declared local
    ArrSet(usize, String, Expr, Expr), // a[i] := expr (index is 1-based)
    Exit(usize),                 // exit: leave the innermost loop
    Loop(usize),                 // loop: jump to the next iteration of the innermost loop
    For(usize, String, Expr, Expr, i64, Vec<Stmt>), // line, var, start, end, step (non-zero literal), body
}

struct Func {
    name: String,
    params: Vec<String>,
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
            // Harbour unary minus (probe q1: `? -7`): sugar for 0 - e, so
            // the i64 typing/codegen path applies unchanged.
            Some(Tok::Minus) => {
                let e = self.factor()?;
                Ok(Expr::Bin('-', Box::new(Expr::Int("0".to_string())), Box::new(e)))
            }
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
                    let mut args: Vec<Expr> = Vec::new();
                    if self.peek() != Some(&Tok::RParen) {
                        loop {
                            args.push(self.expr()?);
                            match self.bump() {
                                Some(Tok::Comma) => continue,
                                Some(Tok::RParen) => break,
                                other => return Err(format!("line {}: expected `,` or `)` in call arguments, got {:?}", self.n, other)),
                            }
                        }
                    } else {
                        self.pos += 1;
                    }
                    Ok(Expr::Call(id, args))
                } else if self.peek() == Some(&Tok::LBracket) {
                    // a[i] - one index level in this increment
                    self.pos += 1;
                    let idx = self.expr()?;
                    if self.bump() != Some(Tok::RBracket) {
                        return Err(format!("line {}: expected `]` after the array index", self.n));
                    }
                    Ok(Expr::Index(id, Box::new(idx)))
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
            Some(Tok::LBrace) => {
                // Array literal {e1, ..., eN}. The empty literal is out of
                // this increment (registered limitation).
                if self.peek() == Some(&Tok::RBrace) {
                    return Err(format!("line {}: empty array literal {{}} is not in this increment", self.n));
                }
                let mut items = Vec::new();
                loop {
                    items.push(self.expr()?);
                    match self.bump() {
                        Some(Tok::Comma) => continue,
                        Some(Tok::RBrace) => break,
                        other => return Err(format!("line {}: expected `,` or `}}` in the array literal, got {:?}", self.n, other)),
                    }
                }
                Ok(Expr::ArrLit(items))
            }
            None => Err(format!("line {}: incomplete expression (operand or ) missing)", self.n)),
            Some(t) => Err(format!("line {}: unexpected token {:?} in expression", self.n, t)),
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
    "print_i64", "print_str", "bound_error",
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
                // Harbour `?`: bare prints a blank line; otherwise a
                // comma-separated expression list (probes b51/b57).
                let rest = &toks[1..];
                let mut exprs = Vec::new();
                if !rest.is_empty() {
                    let mut depth = 0i32;
                    let mut start = 0usize;
                    for (k, t) in rest.iter().enumerate() {
                        match t {
                            Tok::LParen => depth += 1,
                            Tok::RParen => depth -= 1,
                            Tok::Comma if depth == 0 => {
                                exprs.push(parse_expr_tokens(rest[start..k].to_vec(), n)?);
                                start = k + 1;
                            }
                            _ => {}
                        }
                    }
                    exprs.push(parse_expr_tokens(rest[start..].to_vec(), n)?);
                }
                out.push(Stmt::Print(n, exprs));
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
                if toks.len() >= 2 && toks[1] == Tok::LBracket {
                    // a[i] := expr (one index level in this increment)
                    check_ident(&id, n)?;
                    let rb = match toks[2..].iter().position(|t| *t == Tok::RBracket) {
                        Some(p) => p + 2,
                        None => return Err(format!("line {}: expected `name[idx] := expr`", n)),
                    };
                    if rb == 2 || toks.len() <= rb + 1 || toks[rb + 1] != Tok::Assign {
                        return Err(format!("line {}: expected `name[idx] := expr`", n));
                    }
                    let idx = parse_expr_tokens(toks[2..rb].to_vec(), n)?;
                    let e = parse_expr_tokens(toks[rb + 2..].to_vec(), n)?;
                    out.push(Stmt::ArrSet(n, id, idx, e));
                    *i += 1;
                    continue;
                }
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
        let (name, params) = match toks.as_slice() {
            [Tok::KwFunction, Tok::Ident(id), Tok::LParen, Tok::RParen] => {
                check_ident(id, *n)?;
                (id.clone(), Vec::new())
            }
            [Tok::KwFunction, Tok::Ident(id), Tok::LParen, rest @ .., Tok::RParen] if !rest.is_empty() => {
                check_ident(id, *n)?;
                let mut ps: Vec<String> = Vec::new();
                for (k, t) in rest.iter().enumerate() {
                    let want_ident = k % 2 == 0;
                    match (want_ident, t) {
                        (true, Tok::Ident(p)) => {
                            check_ident(p, *n)?;
                            if ps.iter().any(|q| q == p) {
                                return Err(format!("line {}: duplicate parameter `{}`", n, p));
                            }
                            ps.push(p.clone());
                        }
                        (false, Tok::Comma) => {}
                        _ => return Err(format!("line {}: expected `function name(a, b)` with comma-separated parameters", n)),
                    }
                }
                (id.clone(), ps)
            }
            _ => return Err(format!("line {}: expected `function name(...)`", n)),
        };
        i += 1;
        let mut f = Func { name, params, ret: None, stmts: Vec::new() };
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
// Function signature: name, parameter types (i64 only in this increment),
// return type. Passing an integer argument COPIES it (Rust i64 is Copy);
// passing a string is a type error at the call site in this increment.
struct Sig {
    name: String,
    params: Vec<Ty>,
    // None when the function ends in `return nil` (void): its result cannot
    // be used in an expression in this PoC.
    ret: Option<Ty>,
}

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

// ---------------------------------------------------------------------------
// Parameter type pinning (pre-pass, syntactic). Harbour parameters are
// untyped; this PoC is statically typed, so a parameter's type is pinned by
// how the body uses it: under arithmetic it is an integer, compared against
// a string literal (or a literal-initialized local) it is a string, passed
// to another function it takes that parameter's type. A parameter the body
// only prints, returns or copies is NOT pinnable: report it honestly
// instead of guessing.
// ---------------------------------------------------------------------------
fn pin_params(f: &Func, sigs: &[Sig]) -> Result<Vec<Ty>, String> {
    let n = f.params.len();
    let mut pin: Vec<Option<Ty>> = vec![None; n];
    let mut lit: Vec<(String, Ty)> = Vec::new(); // literal-initialized locals
    fn is_param(f: &Func, id: &str) -> Option<usize> {
        f.params.iter().position(|p| p == id)
    }
    fn setpin(pin: &mut Vec<Option<Ty>>, idx: usize, ty: Ty, n: usize) -> Result<(), String> {
        match pin[idx] {
            None => { pin[idx] = Some(ty); Ok(()) }
            Some(t) if t == ty => Ok(()),
            Some(t) => Err(format!("line {}: parameter used as both {} and {}", n,
                if t == Ty::I64 { "an integer" } else { "a string" },
                if ty == Ty::I64 { "an integer" } else { "a string" })),
        }
    }
    // Pin parameter vars appearing directly (not under a call) in e.
    fn pin_vars(f: &Func, e: &Expr, ty: Ty, pin: &mut Vec<Option<Ty>>, n: usize) -> Result<(), String> {
        match e {
            Expr::Var(id) => { if let Some(i) = is_param(f, id) { setpin(pin, i, ty, n)?; } Ok(()) }
            Expr::Bin(_, a, b) => { pin_vars(f, a, Ty::I64, pin, n)?; pin_vars(f, b, Ty::I64, pin, n) }
            Expr::Cmp(_, a, b) => { pin_vars(f, a, ty, pin, n)?; pin_vars(f, b, ty, pin, n) }
            Expr::Call(_, _) => Ok(()), // call arguments pin via the callee's signature, not the outer context
            Expr::ArrLit(es) => { for e in es { pin_vars(f, e, Ty::I64, pin, n)?; } Ok(()) }
            Expr::Index(id, ie) => {
                if is_param(f, id).is_some() {
                    return Err(format!("line {}: array parameters are not in this increment", n));
                }
                pin_vars(f, ie, Ty::I64, pin, n)
            }
            _ => Ok(()),
        }
    }
    fn walk(f: &Func, e: &Expr, sigs: &[Sig], lit: &[(String, Ty)], pin: &mut Vec<Option<Ty>>, n: usize) -> Result<(), String> {
        match e {
            Expr::Bin(_, a, b) => {
                pin_vars(f, a, Ty::I64, pin, n)?;
                pin_vars(f, b, Ty::I64, pin, n)?;
                walk(f, a, sigs, lit, pin, n)?;
                walk(f, b, sigs, lit, pin, n)
            }
            Expr::Cmp(_, a, b) => {
                let ta = match a.as_ref() {
                    Expr::Str(_) => Some(Ty::Str),
                    Expr::Int(_) => Some(Ty::I64),
                    Expr::Var(v) => lit.iter().find(|(x, _)| x == v).map(|(_, t)| *t),
                    _ => None,
                };
                let tb = match b.as_ref() {
                    Expr::Str(_) => Some(Ty::Str),
                    Expr::Int(_) => Some(Ty::I64),
                    Expr::Var(v) => lit.iter().find(|(x, _)| x == v).map(|(_, t)| *t),
                    _ => None,
                };
                if let Some(t) = ta { pin_vars(f, b, t, pin, n)?; }
                if let Some(t) = tb { pin_vars(f, a, t, pin, n)?; }
                walk(f, a, sigs, lit, pin, n)?; walk(f, b, sigs, lit, pin, n)
            }
            Expr::Call(id, args) => {
                if let Some(sig) = sigs.iter().find(|v| v.name == *id) {
                    for (i, a) in args.iter().enumerate() {
                        if i < sig.params.len() { pin_vars(f, a, sig.params[i], pin, n)?; }
                    }
                }
                for a in args { walk(f, a, sigs, lit, pin, n)?; }
                Ok(())
            }
            Expr::ArrLit(es) => {
                for e in es { pin_vars(f, e, Ty::I64, pin, n)?; walk(f, e, sigs, lit, pin, n)?; }
                Ok(())
            }
            Expr::Index(id, ie) => {
                if is_param(f, id).is_some() {
                    return Err(format!("line {}: array parameters are not in this increment", n));
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, n)
            }
            _ => Ok(()),
        }
    }
    fn walk_stmts(f: &Func, stmts: &[Stmt], sigs: &[Sig], lit: &mut Vec<(String, Ty)>, pin: &mut Vec<Option<Ty>>) -> Result<(), String> {
        for st in stmts {
            match st {
                Stmt::Local(n, name, e) => {
                    walk(f, e, sigs, lit, pin, *n)?;
                    match e {
                        Expr::Str(_) => lit.push((name.clone(), Ty::Str)),
                        Expr::Int(_) => lit.push((name.clone(), Ty::I64)),
                        _ => {}
                    }
                }
                Stmt::Assign(n, _, e) => { walk(f, e, sigs, lit, pin, *n)?; }
                Stmt::Print(n, es) => { for e in es { walk(f, e, sigs, lit, pin, *n)?; } }
                Stmt::Ret(n, Some(e)) => { walk(f, e, sigs, lit, pin, *n)?; }
                Stmt::Ret(_, None) => {}
                Stmt::If(n, c, a, b) => {
                    walk(f, c, sigs, lit, pin, *n)?;
                    walk_stmts(f, a, sigs, lit, pin)?;
                    walk_stmts(f, b, sigs, lit, pin)?;
                }
                Stmt::While(n, c, body) => {
                    walk(f, c, sigs, lit, pin, *n)?;
                    walk_stmts(f, body, sigs, lit, pin)?;
                }
                Stmt::For(n, _, a, b, _, body) => {
                    // for bounds are i64 by construction (integer counters
                    // only): they pin a parameter used as a bound (t61).
                    pin_vars(f, a, Ty::I64, pin, *n)?;
                    pin_vars(f, b, Ty::I64, pin, *n)?;
                    walk(f, a, sigs, lit, pin, *n)?; walk(f, b, sigs, lit, pin, *n)?;
                    walk_stmts(f, body, sigs, lit, pin)?;
                }
                Stmt::ArrSet(n, _, ie, e) => {
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::Exit(_) | Stmt::Loop(_) => {}
            }
        }
        Ok(())
    }
    walk_stmts(f, &f.stmts, sigs, &mut lit, &mut pin)?;
    for (i, p) in f.params.iter().enumerate() {
        if pin[i].is_none() {
            return Err(format!("cannot infer the type of parameter `{}` of function `{}` (printing, returning or copying it is not enough; use it in arithmetic or compare it against a value of known type)", p, f.name));
        }
    }
    Ok(pin.into_iter().map(|x| x.unwrap()).collect())
}

fn type_expr(e: &Expr, env: &mut [Local], sigs: &[Sig], n: usize) -> Result<Ty, String> {
    match e {
        Expr::Int(_) => Ok(Ty::I64),
        Expr::Str(_) => Ok(Ty::Str),
        Expr::Var(id) => match env.iter().find(|v| v.name == *id) {
            None => Err(format!("line {}: undefined variable `{}`", n, id)),
            Some(v) if v.moved => Err(format!(
                "line {}: use of moved value `{}` (strings move on assignment or when passed as an argument; they do not copy)", n, id)),
            Some(v) => Ok(v.ty),
        },
        Expr::Call(id, args) => {
            let sig = sigs.iter().find(|v| v.name == *id)
                .ok_or_else(|| format!("line {}: unknown function `{}` (must be defined before use)", n, id))?;
            if sig.params.len() != args.len() {
                return Err(format!("line {}: `{}` takes {} argument(s), got {}", n, id, sig.params.len(), args.len()));
            }
            for (i, a) in args.iter().enumerate() {
                let ta = type_expr(a, env, sigs, n)?;
                if let Ty::Arr(_) = ta {
                    return Err(format!("line {}: arrays cannot be passed as arguments in this increment", n));
                }
                // A string argument moves out of its variable right away, so
                // a second use later in the same expression (e.g. the other
                // side of a `+`) is rejected like any other use-after-move.
                if ta == Ty::Str {
                    if let Expr::Var(v) = a {
                        if let Some(x) = env.iter_mut().find(|x| x.name == *v && x.ty == Ty::Str) { x.moved = true; }
                    }
                }
                if ta != sig.params[i] {
                    return Err(format!("line {}: argument {} of `{}` must be {}, got {}",
                        n, i + 1, id,
                        if sig.params[i] == Ty::I64 { "an integer" } else { "a string" },
                        if ta == Ty::I64 { "an integer" } else { "a string" }));
                }
            }
            match sig.ret {
                Some(t) => Ok(t),
                None => Err(format!("line {}: `{}` returns nothing (`return nil`); its result cannot be used in an expression in this PoC", n, id)),
            }
        }
        Expr::Bin(_, a, b) => {
            let ta = type_expr(a, env, sigs, n)?;
            let tb = type_expr(b, env, sigs, n)?;
            if ta != Ty::I64 || tb != Ty::I64 {
                return Err(format!("line {}: arithmetic requires integers", n));
            }
            Ok(Ty::I64)
        }
        Expr::Cmp(op, a, b) => {
            let ta = type_expr(a, env, sigs, n)?;
            let tb = type_expr(b, env, sigs, n)?;
            if let Ty::Arr(_) = ta {
                return Err(format!("line {}: arrays do not compare in this increment", n));
            }
            if let Ty::Arr(_) = tb {
                return Err(format!("line {}: arrays do not compare in this increment", n));
            }
            if ta == Ty::I64 && tb == Ty::I64 {
                return Ok(Ty::Bool);
            }
            if ta == Ty::Str && tb == Ty::Str {
                // Comparison BORROWS both operands (nothing is moved).
                // Ordering is byte-wise (memcmp-like): no collation.
                let _ = op;
                return Ok(Ty::Bool);
            }
            if ta != tb {
                return Err(format!("line {}: cannot compare a string with an integer in this PoC", n));
            }
            Err(format!("line {}: comparisons require integers", n))
        }
        Expr::ArrLit(es) => {
            for e in es {
                if type_expr(e, env, sigs, n)? != Ty::I64 {
                    return Err(format!("line {}: array elements must be integers in this increment", n));
                }
            }
            Ok(Ty::Arr(es.len()))
        }
        Expr::Index(id, ie) => {
            // Arrays are [i64; N] in the Rust model: Copy elements, no
            // moves, no ownership involvement (rustc-verified semantics).
            if type_expr(ie, env, sigs, n)? != Ty::I64 {
                return Err(format!("line {}: array index must be an integer", n));
            }
            match env.iter().find(|v| v.name == *id) {
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                Some(v) => match v.ty {
                    Ty::Arr(k) => {
                        if let Expr::Int(lit) = ie.as_ref() {
                            let bad = lit.parse::<i64>().map(|x| x < 1 || x > k as i64).unwrap_or(true);
                            if bad {
                                return Err(format!("line {}: array index {} out of bounds (`{}` has {} element(s), base 1)", n, lit, id, k));
                            }
                        }
                        Ok(Ty::I64)
                    }
                    _ => Err(format!("line {}: indexing applies to arrays in this increment; `{}` is not an array", n, id)),
                },
            }
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
fn check_stmts(stmts: &[Stmt], env: &mut Vec<Local>, sigs: &[Sig], ret: &mut Option<Ty>, loop_pre: Option<&Vec<bool>>, exits: &mut Vec<Vec<bool>>) -> Result<bool, String> {
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
                apply_moves(e, env, sigs, true);
                env.push(Local { name: id.clone(), ty: t, moved: false, ro: false });
            }
            Stmt::Print(n, es) => {
                // Printing borrows the value; it never moves it.
                for e in es {
                    let t = type_expr(e, env, sigs, *n)?;
                    if t == Ty::Bool {
                        return Err(format!("line {}: cannot print a boolean in this PoC", n));
                    }
                    if let Ty::Arr(_) = t {
                        return Err(format!("line {}: cannot print an array directly in this increment (print an element: `? a[i]`)", n));
                    }
                }
            }
            Stmt::Ret(n, Some(e)) => {
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::Bool {
                    return Err(format!("line {}: cannot return a boolean in this PoC", n));
                }
                if let Ty::Arr(_) = t {
                    return Err(format!("line {}: arrays cannot be returned in this increment", n));
                }
                apply_moves(e, env, sigs, true);
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
                apply_moves(cond, env, sigs, false);
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
                apply_moves(cond, env, sigs, false);
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
                apply_moves(start, env, sigs, false);
                apply_moves(end, env, sigs, false);
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
            Stmt::ArrSet(n, id, ie, e) => {
                if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array index must be an integer", n));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array elements must be integers in this increment", n));
                }
                apply_moves(ie, env, sigs, false);
                apply_moves(e, env, sigs, true);
                let v = match env.iter().find(|v| v.name == *id) {
                    Some(v) => v,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if v.ro {
                    return Err(format!("line {}: cannot assign through the `for` loop variable `{}`", n, id));
                }
                match v.ty {
                    Ty::Arr(k) => {
                        if let Expr::Int(lit) = ie {
                            let bad = lit.parse::<i64>().map(|x| x < 1 || x > k as i64).unwrap_or(true);
                            if bad {
                                return Err(format!("line {}: array index {} out of bounds (`{}` has {} element(s), base 1)", n, lit, id, k));
                            }
                        }
                    }
                    _ => return Err(format!("line {}: indexed assignment applies to arrays; `{}` is not an array", n, id)),
                }
            }
            Stmt::Assign(n, id, e) => {
                // RHS is evaluated first; a Str source variable moves.
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::Bool {
                    return Err(format!("line {}: booleans only exist in conditions in this PoC", n));
                }
                apply_moves(e, env, sigs, true);
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
// Mark moved-out string vars. `moving` is true where the position consumes
// the value (a local/assign/return root expression, a string argument slot);
// a bare var in a comparison or arithmetic only borrows. Call arguments move
// when the callee's parameter is a string: callers hand over ownership, like
// a Rust String passed by value. i64 never moves (Copy).
fn apply_moves(e: &Expr, env: &mut [Local], sigs: &[Sig], moving: bool) {
    match e {
        Expr::Var(id) => {
            if moving {
                if let Some(v) = env.iter_mut().find(|v| v.name == *id && v.ty == Ty::Str) { v.moved = true; }
            }
        }
        Expr::Bin(_, a, b) => { apply_moves(a, env, sigs, false); apply_moves(b, env, sigs, false); }
        Expr::Cmp(_, a, b) => { apply_moves(a, env, sigs, false); apply_moves(b, env, sigs, false); }
        Expr::Call(id, args) => {
            let sig = sigs.iter().find(|v| v.name == *id).expect("checked");
            for (i, a) in args.iter().enumerate() {
                let m = i < sig.params.len() && sig.params[i] == Ty::Str;
                apply_moves(a, env, sigs, m);
            }
        }
        Expr::ArrLit(es) => { for e in es { apply_moves(e, env, sigs, false); } }
        Expr::Index(_, ie) => apply_moves(ie, env, sigs, false),
        _ => {}
    }
}

// ---------------------------------------------------------------------------
// Code generation: x86-64 assembly (AT&T syntax), freestanding.
//   i64 value  -> %rax
//   Str value  -> %rax = ptr, %rdx = len
// Locals live in the stack frame: i64 takes 8 bytes, Str takes 16.
// ---------------------------------------------------------------------------

fn size_of(t: Ty) -> usize {
    match t { Ty::I64 => 8, Ty::Str => 16, Ty::Arr(n) => 8 * n, Ty::Bool => unreachable!("booleans rejected in analysis") }
}

#[derive(Clone)]
struct CgLocal {
    name: String,
    ty: Ty,
    off: usize, // offset below rbp of the FIRST slot (ptr for Str, value for i64)
}

fn cg_expr(e: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
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
                Ty::Arr(_) => unreachable!("whole-array values are emitted via cg_array_value"),
            }
        }
        Expr::Call(id, args) => {
            let _ = sigs;
            // Arguments are evaluated and pushed LEFT TO RIGHT (Harbour
            // order; it matters if an argument expression fails, e.g. an
            // integer division by zero), each in a 16-byte slot (keeps rsp
            // 16-aligned on both targets); arg k then sits at
            // 16*(n-k)(%rbp) in the callee after its prologue.
            for a in args.iter() {
                let ta = expr_ty(a, env, sigs);
                cg_value(a, env, sigs, strs, out, target);
                if ta == Ty::Str {
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                } else {
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                }
            }
            out.push_str(&format!("    call hbc_fn_{}\n", id));
            if !args.is_empty() {
                out.push_str(&format!("    add ${}, %rsp\n", 16 * args.len()));
            }
        }
        Expr::ArrLit(_) => unreachable!("array literals are emitted via cg_array_value"),
        Expr::Index(id, ie) => {
            let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
            let k = match v.ty { Ty::Arr(k) => k, _ => unreachable!("checked") };
            cg_expr(ie, env, sigs, strs, out, target);
            // Harbour base 1: valid indexes are 1..=k (probe a1). A runtime
            // miss exits via hbc_bound_error (noreturn); Harbour instead
            // opens an interactive error dialog (probes a1/a2) - a
            // registered failure-mode difference, same error condition.
            out.push_str(&format!("    cmp $1, %rax\n    jl 81f\n    cmp ${}, %rax\n    jg 81f\n", k));
            out.push_str(&format!("    lea -{}(%rbp), %r11\n    mov -8(%r11,%rax,8), %rax\n    jmp 82f\n", v.off));
            out.push_str("81:\n    call hbc_bound_error\n82:\n");
        }
        Expr::Bin(op, a, b) => {
            // arithmetic is i64-only (checked in analysis)
            cg_expr(a, env, sigs, strs, out, target);
            // Keep the lhs on the stack while evaluating the rhs. On Windows
            // a plain push would break 16-byte alignment for any call inside
            // the rhs (e.g. `1 + valor()`), so reserve a full 16-byte slot.
            match target {
                Target::Linux => out.push_str("    push %rax\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
            }
            cg_expr(b, env, sigs, strs, out, target);
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
fn cg_value(e: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    if let Expr::Str(s) = e {
        let idx = strs.len();
        strs.push(s.clone());
        out.push_str(&format!("    lea .Lstr{}(%rip), %rax\n", idx));
        out.push_str(&format!("    mov ${}, %edx\n", s.as_bytes().len()));
    } else {
        cg_expr(e, env, sigs, strs, out, target);
    }
}

// Emit an array-producing expression into a frame slot: a literal stores
// each element left to right; a whole-array variable COPIES (Rust [i64; N]
// is Copy - verified against rustc: mutating the copy leaves the source
// intact; Harbour shares a reference instead, a registered MODEL
// difference). Element k sits 8*k bytes below the first slot.
fn cg_array_value(e: &Expr, off: usize, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    match e {
        Expr::ArrLit(es) => {
            for (k, item) in es.iter().enumerate() {
                cg_expr(item, env, sigs, strs, out, target);
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off - 8 * k));
            }
        }
        Expr::Var(id) => {
            let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
            let n = match v.ty { Ty::Arr(n) => n, _ => unreachable!("checked") };
            for k in 0..n {
                out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off - 8 * k));
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off - 8 * k));
            }
        }
        _ => unreachable!("only literals and variables produce array values in this increment"),
    }
}

fn expr_ty(e: &Expr, env: &[CgLocal], sigs: &[Sig]) -> Ty {
    match e {
        Expr::Int(_) | Expr::Bin(_, _, _) => Ty::I64,
        Expr::Str(_) => Ty::Str,
        Expr::Var(id) => env.iter().find(|v| v.name == *id).expect("checked").ty,
        Expr::Call(id, _) => sigs.iter().find(|v| v.name == *id).expect("checked").ret.expect("checked"),
        Expr::Cmp(..) => Ty::Bool,
        Expr::ArrLit(es) => Ty::Arr(es.len()),
        Expr::Index(_, _) => Ty::I64,
    }
}

// Layout pass: assigns stack slots in declaration order and computes the
// total frame size. Branch locals get their own slots and are scoped: the
// env is truncated at each branch join. The codegen walk below rebuilds
// the exact same env, so offsets match.
fn layout_locals(stmts: &[Stmt], env: &mut Vec<CgLocal>, sigs: &[Sig], frame: &mut usize) {
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
fn cg_cond_jump(cond: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target, true_label: &str) {
    match cond {
        Expr::Cmp(op, a, b) if expr_ty(a, env, sigs) == Ty::Str => {
            // String equality/inequality: byte-compare via hbc_str_eq.
            // The lhs (ptr,len) pair is saved while the rhs is evaluated;
            // the comparison borrows both operands (no move).
            cg_value(a, env, sigs, strs, out, target);
            match target {
                Target::Linux => out.push_str("    push %rax\n    push %rdx\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n"),
            }
            cg_value(b, env, sigs, strs, out, target);
            out.push_str("    mov %rax, %rcx\n    mov %rdx, %r8\n");
            match target {
                Target::Linux => out.push_str("    pop %rdx\n    pop %rax\n"),
                Target::Windows => out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n"),
            }
            let j = match op {
                CmpOp::Eq | CmpOp::Ne => {
                    out.push_str("    call hbc_str_eq\n    test %rax, %rax\n");
                    match op { CmpOp::Eq => "jnz", _ => "jz" }
                }
                _ => {
                    // hbc_str_cmp returns -1, 0 or 1 (byte-wise, like memcmp)
                    out.push_str("    call hbc_str_cmp\n    cmp $0, %rax\n");
                    match op {
                        CmpOp::Lt => "jl", CmpOp::Le => "jle",
                        CmpOp::Gt => "jg", CmpOp::Ge => "jge",
                        _ => unreachable!(),
                    }
                }
            };
            out.push_str(&format!("    {} {}\n", j, true_label));
        }
        Expr::Cmp(op, a, b) => {
            cg_expr(a, env, sigs, strs, out, target);
            match target {
                Target::Linux => out.push_str("    push %rax\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
            }
            cg_expr(b, env, sigs, strs, out, target);
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

fn cg_stmts(stmts: &[Stmt], env: &mut Vec<CgLocal>, frame: &mut usize, sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target, fname: &str, label: &mut usize, ll: &Option<(String, String)>) {
    for s in stmts {
        match s {
            Stmt::Local(_, id, e) => {
                let t = expr_ty(e, env, sigs);
                *frame += size_of(t);
                let off = *frame;
                match t {
                    Ty::Arr(_) => cg_array_value(e, off, env, sigs, strs, out, target),
                    _ => {
                        cg_value(e, env, sigs, strs, out, target);
                        match t {
                            Ty::I64 => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off)),
                            Ty::Str => {
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            _ => unreachable!("booleans rejected in analysis"),
                        }
                    }
                }
                env.push(CgLocal { name: id.clone(), ty: t, off });
            }
            Stmt::Print(_, es) => {
                // Harbour `?` is a QOut( <items> ) call (probes b51-b59,
                // t12 vs -gtstd binary): ALL items are evaluated FIRST
                // (side effects like prints inside calls happen before the
                // newline), then the newline, then the items joined by one
                // space; integers right-aligned in a 10-column field,
                // strings raw; no trailing newline.
                for e in es {
                    cg_value(e, env, sigs, strs, out, target);
                    out.push_str("    push %rdx\n    push %rax\n");
                }
                out.push_str("    call hbc_print_nl\n");
                for (i, e) in es.iter().enumerate() {
                    let t = expr_ty(e, env, sigs);
                    let off = 16 * (es.len() - 1 - i);
                    if i > 0 { out.push_str("    call hbc_print_sep\n"); }
                    out.push_str(&format!("    mov {}(%rsp), %rax\n    mov {}(%rsp), %rdx\n", off, off + 8));
                    match t {
                        Ty::I64 => out.push_str("    call hbc_print_i64\n"),
                        Ty::Str => out.push_str("    call hbc_print_str\n"),
                        Ty::Bool => unreachable!("booleans rejected in analysis"),
                        Ty::Arr(_) => unreachable!("whole-array printing rejected in analysis"),
                    }
                }
                if !es.is_empty() {
                    out.push_str(&format!("    add ${}, %rsp\n", 16 * es.len()));
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
                cg_cond_jump(cond, env, sigs, strs, out, target, &format!(".Lthen_{}_{}", fname, id));
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
                cg_cond_jump(cond, env, sigs, strs, out, target, &format!(".Lbody_{}_{}", fname, id));
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
                let l = env.iter().find(|v| v.name == *id).expect("analysis checked the local exists");
                let off = l.off;
                match t {
                    Ty::Arr(_) => cg_array_value(e, off, env, sigs, strs, out, target),
                    _ => {
                        cg_value(e, env, sigs, strs, out, target);
                        match t {
                            Ty::I64 => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off)),
                            Ty::Str => {
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            _ => unreachable!("booleans rejected in analysis"),
                        }
                    }
                }
            }
            Stmt::ArrSet(_, id, ie, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                let k = match v.ty { Ty::Arr(k) => k, _ => unreachable!("checked") };
                // Index first, kept in a 16-byte stack slot (ABI-safe on
                // both targets if the value expression calls); then the
                // value, then a runtime bounds check, then the store.
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(e, env, sigs, strs, out, target);
                out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 83f\n    cmp ${}, %rcx\n    jg 83f\n", k));
                out.push_str(&format!("    lea -{}(%rbp), %r11\n    mov %rax, -8(%r11,%rcx,8)\n    jmp 84f\n", v.off));
                out.push_str("83:\n    call hbc_bound_error\n84:\n");
            }
        }
    }
}

fn cg_func(f: &Func, sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    let mut lenv: Vec<CgLocal> = Vec::new();
    let mut frame = 0usize;
    // Parameters occupy the first frame slots, sized by their pinned type.
    // (main has no signature entry: it returns nil and takes no parameters.)
    if !f.params.is_empty() {
        let own_sig = sigs.iter().find(|v| v.name == f.name).expect("checked");
        for (i, p) in f.params.iter().enumerate() {
            frame += size_of(own_sig.params[i]);
            lenv.push(CgLocal { name: p.clone(), ty: own_sig.params[i], off: frame });
        }
    }
    let nparams = lenv.len();
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
    // Copy incoming arguments from the caller's stack into the parameter
    // slots: arguments were pushed left to right, so arg k sits at
    // 16*(n-k)(%rbp) after this prologue (the last argument is nearest).
    // A string argument occupies both words of its slot (pointer, length).
    for (k, v) in lenv[..nparams].iter().enumerate() {
        let src = 16 * (nparams - k);
        if v.ty == Ty::Str {
            out.push_str(&format!("    mov {}(%rbp), %rax\n    mov {}(%rbp), %rdx\n", src, src + 8));
            out.push_str(&format!("    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", v.off, v.off - 8));
        } else {
            out.push_str(&format!("    mov {}(%rbp), %rax\n", src));
            out.push_str(&format!("    mov %rax, -{}(%rbp)\n", v.off));
        }
    }
    let mut env: Vec<CgLocal> = lenv[..nparams].to_vec();
    let mut walk_frame = env.iter().map(|v| size_of(v.ty)).sum();
    let mut label = 0usize;
    cg_stmts(&f.stmts, &mut env, &mut walk_frame, sigs, strs, out, target, &f.name, &mut label, &None);
    out.push_str(&format!(".Lret_{}:\n", f.name));
    out.push_str("    leave\n    ret\n\n");
}

fn emit_asm(funcs: &[Func], sigs: &[Sig], target: Target) -> String {
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
# hbc_print_str: %rax = ptr, %rdx = len. Writes the raw bytes, no newline:
# Harbour `?` emits the newline BEFORE the items (probes b51-b57).
hbc_print_str:
    mov %rax, %rsi
    mov $1, %eax
    mov $1, %edi
    syscall
    ret

# hbc_print_nl / hbc_print_sep: the `?` leading newline / item separator.
hbc_print_nl:
    lea .Lnl(%rip), %rax
    mov $1, %edx
    jmp hbc_print_str
hbc_print_sep:
    lea .Lpad20(%rip), %rax
    mov $1, %edx
    jmp hbc_print_str

# hbc_str_eq: %rax = lhs ptr, %rdx = lhs len, %rcx = rhs ptr, %r8 = rhs len.
# Returns %rax = 1 when equal, 0 otherwise. Harbour default (SET EXACT
# OFF) `=`: compare over the length of the RIGHT operand, left read
# NUL-padded - "abcd" = "abc" is true, "abc" = "abcd" false, anything
# = "" true (probe b23). Harbour's exact `==` is not in this grammar.
# Leaf routine: no calls, only volatile registers.
hbc_str_eq:
    xor %r9, %r9
91:
    cmp %r8, %r9
    jae 92f
    movzbl (%rcx,%r9), %r10d
    cmp %rdx, %r9
    jae 94f
    movzbl (%rax,%r9), %r11d
    jmp 93f
94:
    xor %r11d, %r11d
93:
    cmp %r11b, %r10b
    jne 90f
    inc %r9
    jmp 91b
92:
    mov $1, %eax
    ret
90:
    xor %eax, %eax
    ret

# hbc_str_cmp: same inputs as hbc_str_eq. Returns %rax = -1, 0 or 1.
# Harbour default (SET EXACT OFF) ordering: compare over the length of
# the RIGHT operand only; the left operand is read NUL-padded past its
# end, so "abc" < "abcd" is true but "abcd" > "abc" is false and
# "abcd" <= "abc" is true (xBase asymmetric prefix rule, probe b22).
# No collation, no Unicode awareness. Leaf: no calls, volatile regs.
hbc_str_cmp:
    xor %r9d, %r9d
95:
    cmp %r8, %r9
    jae 96f
    movzbl (%rcx,%r9), %r10d
    cmp %rdx, %r9
    jae 94f
    movzbl (%rax,%r9), %r11d
    jmp 93f
94:
    xor %r11d, %r11d
93:
    cmp %r11b, %r10b
    jb 98f
    ja 97f
    inc %r9
    jmp 95b
96:
    xor %eax, %eax
    ret
98:
    mov $1, %eax
    ret
97:
    mov $-1, %rax
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
    # Harbour `?` integer field (probes q1/q5/q6): positives right-align in
    # max(10, digits+1); negatives in 10 when they fit, 20 otherwise.
    lea 1(%rsi), %r9
    lea -1(%rbp), %r10
    sub %r9, %r10
    inc %r10
    cmpb $45, (%r9)
    je 5f
    lea 1(%r10), %rcx
    mov $10, %rax
    cmp %rax, %rcx
    cmovae %rcx, %rax
    jmp 6f
5:
    mov $10, %rax
    cmp %rax, %r10
    jbe 6f
    mov $20, %rax
6:
    sub %r10, %rax
    jle 7f
    mov %rax, %rdx
    lea .Lpad20(%rip), %rsi
    mov $1, %eax
    mov $1, %edi
    syscall
7:
    mov %r9, %rsi
    mov %r10, %rdx
    mov $1, %eax
    mov $1, %edi
    syscall
    leave
    ret
"#);

    out.push_str(r#"
# hbc_bound_error: array index outside 1..=n at runtime (noreturn). Prints
# the Harbour wording and exits 1. Harbour itself opens an interactive
# error dialog here (probes a1/a2 hang even with stdin at EOF): a clean
# exit is the registered failure-mode difference, same error condition.
hbc_bound_error:
    lea .Lboundmsg(%rip), %rsi
    mov $26, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall
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
    out.push_str(".Lpad20:\n    .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32\n");
    // "Bound error: array access\n" (26 bytes; Harbour wording, probe a1)
    out.push_str(".Lboundmsg:\n    .byte 66,111,117,110,100,32,101,114,114,111,114,58,32,97,114,114,97,121,32,97,99,99,101,115,115,10\n");
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
    leave
    ret

# hbc_print_nl / hbc_print_sep: the `?` leading newline / item separator.
hbc_print_nl:
    lea .Lnl(%rip), %rax
    mov $1, %edx
    jmp hbc_print_str
hbc_print_sep:
    lea .Lpad20(%rip), %rax
    mov $1, %edx
    jmp hbc_print_str

# hbc_str_eq: %rax = lhs ptr, %rdx = lhs len, %rcx = rhs ptr, %r8 = rhs len.
# Returns %rax = 1 when equal, 0 otherwise. Harbour default (SET EXACT
# OFF) `=`: compare over the length of the RIGHT operand, left read
# NUL-padded - "abcd" = "abc" is true, "abc" = "abcd" false, anything
# = "" true (probe b23). Harbour's exact `==` is not in this grammar.
# Leaf routine: no calls, only volatile registers.
hbc_str_eq:
    xor %r9, %r9
91:
    cmp %r8, %r9
    jae 92f
    movzbl (%rcx,%r9), %r10d
    cmp %rdx, %r9
    jae 94f
    movzbl (%rax,%r9), %r11d
    jmp 93f
94:
    xor %r11d, %r11d
93:
    cmp %r11b, %r10b
    jne 90f
    inc %r9
    jmp 91b
92:
    mov $1, %eax
    ret
90:
    xor %eax, %eax
    ret

# hbc_str_cmp: same inputs as hbc_str_eq. Returns %rax = -1, 0 or 1.
# Harbour default (SET EXACT OFF) ordering: compare over the length of
# the RIGHT operand only; the left operand is read NUL-padded past its
# end, so "abc" < "abcd" is true but "abcd" > "abc" is false and
# "abcd" <= "abc" is true (xBase asymmetric prefix rule, probe b22).
# No collation, no Unicode awareness. Leaf: no calls, volatile regs.
hbc_str_cmp:
    xor %r9d, %r9d
95:
    cmp %r8, %r9
    jae 96f
    movzbl (%rcx,%r9), %r10d
    cmp %rdx, %r9
    jae 94f
    movzbl (%rax,%r9), %r11d
    jmp 93f
94:
    xor %r11d, %r11d
93:
    cmp %r11b, %r10b
    jb 98f
    ja 97f
    inc %r9
    jmp 95b
96:
    xor %eax, %eax
    ret
98:
    mov $1, %eax
    ret
97:
    mov $-1, %rax
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
    # Harbour `?` integer field (probes q1/q5/q6): positives right-align in
    # max(10, digits+1); negatives in 10 when they fit, 20 otherwise.
    lea 1(%r10), %rax
    mov %rbp, %rdx
    sub %r10, %rdx
    dec %rdx
    cmpb $45, (%rax)
    je 5f
    lea 1(%rdx), %rcx
    mov $10, %r8
    cmp %r8, %rcx
    cmovae %rcx, %r8
    jmp 6f
5:
    mov $10, %r8
    cmp %r8, %rdx
    jbe 6f
    mov $20, %r8
6:
    sub %rdx, %r8
    jle 7f
    mov %rax, -32(%rbp)
    mov %rdx, -40(%rbp)
    lea .Lpad20(%rip), %rax
    mov %r8, %rdx
    call hbc_print_str
    mov -32(%rbp), %rax
    mov -40(%rbp), %rdx
7:
    call hbc_print_str
    leave
    ret

# hbc_bound_error: array index outside 1..=n at runtime (noreturn). Same
# wording as the linux helper; exit code 1 via ExitProcess.
hbc_bound_error:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    lea .Lboundmsg(%rip), %rax
    mov $26, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess
"#;

#[derive(Clone, Copy, PartialEq)]
enum Target { Linux, Windows }

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut pos: Vec<&String> = Vec::new();
    let mut target = Target::Linux;
    let mut incdirs: Vec<String> = Vec::new();
    let mut ai = 1;
    while ai < args.len() {
        let a = &args[ai];
        match a.as_str() {
            "--target=linux" => target = Target::Linux,
            "--target=windows" => target = Target::Windows,
            "-I" => { ai += 1; incdirs.push(args.get(ai).expect("-I needs a directory").clone()); }
            _ if a.starts_with("-I") => incdirs.push(a[2..].to_string()),
            _ if a.starts_with("--") => { eprintln!("usage: hbc <input.hb> <output.s> [--target=linux|windows] [-I dir]..."); process::exit(2); }
            _ => pos.push(a),
        }
        ai += 1;
    }
    if pos.len() != 2 {
        eprintln!("usage: hbc <input.hb> <output.s> [--target=linux|windows] [-I dir]...");
        process::exit(2);
    }
    // Preprocessing runs automatically on every compile. Errors cite the
    // line in the ORIGINAL file for the main input; lines injected by an
    // #include report against that include file.
    let mut pre = pp::Pp::new(incdirs);
    let mut src = String::new();
    if let Err(m) = pp::process(pos[0], &mut pre, &mut src, 0) {
        eprintln!("error: {}", m);
        process::exit(1);
    }

    let mut funcs = match parse(&src) {
        Ok(f) => f,
        Err(msg) => { eprintln!("error: {}", msg); process::exit(1); }
    };

    // Pass 1: semantic analysis - types, ownership/move, signatures.
    let mut sigs: Vec<Sig> = Vec::new();
    let mut has_main = false;
    for f in &mut funcs {
        if f.name == "main" { has_main = true; }
        // Pin parameter types. On failure, keep going with i64 placeholders
        // so the body check can surface a more specific error first; the pin
        // error is only reported if the body itself checks clean.
        let (ptys, pin_err) = match pin_params(f, &sigs) {
            Ok(v) => (v, None),
            Err(m) => (vec![Ty::I64; f.params.len()], Some(m)),
        };
        let mut env: Vec<Local> = Vec::new();
        // Parameters enter the frame as owned locals: integer arguments copy,
        // string arguments move (callers hand over ownership).
        for (i, p) in f.params.iter().enumerate() {
            env.push(Local { name: p.clone(), ty: ptys[i], moved: false, ro: false });
        }
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
        if let Some(m) = pin_err {
            eprintln!("error: {}", m);
            process::exit(1);
        }
        sigs.push(Sig { name: f.name.clone(), params: ptys.clone(), ret });
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

    fs::write(pos[1], out)
        .unwrap_or_else(|e| { eprintln!("cannot write {}: {}", args[2], e); process::exit(2); });
    println!("{} -> {} ({} functions)", args[1], args[2], funcs.len());
}

