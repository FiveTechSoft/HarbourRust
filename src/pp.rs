// pp - HarbourRust preprocessor engine (PoC, MIT, written from scratch).
// Shared module: hbc runs it automatically on every compile; the hpp
// binary is a thin standalone frontend over this same code.
//
// Behavioural basis: docs/PP-F0.md (black-box probes against the Harbour
// toolchain; probes are our own programs, no Harbour code copied or
// translated into this file). During the earlier licence evaluation the
// GPL notices of Harbour's src/pp files were read - disclosed in PP-F0.
//
// Scope: object-like and function-like #define / #undef, #ifdef / #ifndef /
// #else / #elif / #endif, #if over integer constants (==, !=, <, <=, >, >=,
// .and./.or./.not., parentheses, defined()), #include, #error. Directive
// names are case-insensitive. Redefinition is allowed, last wins.

use std::collections::HashMap;
use std::fs;

#[derive(Clone)]
struct Def {
    params: Vec<String>, // empty: object-like
    body: String,
}

pub struct Pp {
    pub defs: HashMap<String, Def>, // key: exact name (macro names are case-sensitive)
    pub cmds: Vec<Cmd>,             // #command / #xcommand / #translate rules, in order
    pub incdirs: Vec<String>,
}

// A command rule: pattern tokens (literal words or <param>) => result template.
// Scoped F3a: no optional [...] clauses, no <x,...> lists, no match markers.
pub struct Cmd {
    pattern: Vec<String>, // tokens; "<name>" marks a capture
    result: String,
}

impl Pp {
    pub fn new(incdirs: Vec<String>) -> Self {
        Pp { defs: HashMap::new(), cmds: Vec::new(), incdirs }
    }
}

// A conditional stack entry: whether the current branch is emitting and
// whether any earlier branch of this conditional already emitted.
struct Cond {
    active: bool,
    taken: bool,
}

