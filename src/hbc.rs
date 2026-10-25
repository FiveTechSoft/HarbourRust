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
enum Ty { I64, Str, Bool, Arr(usize), Block(usize), DArr, DArrU, DArr2, Dyn, Hash }

// Dyn is the tagged-union value for any route that can carry NIL (probes
// n1/n2/n3): a 16-byte {tag, payload} pair, tag 0 = i64 payload, tag 1 =
// NIL. No integer is reserved - i64::MIN is an ordinary payload. Pure i64
// stays 8 bytes wherever NIL is proven absent. In registers a Dyn travels
// as rax=tag, rdx=payload (the Str ptr/len convention reused); on the
// stack the tag is the first word, payload the second.

#[derive(Clone, PartialEq, Debug)]
enum Tok {
    Ident(String),
    Int(String),
    Str(String), // already unescaped content
    Plus, Minus, Star, Slash,
    LParen, RParen, Comma,
    LBrace, RBrace, LBracket, RBracket, Pipe,
    Assign,   // :=
    Question, // ?
    Eq,       // =
    FatArrow, // =>
    Ne,       // <> or !=
    Lt, Le, Gt, Ge,
    KwFunction, KwLocal, KwReturn, KwNil, KwIf, KwElse, KwEndif, KwWhile, KwEnddo, KwExit, KwLoop,
    KwFor, KwTo, KwStep, KwNext,
}

#[derive(Clone, Copy, PartialEq, Debug)]
enum CmpOp { Eq, Ne, Lt, Le, Gt, Ge }

static BLOCK_ID: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
fn new_block_id() -> usize { BLOCK_ID.fetch_add(1, std::sync::atomic::Ordering::SeqCst) }

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
            '=' => {
                it.next();
                match it.peek() {
                    Some(&(_, '>')) => { toks.push(Tok::FatArrow); it.next(); }
                    _ => toks.push(Tok::Eq),
                }
            }
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
            '|' => { toks.push(Tok::Pipe); it.next(); }
            ']' => { toks.push(Tok::RBracket); it.next(); }
            o => return Err(format!("line {}: character not allowed `{}` (U+{:04X})", n, o, o as u32)),
        }
    }
    Ok(toks)
}

#[derive(Debug, Clone)]
enum Expr {
    Int(String),
    Str(String),
    Var(String),
    Call(String, Vec<Expr>),
    Bin(char, Box<Expr>, Box<Expr>),
    Cmp(CmpOp, Box<Expr>, Box<Expr>), // i64 operands only (checked in analysis)
    ArrLit(Vec<Expr>),             // {e1, ..., eN}; i64 elements, fixed size
    Index(String, Box<Expr>),      // a[i]; Harbour base 1 (probe a1)
    Index2(String, Box<Expr>, Box<Expr>), // a[i][j] / a[i,j] on a DArr2 (probe m1/m2)
    BlockLit(usize, Vec<String>, Vec<Expr>), // {|p1, p2| e1, e2} -> last (probes c1-c5)
    DArrNew,                     // {} : empty DYNAMIC array (probes d1, e4)
    Nil,                         // NIL: tagged i64 sentinel (probes n1: prints NIL, NIL==NIL .T., NIL==0 .F.)
    // Hash literal: string keys, i64 values (v1). {=>} is the empty
    // hash; {} stays the empty dynamic array.
    HashLit(Vec<(Expr, Expr)>),
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
    ArrSet2(usize, String, Expr, Expr, Expr), // a[i][j] := expr / a[i,j] := expr
    AAdd(usize, String, Expr),  // AAdd(a, x): grow dynamic array in place (probe d1)
    AAddSub(usize, String, Expr, Expr), // AAdd(a[i], x): grow the subarray (probe m5)
    ASizeSub(usize, String, Expr, Expr), // ASize(a[i], n): resize the subarray
    ASize(usize, String, Expr), // ASize(a, n): resize in place (probe d3)
    Exit(usize),                 // exit: leave the innermost loop
    Loop(usize),                 // loop: jump to the next iteration of the innermost loop
    For(usize, String, Expr, Expr, i64, Vec<Stmt>), // line, var, start, end, step (non-zero literal), body
}

