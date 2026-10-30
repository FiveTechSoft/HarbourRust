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
    params: Vec<String>,
    // true: function-like (the `(` touched the name at define time);
    // false: object-like. Distinct even with zero params (probe b42:
    // `#define PI2() 6` expands only as `PI2()`).
    funclike: bool,
    body: String,
    // Identical rules stack in Harbour (b37f): one #untranslate removes ONE
    // instance, the rest stay active. Only #translate/#xtranslate call-form
    // rules use this count; plain #define replaces, as before.
    dup: u32,
}

pub struct Pp {
    pub defs: HashMap<String, Def>, // key: exact name (macro names are case-sensitive)
    pub cmds: Vec<Cmd>,             // #command / #xcommand / #translate rules, in order
    pub incdirs: Vec<String>,
    pub end_lines: Vec<usize>, // emitted statement -> final source line (ProcLine)
    pub origins: Vec<(String, usize)>, // emitted line -> original path/line (diagnostics)
}

// A command rule: pattern tokens (literal words or <param>) => result template.
// Scoped F3a: no optional [...] clauses, no <x,...> lists, no match markers.
pub struct Cmd {
    pattern: Vec<String>, // tokens; "<name>" marks a capture
    result: String,
    restricted_exact: bool, // X directives disallow abbreviation in new lists
}