pub fn eval_if(expr: &str, defs: &HashMap<String, Def>, line: usize) -> Result<bool, String> {
    // Tokens: identifiers, integer literals, operators, defined(...).
    #[derive(Debug, Clone, PartialEq)]
    enum T {
        Num(i64),
        Op(String),
        Arith(String),
        LP,
        RP,
        Not,
        And,
        Or,
    }
    let b = expr.as_bytes();
    let mut i = 0usize;
    let mut toks: Vec<T> = Vec::new();
    while i < b.len() {
        let c = b[i] as char;
        if c.is_whitespace() { i += 1; continue; }
        if c == '(' { toks.push(T::LP); i += 1; continue; }
        if c == ')' { toks.push(T::RP); i += 1; continue; }
        if c.is_ascii_digit() {
            let mut j = i;
            while j < b.len() && (b[j] as char).is_ascii_digit() { j += 1; }
            let v: i64 = expr[i..j].parse().map_err(|_| format!("line {}: bad number in #if", line))?;
            toks.push(T::Num(v));
            i = j;
            continue;
        }
        if c.is_ascii_alphabetic() || c == '_' || c == '.' {
            let mut j = i;
            while j < b.len() && ((b[j] as char).is_ascii_alphanumeric() || b[j] == b'_' || b[j] == b'.') { j += 1; }
            let w = &expr[i..j];
            i = j;
            match w.to_uppercase().as_str() {
                ".AND." => toks.push(T::And),
                ".OR." => toks.push(T::Or),
                ".NOT." => toks.push(T::Not),
                "DEFINED" => {
                    // defined(NAME)
                    while i < b.len() && (b[i] as char).is_whitespace() { i += 1; }
                    if i >= b.len() || b[i] != b'(' { return Err(format!("line {}: expected ( after defined", line)); }
                    i += 1;
                    while i < b.len() && (b[i] as char).is_whitespace() { i += 1; }
                    let k = i;
                    while i < b.len() && ((b[i] as char).is_ascii_alphanumeric() || b[i] == b'_') { i += 1; }
                    let name = &expr[k..i];
                    while i < b.len() && (b[i] as char).is_whitespace() { i += 1; }
                    if i >= b.len() || b[i] != b')' { return Err(format!("line {}: expected ) after defined name", line)); }
                    i += 1;
                    toks.push(T::Num(if defs.contains_key(name) { 1 } else { 0 }));
                }
                _ => {
                    // A defined macro expands to its body if numeric, else 0
                    // (macro names are case-sensitive).
                    let v = defs.get(w).and_then(|d| d.body.trim().parse::<i64>().ok()).unwrap_or(0);
                    toks.push(T::Num(v));
                }
            }
            continue;
        }
        // operators: ==, !=, >=, <=, >, <
        if i + 1 < b.len() {
            let two = &expr[i..i + 2];
            if ["==", "!=", ">=", "<="].contains(&two) {
                toks.push(T::Op(two.to_string()));
                i += 2;
                continue;
            }
        }
        if c == '>' || c == '<' {
            toks.push(T::Op(c.to_string()));
            i += 1;
            continue;
        }
        if c == '+' || c == '-' || c == '*' || c == '/' || c == '%' {
            toks.push(T::Arith(c.to_string()));
            i += 1;
            continue;
        }
        if c == '!' { toks.push(T::Not); i += 1; continue; }
        return Err(format!("line {}: error in #if expression (use ==, not =)", line));
    }
    // Recursive descent: or := and (.or.); and := not (.and.); comparison.
    fn parse_or(t: &[T], p: &mut usize, line: usize) -> Result<i64, String> {
        let mut l = parse_and(t, p, line)?;
        while *p < t.len() && t[*p] == T::Or {
            *p += 1;
            let r = parse_and(t, p, line)?;
            l = if l != 0 || r != 0 { 1 } else { 0 };
        }
        Ok(l)
    }
    fn parse_and(t: &[T], p: &mut usize, line: usize) -> Result<i64, String> {
        let mut l = parse_not(t, p, line)?;
        while *p < t.len() && t[*p] == T::And {
            *p += 1;
            let r = parse_not(t, p, line)?;
            l = if l != 0 && r != 0 { 1 } else { 0 };
        }
        Ok(l)
    }
    fn parse_not(t: &[T], p: &mut usize, line: usize) -> Result<i64, String> {
        if *p < t.len() && t[*p] == T::Not {
            *p += 1;
            let v = parse_not(t, p, line)?;
            return Ok(if v == 0 { 1 } else { 0 });
        }
        parse_cmp(t, p, line)
    }
    fn parse_expr(t: &[T], p: &mut usize, line: usize) -> Result<i64, String> {
        let mut l = parse_term(t, p, line)?;
        while *p < t.len() {
            if let T::Arith(op) = &t[*p] {
                if op != "+" && op != "-" { break; }
                let op = op.clone();
                *p += 1;
                let r = parse_term(t, p, line)?;
                l = if op == "+" { l.wrapping_add(r) } else { l.wrapping_sub(r) };
            } else { break; }
        }
        Ok(l)
    }
    fn parse_term(t: &[T], p: &mut usize, line: usize) -> Result<i64, String> {
        let mut l = parse_atom(t, p, line)?;
        while *p < t.len() {
            if let T::Arith(op) = &t[*p] {
                if op != "*" && op != "/" && op != "%" { break; }
                let op = op.clone();
                *p += 1;
                let r = parse_term(t, p, line)?;
                l = match op.as_str() {
                    "*" => l.wrapping_mul(r),
                    "/" => if r == 0 { return Err(format!("line {}: division by zero in #if", line)); } else { l.wrapping_div(r) },
                    _ => if r == 0 { return Err(format!("line {}: division by zero in #if", line)); } else { l.wrapping_rem(r) },
                };
            } else { break; }
        }
        Ok(l)
    }
    fn parse_cmp(t: &[T], p: &mut usize, line: usize) -> Result<i64, String> {
        let l = parse_expr(t, p, line)?;
        if *p < t.len() {
            if let T::Op(op) = &t[*p] {
                *p += 1;
                let r = parse_expr(t, p, line)?;
                return Ok(match op.as_str() {
                    "==" => (l == r) as i64,
                    "!=" => (l != r) as i64,
                    ">" => (l > r) as i64,
                    "<" => (l < r) as i64,
                    ">=" => (l >= r) as i64,
                    "<=" => (l <= r) as i64,
                    _ => return Err(format!("line {}: error in #if expression", line)),
                });
            }
        }
        Ok(l)
    }
    fn parse_atom(t: &[T], p: &mut usize, line: usize) -> Result<i64, String> {
        if *p >= t.len() { return Err(format!("line {}: error in #if expression", line)); }
        match &t[*p] {
            T::Num(v) => { *p += 1; Ok(*v) }
            T::LP => {
                *p += 1;
                let v = parse_or(t, p, line)?;
                if *p >= t.len() || t[*p] != T::RP { return Err(format!("line {}: missing ) in #if", line)); }
                *p += 1;
                Ok(v)
            }
            _ => Err(format!("line {}: error in #if expression", line)),
        }
    }
    let mut p = 0usize;
    let v = parse_or(&toks, &mut p, line)?;
    if p != toks.len() { return Err(format!("line {}: error in #if expression", line)); }
    Ok(v != 0)
}

