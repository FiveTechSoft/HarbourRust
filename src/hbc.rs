// hbc - PoC front-end: Harbour syntax (closed subset) -> Rust source.
// Fail-closed: tokenizer + parser validate every token; only a known AST is
// emitted. No raw user text ever reaches the generated Rust. The semantic
// checks that matter (ownership, borrow) are then re-enforced by rustc.
// Type contract: integers are i64, strings are owned String.

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
            Some(Tok::Int(v)) => Ok(Expr::Int(v)),
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

const RUST_KEYWORDS: &[&str] = &[
    "fn", "let", "match", "if", "else", "while", "loop", "for", "in", "struct",
    "enum", "impl", "trait", "type", "const", "static", "pub", "mod", "use",
    "crate", "self", "self_",
    "super", "where", "async", "await", "move", "mut", "ref", "box", "dyn",
    "unsafe", "break", "continue", "as", "extern", "true", "false",
];

fn check_ident(id: &str, n: usize) -> Result<(), String> {
    if id.is_empty() || id.len() > 64 {
        return Err(format!("line {}: invalid identifier length", n));
    }
    if RUST_KEYWORDS.contains(&id) {
        return Err(format!("line {}: `{}` is reserved in the backend", n, id));
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

fn type_expr(e: &Expr, env: &[(String, Ty)], sigs: &[(String, Ty)], n: usize) -> Result<Ty, String> {
    match e {
        Expr::Int(_) => Ok(Ty::I64),
        Expr::Str(_) => Ok(Ty::Str),
        Expr::Var(id) => env.iter().find(|(v, _)| v == id).map(|(_, t)| *t)
            .ok_or_else(|| format!("line {}: undefined variable `{}`", n, id)),
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

fn escape_rust(s: &str) -> String {
    let mut o = String::new();
    for c in s.chars() {
        match c {
            '\\' => o.push_str("\\\\"),
            '"' => o.push_str("\\\""),
            c => o.push(c),
        }
    }
    o
}

fn emit_expr_top(e: &Expr) -> String {
    match e {
        Expr::Bin(op, a, b) => format!("{} {} {}", emit_expr(a), op, emit_expr(b)),
        _ => emit_expr(e),
    }
}

fn emit_expr(e: &Expr) -> String {
    match e {
        Expr::Int(v) => format!("{}i64", v),
        Expr::Str(s) => format!("String::from(\"{}\")", escape_rust(s)),
        Expr::Var(id) => id.clone(),
        Expr::Call(id) => format!("{}()", id),
        Expr::Bin(op, a, b) => format!("({} {} {})", emit_expr(a), op, emit_expr(b)),
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("usage: hbc <input.hb> <output.rs>");
        process::exit(2);
    }
    let src = fs::read_to_string(&args[1])
        .unwrap_or_else(|e| { eprintln!("cannot read {}: {}", args[1], e); process::exit(2); });

    let mut funcs = match parse(&src) {
        Ok(f) => f,
        Err(msg) => { eprintln!("error: {}", msg); process::exit(1); }
    };

    // Pass 1: return types and per-function checking (calls only to earlier fns).
    let mut sigs: Vec<(String, Ty)> = Vec::new();
    let mut has_main = false;
    for f in &mut funcs {
        if f.name == "main" { has_main = true; }
        let mut env: Vec<(String, Ty)> = Vec::new();
        let mut ret = None;
        for s in &f.stmts {
            match s {
                Stmt::Local(n, id, e) => {
                    if env.iter().any(|(v, _)| v == id) {
                        eprintln!("error: line {}: duplicate local `{}`", n, id);
                        process::exit(1);
                    }
                    match type_expr(e, &env, &sigs, *n) {
                        Ok(t) => env.push((id.clone(), t)),
                        Err(m) => { eprintln!("error: {}", m); process::exit(1); }
                    }
                }
                Stmt::Print(n, e) => {
                    if let Err(m) = type_expr(e, &env, &sigs, *n) {
                        eprintln!("error: {}", m);
                        process::exit(1);
                    }
                }
                Stmt::Ret(n, Some(e)) => {
                    match type_expr(e, &env, &sigs, *n) {
                        Ok(t) => ret = Some(t),
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

    // Pass 2: emit Rust from the validated AST only.
    let mut out = String::from("// generated by hbc (PoC: Harbour syntax -> Rust)\n");
    for f in &funcs {
        if f.name == "main" {
            out.push_str("fn main() {\n");
        } else {
            let ty = match f.ret {
                Some(Ty::I64) => "i64",
                Some(Ty::Str) => "String",
                None => "()",
            };
            out.push_str(&format!("fn {}() -> {} {{\n", f.name, ty));
        }
        for s in &f.stmts {
            match s {
                Stmt::Local(_, id, e) => out.push_str(&format!("    let {} = {};\n", id, emit_expr_top(e))),
                Stmt::Print(_, e) => out.push_str(&format!("    println!(\"{{}}\", {});\n", emit_expr(e))),
                Stmt::Ret(_, Some(e)) => out.push_str(&format!("    return {};\n", emit_expr_top(e))),
                Stmt::Ret(_, None) => {}
            }
        }
        out.push_str("}\n\n");
    }

    fs::write(&args[2], out)
        .unwrap_or_else(|e| { eprintln!("cannot write {}: {}", args[2], e); process::exit(2); });
    println!("{} -> {} ({} functions)", args[1], args[2], funcs.len());
}
