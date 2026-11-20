// Peephole pass over the final assembly text (phase 1 of the codegen
// tightening; `--no-peephole` turns it off).
//
// hbc's expression code generator is a stack machine: an operand is spilled
// through the machine stack while the other is computed, and statement
// lowering leaves jumps to the next label and double jumps. This pass
// rewrites a few exact, local patterns. Each rule is semantics-preserving on
// its own:
//
// R1  sub $16,%rsp / mov %rax,(%rsp) / M* / mov (%rsp),%rcx / add $16,%rsp
//     and push %rax / M* / pop %rcx  ->  mov %rax,%rcx / M*
//     M are loads of an immediate or an rbp slot into rax/rdx/eax/edx (or
//     xor of edx/eax): they do not read rsp, rcx or the spilled cell. The
//     dropped add/sub only change flags nobody reads (a consumer between
//     them would already have seen them clobbered).
// R2  a 16-byte rax:rdx store immediately reloaded from the same cell and
//     released: dropped.
// R3  a jmp right after an unconditional jmp/ret (no label between): dead.
// R4  jmp .Lx followed only by labels, one of them .Lx: dropped.
// R5  jCC .La / jmp .Lb / (labels incl. .La)  ->  jNCC .Lb / labels.
// R6  add $16,%rsp / sub $16,%rsp: the slot is released and re-reserved at
//     the same address; both dropped (sub writes no memory, so the cell
//     holds the same bytes either way, and it is never below rsp now).
//
// Labels are never removed and no rule crosses a label, so every jump
// target keeps its meaning. Lines with comments never match.

fn is_label(l: &str) -> bool {
    !l.starts_with(|c: char| c.is_whitespace()) && l.ends_with(':') && !l.contains(char::is_whitespace) && l.len() > 1
}

fn ins(l: &str) -> Option<&str> {
    if !l.starts_with(|c: char| c.is_whitespace()) { return None; }
    let t = l.trim();
    if t.is_empty() || t.starts_with('.') || t.contains('#') { return None; }
    Some(t)
}

fn is_imm(s: &str) -> bool {
    let s = match s.strip_prefix('$') { Some(s) => s, None => return false };
    let s = s.strip_prefix('-').unwrap_or(s);
    !s.is_empty() && s.bytes().all(|b| b.is_ascii_digit())
}

fn is_rbp_slot(s: &str) -> bool {
    match s.strip_suffix("(%rbp)") {
        Some(o) => { let o = o.strip_prefix('-').unwrap_or(o); o.bytes().all(|b| b.is_ascii_digit()) }
        None => false,
    }
}

// A middle line of R1: writes only rax/rdx (or their low halves) and reads
// nothing but an immediate or an rbp slot.
fn safe_mid(t: &str) -> bool {
    if t == "xor %edx, %edx" || t == "xor %eax, %eax" { return true; }
    let rest = match t.strip_prefix("mov ") { Some(r) => r, None => return false };
    let (src, dst) = match rest.split_once(", ") { Some(p) => p, None => return false };
    matches!(dst, "%rax" | "%rdx" | "%eax" | "%edx") && (is_imm(src) || is_rbp_slot(src))
}

fn invert(cc: &str) -> Option<&'static str> {
    Some(match cc {
        "e" => "ne", "ne" => "e", "z" => "nz", "nz" => "z",
        "l" => "ge", "ge" => "l", "g" => "le", "le" => "g",
        "b" => "ae", "ae" => "b", "a" => "be", "be" => "a",
        _ => return None,
    })
}

fn jump_target<'a>(t: &'a str, m: &str) -> Option<&'a str> {
    let r = t.strip_prefix(m)?.strip_prefix(' ')?;
    if r.starts_with(".L") && !r.contains(|c: char| c.is_whitespace() || c == ',') { Some(r) } else { None }
}

// Labels at j.. (consecutive); true if `target:` is among them.
fn label_run_has(lines: &[String], mut j: usize, target: &str) -> bool {
    while j < lines.len() && is_label(&lines[j]) {
        if lines[j].len() == target.len() + 1 && lines[j].starts_with(target) { return true; }
        j += 1;
    }
    false
}