impl Pp {
    pub fn new(incdirs: Vec<String>, windows: bool) -> Self {
        let mut defs = HashMap::new();
        // Predefined macros, measured on the pinned Harbour (oracle hk248):
        // __HARBOUR__ expands to 197121 (0x030201) and __PLATFORM__UNIX is
        // defined (empty body, like Harbour's own - it exists for
        // defined()/#ifdef checks; `? __PLATFORM__UNIX` expands to
        // nothing, same as Harbour).
        // Keys are exact-case (this pp is case-sensitive for macro names);
        // the ecosystem writes both in upper case.
        // __HARBOUR__ is a VERSION STAMP ONLY (197121 = 0x030201, Harbour
        // 3.2.0dev, measured on the pinned harbour-core, oracle hk248): it
        // lets conditional compilation take Harbour branches. It is not a
        // claim of Harbour runtime completeness.
        defs.insert("__HARBOUR__".to_string(), Def { params: Vec::new(), funclike: false, body: "197121".to_string(), dup: 1 });
        // The platform macro follows the COMPILE TARGET, not the host:
        // hk248 measured the Linux target (defines __PLATFORM__UNIX, not
        // __PLATFORM__WINDOWS); the Windows target mirrors it. Hardcoding
        // UNIX here would make --target=windows take Unix branches.
        if windows {
            defs.insert("__PLATFORM__WINDOWS".to_string(), Def { params: Vec::new(), funclike: false, body: String::new(), dup: 1 });
        } else {
            defs.insert("__PLATFORM__UNIX".to_string(), Def { params: Vec::new(), funclike: false, body: String::new(), dup: 1 });
        }
        // Scoped default standard macro (std.ch:55, measured hk458):
        // only this exact function-like definition, NOT the whole std.ch
        // command set. Existing #undef/redefinition remain authoritative.
        defs.insert("HB_SYMBOL_UNUSED".to_string(), Def {
            params: vec!["symbol".to_string()], funclike: true,
            body: "( ( symbol ) )".to_string(), dup: 1,
        });
        Pp { defs, cmds: Vec::new(), incdirs, origins: Vec::new(), end_lines: Vec::new() }
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
                "__PRAGMA" => {
                    // Harbour pp built-in (oracle hk320: hbmk2 with no -w
                    // flag defaults WARNINGLEVEL to 0). WARNINGLEVEL is the
                    // only selector the stock headers use (hbclass.ch);
                    // anything else stays a named rejection.
                    while i < b.len() && (b[i] as char).is_whitespace() { i += 1; }
                    if i >= b.len() || b[i] != b'(' { return Err(format!("line {}: expected ( after __pragma", line)); }
                    i += 1;
                    while i < b.len() && (b[i] as char).is_whitespace() { i += 1; }
                    let k = i;
                    while i < b.len() && ((b[i] as char).is_ascii_alphanumeric() || b[i] == b'_') { i += 1; }
                    let sel = &expr[k..i].to_string();
                    while i < b.len() && (b[i] as char).is_whitespace() { i += 1; }
                    if i >= b.len() || b[i] != b')' { return Err(format!("line {}: expected ) after __pragma selector", line)); }
                    i += 1;
                    if !sel.eq_ignore_ascii_case("warninglevel") {
                        return Err(format!("line {}: __pragma({}) is not in this increment (only WARNINGLEVEL - oracle hk320)", line, sel));
                    }
                    toks.push(T::Num(0));
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
                Some(d) if !d.funclike => {
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
                    if d.params.is_empty() && args.len() == 1 && args[0].is_empty() { args.clear(); }
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

// Own black-box marker probes: plain/list/paren plus ASCII identifier <!x!>
// and rest-of-line <*x*>, plus restricted literal alternatives <x: A, B>.
// This is not the full Harbour marker grammar.
fn marker_name(inner: &str) -> &str {
    if inner.len()>=2 && ((inner.starts_with('(') && inner.ends_with(')'))
        || (inner.starts_with('!') && inner.ends_with('!'))
        || (inner.starts_with('*') && inner.ends_with('*'))) {
        &inner[1..inner.len()-1]
    } else if let Some((name, _)) = inner.split_once(':') { name.trim() }
    else { inner.strip_suffix(",...").unwrap_or(inner) }
}
fn marker_ident(s: &str) -> bool {
    let b=s.as_bytes();
    !b.is_empty() && (b[0].is_ascii_alphabetic() || b[0]==b'_')
        && b[1..].iter().all(|c|c.is_ascii_alphanumeric() || *c==b'_')
}
// Restricted literal alternatives are case-insensitive token sequences. X directives
// require exact words; ordinary directives permit four-character abbreviations.
// Empty alternatives and macro ampersand restrictions stay fail-closed.
fn restricted_alternatives(inner: &str) -> Option<Vec<Vec<String>>> {
    let (_, choices) = inner.split_once(':')?;
    Some(choices.split(',').map(|s| cmd_tokens(s.trim())).collect())
}
fn repeated_single_marker(t: &str) -> bool {
    (t.starts_with("<!") && t.ends_with("!>"))
        || (t.starts_with('<') && t.ends_with('>') && t.contains(':'))
}
fn validate_markers(pattern: &[String], line: usize) -> Result<(), String> {
    for t in pattern {
        if t.starts_with('<') && t.ends_with('>') && t.len()>2 {
            let inner = &t[1..t.len()-1];
            // Macro restrictions (&) and malformed/empty alternatives are
            // outside this literal-list increment and stay fail-closed.
            let valid_choices = restricted_alternatives(inner).map(|choices|
                !choices.is_empty() && choices.iter().all(|seq| !seq.is_empty()
                    && seq.iter().all(|t| marker_ident(t)
                        || t.bytes().all(|b| b.is_ascii_digit()) || t == "(" || t == ")"))
            ).unwrap_or(true);
            if !marker_ident(marker_name(inner)) || !valid_choices {
                return Err(format!("line {}: bad match marker {} in #command/#translate (Harbour: E0010)",line,t));
            }
        }
    }
    Ok(())
}

// Harbour keyword abbreviation (probes b45/b45b/b45c/b45d/b45e): a source
// word matches a pattern literal when it is EQUAL (case-insensitive) or a
// PREFIX of at least 4 characters; shorter prefixes and longer words do
// not match (DIS fails against DISPLAY; BYE matches only exactly).
fn lit_match(src: &str, lit: &str) -> bool {
    if src.eq_ignore_ascii_case(lit) { return true; }
    src.len() >= 4
        && lit.len() > src.len()
        && src.is_ascii() && lit.is_ascii()
        && lit[..src.len()].eq_ignore_ascii_case(src)
}


// Harbour E0008 (probe b46): a <marker> in the RESULT that does not exist
// in the pattern is an error at define time.
fn validate_result_markers(pattern: &[String], result: &str, line: usize) -> Result<(), String> {
    let mut names: Vec<String> = Vec::new();
    let mut exact_names: Vec<String> = Vec::new();
    for t in pattern {
        if t.starts_with('<') && t.ends_with('>') && t.len() > 2 {
            let inner = &t[1..t.len() - 1];
            let base = marker_name(inner);
            names.push(base.to_lowercase());
            exact_names.push(base.to_string());
        }
    }
    let rc: Vec<char> = result.chars().collect();
    let mut k = 0usize;
    while k < rc.len() {
        if rc[k] == '<' {
            if let Some(rel) = rc[k..].iter().position(|&c| c == '>') {
                let inner: String = rc[k + 1..k + rel].iter().collect();
                let base: &str = if inner.starts_with('(') && inner.ends_with(')') {
                    &inner[1..inner.len() - 1]
                } else {
                    &inner
                };
                let logical = inner.len() >= 2 && inner.starts_with('.') && inner.ends_with('.');
                let valid = if logical {
                    exact_names.contains(&inner[1..inner.len()-1].to_string())
                } else { names.contains(&base.to_lowercase()) };
                if !valid {
                    return Err(format!("line {}: unknown result marker <{}> (Harbour: E0008)", line, inner));
                }
                k += rel + 1;
                continue;
            }
        }
        k += 1;
    }
    Ok(())
}

fn cmd_match(pat: &[String], src: &[String], restricted_exact: bool) -> Option<Vec<String>> {
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
                    if depth == 0 && lit_match(t, l) { return Some(k); }
                    if t == "(" { depth += 1; } else if t == ")" { depth -= 1; }
                    k += 1;
                }
                Some(src.len()) // terminator absent: capture the rest
            }
        }
    }
    // Match a pattern slice (with balanced groups) against src, returning
    // tokens consumed. Captures are pushed in pattern order.
    fn match_seq(pat: &[String], src: &[String], caps: &mut Vec<String>, restricted_exact: bool) -> Option<usize> {
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
                // A lone optional identifier marker repeats over adjacent
                // identifiers (own oracle probes), collecting in one capture.
                if inner.len()==1 && inner[0].starts_with("<!") && inner[0].ends_with("!>") {
                    let start=si;
                    while si<src.len() && marker_ident(&src[si]) {si+=1;}
                    caps.push(src[start..si].join(" "));pi=j;continue;
                }
                let mut gcaps: Vec<String> = Vec::new();
                match match_seq(inner, &src[si..], &mut gcaps, restricted_exact) {
                    Some(consumed) => {
                        si += consumed;
                        // Optional groups containing identifier/restricted markers
                        // repeat greedily, appending each marker capture in order.
                        if consumed>0 && inner.iter().any(|t|repeated_single_marker(t)) {
                            loop {
                                let mut more=Vec::new();
                                match match_seq(inner,&src[si..],&mut more, restricted_exact) {
                                    Some(n) if n>0 && more.len()==gcaps.len()=>{
                                        for (dst,value) in gcaps.iter_mut().zip(more) {
                                            if !value.is_empty(){if !dst.is_empty(){dst.push(' ');}dst.push_str(&value);}
                                        }
                                        si+=n;
                                    }
                                    _=>break,
                                }
                            }
                        }
                        caps.extend(gcaps);
                    }
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
            } else if p.starts_with('<') && p.ends_with('>') && p.contains(':') {
                let choices = restricted_alternatives(&p[1..p.len()-1])?;
                let choice = choices.iter().find(|tokens| !tokens.is_empty()
                    && si + tokens.len() <= src.len()
                    && tokens.iter().zip(&src[si..]).all(|(lit, word)| if restricted_exact { word.eq_ignore_ascii_case(lit) } else { lit_match(word, lit) }))?;
                caps.push(src[si..si+choice.len()].join(" "));
                si += choice.len(); pi += 1;
            } else if p.starts_with("<!") && p.ends_with("!>") {
                if si>=src.len() || !marker_ident(&src[si]) {return None;}
                caps.push(src[si].clone());si+=1;pi+=1;
            } else if p.starts_with("<*") && p.ends_with("*>") {
                // Wildcard consumes ALL remaining tokens, not up to a later
                // literal. A following required literal therefore cannot match.
                if si>=src.len(){return None;}
                caps.push(src[si..].join(" "));si=src.len();pi+=1;
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
                if si >= src.len() || !lit_match(&src[si], p) { return None; }
                si += 1;
                pi += 1;
            }
        }
        Some(si)
    }
    let mut caps: Vec<String> = Vec::new();
    let consumed = match_seq(pat, src, &mut caps, restricted_exact)?;
    if consumed != src.len() { return None; } // trailing tokens: no match
    Some(caps)
}