// Expand defines in a source line: word boundaries, never inside string
// literals. Function-like defines expand only in call form NAME(args...);
// expansion recurses (nested calls like F(F(2))) with a depth cap.
pub fn expand(line: &str, defs: &HashMap<String, Def>, line_no: usize) -> Result<String, String> {
    expand_depth(line, defs, line_no, 0)
}

fn expand_depth(line: &str, defs: &HashMap<String, Def>, line_no: usize, depth: usize) -> Result<String, String> {
    if depth > 16 { return Err(format!("line {}: macro expansion too deep (recursive define?)", line_no)); }
    let b = line.as_bytes();
    let mut outb: Vec<u8> = Vec::with_capacity(line.len());
    let mut i = 0usize;
    let mut in_str: Option<u8> = None;
    while i < b.len() {
        let c = b[i];
        if !c.is_ascii() {
            // UTF-8 lead/continuation byte: never a delimiter, copy through
            outb.push(c);
            i += 1;
            continue;
        }
        if in_str.is_none() && (c == b'"' || c == b'\'') {
            in_str = Some(c);
            outb.push(c);
            i += 1;
            continue;
        }
        if in_str == Some(c) { in_str = None; outb.push(c); i += 1; continue; }
        if in_str.is_none() && ((c as char).is_ascii_alphabetic() || c == b'_') {
            let mut j = i;
            while j < b.len() && ((b[j] as char).is_ascii_alphanumeric() || b[j] == b'_') { j += 1; }
            let word = &line[i..j];
            match defs.get(word) {
                Some(d) if d.params.is_empty() => {
                    // object-like: the body itself may contain macro calls
                    outb.extend_from_slice(expand_depth(&d.body.clone(), defs, line_no, depth + 1)?.as_bytes());
                }
                Some(d) => {
                    // function-like: only expands in call form
                    let mut k = j;
                    while k < b.len() && (b[k] as char).is_whitespace() { k += 1; }
                    if k >= b.len() || b[k] != b'(' {
                        outb.extend_from_slice(word.as_bytes()); // bare use: not a call, left as-is
                        i = j;
                        continue;
                    }
                    // collect balanced arguments (nesting + strings)
                    let mut args: Vec<String> = Vec::new();
                    let mut curb: Vec<u8> = Vec::new();
                    let mut lev = 0i32;
                    let mut q: Option<u8> = None;
                    let mut m = k + 1;
                    while m < b.len() {
                        let ch = b[m];
                        curb.push(ch);
                        if q.is_none() && (ch == b'"' || ch == b'\'') { q = Some(ch); m += 1; continue; }
                        if q == Some(ch) { q = None; m += 1; continue; }
                        if q.is_none() && ch == b'(' { lev += 1; m += 1; continue; }
                        if q.is_none() && ch == b')' {
                            if lev == 0 { curb.pop(); break; }
                            lev -= 1; m += 1; continue;
                        }
                        if q.is_none() && lev == 0 && ch == b',' {
                            curb.pop();
                            args.push(String::from_utf8_lossy(&curb).trim().to_string());
                            curb.clear();
                            m += 1;
                            continue;
                        }
                        m += 1;
                    }
                    if m >= b.len() { return Err(format!("line {}: unterminated macro call {}", line_no, word)); }
                    args.push(String::from_utf8_lossy(&curb).trim().to_string());
                    if args.len() != d.params.len() {
                        return Err(format!("line {}: macro {} takes {} argument(s), got {}", line_no, word, d.params.len(), args.len()));
                    }
                    // substitute params (word-boundary, outside strings) in the body
                    let mut body = d.body.clone();
                    for (pi, pn) in d.params.iter().enumerate() {
                        body = subst_param(&body, pn, &args[pi]);
                    }
                    outb.extend_from_slice(expand_depth(&body, defs, line_no, depth + 1)?.as_bytes());
                    i = m + 1;
                    continue;
                }
                None => outb.extend_from_slice(word.as_bytes()),
            }
            i = j;
            continue;
        }
        outb.push(c);
        i += 1;
    }
    Ok(String::from_utf8_lossy(&outb).into_owned())
}

