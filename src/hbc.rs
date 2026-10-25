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
enum Ty { I64, Str, Bool, Arr(usize), Block(usize), DArr, DArrU, DArr2, DArr3, DArrS, StrOwn, Dyn, Hash, DArrRef, DArrRef2 }

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
    KwFor, KwTo, KwStep, KwNext, KwEach, KwIn,
    EqEq,       // == (object identity, oracle cl7/cl19)
    Colon,      // : (message send, o:name)
    ColonColon, // :: (self member, inside a method)
    KwCreate, KwClass, KwEndclass, KwMethod, KwData, KwInherit, KwConstructor, KwInit, KwSelfTok,
}

#[derive(Clone, Copy, PartialEq, Debug)]
enum CmpOp { Eq, EqEq, Ne, Lt, Le, Gt, Ge } // EqEq: == object identity (oracles cl7/cl19)

static BLOCK_ID: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
fn new_block_id() -> usize { BLOCK_ID.fetch_add(1, std::sync::atomic::Ordering::SeqCst) }

// Unique-label counter for inline branches emitted by codegen: every
// emission of the same construct gets a fresh id, so two comparisons in
// one function (or one construct emitted twice) can never collide.
// Fixed numeric labels caused two silent miscompares (iteration 33b).
static LBL_ID: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
fn fresh_lbl() -> usize { LBL_ID.fetch_add(1, std::sync::atomic::Ordering::SeqCst) }

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
                    Some(&(_, ':')) => { toks.push(Tok::ColonColon); it.next(); }
                    _ => toks.push(Tok::Colon),
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
                    "each" => Tok::KwEach,
                    "in" => Tok::KwIn,
                    "to" => Tok::KwTo,
                    "step" => Tok::KwStep,
                    "next" => Tok::KwNext,
                    "create" => Tok::KwCreate,
                    "class" => Tok::KwClass,
                    "endclass" => Tok::KwEndclass,
                    "method" => Tok::KwMethod,
                    "data" => Tok::KwData,
                    "inherit" => Tok::KwInherit,
                    "constructor" => Tok::KwConstructor,
                    "init" => Tok::KwInit,
                    "self" => Tok::KwSelfTok,
                    _ => Tok::Ident(id),
                });
            }
            '=' => {
                it.next();
                match it.peek() {
                    Some(&(_, '>')) => { toks.push(Tok::FatArrow); it.next(); }
                    Some(&(_, '=')) => { toks.push(Tok::EqEq); it.next(); }
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
    Index2(String, Box<Expr>, Box<Expr>),
    Index3(String, Box<Expr>, Box<Expr>, Box<Expr>), // a[i][j] / a[i,j] on a DArr2 (probe m1/m2)
    BlockLit(usize, Vec<String>, Vec<Expr>), // {|p1, p2| e1, e2} -> last (probes c1-c5)
    DArrNew,                     // {} : empty DYNAMIC array (probes d1, e4)
    SelfObj,                     // Self (oracle cl2: return Self chains)
    SelfGet(String),             // ::name inside a method (class parser landed; codegen pending)
    Send(Box<Expr>, String, Vec<Expr>), // obj:name(args) / obj:name - Harbour message send (cl1/cl10)
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
    ArrSet3(usize, String, Expr, Expr, Expr, Expr), // a[i][j][k] := expr
    SelfSet(usize, String, Expr),       // ::name := expr
    SendSet(usize, Expr, String, Expr), // obj:name := expr (simple receiver)
    SendStmt(usize, Expr),              // obj:name(args) used as a statement
    AAdd(usize, String, Expr),  // AAdd(a, x): grow dynamic array in place (probe d1)
    AAddSub(usize, String, Expr, Expr), // AAdd(a[i], x): grow the subarray (probe m5)
    ASizeSub(usize, String, Expr, Expr), // ASize(a[i], n): resize the subarray
    AAddSub2(usize, String, Expr, Expr, Expr), // AAdd(a[i][j], x): grow the innermost subarray (oracle pr8)
    ASizeSub2(usize, String, Expr, Expr, Expr), // ASize(a[i][j], n): resize the innermost subarray
    ASize(usize, String, Expr), // ASize(a, n): resize in place (probe d3)
    Exit(usize),                 // exit: leave the innermost loop
    Loop(usize),                 // loop: jump to the next iteration of the innermost loop
    For(usize, String, Expr, Expr, i64, Vec<Stmt>), // line, var, start, end, step (non-zero literal), body
    ForEach(usize, String, Expr, Vec<Stmt>), // line, var, collection (borrowed), body
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
        // Message-send postfix (oracles cl1/cl2/cl10): o:name, o:name(args),
        // chains o:M():N(). o:name without parens is ALSO a send - the
        // method wins over a same-named DATA (cl10), DATA read is the
        // fallback; both resolve in codegen, not here.
        let mut e = self.factor_primary()?;
        while self.peek() == Some(&Tok::Colon) {
            self.pos += 1;
            let name = match self.bump() {
                Some(Tok::Ident(id)) => { check_ident(&id, self.n)?; id }
                other => return Err(format!("line {}: expected a member name after `:`, got {:?}", self.n, other)),
            };
            let mut args: Vec<Expr> = Vec::new();
            if self.peek() == Some(&Tok::LParen) {
                self.pos += 1;
                if self.peek() != Some(&Tok::RParen) {
                    loop {
                        args.push(self.expr()?);
                        match self.bump() {
                            Some(Tok::Comma) => continue,
                            Some(Tok::RParen) => break,
                            other => return Err(format!("line {}: expected `,` or `)` in the message arguments, got {:?}", self.n, other)),
                        }
                    }
                } else {
                    self.pos += 1;
                }
            }
            e = Expr::Send(Box::new(e), name, args);
        }
        Ok(e)
    }
    fn factor_primary(&mut self) -> Result<Expr, String> {
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
            Some(Tok::KwSelfTok) => Ok(Expr::SelfObj),
            Some(Tok::ColonColon) => {
                match self.bump() {
                    Some(Tok::Ident(id)) => { check_ident(&id, self.n)?; Ok(Expr::SelfGet(id)) }
                    other => return Err(format!("line {}: expected a member name after `::`, got {:?}", self.n, other)),
                }
            }
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
                            self.pos += 1;
                            let idx3 = self.expr()?;
                            if self.bump() != Some(Tok::RBracket) {
                                return Err(format!("line {}: expected `]` after the third array index", self.n));
                            }
                            if self.peek() == Some(&Tok::LBracket) {
                                return Err(format!("line {}: more than three index levels are not in this increment", self.n));
                            }
                            return Ok(Expr::Index3(id, Box::new(idx), Box::new(idx2), Box::new(idx3)));
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
            Some(Tok::EqEq) => Some(CmpOp::EqEq),
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
            Tok::KwMethod | Tok::KwCreate => return Ok(()),
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
                // `for each x in <collection>`: Harbour REQUIRES the EACH
                // keyword - `for x in a` is its E0030 syntax error
                // (oracle hk17). Iterates array elements and hash VALUES
                // (hk17/hk18/hk26).
                if toks.get(1) == Some(&Tok::KwEach) {
                    let id = match toks.get(2) {
                        Some(Tok::Ident(id)) => { check_ident(id, n)?; id.clone() }
                        _ => return Err(format!("line {}: expected `for each <var> in <collection>`", n)),
                    };
                    if toks.get(3) != Some(&Tok::KwIn) || toks.len() < 5 {
                        return Err(format!("line {}: expected `for each <var> in <collection>`", n));
                    }
                    let coll = parse_expr_tokens(toks[4..].to_vec(), n)?;
                    *i += 1;
                    let mut body = Vec::new();
                    parse_stmts(lines, i, &mut body, depth + 1)?;
                    if *i >= lines.len() || lines[*i].1[0] != Tok::KwNext {
                        return Err(format!("line {}: `for each` without `next`", n));
                    }
                    if lines[*i].1.len() != 1 {
                        return Err(format!("line {}: `next` takes no expression", n));
                    }
                    *i += 1;
                    out.push(Stmt::ForEach(n, id, coll, body));
                    continue;
                }
                if toks.iter().any(|t| *t == Tok::KwIn) {
                    return Err(format!("line {}: Harbour requires EACH here: `for each <var> in <collection>` (without EACH it is its E0030 syntax error, oracle hk17)", n));
                }
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
                        if rb2 == 0 || toks.len() <= rb2 + 1 {
                            return Err(format!("line {}: expected `name[idx][idx2] := expr`", n));
                        }
                        if toks[rb2 + 1] == Tok::LBracket {
                            // a[i][j][k] := v
                            let mut depth3 = 0i32;
                            let mut rb3 = 0usize;
                            for (p, t) in toks.iter().enumerate().skip(rb2 + 1) {
                                match t {
                                    Tok::LBracket | Tok::LParen => depth3 += 1,
                                    Tok::RBracket | Tok::RParen => {
                                        depth3 -= 1;
                                        if depth3 == 0 { rb3 = p; break; }
                                    }
                                    _ => {}
                                }
                            }
                            if rb3 == 0 || toks.len() <= rb3 + 1 || toks[rb3 + 1] != Tok::Assign {
                                return Err(format!("line {}: expected `name[idx][idx2][idx3] := expr`", n));
                            }
                            let i1 = parse_expr_tokens(toks[2..rb].to_vec(), n)?;
                            let i2 = parse_expr_tokens(toks[rb + 2..rb2].to_vec(), n)?;
                            let i3 = parse_expr_tokens(toks[rb2 + 2..rb3].to_vec(), n)?;
                            let e = parse_expr_tokens(toks[rb3 + 2..].to_vec(), n)?;
                            out.push(Stmt::ArrSet3(n, id, i1, i2, i3, e));
                            *i += 1;
                            continue;
                        }
                        if toks[rb2 + 1] != Tok::Assign {
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
                        _ if matches!(head.first(), Some(Tok::Ident(_)))
                            && head.len() >= 7
                            && matches!(head[1], Tok::LBracket)
                            && matches!(head[head.len() - 1], Tok::RBracket) => {
                            // AAdd/ASize on a[i][j]: split the two bracket
                            // groups by their own depth so index expressions
                            // keep full token freedom.
                            let v = match &head[0] { Tok::Ident(v) => v.clone(), _ => unreachable!() };
                            check_ident(&v, n)?;
                            let mut depth = 0i32;
                            let mut rb = 0usize;
                            for (p, tk) in head.iter().enumerate().skip(1) {
                                match tk {
                                    Tok::LBracket | Tok::LParen => depth += 1,
                                    Tok::RBracket | Tok::RParen => {
                                        depth -= 1;
                                        if depth == 0 { rb = p; break; }
                                    }
                                    _ => {}
                                }
                            }
                            if rb == head.len() - 1 {
                                // One bracket group whose index itself
                                // contains brackets (a[b[1]]): AAddSub.
                                let idx = parse_expr_tokens(head[2..rb].to_vec(), n)?;
                                if is_builtin(&id, "aadd") {
                                    out.push(Stmt::AAddSub(n, v, idx, e));
                                } else {
                                    out.push(Stmt::ASizeSub(n, v, idx, e));
                                }
                                *i += 1;
                                continue;
                            }
                            if rb <= 2 || rb + 1 >= head.len() - 1 || !matches!(head[rb + 1], Tok::LBracket) {
                                return Err(format!("line {}: the first argument of `{}` must be a variable, a[i] or a[i][j]", n, id));
                            }
                            let i1 = parse_expr_tokens(head[2..rb].to_vec(), n)?;
                            let i2 = parse_expr_tokens(head[rb + 2..head.len() - 1].to_vec(), n)?;
                            if is_builtin(&id, "aadd") {
                                out.push(Stmt::AAddSub2(n, v, i1, i2, e));
                            } else {
                                out.push(Stmt::ASizeSub2(n, v, i1, i2, e));
                            }
                        }
                        [Tok::Ident(v), Tok::LBracket, rest @ .., Tok::RBracket] if !rest.is_empty() && !rest.iter().any(|t| matches!(t, Tok::LBracket | Tok::RBracket)) => {
                            check_ident(v, n)?;
                            let idx = parse_expr_tokens(rest.to_vec(), n)?;
                            if is_builtin(&id, "aadd") {
                                out.push(Stmt::AAddSub(n, v.clone(), idx, e));
                            } else {
                                out.push(Stmt::ASizeSub(n, v.clone(), idx, e));
                            }
                        }
                        _ => return Err(format!("line {}: the first argument of `{}` must be a variable, a[i] or a[i][j]", n, id)),
                    }
                    *i += 1;
                    continue;
                }
                if toks.len() >= 3 && toks[1] == Tok::Colon {
                    // o:name := e (simple receiver) or o:M(...) / o:name as
                    // a statement whose value is discarded (oracle cl2).
                    if toks.len() >= 4 {
                        if let [_, Tok::Colon, Tok::Ident(mname), Tok::Assign, rest @ ..] = toks.as_slice() {
                            check_ident(mname, n)?;
                            let e = parse_expr_tokens(rest.to_vec(), n)?;
                            out.push(Stmt::SendSet(n, Expr::Var(id.clone()), mname.clone(), e));
                            *i += 1;
                            continue;
                        }
                        let e = parse_expr_tokens(toks.to_vec(), n)?;
                        match e {
                            Expr::Send(..) => { out.push(Stmt::SendStmt(n, e)); *i += 1; continue; }
                            _ => return Err(format!("line {}: message-send statement not in the subset", n)),
                        }
                    }
                }
                if toks.len() < 3 || toks[1] != Tok::Assign {
                    return Err(format!("line {}: statement not in the subset (identifier-led line is not an assignment; expected `name := expr`)", n));
                }
                check_ident(&id, n)?;
                let e = parse_expr_tokens(toks[2..].to_vec(), n)?;
                out.push(Stmt::Assign(n, id, e));
                *i += 1;
            }
            Tok::ColonColon => {
                // ::name := e (statement form inside a method body)
                match toks.as_slice() {
                    [Tok::ColonColon, Tok::Ident(mname), Tok::Assign, rest @ ..] => {
                        check_ident(mname, n)?;
                        let e = parse_expr_tokens(rest.to_vec(), n)?;
                        out.push(Stmt::SelfSet(n, mname.clone(), e));
                        *i += 1;
                    }
                    _ => {
                        let e = parse_expr_tokens(toks.to_vec(), n)?;
                        match e {
                            Expr::Send(..) | Expr::SelfGet(_) | Expr::SelfObj => { out.push(Stmt::SendStmt(n, e)); *i += 1; }
                            _ => return Err(format!("line {}: `::` statement not in the subset (expected `::name := expr`)", n)),
                        }
                    }
                }
            }
            t => return Err(format!("line {}: statement not in the subset ({:?})", n, t)),
        }
    }
    Ok(())
}

// Class surface (parser landed; runtime representation pending the user's
// decision): CREATE CLASS / DATA / METHOD / INHERIT declarations, METHOD
// ... CLASS definitions. Semantics probed in sondas_ac/classes (cl1-cl21).
struct ClassDecl {
    name: String,
    parent: Option<String>,
    datas: Vec<(String, Option<Expr>)>,           // DATA name [INIT expr]
    methods: Vec<(String, Vec<String>, bool)>,    // name, params, is_constructor
}
struct MethodDef {
    class_name: String,
    f: Func,
}
struct Prog {
    funcs: Vec<Func>,
    classes: Vec<ClassDecl>,
    methods: Vec<MethodDef>,
}

