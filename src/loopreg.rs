// Loop register promotion (codegen phase 2; `--no-loopreg` turns it off).
//
// hbc keeps every local in its rbp frame slot, so a loop that updates an
// integer accumulator stores and reloads it through memory on every
// iteration; that store/reload chain, not the instruction count, is what
// dominates hot integer loops (docs/PEEPHOLE-2026-11-19.md). This pass runs
// on the final assembly text after the peephole pass and, for each
// statement loop (FOR `.Lforc_*`..`.Lfore_*`, WHILE `.Lwhile_*`..`.Lendw_*`)
// whose body is straight inline code, keeps the 8-byte value word of some
// frame slots in caller-saved registers the loop never mentions:
//
//   * the slot's value is loaded into its register right before the loop
//     head label (the head is only reached by fall-through from outside);
//   * every access to the slot inside the loop becomes the register;
//   * every jump that leaves the loop (EXIT, RETURN, the loop end, an
//     overflow or bound error handler) goes through a stub that stores the
//     written slots back first, so code after the loop, error handlers and
//     RECOVER see the frame exactly as before.
//
// A loop qualifies only when, between its head and end labels, there is no
// call, ret, indirect jump, string instruction, directive or comment, no
// memory access through any base other than rbp/rsp/rip (nothing can reach
// the frame through a pointer), no indexed rbp access, and no label that is
// referenced from outside the loop. A slot qualifies only when every access
// overlapping its 8 bytes in the loop is the exact operand `-N(%rbp)` in a
// plain 64-bit integer form (mov, add, sub, cmp, test, and, or, xor, imul,
// inc, dec, neg, not) and its address is never taken (`lea -N(%rbp)`) in
// the function. Slots read and written in the loop (the carried chains)
// get registers first, then read-only, then write-only slots. Without calls
// no ABI rule applies inside the loop, and registers the code generator
// treats as volatile cannot be live across a statement, so r8, r9, r10, rsi
// and rdi are free whenever the loop text does not name them. (rsi and rdi
// are callee-saved in the Win64 ABI, but hbc code uses its own SysV-like
// convention on every target: hbc_fn_* bodies already clobber them without
// saving, the runtime blobs entered from C use the same convention (e.g.
// hrm_call takes its id in %edi and saves only rbx and r12-r15), and the
// Win64 entries, hbc_wthr_entry and the process entry, never return to C.)
// Every output form already appears in
// the generated code with a register operand, so the ELF/PE/Mach-O writers
// and the ARM64 translator see no new instruction shapes.

use std::collections::{HashMap, HashSet};

const POOL: [&str; 5] = ["r8", "r9", "r10", "rsi", "rdi"];
const RX: [&str; 8] = ["r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15"];