// Replace whole-word occurrences of `name` in `text`, skipping string
// literals (a parameter inside a quoted string is text, not an argument).
fn subst_param(text: &str, name: &str, val: &str) -> String {
    let b = text.as_bytes();
    let nb = name.as_bytes();
    let mut out: Vec<u8> = Vec::with_capacity(text.len());
    let mut i = 0usize;
    let mut in_str: Option<u8> = None;
    while i < b.len() {
        let c = b[i];
        if !c.is_ascii() { out.push(c); i += 1; continue; } // UTF-8 passthrough
        if in_str.is_none() && (c == b'"' || c == b'\'') { in_str = Some(c); out.push(c); i += 1; continue; }
        if in_str == Some(c) { in_str = None; out.push(c); i += 1; continue; }
        if in_str.is_none() && i + nb.len() <= b.len() && &b[i..i + nb.len()] == nb { // param substitution is case-sensitive too (probe a07)
            let before = i == 0 || !(b[i - 1] as char).is_ascii_alphanumeric() && b[i - 1] != b'_';
            let after = i + nb.len() == b.len() || !(b[i + nb.len()] as char).is_ascii_alphanumeric() && b[i + nb.len()] != b'_';
            if before && after {
                out.extend_from_slice(val.as_bytes());
                i += nb.len();
                continue;
            }
        }
        out.push(c);
        i += 1;
    }
    String::from_utf8_lossy(&out).into_owned()
}

// Tokenize a command pattern or source line: words, <param> markers, and
// single non-word characters (parens, commas) as separate tokens. Keywords
// match case-insensitively (probe c05); captures keep their original text.
fn cmd_tokens(text: &str) -> Vec<String> {
    let b = text.as_bytes();
    let mut out: Vec<String> = Vec::new();
    let mut i = 0usize;
    while i < b.len() {
        let c = b[i] as char;
        if c.is_whitespace() { i += 1; continue; }
        if c == '<' {
            let mut j = i;
            while j < b.len() && b[j] != b'>' { j += 1; }
            if j < b.len() { out.push(text[i..=j].to_string()); i = j + 1; } else { out.push("<".to_string()); i += 1; }
            continue;
        }
        if c == '"' || c == '\'' {
            let mut j = i + 1;
            while j < b.len() && b[j] != c as u8 { j += 1; }
            let end = if j < b.len() { j + 1 } else { j };
            out.push(text[i..end].to_string());
            i = end;
            continue;
        }
        if !((c as u8).is_ascii()) {
            // UTF-8 lead byte: copy the whole sequence into a word token
            let mut j = i + 1;
            while j < b.len() && !b[j].is_ascii() { j += 1; }
            out.push(text[i..j].to_string());
            i = j;
            continue;
        }
        if c.is_ascii_alphanumeric() || c == '_' {
            let mut j = i;
            while j < b.len() && ((b[j] as char).is_ascii_alphanumeric() || b[j] == b'_' || !b[j].is_ascii()) { j += 1; }
            out.push(text[i..j].to_string());
            i = j;
            continue;
        }
        out.push(text[i..i + 1].to_string());
        i += 1;
    }
    out
}

