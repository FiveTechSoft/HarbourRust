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
    pub defs: HashMap<String, Def>, // key: UPPERCASE name (directives are case-insensitive)
    pub incdirs: Vec<String>,
}

impl Pp {
    pub fn new(incdirs: Vec<String>) -> Self {
        Pp { defs: HashMap::new(), incdirs }
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
        LP,
        RP,
        Not,
        And,
        Or,
    }
    let up = expr.to_uppercase();
    let b = up.as_bytes();
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
            let v: i64 = up[i..j].parse().map_err(|_| format!("line {}: bad number in #if", line))?;
            toks.push(T::Num(v));
            i = j;
            continue;
        }
        if c.is_ascii_alphabetic() || c == '_' || c == '.' {
            let mut j = i;
            while j < b.len() && ((b[j] as char).is_ascii_alphanumeric() || b[j] == b'_' || b[j] == b'.') { j += 1; }
            let w = &up[i..j];
            i = j;
            match w {
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
                    let name = &up[k..i];
                    while i < b.len() && (b[i] as char).is_whitespace() { i += 1; }
                    if i >= b.len() || b[i] != b')' { return Err(format!("line {}: expected ) after defined name", line)); }
                    i += 1;
                    toks.push(T::Num(if defs.contains_key(name) { 1 } else { 0 }));
                }
                _ => {
                    // A defined macro expands to its body if numeric, else 0.
                    let v = defs.get(w).and_then(|d| d.body.trim().parse::<i64>().ok()).unwrap_or(0);
                    toks.push(T::Num(v));
                }
            }
            continue;
        }
        // operators: ==, !=, >=, <=, >, <
        if i + 1 < b.len() {
            let two = &up[i..i + 2];
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
    fn parse_cmp(t: &[T], p: &mut usize, line: usize) -> Result<i64, String> {
        let l = parse_atom(t, p, line)?;
        if *p < t.len() {
            if let T::Op(op) = &t[*p] {
                *p += 1;
                let r = parse_atom(t, p, line)?;
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
            let up = word.to_uppercase();
            match defs.get(&up) {
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
        if in_str.is_none() && i + nb.len() <= b.len() && b[i..i + nb.len()].eq_ignore_ascii_case(nb) {
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

// `#define NAME body` or `#define NAME(p1, p2) body`; the '(' must touch the
// name to make it function-like.
pub fn parse_define(arg: &str, line: usize) -> Result<(String, Vec<String>, String), String> {
    let bytes = arg.as_bytes();
    let mut i = 0usize;
    while i < bytes.len() && ((bytes[i] as char).is_ascii_alphanumeric() || bytes[i] == b'_') { i += 1; }
    if i == 0 { return Err(format!("line {}: #define needs a name", line)); }
    let name = arg[..i].to_uppercase();
    if i < bytes.len() && bytes[i] == b'(' {
        let close = arg[i..].find(')').ok_or_else(|| format!("line {}: unterminated parameter list in #define", line))? + i;
        let plist = &arg[i + 1..close];
        let params: Vec<String> = if plist.trim().is_empty() {
            Vec::new()
        } else {
            plist.split(',').map(|p| p.trim().to_uppercase()).collect()
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
            if emitting { out.push_str(&expand(raw, &pp.defs, line)?); out.push('\n'); }
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
            "UNDEF" => { if emitting { pp.defs.remove(&arg.to_uppercase()); } }
            "IFDEF" | "IFNDEF" => {
                let has = pp.defs.contains_key(&arg.to_uppercase());
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