fn parse(src: &str) -> Result<Prog, String> {
    let mut lines: Vec<(usize, Vec<Tok>)> = Vec::new();
    for (idx, raw) in src.lines().enumerate() {
        let n = idx + 1;
        let toks = tokenize(raw, n)?;
        if !toks.is_empty() { lines.push((n, toks)); }
    }

    let mut funcs: Vec<Func> = Vec::new();
    let mut classes: Vec<ClassDecl> = Vec::new();
    let mut methods: Vec<MethodDef> = Vec::new();
    let mut i = 0usize;
    while i < lines.len() {
        let (n, toks) = &lines[i];
        let n = *n;
        // CREATE CLASS Name [INHERIT Base] ... ENDCLASS
        if toks[0] == Tok::KwCreate {
            let (cname, parent) = match toks.as_slice() {
                [Tok::KwCreate, Tok::KwClass, Tok::Ident(c)] => { check_ident(c, n)?; (c.clone(), None) }
                [Tok::KwCreate, Tok::KwClass, Tok::Ident(c), Tok::KwInherit, Tok::Ident(b)] => {
                    check_ident(c, n)?; check_ident(b, n)?; (c.clone(), Some(b.clone()))
                }
                [Tok::KwCreate, Tok::KwClass, Tok::Ident(_), Tok::KwInherit, Tok::Ident(_), Tok::Comma, ..] => {
                    return Err(format!("line {}: multiple inheritance is not in this increment (oracle cl21: Harbour accepts it)", n));
                }
                _ => return Err(format!("line {}: expected `CREATE CLASS Name [INHERIT Base]`", n)),
            };
            if classes.iter().any(|c| c.name == cname) {
                return Err(format!("line {}: duplicate class `{}`", n, cname));
            }
            i += 1;
            let mut decl = ClassDecl { name: cname, parent, datas: Vec::new(), methods: Vec::new() };
            loop {
                if i >= lines.len() { return Err(format!("class `{}` without ENDCLASS", decl.name)); }
                let (ln, lt) = &lines[i];
                let ln = *ln;
                match lt.as_slice() {
                    [Tok::KwEndclass] => { i += 1; break; }
                    [Tok::KwData, Tok::Ident(d)] => { check_ident(d, ln)?; decl.datas.push((d.clone(), None)); i += 1; }
                    [Tok::KwData, Tok::Ident(d), Tok::KwInit, rest @ ..] => {
                        check_ident(d, ln)?;
                        decl.datas.push((d.clone(), Some(parse_expr_tokens(rest.to_vec(), ln)?)));
                        i += 1;
                    }
                    [Tok::KwMethod, Tok::Ident(m), Tok::LParen, rest @ .., Tok::RParen] => {
                        check_ident(m, ln)?;
                        let ps = parse_param_names(rest, ln)?;
                        decl.methods.push((m.clone(), ps, false));
                        i += 1;
                    }
                    [Tok::KwMethod, Tok::Ident(m), Tok::LParen, rest @ .., Tok::RParen, Tok::KwConstructor] => {
                        check_ident(m, ln)?;
                        let ps = parse_param_names(rest, ln)?;
                        decl.methods.push((m.clone(), ps, true));
                        i += 1;
                    }
                    [Tok::Ident(scope), Tok::Colon] | [Tok::Ident(scope)] if matches!(scope.to_ascii_lowercase().as_str(), "protected" | "hidden" | "exported") => {
                        return Err(format!("line {}: class scopes ({}:, ...) are not in this increment - Harbour enforces them at runtime (oracle cl8)", ln, scope));
                    }
                    _ => return Err(format!("line {}: class member line not in the subset (DATA / METHOD / ENDCLASS)", ln)),
                }
            }
            classes.push(decl);
            continue;
        }
        // METHOD Name(params) CLASS CName ... return ...
        if toks[0] == Tok::KwMethod {
            let (mname, params, cname) = match toks.as_slice() {
                [Tok::KwMethod, Tok::Ident(m), Tok::LParen, rest @ .., Tok::RParen, Tok::KwClass, Tok::Ident(c)] => {
                    check_ident(m, n)?; check_ident(c, n)?;
                    (m.clone(), parse_param_names(rest, n)?, c.clone())
                }
                [Tok::KwMethod, Tok::Ident(m), Tok::LParen, Tok::RParen, Tok::KwClass, Tok::Ident(c)] => {
                    check_ident(m, n)?; check_ident(c, n)?;
                    (m.clone(), Vec::new(), c.clone())
                }
                _ => return Err(format!("line {}: expected `METHOD Name(params) CLASS ClassName`", n)),
            };
            if !classes.iter().any(|c| c.name == cname) {
                return Err(format!("line {}: method `{}` defined for unknown class `{}`", n, mname, cname));
            }
            i += 1;
            let mut f = Func { name: format!("{}__{}", cname, mname), params, ret: None, stmts: Vec::new(), dyn_names: std::collections::HashSet::new() };
            parse_stmts(&lines, &mut i, &mut f.stmts, 0)?;
            if i >= lines.len() || lines[i].1[0] != Tok::KwReturn {
                return Err(format!("method `{}` of `{}` without closing return", mname, cname));
            }
            let (rn, rt) = &lines[i];
            let stmt = match rt.len() {
                1 => Stmt::Ret(*rn, None),
                2 if rt[1] == Tok::KwNil => Stmt::Ret(*rn, None),
                _ => Stmt::Ret(*rn, Some(parse_expr_tokens(rt[1..].to_vec(), *rn)?)),
            };
            f.stmts.push(stmt);
            methods.push(MethodDef { class_name: cname, f });
            i += 1;
            continue;
        }
        if toks[0] != Tok::KwFunction {
            return Err(format!("line {}: code outside a function", n));
        }
        let (name, params) = match toks.as_slice() {
            [Tok::KwFunction, Tok::Ident(id), Tok::LParen, Tok::RParen] => {
                check_ident(id, n)?;
                (id.clone(), Vec::new())
            }
            [Tok::KwFunction, Tok::Ident(id), Tok::LParen, rest @ .., Tok::RParen] if !rest.is_empty() => {
                check_ident(id, n)?;
                let mut ps: Vec<String> = Vec::new();
                for (k, t) in rest.iter().enumerate() {
                    let want_ident = k % 2 == 0;
                    match (want_ident, t) {
                        (true, Tok::Ident(p)) => {
                            check_ident(p, n)?;
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
    Ok(Prog { funcs, classes, methods })
}

// Comma-separated parameter names out of a method declaration's token
// slice (same rules as `function name(a, b)`).
fn parse_param_names(rest: &[Tok], n: usize) -> Result<Vec<String>, String> {
    let mut ps: Vec<String> = Vec::new();
    for (k, tk) in rest.iter().enumerate() {
        match (k % 2 == 0, tk) {
            (true, Tok::Ident(p)) => {
                check_ident(p, n)?;
                if ps.iter().any(|q| q == p) { return Err(format!("line {}: duplicate parameter `{}`", n, p)); }
                ps.push(p.clone());
            }
            (false, Tok::Comma) => {}
            _ => return Err(format!("line {}: expected comma-separated parameters", n)),
        }
    }
    Ok(ps)
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
    // Per-parameter calling-convention flags for array parameters.
    // borrowed[i]: some call site passes a[i] (a MIDDLE cell of an array of
    // arrays) - the callee receives the cell's ADDRESS and borrows it for
    // the call (oracles hk73/hk78/hk86/hk87). arr_moved[i]: some call site
    // moves an owned array variable in (the established contract). The two
    // modes exclude each other for the same parameter.
    borrowed: Vec<bool>,
    arr_moved: Vec<bool>,
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
    // Evidence that an expression is a string at pin time: a literal, a
    // literal-initialized local, or a call whose signature returns one.
    fn str_evidence(e: &Expr, lit: &[(String, Ty)], sigs: &[Sig]) -> bool {
        match e {
            Expr::Str(_) => true,
            Expr::Var(v) => lit.iter().any(|(x, t)| x == v && matches!(*t, Ty::Str | Ty::StrOwn)),
            Expr::Call(id, _) => sigs.iter().any(|s| s.name == *id && matches!(s.ret, Some(Ty::Str) | Some(Ty::StrOwn))),
            _ => false,
        }
    }
    fn setpin(pin: &mut Vec<Option<Ty>>, idx: usize, ty: Ty, n: usize) -> Result<(), String> {
        fn tname(t: Ty) -> &'static str {
            match t {
                Ty::I64 => "an integer",
                Ty::Str => "a string",
                Ty::Dyn => "a NIL-capable value",
                Ty::StrOwn => "a string",
                Ty::DArrS => "an array of strings",
                Ty::Hash => "a hash",
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
            // Whole-array evidence (len(p)) and nested evidence (p[i][j],
            // len(p[i])) describe the same array of arrays (oracle pr1).
            Some(t) if matches!((t, ty), (Ty::DArr, Ty::DArr2) | (Ty::DArr2, Ty::DArr)) => {
                pin[idx] = Some(Ty::DArr2);
                Ok(())
            }
            Some(t) if matches!((t, ty), (Ty::DArr, Ty::DArr3) | (Ty::DArr3, Ty::DArr) | (Ty::DArr2, Ty::DArr3) | (Ty::DArr3, Ty::DArr2)) => {
                pin[idx] = Some(Ty::DArr3);
                Ok(())
            }
            // Whole-array evidence (len(p) pins DArr) merges with
            // string-element evidence (AAdd(p, "x"), p[i] := "x", p[i] in
            // a string context): an array of strings (hb_HKeys shape).
            Some(t) if matches!((t, ty), (Ty::DArr, Ty::DArrS) | (Ty::DArrS, Ty::DArr)) => {
                pin[idx] = Some(Ty::DArrS);
                Ok(())
            }
            // len(p) pins a flat dynamic array and a string key pins a
            // hash; both layouts carry the count in the same word and
            // len() of a hash is its pair count (oracle hk11), so the
            // hash pin - the evidence that can tell the two apart - wins.
            Some(t) if matches!((t, ty), (Ty::DArr, Ty::Hash) | (Ty::Hash, Ty::DArr)) => {
                pin[idx] = Some(Ty::Hash);
                Ok(())
            }
            Some(t) => Err(format!("line {}: parameter used as both {} and {}", n, tname(t), tname(ty))),
        }
    }
    // Pin parameter vars appearing directly (not under a call) in e.
    fn pin_vars(f: &Func, e: &Expr, ty: Ty, pin: &mut Vec<Option<Ty>>, n: usize) -> Result<(), String> {
        // String parameters are uniformly OWNED strings (StrOwn): the
        // callee owns and frees its parameter, a rodata argument is
        // copied at the call boundary and an owned argument moves. One
        // kind keeps the freeing behaviour unambiguous.
        let ty = if ty == Ty::Str { Ty::StrOwn } else { ty };
        match e {
            Expr::Var(id) => { if let Some(i) = is_param(f, id) { setpin(pin, i, ty, n)?; } Ok(()) }
            Expr::Bin(_, a, b) => { pin_vars(f, a, Ty::I64, pin, n)?; pin_vars(f, b, Ty::I64, pin, n) }
            Expr::Cmp(_, a, b) => { pin_vars(f, a, ty, pin, n)?; pin_vars(f, b, ty, pin, n) }
            Expr::Call(_, _) => Ok(()), // call arguments pin via the callee's signature, not the outer context
            Expr::SelfObj | Expr::SelfGet(_) => Ok(()),
            Expr::Send(_, _, _) => Ok(()), // like a call: nothing pins through the message syntax
            Expr::ArrLit(es) => { for e in es { pin_vars(f, e, Ty::I64, pin, n)?; } Ok(()) }
            Expr::Index(id, ie) => {
                if is_param(f, id).is_some() {
                    // p["key"]: a literal string key pins a hash parameter
                    // (oracles hk11/hk12).
                    if matches!(**ie, Expr::Str(_)) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, n)?;
                    // p[i] in a string context (compared against a string
                    // or passed to a string parameter): the parameter is
                    // an array of strings (the hb_HKeys shape).
                    } else if ty == Ty::StrOwn {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArrS, pin, n)?;
                    } else {
                        return Err(format!("line {}: array parameters are not in this increment", n));
                    }
                }
                pin_vars(f, ie, Ty::I64, pin, n)
            }
            Expr::Index2(id, ie, ie2) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j] pins the parameter to an array of
                    // arrays (oracle pr1).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)
            }
            Expr::Index3(id, ie, ie2, ie3) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j][k] pins the parameter to an array of
                    // arrays of arrays (oracle pr9).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)?;
                pin_vars(f, ie3, Ty::I64, pin, n)
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
                        Expr::Index(v, _) if is_param(f, v).is_some() => {
                            // len(p[i]) borrows a child: the parameter is an
                            // array of arrays (oracle pr1).
                            pin_vars(f, &Expr::Var(v.clone()), Ty::DArr2, pin, n)?;
                        }
                        Expr::Index2(v, _, _) if is_param(f, v).is_some() => {
                            // len(p[i][j]) borrows two levels: the parameter
                            // is an array of arrays of arrays (oracle pr9).
                            pin_vars(f, &Expr::Var(v.clone()), Ty::DArr3, pin, n)?;
                        }
                        _ => pin_vars(f, &args[0], Ty::DArr, pin, n)?,
                    }
                    return walk(f, &args[0], sigs, lit, pin, n);
                }
                if is_builtin(id, "eval") {
                    // eval(b, a1..an) PINS a codeblock parameter (33p):
                    // the arity evidence is the argument count. Harbour
                    // tolerates EXTRA ignored arguments (probes c7/c7b);
                    // with a parameter the pin must match the block's
                    // arity exactly - a conservative named rejection, not
                    // a miscompile (registered limitation).
                    if !args.is_empty() {
                        pin_vars(f, &args[0], Ty::Block(args.len() - 1), pin, n)?;
                        // The extra eval arguments are integers here (same
                        // contract as the checker), so they pin I64 too.
                        for a in &args[1..] { pin_vars(f, a, Ty::I64, pin, n)?; }
                    }
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
                    // p["key"]: a string key pins a hash parameter
                    // (oracles hk11/hk12); a numeric index pins a DYNAMIC
                    // array (fixed arrays cannot be parameters here).
                    if str_evidence(ie, lit, sigs) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, n)?;
                    } else {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, n)?;
                    }
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, n)
            }
            Expr::Index2(id, ie, ie2) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j] pins the parameter to an array of
                    // arrays (oracle pr1).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, n)?;
                walk(f, ie2, sigs, lit, pin, n)
            }
            Expr::Index3(id, ie, ie2, ie3) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j][k] pins the parameter to an array of
                    // arrays of arrays (oracle pr9).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)?;
                pin_vars(f, ie3, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, n)?;
                walk(f, ie2, sigs, lit, pin, n)?;
                walk(f, ie3, sigs, lit, pin, n)
            }
            Expr::DArrNew => Ok(()),
            Expr::SelfObj | Expr::SelfGet(_) => Ok(()),
            Expr::Send(o, _, args) => {
                walk(f, o, sigs, lit, pin, n)?;
                for a in args { walk(f, a, sigs, lit, pin, n)?; }
                Ok(())
            }
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
                Stmt::ForEach(n, _, c, body) => {
                    walk(f, c, sigs, lit, pin, *n)?;
                    walk_stmts(f, body, sigs, lit, pin, nil_ret)?;
                }
                Stmt::ArrSet(n, id, ie, e) => {
                    // p["key"] := v: a string key pins a hash parameter
                    // (oracle hk11); p[i] := "x": a string value pins an
                    // array of strings; a scalar value pins a flat dynamic
                    // array (a borrowed middle array writes scalars this
                    // way - oracle hk86).
                    if str_evidence(ie, lit, sigs) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                    } else if str_evidence(e, lit, sigs) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArrS, pin, *n)?;
                    } else if is_param(f, id).is_some() {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, *n)?;
                    }
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::AAdd(n, id, e) => {
                    // AAdd's target is a dynamic array: pins a parameter.
                    // A string element pins an array of strings (the
                    // hb_HKeys shape); an ARRAY literal element pins one
                    // level deeper (a borrowed middle of a three-level
                    // array grows this way - oracle hk94); anything else
                    // keeps the flat pin.
                    if str_evidence(e, lit, sigs) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArrS, pin, *n)?;
                    } else if matches!(e, Expr::ArrLit(es) if es.iter().any(|x| matches!(x, Expr::ArrLit(_) | Expr::DArrNew))) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, *n)?;
                    } else if matches!(e, Expr::ArrLit(_)) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, *n)?;
                    } else {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, *n)?;
                        pin_vars(f, e, Ty::I64, pin, *n)?;
                    }
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::ASize(n, id, e) => {
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::AAddSub(n, id, ie, e) | Stmt::ASizeSub(n, id, ie, e) => {
                    if is_param(f, id).is_some() {
                        // AAdd/ASize on p[i] pins the parameter to an array
                        // of arrays; the callee owns the moved value.
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, *n)?;
                    }
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::ArrSet2(n, id, ie, ie2, e) => {
                    if is_param(f, id).is_some() {
                        // Writing p[i][j] pins the parameter to an array of
                        // arrays; the callee owns the moved value, so the
                        // caller cannot observe this write (see the
                        // registered sharing difference, probes pr2/pr5).
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, *n)?;
                    }
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, ie2, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, *n)?;
                    walk(f, ie2, sigs, lit, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::SelfSet(n, _, e) | Stmt::SendStmt(n, e) => {
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::SendSet(n, o, _, e) => {
                    walk(f, o, sigs, lit, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::AAddSub2(n, id, ie, ie2, e) | Stmt::ASizeSub2(n, id, ie, ie2, e) => {
                    if is_param(f, id).is_some() {
                        // AAdd/ASize on p[i][j] pins the parameter to an
                        // array of arrays of arrays; the callee owns the
                        // moved value.
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, *n)?;
                    }
                    // AAdd/ASize on a[i][j]: indices and value pin i64
                    // (oracle pr8: indices first, then the value).
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, ie2, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, *n)?;
                    walk(f, ie2, sigs, lit, pin, *n)?;
                    walk(f, e, sigs, lit, pin, *n)?;
                }
                Stmt::ArrSet3(n, id, ie, ie2, ie3, e) => {
                    if is_param(f, id).is_some() {
                        // Writing p[i][j][k] pins the parameter to an array
                        // of arrays of arrays; the callee owns the moved
                        // value, so the caller cannot observe this write
                        // (registered sharing difference, oracle pr9).
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, *n)?;
                    }
                    // a[i][j][k] := v: indices and value pin i64 (oracle
                    // pr6). Three-level parameters stay rejected, so no
                    // parameter pinning here.
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, ie2, Ty::I64, pin, *n)?;
                    pin_vars(f, ie3, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, *n)?;
                    walk(f, ie2, sigs, lit, pin, *n)?;
                    walk(f, ie3, sigs, lit, pin, *n)?;
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
            Stmt::While(_, _, b) | Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => any_nil_ret(b),
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

// Does expression `e` mention variable `name` anywhere (including index
// positions)? Used by the borrowed-argument aliasing check.
fn expr_mentions(e: &Expr, name: &str) -> bool {
    match e {
        Expr::Var(v) => v == name,
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => expr_mentions(a, name) || expr_mentions(b, name),
        Expr::Call(_, args) => args.iter().any(|a| expr_mentions(a, name)),
        Expr::Index(id, i) => id == name || expr_mentions(i, name),
        Expr::Index2(id, i, j) => id == name || expr_mentions(i, name) || expr_mentions(j, name),
        Expr::Index3(id, i, j, k) => id == name || expr_mentions(i, name) || expr_mentions(j, name) || expr_mentions(k, name),
        Expr::ArrLit(es) => es.iter().any(|e| expr_mentions(e, name)),
        _ => false,
    }
}

// Borrowed-parameter escape post-pass (iteration 33i). A parameter that
// some call site feeds as `a[i]` is BORROWED: the callee holds the child
// cell's address only for the duration of the call. It may be read
// (len(p), p[i], printing), written (p[i] := v) and resized (AAdd/ASize)
// in place - everything Harbour shows through its sharing (oracles
// hk73/hk78/hk86/hk87) - but it must NOT escape or be aliased: returning
// it, reassigning it, declaring over it, iterating it with FOR EACH
// (deferred) or passing it on to another function would outlive or
// duplicate the borrow. The body already type-checked under the owned
// shape (same allowed operations); this pass rejects the rest by
// whitelist.
fn borrow_expr_ok(e: &Expr, pname: &str) -> bool {
    match e {
        Expr::Var(v) => v != pname,
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => borrow_expr_ok(a, pname) && borrow_expr_ok(b, pname),
        Expr::Call(id, args) => {
            if is_builtin(id, "len") && args.len() == 1 && matches!(&args[0], Expr::Var(v) if v == pname) {
                return true; // len(p) borrows for the length only
            }
            if is_builtin(id, "valtype") && args.len() == 1 && matches!(&args[0], Expr::Var(v) if v == pname) {
                return true; // ValType(p) reads the tag only (hk88)
            }
            args.iter().all(|a| borrow_expr_ok(a, pname))
        }
        Expr::Index(_, ie) => borrow_expr_ok(ie, pname), // p[i] read: the base is the borrow itself
        Expr::Index2(_, a, b) => borrow_expr_ok(a, pname) && borrow_expr_ok(b, pname),
        Expr::Index3(_, a, b, c) => borrow_expr_ok(a, pname) && borrow_expr_ok(b, pname) && borrow_expr_ok(c, pname),
        Expr::ArrLit(es) => es.iter().all(|e| borrow_expr_ok(e, pname)),
        _ => true,
    }
}

fn borrow_stmts_ok(stmts: &[Stmt], pname: &str) -> Option<usize> {
    for s in stmts {
        let bad = match s {
            Stmt::Local(n, id, e) => {
                if id == pname || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::Print(n, items) => {
                let ok = items.iter().all(|i| matches!(i, Expr::Var(v) if v == pname) || borrow_expr_ok(i, pname));
                if ok { None } else { Some(*n) }
            }
            Stmt::Ret(n, Some(e)) => if borrow_expr_ok(e, pname) { None } else { Some(*n) },
            Stmt::Assign(n, id, e) => {
                if id == pname || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::ArrSet(n, id, ie, e) => {
                // p[i] := v writes THROUGH the borrow: allowed.
                if !borrow_expr_ok(ie, pname) || !borrow_expr_ok(e, pname) || (id == pname && false) { Some(*n) } else { None }
            }
            Stmt::ArrSet2(n, id, a, b, e) | Stmt::ArrSet3(n, id, a, b, e, ..) => {
                let _ = id;
                if !borrow_expr_ok(a, pname) || !borrow_expr_ok(b, pname) || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::SelfSet(_, _, e) | Stmt::SendStmt(_, e) => if borrow_expr_ok(e, pname) { None } else { Some(0) },
            Stmt::SendSet(n, r, _, e) => {
                if !borrow_expr_ok(r, pname) || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::AAdd(_, _, e) | Stmt::ASize(_, _, e) | Stmt::AAddSub(_, _, _, e) | Stmt::ASizeSub(_, _, _, e) => {
                if borrow_expr_ok(e, pname) { None } else { Some(0) }
            }
            Stmt::AAddSub2(_, _, a, b, e) | Stmt::ASizeSub2(_, _, a, b, e) => {
                if borrow_expr_ok(a, pname) && borrow_expr_ok(b, pname) && borrow_expr_ok(e, pname) { None } else { Some(0) }
            }
            Stmt::If(n, c, a, b) => {
                if !borrow_expr_ok(c, pname) { Some(*n) }
                else if let Some(m) = borrow_stmts_ok(a, pname) { Some(m) }
                else { borrow_stmts_ok(b, pname) }
            }
            Stmt::While(n, c, b) => {
                if !borrow_expr_ok(c, pname) { Some(*n) } else { borrow_stmts_ok(b, pname) }
            }
            Stmt::For(n, lv, a, b, _, body) => {
                if lv == pname || !borrow_expr_ok(a, pname) || !borrow_expr_ok(b, pname) { Some(*n) }
                else { borrow_stmts_ok(body, pname) }
            }
            Stmt::ForEach(n, lv, coll, body) => {
                // FOR EACH over (or into) a borrowed parameter: deferred.
                if lv == pname || !borrow_expr_ok(coll, pname) { Some(*n) }
                else { borrow_stmts_ok(body, pname) }
            }
            _ => None,
        };
        if let Some(m) = bad {
            return Some(if m == 0 { 1 } else { m });
        }
    }
    None
}

fn type_expr(e: &Expr, env: &mut [Local], sigs: &mut Vec<Sig>, n: usize) -> Result<Ty, String> {
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
                // Array(n[, m[, k]]) constructor (oracles m3/m10/a0/avar/pr7).
                // Harbour accepts more dimensions and answers Array() /
                // Array(-1) with dialogs that hang headless (BASE/1111,
                // BASE/1131): arity errors are compile errors here and a
                // negative dimension is a clean runtime error - registered
                // failure modes, same error conditions.
                if args.is_empty() {
                    return Err(format!("line {}: `Array` needs at least one dimension", n));
                }
                if args.len() > 3 {
                    return Err(format!("line {}: `Array` with more than three dimensions is not in this increment", n));
                }
                for a in args {
                    if !matches!(type_expr(a, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                        return Err(format!("line {}: `Array` dimensions are integers", n));
                    }
                }
                return Ok(match args.len() { 1 => Ty::DArr, 2 => Ty::DArr2, _ => Ty::DArr3 });
            }
            if is_builtin(id, "valtype") {
                // ValType(x): a one-character type tag (hk88-hk92). Borrows
                // its argument; the argument evaluates fully with its
                // effects (hk89). Only measured shapes: literals, plain
                // variables, and one/two-level casillas of measured roots.
                // Deeper indexing and other expressions are named
                // rejections - unmeasured, never inferred across depths.
                if args.len() != 1 {
                    return Err(format!("line {}: `ValType` takes one argument", n));
                }
                match &args[0] {
                    Expr::Int(_) | Expr::Str(_) | Expr::Nil | Expr::Var(_) => {}
                    Expr::Index(v, _) => {
                        match env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()) {
                            Some(Ty::DArr) | Some(Ty::DArr2) | Some(Ty::DArrRef) | Some(Ty::DArrS) => {}
                            _ => return Err(format!("line {}: `ValType` over this array depth is not measured in this PoC", n)),
                        }
                    }
                    Expr::Index2(v, _, _) => {
                        match env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()) {
                            Some(Ty::DArr2) => {}
                            _ => return Err(format!("line {}: `ValType` over this array depth is not measured in this PoC", n)),
                        }
                    }
                    _ => return Err(format!("line {}: `ValType` over this expression is not measured in this PoC", n)),
                }
                match &args[0] {
                    // a[i] on a DArr2 is a child-array casilla: ValType
                    // reads its pointer only (hk90/hk91), never extracts
                    // the subarray by value - so the generic Index typing
                    // (which rejects that extraction) is bypassed here;
                    // the index expression still must type as an integer.
                    Expr::Index(v, ie) if matches!(env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()), Some(Ty::DArr2)) => {
                        match type_expr(ie, env, sigs, n)? {
                            Ty::I64 | Ty::Dyn => {}
                            _ => return Err(format!("line {}: array index must be an integer", n)),
                        }
                    }
                    e => match type_expr(e, env, sigs, n)? {
                        Ty::I64 | Ty::Str | Ty::StrOwn | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::DArrRef | Ty::Arr(_) | Ty::Dyn => {}
                        _ => return Err(format!("line {}: `ValType` is not measured for this type in this PoC", n)),
                    },
                }
                return Ok(Ty::Str);
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
                            Some(v) if v.ty == Ty::DArr3 && !v.moved => Ok(Ty::I64),
                            Some(v) if v.ty == Ty::DArr2 || v.ty == Ty::DArr3 => Err(format!("line {}: use of moved value `{}`", n, id)),
                            _ => Err(format!("line {}: `len` of a[i] needs an array of arrays", n)),
                        };
                    }
                    Expr::Index2(id, ie, ie2) => {
                        // len(a[i][j]): borrow two levels (oracle pr4).
                        if type_expr(ie, env, sigs, n)? != Ty::I64 || type_expr(ie2, env, sigs, n)? != Ty::I64 {
                            return Err(format!("line {}: array indices must be integers", n));
                        }
                        return match env.iter().find(|v| v.name == *id) {
                            Some(v) if v.ty == Ty::DArr3 && !v.moved => Ok(Ty::I64),
                            Some(v) if v.ty == Ty::DArr3 => Err(format!("line {}: use of moved value `{}`", n, id)),
                            _ => Err(format!("line {}: `len` of a[i][j] needs an array of arrays of arrays", n)),
                        };
                    }
                    _ => {}
                }
                return match type_expr(&args[0], env, sigs, n)? {
                    Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::Arr(_) | Ty::Hash => {
                        // Only variables: an array TEMPORARY in expression
                        // position has no free point in this increment
                        // (the FOR EACH temp machinery does not apply
                        // here). Reachable since 33m via static returns;
                        // it also existed for dynamic ones - named
                        // rejection instead of the cg unreachable.
                        if !matches!(&args[0], Expr::Var(_)) {
                            return Err(format!("line {}: `len` of an array temporary is not in this increment (assign it to a variable first)", n));
                        }
                        Ok(Ty::I64)
                    }
                    _ => return Err(format!("line {}: `len` expects an array", n)),
                };
            }
            if is_builtin(id, "hb_hkeys") {
                // hb_HKeys(h): NEW array of owned key strings in insertion
                // order (oracles hk4/hk5/hk6, core hb_HKeys). The hash is
                // borrowed; the result is a DArrS the caller owns.
                if args.len() != 1 {
                    return Err(format!("line {}: `hb_HKeys` takes exactly one argument", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HKeys` expects a hash variable (its slot is passed by address)", n));
                }
                return Ok(Ty::DArrS);
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
            let si = sigs.iter().position(|v| v.name == *id)
                .ok_or_else(|| format!("line {}: unknown function `{}` (must be defined before use)", n, id))?;
            let (sig_params, sig_borrowed, sig_arr_moved, sig_ret) = {
                let s = &sigs[si];
                (s.params.clone(), s.borrowed.clone(), s.arr_moved.clone(), s.ret)
            };
            if sig_params.len() != args.len() {
                return Err(format!("line {}: `{}` takes {} argument(s), got {}", n, id, sig_params.len(), args.len()));
            }
            for (i, a) in args.iter().enumerate() {
                // A MIDDLE cell as an argument: f(a[i]) on an array of
                // arrays. Harbour SHARES the child with the callee
                // (oracles hk73 reads, hk78 growth, hk86 element write,
                // hk87 shrink - all visible back in the caller). This
                // increment passes the child cell's ADDRESS: the callee
                // borrows it exclusively for the call, so growth/shrink/
                // writes land in the owner's cell and read back exactly
                // like Harbour, while the single-owner model stays intact
                // (the borrow ends at the return; escapes are rejected by
                // the post-pass). NOT Harbour sharing: no alias survives
                // the call (registered difference family D5/D7).
                if let Expr::Index(rid, ie) = a {
                    let root = env.iter().find(|v| v.name == *rid);
                    if let Some(v) = root {
                        // One level deeper (33k): f(a[i]) on a THREE-level
                        // array borrows a middle whose cells are child
                        // arrays {ptr, len} - the callee pins DArr2
                        // (oracles hk93-hk96). Same walk, same rules.
                        let borrow_match = (v.ty == Ty::DArr2 && sig_params[i] == Ty::DArr)
                            || (v.ty == Ty::DArr3 && sig_params[i] == Ty::DArr2);
                        if borrow_match {
                            if v.moved {
                                return Err(format!("line {}: use of moved value `{}`", n, rid));
                            }
                            if sig_arr_moved[i] {
                                return Err(format!("line {}: parameter {} of `{}` already receives an owned array elsewhere; it cannot also borrow `a[i]`", n, i + 1, id));
                            }
                            if type_expr(ie, env, sigs, n)? != Ty::I64 {
                                return Err(format!("line {}: array index must be an integer", n));
                            }
                            // The index expression itself may have MOVED the
                            // root (f(a[g(a)]): evaluated before the walk):
                            // reject instead of borrowing nulled slots.
                            if env.iter().find(|v| v.name == *rid).map(|v| v.moved).unwrap_or(true) {
                                return Err(format!("line {}: the index expression moves `{}`; compute the index first", n, rid));
                            }
                            // No aliasing inside one call: no other argument
                            // may mention the same root (two live borrows, or
                            // a move while borrowed, are unsound).
                            for (j, b) in args.iter().enumerate() {
                                if j != i && expr_mentions(b, rid) {
                                    return Err(format!("line {}: `{}` is borrowed by argument {}; no other argument of the same call may mention it", n, rid, i + 1));
                                }
                            }
                            sigs[si].borrowed[i] = true;
                            continue;
                        }
                    }
                }
                let ta = type_expr(a, env, sigs, n)?;
                if let Ty::Arr(_) = ta {
                    // A static root array argument is COPIED at the
                    // boundary into a flat dynamic array the callee owns
                    // and frees (33l). Oracle hk98: Harbour SHARES the
                    // array (callee writes and growth are visible in the
                    // caller), so the copy is a registered D5/D7-family
                    // difference pending the user's contract decision -
                    // NOT sharing. Only a variable argument and only a
                    // flat dynamic-array parameter pin; anything deeper
                    // stays a named rejection.
                    if sig_params[i] != Ty::DArr || !matches!(a, Expr::Var(_)) {
                        return Err(format!("line {}: a static array argument is copied at the boundary only into a flat dynamic-array parameter, from a variable, in this increment", n));
                    }
                    continue;
                }

                if ta == Ty::DArrU {
                    return Err(format!("line {}: the element type of the argument is unknown until its first `AAdd` (pin it first)", n));
                }
                // A string argument moves out of its variable right away, so
                // a second use later in the same expression (e.g. the other
                // side of a `+`) is rejected like any other use-after-move.
                if ta == Ty::Str || ta == Ty::StrOwn {
                    if let Expr::Var(v) = a {
                        if let Some(x) = env.iter_mut().find(|x| x.name == *v && matches!(x.ty, Ty::Str | Ty::StrOwn)) { x.moved = true; }
                    }
                }
                // A hash LITERAL argument has no emission path in
                // argument position (33o): only variables move into a
                // hash parameter. Named rejection instead of the cg
                // unreachable.
                if ta == Ty::Hash && !matches!(a, Expr::Var(_)) {
                    return Err(format!("line {}: a hash argument is a variable in this increment (assign the literal first)", n));
                }
                let ok = ta == sig_params[i]
                    || (ta == Ty::Dyn && sig_params[i] == Ty::I64)  // runtime extract (nil -> clean type error)
                    || (ta == Ty::I64 && sig_params[i] == Ty::Dyn) // tagged at the call
                    || (ta == Ty::Str && sig_params[i] == Ty::StrOwn); // rodata: copied at the call boundary
                if !ok {
                    return Err(format!("line {}: argument {} of `{}` must be {}, got {}",
                        n, i + 1, id,
                        ty_name(sig_params[i]), ty_name(ta)));
                }
                // An owned array variable moves into the parameter (the
                // established contract): exclusive with the borrow mode.
                if matches!(ta, Ty::DArr | Ty::DArr2 | Ty::DArr3 | Ty::DArrS) {
                    if sig_borrowed[i] {
                        return Err(format!("line {}: parameter {} of `{}` already borrows `a[i]` elsewhere; it cannot also receive an owned array", n, i + 1, id));
                    }
                    sigs[si].arr_moved[i] = true;
                }
            }
            match sig_ret {
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
            // A grown casilla of an array of arrays compares against NIL
            // with `=` / `#` (oracle n4): the borrow reads the child
            // pointer, it never extracts the subarray. A real empty child
            // ({}) owns a block and is NOT NIL.
            if matches!(op, CmpOp::EqEq) {
                return Err(format!("line {}: `==` identity comparison is not in this increment yet (oracles cl7/cl19)", n));
            }
            if matches!(op, CmpOp::Eq | CmpOp::Ne) {
                let cas = |e: &Expr| matches!(e, Expr::Index(v, _) if env.iter().any(|x| x.name == *v && matches!(x.ty, Ty::DArr2 | Ty::DArr3)));
                let idx = if cas(a) && matches!(**b, Expr::Nil) {
                    if let Expr::Index(_, ie) = &**a { Some(ie) } else { None }
                } else if cas(b) && matches!(**a, Expr::Nil) {
                    if let Expr::Index(_, ie) = &**b { Some(ie) } else { None }
                } else { None };
                if let Some(ie) = idx {
                    if type_expr(ie, env, sigs, n)? != Ty::I64 {
                        return Err(format!("line {}: array index must be an integer", n));
                    }
                    return Ok(Ty::Bool);
                }
            }
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
            let nil_str = (matches!(**a, Expr::Nil) && matches!(tb, Ty::Str | Ty::StrOwn)) || (matches!(**b, Expr::Nil) && matches!(ta, Ty::Str | Ty::StrOwn));
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
            if matches!(ta, Ty::Str | Ty::StrOwn) && matches!(tb, Ty::Str | Ty::StrOwn) {
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
            // Dyn against a string: runtime dispatch on the Dyn tag.
            // `=`/`#`: xBase prefix rule over the right operand's length
            // (hk33/hk37); a NIL casilla is .F./.T. (hk35); a numeric
            // casilla is a clean named exit 1 (hk34/hk38). Ordering:
            // byte-wise over the right operand's length for string
            // casillas (hk36/hk39/hk40/hk43/hk51); NIL or numeric
            // casillas are a clean named exit 1 mirroring Harbour's
            // BASE/1073-1076 error condition (hk41/hk42/hk44-hk50,
            // dialogs that hang headless) - registered failure modes,
            // not exact equivalence.
            if (ta == Ty::Dyn && matches!(tb, Ty::Str | Ty::StrOwn)) || (matches!(ta, Ty::Str | Ty::StrOwn) && tb == Ty::Dyn) {
                return Ok(Ty::Bool);
            }
            if ta != tb {
                return Err(format!("line {}: cannot compare a string with an integer in this PoC", n));
            }
            Err(format!("line {}: comparisons require integers", n))
        }
        Expr::ArrLit(es) => {
            let deep3 = es.iter().any(|e| matches!(e, Expr::ArrLit(inner) if inner.iter().any(|x| matches!(x, Expr::ArrLit(_) | Expr::DArrNew))));
            if deep3 {
                // {{{1,2}},{{3}}}: a DArr3 (oracle pr4). Elements of the
                // innermost arrays are tagged scalars (integer or NIL).
                for e in es {
                    match e {
                        Expr::ArrLit(inner) => {
                            for ie in inner {
                                match ie {
                                    Expr::ArrLit(innermost) => {
                                        for xe in innermost {
                                            if !matches!(type_expr(xe, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                                                return Err(format!("line {}: nested array elements are tagged scalars (integer or NIL)", n));
                                            }
                                        }
                                    }
                                    Expr::DArrNew => {}
                                    _ => return Err(format!("line {}: array elements cannot mix integers and arrays in this increment", n)),
                                }
                            }
                        }
                        Expr::DArrNew => {}
                        _ => return Err(format!("line {}: array elements cannot mix integers and arrays in this increment", n)),
                    }
                }
                return Ok(Ty::DArr3);
            }
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
                    if it != Ty::Str && it != Ty::StrOwn {
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
                Some(v) if v.ty == Ty::DArrS => {
                    if v.moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                    // Reading a key out of an hb_HKeys result COPIES the
                    // string: the reader owns the copy (Ty::StrOwn), so a
                    // later free/move of the array cannot dangle it.
                    Ok(Ty::StrOwn)
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
        Expr::Index3(id, ie, ie2, ie3) => {
            // a[i][j][k]: three transient indexed borrows then a tagged
            // scalar read (oracle pr4). Child blocks are never moved out.
            if !matches!(type_expr(ie, env, sigs, n)?, Ty::I64 | Ty::Dyn)
                || !matches!(type_expr(ie2, env, sigs, n)?, Ty::I64 | Ty::Dyn)
                || !matches!(type_expr(ie3, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                return Err(format!("line {}: array indices must be integers", n));
            }
            match env.iter().find(|v| v.name == *id) {
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                Some(v) if v.moved => Err(format!("line {}: use of moved value `{}`", n, id)),
                Some(v) if v.ty == Ty::DArr3 => Ok(Ty::Dyn),
                Some(_) => Err(format!("line {}: three-level indexing needs an array of arrays of arrays; `{}` is not one", n, id)),
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
        Expr::SelfObj | Expr::SelfGet(_) | Expr::Send(_, _, _) => {
            Err(format!("line {}: classes are not in this increment yet (parser landed; runtime representation pending)", n))
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
        Ty::DArr3 => "an array of arrays of arrays",
        Ty::DArrS => "an array of strings",
        Ty::StrOwn => "a string",
        Ty::DArrU => "a dynamic array",
        Ty::DArr2 => "an array of arrays",
        Ty::Arr(_) => "an array",
        Ty::Block(_) => "a codeblock",
        Ty::DArr => "a dynamic array",
        Ty::DArrRef => "a borrowed array",
        Ty::DArrRef2 => "a borrowed array",
        Ty::Dyn => "a dynamic value",
        Ty::Hash => "a hash",
    }
}

fn free_vars(e: &Expr, out: &mut Vec<String>) {
    match e {
        Expr::Var(id) => { if !out.iter().any(|x| x == id) { out.push(id.clone()); } }
        Expr::SelfObj | Expr::SelfGet(_) => {}
        Expr::Send(o, _, args) => { free_vars(o, out); for a in args { free_vars(a, out); } }
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => { free_vars(a, out); free_vars(b, out); }
        Expr::Call(_, args) => { for a in args { free_vars(a, out); } }
        Expr::ArrLit(es) => { for e in es { free_vars(e, out); } }
        Expr::Index(_, ie) => free_vars(ie, out),
        Expr::Index2(_, ie, ie2) => { free_vars(ie, out); free_vars(ie2, out); }
        Expr::Index3(_, ie, ie2, ie3) => { free_vars(ie, out); free_vars(ie2, out); free_vars(ie3, out); }
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
        Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => has_value_return(b),
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
        if matches!(ptys[i], Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3) { darr_names.insert(p.clone()); }
    }
    // dynamic arrays declared in the body ({} or a nested literal)
    fn scan_darr(stmts: &[Stmt], darr: &mut HashSet<String>) {
        for st in stmts {
            match st {
                Stmt::Local(_, id, Expr::DArrNew) => { darr.insert(id.clone()); }
                Stmt::Local(_, id, Expr::ArrLit(es)) if es.iter().any(|e| matches!(e, Expr::ArrLit(_) | Expr::DArrNew)) => { darr.insert(id.clone()); }
                Stmt::If(_, _, t, e) => { scan_darr(t, darr); scan_darr(e, darr); }
                Stmt::While(_, _, b) => scan_darr(b, darr),
                Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => scan_darr(b, darr),
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
                Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => collect(b, out),
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
        // A rodata string and an owned string unify to owned (the caller
        // always owns the result; a rodata return point emits a copy).
        (Some(Ty::Str), Ty::StrOwn) | (Some(Ty::StrOwn), Ty::Str) => Ok(Ty::StrOwn),
        (Some(p), _) => Err(format!("line {}: return type mismatch (this function already returns {:?} elsewhere; all returns must agree)", n, p)),
    }
}

// The FOR EACH collection is BORROWED for the whole loop: any body
// statement that reassigns it, sets its elements, moves it (checked via
// the moved flag) or grows it through the mutating builtins would
// invalidate the borrowed (pointer, count) pair - a reallocation leaves
// it dangling. This increment rejects all of them (registered
// limitation; Harbour's own docs advise against mutating while
// iterating).
fn foreach_coll_untouched(stmts: &[Stmt], name: &str) -> bool {
    fn expr_ok(e: &Expr, name: &str) -> bool {
        match e {
            Expr::Call(id, args) => {
                if (is_builtin(id, "AAdd") || is_builtin(id, "ASize"))
                    && matches!(args.first(), Some(Expr::Var(v)) if v == name)
                {
                    return false;
                }
                // Passing a[i] of the loop's root to a user function hands
                // the callee a borrow it may grow through: the current
                // element's Dyn view could dangle. Rejected like the
                // direct mutations above (safe named rejection).
                if !is_builtin(id, "len") && !is_builtin(id, "valtype")
                    && args.iter().any(|a| matches!(a, Expr::Index(r, _) | Expr::Index2(r, _, _) | Expr::Index3(r, _, _, _) if r == name))
                {
                    return false;
                }
                args.iter().all(|a| expr_ok(a, name))
            }
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => expr_ok(a, name) && expr_ok(b, name),
            _ => true,
        }
    }
    stmts.iter().all(|s| match s {
        Stmt::Assign(_, id, e) => id != name && expr_ok(e, name),
        Stmt::ArrSet(_, id, ie, e) | Stmt::ArrSet2(_, id, ie, e, _) | Stmt::ArrSet3(_, id, ie, e, _, _) => id != name && expr_ok(ie, name) && expr_ok(e, name),
        Stmt::AAdd(_, id, _) | Stmt::ASize(_, id, _) | Stmt::AAddSub(_, id, _, _) | Stmt::ASizeSub(_, id, _, _) | Stmt::AAddSub2(_, id, _, _, _) | Stmt::ASizeSub2(_, id, _, _, _) => id != name,
        Stmt::SendStmt(_, e) => expr_ok(e, name),
        Stmt::If(_, c, a, b) => expr_ok(c, name) && foreach_coll_untouched(a, name) && foreach_coll_untouched(b, name),
        Stmt::While(_, c, b) => expr_ok(c, name) && foreach_coll_untouched(b, name),
        Stmt::For(_, _, a, b, _, body) => expr_ok(a, name) && expr_ok(b, name) && foreach_coll_untouched(body, name),
        Stmt::ForEach(_, _, c, body) => expr_ok(c, name) && foreach_coll_untouched(body, name),
        Stmt::Print(_, items) => items.iter().all(|i| expr_ok(i, name)),
        Stmt::Ret(_, Some(e)) => expr_ok(e, name),
        _ => true,
    })
}

// The FOR EACH loop variable is a Dyn view of the CURRENT ELEMENT: a
// tag-2 payload is a pointer INTO the borrowed collection, owned by it.
// That pointer must not escape the body: returning it (the collection is
// freed at the epilogue), copying it to another local (survives the
// iteration), passing it to a function or storing it into a collection
// would all leave a dangling or doubly-owned pointer. Dyn owns nothing
// anywhere in this PoC, so nobody ever copies or frees such a payload -
// this increment allows the variable only in reads that consume it
// immediately: print items, comparisons, arithmetic. Everything else is
// a named compile error (registered limitation).
fn foreach_lv_readonly(stmts: &[Stmt], name: &str) -> bool {
    fn mentions(e: &Expr, name: &str) -> bool {
        match e {
            Expr::Var(v) => v == name,
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => mentions(a, name) || mentions(b, name),
            Expr::Call(_, args) => args.iter().any(|a| mentions(a, name)),
            Expr::Index(id, i) | Expr::Index2(id, i, _) | Expr::Index3(id, i, _, _) => id == name || mentions(i, name),
            _ => false,
        }
    }
    fn in_call(e: &Expr, name: &str) -> bool {
        match e {
            Expr::Call(_, args) => args.iter().any(|a| mentions(a, name)),
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => in_call(a, name) || in_call(b, name),
            Expr::Index(_, i) | Expr::Index2(_, i, _) | Expr::Index3(_, i, _, _) => in_call(i, name),
            _ => false,
        }
    }
    stmts.iter().all(|s| match s {
        Stmt::Print(_, items) => items.iter().all(|i| !in_call(i, name)),
        Stmt::Assign(_, _, e) | Stmt::Ret(_, Some(e)) => !mentions(e, name),
        Stmt::ArrSet(_, _, ie, e) => !mentions(ie, name) && !mentions(e, name),
        Stmt::ArrSet2(_, _, i1, i2, e) => !mentions(i1, name) && !mentions(i2, name) && !mentions(e, name),
        Stmt::ArrSet3(_, _, i1, i2, i3, e) => !mentions(i1, name) && !mentions(i2, name) && !mentions(i3, name) && !mentions(e, name),
        Stmt::AAdd(_, _, e) | Stmt::ASize(_, _, e) => !mentions(e, name),
        Stmt::AAddSub(_, _, i, e) | Stmt::ASizeSub(_, _, i, e) => !mentions(i, name) && !mentions(e, name),
        Stmt::AAddSub2(_, _, i, j, e) | Stmt::ASizeSub2(_, _, i, j, e) => !mentions(i, name) && !mentions(j, name) && !mentions(e, name),
        Stmt::Local(_, _, e) => !mentions(e, name),
        Stmt::If(_, _, a, b) => foreach_lv_readonly(a, name) && foreach_lv_readonly(b, name),
        Stmt::While(_, _, b) => foreach_lv_readonly(b, name),
        Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => foreach_lv_readonly(b, name),
        _ => true,
    })
}

fn check_stmts(stmts: &[Stmt], env: &mut Vec<Local>, sigs: &mut Vec<Sig>, ret: &mut Option<Ty>, loop_pre: Option<&Vec<bool>>, exits: &mut Vec<Vec<bool>>, dyn_names: &std::collections::HashSet<String>) -> Result<bool, String> {
    let mut falls = true;
    for s in stmts {
        match s {
            Stmt::SelfSet(n, _, _) | Stmt::SendSet(n, _, _, _) | Stmt::SendStmt(n, _) => {
                return Err(format!("line {}: classes are not in this increment yet (parser landed; runtime representation pending)", n));
            }
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
                    // `? a[i]` on an array of arrays is allowed: a
                    // NIL-grown casilla prints NIL (oracle n1) and a live
                    // child prints nothing (oracle n5) - the dispatch is
                    // at runtime, so the static type stays opaque here.
                    if let Expr::Index(v, ie) = e {
                        if let Some(var) = env.iter().find(|x| x.name == *v && x.ty == Ty::DArr2) {
                            let _ = var;
                            if type_expr(ie, env, sigs, *n)? != Ty::I64 && !matches!(type_expr(ie, env, sigs, *n)?, Ty::Dyn) {
                                return Err(format!("line {}: array index must be an integer", n));
                            }
                            continue;
                        }
                    }
                    let t = type_expr(e, env, sigs, *n)?;
                    if t == Ty::Bool {
                        return Err(format!("line {}: cannot print a boolean in this PoC", n));
                    }
                    if let Ty::Block(_) = t {
                        return Err(format!("line {}: cannot print a codeblock in this increment", n));
                    }
                    if matches!(t, Ty::Arr(_) | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::Hash) {
                        // Whole dynamic arrays and hashes print EMPTY in
                        // Harbour (oracles hk16/hk20/hk21/hk24: QOut
                        // renders an array or hash value as nothing) and
                        // the variable stays alive afterwards (hk23), so
                        // the item is a plain borrow. This increment
                        // accepts only a variable in this position:
                        // printing a temporary (literal, call result) is
                        // a registered PoC limitation.
                        if !matches!(e, Expr::Var(_)) {
                            return Err(format!("line {}: cannot print a temporary array or hash directly in this increment (assign it to a variable and print the variable)", n));
                        }
                    }
                    // Printing the RESULT borrows it (moving=false at the
                    // root), but a call INSIDE the item moves the arguments
                    // the callee owns - this arm must apply moves like any
                    // other statement, or `? consume(a)` would leave `a`
                    // usable after the callee took it (hole caught by the
                    // pr9 mirror: 2-level arrays had it too).
                    apply_moves(e, env, sigs, false);
                }
            }
            Stmt::Ret(n, Some(e)) => {
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::Bool {
                    return Err(format!("line {}: cannot return a boolean in this PoC", n));
                }
                if let Ty::Arr(_) = t {
                    // Returning a static array materializes a dynamic
                    // COPY the caller owns (33m). Oracle hk99: Harbour's
                    // local array survives the return and the caller gets
                    // a fully working array; a fresh owner matches that
                    // observably for the measured non-aliasing shape.
                    // Only a variable return this increment.
                    if !matches!(e, Expr::Var(_)) {
                        return Err(format!("line {}: a static array return is a variable in this increment", n));
                    }
                    apply_moves(e, env, sigs, false);
                    *ret = Some(unify_ret(*ret, Ty::DArr, *n)?);
                    falls = false;
                } else
                {
                if let Ty::Block(_) = t {
                    return Err(format!("line {}: codeblocks cannot be returned in this increment", n));
                }

                if t == Ty::DArrU {
                    return Err(format!("line {}: cannot return an empty array whose element type was never pinned by `AAdd`", n));
                }
                apply_moves(e, env, sigs, true);
                *ret = Some(unify_ret(*ret, t, *n)?);
                falls = false;
                }
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
            Stmt::ForEach(n, var, coll, body) => {
                // FOR EACH (oracles hk17-hk32): the collection is a
                // VARIABLE, borrowed for the loop and alive afterwards
                // (hk26). The loop variable must already exist - Harbour
                // errors BASE/1003 on an undeclared one - and inside the
                // body it is the CURRENT ELEMENT as a Dyn: i64/NIL for
                // flat arrays (hk26/hk30), string-or-NIL for key arrays
                // (hk17/hk27), value-or-NIL for hashes (hk18/hk31). The
                // outer value is RESTORED after the loop, naturally or
                // via `exit` (hk28/hk29): the outer slot is never
                // touched. Assigning to it is rejected (ro): Harbour
                // writes THROUGH to the element (hk32), a borrow of a
                // mutable cell this increment does not implement -
                // registered limitation.
                apply_moves(coll, env, sigs, false);
                // A nested collection a[i] whose root is an array of
                // arrays is BORROWED from the root owner for the loop
                // (hk53/hk54): the index expression is evaluated once,
                // bounds-checked, and a NIL casilla (a null child)
                // raises Harbour's BASE/1068 condition (hk58) - a clean
                // named exit 1, registered failure mode. The root
                // cannot be mutated, moved or grown inside the body
                // (that covers reseating a[i] and growing the borrowed
                // child, which could reallocate the borrowed cells).
                let sub = matches!(coll, Expr::Index(id, _) if matches!(env.iter().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr2)));
                // Depth 3 (hk60-hk64): a[i][j] on an array of arrays of
                // arrays borrows the innermost child the same way; both
                // index expressions evaluate once, each level is
                // bounds-checked, and a NIL casilla at either level is
                // the BASE/1068 failure mode.
                let sub2 = matches!(coll, Expr::Index2(id, _, _) if matches!(env.iter().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr3)));
                let ct = if sub {
                    if let Expr::Index(id, ie) = coll {
                        if env.iter().find(|v| v.name == *id).map(|v| v.moved).unwrap_or(false) {
                            return Err(format!("line {}: use of moved value `{}`", n, id));
                        }
                        let it = type_expr(ie, env, sigs, *n)?;
                        if !matches!(it, Ty::I64 | Ty::Dyn) {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                    }
                    Ty::DArr
                } else if sub2 {
                    if let Expr::Index2(id, ie, ie2) = coll {
                        if env.iter().find(|v| v.name == *id).map(|v| v.moved).unwrap_or(false) {
                            return Err(format!("line {}: use of moved value `{}`", n, id));
                        }
                        for ix in [ie, ie2] {
                            let it = type_expr(ix, env, sigs, *n)?;
                            if !matches!(it, Ty::I64 | Ty::Dyn) {
                                return Err(format!("line {}: array index must be an integer", n));
                            }
                        }
                    }
                    Ty::DArr
                } else {
                    type_expr(coll, env, sigs, *n)?
                };
                // A temporary collection (a call result: hb_HKeys(h),
                // Array(n) or a user function returning an array or a
                // hash; oracles hk52/hk55/hk56) is OWNED by the loop:
                // it gets a registered slot, zeroed by the prologue,
                // freed-if-nonnull on (re)entry and freed by the
                // epilogue on every exit path (natural, `exit`,
                // `return`). A variable collection is borrowed.
                if !matches!(coll, Expr::Var(_) | Expr::Call(..)) && !sub && !sub2 {
                    return Err(format!("line {}: `for each` iterates a variable or a function result in this increment (assign the expression to a variable first)", n));
                }
                if !matches!(ct, Ty::Arr(_) | Ty::DArr | Ty::DArrU | Ty::DArrS | Ty::Hash) {
                    return Err(format!("line {}: `for each` needs a flat or string array or a hash in this increment", n));
                }
                let kp = match env.iter().position(|v| v.name == *var) {
                    Some(k) => k,
                    None => return Err(format!("line {}: `for each` loop variable `{}` must be declared first (Harbour errors BASE/1003 on an undeclared one)", n, var)),
                };
                let cname = match coll {
                    Expr::Var(cn) => Some(cn.clone()),
                    Expr::Index(cn, _) if sub => Some(cn.clone()),
                    Expr::Index2(cn, _, _) if sub2 => Some(cn.clone()),
                    _ => None,
                };
                if let Some(cn) = &cname {
                    if cn == var {
                        return Err(format!("line {}: `for each` loop variable cannot be the collection itself", n));
                    }
                }
                let saved = (env[kp].ty, env[kp].ro);
                env[kp].ty = Ty::Dyn;
                env[kp].ro = true;
                let outer = env.len();
                let pre: Vec<bool> = env.iter().map(|v| v.moved).collect();
                let mut env_body = env.clone();
                let mut fexits: Vec<Vec<bool>> = Vec::new();
                let fb = check_stmts(body, &mut env_body, sigs, ret, Some(&pre), &mut fexits, dyn_names)?;
                if let Some(cn) = &cname {
                    let kc = env.iter().position(|v| v.name == *cn).expect("collection exists");
                    if env_body[kc].moved || !foreach_coll_untouched(body, cn) {
                        return Err(format!("line {}: the `for each` collection `{}` cannot be modified, moved or grown inside its own loop in this increment (the loop borrows it)", n, cn));
                    }
                }
                if !foreach_lv_readonly(body, var) {
                    return Err(format!("line {}: the `for each` variable `{}` can only be printed, compared or used in arithmetic in this increment - its value borrows from the collection, so it cannot be returned, assigned, passed to a function or stored (registered limitation)", n, var));
                }

                if fb {
                    for k in 0..outer {
                        if !pre[k] && env_body[k].moved {
                            return Err(format!("line {}: `{}` is moved inside the `for each` body and not reassigned before `next` (the next iteration would use a moved value)", n, env[k].name));
                        }
                    }
                }
                for k in 0..outer {
                    env[k].moved = pre[k] || (fb && env_body[k].moved) || fexits.iter().any(|xs| xs[k]);
                    if env[k].ty == Ty::DArrU && matches!(env_body[k].ty, Ty::DArr | Ty::DArr2) {
                        env[k].ty = env_body[k].ty;
                    }
                }
                env[kp].ty = saved.0;
                env[kp].ro = saved.1;
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
                if !matches!(env[kp].ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArrS) {
                    return Err(format!("line {}: `AAdd` applies to dynamic arrays (`{{}}`); `{}` is not one", n, id));
                }
                let t = type_expr(e, env, sigs, *n)?;
                let moves = match env[kp].ty {
                    Ty::DArrU => {
                        match t {
                            Ty::I64 | Ty::Dyn => { env[kp].ty = Ty::DArr; false }
                            Ty::DArr | Ty::DArrU => { env[kp].ty = Ty::DArr2; true }
                            // A string pins an array of strings; an owned
                            // string moves in, a rodata one is copied.
                            Ty::Str | Ty::StrOwn => { env[kp].ty = Ty::DArrS; t == Ty::StrOwn }
                            _ => return Err(format!("line {}: `AAdd` grows with integer, string or dynamic-array elements in this increment", n)),
                        }
                    }
                    Ty::DArrS => {
                        if !matches!(t, Ty::Str | Ty::StrOwn) {
                            return Err(format!("line {}: the elements of `{}` are strings", n, id));
                        }
                        t == Ty::StrOwn
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
                        // A dynamic value MOVES in; a static literal
                        // materializes as a dynamic child (the borrowed
                        // middle of a three-level array grows this way -
                        // oracle hk94).
                        if !matches!(t, Ty::DArr | Ty::Arr(_)) {
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
                if !matches!(env[kp].ty, Ty::DArr2 | Ty::DArr3) {
                    return Err(format!("line {}: `AAdd` on a[i] needs an array of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array index must be an integer", n));
                }
                apply_moves(ie, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if env[kp].ty == Ty::DArr3 {
                    // Middle level of three levels (hk66/hk67/hk69): the
                    // element is a FLAT dynamic array - a static literal
                    // materializes as a dynamic child, a call result or a
                    // variable MOVES in (the source is nulled; the move
                    // contract of root AAdd extends here - Harbour would
                    // SHARE a variable element, registered difference
                    // D5/D7 pending the user's contract decision; this
                    // does NOT implement sharing). Nested literals or
                    // array-of-arrays elements would make a fourth level:
                    // rejected.
                    let t = type_expr(e, env, sigs, *n)?;
                    if !matches!(t, Ty::Arr(_) | Ty::DArr | Ty::DArrU) {
                        return Err(format!("line {}: the elements of the middle level of `{}` are flat dynamic arrays in this increment", n, id));
                    }
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
                    if type_expr(e, env, sigs, *n)? != Ty::I64 {
                        return Err(format!("line {}: nested array elements must be integers in this increment", n));
                    }
                    apply_moves(e, env, sigs, false);
                    if env[kp].moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
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
                    // fresh children are the empty (null, 0) array. DArrS
                    // shrink frees the removed string copies; GROWING an
                    // array of strings is a clean runtime error in this
                    // increment (Harbour grows with NIL casillas, hk13).
                    Ty::DArr | Ty::DArr2 | Ty::DArrS | Ty::DArr3 => {}
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
                // DArr3 root: the middle child resizes in place (hk65:
                // grow with NIL casillas; shrink frees removed innermost
                // children).
                if !matches!(env[kp].ty, Ty::DArr2 | Ty::DArr3) {
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
            Stmt::AAddSub2(n, id, ie, ie2, e) => {
                // AAdd(a[i][j], x): grows the INNERMOST subarray in place
                // (oracle pr8). Runtime order: i, then j, then the value
                // (pr8 measured; NOT inferred from the two-level m7).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].ty != Ty::DArr3 {
                    return Err(format!("line {}: `AAdd` on a[i][j] needs an array of arrays of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
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
            Stmt::ASizeSub2(n, id, ie, ie2, e) => {
                // ASize(a[i][j], n): resize the innermost subarray in
                // place (oracle pr8: grow leaves fresh slots NIL).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].ty != Ty::DArr3 {
                    return Err(format!("line {}: `ASize` on a[i][j] needs an array of arrays of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
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
                        if !matches!(type_expr(ie, env, sigs, *n)?, Ty::Str | Ty::StrOwn) {
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
                    Ty::DArrS => {
                        // Element overwrite on an array of strings: an
                        // owned string moves in, a rodata one is copied;
                        // the old owned copy is freed in codegen.
                        let vt = type_expr(e, env, sigs, *n)?;
                        if !matches!(vt, Ty::Str | Ty::StrOwn) {
                            return Err(format!("line {}: the elements of `{}` are strings", n, id));
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
                        // An i64 literal converts to a Dyn-element child
                        // (oracle n3: a[3] := {9, 9} works in Harbour).
                        if !matches!(t, Ty::DArr | Ty::DArrU | Ty::Arr(_)) {
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
            Stmt::ArrSet3(n, id, ie, ie2, ie3, e) => {
                // a[i][j][k] := v: value first, then the indices (probe
                // m7 order); three transient indexed borrows (oracle pr6).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ro {
                    return Err(format!("line {}: cannot assign through the `for` loop variable `{}`", n, id));
                }
                if env[kp].ty != Ty::DArr3 {
                    return Err(format!("line {}: three-level assignment needs an array of arrays of arrays; `{}` is not one", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: nested array elements must be integers in this increment", n));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 || type_expr(ie3, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(e, env, sigs, true);
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
                apply_moves(ie3, env, sigs, false);
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
                if let Some(v) = env.iter_mut().find(|v| v.name == *id && matches!(v.ty, Ty::Str | Ty::StrOwn | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::Hash)) { v.moved = true; }
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
            if is_builtin(id, "valtype") {
                // ValType borrows its argument (hk88-hk92): nothing moves.
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
            if is_builtin(id, "hb_hkeys") {
                // The hash is BORROWED: hbc_hkeys copies every key, the
                // hash keeps owning its own copies.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            let sig = sigs.iter().find(|v| v.name == *id).expect("checked");
            for (i, a) in args.iter().enumerate() {
                // A static array argument is COPIED at the boundary (33l):
                // the source variable keeps its value.
                let copy = matches!(a, Expr::Var(v) if env.iter().any(|x| x.name == *v && matches!(x.ty, Ty::Arr(_))));
                let m = !copy && i < sig.params.len() && (sig.params[i] == Ty::Str || sig.params[i] == Ty::StrOwn || sig.params[i] == Ty::DArr || sig.params[i] == Ty::DArr2 || sig.params[i] == Ty::DArr3 || sig.params[i] == Ty::DArrS || sig.params[i] == Ty::Hash);
                apply_moves(a, env, sigs, m);
            }
        }
        Expr::ArrLit(es) => { for e in es { apply_moves(e, env, sigs, false); } }
        Expr::Index(_, ie) => apply_moves(ie, env, sigs, false),
        Expr::Index2(_, ie, ie2) => { apply_moves(ie, env, sigs, false); apply_moves(ie2, env, sigs, false); }
        Expr::Index3(_, ie, ie2, ie3) => { apply_moves(ie, env, sigs, false); apply_moves(ie2, env, sigs, false); apply_moves(ie3, env, sigs, false); }
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
    match t { Ty::I64 => 8, Ty::Str | Ty::StrOwn => 16, Ty::Arr(n) => 8 * n, Ty::Block(_) => 8, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::Dyn | Ty::Hash | Ty::DArrRef | Ty::DArrRef2 => 16, Ty::Bool => unreachable!("booleans rejected in analysis") }
}

#[derive(Clone)]
struct CgLocal {
    name: String,
    ty: Ty,
    off: usize, // offset below rbp of the FIRST slot (ptr for Str, value for i64)
}

fn cg_expr(e: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    match e {
        Expr::SelfObj | Expr::SelfGet(_) | Expr::Send(_, _, _) => unreachable!("rejected before codegen"),
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
                Ty::Str | Ty::StrOwn | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::Dyn | Ty::Hash => {
                    // ptr at -(off), len at -(off-8) — same layout as the store
                    out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off));
                    out.push_str(&format!("    mov -{}(%rbp), %rdx\n", v.off - 8));
                }
                Ty::Bool => unreachable!("booleans rejected in analysis"),
                // Only the address word is meaningful; value-position use
                // of a borrowed parameter is rejected by the escape
                // post-pass, so the second word never matters.
                Ty::DArrRef | Ty::DArrRef2 => out.push_str(&format!("    mov -{}(%rbp), %rax\n    xor %edx, %edx\n", v.off)),
                Ty::Arr(_) => unreachable!("whole-array values are emitted via cg_array_value"),
            }
        }
        Expr::Call(id, args) if is_builtin(id, "valtype") => {
            // ValType(x) (hk88-hk92): a one-character tag as a 1-byte
            // string (rax=ptr, rdx=1). Static types classify at compile
            // time; Dyn casillas at runtime: a scalar casilla {tag,
            // payload} reads tag 0/1/2 as "N"/"U"/"C" (hk92), a child-array
            // casilla {ptr, len} reads ptr 0/nonzero as "U"/"A"
            // (hk90/hk91). Index arguments evaluate once, with their
            // effects, before the walk (hk89). Borrows - never moves.
            fn vt_letter(strs: &mut Vec<String>, out: &mut String, ch: &str) {
                let idx = strs.len();
                strs.push(ch.to_string());
                out.push_str(&format!("    lea .Lstr{}(%rip), %rax\n    mov $1, %edx\n", idx));
            }
            // %r10 = scalar Dyn tag: 0 i64 -> "N", 1 NIL -> "U", 2 str -> "C"
            fn vt_classify_scalar(strs: &mut Vec<String>, out: &mut String) {
                out.push_str("    cmp $1, %r10\n    je 95f\n    cmp $2, %r10\n    je 96f\n");
                vt_letter(strs, out, "N");
                out.push_str("    jmp 97f\n95:\n");
                vt_letter(strs, out, "U");
                out.push_str("    jmp 97f\n96:\n");
                vt_letter(strs, out, "C");
                out.push_str("97:\n");
            }
            match &args[0] {
                Expr::Int(_) => vt_letter(strs, out, "N"),
                Expr::Str(_) => vt_letter(strs, out, "C"),
                Expr::Nil => vt_letter(strs, out, "U"),
                Expr::Var(v) => {
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    match var.ty {
                        Ty::I64 => vt_letter(strs, out, "N"),
                        Ty::Str | Ty::StrOwn => vt_letter(strs, out, "C"),
                        Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::DArrRef | Ty::DArrRef2 | Ty::Arr(_) => vt_letter(strs, out, "A"),
                        Ty::Dyn => {
                            // tag word of the stack pair (tag at -(off))
                            out.push_str(&format!("    mov -{}(%rbp), %r10\n", var.off));
                            vt_classify_scalar(strs, out);
                        }
                        _ => unreachable!("checked"),
                    }
                }
                Expr::Index(v, ie) => {
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    cg_expr(ie, env, sigs, strs, out, target);
                    match var.ty {
                        Ty::DArr | Ty::DArrS => {
                            out.push_str(&format!("    cmp $1, %rax\n    jl 87f\n    cmp -{}(%rbp), %rax\n    jg 87f\n", var.off - 8));
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                            out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                            vt_classify_scalar(strs, out);
                        }
                        Ty::DArrRef => {
                            // Borrowed middle array: bounds and base load
                            // through the owner's cell address (hk86).
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rax\n    jl 87f\n    cmp 8(%r11), %rax\n    jg 87f\n", var.off));
                            out.push_str("    mov (%r11), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                            vt_classify_scalar(strs, out);
                        }
                        Ty::DArrRef2 => {
                            // Borrowed middle of a THREE-level array: the
                            // cell content is a child-array {ptr, len} -
                            // null ptr is "U", non-null "A" (hk90/hk91
                            // through the borrow, hk97).
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rax\n    jl 87f\n    cmp 8(%r11), %rax\n    jg 87f\n", var.off));
                            out.push_str("    mov (%r11), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    test %r10, %r10\n    jz 85f\n    jmp 86f\n87:\n    call hbc_bound_error\n85:\n");
                            vt_letter(strs, out, "U");
                            out.push_str("    jmp 88f\n86:\n");
                            vt_letter(strs, out, "A");
                            out.push_str("88:\n");
                        }
                        Ty::DArr2 => {
                            out.push_str(&format!("    cmp $1, %rax\n    jl 87f\n    cmp -{}(%rbp), %rax\n    jg 87f\n", var.off - 8));
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                            out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    test %r10, %r10\n    jz 85f\n    jmp 86f\n87:\n    call hbc_bound_error\n85:\n");
                            vt_letter(strs, out, "U");
                            out.push_str("    jmp 88f\n86:\n");
                            vt_letter(strs, out, "A");
                            out.push_str("88:\n");
                        }
                        _ => unreachable!("checked"),
                    }
                }
                Expr::Index2(v, ie, ie2) => {
                    // DArr2 two-level read (hk88): middle casilla {ptr,
                    // len}, innermost {payload, tag}. A NIL middle cannot
                    // be walked: Harbour's dialog hangs headless - the
                    // registered clean bound-error failure mode, not a
                    // compat success.
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                    if var.ty == Ty::DArrRef2 {
                        // Through the borrowed middle of a three-level
                        // array (hk97): root bounds and base load through
                        // the owner's cell address.
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%r11), %rcx\n    jg 87f\n", var.off));
                        out.push_str("    mov (%r11), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    } else {
                        out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", var.off - 8));
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                        out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    }
                    out.push_str("    mov (%r10), %r11\n    test %r11, %r11\n    jz 87f\n");
                    out.push_str("    cmp $1, %rax\n    jl 87f\n    cmp 8(%r10), %rax\n    jg 87f\n");
                    out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                    vt_classify_scalar(strs, out);
                }
                _ => unreachable!("checked"),
            }
        }
        Expr::Call(id, args) if is_builtin(id, "len") => {
            // len(a) for a dynamic array: the length word of the slot.
            match &args[0] {
                Expr::Var(v) => {
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    match var.ty {
                        Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::Hash => out.push_str(&format!("    mov -{}(%rbp), %rax\n", var.off - 8)),
                        Ty::DArrRef | Ty::DArrRef2 => out.push_str(&format!("    mov -{}(%rbp), %rax\n    mov 8(%rax), %rax\n", var.off)),
                        Ty::Arr(k) => out.push_str(&format!("    mov ${}, %rax\n", k)),
                        _ => unreachable!("checked"),
                    }
                }
                Expr::Index(v, ie) => {
                    // len(a[i]): borrow the child slot (probe m6). A
                    // null child (fresh ASize growth) is Harbour's NIL
                    // casilla: len() of it is Harbour's BASE/1111
                    // (hangs headless, oracle n2) - here a clean
                    // "Argument error: LEN", exit 1 (registered failure
                    // mode). An EMPTY child ({}) owns a header block and
                    // still reads 0 (oracle e4).
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    if var.ty == Ty::DArrRef2 {
                        // len(p[i]) through the borrowed middle of a
                        // three-level array (hk93): bounds and base load
                        // through the owner's cell address; the cell holds
                        // a child {ptr, len} and a null child is the same
                        // registered "Argument error: LEN" failure mode.
                        cg_expr(ie, env, sigs, strs, out, target);
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rax\n    jl 87f\n    cmp 8(%r11), %rax\n    jg 87f\n", var.off));
                        out.push_str("    mov (%r11), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    test %r10, %r10\n    jz hbc_len_error\n    mov 8(%rax), %rax\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                        return;
                    }
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str(&format!("    cmp $1, %rax\n    jl 87f\n    cmp -{}(%rbp), %rax\n    jg 87f\n", var.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                    out.push_str("    dec %rax\n    shl $4, %rax\n    mov 0(%r11,%rax), %r10\n    test %r10, %r10\n    jz hbc_len_error\n    mov 8(%r11,%rax), %rax\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                }
                Expr::Index2(v, ie, ie2) => {
                    // len(a[i][j]): borrow two levels (oracle pr4). A null
                    // child at either level is the NIL casilla: Harbour's
                    // BASE/1111 dialog hangs headless, so this is the same
                    // registered clean "Argument error: LEN" failure mode.
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                    out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", var.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                    out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    out.push_str("    mov (%r10), %r11\n    test %r11, %r11\n    jz hbc_len_error\n");
                    out.push_str("    cmp $1, %rax\n    jl 87f\n    cmp 8(%r10), %rax\n    jg 87f\n");
                    out.push_str("    dec %rax\n    shl $4, %rax\n    mov 0(%r11,%rax), %r10\n    test %r10, %r10\n    jz hbc_len_error\n    mov 8(%r11,%rax), %rax\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                }
                _ => unreachable!("len() of a non-variable in this increment"),
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hkeys") => {
            // hb_HKeys(h): the helper copies every key into a NEW array
            // the caller owns; the hash slot is passed by address and
            // never mutated. Returns rax = data pointer, rdx = count.
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    call hbc_hkeys\n", var.off));
            } else {
                unreachable!("checked: hb_HKeys takes a hash variable");
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
            } else if args.len() == 2 {
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
            } else {
                // Array(n, m, k): dimensions left to right, then the
                // composed constructor (oracle pr7).
                cg_expr(&args[0], env, sigs, strs, out, target);
                if expr_ty(&args[0], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[1], env, sigs, strs, out, target);
                if expr_ty(&args[1], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[2], env, sigs, strs, out, target);
                if expr_ty(&args[2], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    mov %rax, %rcx\n    mov (%rsp), %rdx\n    add $16, %rsp\n    mov (%rsp), %rsi\n    add $16, %rsp\n");
                out.push_str("    sub $16, %rsp\n    movq $0, (%rsp)\n    movq $0, 8(%rsp)\n");
                out.push_str("    mov %rsp, %rdi\n    call hbc_array3m\n");
                out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
            }
        }
        Expr::Call(id, _) if is_builtin(id, "hb_memcheck") => {
            // alloc/free balance counters (test harness only).
            out.push_str("    mov hbc_mem_allocs(%rip), %rax\n    sub hbc_mem_frees(%rip), %rax\n");
        }
        Expr::DArrNew => {
            // {} : the empty dynamic array owns a header-only block
            // (cap 0), so it is distinguishable from a NIL slot left by
            // ASize growth (null, 0) - Harbour types {} as ARRAY and the
            // grown casillas as NIL (oracles e4, n1, n2). len({}) == 0
            // either way.
            out.push_str("    mov $8, %rdi\n    call hbc_alloc\n    movq $0, (%rax)\n    add $8, %rax\n    xor %edx, %edx\n");
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
            let pborrowed = sigs.iter().find(|v| v.name == *id).map(|v| v.borrowed.clone());
            for (ai, a) in args.iter().enumerate() {
                // Borrowed argument: `a[i]` on an array of arrays. The
                // index evaluates FIRST (Harbour order), then the bounds
                // walk yields the child cell's ADDRESS; the callee borrows
                // it for the call (oracles hk73/hk78/hk86/hk87). A NIL
                // casilla is Harbour's BASE/1123-family condition (his
                // dialog hangs headless - no oracle): clean exit 1 with
                // "Argument error: PARAM" (registered failure mode).
                if pborrowed.as_ref().and_then(|b| b.get(ai)).copied() == Some(true) {
                    if let Expr::Index(rid, rie) = a {
                        let rv = env.iter().rev().find(|x| x.name == *rid).expect("checked").clone();
                        if expr_ty(rie, env, sigs) == Ty::Dyn {
                            cg_expr(rie, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64\n");
                        } else {
                            cg_expr(rie, env, sigs, strs, out, target);
                        }
                        out.push_str(&format!("    cmp $1, %rax\n    jl 81f\n    cmp -{}(%rbp), %rax\n    jg 81f\n", rv.off - 8));
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n", rv.off));
                        out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    test %r11, %r11\n    jz hbc_param_error\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
                        out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    movq $0, 8(%rsp)\n");
                        continue;
                    }
                }
                let ta = expr_ty(a, env, sigs);
                let pty = psig.as_ref().and_then(|p| p.get(ai).copied());
                if let Ty::Arr(k) = ta {
                    // Static array argument: materialize the boundary
                    // COPY as a dynamic array (header + tagged cells,
                    // same shape as cg_darr2_literal's inner block); the
                    // callee owns and frees it (33l).
                    if let Expr::Var(src) = a {
                        let sv = env.iter().rev().find(|x| x.name == *src).expect("checked").clone();
                        out.push_str("    sub $16, %rsp\n");
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + k * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", k));
                        for p in 0..k {
                            out.push_str(&format!("    mov -{}(%rbp), %r10\n", sv.off - 8 * p));
                            out.push_str(&format!("    mov (%rsp), %r11\n    movq $0, {}(%r11)\n    mov %r10, {}(%r11)\n", p * 16, p * 16 + 8));
                        }
                        out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $16, %rsp\n", k));
                        out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                        continue;
                    }
                }
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
                if ta == Ty::Str && pty == Some(Ty::StrOwn) {
                    // A rodata string argument to an owned-string
                    // parameter: the callee owns and frees its parameter,
                    // so the call boundary hands over a fresh copy.
                    out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                } else if ta == Ty::Str || ta == Ty::DArr || ta == Ty::DArr2 || ta == Ty::DArr3 || ta == Ty::DArrS || ta == Ty::StrOwn || ta == Ty::Hash {
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    // An owned (moved) argument: null the source slot
                    // right after the copy, so the callee is the only
                    // owner and the caller's later frees see null.
                    if let Expr::Var(src) = a {
                        if matches!(ta, Ty::DArr | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::StrOwn | Ty::Hash) {
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::StrOwn | Ty::Hash)) {
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
                let temp_key = expr_ty(ie, env, sigs) == Ty::StrOwn && !matches!(&**ie, Expr::Var(_));
                if temp_key {
                    // An owned key copy (e.g. h[keys[i]]): the lookup
                    // borrows it; free it right after hbc_hget returns
                    // (the lookup never retains the key bytes).
                    out.push_str("    sub $32, %rsp\n    mov %rsi, (%rsp)\n");
                }
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    call hbc_hget\n", v.off));
                if temp_key {
                    out.push_str("    mov %rax, 8(%rsp)\n    mov (%rsp), %rdi\n    mov $1, %esi\n    call hbc_free\n    mov 8(%rsp), %rax\n    add $32, %rsp\n");
                }
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
            if v.ty == Ty::DArrRef {
                // Borrowed middle array (a[i] passed to this function):
                // the slot holds the child cell's ADDRESS; bounds and the
                // element pointer load THROUGH it, so callee reads see the
                // owner's current contents (oracle hk73).
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rax\n    jl 81f\n    cmp 8(%r11), %rax\n    jg 81f\n", v.off));
                out.push_str("    mov (%r11), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n    jmp 82f\n");
                out.push_str("81:\n    call hbc_bound_error\n82:\n");
                return;
            }
            if v.ty == Ty::DArrS {
                // Reading a key out of an hb_HKeys result COPIES it via
                // hbc_strcpy: the value in rax/rdx is owned by the
                // consumer (a StrOwn slot, a print item, or a hash
                // lookup), never a borrow into the array.
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str(&format!("    cmp $1, %rax\n    jl 81f\n    cmp -{}(%rbp), %rax\n    jg 81f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    # A grown casilla (ASize, hk13/hk14) is NIL: a string context\n    # gets a clean error; `? k[i]` prints NIL instead (Print arm).\n    cmpq $2, (%rax)\n    jne hbc_snil_error\n    mov 8(%rax), %rdi\n    mov -8(%rdi), %rsi\n    call hbc_strcpy\n    jmp 82f\n");
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
            if var.ty == Ty::DArrRef2 {
                // p[i][j] through the borrowed middle of a three-level
                // array (hk93): root bounds and base load through the
                // owner's cell address; the middle cell holds the child's
                // {ptr, len}; a null child has length 0 (same bound
                // error); the innermost cell is a scalar {tag, payload}.
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
                out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rcx\n    jl 81f\n    cmp 8(%r11), %rcx\n    jg 81f\n", var.off));
                out.push_str("    mov (%r11), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                out.push_str("    cmp $1, %rax\n    jl 81f\n    cmp 8(%r10), %rax\n    jg 81f\n");
                out.push_str("    mov (%r10), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
                return;
            }
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
        Expr::Index3(id, ie, ie2, ie3) => {
            // a[i][j][k] read: three transient borrows; indices evaluate
            // left to right, every level bounds-checked. A null child has
            // length 0, so indexing it is a clean bound error (same
            // registered failure mode as the two-level read).
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
            out.push_str("    mov %rax, 8(%rsp)\n");
            if expr_ty(ie3, env, sigs) == Ty::Dyn {
                cg_expr(ie3, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie3, env, sigs, strs, out, target);
            }
            // (%rsp)=i, 8(%rsp)=j, rax=k
            out.push_str(&format!("    mov (%rsp), %rcx\n    cmp $1, %rcx\n    jl 81f\n    cmp -{}(%rbp), %rcx\n    jg 81f\n", var.off - 8));
            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
            out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
            // r10 = level-2 child slot; bounds-check j against its length
            out.push_str("    mov 8(%rsp), %rcx\n    cmp $1, %rcx\n    jl 81f\n    cmp 8(%r10), %rcx\n    jg 81f\n");
            out.push_str("    mov (%r10), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
            // r10 = level-3 child slot; bounds-check k against its length
            out.push_str("    cmp $1, %rax\n    jl 81f\n    cmp 8(%r10), %rax\n    jg 81f\n");
            out.push_str("    mov (%r10), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n");
            out.push_str("    add $16, %rsp\n    jmp 82f\n81:\n    add $16, %rsp\n    call hbc_bound_error\n82:\n");
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
fn cg_darr3_literal(es: &[Expr], env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    // Parent block of (ptr, len) pairs; each child is emitted by the
    // two-level literal emitter, which leaves the child in rax/rdx and
    // keeps rsp balanced, so the parent pointer survives in scratch.
    let k = es.len();
    out.push_str("    sub $16, %rsp\n"); // (%rsp)=outer ptr
    out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + k * 16));
    out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", k));
    for (j, child) in es.iter().enumerate() {
        match child {
            Expr::DArrNew => {
                out.push_str("    mov $8, %rdi\n    call hbc_alloc\n    movq $0, (%rax)\n    add $8, %rax\n");
                out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    movq $0, {}(%r11)\n", j * 16, j * 16 + 8));
            }
            Expr::ArrLit(inner) => {
                cg_darr2_literal(inner, env, sigs, strs, out, target);
                out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", j * 16, j * 16 + 8));
            }
            _ => unreachable!("checked"),
        }
    }
    out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $16, %rsp\n", k));
}

fn cg_darr2_literal(es: &[Expr], env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    let k = es.len();
    out.push_str("    sub $48, %rsp\n"); // (%rsp)=outer ptr, 8(%rsp)=child ptr
    out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + k * 16));
    out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", k));
    for (j, child) in es.iter().enumerate() {
        match child {
            Expr::DArrNew => {
                // An empty child owns a header-only block too (see the
                // DArrNew arm in cg_expr): NIL-grown slots stay (null, 0).
                out.push_str("    mov $8, %rdi\n    call hbc_alloc\n    movq $0, (%rax)\n    add $8, %rax\n");
                out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    movq $0, {}(%r11)\n", j * 16, j * 16 + 8));
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
        if es.iter().any(|x| matches!(x, Expr::ArrLit(inner) if inner.iter().any(|y| matches!(y, Expr::ArrLit(_) | Expr::DArrNew)))) {
            return cg_darr3_literal(es, env, sigs, strs, out, target);
        }
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
        Expr::SelfObj | Expr::SelfGet(_) | Expr::Send(_, _, _) => Ty::Dyn, // unreachable: the checker rejects them first
        Expr::Str(_) => Ty::Str,
        Expr::Var(id) => env.iter().find(|v| v.name == *id).expect("checked").ty,
        Expr::Call(id, args) => {
            if is_builtin(id, "array") { return match args.len() { 1 => Ty::DArr, 2 => Ty::DArr2, _ => Ty::DArr3 }; }
            if is_builtin(id, "hb_hkeys") { return Ty::DArrS; }
            if is_builtin(id, "eval") || is_builtin(id, "len") || is_builtin(id, "hb_memcheck") { return Ty::I64; }
            if is_builtin(id, "valtype") { return Ty::Str; } // hk88-hk92
            sigs.iter().find(|v| v.name == *id).expect("checked").ret.expect("checked")
        }
        Expr::Cmp(..) => Ty::Bool,
        Expr::ArrLit(es) => {
            if es.iter().any(|e| matches!(e, Expr::ArrLit(inner) if inner.iter().any(|x| matches!(x, Expr::ArrLit(_) | Expr::DArrNew)))) { Ty::DArr3 }
            else if es.iter().any(|e| matches!(e, Expr::ArrLit(_) | Expr::DArrNew)) { Ty::DArr2 } else { Ty::Arr(es.len()) }
        }
        Expr::Index(id, _) => match env.iter().find(|v| v.name == *id).map(|v| v.ty) {
            Some(Ty::Arr(_)) => Ty::I64,
            Some(Ty::DArrS) => Ty::StrOwn,
            _ => Ty::Dyn,
        },
        Expr::Index2(_, _, _) => Ty::Dyn,
        Expr::Index3(_, _, _, _) => Ty::Dyn,
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
                if matches!(t, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::StrOwn | Ty::Hash) {
                    darr_slots.push((*frame, if t == Ty::Hash { 2 } else if t == Ty::DArr3 { 3 } else if t == Ty::DArrS { 4 } else if t == Ty::StrOwn { 5 } else { (t == Ty::DArr2) as u8 }));
                }
            }
            Stmt::AAdd(_, id, e) => {
                // Replicate the checker's element-type pinning so later
                // expr_ty lookups and the epilogue agree with it.
                let vt = expr_ty(e, env, sigs);
                let mut flip = None;
                if let Some(v) = env.iter_mut().find(|v| v.name == *id) {
                    if v.ty == Ty::DArrU {
                        v.ty = if matches!(vt, Ty::DArr | Ty::DArrU) { Ty::DArr2 } else if matches!(vt, Ty::Str | Ty::StrOwn) { Ty::DArrS } else { Ty::DArr };
                        flip = Some((v.off, if v.ty == Ty::DArr2 { 1 } else if v.ty == Ty::DArrS { 4 } else { 0 }));
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
            Stmt::ForEach(_, var, coll, body) => {
                // No shadow push: several codegen lookups take the FIRST
                // name match, so the existing local is RETYPED to Dyn and
                // pointed at the hidden element slot for the body, then
                // restored (the outer slot is never written).
                *frame += 16; // hidden pair: collection (ptr, count)
                if matches!(coll, Expr::Call(..)) {
                    // A temporary collection (call result) is OWNED:
                    // registered so the prologue zeroes it and the
                    // epilogue frees it on every exit path.
                    let t = expr_ty(coll, env, sigs);
                    let class = if t == Ty::Hash { 2 } else if t == Ty::DArrS { 4 } else { 0 };
                    darr_slots.push((*frame, class));
                }
                *frame += 8; // hidden slot: 1-based iteration index
                *frame += 16; // loop variable: the current element as a Dyn
                let kl = env.iter().position(|v| v.name == *var).expect("checker found the local");
                let saved = (env[kl].ty, env[kl].off);
                env[kl].ty = Ty::Dyn;
                env[kl].off = *frame;
                layout_locals(body, env, sigs, frame, darr_slots, dyn_names);
                env[kl].ty = saved.0;
                env[kl].off = saved.1;
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
        Expr::Cmp(op, a, b) if (matches!(**a, Expr::Nil) && matches!(expr_ty(b, env, sigs), Ty::Str | Ty::StrOwn))
            || (matches!(**b, Expr::Nil) && matches!(expr_ty(a, env, sigs), Ty::Str | Ty::StrOwn)) => {
            // The result is a constant, but BOTH operands still evaluate
            // left to right (a call may print; an index may raise a bound
            // error) - only the comparison itself is folded (probe n1).
            // An owned temporary (e.g. keys[i]) is freed after evaluation.
            let a_tmp = expr_ty(a, env, sigs) == Ty::StrOwn && !matches!(&**a, Expr::Var(_));
            let b_tmp = expr_ty(b, env, sigs) == Ty::StrOwn && !matches!(&**b, Expr::Var(_));
            cg_value(a, env, sigs, strs, out, target);
            if a_tmp { out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"); }
            cg_value(b, env, sigs, strs, out, target);
            if b_tmp { out.push_str("    mov %rax, %rdi\n    mov $1, %esi\n    call hbc_free\n"); }
            if a_tmp { out.push_str("    mov (%rsp), %rdi\n    mov $1, %esi\n    call hbc_free\n    add $16, %rsp\n"); }
            if matches!(op, CmpOp::Ne) {
                out.push_str(&format!("    jmp {}\n", true_label));
            }
            // Eq: the condition is never true - fall through.
        }
        Expr::Cmp(op, a, b) if {
            let cas = |e: &Expr| matches!(e, Expr::Index(v, _) if env.iter().any(|x| x.name == *v && matches!(x.ty, Ty::DArr2 | Ty::DArr3)));
            matches!(op, CmpOp::Eq | CmpOp::Ne) && ((cas(a) && matches!(**b, Expr::Nil)) || (cas(b) && matches!(**a, Expr::Nil)))
        } => {
            // Casilla = NIL (oracle n4): the index evaluates ONCE
            // (bounds-checked); the child pointer 0 is the NIL casilla.
            // The NIL literal emits nothing.
            let (v, ie) = if let Expr::Index(v, ie) = &**a { (v, ie) } else if let Expr::Index(v, ie) = &**b { (v, ie) } else { unreachable!("guarded") };
            let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
            cg_expr(ie, env, sigs, strs, out, target);
            out.push_str(&format!("    cmp $1, %rax\n    jl 97f\n    cmp -{}(%rbp), %rax\n    jg 97f\n", var.off - 8));
            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
            out.push_str("    dec %rax\n    shl $4, %rax\n    mov 0(%r11,%rax), %rax\n");
            out.push_str("    test %rax, %rax\n    jmp 98f\n97:\n    call hbc_bound_error\n98:\n");
            let j = match op { CmpOp::Eq => "jz", _ => "jnz" };
            out.push_str(&format!("    {} {}\n", j, true_label));
        }
        Expr::Cmp(op, a, b) if expr_ty(a, env, sigs) == Ty::Dyn || expr_ty(b, env, sigs) == Ty::Dyn => {
            let ta = expr_ty(a, env, sigs);
            let tb = expr_ty(b, env, sigs);
            if ta == Ty::Str || tb == Ty::Str || ta == Ty::StrOwn || tb == Ty::StrOwn {
                // Dyn against a string: runtime dispatch on the Dyn
                // tag. tag 2 (string element, e.g. the FOR EACH
                // variable over hb_HKeys): a REAL Harbour comparison -
                // `=`/`#` via hbc_str_eq and ordering via hbc_str_cmp,
                // both over the right operand's length with the left
                // NUL-padded (xBase prefix rule; oracles hk33/hk37 and
                // hk36/hk39/hk40/hk43/hk51, same helpers as b23/b22).
                // tag 1 (NIL): `=` .F., `#` .T. (hk35, n1); ordering
                // raises Harbour's error condition. tag 0 (a number):
                // Harbour raises BASE/1071 `=`, BASE/1072 `#`,
                // BASE/1073 `<`, 1075 `>`, 1074 `<=`, 1076 `>=`
                // (hk34/hk38/hk42/hk44-hk46; hk41/hk47/hk49/hk50 for
                // NIL; error dialogs that hang headless) - clean named
                // exit 1 here (registered failure modes, not exact
                // equivalence). Both operands evaluate left to right;
                // an owned string temporary is freed after the
                // comparison.
                let a_tmp = ta == Ty::StrOwn && !matches!(&**a, Expr::Var(_));
                let b_tmp = tb == Ty::StrOwn && !matches!(&**b, Expr::Var(_));
                let tmp = a_tmp || b_tmp;
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
                // Normalize: rax,rdx = string (ptr,len); r10 = dyn tag,
                // r11 = dyn payload. The string side is the only one
                // that can be an owned temporary.
                if ta == Ty::Dyn {
                    out.push_str("    mov %rax, %r10\n    mov %rdx, %r11\n    mov %rcx, %rax\n    mov %r8, %rdx\n");
                } else {
                    out.push_str("    mov %rcx, %r10\n    mov %r8, %r11\n");
                }
                let lid = fresh_lbl();
                out.push_str(&format!("    cmp $2, %r10\n    je .Ldys{}\n", lid));
                match op {
                    CmpOp::Eq | CmpOp::Ne => {
                        out.push_str(&format!("    cmp $0, %r10\n    je .Ldyn{}\n", lid));
                        // tag 1 (NIL) or any other tag: the previous
                        // fold - `=` is .F., `#` is .T. (hk35, n1).
                        if tmp { out.push_str("    mov %rax, %rdi\n    mov $1, %esi\n    call hbc_free\n"); }
                        if matches!(op, CmpOp::Ne) {
                            out.push_str(&format!("    jmp {}\n", true_label));
                        }
                        out.push_str(&format!("    jmp .Ldye{}\n", lid));
                    }
                    _ => {
                        // Ordering: NIL (tag 1) and numeric (tag 0)
                        // casillas raise Harbour's error condition
                        // (BASE/1073-1076, hk41-hk50) - clean named
                        // exit 1, registered failure mode.
                        match op {
                            CmpOp::Lt => out.push_str("    call hbc_dyncmp_lt_error\n"),
                            CmpOp::Gt => out.push_str("    call hbc_dyncmp_gt_error\n"),
                            CmpOp::Le => out.push_str("    call hbc_dyncmp_le_error\n"),
                            CmpOp::Ge => out.push_str("    call hbc_dyncmp_ge_error\n"),
                            _ => unreachable!("Eq/Ne handled above"),
                        }
                    }
                }
                out.push_str(&format!(".Ldys{}:\n", lid));
                // tag 2: byte comparison. hbc_str_eq (=/#) and
                // hbc_str_cmp (ordering) both compare over the RIGHT
                // operand's length, so operand order matters.
                out.push_str("    sub $16, %rsp\n");
                if tmp { out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"); }
                if ta == Ty::Dyn {
                    // Dyn is the LEFT operand: lhs = dyn string.
                    out.push_str("    mov %rax, %rcx\n    mov %rdx, %r8\n    mov %r11, %rax\n    mov -8(%rax), %rdx\n");
                } else {
                    // Dyn is the RIGHT operand: rhs = dyn string.
                    out.push_str("    mov %r11, %rcx\n    mov -8(%r11), %r8\n");
                }
                match op {
                    CmpOp::Eq | CmpOp::Ne => out.push_str("    call hbc_str_eq\n"),
                    _ => out.push_str("    call hbc_str_cmp\n"),
                }
                if tmp {
                    out.push_str("    mov %rax, 16(%rsp)\n    mov (%rsp), %rdi\n    mov $1, %esi\n    call hbc_free\n    add $16, %rsp\n");
                } else {
                    out.push_str("    mov %rax, (%rsp)\n");
                }
                out.push_str("    mov (%rsp), %rax\n    add $16, %rsp\n");
                match op {
                    CmpOp::Eq | CmpOp::Ne => {
                        out.push_str("    test %rax, %rax\n");
                        let j = match op { CmpOp::Eq => "jnz", _ => "jz" };
                        out.push_str(&format!("    {} {}\n", j, true_label));
                        out.push_str(&format!("    jmp .Ldye{}\n.Ldyn{}:\n", lid, lid));
                        // tag 0: number against a string - Harbour's
                        // BASE/1071 for `=` (hk34) and BASE/1072 for
                        // `#` (hk38); clean named exit 1.
                        match op {
                            CmpOp::Eq => out.push_str("    call hbc_dyncmp_eq_error\n"),
                            _ => out.push_str("    call hbc_dyncmp_ne_error\n"),
                        }
                    }
                    CmpOp::Lt => out.push_str(&format!("    test %rax, %rax\n    js {}\n", true_label)),
                    CmpOp::Gt => out.push_str(&format!("    test %rax, %rax\n    jg {}\n", true_label)),
                    CmpOp::Le => out.push_str(&format!("    test %rax, %rax\n    jle {}\n", true_label)),
                    CmpOp::Ge => out.push_str(&format!("    test %rax, %rax\n    jns {}\n", true_label)),
                    _ => unreachable!("CmpOp variants"),
                }
                out.push_str(&format!(".Ldye{}:\n", lid));
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
        Expr::Cmp(op, a, b) if matches!(expr_ty(a, env, sigs), Ty::Str | Ty::StrOwn)
            && matches!(expr_ty(b, env, sigs), Ty::Str | Ty::StrOwn) => {
            // String equality/inequality: byte-compare via hbc_str_eq.
            // The lhs (ptr,len) pair is saved while the rhs is evaluated;
            // the comparison borrows both operands (no move). Owned
            // temporaries (reads like keys[i]) are freed AFTER the call,
            // with the result preserved across the frees.
            let a_tmp = expr_ty(a, env, sigs) == Ty::StrOwn && !matches!(&**a, Expr::Var(_));
            let b_tmp = expr_ty(b, env, sigs) == Ty::StrOwn && !matches!(&**b, Expr::Var(_));
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
            if a_tmp || b_tmp {
                // Stack above the compare (top first): result slot, then
                // the b-temp pointer, then the a-temp pointer.
                let nt = a_tmp as usize + b_tmp as usize;
                out.push_str("    sub $16, %rsp\n");
                if b_tmp { out.push_str("    sub $16, %rsp\n    mov %rcx, (%rsp)\n"); }
                if a_tmp { out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"); }
                match op {
                    CmpOp::Eq | CmpOp::Ne => { out.push_str("    call hbc_str_eq\n"); }
                    _ => { out.push_str("    call hbc_str_cmp\n"); }
                }
                out.push_str(&format!("    mov %rax, {}(%rsp)\n", 16 * nt));
                if a_tmp { out.push_str(&format!("    mov {}(%rsp), %rdi\n    mov $1, %esi\n    call hbc_free\n", 16 * (b_tmp as usize))); }
                if b_tmp { out.push_str("    mov (%rsp), %rdi\n    mov $1, %esi\n    call hbc_free\n"); }
                out.push_str(&format!("    mov {}(%rsp), %rax\n    add ${}, %rsp\n", 16 * nt, 16 * (nt + 1)));
            }
            let j = match op {
                CmpOp::Eq | CmpOp::Ne => {
                    if !a_tmp && !b_tmp { out.push_str("    call hbc_str_eq\n"); }
                    out.push_str("    test %rax, %rax\n");
                    match op { CmpOp::Eq => "jnz", _ => "jz" }
                }
                _ => {
                    // hbc_str_cmp returns -1, 0 or 1 (byte-wise, like memcmp)
                    if !a_tmp && !b_tmp { out.push_str("    call hbc_str_cmp\n"); }
                    out.push_str("    cmp $0, %rax\n");
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
                CmpOp::EqEq => unreachable!("rejected before codegen"),
            };
            out.push_str(&format!("    {} {}\n", j, true_label));
        }
        _ => unreachable!("analysis requires a comparison as the `if` condition"),
    }
}

fn cg_stmts(stmts: &[Stmt], env: &mut Vec<CgLocal>, frame: &mut usize, sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target, fname: &str, label: &mut usize, ll: &Option<(String, String)>, slots: &[(usize, u8)], dyn_names: &std::collections::HashSet<String>) {
    for s in stmts {
        match s {
            Stmt::SelfSet(..) | Stmt::SendSet(..) | Stmt::SendStmt(..) => unreachable!("rejected before codegen"),
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
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::StrOwn | Ty::Hash)) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                            }
                        }
                        match t {
                            Ty::I64 | Ty::Block(_) => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off)),
                            Ty::Str | Ty::Dyn => {
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::StrOwn | Ty::Hash => {
                                // The slot can hold a live value when a
                                // `local` re-declares inside a loop body:
                                // free the old allocation first (null-safe).
                                // The new value waits on the stack: hbc_free
                                // clobbers caller-saved registers (syscall).
                                let class = slots.iter().find(|(o, _)| *o == off).map(|(_, c)| *c).unwrap_or(0);
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                if class == 1 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    call hbc_free2\n85:\n", off, off - 8));
                                } else if class == 3 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    mov $2, %edx\n    call hbc_rfree\n85:\n", off, off - 8));
                                } else if class == 2 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    call hbc_hfree\n85:\n", off, off - 8));
                                } else if class == 4 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    call hbc_sfree\n85:\n", off, off - 8));
                                } else if class == 5 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov $1, %esi\n    call hbc_free\n85:\n", off));
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
                let darr2_child = |e: &Expr, env: &[CgLocal]| matches!(e, Expr::Index(v, _) if env.iter().any(|x| x.name == *v && x.ty == Ty::DArr2));
                let darrs_elem = |e: &Expr, env: &[CgLocal]| matches!(e, Expr::Index(v, _) if env.iter().any(|x| x.name == *v && x.ty == Ty::DArrS));
                // A whole array/hash VARIABLE renders empty
                // (hk16/hk20/hk24): only borrowed, never consumed.
                let renders_empty = |e: &Expr| matches!(expr_ty(e, env, sigs), Ty::Arr(_) | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::Hash | Ty::DArrRef | Ty::DArrRef2);
                for e in es {
                    if let Expr::Index(v, ie) = e {
                        if darr2_child(e, env) {
                            // Push the child pointer (0 marks a NIL
                            // casilla); bounds-checked like len(a[i]).
                            let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                            cg_expr(ie, env, sigs, strs, out, target);
                            out.push_str(&format!("    cmp $1, %rax\n    jl 93f\n    cmp -{}(%rbp), %rax\n    jg 93f\n", var.off - 8));
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                            out.push_str("    dec %rax\n    shl $4, %rax\n    mov 0(%r11,%rax), %rax\n    jmp 94f\n93:\n    call hbc_bound_error\n94:\n");
                            out.push_str("    xor %edx, %edx\n    push %rdx\n    push %rax\n");
                            continue;
                        }
                    }
                    if let Expr::Index(v, ie) = e {
                        if darrs_elem(e, env) {
                            // Push the raw element pair {payload, tag}
                            // (no copy): a grown NIL casilla prints NIL
                            // (hk13), a string element prints borrowed.
                            let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                            if expr_ty(ie, env, sigs) == Ty::Dyn {
                                cg_expr(ie, env, sigs, strs, out, target);
                                out.push_str("    call hbc_dyn_to_i64\n");
                            } else {
                                cg_expr(ie, env, sigs, strs, out, target);
                            }
                            out.push_str(&format!("    cmp $1, %rax\n    jl 93f\n    cmp -{}(%rbp), %rax\n    jg 93f\n", var.off - 8));
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                            out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov 8(%rax), %rcx\n    mov (%rax), %rax\n    jmp 94f\n93:\n    call hbc_bound_error\n94:\n");
                            out.push_str("    push %rax\n    push %rcx\n");
                            continue;
                        }
                    }
                    if renders_empty(e) {
                        // The pair is never consumed; the variable is
                        // only borrowed (hk23: alive after printing).
                        out.push_str("    xor %eax, %eax\n    push %rax\n    push %rax\n");
                        continue;
                    }
                    cg_value(e, env, sigs, strs, out, target);
                    out.push_str("    push %rdx\n    push %rax\n");
                }
                out.push_str("    call hbc_print_nl\n");
                // Harbour renders a whole dynamic array or hash as
                // NOTHING (oracles hk16/hk20/hk21/hk24) and QOut
                // space-trims the END of the line (hk22/hk24/hk25);
                // interior spacing is preserved exactly
                // (`? "ab  ", 5` keeps the string's trailing spaces).
                // The trim is reproduced by dropping the static suffix
                // of empty-rendering items together with their preceding
                // separators, and by right-trimming a surviving trailing
                // string at runtime (numbers never trail spaces).
                // Registered edge: a trailing ALL-SPACES string still
                // leaves the separator before it in this PoC; exact
                // fidelity there needs a buffered line.
                let last_vis = es.iter().rposition(|e| !renders_empty(e));
                // Right-trim spaces (0x20) off %rdx bytes at %rax.
                let rtrim = "97:    cmp $0, %rdx\n    je 98f\n    cmpb $0x20, -1(%rax,%rdx)\n    jne 98f\n    dec %rdx\n    jmp 97b\n98:\n";
                for (i, e) in es.iter().enumerate() {
                    if last_vis.map_or(true, |lv| i > lv) { break; }
                    let t = expr_ty(e, env, sigs);
                    let off = 16 * (es.len() - 1 - i);
                    if i > 0 { out.push_str("    call hbc_print_sep\n"); }
                    if renders_empty(e) { continue; }
                    let is_last = last_vis == Some(i);
                    if darrs_elem(e, env) {
                        // A grown NIL casilla prints NIL (hk13); a string
                        // element prints its bytes, borrowed (no copy).
                        // As the last visible item the string is trimmed
                        // at the line end like any other string (hk25).
                        out.push_str(&format!("    mov {}(%rsp), %rax\n    mov {}(%rsp), %rdx\n", off, off + 8));
                        if is_last {
                            out.push_str("    cmp $2, %rdx\n    jne 95f\n    mov -8(%rax), %rdx\n");
                            out.push_str(rtrim);
                            out.push_str("    call hbc_print_str\n    jmp 96f\n95:\n    mov $1, %rax\n    xor %edx, %edx\n    call hbc_print_dyn\n96:\n");
                        } else {
                            out.push_str("    cmp $2, %rdx\n    jne 95f\n    mov -8(%rax), %rdx\n    call hbc_print_str\n    jmp 96f\n95:\n    mov $1, %rax\n    xor %edx, %edx\n    call hbc_print_dyn\n96:\n");
                        }
                        continue;
                    }
                    if darr2_child(e, env) {
                        // A NIL casilla prints NIL (n1); a live child
                        // prints nothing (n5).
                        out.push_str(&format!("    mov {}(%rsp), %rax\n", off));
                        out.push_str("    test %rax, %rax\n    jz 95f\n    jmp 96f\n95:\n    mov $1, %rax\n    xor %edx, %edx\n    call hbc_print_dyn\n96:\n");
                        continue;
                    }
                    out.push_str(&format!("    mov {}(%rsp), %rax\n    mov {}(%rsp), %rdx\n", off, off + 8));
                    match t {
                        Ty::I64 => out.push_str("    call hbc_print_i64\n"),
                        Ty::Str | Ty::StrOwn => {
                            // Line-end space trim (hk22/hk24): only the
                            // LAST visible item can trail spaces.
                            if is_last { out.push_str(rtrim); }
                            out.push_str("    call hbc_print_str\n");
                            if t == Ty::StrOwn && !matches!(e, Expr::Var(_)) {
                                // A temporary copy (e.g. `? keys[i]`): the
                                // item owns it and frees it right after
                                // printing; the array keeps its own copy.
                                out.push_str(&format!("    mov {}(%rsp), %rdi\n    mov $1, %esi\n    call hbc_free\n", off));
                            }
                        }
                        Ty::Dyn => out.push_str("    call hbc_print_dyn\n"),
                        Ty::Bool => unreachable!("booleans rejected in analysis"),
                        Ty::Arr(_) => unreachable!("whole-array printing rejected in analysis"),
                        Ty::Block(_) => unreachable!("codeblock printing rejected in analysis"),
                        Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::DArrRef | Ty::DArrRef2 => unreachable!("whole-array printing rejected in analysis"),
                        Ty::Hash => unreachable!("whole-hash printing rejected in analysis"),
                    }
                }
                if !es.is_empty() {
                    out.push_str(&format!("    add ${}, %rsp\n", 16 * es.len()));
                }
            }
            Stmt::Ret(_, Some(e)) => {
                if let Ty::Arr(k) = expr_ty(e, env, sigs) {
                    // Static array return: materialize the boundary COPY
                    // as a dynamic array (same shape as the argument
                    // copy, 33l); the caller owns and frees it (33m).
                    if let Expr::Var(src) = e {
                        let sv = env.iter().rev().find(|x| x.name == *src).expect("checked").clone();
                        out.push_str("    sub $16, %rsp\n");
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + k * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", k));
                        for p in 0..k {
                            out.push_str(&format!("    mov -{}(%rbp), %r10\n", sv.off - 8 * p));
                            out.push_str(&format!("    mov (%rsp), %r11\n    movq $0, {}(%r11)\n    mov %r10, {}(%r11)\n", p * 16, p * 16 + 8));
                        }
                        out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $16, %rsp\n", k));
                        out.push_str(&format!("    jmp .Lret_{}\n", fname));
                    }
                } else {
                cg_value(e, env, sigs, strs, out, target);
                // Mixed int/NIL returns unify to Dyn (probe n2): an i64
                // return expression is tagged into the {0, payload} pair.
                if expr_ty(e, env, sigs) == Ty::I64
                    && sigs.iter().any(|sg| sg.name == fname && sg.ret == Some(Ty::Dyn)) {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                // A rodata string returned under an owned-string signature
                // (Str/StrOwn unification): the caller owns the result, so
                // the return point hands over a fresh copy.
                if expr_ty(e, env, sigs) == Ty::Str
                    && sigs.iter().any(|sg| sg.name == fname && sg.ret == Some(Ty::StrOwn)) {
                    out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                }
                // Returning a dynamic array MOVES it to the caller: the
                // source slot is nulled BEFORE the shared epilogue runs, so
                // the epilogue never frees the returned allocation (parent
                // rule: move the return to the output before cleanup).
                if let Expr::Var(src) = e {
                    if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::StrOwn | Ty::Hash)) {
                        out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                    }
                }
                out.push_str(&format!("    jmp .Lret_{}\n", fname));
                }
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
            Stmt::ForEach(_, var, coll, body) => {
                let id = *label;
                *label += 1;
                let mark = env.len();
                // The collection is evaluated ONCE into a hidden pair.
                // A VARIABLE is borrowed (never freed here); a CALL
                // RESULT is an owned temporary in a registered slot:
                // the prologue zeroed it and the epilogue frees it on
                // every exit path (natural, `exit`, `return`), so a
                // statement that runs again (an enclosing loop) must
                // free the previous temporary first. The index is
                // 1-based like Harbour. The current element is rebuilt
                // as a Dyn pair on every iteration: {tag, payload}
                // directly from the 16-byte array cells, the value
                // words of the 32-byte hash entries, or a tag-0 pair
                // for static i64 arrays.
                *frame += 16;
                let coll_off = *frame;
                if matches!(coll, Expr::Call(..)) {
                    let fl = fresh_lbl();
                    match expr_ty(coll, env, sigs) {
                        Ty::Hash => out.push_str(&format!("    mov -{}(%rbp), %rdi
    test %rdi, %rdi
    je .Lfetf{}
    mov -{}(%rbp), %rsi
    call hbc_hfree
.Lfetf{}:
    movq $0, -{}(%rbp)
", coll_off, fl, coll_off - 8, fl, coll_off)),
                        Ty::DArrS => out.push_str(&format!("    mov -{}(%rbp), %rdi
    test %rdi, %rdi
    je .Lfetf{}
    mov -{}(%rbp), %rsi
    call hbc_sfree
.Lfetf{}:
    movq $0, -{}(%rbp)
", coll_off, fl, coll_off - 8, fl, coll_off)),
                        _ => out.push_str(&format!("    mov -{}(%rbp), %rdi
    test %rdi, %rdi
    je .Lfetf{}
    mov $16, %esi
    call hbc_free
.Lfetf{}:
    movq $0, -{}(%rbp)
", coll_off, fl, fl, coll_off)),
                    }
                }
                if let Expr::Index(id, ie) = coll {
                    if matches!(env.iter().rev().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr2)) {
                        // Borrow the child (ptr, len) from the root's
                        // cell: the index evaluates ONCE and is
                        // bounds-checked; a NIL casilla (null child)
                        // is Harbour's BASE/1068 condition (hk58) -
                        // hbc_arracc_error, a clean named exit 1,
                        // registered failure mode. Nothing owned here.
                        let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
                        if expr_ty(ie, env, sigs) == Ty::Dyn {
                            cg_expr(ie, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64\n");
                        } else {
                            cg_expr(ie, env, sigs, strs, out, target);
                        }
                        let fl2 = fresh_lbl();
                        out.push_str(&format!("    cmp $1, %rax\n    jl .Lfeb{}\n    cmp -{}(%rbp), %rax\n    jg .Lfeb{}\n", fl2, v.off - 8, fl2));
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov 8(%rax), %rdx\n    mov (%rax), %rcx\n    test %rcx, %rcx\n    je .Lfen{}\n    mov %rcx, %rax\n    jmp .Lfeo{}\n.Lfeb{}:\n    call hbc_bound_error\n.Lfen{}:\n    call hbc_arracc_error\n.Lfeo{}:\n", v.off, fl2, fl2, fl2, fl2, fl2));
                    } else {
                        cg_value(coll, env, sigs, strs, out, target);
                    }
                } else if let Expr::Index2(id, ie, ie2) = coll {
                    if matches!(env.iter().rev().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr3)) {
                        // Depth-3 borrow (hk60-hk64): evaluate each index
                        // ONCE, bounds-check each level, load the level-2
                        // then the level-1 cell; a NIL casilla at either
                        // level is the BASE/1068 failure mode
                        // (hbc_arracc_error). Nothing owned here.
                        let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
                        if expr_ty(ie, env, sigs) == Ty::Dyn {
                            cg_expr(ie, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64
");
                        } else {
                            cg_expr(ie, env, sigs, strs, out, target);
                        }
                        let fl2 = fresh_lbl();
                        out.push_str(&format!("    cmp $1, %rax
    jl .Lfeb{}
    cmp -{}(%rbp), %rax
    jg .Lfeb{}
", fl2, v.off - 8, fl2));
                        out.push_str(&format!("    mov -{}(%rbp), %r11
    dec %rax
    shl $4, %rax
    add %r11, %rax
    mov 8(%rax), %rdx
    mov (%rax), %rcx
    test %rcx, %rcx
    je .Lfen{}
    push %rcx
    push %rdx
", v.off, fl2));
                        if expr_ty(ie2, env, sigs) == Ty::Dyn {
                            cg_expr(ie2, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64
");
                        } else {
                            cg_expr(ie2, env, sigs, strs, out, target);
                        }
                        out.push_str(&format!("    pop %rdx
    pop %rcx
    cmp $1, %rax
    jl .Lfeb{}
    cmp %rdx, %rax
    jg .Lfeb{}
    dec %rax
    shl $4, %rax
    add %rcx, %rax
    mov 8(%rax), %rdx
    mov (%rax), %rcx
    test %rcx, %rcx
    je .Lfen{}
    mov %rcx, %rax
    jmp .Lfeo{}
.Lfeb{}:
    call hbc_bound_error
.Lfen{}:
    call hbc_arracc_error
.Lfeo{}:
", fl2, fl2, fl2, fl2, fl2, fl2, fl2));
                    } else {
                        cg_value(coll, env, sigs, strs, out, target);
                    }
                } else {
                    cg_value(coll, env, sigs, strs, out, target);
                }
                out.push_str(&format!("    mov %rax, -{}(%rbp)
    mov %rdx, -{}(%rbp)
", coll_off, coll_off - 8));
                *frame += 8;
                let idx_off = *frame;
                out.push_str(&format!("    movq $1, -{}(%rbp)
", idx_off));
                *frame += 16;
                let lv_off = *frame;
                let ct = expr_ty(coll, env, sigs);
                let kl = env.iter().position(|v| v.name == *var).expect("checker found the local");
                let saved_lv = (env[kl].ty, env[kl].off);
                env[kl].ty = Ty::Dyn;
                env[kl].off = lv_off;
                out.push_str(&format!(".Lfec_{}_{}:
", fname, id));
                out.push_str(&format!("    mov -{}(%rbp), %rax
    cmp -{}(%rbp), %rax
    jg .Lfee_{}_{}
", idx_off, coll_off - 8, fname, id));
                out.push_str(&format!("    mov -{}(%rbp), %r11
    mov -{}(%rbp), %rax
    dec %rax
", coll_off, idx_off));
                match ct {
                    Ty::Arr(_) => out.push_str("    shl $3, %rax
    add %r11, %rax
    mov (%rax), %rdx
    xor %eax, %eax
"),
                    Ty::Hash => out.push_str("    shl $5, %rax
    add %r11, %rax
    mov 16(%rax), %rcx
    mov 24(%rax), %rdx
    mov %rcx, %rax
"),
                    _ => out.push_str("    shl $4, %rax
    add %r11, %rax
    mov (%rax), %rcx
    mov 8(%rax), %rdx
    mov %rcx, %rax
"),
                }
                out.push_str(&format!("    mov %rax, -{}(%rbp)
    mov %rdx, -{}(%rbp)
", lv_off, lv_off - 8));
                let inner = Some((format!(".Lfen_{}_{}", fname, id), format!(".Lfee_{}_{}", fname, id)));
                cg_stmts(body, env, frame, sigs, strs, out, target, fname, label, &inner, slots, dyn_names);
                env[kl].ty = saved_lv.0;
                env[kl].off = saved_lv.1;
                env.truncate(mark);
                out.push_str(&format!(".Lfen_{}_{}:
    incq -{}(%rbp)
    jmp .Lfec_{}_{}
", fname, id, idx_off, fname, id));
                out.push_str(&format!(".Lfee_{}_{}:
", fname, id));
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
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::StrOwn | Ty::Hash)) {
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
                            Ty::StrOwn => {
                                // Free the OLD owned copy after the RHS
                                // exists (fresh slots are zero-initialised,
                                // so the guard sees null), then store.
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov $1, %esi\n    call hbc_free\n86:\n", off));
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
                            }
                            Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArrS | Ty::Hash => {
                                // Free the OLD value after the RHS exists
                                // (self-assignment `a := a` moved through a
                                // temporary: the source was nulled above, so
                                // the free sees null and nothing is dropped
                                // twice). The free kind follows the slot's
                                // CURRENT type (the old value's type).
                                let cur_ty = env.iter().find(|x| x.name == *id).map(|x| x.ty);
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                if cur_ty == Some(Ty::DArrS) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    call hbc_sfree\n86:\n", off, off - 8));
                                } else if cur_ty == Some(Ty::DArr2) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    call hbc_free2\n86:\n", off, off - 8));
                                } else if cur_ty == Some(Ty::DArr3) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    mov $2, %edx\n    call hbc_rfree\n86:\n", off, off - 8));
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
                // DArrRef (borrowed middle array): the slot holds the child
                // cell's ADDRESS - feed THAT to hbc_aadd exactly like the
                // middle arm does, so growth reallocates through the
                // owner's cell (oracle hk78).
                let aptr = if v.ty == Ty::DArrRef || v.ty == Ty::DArrRef2 { format!("mov -{}(%rbp), %rdi", v.off) } else { format!("lea -{}(%rbp), %rdi", v.off) };
                if v.ty == Ty::DArrS || (v.ty == Ty::DArrU && matches!(vt, Ty::Str | Ty::StrOwn)) {
                    // String element: a rodata value is copied (the array
                    // owns the copy); an owned value moves in (its source
                    // slot is nulled). The appended pair is {tag 2, ptr}.
                    cg_value(e, env, sigs, strs, out, target);
                    if vt == Ty::Str {
                        out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                    }
                    if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src && x.ty == Ty::StrOwn) {
                            out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                        }
                    }
                    out.push_str("    mov %rax, %r11\n    sub $16, %rsp\n    movq $2, (%rsp)\n    mov %r11, 8(%rsp)\n");
                    out.push_str(&format!("    mov %rsp, %rdx\n    mov $16, %esi\n    {}\n    call hbc_aadd\n    add $16, %rsp\n", aptr));
                } else if v.ty == Ty::DArr2 || v.ty == Ty::DArrRef2 || (v.ty == Ty::DArrU && matches!(vt, Ty::DArr | Ty::DArrU)) {
                    // Insert a dynamic array: the value MOVES into the
                    // parent (null the source right after the load). A
                    // static literal materializes as a dynamic child
                    // (header + tagged cells, the same shape as the
                    // middle arm's materialization - oracle hk94).
                    if let Expr::ArrLit(inner) = e {
                        let m = inner.len();
                        out.push_str("    sub $16, %rsp\n");
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", m));
                        for (p, xe) in inner.iter().enumerate() {
                            cg_expr(xe, env, sigs, strs, out, target);
                            if expr_ty(xe, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p * 16, p * 16 + 8));
                        }
                        out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $16, %rsp\n", m));
                    } else {
                        cg_value(e, env, sigs, strs, out, target);
                        if let Expr::Var(src) = e {
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3)) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                            }
                        }
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    out.push_str(&format!("    mov %rsp, %rdx\n    mov $16, %esi\n    {}\n    call hbc_aadd\n    add $16, %rsp\n", aptr));
                } else {
                    // Scalar element: tag it into the {tag, payload} pair
                    // (i64 -> {0, v}, NIL/Dyn -> copied pair).
                    cg_expr(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::I64 {
                        out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    out.push_str(&format!("    mov %rsp, %rdx\n    mov $16, %esi\n    {}\n    call hbc_aadd\n    add $16, %rsp\n", aptr));
                }
                // Replicate the checker's pinning of `{}`.
                if let Some(x) = env.iter_mut().find(|x| x.name == *id) {
                    if x.ty == Ty::DArrU {
                        x.ty = if matches!(vt, Ty::DArr | Ty::DArrU) { Ty::DArr2 } else if matches!(vt, Ty::Str | Ty::StrOwn) { Ty::DArrS } else { Ty::DArr };
                    }
                }
            }
            Stmt::ASize(_, id, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                // kind 0: flat (grow NIL). kind 1: arrays (grow the empty
                // child; shrink frees children). kind 2: strings (shrink
                // frees the copies; grow is a clean runtime error here -
                // Harbour grows with NIL, oracle hk13).
                // kind 3: three levels (grow NIL casillas like kind 1;
                // shrink frees removed children RECURSIVELY via
                // hbc_rfree - they own their own children).
                let kind = if v.ty == Ty::DArr2 { 1 } else if v.ty == Ty::DArrS { 2 } else if v.ty == Ty::DArr3 || v.ty == Ty::DArrRef2 { 3 } else { 0 };
                // DArrRef: address of the owner's cell, like AAdd (hk87).
                let aptr = if v.ty == Ty::DArrRef || v.ty == Ty::DArrRef2 { format!("mov -{}(%rbp), %rdi", v.off) } else { format!("lea -{}(%rbp), %rdi", v.off) };
                cg_expr(e, env, sigs, strs, out, target);
                out.push_str(&format!("    mov %rax, %rsi\n    mov $16, %edx\n    mov ${}, %ecx\n    {}\n    call hbc_asize\n",
                    kind, aptr));
            }
            Stmt::AAddSub(_, id, ie, e) => {
                // AAdd(a[i], x): index FIRST, then the value (probe m7;
                // same order at the middle level, hk67).
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                if v.ty == Ty::DArr3 {
                    // Array element: a static literal materializes as a
                    // dynamic child (header + tagged cells, same shape as
                    // cg_darr2_literal's inner block); a call result or a
                    // variable MOVES in (source nulled right after the
                    // load - the move contract of root AAdd, NOT Harbour
                    // sharing; D5/D7 registered).
                    if let Expr::ArrLit(inner) = e {
                        let m = inner.len();
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, 8(%rsp)\n", m));
                        for (p, xe) in inner.iter().enumerate() {
                            cg_expr(xe, env, sigs, strs, out, target);
                            if expr_ty(xe, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            out.push_str(&format!("    mov 8(%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p * 16, p * 16 + 8));
                        }
                        out.push_str(&format!("    mov 8(%rsp), %rax\n    mov ${}, %edx\n", m));
                    } else {
                        cg_value(e, env, sigs, strs, out, target);
                        if let Expr::Var(src) = e {
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3)) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                            }
                        }
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                } else {
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                }
                out.push_str("    mov 16(%rsp), %rcx\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                // A NIL casilla (fresh ASize growth) is Harbour's
                // BASE/1123 (hangs headless, oracle n6): clean error.
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_aadd_error\n");
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
                // A NIL casilla is Harbour's BASE/2023 (hangs headless,
                // oracle n7): clean error.
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_asize_error\n");
                // DArr3 root: the middle child owns innermost arrays,
                // so its shrink frees them (kind 1); a DArr2 subarray is
                // flat (kind 0).
                let kind = if v.ty == Ty::DArr3 { 1 } else { 0 };
                out.push_str(&format!("    mov %rax, %rsi\n    mov $16, %edx\n    mov ${}, %ecx\n    call hbc_asize\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n", kind));
            }
            Stmt::AAddSub2(_, id, ie, ie2, e) => {
                // AAdd(a[i][j], x): i first, then j, then the value
                // (oracle pr8). Two bounds-checked pair walks; a null
                // child at either level is the clean AAdd error.
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                for iex in [ie, ie2] {
                    if expr_ty(iex, env, sigs) == Ty::Dyn {
                        cg_expr(iex, env, sigs, strs, out, target);
                        out.push_str("    call hbc_dyn_to_i64\n");
                    } else {
                        cg_expr(iex, env, sigs, strs, out, target);
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                }
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                // stack: [value 16][j 16][i 16]
                out.push_str("    mov 32(%rsp), %rcx\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_aadd_error\n");
                out.push_str("    mov 16(%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%rdi), %rcx\n    jg 87f\n");
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r10, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_aadd_error\n");
                out.push_str("    mov %rsp, %rdx\n    mov $16, %esi\n    call hbc_aadd\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                out.push_str("    add $48, %rsp\n");
            }
            Stmt::ASizeSub2(_, id, ie, ie2, e) => {
                // ASize(a[i][j], n): i first, then j, then the size
                // (oracle pr8). Grow zero-fills fresh slots (they read
                // NIL via the Dyn tag, probe pr8); shrink frees.
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(ie2, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(e, env, sigs, strs, out, target);
                // rax = size; stack: [j 16][i 16]
                out.push_str("    mov 16(%rsp), %rcx\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_asize_error\n");
                out.push_str("    mov (%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%rdi), %rcx\n    jg 87f\n");
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r10, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_asize_error\n");
                out.push_str("    mov %rax, %rsi\n    mov $16, %edx\n    xor %ecx, %ecx\n    call hbc_asize\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                out.push_str("    add $32, %rsp\n");
            }
            Stmt::ArrSet(_, id, ie, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                if v.ty == Ty::DArr2 {
                    // Child overwrite: RHS (a dynamic array) moves in; the
                    // OLD child is freed once, AFTER the new value exists
                    // and the source was nulled (no double free).
                    if let Expr::ArrLit(inner) = e {
                        // i64 literal -> Dyn-element child (same shape as
                        // nested-literal children; oracle n3).
                        let m = inner.len();
                        out.push_str("    sub $16, %rsp\n");
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", m));
                        for (p2, ie2) in inner.iter().enumerate() {
                            cg_expr(ie2, env, sigs, strs, out, target);
                            if expr_ty(ie2, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p2 * 16, p2 * 16 + 8));
                        }
                        out.push_str(&format!("    mov (%rsp), %rax\n    add $16, %rsp\n    mov ${}, %rdx\n", m));
                    } else {
                        cg_value(e, env, sigs, strs, out, target);
                    }
                    if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3)) {
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
                } else if v.ty == Ty::DArrS {
                    // Element overwrite on an array of strings: the value
                    // evaluates FIRST (probe adv2's order), a rodata value
                    // is copied and an owned one moves in; the OLD owned
                    // copy is freed once, after the new one exists.
                    cg_value(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::Str {
                        out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                    }
                    if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src && x.ty == Ty::StrOwn) {
                            out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                        }
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, %rcx\n");
                    out.push_str(&format!("    cmp $1, %rcx\n    jl 89f\n    cmp -{}(%rbp), %rcx\n    jg 89f\n", v.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                    out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    // free the old owned copy (payload at 8(entry); a
                    // NIL casilla from ASize growth has a null payload,
                    // skipped here and RETAGGED to a string below - hk14)
                    out.push_str("    mov 8(%r10), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov $1, %esi\n    sub $16, %rsp\n    mov %r10, (%rsp)\n    call hbc_free\n    mov (%rsp), %r10\n    add $16, %rsp\n85:\n");
                    out.push_str("    mov (%rsp), %rax\n    movq $2, (%r10)\n    mov %rax, 8(%r10)\n    add $16, %rsp\n    jmp 86f\n89:\n    call hbc_bound_error\n86:\n");
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
                    let temp_key = expr_ty(ie, env, sigs) == Ty::StrOwn && !matches!(ie, Expr::Var(_));
                    if temp_key {
                        // Owned key copy (h[keys[i]] := v): hbc_hput copies
                        // the bytes, so the temporary is freed right after.
                        out.push_str("    sub $16, %rsp\n    mov %rsi, (%rsp)\n");
                        out.push_str(&format!("    lea -{}(%rbp), %rdi\n    lea 16(%rsp), %rcx\n    call hbc_hput\n    mov (%rsp), %rdi\n    mov $1, %esi\n    call hbc_free\n    add $32, %rsp\n", v.off));
                    } else {
                        out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov %rsp, %rcx\n    call hbc_hput\n    add $16, %rsp\n", v.off));
                    }
                } else if v.ty == Ty::DArr || v.ty == Ty::DArrRef {
                    // Dynamic array write: same value-first order; bounds
                    // 1..=len from the slot word. Elements are {tag,
                    // payload} pairs. Borrows `a` - never nulls.
                    // DArrRef (a borrowed middle array): the slot holds the
                    // child cell's ADDRESS; bounds and base load through it
                    // so the write lands in the owner's cell (oracle hk86).
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
                    if v.ty == Ty::DArrRef {
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rcx\n    jl 83f\n    cmp 8(%r11), %rcx\n    jg 83f\n", v.off));
                        out.push_str("    mov (%r11), %r11\n");
                    } else {
                        out.push_str(&format!("    cmp $1, %rcx\n    jl 83f\n    cmp -{}(%rbp), %rcx\n    jg 83f\n", v.off - 8));
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                    }
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
                if v.ty == Ty::DArrRef2 {
                    // p[i][j] := v through the borrowed middle of a
                    // three-level array (hk95): root bounds and base load
                    // through the owner's cell address, the write lands
                    // in the owner's innermost cell.
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rcx\n    jl 90f\n    cmp 8(%r11), %rcx\n    jg 90f\n", v.off));
                    out.push_str("    mov (%r11), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                } else {
                out.push_str(&format!("    cmp $1, %rcx\n    jl 90f\n    cmp -{}(%rbp), %rcx\n    jg 90f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                }
                out.push_str("    cmp $1, %r9\n    jl 90f\n    cmp 8(%r10), %r9\n    jg 90f\n");
                out.push_str("    mov (%r10), %r11\n    dec %r9\n    shl $4, %r9\n    add %r11, %r9\n    mov %rax, (%r9)\n    mov %rdx, 8(%r9)\n    jmp 92f\n90:\n    call hbc_bound_error\n92:\n");
            }
            Stmt::ArrSet3(_, id, ie, ie2, ie3, e) => {
                // a[i][j][k] := v: value first, then the indices left to
                // right (probe m7 order); every level bounds checked; a
                // null child pointer is a bound error (same as reads).
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                for iex in [ie, ie2] {
                    if expr_ty(iex, env, sigs) == Ty::Dyn {
                        cg_expr(iex, env, sigs, strs, out, target);
                        out.push_str("    call hbc_dyn_to_i64\n");
                    } else {
                        cg_expr(iex, env, sigs, strs, out, target);
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                }
                if expr_ty(ie3, env, sigs) == Ty::Dyn {
                    cg_expr(ie3, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie3, env, sigs, strs, out, target);
                }
                // rax = k; pop j -> rcx, i -> r10, value -> rax(tag)/rdx(payload)
                out.push_str("    mov %rax, %r9\n    mov (%rsp), %rcx\n    add $16, %rsp\n    mov (%rsp), %r10\n    add $16, %rsp\n    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
                // level 1: i in r10 against the outer length
                out.push_str(&format!("    cmp $1, %r10\n    jl 90f\n    cmp -{}(%rbp), %r10\n    jg 90f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                // level 2: j in rcx against the child length
                out.push_str("    cmp $1, %rcx\n    jl 90f\n    cmp 8(%r10), %rcx\n    jg 90f\n    mov (%r10), %r11\n    test %r11, %r11\n    jz 90f\n    dec %rcx\n    shl $4, %rcx\n    add %r11, %rcx\n");
                // level 3: k in r9 against the innermost length
                out.push_str("    cmp $1, %r9\n    jl 90f\n    cmp 8(%rcx), %r9\n    jg 90f\n    mov (%rcx), %r11\n    test %r11, %r11\n    jz 90f\n    dec %r9\n    shl $4, %r9\n    add %r11, %r9\n    mov %rax, (%r9)\n    mov %rdx, 8(%r9)\n    jmp 92f\n90:\n    call hbc_bound_error\n92:\n");
            }
        }
    }
}

// Collect every block literal in a statement tree (deterministic order).
fn collect_blocks_expr(e: &Expr, out: &mut Vec<(usize, Vec<String>, Vec<Expr>)>) {
    if let Expr::Send(o, _, args) = e {
        collect_blocks_expr(o, out);
        for a in args { collect_blocks_expr(a, out); }
        return;
    }
    if matches!(e, Expr::SelfObj | Expr::SelfGet(_)) { return; }
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
            Stmt::SelfSet(_, _, e) | Stmt::SendStmt(_, e) => collect_blocks_expr(e, out),
            Stmt::SendSet(_, o, _, e) => { collect_blocks_expr(o, out); collect_blocks_expr(e, out); }
            Stmt::Ret(_, None) | Stmt::Exit(_) | Stmt::Loop(_) => {}
            Stmt::AAdd(_, _, e) | Stmt::ASize(_, _, e) => collect_blocks_expr(e, out),
            Stmt::ArrSet2(_, _, ie, ie2, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); collect_blocks_expr(e, out); }
            Stmt::ArrSet3(_, _, ie, ie2, ie3, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); collect_blocks_expr(ie3, out); collect_blocks_expr(e, out); }
            Stmt::AAddSub(_, _, ie, e) | Stmt::ASizeSub(_, _, ie, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(e, out); }
            Stmt::AAddSub2(_, _, ie, ie2, e) | Stmt::ASizeSub2(_, _, ie, ie2, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); collect_blocks_expr(e, out); }
            Stmt::If(_, c, a, b) => { collect_blocks_expr(c, out); collect_blocks_stmts(a, out); collect_blocks_stmts(b, out); }
            Stmt::While(_, c, body) => { collect_blocks_expr(c, out); collect_blocks_stmts(body, out); }
            Stmt::For(_, _, a, b, _, body) => { collect_blocks_expr(a, out); collect_blocks_expr(b, out); collect_blocks_stmts(body, out); }
            Stmt::ForEach(_, _, c, body) => { collect_blocks_expr(c, out); collect_blocks_stmts(body, out); }
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
            // A parameter some caller feeds as `a[i]` arrives as the cell
            // ADDRESS (one word): borrow shape, never freed here.
            let pty = if own_sig.borrowed.get(i).copied().unwrap_or(false) && own_sig.params[i] == Ty::DArr { Ty::DArrRef } else if own_sig.borrowed.get(i).copied().unwrap_or(false) && own_sig.params[i] == Ty::DArr2 { Ty::DArrRef2 } else { own_sig.params[i] };
            lenv.push(CgLocal { name: p.clone(), ty: pty, off: frame });
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
        if v.ty == Ty::DArr2 {
            darr_slots.push((v.off, 1));
        }
        if v.ty == Ty::DArr3 {
            darr_slots.push((v.off, 3));
        }
        if v.ty == Ty::DArrS {
            darr_slots.push((v.off, 4));
        }
        if v.ty == Ty::StrOwn {
            darr_slots.push((v.off, 5));
        }
        if v.ty == Ty::Hash {
            darr_slots.push((v.off, 2));
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
        if v.ty == Ty::Str || v.ty == Ty::DArr || v.ty == Ty::Dyn || v.ty == Ty::DArr2 || v.ty == Ty::DArr3 || v.ty == Ty::DArrS || v.ty == Ty::StrOwn || v.ty == Ty::Hash {
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
            3 => {
                // DArr3: recursive free, two pair-levels (rdx = depth).
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov -{}(%rbp), %rsi\n    mov $2, %edx\n    call hbc_rfree\n91{}:\n", off, i, off - 8, i));
            }
            4 => {
                // DArrS: free each owned key copy, then the block.
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov -{}(%rbp), %rsi\n    call hbc_sfree\n91{}:\n", off, i, off - 8, i));
            }
            5 => {
                // StrOwn: an owned string copy; hbc_free(ptr, 1) releases
                // exactly 8 + len bytes (the length header is at ptr-8).
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov $1, %esi\n    call hbc_free\n91{}:\n", off, i, i));
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
    cmpq $0, -24(%rbp)
    jne 24f
    # Zero columns: the child is a real empty array (oracle az0b: len 0,
    # not NIL), so it owns a header-only block like `{}`.
    mov $8, %edi
    call hbc_alloc
    movq $0, (%rax)
    add $8, %rax
    mov %rax, -48(%rbp)
    jmp 25f
24: lea -48(%rbp), %rdi
    mov -24(%rbp), %rsi
    mov $16, %edx
    xor %ecx, %ecx
    call hbc_asize
25: nop
    mov -8(%rbp), %rdi
    mov $16, %esi
    lea -48(%rbp), %rdx
    call hbc_aadd
    incq -32(%rbp)
    jmp 22b
23: leave
    ret
";

const ARRAY3_HELPER: &str = r"
# --- Array(n, m, k) constructor ------------------------------------------
# hbc_array3m: rdi = parent slot address (zeroed by the caller), rsi =
# dim1, rdx = dim2, rcx = dim3. Builds dim1 children, each a full
# Array(dim2, dim3) built by hbc_arraym (oracle pr7: real child arrays,
# innermost slots NIL). A negative dimension aborts via hbc_asize_neg
# (same registered failure mode as the 2D form). Frame-held state only,
# 16-byte-aligned internal calls on both targets.
hbc_array3m:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rdi, -8(%rbp)
    mov %rsi, -16(%rbp)
    mov %rdx, -24(%rbp)
    mov %rcx, -32(%rbp)
    movq $0, -40(%rbp)
    test %rsi, %rsi
    js hbc_asize_neg
    test %rdx, %rdx
    js hbc_asize_neg
    test %rcx, %rcx
    js hbc_asize_neg
22: mov -40(%rbp), %rax
    cmp -16(%rbp), %rax
    jae 23f
    movq $0, -56(%rbp)
    movq $0, -48(%rbp)
    lea -56(%rbp), %rdi
    mov -24(%rbp), %rsi
    mov -32(%rbp), %rdx
    call hbc_arraym
    # Zero rows: hbc_arraym leaves the slot null, but as a CHILD of the
    # 3D value Harbour materializes a real empty array (oracle pr7b:
    # len(b[1]) = 0 and b[1] = NIL is .F., not a NIL casilla).
    cmpq $0, -56(%rbp)
    jne 25f
    mov $8, %edi
    call hbc_alloc
    movq $0, (%rax)
    add $8, %rax
    mov %rax, -56(%rbp)
25: nop
    mov -8(%rbp), %rdi
    mov $16, %esi
    lea -56(%rbp), %rdx
    call hbc_aadd
    incq -40(%rbp)
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

# hbc_hkeys: rdi = hash slot address. Returns rax = data pointer of a
# NEW array block holding one Dyn {tag 2, payload} element per live
# entry in insertion order (probes hk4/hk5/hk6), rdx = element count.
# Each key's bytes are COPIED into an own allocation with an 8-byte
# length header - the same layout as a hash key copy - so the returned
# array owns its strings independently of the hash (a later hbc_hfree
# of the hash cannot dangle them) and hbc_free(payload, 1) releases
# exactly one. Overflow of 8 + count*16 is OOM (the count is guarded
# before the shift), matching hbc_hput's rule; a mid-copy hbc_oom
# exits the process with every temporary still owned by this helper.
hbc_hkeys:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $8, %rsp
    mov (%rdi), %r12
    mov 8(%rdi), %r13
    mov $0x0FFFFFFFFFFFFFFF, %rax
    cmp %rax, %r13
    ja hbc_oom
    mov %r13, %rdi
    shl $4, %rdi
    add $8, %rdi
    call hbc_alloc
    mov %rax, %rbx
    mov %r13, (%rbx)
    xor %r14d, %r14d
50: cmp %r13, %r14
    jae 51f
    mov %r14, %rax
    shl $5, %rax
    lea (%r12,%rax), %r15
    mov 8(%r15), %rdi
    add $8, %rdi
    call hbc_alloc
    mov 8(%r15), %rcx
    mov %rcx, (%rax)
    mov (%r15), %rsi
    lea 8(%rax), %rdi
    mov %r14, %rdx
    shl $4, %rdx
    lea 8(%rbx,%rdx), %r10
    mov %rdi, 8(%r10)
    movq $2, (%r10)
    xor %r9d, %r9d
52: cmp %rcx, %r9
    jae 53f
    movzbl (%rsi,%r9), %r11d
    mov %r11b, (%rdi,%r9)
    inc %r9
    jmp 52b
53: inc %r14
    jmp 50b
51: lea 8(%rbx), %rax
    mov %r13, %rdx
    add $8, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_strcpy: rdi = source bytes, rsi = length. Returns rax = pointer to
# the bytes of a NEW owned allocation with an 8-byte length header (the
# hash-key-copy layout: hbc_free(ptr, 1) releases it), rdx = length.
# Used when a tag-2 array element is read out of its array: the reader
# owns an independent copy, so freeing or moving the array afterwards
# cannot dangle it.
hbc_strcpy:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $8, %rsp
    mov %rdi, %r13
    mov %rsi, %r12
    lea 8(%rsi), %rdi
    call hbc_alloc
    mov %rax, %rbx
    mov %r12, (%rbx)
    xor %ecx, %ecx
70: cmp %r12, %rcx
    jae 71f
    movzbl (%r13,%rcx), %r9d
    mov %r9b, 8(%rbx,%rcx)
    inc %rcx
    jmp 70b
71: lea 8(%rbx), %rax
    mov %r12, %rdx
    add $8, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_sfree: rdi = array data pointer (non-null), rsi = live element
# count. Frees each tag-2 string payload, then the block. Uses the
# LIVE count, never capacity, like hbc_hfree; a non-2 tag is skipped,
# so a NIL casilla would be harmless.
hbc_sfree:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $8, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    xor %r13d, %r13d
60: cmp %r12, %r13
    jae 61f
    mov %r13, %rax
    shl $4, %rax
    cmpq $2, (%rbx,%rax)
    jne 62f
    mov 8(%rbx,%rax), %rdi
    mov $1, %esi
    call hbc_free
62: inc %r13
    jmp 60b
61: mov %rbx, %rdi
    mov $16, %esi
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
            out.push_str(ARRAY3_HELPER);
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
# probe n1) for tag 1, the raw string bytes for tag 2 (payload points at
# the bytes, length header at payload-8 - same layout as a hash key
# copy); otherwise the numeric payload via hbc_print_i64.
hbc_print_dyn:
    test %rax, %rax
    jz 8f
    cmp $2, %rax
    je 9f
    lea .Lnilmsg(%rip), %rsi
    mov $3, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    ret
8:  mov %rdx, %rax
    jmp hbc_print_i64
9:  mov %rdx, %rax
    mov -8(%rax), %rdx
    jmp hbc_print_str

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

# hbc_len_error: len() of a NIL slot (noreturn). Harbour's BASE/1111
# dialog hangs headless (oracle n2): this clean exit 1 is the registered
# failure mode for the same error condition, not a compat success.
hbc_len_error:
    lea .Llenerrmsg(%rip), %rsi
    mov $20, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_param_error: a NIL casilla passed as a borrowed a[i] argument
# (noreturn). Harbour's dialog hangs headless (same family as BASE/1123,
# oracle n6): clean exit 1, registered failure mode - not a compat success.
hbc_param_error:
    lea .Lparamerrmsg(%rip), %rsi
    mov $22, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_aadd_error / hbc_asize_error: AAdd/ASize on a NIL casilla
# (noreturn). Harbour's BASE/1123 and BASE/2023 dialogs hang headless
# (oracles n6/n7): clean exit 1, registered failure modes.
# hbc_snil_error: a NIL casilla (ASize growth, hk13/hk14) read in a
# string context (noreturn). Harbour yields NIL there - its typing is
# dynamic; the static StrOwn cannot, so this is the registered clean
# failure mode.
hbc_snil_error:
    lea .Lsnilmsg(%rip), %rsi
    mov $47, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_dyncmp_eq_error / hbc_dyncmp_ne_error: a numeric Dyn compared
# against a string (noreturn). Harbour raises BASE/1071 "Argument
# error: =" and BASE/1072 "Argument error: <>" (hk34/hk38, dialogs
# that hang headless) - clean named exit 1 here, registered failure
# mode, same error condition.
hbc_dyncmp_eq_error:
    lea .Ldyncmpeqmsg(%rip), %rsi
    mov $18, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_dyncmp_ne_error:
    lea .Ldyncmpnemsg(%rip), %rsi
    mov $19, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_dyncmp_lt/gt/le/ge_error: a NIL or numeric Dyn ordered against
# a string (noreturn). Harbour raises BASE/1073 "Argument error: <",
# BASE/1075 "Argument error: >", BASE/1074 "Argument error: <=" and
# BASE/1076 "Argument error: >=" (hk41/hk42/hk44-hk50, dialogs that
# hang headless) - clean named exit 1 here, registered failure mode,
# same error condition.
hbc_dyncmp_lt_error:
    lea .Ldyncmpltmsg(%rip), %rsi
    mov $18, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_dyncmp_gt_error:
    lea .Ldyncmpgtmsg(%rip), %rsi
    mov $18, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_dyncmp_le_error:
    lea .Ldyncmplemsg(%rip), %rsi
    mov $19, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_dyncmp_ge_error:
    lea .Ldyncmpgemsg(%rip), %rsi
    mov $19, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_arracc_error: a NIL casilla of an array of arrays iterated with
# FOR EACH (noreturn). Harbour raises BASE/1068 "Argument error:
# array access" (hk58, dialog hangs headless) - clean named exit 1
# here, registered failure mode, same error condition.
hbc_arracc_error:
    lea .Larraccmsg(%rip), %rsi
    mov $29, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_aadd_error:
    lea .Laadderrmsg(%rip), %rsi
    mov $21, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall
hbc_asize_error:
    lea .Lasizeerrmsg(%rip), %rsi
    mov $22, %edx
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

# hbc_rfree: rdi = block of (ptr,len) pairs, rsi = pair count, rdx =
# pair-levels (>= 2). Generic recursive free: a child of a block with
# more than two pair-levels is freed by hbc_rfree at one level less; a
# child at exactly two pair-levels is a DArr2 block, freed by the tested
# hbc_free2. Depth 4+ needs no new helper. Callee-saved registers are
# preserved (rbx/r12-r14); the extra sub keeps rsp 16-aligned at calls.
hbc_rfree:
    push %rbx
    push %r12
    push %r13
    push %r14
    sub $8, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r14
    xor %r13, %r13
71: cmp %r12, %r13
    jge 72f
    mov %r13, %rax
    shl $4, %rax
    mov (%rbx,%rax), %rdi
    test %rdi, %rdi
    jz 73f
    mov 8(%rbx,%rax), %rsi
    cmp $2, %r14
    je 74f
    lea -1(%r14), %rdx
    call hbc_rfree
    jmp 73f
74: call hbc_free2
73: inc %r13
    jmp 71b
72: mov %rbx, %rdi
    mov $16, %esi
    call hbc_free
    add $8, %rsp
    pop %r14
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
    cmp $1, %r15
    je 79f
    cmp $3, %r15
    je 79f
    # flat arrays and arrays of strings grow with NIL {1, 0} (probe e1;
    # hk13/hk14 for the string array: grown casillas read NIL)
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
59: # shrink: kind 2 frees the removed string copies, kind 1 the children
    cmp $2, %r15
    je 80f
    cmp $3, %r15
    je 83f
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
80: mov (%rbx), %r13
    mov %r12, %r9
81: cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    cmpq $2, (%r13,%r10)
    jne 82f
    mov 8(%r13,%r10), %rdi
    test %rdi, %rdi
    jz 82f
    mov $1, %esi
    call hbc_free
82: inc %r9
    jmp 81b
    # kind 3: three levels - removed children own their own children,
    # so they are freed RECURSIVELY (hbc_rfree depth 2)
83: mov (%rbx), %r13
    mov %r12, %r9
84: cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    mov (%r13,%r10), %rdi
    test %rdi, %rdi
    jz 85f
    mov 8(%r13,%r10), %rsi
    mov $2, %edx
    call hbc_rfree
85: inc %r9
    jmp 84b
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
    out.push_str(ARRAY3_HELPER);
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
    // "Argument error: LEN\n" (20 bytes; Harbour BASE/1111 hangs headless - registered failure mode)
    out.push_str(".Llenerrmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,76,69,78,10\n");
    // "Argument error: AADD\n" (21 bytes; Harbour BASE/1123 hangs headless, oracle n6)
    out.push_str(".Laadderrmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,65,65,68,68,10\n");
    // "Argument error: PARAM\n" (22 bytes; NIL casilla as a borrowed argument - registered failure mode, Harbour hangs headless)
    out.push_str(".Lparamerrmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,80,65,82,65,77,10\n");
    out.push_str(".Lsnilmsg:\n    .byte 84,121,112,101,32,101,114,114,111,114,58,32,101,120,112,101,99,116,101,100,32,97,32,115,116,114,105,110,103,32,101,108,101,109,101,110,116,44,32,103,111,116,32,78,73,76,10\n");
    out.push_str(".Ldyncmpeqmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,61,10\n");
    out.push_str(".Ldyncmpnemsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,60,62,10\n");
    out.push_str(".Ldyncmpltmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,60,10\n");
    out.push_str(".Ldyncmpgtmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,62,10\n");
    out.push_str(".Ldyncmplemsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,60,61,10\n");
    out.push_str(".Ldyncmpgemsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,62,61,10\n");
    out.push_str(".Larraccmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,97,114,114,97,121,32,97,99,99,101,115,115,10\n");
    // "Argument error: ASIZE\n" (22 bytes; Harbour BASE/2023 hangs headless, oracle n7)
    out.push_str(".Lasizeerrmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,65,83,73,90,69,10\n");
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
# probe n1) for tag 1, the raw string bytes for tag 2 (payload points at
# the bytes, length header at payload-8 - same layout as a hash key
# copy); otherwise the numeric payload via hbc_print_i64.
hbc_print_dyn:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    test %rax, %rax
    jz 8f
    cmp $2, %rax
    je 10f
    lea .Lnilmsg(%rip), %rax
    mov $3, %edx
    call hbc_print_str
    jmp 9f
8:  mov %rdx, %rax
    call hbc_print_i64
    jmp 9f
10: mov %rdx, %rax
    mov -8(%rax), %rdx
    call hbc_print_str
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

# hbc_len_error: len() of a NIL slot (noreturn) - see the linux copy.
hbc_len_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Llenerrmsg(%rip), %rax
    mov $20, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_param_error: see the linux copy.
hbc_param_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lparamerrmsg(%rip), %rax
    mov $22, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_aadd_error / hbc_asize_error: see the linux copies.
hbc_snil_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lsnilmsg(%rip), %rax
    mov $47, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_eq_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpeqmsg(%rip), %rax
    mov $18, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_ne_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpnemsg(%rip), %rax
    mov $19, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_lt_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpltmsg(%rip), %rax
    mov $18, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_gt_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpgtmsg(%rip), %rax
    mov $18, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_le_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmplemsg(%rip), %rax
    mov $19, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_ge_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpgemsg(%rip), %rax
    mov $19, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_arracc_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Larraccmsg(%rip), %rax
    mov $29, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_aadd_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Laadderrmsg(%rip), %rax
    mov $21, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess
hbc_asize_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lasizeerrmsg(%rip), %rax
    mov $22, %edx
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

# hbc_rfree: rdi = block of (ptr,len) pairs, rsi = pair count, rdx =
# pair-levels (>= 2). Same generic recursive free as the SysV helper.
hbc_rfree:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    sub $48, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r14
    xor %r13, %r13
71: cmp %r12, %r13
    jge 72f
    mov %r13, %rax
    shl $4, %rax
    mov (%rbx,%rax), %rdi
    test %rdi, %rdi
    jz 73f
    mov 8(%rbx,%rax), %rsi
    cmp $2, %r14
    je 74f
    lea -1(%r14), %rdx
    call hbc_rfree
    jmp 73f
74: call hbc_free2
73: inc %r13
    jmp 71b
72: mov %rbx, %rdi
    mov $16, %esi
    call hbc_free
    add $48, %rsp
    pop %r14
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
    cmp $1, %r15
    je 79f
    cmp $3, %r15
    je 79f
    # flat arrays and arrays of strings grow with NIL {1, 0} (probe e1;
    # hk13/hk14 for the string array: grown casillas read NIL)
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
59: # shrink: kind 2 frees the removed string copies, kind 1 the children.
# The counter lives on the stack: kernel32 may clobber the volatile r9
# across the hbc_free call.
    cmp $2, %r15
    je 80f
    cmp $3, %r15
    je 83f
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
80: mov (%rbx), %r13
    mov %r12, -48(%rbp)
81: mov -48(%rbp), %r9
    cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    cmpq $2, (%r13,%r10)
    jne 82f
    mov 8(%r13,%r10), %rdi
    test %rdi, %rdi
    jz 82f
    mov $1, %esi
    call hbc_free
82: incq -48(%rbp)
    jmp 81b
    # kind 3: three levels - recursive free of removed children
    # (hbc_rfree depth 2); same stack-counter pattern as kind 1.
83: mov (%rbx), %r13
    mov %r12, -48(%rbp)
84: mov -48(%rbp), %r9
    cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    mov (%r13,%r10), %rdi
    test %rdi, %rdi
    jz 85f
    mov 8(%r13,%r10), %rsi
    mov $2, %edx
    call hbc_rfree
85: incq -48(%rbp)
    jmp 84b
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

    let prog = match parse(&src) {
        Ok(p) => p,
        Err(msg) => { eprintln!("error: {}", msg); process::exit(1); }
    };
    if !prog.classes.is_empty() || !prog.methods.is_empty() {
        eprintln!("error: classes are not in this increment yet (the parser landed; the runtime representation is pending the user's decision)");
        process::exit(1);
    }
    let mut funcs = prog.funcs;

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
        let res = check_stmts(&f.stmts, &mut env, &mut sigs, &mut ret, None, &mut top_exits, &dyn_names);
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
        sigs.push(Sig { name: f.name.clone(), borrowed: vec![false; ptys.len()], arr_moved: vec![false; ptys.len()], params: ptys.clone(), ret });
        f.ret = ret;
    }
    // Borrowed-parameter escape post-pass (see borrow_stmts_ok).
    for f in &funcs {
        if let Some(s) = sigs.iter().find(|s| s.name == f.name) {
            for (i, p) in f.params.iter().enumerate() {
                if s.borrowed.get(i).copied().unwrap_or(false) {
                    if let Some(m) = borrow_stmts_ok(&f.stmts, p) {
                        eprintln!("error: line {}: parameter `{}` of `{}` is borrowed from its caller; it can be read, written and grown in place, but not returned, reassigned, iterated or passed on", m, p, f.name);
                        process::exit(1);
                    }
                }
            }
        }
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