fn pass(lines: Vec<String>) -> (Vec<String>, bool) {
    let mut out: Vec<String> = Vec::with_capacity(lines.len());
    let mut changed = false;
    let n = lines.len();
    let mut i = 0;
    let t = |k: usize| -> Option<&str> { if k < n { ins(&lines[k]) } else { None } };
    while i < n {
        // R2
        if t(i) == Some("sub $16, %rsp") && t(i + 1) == Some("mov %rax, (%rsp)") && t(i + 2) == Some("mov %rdx, 8(%rsp)")
            && t(i + 3) == Some("mov (%rsp), %rax") && t(i + 4) == Some("mov 8(%rsp), %rdx") && t(i + 5) == Some("add $16, %rsp") {
            i += 6; changed = true; continue;
        }
        // R6
        if t(i) == Some("add $16, %rsp") && t(i + 1) == Some("sub $16, %rsp") {
            i += 2; changed = true; continue;
        }
        // R1
        let (open, body) = if t(i) == Some("sub $16, %rsp") && t(i + 1) == Some("mov %rax, (%rsp)") { (true, i + 2) }
            else if t(i) == Some("push %rax") { (false, i + 1) } else { (false, usize::MAX) };
        if body != usize::MAX {
            let mut j = body;
            while t(j).map_or(false, safe_mid) { j += 1; }
            let closes = if open { t(j) == Some("mov (%rsp), %rcx") && t(j + 1) == Some("add $16, %rsp") } else { t(j) == Some("pop %rcx") };
            if closes {
                out.push("    mov %rax, %rcx".to_string());
                for k in body..j { out.push(lines[k].clone()); }
                i = j + if open { 2 } else { 1 };
                changed = true; continue;
            }
        }
        if let Some(cur) = t(i) {
            // R3
            if (cur.starts_with("jmp ") || cur == "ret") && t(i + 1).map_or(false, |x| x.starts_with("jmp ")) {
                out.push(lines[i].clone()); i += 2; changed = true; continue;
            }
            // R4
            if let Some(l) = jump_target(cur, "jmp") {
                if label_run_has(&lines, i + 1, l) { i += 1; changed = true; continue; }
            }
            // R5
            if let Some(m) = cur.split(' ').next() {
                if let Some(cc) = m.strip_prefix('j').and_then(invert) {
                    if let (Some(a), Some(b)) = (jump_target(cur, m), t(i + 1).and_then(|x| jump_target(x, "jmp"))) {
                        if label_run_has(&lines, i + 2, a) {
                            out.push(format!("    j{} {}", cc, b));
                            i += 2; changed = true; continue;
                        }
                    }
                }
            }
        }
        out.push(lines[i].clone());
        i += 1;
    }
    (out, changed)
}

pub fn peephole(asm: &str) -> String {
    let trailing_nl = asm.ends_with('\n');
    let mut lines: Vec<String> = asm.lines().map(|s| s.to_string()).collect();
    for _ in 0..8 {
        let (l, ch) = pass(lines);
        lines = l;
        if !ch { break; }
    }
    let mut s = lines.join("\n");
    if trailing_nl { s.push('\n'); }
    s
}

#[cfg(test)]
mod tests {
    use super::peephole;
    #[test]
    fn spill_through_stack_becomes_rcx_move() {
        let a = "    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov $1, %rax\n    mov $1, %edx\n    mov (%rsp), %rcx\n    add $16, %rsp\n    sub %rax, %rcx\n";
        assert_eq!(peephole(a), "    mov %rax, %rcx\n    mov $1, %rax\n    mov $1, %edx\n    sub %rax, %rcx\n");
        let b = "    push %rax\n    mov $2, %rax\n    mov $1, %edx\n    pop %rcx\n";
        assert_eq!(peephole(b), "    mov %rax, %rcx\n    mov $2, %rax\n    mov $1, %edx\n");
    }
    #[test]
    fn spill_with_unsafe_middle_is_kept() {
        let a = "    push %rax\n    call f\n    pop %rcx\n";
        assert_eq!(peephole(a), a);
        let b = "    push %rax\n    mov 8(%rsp), %rax\n    pop %rcx\n";
        assert_eq!(peephole(b), b);
    }
    #[test]
    fn jumps() {
        let a = "    jl .Lt\n    jmp .Le\n.Lt:\n    ret\n    jmp .Lx\n.Le:\n    jmp .Ln\n.Lq:\n.Ln:\n";
        assert_eq!(peephole(a), "    jge .Le\n.Lt:\n    ret\n.Le:\n.Lq:\n.Ln:\n");
    }
    #[test]
    fn release_reserve_pair_dropped() {
        let a = "    call f\n    add $16, %rsp\n    sub $16, %rsp\n    mov %rax, (%rsp)\n";
        assert_eq!(peephole(a), "    call f\n    mov %rax, (%rsp)\n");
    }
    #[test]
    fn roundtrip_dropped() {
        let a = "    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    leave\n";
        assert_eq!(peephole(a), "    leave\n");
    }
}