struct Func {
    name: String,
    params: Vec<String>,
    ret: Option<Ty>,
    stmts: Vec<Stmt>,
    // Locals widened to Dyn by prescan (a later assignment can deliver a
    // NIL-capable value, probe n2). Filled in the infer loop, used by cg.
    dyn_names: std::collections::HashSet<String>,
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
            Some(Tok::KwNil) => Ok(Expr::Nil),
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
                    // a[i], a[i][j] and a[i,j] (probe m2: the comma form
                    // is the same nested access in Harbour)
                    self.pos += 1;
                    let idx = self.expr()?;
                    match self.bump() {
                        Some(Tok::RBracket) => {}
                        Some(Tok::Comma) => {
                            let idx2 = self.expr()?;
                            if self.bump() != Some(Tok::RBracket) {
                                return Err(format!("line {}: expected `]` after the second array index", self.n));
                            }
                            return Ok(Expr::Index2(id, Box::new(idx), Box::new(idx2)));
                        }
                        other => return Err(format!("line {}: expected `]` after the array index, got {:?}", self.n, other)),
                    }
                    if self.peek() == Some(&Tok::LBracket) {
                        self.pos += 1;
                        let idx2 = self.expr()?;
                        if self.bump() != Some(Tok::RBracket) {
                            return Err(format!("line {}: expected `]` after the second array index", self.n));
                        }
                        if self.peek() == Some(&Tok::LBracket) {
                            return Err(format!("line {}: more than two index levels are not in this increment", self.n));
                        }
                        return Ok(Expr::Index2(id, Box::new(idx), Box::new(idx2)));
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
                if self.peek() == Some(&Tok::Pipe) {
                    // Codeblock {|p1, p2| e1, ..., eN}: comma-separated
                    // expressions, the value is the LAST one (probe c4).
                    // No captures in this increment (v1).
                    self.pos += 1;
                    let mut params: Vec<String> = Vec::new();
                    loop {
                        match self.bump() {
                            Some(Tok::Pipe) => break,
                            Some(Tok::Ident(id)) => {
                                check_ident(&id, self.n)?;
                                if params.iter().any(|p| *p == id) {
                                    return Err(format!("line {}: duplicate codeblock parameter `{}`", self.n, id));
                                }
                                params.push(id);
                                match self.bump() {
                                    Some(Tok::Comma) => continue,
                                    Some(Tok::Pipe) => break,
                                    other => return Err(format!("line {}: expected `,` or `|` in the codeblock parameters, got {:?}", self.n, other)),
                                }
                            }
                            other => return Err(format!("line {}: expected codeblock parameters between `|`, got {:?}", self.n, other)),
                        }
                    }
                    let mut body = Vec::new();
                    loop {
                        body.push(self.expr()?);
                        match self.bump() {
                            Some(Tok::Comma) => continue,
                            Some(Tok::RBrace) => break,
                            other => return Err(format!("line {}: expected `,` or `}}` in the codeblock body, got {:?}", self.n, other)),
                        }
                    }
                    return Ok(Expr::BlockLit(new_block_id(), params, body));
                }
                // {} is the empty DYNAMIC array value (probes d1, e4);
                // non-empty literals stay fixed-size stack arrays.
                if self.peek() == Some(&Tok::RBrace) {
                    self.pos += 1;
                    return Ok(Expr::DArrNew);
                }
                // {=>} is the EMPTY HASH (probe h2: len 0); {} above is
                // the empty dynamic array - different types in Harbour too.
                if self.peek() == Some(&Tok::FatArrow) {
                    self.pos += 1;
                    if self.bump() != Some(Tok::RBrace) {
                        return Err(format!("line {}: expected `}}` after `{{=>`", self.n));
                    }
                    return Ok(Expr::HashLit(Vec::new()));
                }
                let mut items = Vec::new();
                let first = self.expr()?;
                if self.peek() == Some(&Tok::FatArrow) {
                    // Hash literal {k => v, ...} (probes d4, h5).
                    let mut pairs = Vec::new();
                    let mut key = first;
                    loop {
                        if self.bump() != Some(Tok::FatArrow) {
                            return Err(format!("line {}: expected `=>` after the hash key, got {:?}", self.n, self.peek()));
                        }
                        let val = self.expr()?;
                        pairs.push((key, val));
                        match self.bump() {
                            Some(Tok::Comma) => { key = self.expr()?; continue; }
                            Some(Tok::RBrace) => break,
                            other => return Err(format!("line {}: expected `,` or `}}` in the hash literal, got {:?}", self.n, other)),
                        }
                    }
                    return Ok(Expr::HashLit(pairs));
                }
                items.push(first);
                loop {
                    match self.bump() {
                        Some(Tok::Comma) => { items.push(self.expr()?); continue; }
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
    "print_i64", "print_str", "bound_error", "eval", "len", "hb_memcheck", "aadd", "asize", "alloc", "free", "oom", "asize_neg", "mem_allocs", "mem_frees",
];

fn is_builtin(id: &str, name: &str) -> bool { id.eq_ignore_ascii_case(name) }

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
                    1 => return Err(format!("line {}: an early `return` inside a block needs a value (`return <expr>` or `return nil`); only the closing top-level return may be bare", n)),
                    // `return nil` IS a value since v2c: NIL is a real
                    // tagged value, so an early nil return unifies with the
                    // other returns like any expression (probe n2 order-
                    // independence).
                    2 if toks[1] == Tok::KwNil => Stmt::Ret(n, None),
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
                            Tok::LParen | Tok::LBracket => depth += 1,
                            Tok::RParen | Tok::RBracket => depth -= 1,
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
                    // a[i] := v, a[i][j] := v or a[i,j] := v (probe m2: the
                    // comma form is the same nested access in Harbour)
                    check_ident(&id, n)?;
                    let mut depth = 0i32;
                    let mut rb = 0usize;
                    let mut comma2: Option<usize> = None;
                    for (p, t) in toks.iter().enumerate().skip(1) {
                        match t {
                            Tok::LBracket | Tok::LParen => depth += 1,
                            Tok::RBracket | Tok::RParen => {
                                depth -= 1;
                                if depth == 0 { rb = p; break; }
                            }
                            Tok::Comma if depth == 1 && comma2.is_none() => comma2 = Some(p),
                            _ => {}
                        }
                    }
                    if rb == 0 {
                        return Err(format!("line {}: expected `name[idx] := expr`", n));
                    }
                    if let Some(cp) = comma2 {
                        // a[i, j] := v
                        if toks.len() <= rb + 1 || toks[rb + 1] != Tok::Assign {
                            return Err(format!("line {}: expected `name[idx, idx2] := expr`", n));
                        }
                        let i1 = parse_expr_tokens(toks[2..cp].to_vec(), n)?;
                        let i2 = parse_expr_tokens(toks[cp + 1..rb].to_vec(), n)?;
                        let e = parse_expr_tokens(toks[rb + 2..].to_vec(), n)?;
                        out.push(Stmt::ArrSet2(n, id, i1, i2, e));
                        *i += 1;
                        continue;
                    }
                    if toks.len() > rb + 1 && toks[rb + 1] == Tok::LBracket {
                        // a[i][j] := v
                        let mut depth2 = 0i32;
                        let mut rb2 = 0usize;
                        for (p, t) in toks.iter().enumerate().skip(rb + 1) {
                            match t {
                                Tok::LBracket | Tok::LParen => depth2 += 1,
                                Tok::RBracket | Tok::RParen => {
                                    depth2 -= 1;
                                    if depth2 == 0 { rb2 = p; break; }
                                }
                                _ => {}
                            }
                        }
                        if rb2 == 0 || toks.len() <= rb2 + 1 || toks[rb2 + 1] != Tok::Assign {
                            return Err(format!("line {}: expected `name[idx][idx2] := expr`", n));
                        }
                        let i1 = parse_expr_tokens(toks[2..rb].to_vec(), n)?;
                        let i2 = parse_expr_tokens(toks[rb + 2..rb2].to_vec(), n)?;
                        let e = parse_expr_tokens(toks[rb2 + 2..].to_vec(), n)?;
                        out.push(Stmt::ArrSet2(n, id, i1, i2, e));
                        *i += 1;
                        continue;
                    }
                    if rb == 2 || toks.len() <= rb + 1 || toks[rb + 1] != Tok::Assign {
                        return Err(format!("line {}: expected `name[idx] := expr`", n));
                    }
                    let idx = parse_expr_tokens(toks[2..rb].to_vec(), n)?;
                    let e = parse_expr_tokens(toks[rb + 2..].to_vec(), n)?;
                    out.push(Stmt::ArrSet(n, id, idx, e));
                    *i += 1;
                    continue;
                }
                if (is_builtin(&id, "aadd") || is_builtin(&id, "asize")) && toks.len() >= 5 && toks[1] == Tok::LParen && toks[toks.len() - 1] == Tok::RParen {
                    // AAdd(a, x) / ASize(a, n) as a STATEMENT: in-place
                    // mutation of the named local (Harbour writes these as
                    // calls; the statement form is the PoC surface - probe
                    // e5's return value is out of scope, registered).
                    let inner = &toks[2..toks.len() - 1];
                    let comma = match inner.iter().position(|t| *t == Tok::Comma) {
                        Some(p) => p,
                        None => return Err(format!("line {}: `{}` takes two arguments", n, id)),
                    };
                    let head = &inner[..comma];
                    let e = parse_expr_tokens(inner[comma + 1..].to_vec(), n)?;
                    match head {
                        [Tok::Ident(v)] => {
                            check_ident(v, n)?;
                            if is_builtin(&id, "aadd") {
                                out.push(Stmt::AAdd(n, v.clone(), e));
                            } else {
                                out.push(Stmt::ASize(n, v.clone(), e));
                            }
                        }
                        [Tok::Ident(v), Tok::LBracket, rest @ .., Tok::RBracket] if !rest.is_empty() => {
                            check_ident(v, n)?;
                            let idx = parse_expr_tokens(rest.to_vec(), n)?;
                            if is_builtin(&id, "aadd") {
                                out.push(Stmt::AAddSub(n, v.clone(), idx, e));
                            } else {
                                out.push(Stmt::ASizeSub(n, v.clone(), idx, e));
                            }
                        }
                        _ => return Err(format!("line {}: the first argument of `{}` must be a variable or a[i]", n, id)),
                    }
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
        let mut f = Func { name, params, ret: None, stmts: Vec::new(), dyn_names: std::collections::HashSet::new() };
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
        fn tname(t: Ty) -> &'static str {
            match t {
                Ty::I64 => "an integer",
                Ty::Str => "a string",
                Ty::Dyn => "a NIL-capable value",
                _ => "a value of another type",
            }
        }
        match pin[idx] {
            None => { pin[idx] = Some(ty); Ok(()) }
            Some(t) if t == ty => Ok(()),
            // A parameter used numerically in one place and as NIL in
            // another pins to the tagged union (probe n2: x := NIL / x := 9).
            Some(t) if matches!((t, ty), (Ty::I64, Ty::Dyn) | (Ty::Dyn, Ty::I64)) => {
                pin[idx] = Some(Ty::Dyn);
                Ok(())
            }
            Some(t) => Err(format!("line {}: parameter used as both {} and {}", n, tname(t), tname(ty))),
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
            Expr::Index2(id, ie, ie2) => {
                if is_param(f, id).is_some() {
                    return Err(format!("line {}: arrays of arrays cannot be function parameters in this increment", n));
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)
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
                    Expr::Nil => Some(Ty::Dyn),
                    Expr::Var(v) => lit.iter().find(|(x, _)| x == v).map(|(_, t)| *t),
                    _ => None,
                };
                let tb = match b.as_ref() {
                    Expr::Str(_) => Some(Ty::Str),
                    Expr::Int(_) => Some(Ty::I64),
                    Expr::Nil => Some(Ty::Dyn),
                    Expr::Var(v) => lit.iter().find(|(x, _)| x == v).map(|(_, t)| *t),
                    _ => None,
                };
                if let Some(t) = ta { pin_vars(f, b, t, pin, n)?; }
                if let Some(t) = tb { pin_vars(f, a, t, pin, n)?; }
                walk(f, a, sigs, lit, pin, n)?; walk(f, b, sigs, lit, pin, n)
            }
            Expr::Call(id, args) => {
                if is_builtin(id, "hb_memcheck") {
                    return Ok(());
                }
                if is_builtin(id, "len") && !args.is_empty() {
                    match &args[0] {
                        Expr::Index(v, _) | Expr::Index2(v, _, _) if is_param(f, v).is_some() => {
                            return Err(format!("line {}: arrays of arrays cannot be function parameters in this increment", n));
                        }
                        _ => pin_vars(f, &args[0], Ty::DArr, pin, n)?,
                    }
                    return walk(f, &args[0], sigs, lit, pin, n);
                }
                if is_builtin(id, "eval") {
                    for a in args { walk(f, a, sigs, lit, pin, n)?; }
                    return Ok(());
                }
                if is_builtin(id, "array") {
                    // Array(n[, m]) dimensions are integers (oracles
                    // m3/m10); a parameter used as a dimension pins I64.
                    for a in args { pin_vars(f, a, Ty::I64, pin, n)?; walk(f, a, sigs, lit, pin, n)?; }
                    return Ok(());
                }
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
                    // Indexing a parameter pins it to a DYNAMIC array
                    // (fixed arrays cannot be parameters in this increment).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, n)
            }
            Expr::Index2(id, ie, ie2) => {
                if is_param(f, id).is_some() {
                    return Err(format!("line {}: arrays of arrays cannot be function parameters in this increment", n));
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, n)?;
                walk(f, ie2, sigs, lit, pin, n)
            }
            Expr::DArrNew => Ok(()),
            _ => Ok(()),
        }
    }
    fn walk_stmts(f: &Func, stmts: &[Stmt], sigs: &[Sig], lit: &mut Vec<(String, Ty)>, pin: &mut Vec<Option<Ty>>, nil_ret: bool) -> Result<(), String> {
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
                Stmt::Assign(n, id, e) => {
                    // `x := NIL` pins a parameter to the tagged union.
                    if matches!(e, Expr::Nil) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::Dyn, pin, *n)?;
                    }
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::Print(n, es) => { for e in es { walk(f, e, sigs, lit, pin, *n)?; } }
                Stmt::Ret(n, Some(e)) => {
                    // Mixed return (a value here, bare `return` / `return
                    // nil` elsewhere): the value is tagged, so a returned
                    // parameter pins Dyn (probe n2).
                    if nil_ret { pin_vars(f, e, Ty::Dyn, pin, *n)?; }
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::Ret(_, None) => {}
                Stmt::If(n, c, a, b) => {
                    walk(f, c, sigs, lit, pin, *n)?;
                    walk_stmts(f, a, sigs, lit, pin, nil_ret)?;
                    walk_stmts(f, b, sigs, lit, pin, nil_ret)?;
                }
                Stmt::While(n, c, body) => {
                    walk(f, c, sigs, lit, pin, *n)?;
                    walk_stmts(f, body, sigs, lit, pin, nil_ret)?;
                }
                Stmt::For(n, _, a, b, _, body) => {
                    // for bounds are i64 by construction (integer counters
                    // only): they pin a parameter used as a bound (t61).
                    pin_vars(f, a, Ty::I64, pin, *n)?;
                    pin_vars(f, b, Ty::I64, pin, *n)?;
                    walk(f, a, sigs, lit, pin, *n)?; walk(f, b, sigs, lit, pin, *n)?;
                    walk_stmts(f, body, sigs, lit, pin, nil_ret)?;
                }
                Stmt::ArrSet(n, _, ie, e) => {
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::AAdd(n, id, e) => {
                    // AAdd's target is a dynamic array: pins a parameter.
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::ASize(n, id, e) => {
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::AAddSub(n, id, ie, e) | Stmt::ASizeSub(n, id, ie, e) => {
                    if is_param(f, id).is_some() {
                        return Err(format!("line {}: arrays of arrays cannot be function parameters in this increment", n));
                    }
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::ArrSet2(n, id, ie, ie2, e) => {
                    if is_param(f, id).is_some() {
                        return Err(format!("line {}: arrays of arrays cannot be function parameters in this increment", n));
                    }
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, ie2, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, *n)?;
                    walk(f, ie2, sigs, lit, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::Exit(_) | Stmt::Loop(_) => {}
            }
        }
        Ok(())
    }
    fn any_nil_ret(stmts: &[Stmt]) -> bool {
        stmts.iter().any(|s| match s {
            Stmt::Ret(_, None) => true,
            Stmt::If(_, _, a, b) => any_nil_ret(a) || any_nil_ret(b),
            Stmt::While(_, _, b) | Stmt::For(_, _, _, _, _, b) => any_nil_ret(b),
            _ => false,
        })
    }
    let nil_ret = any_nil_ret(&f.stmts);
    walk_stmts(f, &f.stmts, sigs, &mut lit, &mut pin, nil_ret)?;
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
                "line {}: use of moved value `{}` (heap values - strings and dynamic arrays - move on assignment, call or return; they do not copy)", n, id)),
            Some(v) => Ok(v.ty),
        },
        Expr::Call(id, args) => {
            if is_builtin(id, "hb_memcheck") {
                // alloc/free balance counters (test harness only).
                if !args.is_empty() {
                    return Err(format!("line {}: `hb_memcheck` takes no arguments", n));
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "array") {
                // Array(n[, m]) constructor (oracles m3/m10/a0/avar).
                // Harbour accepts more dimensions and answers Array() /
                // Array(-1) with dialogs that hang headless (BASE/1111,
                // BASE/1131): arity errors are compile errors here and a
                // negative dimension is a clean runtime error - registered
                // failure modes, same error conditions.
                if args.is_empty() {
                    return Err(format!("line {}: `Array` needs at least one dimension", n));
                }
                if args.len() > 2 {
                    return Err(format!("line {}: `Array` with more than two dimensions is not in this increment", n));
                }
                for a in args {
                    if !matches!(type_expr(a, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                        return Err(format!("line {}: `Array` dimensions are integers", n));
                    }
                }
                return Ok(if args.len() == 1 { Ty::DArr } else { Ty::DArr2 });
            }
            if is_builtin(id, "len") {
                // len(a): number of elements of an array (probe e4:
                // len({}) == 0). Borrows its argument.
                if args.len() != 1 {
                    return Err(format!("line {}: `len` takes one argument", n));
                }
                match &args[0] {
                    Expr::Index(id, ie) => {
                        // len(a[i]): the subarray length, a borrow (probe m6).
                        if type_expr(ie, env, sigs, n)? != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        return match env.iter().find(|v| v.name == *id) {
                            Some(v) if v.ty == Ty::DArr2 && !v.moved => Ok(Ty::I64),
                            Some(v) if v.ty == Ty::DArr2 => Err(format!("line {}: use of moved value `{}`", n, id)),
                            _ => Err(format!("line {}: `len` of a[i] needs an array of arrays", n)),
                        };
                    }
                    _ => {}
                }
                return match type_expr(&args[0], env, sigs, n)? {
                    Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Arr(_) | Ty::Hash => Ok(Ty::I64),
                    _ => return Err(format!("line {}: `len` expects an array", n)),
                };
            }
            if is_builtin(id, "eval") {
                // eval(b, a1..an): b is a codeblock value. Extra arguments
                // are evaluated and IGNORED, as Harbour does (probes c7 and
                // c7b: side effects run, the result ignores them); fewer
                // arguments than parameters are a COMPILE error here
                // (Harbour fails at runtime with an interactive dialog -
                // probe c8). Arguments are integers in this increment.
                if args.is_empty() {
                    return Err(format!("line {}: `eval` needs a codeblock as its first argument", n));
                }
                let t0 = type_expr(&args[0], env, sigs, n)?;
                let k = match t0 {
                    Ty::Block(k) => k,
                    _ => return Err(format!("line {}: `eval` expects a codeblock as its first argument", n)),
                };
                if args.len() - 1 < k {
                    return Err(format!("line {}: codeblock takes {} argument(s), `eval` got {}", n, k, args.len() - 1));
                }
                for a in &args[1..] {
                    if type_expr(a, env, sigs, n)? != Ty::I64 {
                        return Err(format!("line {}: codeblock arguments must be integers in this increment", n));
                    }
                }
                return Ok(Ty::I64);
            }
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
                if ta == Ty::DArr2 {
                    return Err(format!("line {}: arrays of arrays cannot be function parameters in this increment", n));
                }
                if ta == Ty::DArrU {
                    return Err(format!("line {}: the element type of the argument is unknown until its first `AAdd` (pin it first)", n));
                }
                if ta == Ty::Hash {
                    return Err(format!("line {}: hashes cannot be function parameters in this increment", n));
                }
                // A string argument moves out of its variable right away, so
                // a second use later in the same expression (e.g. the other
                // side of a `+`) is rejected like any other use-after-move.
                if ta == Ty::Str {
                    if let Expr::Var(v) = a {
                        if let Some(x) = env.iter_mut().find(|x| x.name == *v && x.ty == Ty::Str) { x.moved = true; }
                    }
                }
                let ok = ta == sig.params[i]
                    || (ta == Ty::Dyn && sig.params[i] == Ty::I64)  // runtime extract (nil -> clean type error)
                    || (ta == Ty::I64 && sig.params[i] == Ty::Dyn); // tagged at the call
                if !ok {
                    return Err(format!("line {}: argument {} of `{}` must be {}, got {}",
                        n, i + 1, id,
                        ty_name(sig.params[i]), ty_name(ta)));
                }
            }
            match sig.ret {
                Some(t) => Ok(t),
                None => Err(format!("line {}: `{}` never returns a value; its result cannot be used in an expression in this PoC", n, id)),
            }
        }
        Expr::Bin(_, a, b) => {
            let ta = type_expr(a, env, sigs, n)?;
            let tb = type_expr(b, env, sigs, n)?;
            // Dyn operands are extracted at runtime: a NIL payload is a
            // clean type error (Harbour's interactive dialog is the
            // registered failure-mode difference, same condition).
            if !matches!(ta, Ty::I64 | Ty::Dyn) || !matches!(tb, Ty::I64 | Ty::Dyn) {
                return Err(format!("line {}: arithmetic requires integers", n));
            }
            Ok(Ty::I64)
        }
        Expr::Nil => Ok(Ty::Dyn),
        Expr::Cmp(op, a, b) => {
            let ta = type_expr(a, env, sigs, n)?;
            let tb = type_expr(b, env, sigs, n)?;
            // NIL against a string: Harbour answers .F. for `=` (probe n1:
            // "" == NIL is .F., no error). Only `=` / `#` are accepted;
            // ordering NIL is a Harbour runtime error (no headless oracle).
            // Ordering a NIL literal is a Harbour type error (no headless
            // oracle): reject it at compile time. A NIL held in a variable
            // still compares numerically - the documented sentinel cost.
            if (matches!(**a, Expr::Nil) || matches!(**b, Expr::Nil)) && !matches!(op, CmpOp::Eq | CmpOp::Ne) {
                return Err(format!("line {}: NIL only compares with `=` or `#` in this PoC (Harbour raises a type error on ordering NIL)", n));
            }
            let nil_str = (matches!(**a, Expr::Nil) && tb == Ty::Str) || (matches!(**b, Expr::Nil) && ta == Ty::Str);
            if nil_str {
                return Ok(Ty::Bool);
            }
            if let Ty::Arr(_) = ta {
                return Err(format!("line {}: arrays do not compare in this increment", n));
            }
            if let Ty::Arr(_) = tb {
                return Err(format!("line {}: arrays do not compare in this increment", n));
            }
            if let Ty::Block(_) = ta {
                return Err(format!("line {}: codeblocks do not compare in this increment", n));
            }
            if ta == Ty::DArr || tb == Ty::DArr {
                return Err(format!("line {}: dynamic arrays do not compare in this increment", n));
            }
            if let Ty::Block(_) = tb {
                return Err(format!("line {}: codeblocks do not compare in this increment", n));
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
            // Dyn against a number: tag dispatch at runtime (nil = nil is
            // .T., nil against a payload is .F. under `=`, payloads compare).
            if matches!(ta, Ty::Dyn | Ty::I64) && matches!(tb, Ty::Dyn | Ty::I64) {
                return Ok(Ty::Bool);
            }
            // Dyn against a string: `=` is always .F. in Harbour (probe n1:
            // "" = NIL is .F.), `#` always .T.; ordering is a Harbour type
            // error, rejected here at compile time.
            if (ta == Ty::Dyn && tb == Ty::Str) || (ta == Ty::Str && tb == Ty::Dyn) {
                return match op {
                    CmpOp::Eq | CmpOp::Ne => Ok(Ty::Bool),
                    _ => Err(format!("line {}: cannot order a string against a number in this PoC (Harbour raises a type error)", n)),
                };
            }
            if ta != tb {
                return Err(format!("line {}: cannot compare a string with an integer in this PoC", n));
            }
            Err(format!("line {}: comparisons require integers", n))
        }
        Expr::ArrLit(es) => {
            let nested = es.iter().any(|e| matches!(e, Expr::ArrLit(_) | Expr::DArrNew));
            if nested {
                // {{1,2},{3,4}}: a DArr2 - dynamic array of dynamic arrays
                // of i64 (probe m1). Two levels in this increment.
                for e in es {
                    match e {
                        Expr::ArrLit(inner) => {
                            for ie in inner {
                                if !matches!(type_expr(ie, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                                    return Err(format!("line {}: nested array elements are tagged scalars (integer or NIL)", n));
                                }
                            }
                        }
                        Expr::DArrNew => {}
                        _ => return Err(format!("line {}: array elements cannot mix integers and arrays in this increment", n)),
                    }
                }
                return Ok(Ty::DArr2);
            }
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
            let it = type_expr(ie, env, sigs, n)?;
            match env.iter().find(|v| v.name == *id) {
                Some(v) if v.ty == Ty::Hash => {
                    // h["k"]: string keys (probes h3b case-sensitive, h12
                    // prefix-distinct); a read borrows and yields the
                    // stored Dyn scalar.
                    if v.moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                    if it != Ty::Str {
                        return Err(format!("line {}: hash keys are strings in this increment", n));
                    }
                    Ok(Ty::Dyn)
                }
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                _ => {
            if it != Ty::I64 && it != Ty::Dyn {
                return Err(format!("line {}: array index must be an integer", n));
            }
            match env.iter().find(|v| v.name == *id) {
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                Some(v) if v.ty == Ty::DArr => {
                    if v.moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                    // Elements are {tag, payload}: a read is a Dyn value
                    // (probes n1/n2: a grown or NIL-stored slot reads NIL).
                    Ok(Ty::Dyn)
                }
                Some(v) if v.ty == Ty::DArrU => {
                    Err(format!("line {}: the element type of `{}` is unknown until its first `AAdd` (pin it first)", n, id))
                }
                Some(v) if v.ty == Ty::DArr2 => {
                    // a[i] on an array of arrays would EXTRACT the child by
                    // value: rejected in this increment (indexed borrows
                    // only: a[i][j], len(a[i]), AAdd/ASize(a[i], ...)).
                    Err(format!("line {}: cannot extract the subarray `{}[i]` by value in this increment (use a[i][j], len(a[i]) or AAdd/ASize on a[i])", n, id))
                }
                Some(v) => match v.ty {
                    Ty::Arr(k) => {
                        if it != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
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
        Expr::Index2(id, ie, ie2) => {
            // a[i][j]: a transient indexed BORROW of the subarray (probe
            // m1). Both indices are integers; the child is never moved out.
            if !matches!(type_expr(ie, env, sigs, n)?, Ty::I64 | Ty::Dyn)
                || !matches!(type_expr(ie2, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                return Err(format!("line {}: array indices must be integers", n));
            }
            match env.iter().find(|v| v.name == *id) {
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                Some(v) if v.moved => Err(format!("line {}: use of moved value `{}`", n, id)),
                Some(v) if v.ty == Ty::DArr2 => Ok(Ty::Dyn),
                Some(v) if v.ty == Ty::DArrU => Err(format!("line {}: the element type of `{}` is unknown until its first `AAdd` (pin it first)", n, id)),
                Some(_) => Err(format!("line {}: two-level indexing needs an array of arrays; `{}` is not one", n, id)),
            }
        }
        Expr::BlockLit(_, params, body) => {
            // v1: no captures - the body sees ONLY its parameters (probe
            // c3 captures a function local in Harbour; that is the next
            // increment, not this one). Parameters are integers here.
            for e in body {
                let mut found = Vec::new();
                free_vars(e, &mut found);
                for v in found {
                    if !params.iter().any(|p| *p == v) {
                        return Err(format!("line {}: codeblock captures are not in this increment (`{}` is not a codeblock parameter)", n, v));
                    }
                }
            }
            let mut benv: Vec<Local> = params.iter().map(|p| Local { name: p.clone(), ty: Ty::I64, moved: false, ro: false }).collect();
            for e in body {
                if type_expr(e, &mut benv, sigs, n)? != Ty::I64 {
                    return Err(format!("line {}: codeblock bodies are integer expressions in this increment", n));
                }
            }
            Ok(Ty::Block(params.len()))
        }
        Expr::DArrNew => Ok(Ty::DArrU),
        // Hash literal (probes h1/h2/h8/h9): string keys, tagged-scalar
        // values in v1. Duplicate keys in one literal overwrite in place
        // (h8: len stays 1, last value wins); each pair evaluates its key
        // first, then its value (h9) - the opposite of `h[k] := v` (h4).
        Expr::HashLit(ps) => {
            for (k, v) in ps {
                if type_expr(k, env, sigs, n)? != Ty::Str {
                    return Err(format!("line {}: hash keys are strings in this increment", n));
                }
                let vt = type_expr(v, env, sigs, n)?;
                if !matches!(vt, Ty::I64 | Ty::Dyn) {
                    return Err(format!("line {}: hash values are tagged scalars (integer or NIL) in this increment", n));
                }
            }
            Ok(Ty::Hash)
        }
    }
}

// Free VARIABLE names used inside an expression (callees are not variables).
fn ty_name(t: Ty) -> &'static str {
    match t {
        Ty::I64 => "an integer",
        Ty::Str => "a string",
        Ty::Bool => "a boolean",
        Ty::DArrU | Ty::DArr2 => "a dynamic array",
        Ty::Arr(_) => "an array",
        Ty::Block(_) => "a codeblock",
        Ty::DArr => "a dynamic array",
        Ty::Dyn => "a dynamic value",
        Ty::Hash => "a hash",
    }
}

fn free_vars(e: &Expr, out: &mut Vec<String>) {
    match e {
        Expr::Var(id) => { if !out.iter().any(|x| x == id) { out.push(id.clone()); } }
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => { free_vars(a, out); free_vars(b, out); }
        Expr::Call(_, args) => { for a in args { free_vars(a, out); } }
        Expr::ArrLit(es) => { for e in es { free_vars(e, out); } }
        Expr::Index(_, ie) => free_vars(ie, out),
        Expr::Index2(_, ie, ie2) => { free_vars(ie, out); free_vars(ie2, out); }
        Expr::HashLit(ps) => { for (k, v) in ps { free_vars(k, out); free_vars(v, out); } }
        Expr::BlockLit(_, _, _) => {} // nested blocks: rejected by the integer-body rule
        _ => {}
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
// Does this statement list contain a `return <expr>` anywhere (nested
// blocks included)? Used to keep main value-free: main's own `return nil`
// returns NIL like any function (probe n1c) but must not yield a value.
fn has_value_return(stmts: &[Stmt]) -> bool {
    stmts.iter().any(|s| match s {
        Stmt::Ret(_, Some(_)) => true,
        Stmt::If(_, _, t, e) => has_value_return(t) || has_value_return(e),
        Stmt::While(_, _, b) => has_value_return(b),
        Stmt::For(_, _, _, _, _, b) => has_value_return(b),
        _ => false,
    })
}

// Pre-scan: which locals can ever hold a Dyn (NIL-capable) value? Seeds:
// a NIL literal, a dynamic-array element read, or a call to a Dyn-returning
// function on the RHS of any local/assign; propagation through plain Var
// copies to a fixpoint (probe n2: a variable is re-tagged live, so the
// width must be known before the frame is laid out). Params pinned Dyn by
// the pin pass seed the set too. Only I64 declarations widen; strings,
// arrays and codeblocks never change type.
fn prescan_dyn(f: &Func, sigs: &[Sig], ptys: &[Ty]) -> std::collections::HashSet<String> {
    use std::collections::HashSet;
    let mut dyn_names: HashSet<String> = HashSet::new();
    let mut darr_names: HashSet<String> = HashSet::new();
    for (i, p) in f.params.iter().enumerate() {
        if ptys[i] == Ty::Dyn { dyn_names.insert(p.clone()); }
        if matches!(ptys[i], Ty::DArr | Ty::DArrU | Ty::DArr2) { darr_names.insert(p.clone()); }
    }
    // dynamic arrays declared in the body ({} or a nested literal)
    fn scan_darr(stmts: &[Stmt], darr: &mut HashSet<String>) {
        for st in stmts {
            match st {
                Stmt::Local(_, id, Expr::DArrNew) => { darr.insert(id.clone()); }
                Stmt::Local(_, id, Expr::ArrLit(es)) if es.iter().any(|e| matches!(e, Expr::ArrLit(_) | Expr::DArrNew)) => { darr.insert(id.clone()); }
                Stmt::If(_, _, t, e) => { scan_darr(t, darr); scan_darr(e, darr); }
                Stmt::While(_, _, b) => scan_darr(b, darr),
                Stmt::For(_, _, _, _, _, b) => scan_darr(b, darr),
                _ => {}
            }
        }
    }
    scan_darr(&f.stmts, &mut darr_names);
    // assignments/local inits as (name, expr) pairs, flattened
    fn collect<'a>(stmts: &'a [Stmt], out: &mut Vec<(&'a String, &'a Expr)>) {
        for st in stmts {
            match st {
                Stmt::Local(_, id, e) | Stmt::Assign(_, id, e) => out.push((id, e)),
                Stmt::If(_, _, t, e) => { collect(t, out); collect(e, out); }
                Stmt::While(_, _, b) => collect(b, out),
                Stmt::For(_, _, _, _, _, b) => collect(b, out),
                _ => {}
            }
        }
    }
    let mut pairs: Vec<(&String, &Expr)> = Vec::new();
    collect(&f.stmts, &mut pairs);
    let may_be_dyn = |e: &Expr, dyn_names: &HashSet<String>, darr: &HashSet<String>| -> bool {
        match e {
            Expr::Nil => true,
            Expr::Index(id, _) | Expr::Index2(id, _, _) => darr.contains(id),
            Expr::Var(v) => dyn_names.contains(v),
            Expr::Call(id, _) if !is_builtin(id, "len") && !is_builtin(id, "eval") && !is_builtin(id, "hb_memcheck") => {
                sigs.iter().find(|s| s.name == *id).map(|s| s.ret == Some(Ty::Dyn)).unwrap_or(false)
            }
            _ => false,
        }
    };
    loop {
        let before = dyn_names.len();
        for (name, e) in &pairs {
            if may_be_dyn(e, &dyn_names, &darr_names) {
                dyn_names.insert((*name).clone());
            }
        }
        if dyn_names.len() == before { break; }
    }
    dyn_names
}

// Return-type unification (probe n2): an i64 return and a NIL return in
// the same function unify to Dyn ({tag,payload}); Harbour's mixed returns
// are supported, not registered as a static-model difference.
fn unify_ret(ret: Option<Ty>, t: Ty, n: usize) -> Result<Ty, String> {
    match (ret, t) {
        (None, t) => Ok(t),
        (Some(p), t) if p == t => Ok(t),
        (Some(Ty::I64), Ty::Dyn) | (Some(Ty::Dyn), Ty::I64) => Ok(Ty::Dyn),
        (Some(p), _) => Err(format!("line {}: return type mismatch (this function already returns {:?} elsewhere; all returns must agree)", n, p)),
    }
}

fn check_stmts(stmts: &[Stmt], env: &mut Vec<Local>, sigs: &[Sig], ret: &mut Option<Ty>, loop_pre: Option<&Vec<bool>>, exits: &mut Vec<Vec<bool>>, dyn_names: &std::collections::HashSet<String>) -> Result<bool, String> {
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
                let t = if t == Ty::I64 && dyn_names.contains(id) { Ty::Dyn } else { t };
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
                    if let Ty::Block(_) = t {
                        return Err(format!("line {}: cannot print a codeblock in this increment", n));
                    }
                    if t == Ty::DArr || t == Ty::DArrU || t == Ty::DArr2 {
                        return Err(format!("line {}: cannot print a dynamic array directly in this increment (print an element or `len(a)`)", n));
                    }
                    if t == Ty::Hash {
                        return Err(format!("line {}: cannot print a hash directly in this increment (print an element or `len(h)`)", n));
                    }
                }
            }
            Stmt::Ret(n, Some(e)) => {
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::Hash {
                    return Err(format!("line {}: hashes cannot be returned in this increment", n));
                }
                if t == Ty::Bool {
                    return Err(format!("line {}: cannot return a boolean in this PoC", n));
                }
                if let Ty::Arr(_) = t {
                    return Err(format!("line {}: arrays cannot be returned in this increment", n));
                }
                if let Ty::Block(_) = t {
                    return Err(format!("line {}: codeblocks cannot be returned in this increment", n));
                }
                if t == Ty::DArr2 {
                    return Err(format!("line {}: arrays of arrays cannot be returned in this increment", n));
                }
                if t == Ty::DArrU {
                    return Err(format!("line {}: cannot return an empty array whose element type was never pinned by `AAdd`", n));
                }
                apply_moves(e, env, sigs, true);
                *ret = Some(unify_ret(*ret, t, *n)?);
                falls = false;
            }
            Stmt::Ret(n, None) => {
                // `return` / `return nil` return NIL (probe n1c): the Dyn
                // value {tag=1}. Mixed `return 5` / `return nil` unifies to
                // a Dyn return (probe n2) - Harbour behaviour, not a
                // registered difference.
                *ret = Some(unify_ret(*ret, Ty::Dyn, *n)?);
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
                let ft = check_stmts(then_s, &mut env_then, sigs, ret, loop_pre, exits, dyn_names)?;
                let mut env_else = env.clone();
                let fe = check_stmts(else_s, &mut env_else, sigs, ret, loop_pre, exits, dyn_names)?;
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
                let fb = check_stmts(body, &mut env_body, sigs, ret, Some(&pre), &mut wexits, dyn_names)?;
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
                    // Element-type pinning is monotonic: an AAdd inside the
                    // body pins the outer variable for every later use too
                    // (the body ran at least... may run zero times - but a
                    // pin only NARROWS the unknown element type, so joining
                    // it forward is sound: unpinned loops still reject at
                    // the use site if the body never pins).
                    if env[k].ty == Ty::DArrU && matches!(env_body[k].ty, Ty::DArr | Ty::DArr2) {
                        env[k].ty = env_body[k].ty;
                    }
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
                let fb = check_stmts(body, &mut env_body, sigs, ret, Some(&pre), &mut fexits, dyn_names)?;
                if fb {
                    for k in 0..outer {
                        if !pre[k] && env_body[k].moved {
                            return Err(format!("line {}: `{}` is moved inside the `for` body and not reassigned before `next` (the next iteration would use a moved value)", n, env[k].name));
                        }
                    }
                }
                for k in 0..outer {
                    env[k].moved = pre[k] || (fb && env_body[k].moved) || fexits.iter().any(|xs| xs[k]);
                    if env[k].ty == Ty::DArrU && matches!(env_body[k].ty, Ty::DArr | Ty::DArr2) {
                        env[k].ty = env_body[k].ty;
                    }
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
            Stmt::AAdd(n, id, e) => {
                // AAdd(a, x): borrows `a` MUTABLY (grows in place, may
                // realloc); does NOT move or null it. The FIRST AAdd pins
                // the element type of an unpinned `{}`: an integer pins a
                // flat array, a dynamic array pins an array of arrays and
                // MOVES the element in (the parent owns it; probe m5's
                // shared-reference behaviour is a registered MODEL
                // divergence).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if !matches!(env[kp].ty, Ty::DArr | Ty::DArrU | Ty::DArr2) {
                    return Err(format!("line {}: `AAdd` applies to dynamic arrays (`{{}}`); `{}` is not one", n, id));
                }
                let t = type_expr(e, env, sigs, *n)?;
                let moves = match env[kp].ty {
                    Ty::DArrU => {
                        match t {
                            Ty::I64 | Ty::Dyn => { env[kp].ty = Ty::DArr; false }
                            Ty::DArr | Ty::DArrU => { env[kp].ty = Ty::DArr2; true }
                            _ => return Err(format!("line {}: `AAdd` grows with integer or dynamic-array elements in this increment", n)),
                        }
                    }
                    Ty::DArr => {
                        // Elements are tagged values: an i64 or a Dyn (NIL
                        // included) both store with their tag.
                        if !matches!(t, Ty::I64 | Ty::Dyn) {
                            return Err(format!("line {}: the elements of `{}` are tagged scalars (integer or NIL)", n, id));
                        }
                        false
                    }
                    Ty::DArr2 => {
                        if t != Ty::DArr {
                            return Err(format!("line {}: the elements of `{}` are dynamic arrays", n, id));
                        }
                        true
                    }
                    _ => unreachable!(),
                };
                if moves {
                    if let Expr::Var(v) = e {
                        if v == id {
                            return Err(format!("line {}: cannot insert `{}` into itself", n, id));
                        }
                    }
                    apply_moves(e, env, sigs, true);
                    if env[kp].moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                } else {
                    apply_moves(e, env, sigs, false);
                    if env[kp].moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                }
            }
            Stmt::AAddSub(n, id, ie, e) => {
                // AAdd(a[i], x): grows the SUBARRAY a[i] in place (probe
                // m5). Runtime order: the target index first, then the
                // value (probe m7). The parent must not move inside either.
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].ty != Ty::DArr2 {
                    return Err(format!("line {}: `AAdd` on a[i] needs an array of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array index must be an integer", n));
                }
                apply_moves(ie, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: nested array elements must be integers in this increment", n));
                }
                apply_moves(e, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::ASize(n, id, e) => {
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                match env[kp].ty {
                    // DArr2 shrink frees the removed children recursively
                    // (they are owned by the parent); grow zero-fills, so
                    // fresh children are the empty (null, 0) array.
                    Ty::DArr | Ty::DArr2 => {}
                    Ty::DArrU => return Err(format!("line {}: the element type of `{}` is unknown until its first `AAdd` (pin it first)", n, id)),
                    _ => return Err(format!("line {}: `ASize` applies to dynamic arrays (`{{}}`); `{}` is not one", n, id)),
                }
                let t = type_expr(e, env, sigs, *n)?;
                if t != Ty::I64 {
                    return Err(format!("line {}: `ASize` takes an integer size", n));
                }
                apply_moves(e, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::ASizeSub(n, id, ie, e) => {
                // ASize(a[i], n): resize the subarray in place. Runtime
                // order: the target index first, then the size (probe m7).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].ty != Ty::DArr2 {
                    return Err(format!("line {}: `ASize` on a[i] needs an array of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array index must be an integer", n));
                }
                apply_moves(ie, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: `ASize` takes an integer size", n));
                }
                apply_moves(e, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::ArrSet(n, id, ie, e) => {
                // Value first, then the index: the runtime order (probe
                // adv2, shared by Harbour and Rust) decides which of two
                // consuming expressions is the use-after-move.
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ro {
                    return Err(format!("line {}: cannot assign through the `for` loop variable `{}`", n, id));
                }
                let root_ty = env[kp].ty;
                match root_ty {
                    Ty::Hash => {
                        if env[kp].moved {
                            return Err(format!("line {}: use of moved value `{}`", n, id));
                        }
                        // Value first, then the key (probe h4).
                        let vt = type_expr(e, env, sigs, *n)?;
                        if !matches!(vt, Ty::I64 | Ty::Dyn) {
                            return Err(format!("line {}: hash values are tagged scalars (integer or NIL) in this increment", n));
                        }
                        if type_expr(ie, env, sigs, *n)? != Ty::Str {
                            return Err(format!("line {}: hash keys are strings in this increment", n));
                        }
                        apply_moves(e, env, sigs, true);
                        apply_moves(ie, env, sigs, false);
                    }
                    Ty::DArr => {
                        let vt = type_expr(e, env, sigs, *n)?;
                        if !matches!(vt, Ty::I64 | Ty::Dyn) {
                            return Err(format!("line {}: dynamic-array elements are tagged scalars (integer or NIL)", n));
                        }
                        if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        apply_moves(e, env, sigs, true);
                        apply_moves(ie, env, sigs, false);
                    }
                    Ty::Arr(_) => {
                        if type_expr(e, env, sigs, *n)? != Ty::I64 {
                            return Err(format!("line {}: array elements must be integers in this increment", n));
                        }
                        if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        apply_moves(e, env, sigs, true);
                        apply_moves(ie, env, sigs, false);
                    }
                    Ty::DArr2 => {
                        // Child overwrite: the RHS is a dynamic array and
                        // MOVES in; the old child is freed once, AFTER the
                        // new value exists (parent rule).
                        let t = type_expr(e, env, sigs, *n)?;
                        if !matches!(t, Ty::DArr | Ty::DArrU) {
                            return Err(format!("line {}: the elements of `{}` are dynamic arrays; assign one (or `{{}}`)", n, id));
                        }
                        if let Expr::Var(v) = e {
                            if v == id {
                                return Err(format!("line {}: cannot assign `{}` into its own element", n, id));
                            }
                        }
                        if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        apply_moves(e, env, sigs, true);
                        apply_moves(ie, env, sigs, false);
                    }
                    Ty::DArrU => {
                        return Err(format!("line {}: the element type of `{}` is unknown until its first `AAdd` (pin it first)", n, id));
                    }
                    _ => return Err(format!("line {}: indexed assignment applies to arrays; `{}` is not an array", n, id)),
                }
                // The parent must not move while the indexed borrow exists
                // (e.g. a[give(a)] := 1 moves `a` inside the index).
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if let Ty::Arr(k) = root_ty {
                    if let Expr::Int(lit) = ie {
                        let bad = lit.parse::<i64>().map(|x| x < 1 || x > k as i64).unwrap_or(true);
                        if bad {
                            return Err(format!("line {}: array index {} out of bounds (`{}` has {} element(s), base 1)", n, lit, id, k));
                        }
                    }
                }
            }
            Stmt::ArrSet2(n, id, ie, ie2, e) => {
                // a[i][j] := v: value first, then outer index, then inner
                // index (probe m7). Transient indexed borrows only; the
                // parent must not move while any borrow exists.
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ro {
                    return Err(format!("line {}: cannot assign through the `for` loop variable `{}`", n, id));
                }
                if env[kp].ty != Ty::DArr2 {
                    return Err(format!("line {}: two-level assignment needs an array of arrays; `{}` is not one", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: nested array elements must be integers in this increment", n));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(e, env, sigs, true);
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
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
                if env[idx].ty == Ty::DArrU && matches!(t, Ty::DArr | Ty::DArr2) {
                    // Assigning a pinned dynamic array pins the empty `{}`.
                    env[idx].ty = t;
                } else if env[idx].ty == Ty::Dyn && matches!(t, Ty::I64 | Ty::Dyn) {
                    // Dyn slot: an i64 is tagged in, a Dyn is copied (probe
                    // n2: reassignment re-tags a live variable).
                } else if env[idx].ty == Ty::I64 && t == Ty::Dyn {
                    // i64 slot receiving a Dyn: the tag is checked at
                    // runtime (NIL payload -> clean type error).
                } else if env[idx].ty != t {
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
// Mark moved-out heap vars (strings, dynamic arrays). `moving` is true where
// the position consumes the value (a local/assign/return root expression, an
// owned argument slot); a bare var in a comparison, arithmetic, index or
// len() only borrows. Call arguments move when the callee's parameter owns
// the value (string or dynamic array), like Rust String/Vec passed by value.
// i64 and codeblocks never move (Copy).
fn apply_moves(e: &Expr, env: &mut [Local], sigs: &[Sig], moving: bool) {
    match e {
        Expr::Var(id) => {
            if moving {
                if let Some(v) = env.iter_mut().find(|v| v.name == *id && matches!(v.ty, Ty::Str | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Hash)) { v.moved = true; }
            }
        }
        Expr::Bin(_, a, b) => { apply_moves(a, env, sigs, false); apply_moves(b, env, sigs, false); }
        Expr::Cmp(_, a, b) => { apply_moves(a, env, sigs, false); apply_moves(b, env, sigs, false); }
        Expr::Call(id, args) => {
            if is_builtin(id, "hb_memcheck") {
                return;
            }
            if is_builtin(id, "len") {
                apply_moves(&args[0], env, sigs, false);
                return;
            }
            if is_builtin(id, "eval") {
                // Block values are Copy pointers; arguments are integers:
                // nothing moves (checked in analysis).
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "array") {
                // Integer dimensions: borrowed, never moved.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            let sig = sigs.iter().find(|v| v.name == *id).expect("checked");
            for (i, a) in args.iter().enumerate() {
                let m = i < sig.params.len() && (sig.params[i] == Ty::Str || sig.params[i] == Ty::DArr);
                apply_moves(a, env, sigs, m);
            }
        }
        Expr::ArrLit(es) => { for e in es { apply_moves(e, env, sigs, false); } }
        Expr::Index(_, ie) => apply_moves(ie, env, sigs, false),
        Expr::Index2(_, ie, ie2) => { apply_moves(ie, env, sigs, false); apply_moves(ie2, env, sigs, false); }
        Expr::BlockLit(_, _, _) => {}
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
    match t { Ty::I64 => 8, Ty::Str => 16, Ty::Arr(n) => 8 * n, Ty::Block(_) => 8, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Dyn | Ty::Hash => 16, Ty::Bool => unreachable!("booleans rejected in analysis") }
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
        Expr::Nil => {
            // NIL: the Dyn tag/payload pair (probe n1) - rax=tag, rdx=payload
            out.push_str("    mov $1, %eax\n    xor %edx, %edx\n");
        }
        Expr::Str(_) => unreachable!("string literals are emitted via cg_str_ref"),
        Expr::Cmp(..) => unreachable!("comparisons are emitted via cg_cond_jump"),
        Expr::Var(id) => {
            let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
            match v.ty {
                Ty::I64 | Ty::Block(_) => out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off)),
                Ty::Str | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Dyn | Ty::Hash => {
                    // ptr at -(off), len at -(off-8) — same layout as the store
                    out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off));
                    out.push_str(&format!("    mov -{}(%rbp), %rdx\n", v.off - 8));
                }
                Ty::Bool => unreachable!("booleans rejected in analysis"),
                Ty::Arr(_) => unreachable!("whole-array values are emitted via cg_array_value"),
            }
        }
        Expr::Call(id, args) if is_builtin(id, "len") => {
            // len(a) for a dynamic array: the length word of the slot.
            match &args[0] {
                Expr::Var(v) => {
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    match var.ty {
                        Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Hash => out.push_str(&format!("    mov -{}(%rbp), %rax\n", var.off - 8)),
                        Ty::Arr(k) => out.push_str(&format!("    mov ${}, %rax\n", k)),
                        _ => unreachable!("checked"),
                    }
                }
                Expr::Index(v, ie) => {
                    // len(a[i]): borrow the child slot (probe m6). A null
                    // child (fresh ASize growth) reads length 0.
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str(&format!("    cmp $1, %rax\n    jl 87f\n    cmp -{}(%rbp), %rax\n    jg 87f\n", var.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                    out.push_str("    dec %rax\n    shl $4, %rax\n    mov 8(%r11,%rax), %rax\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                }
                _ => unreachable!("len() of a non-variable in this increment"),
            }
        }
        Expr::Call(id, args) if is_builtin(id, "array") => {
            // Array(n): Dyn-element array with n NIL slots (oracle m10).
            // Array(n, m): n children of m NILs each (oracle m3). The
            // dimensions evaluate left to right; the value comes back as
            // {ptr, len} from a temporary slot (the caller owns the move).
            if args.len() == 1 {
                cg_expr(&args[0], env, sigs, strs, out, target);
                if expr_ty(&args[0], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    movq $0, (%rsp)\n    movq $0, 8(%rsp)\n");
                out.push_str("    mov %rax, %rsi\n    mov %rsp, %rdi\n    mov $16, %edx\n    xor %ecx, %ecx\n    call hbc_asize\n");
                out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
            } else {
                cg_expr(&args[0], env, sigs, strs, out, target);
                if expr_ty(&args[0], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[1], env, sigs, strs, out, target);
                if expr_ty(&args[1], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    mov %rax, %rdx\n    mov (%rsp), %rsi\n    add $16, %rsp\n");
                out.push_str("    sub $16, %rsp\n    movq $0, (%rsp)\n    movq $0, 8(%rsp)\n");
                out.push_str("    mov %rsp, %rdi\n    call hbc_arraym\n");
                out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
            }
        }
        Expr::Call(id, _) if is_builtin(id, "hb_memcheck") => {
            // alloc/free balance counters (test harness only).
            out.push_str("    mov hbc_mem_allocs(%rip), %rax\n    sub hbc_mem_frees(%rip), %rax\n");
        }
        Expr::DArrNew => {
            // {} : the empty dynamic array is (null, 0) - no allocation
            // happens until the first AAdd (probe e4: len({}) == 0).
            out.push_str("    xor %eax, %eax\n    xor %edx, %edx\n");
        }
        Expr::HashLit(_) => unreachable!("hash literals are emitted in statement position (local/assign initializers)"),
        Expr::BlockLit(id, _, _) => {
            // The block's value is its code pointer (8 bytes, Copy).
            out.push_str(&format!("    lea hbc_blk_{}(%rip), %rax\n", id));
        }
        Expr::Call(id, args) if is_builtin(id, "eval") => {
            // eval(b, a1..an): evaluate ALL arguments left to right (extras
            // are discarded afterwards, matching probe c7b), push the first
            // k as call arguments, then call the block pointer indirectly
            // with the standard convention.
            let k = match expr_ty(&args[0], env, sigs) { Ty::Block(k) => k, _ => unreachable!("checked") };
            for a in &args[1..] {
                cg_expr(a, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
            }
            if args.len() - 1 > k {
                out.push_str(&format!("    add ${}, %rsp\n", 16 * (args.len() - 1 - k)));
            }
            cg_expr(&args[0], env, sigs, strs, out, target);
            out.push_str("    mov %rax, %r11\n    call *%r11\n");
            if k > 0 {
                out.push_str(&format!("    add ${}, %rsp\n", 16 * k));
            }
        }
        Expr::Call(id, args) => {
            let _ = sigs;
            // Arguments are evaluated and pushed LEFT TO RIGHT (Harbour
            // order; it matters if an argument expression fails, e.g. an
            // integer division by zero), each in a 16-byte slot (keeps rsp
            // 16-aligned on both targets); arg k then sits at
            // 16*(n-k)(%rbp) in the callee after its prologue.
            let psig = sigs.iter().find(|v| v.name == *id).map(|v| v.params.clone());
            for (ai, a) in args.iter().enumerate() {
                let ta = expr_ty(a, env, sigs);
                let pty = psig.as_ref().and_then(|p| p.get(ai).copied());
                cg_value(a, env, sigs, strs, out, target);
                if ta == Ty::Dyn && pty == Some(Ty::I64) {
                    // Dyn argument to an i64 parameter: extract with the
                    // runtime tag check (NIL -> clean type error).
                    out.push_str("    call hbc_dyn_to_i64\n");
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    continue;
                }
                if ta == Ty::I64 && pty == Some(Ty::Dyn) {
                    // i64 argument to a Dyn parameter: tag it in.
                    out.push_str("    sub $16, %rsp\n    movq $0, (%rsp)\n    mov %rax, 8(%rsp)\n");
                    continue;
                }
                if ta == Ty::Dyn {
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    continue;
                }
                if ta == Ty::Str || ta == Ty::DArr {
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    // An owned (moved) DArr argument: null the source slot
                    // right after the copy, so the callee is the only owner
                    // and the caller's later frees see null.
                    if let Expr::Var(src) = a {
                        if ta == Ty::DArr {
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2)) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                            }
                        }
                    }
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
            if v.ty == Ty::Hash {
                // h["k"] read: hbc_hget scans live entries (byte compare
                // with length - probes h3b/h12). A miss is a clean bound
                // error here; Harbour shows its interactive dialog and
                // hangs headless (probes h3/h3c) - registered failure-mode
                // difference, same error condition. The lookup never
                // mutates the hash.
                cg_value(ie, env, sigs, strs, out, target);
                out.push_str("    mov %rax, %rsi\n");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    call hbc_hget\n", v.off));
                out.push_str("    test %rax, %rax\n    je 81f\n    mov (%rax), %rcx\n    mov 8(%rax), %rdx\n    mov %rcx, %rax\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
                return;
            }
            if v.ty == Ty::DArr {
                // Dynamic array read: bounds are 1..=len (runtime word);
                // elements are {tag, payload} pairs (rax=tag, rdx=payload).
                // Borrow only - nothing is moved or nulled.
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str(&format!("    cmp $1, %rax\n    jl 81f\n    cmp -{}(%rbp), %rax\n    jg 81f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n    jmp 82f\n");
                out.push_str("81:\n    call hbc_bound_error\n82:\n");
                return;
            }
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
        Expr::Index2(id, ie, ie2) => {
            // a[i][j] read: two transient indexed borrows (probe m1). The
            // indices are evaluated left to right, then both bounds are
            // checked; a null child has length 0, so indexing it is a
            // clean bound error (Harbour would show its dialog instead -
            // registered DIVERGE-FAILMODE).
            let var = env.iter().rev().find(|v| v.name == *id).expect("checked");
            if expr_ty(ie, env, sigs) == Ty::Dyn {
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie, env, sigs, strs, out, target);
            }
            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
            if expr_ty(ie2, env, sigs) == Ty::Dyn {
                cg_expr(ie2, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie2, env, sigs, strs, out, target);
            }
            out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
            // rcx = i, rax = j
            out.push_str(&format!("    cmp $1, %rcx\n    jl 81f\n    cmp -{}(%rbp), %rcx\n    jg 81f\n", var.off - 8));
            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
            out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
            // r10 = child slot; bounds-check j against the child length
            out.push_str("    cmp $1, %rax\n    jl 81f\n    cmp 8(%r10), %rax\n    jg 81f\n");
            out.push_str("    mov (%r10), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
        }
        Expr::Bin(op, a, b) => {
            // Operands are i64 or Dyn (checked in analysis): a Dyn operand
            // is extracted with the runtime tag check (NIL payload -> clean
            // type error, Harbour's dialog is the registered difference).
            cg_expr(a, env, sigs, strs, out, target);
            if expr_ty(a, env, sigs) == Ty::Dyn {
                out.push_str("    call hbc_dyn_to_i64\n");
            }
            // Keep the lhs on the stack while evaluating the rhs. On Windows
            // a plain push would break 16-byte alignment for any call inside
            // the rhs (e.g. `1 + valor()`), so reserve a full 16-byte slot.
            match target {
                Target::Linux => out.push_str("    push %rax\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
            }
            cg_expr(b, env, sigs, strs, out, target);
            if expr_ty(b, env, sigs) == Ty::Dyn {
                out.push_str("    call hbc_dyn_to_i64\n");
            }
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

// Build a nested literal {{1,2},{3,4}} on the heap: outer block of child
// slots, one inner block per child. Children are built left to right and
// every element expression is evaluated exactly once, in order. Capacity
// equals the length (later AAdd growth doubles). On OOM the process aborts
// via hbc_oom; partially built children die with the process (no unwinding
// in this PoC - documented).
fn cg_darr2_literal(es: &[Expr], env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    let k = es.len();
    out.push_str("    sub $48, %rsp\n"); // (%rsp)=outer ptr, 8(%rsp)=child ptr
    out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + k * 16));
    out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", k));
    for (j, child) in es.iter().enumerate() {
        match child {
            Expr::DArrNew => {
                out.push_str(&format!("    mov (%rsp), %r11\n    movq $0, {}(%r11)\n    movq $0, {}(%r11)\n", j * 16, j * 16 + 8));
            }
            Expr::ArrLit(inner) => {
                let m = inner.len();
                out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, 8(%rsp)\n", m));
                for (p, ie) in inner.iter().enumerate() {
                    cg_expr(ie, env, sigs, strs, out, target);
                    if expr_ty(ie, env, sigs) == Ty::I64 {
                        out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                    }
                    out.push_str(&format!("    mov 8(%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p * 16, p * 16 + 8));
                }
                out.push_str(&format!("    mov (%rsp), %r11\n    mov 8(%rsp), %rax\n    mov %rax, {}(%r11)\n    movq ${}, {}(%r11)\n", j * 16, m, j * 16 + 8));
            }
            _ => unreachable!("checked"),
        }
    }
    out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $48, %rsp\n", k));
    let _ = target;
}

// Evaluate any expression whose value might be a Str: string literals need a
// .rodata slot, so they are handled here with a label table.
fn cg_value(e: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    if let Expr::ArrLit(es) = e {
        if es.iter().any(|x| matches!(x, Expr::ArrLit(_) | Expr::DArrNew)) {
            return cg_darr2_literal(es, env, sigs, strs, out, target);
        }
    }
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
        Expr::Nil => Ty::Dyn,
        Expr::Str(_) => Ty::Str,
        Expr::Var(id) => env.iter().find(|v| v.name == *id).expect("checked").ty,
        Expr::Call(id, args) => {
            if is_builtin(id, "array") { return if args.len() == 1 { Ty::DArr } else { Ty::DArr2 }; }
            if is_builtin(id, "eval") || is_builtin(id, "len") || is_builtin(id, "hb_memcheck") { return Ty::I64; }
            sigs.iter().find(|v| v.name == *id).expect("checked").ret.expect("checked")
        }
        Expr::Cmp(..) => Ty::Bool,
        Expr::ArrLit(es) => {
            if es.iter().any(|e| matches!(e, Expr::ArrLit(_) | Expr::DArrNew)) { Ty::DArr2 } else { Ty::Arr(es.len()) }
        }
        Expr::Index(id, _) => match env.iter().find(|v| v.name == *id).map(|v| v.ty) {
            Some(Ty::Arr(_)) => Ty::I64,
            _ => Ty::Dyn,
        },
        Expr::Index2(_, _, _) => Ty::Dyn,
        Expr::BlockLit(_, ps, _) => Ty::Block(ps.len()),
        Expr::DArrNew => Ty::DArrU,
        Expr::HashLit(_) => Ty::Hash,
    }
}

// Layout pass: assigns stack slots in declaration order and computes the
// total frame size. Branch locals get their own slots and are scoped: the
// env is truncated at each branch join. The codegen walk below rebuilds
// the exact same env, so offsets match.
fn layout_locals(stmts: &[Stmt], env: &mut Vec<CgLocal>, sigs: &[Sig], frame: &mut usize, darr_slots: &mut Vec<(usize, u8)>, dyn_names: &std::collections::HashSet<String>) {
    for s in stmts {
        match s {
            Stmt::Local(_, id, e) => {
                let mut t = expr_ty(e, env, sigs);
                // Same prescan widening as cg_stmts (probe n2): an i64
                // initializer whose local later receives a Dyn value gets
                // the 16-byte slot.
                if t == Ty::I64 && dyn_names.contains(id) { t = Ty::Dyn; }
                *frame += size_of(t);
                env.push(CgLocal { name: id.clone(), ty: t, off: *frame });
                if matches!(t, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Hash) {
                    darr_slots.push((*frame, if t == Ty::Hash { 2 } else { (t == Ty::DArr2) as u8 }));
                }
            }
            Stmt::AAdd(_, id, e) => {
                // Replicate the checker's element-type pinning so later
                // expr_ty lookups and the epilogue agree with it.
                let vt = expr_ty(e, env, sigs);
                let mut flip = None;
                if let Some(v) = env.iter_mut().find(|v| v.name == *id) {
                    if v.ty == Ty::DArrU {
                        v.ty = if matches!(vt, Ty::DArr | Ty::DArrU) { Ty::DArr2 } else { Ty::DArr };
                        flip = Some((v.off, (v.ty == Ty::DArr2) as u8));
                    }
                }
                if let Some((off, deep)) = flip {
                    if let Some(slot) = darr_slots.iter_mut().find(|(o, _)| *o == off) {
                        slot.1 = deep;
                    }
                }
            }
            Stmt::Assign(_, id, e) => {
                let vt = expr_ty(e, env, sigs);
                let mut flip = None;
                if let Some(v) = env.iter_mut().find(|v| v.name == *id) {
                    if v.ty == Ty::DArrU && matches!(vt, Ty::DArr | Ty::DArr2) {
                        v.ty = vt;
                        flip = Some((v.off, (v.ty == Ty::DArr2) as u8));
                    }
                }
                if let Some((off, deep)) = flip {
                    if let Some(slot) = darr_slots.iter_mut().find(|(o, _)| *o == off) {
                        slot.1 = deep;
                    }
                }
            }
            Stmt::If(_, _, then_s, else_s) => {
                let mark = env.len();
                layout_locals(then_s, env, sigs, frame, darr_slots, dyn_names);
                env.truncate(mark);
                layout_locals(else_s, env, sigs, frame, darr_slots, dyn_names);
                env.truncate(mark);
            }
            Stmt::While(_, _, body) => {
                let mark = env.len();
                layout_locals(body, env, sigs, frame, darr_slots, dyn_names);
                env.truncate(mark);
            }
            Stmt::For(_, var, _, _, _, body) => {
                let mark = env.len();
                *frame += 8; // hidden slot holding the evaluated end bound
                *frame += 8;
                env.push(CgLocal { name: var.clone(), ty: Ty::I64, off: *frame });
                layout_locals(body, env, sigs, frame, darr_slots, dyn_names);
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
        // NIL against a string is always .F. under `=` (probe n1); only
        // `=` / `#` reach codegen (analysis rejects ordering NIL).
        Expr::Cmp(op, a, b) if (matches!(**a, Expr::Nil) && expr_ty(b, env, sigs) == Ty::Str)
            || (matches!(**b, Expr::Nil) && expr_ty(a, env, sigs) == Ty::Str) => {
            // The result is a constant, but BOTH operands still evaluate
            // left to right (a call may print; an index may raise a bound
            // error) - only the comparison itself is folded (probe n1).
            cg_value(a, env, sigs, strs, out, target);
            cg_value(b, env, sigs, strs, out, target);
            if matches!(op, CmpOp::Ne) {
                out.push_str(&format!("    jmp {}\n", true_label));
            }
            // Eq: the condition is never true - fall through.
        }
        Expr::Cmp(op, a, b) if expr_ty(a, env, sigs) == Ty::Dyn || expr_ty(b, env, sigs) == Ty::Dyn => {
            let ta = expr_ty(a, env, sigs);
            let tb = expr_ty(b, env, sigs);
            if ta == Ty::Str || tb == Ty::Str {
                // Dyn against a string: `=` is always .F., `#` always .T.
                // (probe n1: "" = NIL is .F.). Analysis rejects ordering.
                // The operands still evaluate left to right - only the
                // comparison is folded.
                cg_value(a, env, sigs, strs, out, target);
                cg_value(b, env, sigs, strs, out, target);
                if matches!(op, CmpOp::Ne) {
                    out.push_str(&format!("    jmp {}\n", true_label));
                }
                // Eq: the condition is never true - fall through.
            } else {
                match op {
                    CmpOp::Eq | CmpOp::Ne => {
                        // Tag-dispatch equality: NIL = NIL is .T., NIL
                        // against a payload is .F., payloads compare
                        // numerically (hbc_dyn_eq).
                        cg_expr(a, env, sigs, strs, out, target);
                        if ta == Ty::I64 { out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n"); }
                        match target {
                            Target::Linux => out.push_str("    push %rax\n    push %rdx\n"),
                            Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n"),
                        }
                        cg_expr(b, env, sigs, strs, out, target);
                        if tb == Ty::I64 { out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n"); }
                        out.push_str("    mov %rax, %rcx\n    mov %rdx, %r8\n");
                        match target {
                            Target::Linux => out.push_str("    pop %rdx\n    pop %rax\n"),
                            Target::Windows => out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n"),
                        }
                        out.push_str("    call hbc_dyn_eq\n    test %rax, %rax\n");
                        let j = match op { CmpOp::Eq => "jnz", _ => "jz" };
                        out.push_str(&format!("    {} {}\n", j, true_label));
                    }
                    _ => {
                        // Ordering: NIL in an ordering comparison is a
                        // Harbour type error; extraction raises it (clean
                        // exit 1, registered failure mode).
                        cg_expr(a, env, sigs, strs, out, target);
                        if ta == Ty::Dyn { out.push_str("    call hbc_dyn_to_i64\n"); }
                        match target {
                            Target::Linux => out.push_str("    push %rax\n"),
                            Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
                        }
                        cg_expr(b, env, sigs, strs, out, target);
                        if tb == Ty::Dyn { out.push_str("    call hbc_dyn_to_i64\n"); }
                        match target {
                            Target::Linux => out.push_str("    pop %rcx\n"),
                            Target::Windows => out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n"),
                        }
                        out.push_str("    cmp %rax, %rcx\n");
                        let j = match op {
                            CmpOp::Lt => "jl", CmpOp::Le => "jle", CmpOp::Gt => "jg",
                            CmpOp::Ge => "jge", _ => unreachable!(),
                        };
                        out.push_str(&format!("    {} {}\n", j, true_label));
                    }
                }
            }
        }
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

fn cg_stmts(stmts: &[Stmt], env: &mut Vec<CgLocal>, frame: &mut usize, sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target, fname: &str, label: &mut usize, ll: &Option<(String, String)>, slots: &[(usize, u8)], dyn_names: &std::collections::HashSet<String>) {
    for s in stmts {
        match s {
            Stmt::Local(_, id, e) => {
                let mut t = expr_ty(e, env, sigs);
                // Prescan widening (probe n2): an i64 initializer whose
                // local later receives a Dyn value gets the 16-byte slot;
                // the i64 initializer is tagged in as {0, payload}.
                let i64_init = t == Ty::I64 && dyn_names.contains(id);
                if i64_init { t = Ty::Dyn; }
                *frame += size_of(t);
                let off = *frame;
                if t == Ty::Hash {
                    if let Expr::HashLit(ps) = e {
                        // The slot starts zeroed by the prologue. Pairs are
                        // inserted in source order, key first then value
                        // (probe h9); hbc_hput copies the key bytes and the
                        // 16-byte value, so the temporaries stay owned here.
                        for (k, v) in ps {
                            cg_value(k, env, sigs, strs, out, target);
                            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                            cg_value(v, env, sigs, strs, out, target);
                            if expr_ty(v, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                            out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov 16(%rsp), %rsi\n    mov 24(%rsp), %rdx\n    mov %rsp, %rcx\n    call hbc_hput\n    add $32, %rsp\n", off));
                        }
                        env.push(CgLocal { name: id.clone(), ty: t, off });
                        continue;
                    }
                }
                match t {
                    Ty::Arr(_) => cg_array_value(e, off, env, sigs, strs, out, target),
                    _ => {
                        cg_value(e, env, sigs, strs, out, target);
                        if i64_init {
                            out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                        }
                        // A moved-out DArr SOURCE slot is nulled right after
                        // the load: every allocation keeps exactly one owner.
                        if let Expr::Var(src) = e {
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Hash)) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                            }
                        }
                        match t {
                            Ty::I64 | Ty::Block(_) => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off)),
                            Ty::Str | Ty::Dyn => {
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Hash => {
                                // The slot can hold a live value when a
                                // `local` re-declares inside a loop body:
                                // free the old allocation first (null-safe).
                                // The new value waits on the stack: hbc_free
                                // clobbers caller-saved registers (syscall).
                                let class = slots.iter().find(|(o, _)| *o == off).map(|(_, c)| *c).unwrap_or(0);
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                if class == 1 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    call hbc_free2\n85:\n", off, off - 8));
                                } else if class == 2 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    call hbc_hfree\n85:\n", off, off - 8));
                                } else {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov $16, %esi\n    call hbc_free\n85:\n", off));
                                }
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
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
                        Ty::Dyn => out.push_str("    call hbc_print_dyn\n"),
                        Ty::Bool => unreachable!("booleans rejected in analysis"),
                        Ty::Arr(_) => unreachable!("whole-array printing rejected in analysis"),
                        Ty::Block(_) => unreachable!("codeblock printing rejected in analysis"),
                        Ty::DArr | Ty::DArrU | Ty::DArr2 => unreachable!("whole-array printing rejected in analysis"),
                        Ty::Hash => unreachable!("whole-hash printing rejected in analysis"),
                    }
                }
                if !es.is_empty() {
                    out.push_str(&format!("    add ${}, %rsp\n", 16 * es.len()));
                }
            }
            Stmt::Ret(_, Some(e)) => {
                cg_value(e, env, sigs, strs, out, target);
                // Mixed int/NIL returns unify to Dyn (probe n2): an i64
                // return expression is tagged into the {0, payload} pair.
                if expr_ty(e, env, sigs) == Ty::I64
                    && sigs.iter().any(|sg| sg.name == fname && sg.ret == Some(Ty::Dyn)) {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                // Returning a dynamic array MOVES it to the caller: the
                // source slot is nulled BEFORE the shared epilogue runs, so
                // the epilogue never frees the returned allocation (parent
                // rule: move the return to the output before cleanup).
                if let Expr::Var(src) = e {
                    if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2)) {
                        out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                    }
                }
                out.push_str(&format!("    jmp .Lret_{}\n", fname));
            }
            Stmt::Ret(_, None) => {
                // `return` / `return nil` return NIL (probes n1c/n2): the
                // Dyn tag/payload pair travels like any 16-byte value.
                out.push_str("    mov $1, %eax\n    xor %edx, %edx\n");
                out.push_str(&format!("    jmp .Lret_{}\n", fname));
            }
            Stmt::If(_, cond, then_s, else_s) => {
                let id = *label;
                *label += 1;
                cg_cond_jump(cond, env, sigs, strs, out, target, &format!(".Lthen_{}_{}", fname, id));
                out.push_str(&format!("    jmp .Lelse_{}_{}\n", fname, id));
                out.push_str(&format!(".Lthen_{}_{}:\n", fname, id));
                let mark = env.len();
                cg_stmts(then_s, env, frame, sigs, strs, out, target, fname, label, ll, slots, dyn_names);
                env.truncate(mark);
                out.push_str(&format!("    jmp .Lend_{}_{}\n", fname, id));
                out.push_str(&format!(".Lelse_{}_{}:\n", fname, id));
                cg_stmts(else_s, env, frame, sigs, strs, out, target, fname, label, ll, slots, dyn_names);
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
                cg_stmts(body, env, frame, sigs, strs, out, target, fname, label, &inner, slots, dyn_names);
                env.truncate(mark);
                out.push_str(&format!("    jmp .Lwhile_{}_{}\n", fname, id));
                out.push_str(&format!(".Lendw_{}_{}:\n", fname, id));
            }
            Stmt::For(_, var, start, end, step, body) => {
                let id = *label;
                *label += 1;
                let mark = env.len();
                // Evaluate the START first, then the END into a hidden
                // slot: Harbour's observed order (probe c11: the start's
                // side effects print first) and Rust's `a..b` order agree.
                // Bounds evaluate once, as in Rust ranges. The step is a
                // non-zero literal, so the counting direction is fixed
                // here at compile time.
                cg_value(start, env, sigs, strs, out, target);
                *frame += 8;
                let i_off = *frame;
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", i_off));
                cg_value(end, env, sigs, strs, out, target);
                *frame += 8;
                let end_off = *frame;
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", end_off));
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
                cg_stmts(body, env, frame, sigs, strs, out, target, fname, label, &inner, slots, dyn_names);
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
                let lty = l.ty;
                if t == Ty::Hash {
                    if let Expr::HashLit(ps) = e {
                        // Reassign from a literal: the old value goes first
                        // (live len, never capacity), the slot is zeroed,
                        // then the pairs are inserted in source order.
                        out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 87f\n    mov -{}(%rbp), %rsi\n    call hbc_hfree\n87:\n", off, off - 8));
                        out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", off, off - 8));
                        for (k, v) in ps {
                            cg_value(k, env, sigs, strs, out, target);
                            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                            cg_value(v, env, sigs, strs, out, target);
                            if expr_ty(v, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                            out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov 16(%rsp), %rsi\n    mov 24(%rsp), %rdx\n    mov %rsp, %rcx\n    call hbc_hput\n    add $32, %rsp\n", off));
                        }
                        continue;
                    }
                }
                match t {
                    Ty::Arr(_) => cg_array_value(e, off, env, sigs, strs, out, target),
                    _ => {
                        cg_value(e, env, sigs, strs, out, target);
                        // Null a moved-out DArr source AFTER the RHS was
                        // fully evaluated (parent rule: move transfers; the
                        // old slot must not free what it no longer owns).
                        if let Expr::Var(src) = e {
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Hash)) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                            }
                        }
                        match t {
                            Ty::I64 | Ty::Block(_) if lty == Ty::Dyn => {
                                // Dyn slot, i64 value: tag it in (probe n2:
                                // reassignment re-tags a live variable).
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            Ty::I64 | Ty::Block(_) => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off)),
                            Ty::Dyn if lty == Ty::I64 => {
                                // i64 slot receiving a Dyn: the tag is
                                // checked at runtime (NIL -> clean error).
                                out.push_str("    call hbc_dyn_to_i64\n");
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                            }
                            Ty::Dyn => {
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            Ty::Str => {
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::Hash => {
                                // Free the OLD value after the RHS exists
                                // (self-assignment `a := a` moved through a
                                // temporary: the source was nulled above, so
                                // the free sees null and nothing is dropped
                                // twice). The free kind follows the slot's
                                // CURRENT type (the old value's type).
                                let cur_ty = env.iter().find(|x| x.name == *id).map(|x| x.ty);
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                if cur_ty == Some(Ty::DArr2) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    call hbc_free2\n86:\n", off, off - 8));
                                } else if cur_ty == Some(Ty::Hash) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    call hbc_hfree\n86:\n", off, off - 8));
                                } else {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov $16, %esi\n    call hbc_free\n86:\n", off));
                                }
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
                                // Replicate the checker's pinning of `{}`.
                                if let Some(v) = env.iter_mut().find(|x| x.name == *id) {
                                    if v.ty == Ty::DArrU && matches!(t, Ty::DArr | Ty::DArr2) {
                                        v.ty = t;
                                    }
                                }
                            }
                            _ => unreachable!("booleans rejected in analysis"),
                        }
                    }
                }
            }
            Stmt::AAdd(_, id, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                let vt = expr_ty(e, env, sigs);
                if v.ty == Ty::DArr2 || (v.ty == Ty::DArrU && matches!(vt, Ty::DArr | Ty::DArrU)) {
                    // Insert a dynamic array: the value MOVES into the
                    // parent (null the source right after the load).
                    cg_value(e, env, sigs, strs, out, target);
                    if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2)) {
                            out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                        }
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    out.push_str(&format!("    mov %rsp, %rdx\n    mov $16, %esi\n    lea -{}(%rbp), %rdi\n    call hbc_aadd\n    add $16, %rsp\n", v.off));
                } else {
                    // Scalar element: tag it into the {tag, payload} pair
                    // (i64 -> {0, v}, NIL/Dyn -> copied pair).
                    cg_expr(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::I64 {
                        out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    out.push_str(&format!("    mov %rsp, %rdx\n    mov $16, %esi\n    lea -{}(%rbp), %rdi\n    call hbc_aadd\n    add $16, %rsp\n", v.off));
                }
                // Replicate the checker's pinning of `{}`.
                if let Some(x) = env.iter_mut().find(|x| x.name == *id) {
                    if x.ty == Ty::DArrU {
                        x.ty = if matches!(vt, Ty::DArr | Ty::DArrU) { Ty::DArr2 } else { Ty::DArr };
                    }
                }
            }
            Stmt::ASize(_, id, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                let deep = v.ty == Ty::DArr2;
                cg_expr(e, env, sigs, strs, out, target);
                out.push_str(&format!("    mov %rax, %rsi\n    mov $16, %edx\n    mov ${}, %ecx\n    lea -{}(%rbp), %rdi\n    call hbc_asize\n",
                    if deep { 1 } else { 0 }, v.off));
            }
            Stmt::AAddSub(_, id, ie, e) => {
                // AAdd(a[i], x): index FIRST, then the value (probe m7).
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                out.push_str("    mov 16(%rsp), %rcx\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                out.push_str("    mov %rsp, %rdx\n    mov $16, %esi\n    call hbc_aadd\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                out.push_str("    add $32, %rsp\n");
            }
            Stmt::ASizeSub(_, id, ie, e) => {
                // ASize(a[i], n): index first, then the size (probe m7).
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(e, env, sigs, strs, out, target);
                out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                out.push_str("    mov %rax, %rsi\n    mov $16, %edx\n    xor %ecx, %ecx\n    call hbc_asize\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
            }
            Stmt::ArrSet(_, id, ie, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                if v.ty == Ty::DArr2 {
                    // Child overwrite: RHS (a dynamic array) moves in; the
                    // OLD child is freed once, AFTER the new value exists
                    // and the source was nulled (no double free).
                    cg_value(e, env, sigs, strs, out, target);
                    if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2)) {
                            out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                        }
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, %rcx\n");
                    out.push_str(&format!("    cmp $1, %rcx\n    jl 89f\n    cmp -{}(%rbp), %rcx\n    jg 89f\n", v.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                    out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    // free the old child (a Dyn-element array: shallow free)
                    out.push_str("    mov (%r10), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov $16, %esi\n    sub $16, %rsp\n    mov %r10, (%rsp)\n    call hbc_free\n    mov (%rsp), %r10\n    add $16, %rsp\n85:\n");
                    out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    mov %rax, (%r10)\n    mov %rdx, 8(%r10)\n    add $16, %rsp\n    jmp 86f\n89:\n    call hbc_bound_error\n86:\n");
                } else if v.ty == Ty::Hash {
                    // h[k] := v: value FIRST, then the key (probe h4).
                    // Both wait on the stack across hbc_hput, which copies
                    // the key bytes and the value - the hash owns copies,
                    // the temporaries stay owned here.
                    cg_value(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::I64 {
                        out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    cg_value(ie, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, %rsi\n");
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov %rsp, %rcx\n    call hbc_hput\n    add $16, %rsp\n", v.off));
                } else if v.ty == Ty::DArr {
                    // Dynamic array write: same value-first order; bounds
                    // 1..=len from the slot word. Elements are {tag,
                    // payload} pairs. Borrows `a` - never nulls.
                    cg_expr(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::I64 {
                        out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    if expr_ty(ie, env, sigs) == Ty::Dyn {
                        cg_expr(ie, env, sigs, strs, out, target);
                        out.push_str("    call hbc_dyn_to_i64\n");
                    } else {
                        cg_expr(ie, env, sigs, strs, out, target);
                    }
                    out.push_str("    mov %rax, %rcx\n    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
                    out.push_str(&format!("    cmp $1, %rcx\n    jl 83f\n    cmp -{}(%rbp), %rcx\n    jg 83f\n", v.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                    out.push_str("    dec %rcx\n    shl $4, %rcx\n    add %r11, %rcx\n    mov %rax, (%rcx)\n    mov %rdx, 8(%rcx)\n    jmp 84f\n");
                    out.push_str("83:\n    call hbc_bound_error\n84:\n");
                } else {
                let k = match v.ty { Ty::Arr(k) => k, _ => unreachable!("checked") };
                // Value FIRST, then the index: both Harbour (probe adv2,
                // `a[idx()] := give()` prints give's side effect first)
                // and Rust (`a[i] = v` evaluates the RHS before the place)
                // use this order. The value waits in a 16-byte stack slot
                // (keeps rsp 16-aligned for the Win64 ABI if the index
                // expression calls; the Linux side is our own freestanding
                // syscall convention - it imposes no external ABI, but we
                // claim no general System V compliance either).
                cg_expr(e, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    mov %rax, %rcx\n    mov (%rsp), %rax\n    add $16, %rsp\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 83f\n    cmp ${}, %rcx\n    jg 83f\n", k));
                out.push_str(&format!("    lea -{}(%rbp), %r11\n    mov %rax, -8(%r11,%rcx,8)\n    jmp 84f\n", v.off));
                out.push_str("83:\n    call hbc_bound_error\n84:\n");
                }
            }
            Stmt::ArrSet2(_, id, ie, ie2, e) => {
                // a[i][j] := v: value first, then outer index, then inner
                // index (probe m7); both bounds checked; transient borrows.
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                if expr_ty(ie2, env, sigs) == Ty::Dyn {
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie2, env, sigs, strs, out, target);
                }
                out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                // rax = value(sp), rcx = i, then j in rax below
                out.push_str("    mov %rax, %r9\n    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
                // rax = value tag, rdx = payload, rcx = i, r9 = j
                out.push_str(&format!("    cmp $1, %rcx\n    jl 90f\n    cmp -{}(%rbp), %rcx\n    jg 90f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                out.push_str("    cmp $1, %r9\n    jl 90f\n    cmp 8(%r10), %r9\n    jg 90f\n");
                out.push_str("    mov (%r10), %r11\n    dec %r9\n    shl $4, %r9\n    add %r11, %r9\n    mov %rax, (%r9)\n    mov %rdx, 8(%r9)\n    jmp 92f\n90:\n    call hbc_bound_error\n92:\n");
            }
        }
    }
}

// Collect every block literal in a statement tree (deterministic order).
fn collect_blocks_expr(e: &Expr, out: &mut Vec<(usize, Vec<String>, Vec<Expr>)>) {
    match e {
        Expr::BlockLit(id, ps, body) => {
            out.push((*id, ps.clone(), body.clone()));
        }
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => { collect_blocks_expr(a, out); collect_blocks_expr(b, out); }
        Expr::Call(_, args) => { for a in args { collect_blocks_expr(a, out); } }
        Expr::ArrLit(es) => { for e in es { collect_blocks_expr(e, out); } }
        Expr::Index(_, ie) => collect_blocks_expr(ie, out),
        Expr::Index2(_, ie, ie2) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); }
        _ => {}
    }
}
fn collect_blocks_stmts(stmts: &[Stmt], out: &mut Vec<(usize, Vec<String>, Vec<Expr>)>) {
    for s in stmts {
        match s {
            Stmt::Local(_, _, e) | Stmt::Assign(_, _, e) => collect_blocks_expr(e, out),
            Stmt::ArrSet(_, _, ie, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(e, out); }
            Stmt::Print(_, es) => { for e in es { collect_blocks_expr(e, out); } }
            Stmt::Ret(_, Some(e)) => collect_blocks_expr(e, out),
            Stmt::Ret(_, None) | Stmt::Exit(_) | Stmt::Loop(_) => {}
            Stmt::AAdd(_, _, e) | Stmt::ASize(_, _, e) => collect_blocks_expr(e, out),
            Stmt::ArrSet2(_, _, ie, ie2, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); collect_blocks_expr(e, out); }
            Stmt::AAddSub(_, _, ie, e) | Stmt::ASizeSub(_, _, ie, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(e, out); }
            Stmt::If(_, c, a, b) => { collect_blocks_expr(c, out); collect_blocks_stmts(a, out); collect_blocks_stmts(b, out); }
            Stmt::While(_, c, body) => { collect_blocks_expr(c, out); collect_blocks_stmts(body, out); }
            Stmt::For(_, _, a, b, _, body) => { collect_blocks_expr(a, out); collect_blocks_expr(b, out); collect_blocks_stmts(body, out); }
        }
    }
}

// Emit one block as a function with the standard convention: parameters
// copied from the caller's argument slots, body expressions evaluated in
// order, the LAST one's value returned in %rax (probe c4). Integer
// parameters and bodies only in this increment (checked in analysis), so
// no strings, no drops, no heap.
fn emit_block(id: usize, params: &[String], body: &[Expr], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    let mut lenv: Vec<CgLocal> = Vec::new();
    let mut frame = 0usize;
    for p in params {
        frame += 8;
        lenv.push(CgLocal { name: p.clone(), ty: Ty::I64, off: frame });
    }
    let n = lenv.len();
    out.push_str(&format!("hbc_blk_{}:\n", id));
    out.push_str("    push %rbp\n    mov %rsp, %rbp\n");
    let frame = if target == Target::Windows { (frame + 15) & !15 } else { frame };
    if frame > 0 {
        out.push_str(&format!("    sub ${}, %rsp\n", frame));
    }
    for (k, v) in lenv.iter().enumerate() {
        let src = 16 * (n - k);
        out.push_str(&format!("    mov {}(%rbp), %rax\n", src));
        out.push_str(&format!("    mov %rax, -{}(%rbp)\n", v.off));
    }
    for (i, e) in body.iter().enumerate() {
        cg_expr(e, &lenv, sigs, strs, out, target);
        if i + 1 < body.len() {
            out.push_str("    # intermediate block expression: value discarded (probe c4)\n");
        }
    }
    out.push_str("    leave\n    ret\n\n");
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
    let mut darr_slots: Vec<(usize, u8)> = Vec::new();
    layout_locals(&f.stmts, &mut lenv, sigs, &mut frame, &mut darr_slots, &f.dyn_names);
    // Dynamic-array parameters are owned by this function: their slots are
    // freed at the shared epilogue like any other DArr local.
    for v in &lenv[..lenv.len().min(f.params.len())] {
        if v.ty == Ty::DArr {
            darr_slots.push((v.off, 0));
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
    // Zero-init every dynamic-array slot (parameters included): the
    // epilogue and reassignment free any non-null slot, so every slot must
    // start in the known-empty state even when its declaring branch never
    // runs. Argument copy-in below overwrites the parameter slots.
    for (off, _) in &darr_slots {
        out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", off, off - 8));
    }
    // Copy incoming arguments from the caller's stack into the parameter
    // slots: arguments were pushed left to right, so arg k sits at
    // 16*(n-k)(%rbp) after this prologue (the last argument is nearest).
    // A string argument occupies both words of its slot (pointer, length).
    for (k, v) in lenv[..nparams].iter().enumerate() {
        let src = 16 * (nparams - k);
        if v.ty == Ty::Str || v.ty == Ty::DArr || v.ty == Ty::Dyn {
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
    cg_stmts(&f.stmts, &mut env, &mut walk_frame, sigs, strs, out, target, &f.name, &mut label, &None, &darr_slots, &f.dyn_names);
    // Free every dynamic array still owned on this exit path. A slot is
    // null when its value was moved out (moves null the source, so each
    // allocation has exactly one freeing owner) or when it never held a
    // value; freeing checks the pointer, so both cases are safe without
    // any path tracking in codegen. The return value was moved to the
    // output registers (and its slot nulled) before this point.
    out.push_str(&format!(".Lret_{}:\n", f.name));
    // The return value waits on the stack while the frees run: hbc_free
    // clobbers rax (and rdx on Windows) and a slot still owned here must
    // not destroy it.
    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
    for (i, (off, class)) in darr_slots.iter().enumerate() {
        match class {
            1 => {
                // DArr2: free each live child, then the outer block.
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov -{}(%rbp), %rsi\n    call hbc_free2\n91{}:\n", off, i, off - 8, i));
            }
            2 => {
                // Hash: free each live key copy, then the block.
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov -{}(%rbp), %rsi\n    call hbc_hfree\n91{}:\n", off, i, off - 8, i));
            }
            _ => {
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov $16, %esi\n    call hbc_free\n91{}:\n", off, i, i));
            }
        }
    }
    out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
    out.push_str("    leave\n    ret\n\n");
    // Block literals used by this function are emitted right after it.
    let mut blocks = Vec::new();
    collect_blocks_stmts(&f.stmts, &mut blocks);
    for (id, ps, body) in blocks {
        emit_block(id, &ps, &body, sigs, strs, out, target);
    }
}

const REG_ALLOC_L: &str = r"    # harness registry (instrumented build): record (base, bytes) so
    # hbc_free can verify the exact unmap length, not just call balance.
    # Freed entries are reused (swap-with-last in hbc_free); the 16384
    # CONCURRENT-live limit exists only in this build and reports as OOM.
    mov hbc_reg_count(%rip), %rcx
    cmp $16384, %rcx
    jae hbc_oom
    lea hbc_reg_base(%rip), %r10
    mov %rax, (%r10,%rcx,8)
    lea hbc_reg_size(%rip), %r10
    mov %rsi, (%r10,%rcx,8)
    incq hbc_reg_count(%rip)
";
const REG_FREE_L: &str = r"    # harness registry: the computed unmap length must equal the recorded
    # allocation size, and the block must be live (double free = absent).
    # Callers keep loop state in r9/r10 (hbc_asize shrink) and possibly
    # rdx across this call: preserve them; r11 is syscall-clobbered anyway.
    push %rdx
    push %r9
    push %r10
    mov hbc_reg_count(%rip), %rcx
    lea hbc_reg_base(%rip), %r10
    lea hbc_reg_size(%rip), %r11
31: test %rcx, %rcx
    jz hbc_reg_bad
    dec %rcx
    cmp %rdi, (%r10,%rcx,8)
    jne 31b
    cmp %rsi, (%r11,%rcx,8)
    jne hbc_reg_bad
    mov hbc_reg_count(%rip), %rdx
    dec %rdx
    mov (%r10,%rdx,8), %r9
    mov %r9, (%r10,%rcx,8)
    mov (%r11,%rdx,8), %r9
    mov %r9, (%r11,%rcx,8)
    mov %rdx, hbc_reg_count(%rip)
    pop %r10
    pop %r9
    pop %rdx
";
const REG_BAD_L: &str = r"# hbc_reg_bad: registry mismatch or unknown/double free (noreturn).
hbc_reg_bad:
    lea .Lregbadmsg(%rip), %rsi
    mov $45, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

";
const REG_ALLOC_W: &str = r"    # harness registry (instrumented build): record (base, bytes) so
    # hbc_free can verify the exact block size, not just call balance.
    # Freed entries are reused; the 16384 CONCURRENT-live limit exists
    # only in this build and reports as OOM.
    mov hbc_reg_count(%rip), %rcx
    cmp $16384, %rcx
    jae hbc_oom
    lea hbc_reg_base(%rip), %r10
    mov %rax, (%r10,%rcx,8)
    mov 32(%rsp), %rdx
    lea hbc_reg_size(%rip), %r10
    mov %rdx, (%r10,%rcx,8)
    incq hbc_reg_count(%rip)
";
const REG_FREE_W: &str = r"    # harness registry: computed 8 + cap*elemsize must equal the recorded
    # allocation size, and the block must be live (double free = absent).
    mov -8(%rdi), %rax
    imul %rsi, %rax
    add $8, %rax
    lea -8(%rdi), %r8
    mov hbc_reg_count(%rip), %rcx
    lea hbc_reg_base(%rip), %r10
    lea hbc_reg_size(%rip), %r11
31: test %rcx, %rcx
    jz hbc_reg_bad
    dec %rcx
    cmp %r8, (%r10,%rcx,8)
    jne 31b
    cmp %rax, (%r11,%rcx,8)
    jne hbc_reg_bad
    mov hbc_reg_count(%rip), %rdx
    dec %rdx
    mov (%r10,%rdx,8), %r9
    mov %r9, (%r10,%rcx,8)
    mov (%r11,%rdx,8), %r9
    mov %r9, (%r11,%rcx,8)
    mov %rdx, hbc_reg_count(%rip)
";
const REG_BAD_W: &str = r"# hbc_reg_bad: registry mismatch or unknown/double free (noreturn).
# Entered via a conditional JUMP: force 16-byte alignment explicitly.
hbc_reg_bad:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lregbadmsg(%rip), %rax
    mov $45, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

";
const REG_DATA: &str = r"hbc_reg_count:  .quad 0
    .bss
    .align 8
hbc_reg_base:   .skip 131072
hbc_reg_size:   .skip 131072
";

const CTOR_HELPERS: &str = r"
# --- Array(n, m) constructor -------------------------------------------
# hbc_arraym: rdi = parent slot address (zeroed by the caller), rsi =
# rows, rdx = cols. Builds n children, each a Dyn-element array of m NIL
# slots (oracle m3), via hbc_asize + hbc_aadd. A negative dimension
# aborts via hbc_asize_neg (Harbour's BASE/1131 dialog hangs headless -
# registered failure mode); OOM aborts via hbc_oom with the entries
# already appended staying a valid shorter array. Target-independent
# logic: all OS contact goes through hbc_alloc/hbc_free inside the
# called helpers.
# State lives on the frame. (Internal helper ABI, audited in iteration
# 18: every helper preserves rbx/rbp/r12-r15 on both targets - the
# Windows hbc_free2/hbc_aadd/hbc_asize were fixed to save what they use;
# generated code holds live state on the stack and in volatile registers
# only. Frame-held state keeps this helper correct even if a future
# helper regresses.)
hbc_arraym:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rdi, -8(%rbp)
    mov %rsi, -16(%rbp)
    mov %rdx, -24(%rbp)
    movq $0, -32(%rbp)
    test %rsi, %rsi
    js hbc_asize_neg
    test %rdx, %rdx
    js hbc_asize_neg
22: mov -32(%rbp), %rax
    cmp -16(%rbp), %rax
    jae 23f
    movq $0, -48(%rbp)
    movq $0, -40(%rbp)
    lea -48(%rbp), %rdi
    mov -24(%rbp), %rsi
    mov $16, %edx
    xor %ecx, %ecx
    call hbc_asize
    mov -8(%rbp), %rdi
    mov $16, %esi
    lea -48(%rbp), %rdx
    call hbc_aadd
    incq -32(%rbp)
    jmp 22b
23: leave
    ret
";

const HASH_HELPERS: &str = r"
# --- hashes (v1): insertion-ordered, string-keyed maps -----------------
# The slot holds {data pointer, live pair count}; null/0 is the empty
# hash (probe h2). Block layout: capacity header (in pairs) at the base,
# then 32-byte entries {keyptr, keylen, tag, payload} from base+8, packed
# over [0, len). Keys are owned copies with an 8-byte length header, so
# hbc_free(keyptr, 1) releases exactly 8 + keylen bytes. Values are Dyn
# {tag, payload} pairs (i64 or NIL in v1). Target-independent logic: all
# OS contact goes through hbc_alloc/hbc_free.

# hbc_hget: rdi = slot address, rsi = key bytes, rdx = key length.
# Returns rax = pointer to the entry's {tag, payload} pair, or 0 on a
# miss. Read-only: a lookup never mutates the hash (probes h3/h3b/h3c).
hbc_hget:
    mov (%rdi), %r10
    test %r10, %r10
    je 41f
    mov 8(%rdi), %r11
    xor %ecx, %ecx
42: cmp %r11, %rcx
    jae 41f
    mov %rcx, %rax
    shl $5, %rax
    add %r10, %rax
    mov 8(%rax), %r8
    cmp %rdx, %r8
    jne 43f
    mov (%rax), %r8
    xor %r9d, %r9d
44: cmp %rdx, %r9
    jae 45f
    movzbl (%r8,%r9), %edi
    cmp %dil, (%rsi,%r9)
    jne 43f
    inc %r9
    jmp 44b
43: inc %rcx
    jmp 42b
45: add $16, %rax
    ret
41: xor %eax, %eax
    ret

# hbc_hput: rdi = slot address, rsi = key bytes, rdx = key length,
# rcx = pointer to the 16-byte value {tag, payload}. A found key is
# overwritten in place (probe h8: len unchanged, last value wins). On a
# miss the key bytes are copied into an owned allocation FIRST, so a
# failed grow leaves the hash untouched (hbc_alloc exits via hbc_oom
# with every temporary still owned by the caller). Growth doubles the
# capacity (first grow: 4 pairs, overflow is OOM), moves the entries,
# frees the OLD block shallow - the key copies moved with the entries -
# and commits {ptr, len} last.
hbc_hput:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $24, %rsp
    mov %rdi, %rbx
    mov %rsi, %r14
    mov %rdx, %r15
    mov %rcx, -48(%rbp)
    mov (%rbx), %r12
    mov 8(%rbx), %r13
    test %r12, %r12
    je 30f
    xor %ecx, %ecx
31: cmp %r13, %rcx
    jae 30f
    mov %rcx, %rax
    shl $5, %rax
    add %r12, %rax
    mov 8(%rax), %r8
    cmp %r15, %r8
    jne 32f
    mov (%rax), %r8
    xor %r9d, %r9d
33: cmp %r15, %r9
    jae 34f
    movzbl (%r8,%r9), %r10d
    cmp %r10b, (%r14,%r9)
    jne 32f
    inc %r9
    jmp 33b
32: inc %rcx
    jmp 31b
34: mov -48(%rbp), %rcx
    mov (%rcx), %r8
    mov %r8, 16(%rax)
    mov 8(%rcx), %r8
    mov %r8, 24(%rax)
    jmp 49f
30: lea 8(%r15), %rdi
    call hbc_alloc
    mov %r15, (%rax)
    lea 8(%rax), %rsi
    xor %ecx, %ecx
35: cmp %r15, %rcx
    jae 36f
    movzbl (%r14,%rcx), %r8d
    mov %r8b, (%rsi,%rcx)
    inc %rcx
    jmp 35b
36: mov %rsi, %r14
    test %r12, %r12
    je 37f
    mov -8(%r12), %rax
    cmp %rax, %r13
    jb 40f
    add %rax, %rax
    mov $0x07FFFFFFFFFFFFFF, %rcx
    cmp %rcx, %rax
    ja hbc_oom
    jmp 38f
37: mov $4, %eax
38: mov %rax, -56(%rbp)
    shl $5, %rax
    lea 8(%rax), %rdi
    call hbc_alloc
    mov -56(%rbp), %rcx
    mov %rcx, (%rax)
    add $8, %rax
    mov %rax, -64(%rbp)
    mov %rax, %r9
    test %r12, %r12
    je 39f
    xor %ecx, %ecx
46: cmp %r13, %rcx
    jae 47f
    mov %rcx, %rax
    shl $5, %rax
    mov (%r12,%rax), %r8
    mov %r8, (%r9,%rax)
    mov 8(%r12,%rax), %r8
    mov %r8, 8(%r9,%rax)
    mov 16(%r12,%rax), %r8
    mov %r8, 16(%r9,%rax)
    mov 24(%r12,%rax), %r8
    mov %r8, 24(%r9,%rax)
    inc %rcx
    jmp 46b
47: mov %r12, %rdi
    mov $32, %esi
    call hbc_free
39: mov -64(%rbp), %r12
40: mov %r13, %rax
    shl $5, %rax
    add %r12, %rax
    mov %r14, (%rax)
    mov %r15, 8(%rax)
    mov -48(%rbp), %rcx
    mov (%rcx), %r8
    mov %r8, 16(%rax)
    mov 8(%rcx), %r8
    mov %r8, 24(%rax)
    mov %r12, (%rbx)
    inc %r13
    mov %r13, 8(%rbx)
49: add $24, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_hfree: rdi = block data pointer (non-null), rsi = live pair count.
# Frees each live key copy, then the block. Uses the LIVE length, never
# the capacity: after a grow the key copies live in the new block's
# [0, len) entries.
hbc_hfree:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $8, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    xor %r13d, %r13d
20: cmp %r12, %r13
    jae 21f
    mov %r13, %rax
    shl $5, %rax
    mov (%rbx,%rax), %rdi
    mov $1, %esi
    call hbc_free
    inc %r13
    jmp 20b
21: mov %rbx, %rdi
    mov $32, %esi
    call hbc_free
    add $8, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
";

fn emit_asm(funcs: &[Func], sigs: &[Sig], target: Target, instrument: bool) -> String {
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
            out.push_str(CTOR_HELPERS);
            out.push_str(HASH_HELPERS);
            out.push_str("\n    .section .rdata,\"r\"\n");
            emit_strings(&mut out, &strs);
            // Allocation registry only in instrumented builds (--instrument).
            out = out.replace("@REG_ALLOC_W@", if instrument { REG_ALLOC_W } else { "" });
            out = out.replace("@REG_FREE_W@", if instrument { REG_FREE_W } else { "" });
            out = out.replace("@REG_BAD_W@", if instrument { REG_BAD_W } else { "" });
            out = out.replace("@REG_DATA@", if instrument { REG_DATA } else { "" });
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

# hbc_print_dyn: %rax = tag, %rdx = payload. Prints NIL (no field width,
# probe n1) for tag 1; otherwise the numeric payload via hbc_print_i64.
hbc_print_dyn:
    test %rax, %rax
    jz 8f
    lea .Lnilmsg(%rip), %rsi
    mov $3, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    ret
8:  mov %rdx, %rax
    jmp hbc_print_i64

# hbc_dyn_to_i64: %rax = tag, %rdx = payload -> %rax = payload. NIL here is
# a Harbour type error (arithmetic/ordering/indexing on NIL); its dialog
# cannot be probed headless, so this fails cleanly - registered failure
# mode alongside hbc_bound_error, NOT a compat success.
hbc_dyn_to_i64:
    test %rax, %rax
    jnz hbc_type_error
    mov %rdx, %rax
    ret

# hbc_dyn_eq: %rax/%rdx = lhs tag/payload, %rcx/%r8 = rhs tag/payload ->
# %rax = 1/0. NIL = NIL is .T.; NIL against a payload is .F. (probes n1-n3).
hbc_dyn_eq:
    cmp %rcx, %rax
    jne 8f
    test %rax, %rax
    jnz 9f
    cmp %r8, %rdx
    jne 8f
9:  mov $1, %eax
    ret
8:  xor %eax, %eax
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

# hbc_type_error: NIL used as a number at runtime (arithmetic, ordering or
# array indexing). Harbour raises a type-error dialog; headless probes
# cannot capture it, so this PoC prints and exits 1 (registered failure
# mode, same error condition).
hbc_type_error:
    lea .Ltypemsg(%rip), %rsi
    mov $33, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# ---- dynamic array heap (mmap) ----
# hbc_alloc: rdi = bytes -> rax = base of a zeroed anonymous mapping.
# mmap failure is a negative errno in rax (range -4095..-1), never NULL.
hbc_alloc:
    mov %rdi, %rsi
    xor %edi, %edi
    mov $3, %edx
    mov $0x22, %r10d
    mov $-1, %r8
    xor %r9d, %r9d
    mov $9, %eax
    syscall
    mov $-4096, %rcx
    cmp %rcx, %rax
    ja hbc_oom
@REG_ALLOC_L@    incq hbc_mem_allocs(%rip)
    ret

# hbc_oom: allocation failure or capacity overflow (noreturn)
hbc_oom:
    lea .Loommsg(%rip), %rsi
    mov $14, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_asize_neg: ASize with a negative size (noreturn)
hbc_asize_neg:
    lea .Lasizenegmsg(%rip), %rsi
    mov $21, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_free: rdi = data pointer (non-null), rsi = element size in bytes.
# Header at -8 holds the capacity in elements; the mapped length is
# 8 + cap*elemsize (munmap needs the allocation length).
hbc_free:
    mov -8(%rdi), %rax
    imul %rsi, %rax
    lea 8(%rax), %rsi
    sub $8, %rdi
@REG_FREE_L@    mov $11, %eax
    syscall
    # munmap result: 0 on success, negative errno otherwise - a registry
    # match alone does not prove the OS released the block.
    test %rax, %rax
    jnz hbc_os_bad
    incq hbc_mem_frees(%rip)
    ret

@REG_BAD_L@# hbc_os_bad: munmap reported failure (noreturn).
hbc_os_bad:
    lea .Losbadmsg(%rip), %rsi
    mov $31, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_free2: rdi = outer data pointer (non-null), rsi = outer length.
# Frees each live child (i64 arrays in this increment) then the outer block.
hbc_free2:
    push %rbx
    push %r12
    push %r13
    mov %rdi, %rbx
    mov %rsi, %r12
    xor %r13, %r13
71: cmp %r12, %r13
    jge 72f
    mov %r13, %rax
    shl $4, %rax
    mov (%rbx,%rax), %rdi
    test %rdi, %rdi
    jz 73f
    mov $16, %esi
    call hbc_free
73: inc %r13
    jmp 71b
72: mov %rbx, %rdi
    mov $16, %esi
    call hbc_free
    pop %r13
    pop %r12
    pop %rbx
    ret

# hbc_aadd: rdi = slot address (ptr,len), rsi = element size (8 or 16),
# rdx = pointer to the new element. Grows in place; a failed allocation
# leaves the old block and the slot untouched (the slot is replaced only
# after the new block is fully populated).
hbc_aadd:
    push %rbx
    push %r12
    push %r13
    push %r14
    mov %rdi, %rbx
    mov %rsi, %r14
    mov %rdx, %r12
    mov (%rbx), %r13
    xor %ecx, %ecx
    test %r13, %r13
    jz 51f
    mov -8(%r13), %rcx
51: cmp 8(%rbx), %rcx
    jg 54f
    # grow: newcap = cap ? cap*2 : 4
    mov $4, %eax
    test %rcx, %rcx
    jz 52f
    lea (%rcx,%rcx), %rax
52: mov $0x2000000000000000, %rdx
    cmp %rdx, %rax
    jae hbc_oom
    push %rcx
    push %rax
    mov %rax, %rdi
    imul %r14, %rdi
    jo hbc_oom
    add $8, %rdi
    jc hbc_oom
    call hbc_alloc
    pop %rdx
    pop %rcx
    mov %rdx, (%rax)
    test %r13, %r13
    jz 53f
    mov 8(%rbx), %r8
    xor %r9, %r9
55: cmp %r8, %r9
    jge 56f
    mov %r9, %r10
    imul %r14, %r10
    mov (%r13,%r10), %rcx
    mov %rcx, 8(%rax,%r10)
    cmp $16, %r14
    jne 57f
    mov 8(%r13,%r10), %rcx
    mov %rcx, 16(%rax,%r10)
57: inc %r9
    jmp 55b
56: sub $16, %rsp
    mov %rax, (%rsp)
    mov %r13, %rdi
    mov %r14, %rsi
    call hbc_free
    mov (%rsp), %rax
    add $16, %rsp
53: add $8, %rax
    mov %rax, (%rbx)
    mov %rax, %r13
54: mov 8(%rbx), %rcx
    mov %rcx, %r10
    imul %r14, %r10
    mov (%r12), %rax
    mov %rax, (%r13,%r10)
    cmp $16, %r14
    jne 58f
    mov 8(%r12), %rax
    mov %rax, 8(%r13,%r10)
58: inc %rcx
    mov %rcx, 8(%rbx)
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret

# hbc_asize: rdi = slot address, rsi = new length, rdx = element size,
# rcx = deep flag (1: free removed children on shrink). Grown i64 slots
# read NIL (probe e1: Harbour grows with NIL); a DArr2 grows with the empty
# (null, 0) child.
hbc_asize:
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r14
    mov %rcx, %r15
    test %r12, %r12
    js hbc_asize_neg
    mov 8(%rbx), %rcx
    cmp %rcx, %r12
    jle 59f
    mov (%rbx), %r13
    xor %edx, %edx
    test %r13, %r13
    jz 61f
    mov -8(%r13), %rdx
61: cmp %rdx, %r12
    jle 63f
    mov $4, %eax
    test %rdx, %rdx
    jz 62f
    lea (%rdx,%rdx), %rax
62: cmp %rax, %r12
    jle 64f
    mov %r12, %rax
64: mov $0x2000000000000000, %r8
    cmp %r8, %rax
    jae hbc_oom
    push %rdx
    push %rax
    mov %rax, %rdi
    imul %r14, %rdi
    jo hbc_oom
    add $8, %rdi
    jc hbc_oom
    call hbc_alloc
    pop %rdx
    pop %rcx
    mov %rdx, (%rax)
    mov 8(%rbx), %r8
    test %r13, %r13
    jz 65f
    xor %r9, %r9
66: cmp %r8, %r9
    jge 69f
    mov %r9, %r10
    imul %r14, %r10
    mov (%r13,%r10), %rcx
    mov %rcx, 8(%rax,%r10)
    cmp $16, %r14
    jne 60f
    mov 8(%r13,%r10), %rcx
    mov %rcx, 16(%rax,%r10)
60: inc %r9
    jmp 66b
69: sub $16, %rsp
    mov %rax, (%rsp)
    mov %r13, %rdi
    mov %r14, %rsi
    call hbc_free
    mov (%rsp), %rax
    add $16, %rsp
65: add $8, %rax
    mov %rax, (%rbx)
    mov %rax, %r13
63: mov 8(%rbx), %rcx
67: cmp %r12, %rcx
    jge 68f
    mov %rcx, %r10
    shl $4, %r10
    test %r15, %r15
    jnz 79f
    # flat dynamic arrays grow with NIL {1, 0} (probe e1: grown slots read NIL)
    movq $1, (%r13,%r10)
    movq $0, 8(%r13,%r10)
    jmp 74f
79: # a DArr2 grows with the empty child (null, 0) - m-probes, unchanged
    movq $0, (%r13,%r10)
    movq $0, 8(%r13,%r10)
74: inc %rcx
    jmp 67b
68: mov %r12, 8(%rbx)
    jmp 75f
59: # shrink: free the removed children when deep
    test %r15, %r15
    jz 76f
    mov (%rbx), %r13
    mov %r12, %r9
77: cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    mov (%r13,%r10), %rdi
    test %rdi, %rdi
    jz 78f
    mov $16, %esi
    call hbc_free
78: inc %r9
    jmp 77b
76: mov %r12, 8(%rbx)
75: pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret

    .data
    .align 8
hbc_mem_allocs: .quad 0
hbc_mem_frees:  .quad 0
@REG_DATA@    .text
"#);
    out.push_str(CTOR_HELPERS);
    out.push_str(HASH_HELPERS);
    out.push_str("\n    .section .rodata\n");
    emit_strings(&mut out, &strs);
    // Allocation registry: only instrumented builds (--instrument, the
    // battery's mode) carry it; normal output has no registry at all.
    out = out.replace("@REG_ALLOC_L@", if instrument { REG_ALLOC_L } else { "" });
    out = out.replace("@REG_FREE_L@", if instrument { REG_FREE_L } else { "" });
    out = out.replace("@REG_BAD_L@", if instrument { REG_BAD_L } else { "" });
    out = out.replace("@REG_ALLOC_W@", if instrument { REG_ALLOC_W } else { "" });
    out = out.replace("@REG_FREE_W@", if instrument { REG_FREE_W } else { "" });
    out = out.replace("@REG_BAD_W@", if instrument { REG_BAD_W } else { "" });
    out = out.replace("@REG_DATA@", if instrument { REG_DATA } else { "" });
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
    // "NIL" (3 bytes; the NIL print form, probe n1)
    out.push_str(".Lnilmsg:\n    .byte 78,73,76\n");
    // "Bound error: array access\n" (26 bytes; Harbour wording, probe a1)
    out.push_str(".Lboundmsg:\n    .byte 66,111,117,110,100,32,101,114,114,111,114,58,32,97,114,114,97,121,32,97,99,99,101,115,115,10\n");
    out.push_str(".Loommsg:\n    .byte 79,117,116,32,111,102,32,109,101,109,111,114,121,10\n");
    // "Type error: NIL used as a number\n" (33 bytes; registered failure mode)
    out.push_str(".Losbadmsg:\n    .byte 73,110,116,101,114,110,97,108,32,101,114,114,111,114,58,32,79,83,32,102,114,101,101,32,102,97,105,108,101,100,10\n");
    out.push_str(".Lregbadmsg:\n    .byte 73,110,116,101,114,110,97,108,32,101,114,114,111,114,58,32,97,108,108,111,99,97,116,105,111,110,32,114,101,103,105,115,116,114,121,32,109,105,115,109,97,116,99,104,10\n");
    out.push_str(".Ltypemsg:\n    .byte 84,121,112,101,32,101,114,114,111,114,58,32,78,73,76,32,117,115,101,100,32,97,115,32,97,32,110,117,109,98,101,114,10\n");
    out.push_str(".Lasizenegmsg:\n    .byte 65,83,105,122,101,58,32,110,101,103,97,116,105,118,101,32,115,105,122,101,10\n");
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

# hbc_print_dyn: %rax = tag, %rdx = payload. Prints NIL (no field width,
# probe n1) for tag 1; otherwise the numeric payload via hbc_print_i64.
hbc_print_dyn:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    test %rax, %rax
    jz 8f
    lea .Lnilmsg(%rip), %rax
    mov $3, %edx
    call hbc_print_str
    jmp 9f
8:  mov %rdx, %rax
    call hbc_print_i64
9:  leave
    ret

# hbc_dyn_to_i64: %rax = tag, %rdx = payload -> %rax = payload. NIL here is
# a Harbour type error; see the linux copy for the failure-mode note.
hbc_dyn_to_i64:
    test %rax, %rax
    jnz hbc_type_error
    mov %rdx, %rax
    ret

# hbc_dyn_eq: %rax/%rdx = lhs tag/payload, %rcx/%r8 = rhs tag/payload ->
# %rax = 1/0. NIL = NIL is .T.; NIL against a payload is .F. (probes n1-n3).
hbc_dyn_eq:
    cmp %rcx, %rax
    jne 8f
    test %rax, %rax
    jnz 9f
    cmp %r8, %rdx
    jne 8f
9:  mov $1, %eax
    ret
8:  xor %eax, %eax
    ret

# hbc_type_error: NIL used as a number at runtime. Reached via a JUMP from
# hbc_dyn_to_i64, so force 16-byte alignment before calling out (noreturn).
hbc_type_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ltypemsg(%rip), %rax
    mov $33, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

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

# ---- dynamic array heap (kernel32 Heap API) ----
# hbc_alloc: rdi = bytes -> rax = base. HeapAlloc failure returns NULL.
hbc_alloc:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    mov %rdi, %r8
    mov %rdi, 32(%rsp)
    call GetProcessHeap
    mov %rax, %rcx
    xor %edx, %edx
    call HeapAlloc
    test %rax, %rax
    jz hbc_oom
@REG_ALLOC_W@    incq hbc_mem_allocs(%rip)
    leave
    ret

# hbc_oom / hbc_asize_neg: print the message, exit 1 (noreturn)
# Entered via a conditional JUMP, not a call: the stack alignment at entry
# is the caller's, so force 16-byte alignment explicitly before calling out.
hbc_oom:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Loommsg(%rip), %rax
    mov $14, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_asize_neg:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lasizenegmsg(%rip), %rax
    mov $21, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_free: rdi = data pointer (non-null), rsi = element size (unused:
# HeapFree needs the base pointer, not the length).
hbc_free:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
@REG_FREE_W@    sub $8, %rdi
    mov %rdi, %r8
    call GetProcessHeap
    mov %rax, %rcx
    xor %edx, %edx
    call HeapFree
    # HeapFree result: nonzero on success - a registry match alone does
    # not prove the OS released the block.
    test %rax, %rax
    jz hbc_os_bad
    incq hbc_mem_frees(%rip)
    leave
    ret

@REG_BAD_W@# hbc_os_bad: HeapFree reported failure (noreturn). Entered via JUMP.
hbc_os_bad:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Losbadmsg(%rip), %rax
    mov $31, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_free2: rdi = outer data pointer (non-null), rsi = outer length.
hbc_free2:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $56, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    xor %r13, %r13
71: cmp %r12, %r13
    jge 72f
    mov %r13, %rax
    shl $4, %rax
    mov (%rbx,%rax), %rdi
    test %rdi, %rdi
    jz 73f
    mov $16, %esi
    call hbc_free
73: inc %r13
    jmp 71b
72: mov %rbx, %rdi
    mov $16, %esi
    call hbc_free
    add $56, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_aadd: rdi = slot address (ptr,len), rsi = element size (8 or 16),
# rdx = pointer to the new element. A failed allocation leaves the old
# block and the slot untouched.
hbc_aadd:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    sub $48, %rsp
    mov %rdi, %rbx
    mov %rsi, %r14
    mov %rdx, %r12
    mov (%rbx), %r13
    xor %ecx, %ecx
    test %r13, %r13
    jz 51f
    mov -8(%r13), %rcx
51: cmp 8(%rbx), %rcx
    jg 54f
    mov $4, %eax
    test %rcx, %rcx
    jz 52f
    lea (%rcx,%rcx), %rax
52: mov $0x2000000000000000, %rdx
    cmp %rdx, %rax
    jae hbc_oom
    mov %rcx, -40(%rbp)
    mov %rax, -48(%rbp)
    mov %rax, %rdi
    imul %r14, %rdi
    jo hbc_oom
    add $8, %rdi
    jc hbc_oom
    call hbc_alloc
    mov -48(%rbp), %rdx
    mov %rdx, (%rax)
    test %r13, %r13
    jz 53f
    mov 8(%rbx), %r8
    xor %r9, %r9
55: cmp %r8, %r9
    jge 56f
    mov %r9, %r10
    imul %r14, %r10
    mov (%r13,%r10), %rcx
    mov %rcx, 8(%rax,%r10)
    cmp $16, %r14
    jne 57f
    mov 8(%r13,%r10), %rcx
    mov %rcx, 16(%rax,%r10)
57: inc %r9
    jmp 55b
56: mov %rax, -40(%rbp)
    mov %r13, %rdi
    mov %r14, %rsi
    call hbc_free
    mov -40(%rbp), %rax
53: add $8, %rax
    mov %rax, (%rbx)
    mov %rax, %r13
54: mov 8(%rbx), %rcx
    mov %rcx, %r10
    imul %r14, %r10
    mov (%r12), %rax
    mov %rax, (%r13,%r10)
    cmp $16, %r14
    jne 58f
    mov 8(%r12), %rax
    mov %rax, 8(%r13,%r10)
58: inc %rcx
    mov %rcx, 8(%rbx)
    add $48, %rsp
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_asize: rdi = slot address, rsi = new length, rdx = element size,
# rcx = deep flag (1: free removed children on shrink). Grown i64 slots
# read NIL (probe e1); a DArr2 grows with the empty (null, 0) child.
hbc_asize:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $56, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r14
    mov %rcx, %r15
    test %r12, %r12
    js hbc_asize_neg
    mov 8(%rbx), %rcx
    cmp %rcx, %r12
    jle 59f
    mov (%rbx), %r13
    xor %edx, %edx
    test %r13, %r13
    jz 61f
    mov -8(%r13), %rdx
61: cmp %rdx, %r12
    jle 63f
    mov $4, %eax
    test %rdx, %rdx
    jz 62f
    lea (%rdx,%rdx), %rax
62: cmp %rax, %r12
    jle 64f
    mov %r12, %rax
64: mov $0x2000000000000000, %r8
    cmp %r8, %rax
    jae hbc_oom
    mov %rdx, -48(%rbp)
    mov %rax, -56(%rbp)
    mov %rax, %rdi
    imul %r14, %rdi
    jo hbc_oom
    add $8, %rdi
    jc hbc_oom
    call hbc_alloc
    mov -56(%rbp), %rdx
    mov %rdx, (%rax)
    mov 8(%rbx), %r8
    test %r13, %r13
    jz 65f
    xor %r9, %r9
66: cmp %r8, %r9
    jge 69f
    mov %r9, %r10
    imul %r14, %r10
    mov (%r13,%r10), %rcx
    mov %rcx, 8(%rax,%r10)
    cmp $16, %r14
    jne 60f
    mov 8(%r13,%r10), %rcx
    mov %rcx, 16(%rax,%r10)
60: inc %r9
    jmp 66b
69: mov %rax, -48(%rbp)
    mov %r13, %rdi
    mov %r14, %rsi
    call hbc_free
    mov -48(%rbp), %rax
65: add $8, %rax
    mov %rax, (%rbx)
    mov %rax, %r13
63: mov 8(%rbx), %rcx
67: cmp %r12, %rcx
    jge 68f
    mov %rcx, %r10
    shl $4, %r10
    test %r15, %r15
    jnz 79f
    # flat dynamic arrays grow with NIL {1, 0} (probe e1: grown slots read NIL)
    movq $1, (%r13,%r10)
    movq $0, 8(%r13,%r10)
    jmp 74f
79: # a DArr2 grows with the empty child (null, 0) - m-probes, unchanged
    movq $0, (%r13,%r10)
    movq $0, 8(%r13,%r10)
74: inc %rcx
    jmp 67b
68: mov %r12, 8(%rbx)
    jmp 75f
59: # shrink: free the removed children when deep. The counter lives on the
# stack: kernel32 may clobber the volatile r9 across the hbc_free call.
    test %r15, %r15
    jz 76f
    mov (%rbx), %r13
    mov %r12, -48(%rbp)
77: mov -48(%rbp), %r9
    cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    mov (%r13,%r10), %rdi
    test %rdi, %rdi
    jz 78f
    mov $16, %esi
    call hbc_free
78: incq -48(%rbp)
    jmp 77b
76: mov %r12, 8(%rbx)
75: add $56, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

    .data
    .align 8
hbc_mem_allocs: .quad 0
hbc_mem_frees:  .quad 0
@REG_DATA@    .text
"#;

#[derive(Clone, Copy, PartialEq)]
enum Target { Linux, Windows }

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut pos: Vec<&String> = Vec::new();
    let mut target = Target::Linux;
    let mut incdirs: Vec<String> = Vec::new();
    let mut instrument = false;
    let mut ai = 1;
    while ai < args.len() {
        let a = &args[ai];
        match a.as_str() {
            "--target=linux" => target = Target::Linux,
            "--target=windows" => target = Target::Windows,
            "--instrument" => instrument = true,
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
        let dyn_names = prescan_dyn(f, &sigs, &ptys);
        let res = check_stmts(&f.stmts, &mut env, &sigs, &mut ret, None, &mut top_exits, &dyn_names);
        f.dyn_names = dyn_names;
        if let Err(m) = res {
            eprintln!("error: {}", m);
            process::exit(1);
        }
        if f.name == "main" {
            if has_value_return(&f.stmts) {
                eprintln!("error: main must end with `return` or `return nil` in this PoC");
                process::exit(1);
            }
            ret = None; // main's own `return nil` is NIL, never a usable value
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
    let out = emit_asm(&funcs, &sigs, target, instrument);

    fs::write(pos[1], out)
        .unwrap_or_else(|e| { eprintln!("cannot write {}: {}", args[2], e); process::exit(2); });
    println!("{} -> {} ({} functions)", args[1], args[2], funcs.len());
}