// Try to match source tokens against a command pattern. On success returns
// the captured params (pattern order; optionals that did not fire capture
// as empty). A <param> captures tokens up to the next literal (at paren
// depth 0), or the rest of the input when no literal follows. Supported
// markers (all probed against Harbour first): <x>, <x,...> list captures,
// <(x)> parenthesized-expression captures, and [ ... ] optional groups
// including nesting (probe b18).
fn cmd_match(pat: &[String], src: &[String]) -> Option<Vec<String>> {
    // First literal token at or after pat[i], looking through markers and
    // group brackets; used as the terminator for captures.
    fn next_lit(pat: &[String], i: usize) -> Option<&str> {
        pat[i..].iter().find(|t| {
            !(t.starts_with('<') && t.ends_with('>')) && t.as_str() != "[" && t.as_str() != "]"
        }).map(|s| s.as_str())
    }
    // Capture src[start..] up to `lit` at paren depth 0; when `lit` is
    // None, or absent from src while stemming from an optional
    // continuation, capture the rest.
    fn capture_to(src: &[String], start: usize, lit: Option<&str>) -> Option<usize> {
        match lit {
            None => Some(src.len()),
            Some(l) => {
                let mut depth = 0i32;
                let mut k = start;
                while k < src.len() {
                    let t = &src[k];
                    // the terminating literal is compared BEFORE it can
                    // change the depth (a ")" at depth 0 ends the capture)
                    if depth == 0 && t.eq_ignore_ascii_case(l) { return Some(k); }
                    if t == "(" { depth += 1; } else if t == ")" { depth -= 1; }
                    k += 1;
                }
                Some(src.len()) // terminator absent: capture the rest
            }
        }
    }
    // Match a pattern slice (with balanced groups) against src, returning
    // tokens consumed. Captures are pushed in pattern order.
    fn match_seq(pat: &[String], src: &[String], caps: &mut Vec<String>) -> Option<usize> {
        let mut si = 0usize;
        let mut pi = 0usize;
        while pi < pat.len() {
            let p = &pat[pi];
            if p == "[" {
                // balanced group
                let mut depth = 1;
                let mut j = pi + 1;
                while j < pat.len() && depth > 0 {
                    if pat[j] == "[" { depth += 1; } else if pat[j] == "]" { depth -= 1; }
                    j += 1;
                }
                if depth != 0 { return None; } // unbalanced pattern
                let inner = &pat[pi + 1..j - 1];
                let mut gcaps: Vec<String> = Vec::new();
                match match_seq(inner, &src[si..], &mut gcaps) {
                    Some(consumed) => { si += consumed; caps.extend(gcaps); }
                    None => {
                        // optional group absent: its markers capture as empty
                        fn markers(pat: &[String], caps: &mut Vec<String>) {
                            for t in pat {
                                if t == "[" || t == "]" { continue; }
                                if t.starts_with('<') && t.ends_with('>') { caps.push(String::new()); }
                            }
                        }
                        markers(inner, caps);
                    }
                }
                pi = j;
            } else if p.starts_with("<(") && p.ends_with(")>") {
                // <(x)> match marker: source must be a parenthesized
                // expression (probes b14/b16); capture the inner tokens
                if si >= src.len() || src[si] != "(" { return None; }
                let mut depth = 0i32;
                let mut k = si;
                while k < src.len() {
                    if src[k] == "(" { depth += 1; } else if src[k] == ")" { depth -= 1; if depth == 0 { break; } }
                    k += 1;
                }
                if k >= src.len() { return None; } // unbalanced
                caps.push(src[si + 1..k].join(" "));
                if caps.last().map(|c| c.is_empty()).unwrap_or(true) { return None; }
                si = k + 1;
                pi += 1;
            } else if p.starts_with('<') && p.ends_with('>') {
                // <x> or <x,...>: capture up to the next literal anywhere
                // ahead in the pattern (group brackets included)
                let lit = next_lit(pat, pi + 1);
                let end = capture_to(src, si, lit)?;
                caps.push(src[si..end].join(" "));
                if caps.last().map(|c| c.is_empty()).unwrap_or(true) { return None; } // empty capture: no match
                si = end;
                pi += 1;
            } else {
                if si >= src.len() || !src[si].eq_ignore_ascii_case(p) { return None; }
                si += 1;
                pi += 1;
            }
        }
        Some(si)
    }
    let mut caps: Vec<String> = Vec::new();
    let consumed = match_seq(pat, src, &mut caps)?;
    if consumed != src.len() { return None; } // trailing tokens: no match
    Some(caps)
}

