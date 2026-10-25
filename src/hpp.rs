// hpp - HarbourRust preprocessor (PoC, MIT, written from scratch).
//
// Behavioural basis: docs/PP-F0.md (black-box probes against the Harbour
// toolchain; no Harbour source read or copied). F1 scope: object-like
// #define / #undef, #ifdef / #ifndef / #else / #elif / #endif, #if with
// integer constants, ==, relational operators, .and./.or./.not. and
// defined(), #include, #error. Directive names are case-insensitive.
// Redefinition is allowed, last definition wins.
//
// Usage: hpp <input.prg> [-I <dir>]... [-o <output>]
// Without -o, writes to stdout. Exit 1 with `error: ...` on any failure.

use std::collections::HashMap;
use std::env;
use std::fs;
use std::process;

#[derive(Clone)]
struct Def {
    body: String,
}

struct Pp {
    defs: HashMap<String, Def>, // key: UPPERCASE name (directives are case-insensitive)
    incdirs: Vec<String>,
}

// A conditional stack entry: whether the current branch is emitting and
// whether any earlier branch of this conditional already emitted.
struct Cond {
    active: bool,
    taken: bool,
}

fn eval_if(expr: &str, defs: &HashMap<String, Def>, line: usize) -> Result<bool, String> {
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

// Expand object-like defines in a source line (longest name first, word
// boundaries). Function-like defines are F2: not in F1.
fn expand(line: &str, defs: &HashMap<String, Def>) -> String {
    let mut names: Vec<&String> = defs.keys().collect();
    names.sort_by_key(|n| std::cmp::Reverse(n.len()));
    let b = line.as_bytes();
    let mut out = String::with_capacity(line.len());
    let mut i = 0usize;
    let mut in_str: Option<u8> = None;
    while i < b.len() {
        let c = b[i];
        if in_str.is_none() && (c == b'"' || c == b'\'') {
            in_str = Some(c);
            out.push(c as char);
            i += 1;
            continue;
        }
        if in_str == Some(c) { in_str = None; out.push(c as char); i += 1; continue; }
        if in_str.is_none() && ((c as char).is_ascii_alphabetic() || c == b'_') {
            let mut j = i;
            while j < b.len() && ((b[j] as char).is_ascii_alphanumeric() || b[j] == b'_') { j += 1; }
            let word = &line[i..j];
            let up = word.to_uppercase();
            if let Some(d) = defs.get(&up) {
                out.push_str(&d.body);
            } else {
                out.push_str(word);
            }
            i = j;
            continue;
        }
        out.push(c as char);
        i += 1;
    }
    out
}

fn process(path: &str, pp: &mut Pp, out: &mut String, depth: usize) -> Result<(), String> {
    if depth > 16 { return Err("too many nested #include levels".to_string()); }
    let text = fs::read_to_string(path).map_err(|e| format!("cannot read {}: {}", path, e))?;
    let mut conds: Vec<Cond> = Vec::new();
    let mut emitting = true;
    for (li, raw) in text.lines().enumerate() {
        let line = li + 1;
        let t = raw.trim_start();
        if !t.starts_with('#') {
            if emitting { out.push_str(&expand(raw, &pp.defs)); out.push('\n'); }
            continue;
        }
        let rest = t[1..].trim_start();
        let end = rest.find(|c: char| c.is_whitespace() || c == '(').unwrap_or(rest.len());
        let (dir, arg) = (rest[..end].to_uppercase(), rest[end..].trim().to_string());
        match dir.as_str() {
            "DEFINE" => {
                if emitting {
                    let sp = arg.find(char::is_whitespace).unwrap_or(arg.len());
                    let (name, body) = (arg[..sp].to_uppercase(), arg[sp..].trim().to_string());
                    if name.is_empty() || name.contains('(') {
                        return Err(format!("line {}: only object-like #define in this PoC (function-like is F2)", line));
                    }
                    pp.defs.insert(name, Def { body });
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

fn main() {
    let mut args = env::args().skip(1);
    let mut input = None;
    let mut output = None;
    let mut incdirs: Vec<String> = Vec::new();
    while let Some(a) = args.next() {
        match a.as_str() {
            "-o" => output = args.next(),
            "-I" => incdirs.push(args.next().expect("-I needs a directory")),
            _ if a.starts_with("-I") => incdirs.push(a[2..].to_string()),
            _ => input = Some(a),
        }
    }
    let input = match input {
        Some(x) => x,
        None => { eprintln!("usage: hpp <input.prg> [-I <dir>]... [-o <output>]"); process::exit(2); }
    };
    let mut pp = Pp { defs: HashMap::new(), incdirs };
    let mut out = String::new();
    if let Err(m) = process(&input, &mut pp, &mut out, 0) {
        eprintln!("error: {}", m);
        process::exit(1);
    }
    match output {
        Some(f) => { fs::write(&f, out).unwrap_or_else(|e| { eprintln!("error: cannot write {}: {}", f, e); process::exit(1); }); }
        None => print!("{}", out),
    }
}
