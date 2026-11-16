// Dead-helper elimination over the final assembly text.
//
// hbc emits its runtime helpers as fixed blocks of hand-written assembly
// (HASH_HELPERS and friends), most of them unconditionally: a hello world
// carried ASCAN, ASORT, STRTRAN, PADC, the float cells and the math
// helpers. This pass keeps only the text reachable from the entry point.
//
// Model:
// - The text sections are split into blocks, one per non-local label
//   (`name:`; `.L...` labels, numeric labels and `.set` names belong to the
//   block they appear in). Lines before the first label of a text run, and
//   every line outside text sections, are always kept.
// - A block references every symbol named in its lines (call, jmp, lea,
//   .quad ...): an edge to the block that defines it.
// - A block whose last instruction is not ret/jmp/ud2/hlt can fall through
//   into the next block, so that next block is kept with it.
// - Roots: `_start`, every `.globl`, and every symbol named by a kept line
//   (data sections, text preamble).
// Anything unsure is kept; the pass only ever drops whole blocks.

use std::collections::HashMap;

fn is_ident_start(c: u8) -> bool { c.is_ascii_alphabetic() || c == b'_' || c == b'.' || c == b'$' }
fn is_ident(c: u8) -> bool { c.is_ascii_alphanumeric() || c == b'_' || c == b'.' || c == b'$' }

/// The line without its comment and without quoted strings.
fn code_part(line: &str) -> String {
    let b = line.as_bytes();
    let mut out = String::with_capacity(b.len());
    let mut i = 0;
    while i < b.len() {
        let c = b[i];
        if c == b'#' { break; }
        if c == b'"' {
            i += 1;
            while i < b.len() && b[i] != b'"' { if b[i] == b'\\' { i += 1; } i += 1; }
            i += 1;
            out.push(' ');
            continue;
        }
        out.push(c as char);
        i += 1;
    }
    out
}

fn idents(code: &str) -> Vec<&str> {
    let b = code.as_bytes();
    let mut v = Vec::new();
    let mut i = 0;
    while i < b.len() {
        if is_ident_start(b[i]) && (i == 0 || !(is_ident(b[i - 1]) || b[i - 1] == b'%')) {
            let s = i;
            while i < b.len() && is_ident(b[i]) { i += 1; }
            v.push(&code[s..i]);
        } else { i += 1; }
    }
    v
}

/// Leading `name:` of a code line (not `name::`), if any.
fn leading_label(code: &str) -> Option<(&str, &str)> {
    let t = code.trim_start();
    let b = t.as_bytes();
    if b.is_empty() || !(is_ident_start(b[0]) || b[0].is_ascii_digit()) { return None; }
    let mut i = 0;
    while i < b.len() && is_ident(b[i]) { i += 1; }
    if i < b.len() && b[i] == b':' && !(i + 1 < b.len() && b[i + 1] == b':') {
        return Some((&t[..i], &t[i + 1..]));
    }
    None
}

#[derive(Clone, Copy, PartialEq)]
enum Sec { Text, Other }

fn section_of(directive: &str, cur: Sec) -> Sec {
    let d = directive.trim();
    let word = d.split(|c: char| c.is_whitespace() || c == ',').next().unwrap_or("");
    match word {
        ".text" => Sec::Text,
        ".data" | ".bss" | ".rodata" | ".rdata" => Sec::Other,
        ".section" => {
            let name = d[8..].trim().split(|c: char| c.is_whitespace() || c == ',').next().unwrap_or("");
            if name.starts_with(".text") { Sec::Text } else { Sec::Other }
        }
        _ => cur,
    }
}

fn is_section_directive(code: &str) -> bool {
    let t = code.trim_start();
    let w = t.split(|c: char| c.is_whitespace() || c == ',').next().unwrap_or("");
    matches!(w, ".text" | ".data" | ".bss" | ".rodata" | ".rdata" | ".section")
}