fn apply_commands(line: &str, cmds: &[Cmd], line_no: usize) -> Result<Option<String>, String> {
    let src = cmd_tokens(line);
    if src.is_empty() { return Ok(None); }
    let mut starts = false;
    for c in cmds {
        let first = match c.pattern.first() { Some(f) => f, None => continue };
        if first.starts_with('<') { continue; }
        if !src[0].eq_ignore_ascii_case(first) { continue; }
        starts = true;
        if let Some(caps) = cmd_match(&c.pattern, &src) {
            let mut out = c.result.clone();
            let mut pi = 0usize;
            for t in &c.pattern {
                if t.starts_with('<') && t.ends_with('>') {
                    let name = &t[1..t.len() - 1];
                    // Harbour result-side markers use the plain name: a list
                    // captured as <x,...> is inserted via <x> (see std.ch:
                    // #command ? [<explist,...>] => QOut( <explist> )); a
                    // parenthesized capture <(x)> is inserted via <x> plain or
                    // <(x)> re-parenthesized (probes b15-b17)
                    let is_paren = name.starts_with('(') && name.ends_with(')');
                    let inner = if is_paren { &name[1..name.len() - 1] } else { name };
                    let base = inner.strip_suffix(",...").unwrap_or(inner);
                    for (needle, insertion) in [
                        (format!("<{}>", base.to_lowercase()), caps[pi].clone()),
                        (format!("<({})>", base.to_lowercase()), format!("( {} )", caps[pi])),
                    ] {
                        let low = out.to_lowercase();
                        let mut rebuilt = String::new();
                        let mut at = 0usize;
                        while let Some(k) = low[at..].find(&needle) {
                            rebuilt.push_str(&out[at..at + k]);
                            rebuilt.push_str(&insertion);
                            at += k + needle.len();
                        }
                        rebuilt.push_str(&out[at..]);
                        out = rebuilt;
                    }
                    pi += 1;
                }
            }
            return Ok(Some(out));
        }
    }
    if starts {
        return Err(format!("line {}: incomplete statement for the command used here (Harbour: E0020)", line_no));
    }
    Ok(None)
}

// `#define NAME body` or `#define NAME(p1, p2) body`; the '(' must touch the
// name to make it function-like.
pub fn parse_define(arg: &str, line: usize) -> Result<(String, Vec<String>, String), String> {
    let bytes = arg.as_bytes();
    let mut i = 0usize;
    while i < bytes.len() && ((bytes[i] as char).is_ascii_alphanumeric() || bytes[i] == b'_') { i += 1; }
    if i == 0 { return Err(format!("line {}: #define needs a name", line)); }
    let name = arg[..i].to_string();
    if i < bytes.len() && bytes[i] == b'(' {
        let close = arg[i..].find(')').ok_or_else(|| format!("line {}: unterminated parameter list in #define", line))? + i;
        let plist = &arg[i + 1..close];
        let params: Vec<String> = if plist.trim().is_empty() {
            Vec::new()
        } else {
            plist.split(',').map(|p| p.trim().to_string()).collect()
        };
        if params.iter().any(|p| p.is_empty()) {
            return Err(format!("line {}: empty parameter name in #define", line));
        }
        return Ok((name, params.clone(), arg[close + 1..].trim().to_string()));
    }
    let body = arg[i..].trim().to_string();
    Ok((name, Vec::new(), body))
}