// Harbour result-side `[ ... ]` (e.g. std.ch's `[, <clr>]`): the bracketed
// part is emitted only when EVERY marker inside it is bound (its optional
// pattern clause matched); otherwise the whole group is dropped (probe
// b35). `bound` holds the lowercase result needles (`<x>`, `<(x)>`) of
// markers whose capture is non-empty.
// Harbour result-side `[ ... ]` (probes b35, b36a-d):
// - if the bracket contains at least one BOUND marker, the content is kept
//   and any UNBOUND markers inside it are individually removed (which can
//   leave syntax both compilers then reject, e.g. b36c: `+ <x> + <y>` with
//   <y> absent yields `+ 5 +`; Harbour E0030, our parse error);
// - if it contains NO bound marker (only unbound markers and/or literal
//   text), the whole bracket is dropped (b36b/b36d, std.ch's `[, <clr>]`
//   with the optional clause absent -> nothing, not even the comma).
// `bound` holds lowercase result needles (`<x>`, `<(x)>`, `<.x.>`) of markers
// whose capture is non-empty.
fn resolve_result_brackets(text: &str, bound: &std::collections::HashSet<String>) -> String {
    fn markers_of(s: &str) -> Vec<String> {
        let ic: Vec<char> = s.chars().collect();
        let mut v = Vec::new();
        let mut k = 0usize;
        while k < ic.len() {
            if ic[k] == '<' {
                if let Some(rel) = ic[k..].iter().position(|&c| c == '>') {
                    v.push(ic[k..=k + rel].iter().collect::<String>().to_lowercase());
                    k += rel + 1;
                    continue;
                }
            }
            k += 1;
        }
        v
    }
    let b: Vec<char> = text.chars().collect();
    let mut out = String::new();
    let mut i = 0usize;
    while i < b.len() {
        if b[i] == '[' {
            let mut depth = 1;
            let mut j = i + 1;
            while j < b.len() && depth > 0 {
                if b[j] == '[' { depth += 1; } else if b[j] == ']' { depth -= 1; }
                j += 1;
            }
            if depth != 0 {
                // unbalanced: leave untouched; downstream parsing reports it
                out.push('[');
                i += 1;
                continue;
            }
            let inner: String = b[i + 1..j - 1].iter().collect();
            let inner = resolve_result_brackets(&inner, bound);
            let ms = markers_of(&inner);
            if ms.iter().any(|m| bound.contains(m)) {
                // keep content; strip unbound markers individually
                let mut kept = inner.clone();
                for m in ms {
                    if !bound.contains(&m) {
                        // markers are matched case-insensitively
                        while let Some(p) = kept.to_lowercase().find(&m) {
                            kept = format!("{}{}", &kept[..p], &kept[p + m.len()..]);
                        }
                    }
                }
                out.push_str(&kept);
            }
            // else: no bound marker -> drop the whole bracket
            i = j;
        } else {
            out.push(b[i]);
            i += 1;
        }
    }
    out
}