pub fn prune(asm: &str) -> String {
    let lines: Vec<&str> = asm.split_inclusive('\n').collect();
    // owner[i] = Some(block) for text lines inside a block, None = always kept.
    let mut owner: Vec<Option<usize>> = vec![None; lines.len()];
    let mut block_names: Vec<String> = Vec::new();
    let mut defs: HashMap<String, usize> = HashMap::new();
    let mut last_insn: Vec<String> = Vec::new();
    let mut sec = Sec::Text;
    let mut cur: Option<usize> = None;
    let mut codes: Vec<String> = Vec::with_capacity(lines.len());
    for (i, line) in lines.iter().enumerate() {
        let code = code_part(line);
        if is_section_directive(&code) {
            sec = section_of(&code, sec);
            codes.push(code);
            continue; // section switches are always kept
        }
        let mut rest: &str = &code;
        if sec == Sec::Text {
            if let Some((name, after)) = leading_label(&code) {
                let local = name.starts_with('.') || name.as_bytes()[0].is_ascii_digit();
                if !local {
                    block_names.push(name.to_string());
                    last_insn.push(String::new());
                    cur = Some(block_names.len() - 1);
                }
                if let Some(b) = cur { defs.entry(name.to_string()).or_insert(b); }
                rest = after;
            }
            let t = rest.trim();
            if let Some(b) = cur {
                owner[i] = Some(b);
                if t.starts_with(".set") || t.starts_with(".equ") {
                    if let Some(n) = idents(t).get(1) { defs.entry(n.to_string()).or_insert(b); }
                } else if !t.is_empty() && !t.starts_with('.') {
                    last_insn[b] = t.to_string();
                }
            }
        } else if let Some((name, _)) = leading_label(&code) {
            // Labels in data sections are never pruned.
            let _ = name;
        }
        codes.push(code);
    }
    let nb = block_names.len();
    if nb == 0 { return asm.to_string(); }
    // Edges.
    let mut edges: Vec<Vec<usize>> = vec![Vec::new(); nb];
    let mut roots: Vec<usize> = Vec::new();
    let mut root_all = false;
    for (i, code) in codes.iter().enumerate() {
        let t = code.trim_start();
        let globl = t.starts_with(".globl") || t.starts_with(".global");
        for id in idents(code) {
            if let Some(&d) = defs.get(id) {
                match owner[i] {
                    Some(b) if !globl => { if b != d { edges[b].push(d); } }
                    _ => roots.push(d),
                }
            }
        }
        // A kept line naming a symbol through something we cannot parse
        // (e.g. `.rept` arithmetic) is still covered: every ident counts.
        if t.starts_with(".include") || t.starts_with(".incbin") { root_all = true; }
    }
    if root_all { return asm.to_string(); }
    for b in 0..nb {
        let li = last_insn[b].to_ascii_lowercase();
        let m = li.split_whitespace().next().unwrap_or("");
        let terminal = matches!(m, "ret" | "retq" | "jmp" | "jmpq" | "ud2" | "hlt");
        if !terminal && b + 1 < nb { edges[b].push(b + 1); }
    }
    if let Some(&s) = defs.get("_start") { roots.push(s); } else { return asm.to_string(); }
    let mut live = vec![false; nb];
    let mut stack = roots;
    while let Some(b) = stack.pop() {
        if live[b] { continue; }
        live[b] = true;
        stack.extend(edges[b].iter().copied());
    }
    let mut out = String::with_capacity(asm.len());
    for (i, line) in lines.iter().enumerate() {
        match owner[i] { Some(b) if !live[b] => {} _ => out.push_str(line) }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::prune;

    #[test]
    fn drops_unreferenced_helper() {
        let s = "    .text\n    .globl _start\n_start:\n    call used\n    ret\nused:\n    ret\nunused:\n    call used\n    ret\n";
        let p = prune(s);
        assert!(p.contains("used:\n"));
        assert!(!p.contains("unused:"));
    }

    #[test]
    fn keeps_fallthrough_and_data_refs() {
        let s = "    .text\n_start:\n    call a\n    ret\na:\n    mov $1, %eax\nb:\n    ret\nc:\n    ret\nd:\n    ret\n    .data\ntab: .quad c\n";
        let p = prune(s);
        assert!(p.contains("b:\n"), "fallthrough from a into b");
        assert!(p.contains("c:\n"), "referenced from data");
        assert!(!p.contains("d:\n"));
        assert!(p.contains("tab: .quad c"));
    }

    #[test]
    fn local_label_reference_keeps_owner() {
        let s = "    .text\n_start:\n    jmp .Lx_tail\nx:\n    nop\n.Lx_tail:\n    ret\ny:\n    ret\n";
        let p = prune(s);
        assert!(p.contains("x:\n") && p.contains(".Lx_tail:"));
        assert!(!p.contains("y:\n"));
    }

    #[test]
    fn strings_and_comments_are_not_references() {
        let s = "    .text\n_start:\n    ret # call z\n    .section .rdata,\"r\"\nmsg: .ascii \"z\"\n    .text\nz:\n    ret\n";
        let p = prune(s);
        assert!(!p.contains("z:\n"));
    }
}