pub fn process(path: &str, pp: &mut Pp, out: &mut String, depth: usize) -> Result<(), String> {
    if depth > 16 { return Err("too many nested #include levels".to_string()); }
    let text = fs::read_to_string(path).map_err(|e| format!("cannot read {}: {}", path, e))?;
    let mut conds: Vec<Cond> = Vec::new();
    let mut emitting = true;
    for (li, raw) in text.lines().enumerate() {
        let line = li + 1;
        let t = raw.trim_start();
        if !t.starts_with('#') {
            if emitting {
                // commands can expand into other commands (probe c04):
                // re-match the result, capped like macro expansion
                let mut cur = t.to_string();
                let mut depth = 0usize;
                loop {
                    match apply_commands(&cur, &pp.cmds, line)? {
                        Some(x) => {
                            depth += 1;
                            if depth > 16 { return Err(format!("line {}: command expansion too deep (recursive command?)", line)); }
                            cur = x;
                        }
                        None => break,
                    }
                }
                out.push_str(&expand(&cur, &pp.defs, line)?);
                out.push('\n');
            }
            continue;
        }
        let rest = t[1..].trim_start();
        let end = rest.find(|c: char| c.is_whitespace() || c == '(').unwrap_or(rest.len());
        let (dir, arg) = (rest[..end].to_uppercase(), rest[end..].trim().to_string());
        match dir.as_str() {
            "DEFINE" => {
                if emitting {
                    let (name, params, body) = parse_define(&arg, line)?;
                    pp.defs.insert(name, Def { params, body });
                }
            }
            "COMMAND" | "XCOMMAND" => {
                if emitting {
                    let arrow = arg.find("=>").ok_or_else(|| format!("line {}: #{} needs `pattern => result`", line, dir.to_lowercase()))?;
                    let pattern = cmd_tokens(arg[..arrow].trim());
                    let result = arg[arrow + 2..].trim().to_string();
                    if pattern.is_empty() || result.is_empty() {
                        return Err(format!("line {}: #{} needs `pattern => result`", line, dir.to_lowercase()));
                    }
                    pp.cmds.push(Cmd { pattern, result });
                }
            }
            "TRANSLATE" | "XTRANSLATE" => {
                if emitting {
                    let arrow = arg.find("=>").ok_or_else(|| format!("line {}: #translate needs `pattern => result`", line))?;
                    let pat = arg[..arrow].trim();
                    let result = arg[arrow + 2..].trim().to_string();
                    match parse_define(pat, line) {
                        // Call form NAME( <p>, ... ) => body: exactly a
                        // function-like define (inline use in expressions).
                        Ok((name, params, _)) if !(params.is_empty() && !pat.contains('(')) => {
                            pp.defs.insert(name, Def { params, body: result });
                        }
                        // Non-call form: statement-start rule, same machinery
                        // as #command (probes b19-b21: Harbour applies it at
                        // statement start - and after its own `?` command via
                        // std.ch chaining, which this PoC does not emulate -
                        // but rejects it inside an expression, E0030).
                        _ => {
                            let pattern = cmd_tokens(pat);
                            if pattern.is_empty() || result.is_empty() {
                                return Err(format!("line {}: #translate needs `pattern => result`", line));
                            }
                            pp.cmds.push(Cmd { pattern, result });
                        }
                    }
                }
            }
            "UNDEF" => { if emitting { pp.defs.remove(&arg); } }
            "IFDEF" | "IFNDEF" => {
                let has = pp.defs.contains_key(&arg);
                let cond = if dir == "IFDEF" { has } else { !has };
                let act = emitting && cond;
                conds.push(Cond { active: act, taken: cond });
                emitting = act;
            }
            "IF" => {
                let cond = if emitting { eval_if(&arg, &pp.defs, line)? } else { false };
                let act = emitting && cond;
                conds.push(Cond { active: act, taken: cond && emitting });
                emitting = act;
            }
            "ELIF" => {
                if conds.is_empty() { return Err(format!("line {}: #elif without #if", line)); }
                let parent = conds[..conds.len() - 1].iter().all(|x| x.active);
                let taken = conds.last().map(|c| c.taken).unwrap_or(false);
                let cond = if parent && !taken { eval_if(&arg, &pp.defs, line)? } else { false };
                let c = conds.last_mut().unwrap();
                c.active = parent && !taken && cond;
                c.taken = taken || cond;
                emitting = c.active;
            }
            "ELSE" => {
                if conds.is_empty() { return Err(format!("line {}: #else without #if", line)); }
                let parent = conds[..conds.len() - 1].iter().all(|x| x.active);
                let c = conds.last_mut().unwrap();
                c.active = parent && !c.taken;
                c.taken = true;
                emitting = c.active;
            }
            "ENDIF" => {
                conds.pop().ok_or_else(|| format!("line {}: #endif without #if", line))?;
                emitting = conds.iter().all(|c| c.active);
            }
            "INCLUDE" => {
                if emitting {
                    let name = arg.trim_matches(|c| c == '"' || c == '\'');
                    let mut full = None;
                    let parent_dir = std::path::Path::new(path).parent().map(|p| p.to_path_buf()).filter(|p| !p.as_os_str().is_empty()).unwrap_or_else(|| std::path::PathBuf::from("."));
                    let mut cands: Vec<String> = vec![format!("{}/{}", parent_dir.display(), name)];
                    for d in &pp.incdirs { cands.push(format!("{}/{}", d, name)); }
                    for c in cands { if fs::metadata(&c).is_ok() { full = Some(c); break; } }
                    let f = full.ok_or_else(|| format!("line {}: cannot find include {}", line, name))?;
                    process(&f, pp, out, depth + 1)?;
                }
            }
            "ERROR" => {
                if emitting { return Err(format!("line {}: #error {}", line, arg)); }
            }
            "" => {}
            _ => return Err(format!("line {}: unknown directive #{} in this PoC", line, dir.to_lowercase())),
        }
    }
    if !conds.is_empty() { return Err(format!("{}: unterminated #if/#ifdef", path)); }
    Ok(())
}