fn canon(r: &str) -> Option<(&'static str, u8)> {
    let t: [(&[&str], &'static str); 8] = [
        (&["rax", "eax", "ax", "al", "ah"], "rax"), (&["rbx", "ebx", "bx", "bl", "bh"], "rbx"),
        (&["rcx", "ecx", "cx", "cl", "ch"], "rcx"), (&["rdx", "edx", "dx", "dl", "dh"], "rdx"),
        (&["rsi", "esi", "si", "sil"], "rsi"), (&["rdi", "edi", "di", "dil"], "rdi"),
        (&["rbp", "ebp", "bp", "bpl"], "rbp"), (&["rsp", "esp", "sp", "spl"], "rsp"),
    ];
    for (names, c) in t.iter() {
        if let Some(k) = names.iter().position(|n| *n == r) {
            let w = match k { 0 => 8, 1 => 4, 2 => 2, _ => 1 };
            return Some((c, w));
        }
    }
    let rest = r.strip_prefix('r')?;
    let digits: String = rest.chars().take_while(|c| c.is_ascii_digit()).collect();
    let k: usize = digits.parse().ok()?;
    if !(8..16).contains(&k) { return None; }
    let w = match &rest[digits.len()..] { "" => 8, "d" => 4, "w" => 2, "b" => 1, _ => return None };
    Some((RX[k - 8], w))
}

fn is_label(l: &str) -> bool {
    !l.starts_with(|c: char| c.is_whitespace()) && l.ends_with(':') && !l.contains(char::is_whitespace) && l.len() > 1
}

fn split_ops(s: &str) -> Vec<String> {
    let mut v = Vec::new();
    let mut depth = 0;
    let mut cur = String::new();
    for c in s.chars() {
        match c {
            '(' => { depth += 1; cur.push(c); }
            ')' => { depth -= 1; cur.push(c); }
            ',' if depth == 0 => { v.push(cur.trim().to_string()); cur.clear(); }
            _ => cur.push(c),
        }
    }
    if !cur.trim().is_empty() { v.push(cur.trim().to_string()); }
    v
}

struct Ins { m: String, ops: Vec<String> }

fn parse(l: &str) -> Option<Ins> {
    if !l.starts_with(|c: char| c.is_whitespace()) { return None; }
    let t = l.trim();
    if t.is_empty() || t.starts_with('.') || t.contains('#') { return None; }
    let (m, rest) = match t.find(' ') { Some(p) => (&t[..p], t[p + 1..].trim()), None => (t, "") };
    Some(Ins { m: m.to_string(), ops: if rest.is_empty() { Vec::new() } else { split_ops(rest) } })
}

// Memory operand: (disp text, base, has index).
fn mem(op: &str) -> Option<(&str, &str, bool)> {
    let p = op.find('(')?;
    let inner = op[p + 1..].strip_suffix(')')?;
    let parts: Vec<&str> = inner.split(',').map(|s| s.trim()).collect();
    let base = parts[0].strip_prefix('%').unwrap_or(parts[0]);
    Some((&op[..p], base, parts.len() > 1 && !parts[1].is_empty()))
}

fn reg64(op: &str) -> bool {
    op.strip_prefix('%').and_then(canon).map_or(false, |(c, w)| w == 8 && c != "rsp" && c != "rbp")
}

fn is_imm(op: &str) -> bool {
    op.strip_prefix('$').map_or(false, |s| { let s = s.strip_prefix('-').unwrap_or(s); !s.is_empty() && s.chars().all(|c| c.is_ascii_digit()) })
}

fn base_mnemonic(m: &str) -> &str {
    const PLAIN: [&str; 13] = ["mov", "add", "sub", "cmp", "test", "and", "or", "xor", "imul", "inc", "dec", "neg", "not"];
    if PLAIN.contains(&m) { return m; }
    if let Some(b) = m.strip_suffix('q') { if PLAIN.contains(&b) { return b; } }
    ""
}

// The slot at operand index `k` is used in a promotable 64-bit integer form.
fn plain_form(i: &Ins, k: usize) -> bool {
    let b = base_mnemonic(&i.m);
    if b.is_empty() { return false; }
    let others_ok = |allow_imm: bool| i.ops.iter().enumerate().all(|(j, o)| j == k || reg64(o) || (allow_imm && is_imm(o)));
    match (b, i.ops.len()) {
        ("inc" | "dec" | "neg" | "not", 1) => true,
        ("imul", 3) => k == 1 && is_imm(&i.ops[0]) && reg64(&i.ops[2]),
        ("imul", 2) => k == 0 && reg64(&i.ops[1]),
        (_, 2) => others_ok(true) && !(k == 0 && is_imm(&i.ops[1])),
        _ => false,
    }
}

// `mov x, slot`: the old value is not read.
fn pure_write(i: &Ins, k: usize) -> bool {
    base_mnemonic(&i.m) == "mov" && k == 1
}

fn writes(i: &Ins, k: usize) -> bool {
    let b = base_mnemonic(&i.m);
    !(b == "cmp" || b == "test") && k + 1 == i.ops.len() && !(b == "imul" && i.ops.len() == 3)
}

// Bytes touched by an rbp operand of an instruction that is not a plain form.
fn width(i: &Ins) -> i64 {
    for o in &i.ops {
        if let Some((_, w)) = o.strip_prefix('%').and_then(canon) { return w as i64; }
    }
    let m = i.m.as_str();
    if ["movsd", "addsd", "subsd", "mulsd", "divsd", "ucomisd", "comisd", "cvttsd2si", "cvttsd2siq", "cvtsd2si", "fldl", "fstpl", "fildq", "fistpq", "fisttpq", "fildll", "fistpll", "movq"].contains(&m) { return 8; }
    if ["movss", "flds", "fstps", "fildl", "fistpl"].contains(&m) { return 4; }
    if ["fldt", "fstpt"].contains(&m) { return 10; }
    const BASE: [&str; 14] = ["mov", "add", "sub", "cmp", "test", "and", "or", "xor", "imul", "inc", "dec", "neg", "not", "adc"];
    for (sfx, w) in [('q', 8), ('l', 4), ('w', 2), ('b', 1)] {
        if let Some(b) = m.strip_suffix(sfx) { if BASE.contains(&b) { return w; } }
    }
    16
}

fn regs_named(l: &str, set: &mut HashSet<&'static str>) {
    let b = l.as_bytes();
    let mut i = 0;
    while i < b.len() {
        if b[i] == b'%' {
            let s = i + 1;
            let mut e = s;
            while e < b.len() && b[e].is_ascii_alphanumeric() { e += 1; }
            if let Some((c, _)) = canon(&l[s..e]) { set.insert(c); }
            i = e;
        } else { i += 1; }
    }
}

fn symbols(l: &str) -> impl Iterator<Item = &str> {
    l.split(|c: char| !(c.is_ascii_alphanumeric() || c == '_' || c == '.' || c == '$')).filter(|t| t.starts_with(".L"))
}

fn head_end(head: &str) -> Option<String> {
    let name = head.strip_suffix(':')?;
    if let Some(r) = name.strip_prefix(".Lforc_") { return Some(format!(".Lfore_{}:", r)); }
    if let Some(r) = name.strip_prefix(".Lwhile_") { return Some(format!(".Lendw_{}:", r)); }
    None
}

fn func_range(lines: &[String], at: usize) -> (usize, usize) {
    let global = |l: &String| is_label(l) && !l.starts_with(".L");
    let s = (0..=at).rev().find(|&k| global(&lines[k])).unwrap_or(0);
    let e = (at + 1..lines.len()).find(|&k| global(&lines[k])).unwrap_or(lines.len());
    (s, e)
}

fn slot_of(op: &str) -> Option<i64> {
    let (d, base, idx) = mem(op)?;
    if base != "rbp" || idx { return None; }
    d.parse::<i64>().ok()
}

// One loop region [h, e): returns the replacement lines, or None.
fn promote(lines: &[String], h: usize, e: usize, outside_refs: &HashSet<String>, uid: usize) -> Option<Vec<String>> {
    let mut internal: HashSet<&str> = HashSet::new();
    for l in &lines[h..e] { if is_label(l) { internal.insert(l.trim_end_matches(':')); } }
    for lab in &internal {
        if !lab.starts_with(".L") || outside_refs.contains(*lab) { return None; }
    }
    let mut named: HashSet<&'static str> = HashSet::new();
    // (offset, plain form?, width) of every rbp access
    let mut acc: Vec<(i64, bool, i64)> = Vec::new();
    let mut uses: HashMap<i64, usize> = HashMap::new();
    let mut written: HashSet<i64> = HashSet::new();
    let mut read: HashSet<i64> = HashSet::new();
    for l in &lines[h..e] {
        if l.trim().is_empty() || is_label(l) { continue; }
        let i = parse(l)?;
        let m = i.m.as_str();
        if m.starts_with("call") || m.starts_with("ret") || m.starts_with("rep") || m == "syscall" || m == "int" || m == "leave" || m == "enter" { return None; }
        if i.ops.iter().any(|o| o.starts_with('*')) { return None; }
        if i.ops.is_empty() && ["movs", "stos", "lods", "scas", "cmps"].iter().any(|p| m.starts_with(p)) { return None; }
        if m.starts_with('j') {
            if i.ops.len() != 1 || i.ops[0].contains('(') || i.ops[0].contains('%') { return None; }
            continue;
        }
        regs_named(l, &mut named);
        if m == "lea" { continue; }
        for (k, o) in i.ops.iter().enumerate() {
            if let Some((_, base, idx)) = mem(o) {
                if base == "rsp" || base == "rip" || base.is_empty() { continue; }
                if base != "rbp" || idx { return None; }
                let off = slot_of(o)?;
                let plain = plain_form(&i, k);
                acc.push((off, plain, if plain { 8 } else { width(&i) }));
                if plain {
                    *uses.entry(off).or_insert(0) += 1;
                    if writes(&i, k) { written.insert(off); }
                    if !pure_write(&i, k) { read.insert(off); }
                }
            }
        }
    }
    let (fs, fe) = func_range(lines, h);
    let mut taken: HashSet<i64> = HashSet::new();
    for l in &lines[fs..fe] {
        if let Some(i) = parse(l) {
            if i.m == "lea" { if let Some(o) = i.ops.first().and_then(|o| slot_of(o)) { taken.insert(o); } }
        }
    }
    // candidate slot at address rbp+d, d = -N, bytes [d, d+8)
    let rank = |d: i64| match (read.contains(&d), written.contains(&d)) { (true, true) => 2, (true, false) => 1, _ => 0 };
    let mut cands: Vec<(i64, usize)> = uses.iter()
        .filter(|(&d, _)| d < 0 && d % 8 == 0 && !taken.contains(&d))
        .filter(|(&d, _)| acc.iter().all(|&(o, plain, w)| !(o < d + 8 && d < o + w) || (o == d && plain)))
        .map(|(&d, &n)| (d, n)).collect();
    cands.sort_by(|a, b| rank(b.0).cmp(&rank(a.0)).then(b.1.cmp(&a.1)).then(b.0.cmp(&a.0)));
    let free: Vec<&str> = POOL.iter().copied().filter(|r| !named.contains(r)).collect();
    let chosen: Vec<(i64, &str)> = cands.iter().zip(free.iter()).map(|(&(d, _), &r)| (d, r)).collect();
    if chosen.is_empty() { return None; }
    let map: HashMap<String, String> = chosen.iter().map(|&(d, r)| (format!("{}(%rbp)", d), format!("%{}", r))).collect();
    let stores: Vec<String> = chosen.iter().filter(|(d, _)| written.contains(d)).map(|&(d, r)| format!("    mov %{}, {}(%rbp)", r, d)).collect();

    let mut out: Vec<String> = Vec::new();
    for &(d, r) in &chosen { out.push(format!("    mov {}(%rbp), %{}", d, r)); }
    let end_label = lines[e].trim_end_matches(':').to_string();
    let mut stubs: Vec<(String, String)> = Vec::new();
    let stub_for = |t: &str, stubs: &mut Vec<(String, String)>| -> String {
        if stores.is_empty() { return t.to_string(); }
        if let Some((_, s)) = stubs.iter().find(|(x, _)| x == t) { return s.clone(); }
        let s = format!(".Llr{}_{}", uid, stubs.len());
        stubs.push((t.to_string(), s.clone()));
        s
    };
    let mut last_uncond = false;
    for l in &lines[h..e] {
        let i = match parse(l) {
            Some(i) => i,
            None => { if is_label(l) { last_uncond = false; } out.push(l.clone()); continue; }
        };
        if i.m.starts_with('j') {
            let t = i.ops[0].as_str();
            let nt = if internal.contains(t) { t.to_string() } else { stub_for(t, &mut stubs) };
            out.push(format!("    {} {}", i.m, nt));
            last_uncond = i.m == "jmp";
            continue;
        }
        last_uncond = false;
        if i.ops.iter().any(|o| map.contains_key(o)) {
            let b = base_mnemonic(&i.m);
            let ops: Vec<String> = i.ops.iter().map(|o| map.get(o).cloned().unwrap_or_else(|| o.clone())).collect();
            out.push(format!("    {} {}", b, ops.join(", ")));
        } else {
            out.push(l.clone());
        }
    }
    if !stores.is_empty() {
        let end_stub = stub_for(&end_label, &mut stubs);
        if !last_uncond { out.push(format!("    jmp {}", end_stub)); }
        // the stub for the end label goes last and falls through into it
        let mut order: Vec<(String, String)> = stubs.iter().filter(|(t, _)| *t != end_label).cloned().collect();
        order.push((end_label.clone(), end_stub));
        for (t, s) in order {
            out.push(format!("{}:", s));
            out.extend(stores.iter().cloned());
            if t != end_label { out.push(format!("    jmp {}", t)); }
        }
    }
    Some(out)
}

pub fn loopreg(asm: &str) -> String {
    let mut lines: Vec<String> = asm.split('\n').map(|s| s.to_string()).collect();
    let heads: Vec<String> = lines.iter().filter(|l| is_label(l) && head_end(l).is_some()).cloned().collect();
    let mut uid = 0;
    // innermost first: a later head never encloses an earlier one
    for head in heads.iter().rev() {
        let h = match lines.iter().position(|l| l == head) { Some(h) => h, None => continue };
        let end = head_end(head).unwrap();
        let e = match (h + 1..lines.len()).find(|&k| lines[k] == end) { Some(e) => e, None => continue };
        // .L symbols referenced from outside [h, e)
        let mut outside: HashSet<String> = HashSet::new();
        for (k, l) in lines.iter().enumerate() {
            if (h..e).contains(&k) || is_label(l) { continue; }
            for s in symbols(l) { outside.insert(s.to_string()); }
        }
        // internal labels used as data (not jump targets) inside the loop
        for l in &lines[h..e] {
            if is_label(l) { continue; }
            if let Some(i) = parse(l) { if i.m.starts_with('j') { continue; } }
            for s in symbols(l) { outside.insert(s.to_string()); }
        }
        if let Some(new) = promote(&lines, h, e, &outside, uid) {
            uid += 1;
            lines.splice(h..e, new);
        }
    }
    lines.join("\n")
}

#[cfg(test)]
mod tests {
    use super::*;

    const LOOP: &str = "f:
    mov %rax, -16(%rbp)
.Lforc_f_0:
    mov -16(%rbp), %rax
    cmp -56(%rbp), %rax
    jg .Lfore_f_0
    mov -32(%rbp), %rax
    add -16(%rbp), %rax
    jo hbc_static_overflow
    mov %rax, -32(%rbp)
    mov %rdx, -24(%rbp)
.Lforn_f_0:
    mov -16(%rbp), %rax
    add $1, %rax
    jo .Lfore_f_0
    mov %rax, -16(%rbp)
    movq $0, -8(%rbp)
    jmp .Lforc_f_0
.Lfore_f_0:
    ret
";

    #[test]
    fn counter_and_accumulator_in_registers() {
        let o = loopreg(LOOP);
        assert!(o.contains("    mov -16(%rbp), %r8\n    mov -32(%rbp), %r9\n    mov -56(%rbp), %r10\n    mov -8(%rbp), %rsi\n    mov -24(%rbp), %rdi\n.Lforc_f_0:"), "{}", o);
        assert!(o.contains("    add %r8, %rax\n"), "{}", o);
        assert!(o.contains("    cmp %r10, %rax\n    jg .Llr0_0\n"), "{}", o);
        assert!(o.contains("    jo .Llr0_1\n"), "{}", o);
        let st = "    mov %r8, -16(%rbp)\n    mov %r9, -32(%rbp)\n    mov %rsi, -8(%rbp)\n    mov %rdi, -24(%rbp)\n";
        assert!(o.contains(&format!(".Llr0_1:\n{}    jmp hbc_static_overflow\n", st)), "{}", o);
        assert!(o.contains(&format!(".Llr0_0:\n{}.Lfore_f_0:", st)), "{}", o);
        // read-only slot: no store back; immediates and tag stores become register moves
        assert!(!o.contains("%r10, -56(%rbp)") && o.contains("    mov $0, %rsi\n") && o.contains("    mov %rdx, %rdi\n"), "{}", o);
    }

    #[test]
    fn call_in_body_is_left_alone() {
        let s = LOOP.replace("    mov %rdx, -24(%rbp)\n", "    call hbc_x\n");
        assert_eq!(loopreg(&s), s);
    }

    #[test]
    fn pointer_access_is_left_alone() {
        let s = LOOP.replace("    mov %rdx, -24(%rbp)\n", "    mov 8(%r11), %rcx\n");
        assert_eq!(loopreg(&s), s);
    }

    #[test]
    fn address_taken_or_partial_access_slot_not_promoted() {
        let s = LOOP.replace("    ret\n", "    lea -32(%rbp), %rax\n    ret\n").replace("    mov %rdx, -24(%rbp)\n", "    movl $0, -12(%rbp)\n");
        let o = loopreg(&s);
        assert!(o.contains("    mov -32(%rbp), %rax\n    add -16(%rbp), %rax\n"), "{}", o);
        assert!(o.contains("    mov -56(%rbp), %r8\n    mov -8(%rbp), %r9\n.Lforc_f_0:"), "{}", o);
    }

    #[test]
    fn register_named_in_body_not_used() {
        let s = LOOP.replace("    mov %rdx, -24(%rbp)\n", "    mov %r8, %rcx\n");
        let o = loopreg(&s);
        assert!(o.contains("    mov -16(%rbp), %r9\n"), "{}", o);
    }

    #[test]
    fn label_referenced_from_outside_is_left_alone() {
        let s = LOOP.replace("    ret\n", "    jmp .Lforn_f_0\n");
        assert_eq!(loopreg(&s), s);
    }
}