// Exact-match rule removal for #uncommand / #untranslate (probes b37a-f):
// the pattern must match token by token (literal words case-insensitively,
// markers exactly) AND the result text must be identical (b37b: a
// different result removes nothing); one directive removes ONE instance of
// a duplicated rule (b37f); removing a never-defined rule is silent
// (b37e). Returns true when a rule was removed.
fn remove_rule(cmds: &mut Vec<Cmd>, pattern: &[String], result: &str) -> bool {
    if let Some(pos) = cmds.iter().rposition(|c| {
        c.pattern.len() == pattern.len()
            && c.pattern.iter().zip(pattern.iter()).all(|(a, b)| {
                let am = a.starts_with('<') && a.ends_with('>');
                let bm = b.starts_with('<') && b.ends_with('>');
                if am || bm { a == b } else { a.eq_ignore_ascii_case(b) }
            })
            && c.result == result
    }) {
        cmds.remove(pos);
        true
    } else {
        false
    }
}

fn apply_commands(line: &str, cmds: &[Cmd], line_no: usize) -> Result<Option<String>, String> {
    let src = cmd_tokens(line);
    if src.is_empty() { return Ok(None); }
    let mut starts = false;
    // Harbour picks the MOST SPECIFIC matching rule (most literal words),
    // regardless of definition order (probes b31/b31b); ties keep the
    // LATEST definition (b47/b47b/b47c).
    let mut best: Option<(usize, usize)> = None; // (literal count, index)
    let mut best_caps: Vec<String> = Vec::new();
    for (ci, c) in cmds.iter().enumerate() {
        let first = match c.pattern.first() { Some(f) => f, None => continue };
        if first.starts_with('<') { continue; }
        if !lit_match(&src[0], first) { continue; }
        starts = true;
        if let Some(caps) = cmd_match(&c.pattern, &src, c.restricted_exact) {
            let lits = c.pattern.iter().filter(|t| !(t.starts_with('<') && t.ends_with('>')) && t.as_str() != "[" && t.as_str() != "]").count();
            // probes b47/b47b/b47c: equal literal counts keep the LATEST
            // definition (>= replaces the current winner with a later tie).
            if best.map(|(bl, _)| lits >= bl).unwrap_or(true) {
                best = Some((lits, ci));
                best_caps = caps;
            }
        }
    }
    if let Some((_, ci)) = best {
        let c = &cmds[ci];
        let caps = best_caps;
        {
            // Resolve result-side [ ... ] groups BEFORE substituting: a
            // marker is bound exactly when its capture is non-empty (an
            // unmatched optional clause captures as empty by construction).
            let mut bound: std::collections::HashSet<String> = std::collections::HashSet::new();
            {
                let mut pi = 0usize;
                for t in &c.pattern {
                    if t.starts_with('<') && t.ends_with('>') {
                        let name = &t[1..t.len() - 1];
                        let is_paren = name.starts_with('(') && name.ends_with(')');
                        let inner = if is_paren { &name[1..name.len() - 1] } else { name };
                        let base = marker_name(inner);
                        if !caps[pi].is_empty() {
                            bound.insert(format!("<{}>", base.to_lowercase()));
                            bound.insert(format!("<({})>", base.to_lowercase()));
                            bound.insert(format!("<.{}.>", base.to_lowercase()));
                        }
                        pi += 1;
                    }
                }
            }
            let mut out = resolve_result_brackets(&c.result, &bound);
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
                    let base = marker_name(inner);
                    for (needle, insertion) in [
                        (format!("<{}>", base.to_lowercase()), caps[pi].clone()),
                        (format!("<({})>", base.to_lowercase()), format!("( {} )", caps[pi])),
                        // Logical result is capture presence, not evaluation.
                        // Emit one atomic dotted literal,without changing the
                        // existing general capture-token reemission path.
                        (format!("<.{}.>", base.to_lowercase()),
                         if caps[pi].is_empty() { ".F.".to_string() } else { ".T.".to_string() }),
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
pub fn parse_define(arg: &str, line: usize) -> Result<(String, Vec<String>, String, bool), String> {
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
        return Ok((name, params.clone(), arg[close + 1..].trim().to_string(), true));
    }
    let body = arg[i..].trim().to_string();
    Ok((name, Vec::new(), body, false))
}


// Harbour comment forms (oracle family hk211, own probes, no Harbour code):
// `//` and `&&` run to end of line; `*` as the first non-whitespace
// character comments the whole line (leading whitespace allowed, hk211b);
// `/* ... */` blocks may sit mid-line (hk211c) and span lines (hk211f), do
// NOT nest (hk211: the first `*/` closes the block), and code may follow
// the closing `*/` on the same line (hk211g). Markers inside string
// literals are data (hk211g). An unterminated block at EOF is a compile
// error (hk211h, Harbour E0023); the line cited is the opening line.
fn strip_line(raw: &str, in_block: &mut bool, block_line: &mut usize, line: usize) -> String {
    let t = raw.trim_start();
    if !*in_block && t.starts_with('*') {
        return String::new();
    }
    let mut out = String::with_capacity(raw.len());
    let mut it = raw.chars().peekable();
    let mut in_str: Option<char> = None;
    while let Some(c) = it.next() {
        if *in_block {
            if c == '*' && it.peek() == Some(&'/') {
                it.next();
                *in_block = false;
            }
            continue;
        }
        match in_str {
            Some(q) => {
                out.push(c);
                if c == q {
                    in_str = None;
                }
            }
            None => match c {
                '"' | '\'' => {
                    in_str = Some(c);
                    out.push(c);
                }
                '/' => {
                    if it.peek() == Some(&'/') {
                        break;
                    }
                    if it.peek() == Some(&'*') {
                        it.next();
                        *in_block = true;
                        *block_line = line;
                    } else {
                        out.push(c);
                    }
                }
                '&' => {
                    if it.peek() == Some(&'&') {
                        break;
                    }
                    out.push(c);
                }
                _ => out.push(c),
            },
        }
    }
    out
}

// Physical trailing semicolons are continuation markers, consumed earlier.
// Remaining unquoted semicolons separate statements, including macro results.
fn split_statements(text: &str) -> Vec<&str> {
    let mut q = None;
    let mut start = 0;
    let mut parts = Vec::new();
    for (i,c) in text.char_indices() {
        if let Some(v) = q { if c == v { q = None; } }
        else if c == '\'' || c == '"' { q = Some(c); }
        else if c == ';' { parts.push(&text[start..i]); start = i+1; }
    }
    parts.push(&text[start..]);
    parts
}

pub fn process(path: &str, pp: &mut Pp, out: &mut String, depth: usize) -> Result<(), String> {
    if depth > 16 { return Err("too many nested #include levels".to_string()); }
    let text = fs::read_to_string(path).map_err(|e| format!("cannot read {}: {}", path, e))?;
    let mut conds: Vec<Cond> = Vec::new();
    let mut emitting = true;
    // Harbour line continuation (probes b39/b39e, oracles hk357-hk368):
    // a line whose last non-whitespace character is a `;` OUTSIDE any
    // string literal joins with the next line. Only COMMENTS may follow
    // the `;` - hk362 measures `; // comment` joining (prints 3), hk367
    // measures `; /* block */` joining, even a MULTI-LINE block comment
    // with code after its close; hk368 measures CODE after the `;` as a
    // Harbour E0030 syntax error for an INCOMPLETE first expression.
    // Complete statements separated by semicolons are supported below.
    // (The old b39c probe claimed even a
    // comment blocked the join; hk362/hk367 on the pinned hbmk2 supersede
    // it - the original probe text was lost to a sandbox wipe, so the
    // fresh oracles are the record.) Comments are stripped before this
    // check, so a stripped line ending in `;` had only ws/comments after
    // it. The join inserts a space: tokens never merge across the break
    // (hk363: `ab;` + `c` is NOT `abc`). The joined statement reports its
    // first line's number.
    let raws: Vec<&str> = text.lines().collect();
    // Strip comments before any directive or continuation processing, the
    // same point Harbour's own reader drops them. Line count is preserved
    // (a stripped line keeps its newline) so reported line numbers stay put.
    let mut in_block = false;
    let mut block_line = 0usize;
    let mut stripped: Vec<String> = Vec::with_capacity(raws.len());
    for (idx, raw) in raws.iter().enumerate() {
        stripped.push(strip_line(raw, &mut in_block, &mut block_line, idx + 1));
    }
    if in_block {
        return Err(format!("line {}: unterminated /* */ comment", block_line));
    }
    let mut li = 0usize;
    while li < raws.len() {
        let line = li + 1;
        let mut joined = stripped[li].clone();
        loop {
            let mut in_str = false;
            let mut q = '"';
            let mut last_non_ws: Option<char> = None;
            for ch in joined.chars() {
                if in_str {
                    if ch == q { in_str = false; }
                } else if ch == '"' || ch == '\'' {
                    in_str = true; q = ch;
                }
                if !ch.is_whitespace() { last_non_ws = Some(ch); }
            }
            if in_str || last_non_ws != Some(';') { break; }
            if li + 1 >= raws.len() { break; } // Harbour accepts a final separator at EOF (hk482).
            joined.pop(); // the ';' itself (it is the last char only if no trailing ws)
            while joined.ends_with(|c: char| c.is_whitespace()) { joined.pop(); }
            if joined.ends_with(';') { joined.pop(); }
            joined.push(' ');
            li += 1;
            joined.push_str(stripped[li].trim_start());
        }
        let raw = joined.as_str();
        let t = raw.trim_start();
        if !t.starts_with('#') {
            if emitting {
                for statement in split_statements(t) {
                    // Match each source statement separately. Expansion can
                    // itself emit separators; split again only after expansion.
                    let mut cur = statement.trim().to_string();
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
                    let expanded = expand(&cur, &pp.defs, line)?;
                    for part in split_statements(&expanded) {
                        for _ in 0..part.split('\n').count() {
                            pp.origins.push((path.to_string(), line));
                            pp.end_lines.push(li + 1);
                        }
                        out.push_str(part);
                        out.push('\n');
                    }
                }
            }
            li += 1;
            continue;
        }
        let rest = t[1..].trim_start();
        let end = rest.find(|c: char| c.is_whitespace() || c == '(').unwrap_or(rest.len());
        let (dir, arg) = (rest[..end].to_uppercase(), rest[end..].trim().to_string());
        match dir.as_str() {
            "DEFINE" => {
                if emitting {
                    let (name, params, body, funclike) = parse_define(&arg, line)?;
                    pp.defs.insert(name, Def { params, funclike, body, dup: 1 });
                }
            }
            "COMMAND" | "XCOMMAND" => {
                if emitting {
                    let arrow = arg.find("=>").ok_or_else(|| format!("line {}: #{} needs `pattern => result`", line, dir.to_lowercase()))?;
                    let pattern = cmd_tokens(arg[..arrow].trim());
                    // An empty RESULT is legal (probe b40: the statement is
                    // deleted); an empty pattern is not.
                    if pattern.is_empty() {
                        return Err(format!("line {}: #{} needs `pattern => result`", line, dir.to_lowercase()));
                    }
                    validate_markers(&pattern, line)?;
                    let result = arg[arrow + 2..].trim().to_string();
                    validate_result_markers(&pattern, &result, line)?;
                    pp.cmds.push(Cmd { pattern, result, restricted_exact: dir.starts_with('X') });
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
                        Ok((name, params, _, _)) if !(params.is_empty() && !pat.contains('(')) => {
                            // Identical translate rules stack (probe b37f);
                            // a differing one replaces, like #define.
                            match pp.defs.get_mut(&name) {
                                Some(d) if d.params == params && d.body.trim() == result.trim() => { d.dup += 1; }
                                _ => { pp.defs.insert(name, Def { params, funclike: true, body: result, dup: 1 }); }
                            }
                        }
                        // Non-call form: statement-start rule, same machinery
                        // as #command (probes b19-b21: Harbour applies it at
                        // statement start - and after its own `?` command via
                        // std.ch chaining, which this PoC does not emulate -
                        // but rejects it inside an expression, E0030).
                        _ => {
                            // Empty result is legal here too (probe b44).
                            let pattern = cmd_tokens(pat);
                            if pattern.is_empty() {
                                return Err(format!("line {}: #translate needs `pattern => result`", line));
                            }
                            validate_markers(&pattern, line)?;
                            validate_result_markers(&pattern, &result, line)?;
                            pp.cmds.push(Cmd { pattern, result, restricted_exact: dir.starts_with('X') });
                        }
                    }
                }
            }
            "UNCOMMAND" | "UXCOMMAND" => {
                if emitting {
                    let arrow = arg.find("=>").ok_or_else(|| format!("line {}: #{} needs `pattern => result`", line, dir.to_lowercase()))?;
                    let pattern = cmd_tokens(arg[..arrow].trim());
                    let result = arg[arrow + 2..].trim().to_string();
                    remove_rule(&mut pp.cmds, &pattern, &result);
                }
            }
            "UNTRANSLATE" | "UXTRANSLATE" => {
                if emitting {
                    let arrow = arg.find("=>").ok_or_else(|| format!("line {}: #untranslate needs `pattern => result`", line))?;
                    let pat = arg[..arrow].trim();
                    let result = arg[arrow + 2..].trim().to_string();
                    match parse_define(pat, line) {
                        // Call form: the rule lives in the define table;
                        // name, parameter names and body must all match.
                        Ok((name, params, _, _)) if !(params.is_empty() && !pat.contains('(')) => {
                            // Pop ONE instance of a stacked rule (b37f).
                            let pop = pp.defs.get(&name).map(|d| d.params == params && d.body.trim() == result).unwrap_or(false);
                            if pop {
                                if let Some(d) = pp.defs.get_mut(&name) { d.dup = d.dup.saturating_sub(1); }
                                if pp.defs.get(&name).map(|d| d.dup == 0).unwrap_or(false) { pp.defs.remove(&name); }
                            }
                        }
                        _ => {
                            let pattern = cmd_tokens(pat);
                            remove_rule(&mut pp.cmds, &pattern, &result);
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
                    // Probe b38: the angle form <file> searches the -I paths
                    // ONLY (Harbour F0029 without -I, even in the same
                    // directory); the quoted form checks the including
                    // file's directory first, then the -I paths.
                    let angle = arg.starts_with('<') && arg.ends_with('>');
                    let name = if angle {
                        arg[1..arg.len() - 1].trim().to_string()
                    } else {
                        arg.trim_matches(|c| c == '"' || c == '\'').to_string()
                    };
                    let parent_dir = std::path::Path::new(path).parent().map(|p| p.to_path_buf()).filter(|p| !p.as_os_str().is_empty()).unwrap_or_else(|| std::path::PathBuf::from("."));
                    let mut cands: Vec<String> = Vec::new();
                    if !angle { cands.push(format!("{}/{}", parent_dir.display(), name)); }
                    for d in &pp.incdirs { cands.push(format!("{}/{}", d, name)); }
                    let mut full = None;
                    for c in cands { if fs::metadata(&c).is_ok() { full = Some(c); break; } }
                    let f = full.ok_or_else(|| format!("line {}: cannot find include {}", line, name))?;
                    process(&f, pp, out, depth + 1)?;
                }
            }
            "ERROR" => {
                if emitting { return Err(format!("line {}: #error {}", line, arg)); }
            }
            "WARNING" => {
                // Harbour accepts #warning without aborting compilation.
                // This dialect's warning level is fixed at the measured
                // default 0 (__pragma(WARNINGLEVEL), hk320/hk451): explicit
                // warnings are silent there, including unexpanded text.
                // Do not turn their payload into source or expand macros.
            }
            "" => {}
            _ => return Err(format!("line {}: unknown directive #{} in this PoC", line, dir.to_lowercase())),
        }
        li += 1;
    }
    if !conds.is_empty() { return Err(format!("{}: unterminated #if/#ifdef", path)); }
    Ok(())
}

