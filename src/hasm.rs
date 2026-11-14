// hasm.rs — mini-ensamblador del subconjunto x86-64 que emite hbc + escritor ELF64.
// Objetivo: salida byte-idéntica a `as -o fixed.o x.s && ld -s -o out fixed.o`
// (binutils 2.45, layout medido empíricamente). Sin dependencias externas.

use std::cell::Cell;
use std::collections::HashMap;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Sec { Text, Rodata, Data, Bss, Note }

#[derive(Clone, Debug)]
enum Term { Num(i64), Sym(String), Fwd(u32, u64), Back(u32, u64) }

#[derive(Clone, Debug)]
struct Expr(Vec<(bool, Term)>); // (restar?, término)

#[derive(Clone, Debug)]
enum Op {
    Reg(u8, u8, bool), // código, ancho bits (8/16/32/64), high-byte (ah..bh)
    Xmm(u8),
    St(u8),
    Imm(Expr),
    Mem { disp: Option<Expr>, base: Option<u8>, index: Option<(u8, u8)>, riplab: Option<String>, fs: bool },
    Star(Box<Op>),
}

#[derive(Clone, Debug)]
enum TItem {
    Ins { mnem: String, ops: Vec<Op>, lock: bool },
    P2 { bits: u32, maxskip: Option<u32> },
    Raw(DItem),
}

#[derive(Clone, Debug)]
enum DItem {
    Bytes(Vec<u8>),
    Align(u64),
    Patch4(Expr),
    Patch8(Expr),
}

#[derive(Clone, Copy, Debug)]
struct Loc { sec: Sec, idx: usize }

fn is_name_char(c: char) -> bool { c.is_ascii_alphanumeric() || c == '_' || c == '.' || c == '$' }

fn parse_int(s: &str) -> Result<i64, String> {
    let t = s.trim();
    let (neg, t) = if let Some(r) = t.strip_prefix('-') { (true, r) } else { (false, t) };
    let v: u64 = if let Some(h) = t.strip_prefix("0x").or_else(|| t.strip_prefix("0X")) {
        u64::from_str_radix(h, 16).map_err(|e| e.to_string())?
    } else {
        match t.parse::<i64>() { Ok(v) => v as u64, Err(_) => t.parse::<u64>().map_err(|e| e.to_string())? }
    };
    Ok(if neg { (v as i64).wrapping_neg() } else { v as i64 })
}

fn split_operands(s: &str) -> Vec<String> {
    let mut out = Vec::new();
    let mut depth = 0i32;
    let mut inq = false;
    let mut cur = String::new();
    for c in s.chars() {
        match c {
            '"' => { inq = !inq; cur.push(c); }
            '(' if !inq => { depth += 1; cur.push(c); }
            ')' if !inq => { depth -= 1; cur.push(c); }
            ',' if !inq && depth == 0 => { out.push(cur.trim().to_string()); cur.clear(); }
            _ => cur.push(c),
        }
    }
    if !cur.trim().is_empty() { out.push(cur.trim().to_string()); }
    out
}

fn parse_reg(s: &str) -> Option<(u8, u8, bool)> {
    let t = s.strip_prefix('%')?;
    const R64: [&str; 16] = ["rax","rcx","rdx","rbx","rsp","rbp","rsi","rdi","r8","r9","r10","r11","r12","r13","r14","r15"];
    const R32: [&str; 16] = ["eax","ecx","edx","ebx","esp","ebp","esi","edi","r8d","r9d","r10d","r11d","r12d","r13d","r14d","r15d"];
    const R16: [&str; 16] = ["ax","cx","dx","bx","sp","bp","si","di","r8w","r9w","r10w","r11w","r12w","r13w","r14w","r15w"];
    const R8: [&str; 16] = ["al","cl","dl","bl","spl","bpl","sil","dil","r8b","r9b","r10b","r11b","r12b","r13b","r14b","r15b"];
    const HI: [&str; 4] = ["ah","ch","dh","bh"];
    for (i, n) in R64.iter().enumerate() { if t == *n { return Some((i as u8, 64, false)); } }
    for (i, n) in R32.iter().enumerate() { if t == *n { return Some((i as u8, 32, false)); } }
    for (i, n) in R16.iter().enumerate() { if t == *n { return Some((i as u8, 16, false)); } }
    for (i, n) in R8.iter().enumerate() { if t == *n { return Some((i as u8, 8, false)); } }
    for (i, n) in HI.iter().enumerate() { if t == *n { return Some((i as u8 + 4, 8, true)); } }
    None
}

fn parse_xmm(s: &str) -> Option<u8> {
    s.strip_prefix("%xmm")?.parse::<u8>().ok().filter(|v| *v < 16)
}

struct Parser {
    consts: HashMap<String, i64>,
    labels: HashMap<String, Loc>,
    numlabels: HashMap<u32, Vec<(u64, Loc)>>,
    seq: Cell<u64>,
}

impl Parser {
    fn next_seq(&self) -> u64 { let s = self.seq.get() + 1; self.seq.set(s); s }

    fn parse_expr(&self, s: &str) -> Result<Expr, String> {
        let t0 = s.trim();
        // quitar paréntesis envolventes
        let mut t = t0;
        while t.starts_with('(') && t.ends_with(')') {
            let mut d = 0i32; let mut envolvente = true;
            for (i, c) in t.char_indices() {
                match c { '(' => d += 1, ')' => { d -= 1; if d == 0 && i != t.len() - 1 { envolvente = false; break; } } _ => {} }
            }
            if envolvente { t = &t[1..t.len() - 1]; } else { break; }
        }
        let mut terms: Vec<(bool, Term)> = Vec::new();
        let mut cur = String::new();
        let mut neg = false;
        let mut started = false;
        let mut push = |cur: &mut String, neg: bool, terms: &mut Vec<(bool, Term)>, seq: u64| -> Result<(), String> {
            let p = cur.trim().to_string();
            if p.is_empty() { return Err("expresión vacía".into()); }
            let bytes = p.as_bytes();
            let term = if bytes.len() >= 2 && bytes[..bytes.len()-1].iter().all(|b| b.is_ascii_digit())
                && (p.ends_with('f') || p.ends_with('b')) {
                let n = p[..p.len()-1].parse::<u32>().map_err(|e| e.to_string())?;
                if p.ends_with('f') { Term::Fwd(n, seq) } else { Term::Back(n, seq) }
            } else if p.chars().all(is_name_char) && !p.chars().next().unwrap().is_ascii_digit() {
                Term::Sym(p)
            } else {
                match parse_int(&p) { Ok(v) => Term::Num(v), Err(e) => return Err(format!("término {:?}: {}", cur, e)) }
            };
            terms.push((neg, term));
            cur.clear();
            Ok(())
        };
        for c in t.chars() {
            match c {
                '+' => { let s = self.next_seq(); push(&mut cur, neg, &mut terms, s)?; neg = false; started = true; }
                '-' => {
                    if !started && cur.trim().is_empty() { cur.push(c); }
                    else { let s = self.next_seq(); push(&mut cur, neg, &mut terms, s)?; neg = true; started = true; }
                }
                _ => cur.push(c),
            }
        }
        let s = self.next_seq();
        push(&mut cur, neg, &mut terms, s)?;
        Ok(Expr(terms))
    }

    fn parse_op(&self, s: &str) -> Result<Op, String> {
        let t = s.trim();
        if let Some(r) = t.strip_prefix('*') { return Ok(Op::Star(Box::new(self.parse_op(r)?))); }
        if t.starts_with("%fs:") { return self.parse_mem_seg(&t[4..], 1); }
        if t.starts_with("%gs:") { return self.parse_mem_seg(&t[4..], 2); }
        if let Some(r) = t.strip_prefix('$') { return Ok(Op::Imm(self.parse_expr(r)?)); }
        if let Some((c, w, h)) = parse_reg(t) { return Ok(Op::Reg(c, w, h)); }
        if let Some(x) = parse_xmm(t) { return Ok(Op::Xmm(x)); }
        if t == "%st" || t == "%st(0)" { return Ok(Op::St(0)); }
        if let Some(b) = t.strip_prefix("%st(").and_then(|r| r.strip_suffix(')')) {
            return Ok(Op::St(b.parse::<u8>().map_err(|e| e.to_string())?));
        }
        if t.ends_with(')') && t.contains('(') {
            return self.parse_mem_seg(t, 0);
        }
        if !t.is_empty() && t.chars().all(is_name_char) && !t.chars().next().unwrap().is_ascii_digit() {
            return Ok(Op::Imm(Expr(vec![(false, Term::Sym(t.to_string()))])));
        }
        if t.len() >= 2 && t[..t.len()-1].chars().all(|c| c.is_ascii_digit()) && (t.ends_with('f') || t.ends_with('b')) {
            let n = t[..t.len()-1].parse::<u32>().map_err(|e| e.to_string())?;
            let term = if t.ends_with('f') { Term::Fwd(n, self.next_seq()) } else { Term::Back(n, self.next_seq()) };
            return Ok(Op::Imm(Expr(vec![(false, term)])));
        }
        Err(format!("operando no reconocido: {:?}", s))
    }

    // memoria con o sin prefijo de segmento (%fs: ya extraído; gs no soportado aún)
    fn parse_mem_seg(&self, t: &str, seg: u8) -> Result<Op, String> {
        if seg == 2 { return Err("%gs: no soportado".into()); }
        let fs = seg == 1;
        if t.ends_with(')') && t.contains('(') {
            let lp = t.rfind('(').unwrap();
            let inner = &t[lp + 1..t.len() - 1];
            let disp_s = t[..lp].trim();
            let parts: Vec<&str> = inner.split(',').map(|x| x.trim()).collect();
            if parts.len() == 1 && parts[0] == "%rip" {
                return Ok(Op::Mem { disp: None, base: None, index: None, riplab: Some(disp_s.to_string()), fs });
            }
            let base = if parts[0].is_empty() { None } else {
                let (c, w, _) = parse_reg(parts[0]).ok_or_else(|| format!("base no reg64: {}", parts[0]))?;
                if w != 64 { return Err("base no 64".into()); }
                Some(c)
            };
            let index = if parts.len() >= 2 && !parts[1].is_empty() {
                let (c, w, _) = parse_reg(parts[1]).ok_or_else(|| format!("índice no reg64: {}", parts[1]))?;
                if w != 64 { return Err("índice no 64".into()); }
                let scale = if parts.len() >= 3 && !parts[2].is_empty() {
                    match parts[2] { "1" => 0u8, "2" => 1, "4" => 2, "8" => 3, x => return Err(format!("escala mala: {}", x)) }
                } else { 0 };
                Some((c, scale))
            } else { None };
            let disp = if disp_s.is_empty() { None } else { Some(self.parse_expr(disp_s)?) };
            return Ok(Op::Mem { disp, base, index, riplab: None, fs });
        }
        // absoluto: %fs:N
        let disp = Some(self.parse_expr(t)?);
        Ok(Op::Mem { disp, base: None, index: None, riplab: None, fs })
    }
}

impl Expr {
    // ¿es un literal entero tal cual se escribió (no símbolo .set ni expresión)?
    fn literal(&self) -> Option<i64> {
        if self.0.len() == 1 {
            if let (neg, Term::Num(v)) = &self.0[0] { return Some(if *neg { -*v } else { *v }); }
        }
        None
    }
}

fn ditems_size(items: &[DItem]) -> u64 {
    let mut off = 0u64;
    for it in items {
        match it {
            DItem::Bytes(b) => off += b.len() as u64,
            DItem::Align(n) => off = (off + n - 1) & !(n - 1),
            DItem::Patch4(_) => off += 4,
            DItem::Patch8(_) => off += 8,
        }
    }
    off
}

fn strip_comment(line: &str) -> String {
    let mut inq = false;
    let mut out = String::new();
    for c in line.chars() {
        match c { '"' => { inq = !inq; out.push(c); } '#' if !inq => break, _ => out.push(c) }
    }
    out
}

fn expand_rept(src: &str) -> Result<String, String> {
    let mut out = String::with_capacity(src.len());
    let mut iter = src.lines().peekable();
    while let Some(line) = iter.next() {
        let t = strip_comment(line).trim().to_string();
        if let Some(ns) = t.strip_prefix(".rept") {
            let n: u32 = ns.trim().parse().map_err(|_| format!(".rept malo: {}", t))?;
            let mut body = String::new();
            loop {
                let l = iter.next().ok_or(".rept sin .endr")?;
                if strip_comment(l).trim() == ".endr" { break; }
                body.push_str(l); body.push('\n');
            }
            for _ in 0..n { out.push_str(&body); }
        } else { out.push_str(line); out.push('\n'); }
    }
    Ok(out)
}

struct Asm {
    p: Parser,
    text: Vec<TItem>,
    rodata: Vec<DItem>,
    data: Vec<DItem>,
    bss: Vec<DItem>,
    note: Vec<DItem>,
    has_gnu_stack: bool,
    cur: Sec,
    secstack: Vec<Sec>,
    text_align: u32,
    rod_align: u32,
    dat_align: u32,
    bss_align: u32,
}

impl Asm {
    fn push_data(&mut self, it: DItem) {
        if self.cur == Sec::Text { self.text.push(TItem::Raw(it)); }
        else { self.cur_items().push(it); }
    }

    fn cur_items(&mut self) -> &mut Vec<DItem> {
        match self.cur {
            Sec::Rodata => &mut self.rodata,
            Sec::Data => &mut self.data,
            Sec::Bss => &mut self.bss,
            Sec::Note => &mut self.note,
            Sec::Text => unreachable!(),
        }
    }
    fn cur_idx(&self) -> Loc {
        Loc { sec: self.cur, idx: match self.cur {
            Sec::Text => self.text.len(), Sec::Rodata => self.rodata.len(),
            Sec::Data => self.data.len(), Sec::Bss => self.bss.len(), Sec::Note => self.note.len(),
        } }
    }
    fn bump_align(&mut self, n: u32) {
        match self.cur {
            Sec::Text => self.text_align = self.text_align.max(n),
            Sec::Rodata => self.rod_align = self.rod_align.max(n),
            Sec::Data => self.dat_align = self.dat_align.max(n),
            Sec::Bss => self.bss_align = self.bss_align.max(n),
            Sec::Note => {}
        }
    }

    fn parse_line(&mut self, raw: &str) -> Result<(), String> {
        let mut line = strip_comment(raw).trim().to_string();
        if line.is_empty() { return Ok(()); }
        loop {
            let b = line.as_bytes();
            let mut i = 0;
            while i < b.len() && is_name_char(b[i] as char) { i += 1; }
            if i > 0 && i < b.len() && b[i] == b':' {
                let name = line[..i].to_string();
                let loc = self.cur_idx();
                if name.chars().all(|c| c.is_ascii_digit()) {
                    let n: u32 = name.parse().map_err(|_| "numlabel")?;
                    let s = self.p.next_seq();
                    self.p.numlabels.entry(n).or_default().push((s, loc));
                } else {
                    self.p.labels.insert(name, loc);
                }
                line = line[i + 1..].trim().to_string();
                if line.is_empty() { return Ok(()); }
                continue;
            }
            break;
        }
        let (mnem, rest) = match line.find(char::is_whitespace) {
            Some(p) => (line[..p].to_string(), line[p..].trim().to_string()),
            None => (line.clone(), String::new()),
        };
        if mnem.starts_with('.') { return self.directive(&mnem, &rest); }
        let (mnem, rest, lock) = if mnem == "lock" {
            let (m2, r2) = match rest.find(char::is_whitespace) {
                Some(p) => (rest[..p].to_string(), rest[p..].trim().to_string()),
                None => (rest.clone(), String::new()),
            };
            (m2, r2, true)
        } else { (mnem, rest, false) };
        let mnem = if mnem == "rep" {
            let m2 = rest.split_whitespace().next().unwrap_or("").to_string();
            let r2 = rest[m2.len()..].trim().to_string();
            format!("rep {}", m2).to_string();
            let ops = if r2.is_empty() { Vec::new() } else {
                split_operands(&r2).iter().map(|o| self.p.parse_op(o)).collect::<Result<Vec<_>, _>>()?
            };
            self.text.push(TItem::Ins { mnem: format!("rep {}", m2), ops, lock: false });
            return Ok(());
        } else { mnem };
        let ops = if rest.is_empty() { Vec::new() } else {
            split_operands(&rest).iter().map(|o| self.p.parse_op(o)).collect::<Result<Vec<_>, _>>()?
        };
        self.text.push(TItem::Ins { mnem, ops, lock });
        Ok(())
    }

    fn directive(&mut self, d: &str, rest: &str) -> Result<(), String> {
        match d {
            ".text" => self.cur = Sec::Text,
            ".data" => self.cur = Sec::Data,
            ".bss" => self.cur = Sec::Bss,
            ".section" => {
                let name = rest.split(|c: char| c == ',' || c.is_whitespace()).next().unwrap_or("");
                match name {
                    ".rodata" | ".rdata" => self.cur = Sec::Rodata,
                    ".note.gnu.property" => self.cur = Sec::Note,
                    ".note.GNU-stack" => self.has_gnu_stack = true,
                    _ => return Err(format!(".section desconocida: {}", name)),
                }
            }
            ".pushsection" => {
                self.secstack.push(self.cur);
                let name = rest.split(|c: char| c == ',' || c.is_whitespace()).next().unwrap_or("");
                match name { ".rodata" => self.cur = Sec::Rodata, _ => return Err(format!(".pushsection: {}", name)) }
            }
            ".popsection" => self.cur = self.secstack.pop().ok_or(".popsection vacío")?,
            ".globl" | ".hidden" | ".type" | ".size" => {}
            ".set" => {
                let parts: Vec<&str> = rest.splitn(2, ',').collect();
                if parts.len() != 2 { return Err(".set malo".into()); }
                let v = parse_int(parts[1].trim())?;
                self.p.consts.insert(parts[0].trim().to_string(), v);
            }
            ".byte" => {
                let mut b = Vec::new();
                for v in &split_operands(rest) { b.push(parse_int(v)? as u8); }
                self.push_data(DItem::Bytes(b));
            }
            ".long" => {
                for v in split_operands(rest) {
                    if let Ok(n) = parse_int(&v) { self.push_data(DItem::Bytes((n as u32).to_le_bytes().to_vec())); }
                    else { let e = self.p.parse_expr(&v)?; self.push_data(DItem::Patch4(e)); }
                }
            }
            ".quad" => {
                for v in split_operands(rest) {
                    if let Ok(n) = parse_int(&v) { self.push_data(DItem::Bytes((n as u64).to_le_bytes().to_vec())); }
                    else { let e = self.p.parse_expr(&v)?; self.push_data(DItem::Patch8(e)); }
                }
            }
            ".double" => {
                for v in split_operands(rest) {
                    let f: f64 = v.parse().map_err(|_| format!(".double malo: {}", v))?;
                    self.push_data(DItem::Bytes(f.to_bits().to_le_bytes().to_vec()));
                }
            }
            ".ascii" | ".asciz" | ".string" => {
                let t = rest.trim();
                if !(t.starts_with('"') && t.ends_with('"')) { return Err(format!("{} sin comillas", d)); }
                let inner = &t[1..t.len() - 1];
                if inner.contains('\\') { return Err("escape en cadena no soportado".into()); }
                let mut b = inner.as_bytes().to_vec();
                if d != ".ascii" { b.push(0); }
                self.push_data(DItem::Bytes(b));
            }
            ".zero" | ".skip" | ".space" => {
                let n: u64 = rest.trim().parse().map_err(|_| ".zero malo")?;
                self.push_data(DItem::Bytes(vec![0u8; n as usize]));
            }
            ".align" | ".balign" => {
                let n: u32 = rest.trim().parse().map_err(|_| ".align malo")?;
                if !n.is_power_of_two() { return Err(".align no potencia de 2".into()); }
                if self.cur == Sec::Text {
                    self.bump_align(n);
                    self.text.push(TItem::P2 { bits: n.trailing_zeros(), maxskip: None });
                } else {
                    self.bump_align(n);
                    self.cur_items().push(DItem::Align(n as u64));
                }
            }
            ".p2align" => {
                let parts: Vec<&str> = rest.split(',').collect();
                let bits: u32 = parts[0].trim().parse().map_err(|_| ".p2align malo")?;
                let maxskip = if parts.len() >= 3 && !parts[2].trim().is_empty() {
                    Some(parts[2].trim().parse::<u32>().map_err(|_| ".p2align maxskip")?)
                } else { None };
                if self.cur == Sec::Text {
                    self.bump_align(1 << bits);
                    self.text.push(TItem::P2 { bits, maxskip });
                } else {
                    self.bump_align(1 << bits);
                    self.cur_items().push(DItem::Align(1u64 << bits));
                }
            }
            _ => return Err(format!("directiva desconocida: {}", d)),
        }
        Ok(())
    }
}

// ---------------------------------------------------------------- codificación

fn modrm(md: u8, reg: u8, rm: u8) -> u8 { (md << 6) | ((reg & 7) << 3) | (rm & 7) }

struct Enc<'a> {
    resolve: &'a dyn Fn(&Expr) -> Result<i64, String>,
}

impl<'a> Enc<'a> {
    fn rexw(&self, out: &mut Vec<u8>, w: bool, r: u8, x: u8, b: u8, force: bool) {
        let v = 0x40 | ((w as u8) << 3) | (((r >> 3) & 1) << 2) | (((x >> 3) & 1) << 1) | ((b >> 3) & 1);
        if v != 0x40 || force { out.push(v); }
    }
    fn eval(&self, e: &Expr) -> Result<i64, String> { (self.resolve)(e) }

    // Emite modrm+sib+disp para operando reg/mem. `rm` es Reg o Mem.
    // NO emite el REX: lo hace quien llama (necesita ir antes del opcode).
    // Devuelve (needs_rex_force) por registros spl/bpl/sil/dil/rXb.
    fn modrm_operand(&self, out: &mut Vec<u8>, regfield: u8, rm: &Op) -> Result<(), String> {
        match rm {
            Op::Reg(c, _, _) => { out.push(modrm(3, regfield, *c)); }
            Op::Mem { disp, base, index, riplab, .. } => {
                if riplab.is_some() {
                    out.push(modrm(0, regfield, 5));
                    out.extend_from_slice(&[0; 4]); // parcheado por quien llama con resolve
                    return Ok(());
                }
                let dv: Option<i64> = match disp { Some(e) => Some(self.eval(e)?), None => None };
                match (base, index) {
                    (Some(b), idx) => {
                        let (md, db): (u8, Vec<u8>) = match dv {
                            None => if b & 7 == 5 { (1, vec![0]) } else { (0, vec![]) },
                            Some(0) => if b & 7 == 5 { (1, vec![0]) } else { (0, vec![]) },
                            Some(v) if (-128..=127).contains(&v) => (1, vec![v as u8]),
                            Some(v) => (2, (v as i32).to_le_bytes().to_vec()),
                        };
                        if let Some((i, s)) = idx {
                            out.push(modrm(md, regfield, 4));
                            out.push((s << 6) | ((i & 7) << 3) | (b & 7));
                        } else if b & 7 == 4 {
                            out.push(modrm(md, regfield, 4));
                            out.push(0x24);
                        } else {
                            out.push(modrm(md, regfield, b & 7));
                        }
                        out.extend_from_slice(&db);
                    }
                    (None, Some((i, s))) => {
                        out.push(modrm(0, regfield, 4));
                        out.push((s << 6) | ((i & 7) << 3) | 5);
                        out.extend_from_slice(&(dv.unwrap_or(0) as i32).to_le_bytes());
                    }
                    (None, None) => {
                        out.push(modrm(0, regfield, 4));
                        out.push(0x25);
                        out.extend_from_slice(&(dv.unwrap_or(0) as i32).to_le_bytes());
                    }
                }
            }
            _ => return Err("operando rm inválido".into()),
        }
        Ok(())
    }

    // Calcula REX necesario para modrm_operand (regfield, rm) con ancho w.
    fn rex_bits(rf: u8, rm: &Op) -> (u8, u8, bool) {
        // (x, b, force)
        match rm {
            Op::Reg(c, _, h) => (0, *c, *h),
            Op::Mem { base, index, riplab, .. } => {
                if riplab.is_some() { return (0, 0, false); }
                let x = index.map(|(i, _)| i).unwrap_or(0);
                let b = base.unwrap_or(0);
                (x, b, false)
            }
            _ => (0, 0, false),
        }
    }

    fn push_rex(&self, out: &mut Vec<u8>, w: bool, regfield: u8, rm: &Op) {
        let (x, b, hibyte) = Enc::rex_bits(regfield, rm);
        // high-byte regs (ah..bh) prohiben REX
        let hi = hibyte || matches!(rm, Op::Reg(_, 8, true));
        if hi { return; }
        // force si reg de 8 bits extendido (spl/bpl/sil/dil/r8b+) en regfield o rm
        let rf8ext = false; // lo maneja quien llama vía force
        let v = 0x40 | ((w as u8) << 3) | (((regfield >> 3) & 1) << 2) | (((x >> 3) & 1) << 1) | ((b >> 3) & 1);
        if v != 0x40 || rf8ext { out.push(v); }
    }
}

// Tabla de NOPs de GAS para .p2align en .text (greedy: bloques de 11, luego tabla)
const NOP_TABLE: [&[u8]; 12] = [
    &[],
    &[0x90],
    &[0x66, 0x90],
    &[0x0f, 0x1f, 0x00],
    &[0x0f, 0x1f, 0x40, 0x00],
    &[0x0f, 0x1f, 0x44, 0x00, 0x00],
    &[0x66, 0x0f, 0x1f, 0x44, 0x00, 0x00],
    &[0x0f, 0x1f, 0x80, 0x00, 0x00, 0x00, 0x00],
    &[0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00],
    &[0x66, 0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00],
    &[0x66, 0x2e, 0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00],
    &[0x66, 0x66, 0x2e, 0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00],
];

fn nop_fill(mut n: usize) -> Vec<u8> {
    let mut out = Vec::new();
    while n > 11 { out.extend_from_slice(NOP_TABLE[11]); n -= 11; }
    out.extend_from_slice(NOP_TABLE[n]);
    out
}

// condiciones jcc/setcc/cmovcc
fn cc_code(cc: &str) -> Option<u8> {
    Some(match cc {
        "o" => 0, "no" => 1, "b" | "c" | "nae" => 2, "ae" | "nb" | "nc" => 3,
        "e" | "z" => 4, "ne" | "nz" => 5, "be" | "na" => 6, "a" | "nbe" => 7,
        "s" => 8, "ns" => 9, "p" | "pe" => 10, "np" | "po" => 11,
        "l" | "nge" => 12, "ge" | "nl" => 13, "le" | "ng" => 14, "g" | "nle" => 15,
        _ => return None,
    })
}

// ALU: (nombre, opcode base r/m8<-r8, ext /n para 80/81/83, acumulador 8-bit)
fn alu_info(m: &str) -> Option<(u8, u8, u8)> {
    Some(match m {
        "add" => (0x00, 0, 0x04), "or" => (0x08, 1, 0x0c), "and" => (0x20, 4, 0x24),
        "sub" => (0x28, 5, 0x2c), "xor" => (0x30, 6, 0x34), "cmp" => (0x38, 7, 0x3c),
        _ => return None,
    })
}

// ---------------------------------------------------------------- encoder

type RipPatches = Vec<(usize, String)>; // (posición del disp32 en out, etiqueta)

fn rex_byte(w: bool, r: u8, x: u8, b: u8, force: bool) -> Option<u8> {
    let v = 0x40 | ((w as u8) << 3) | (((r >> 3) & 1) << 2) | (((x >> 3) & 1) << 1) | ((b >> 3) & 1);
    if v != 0x40 || force { Some(v) } else { None }
}

// REX para instrucción con campo reg + operando rm (Reg o Mem).
// force8: el registro del campo reg es de 8 bits extendido (spl/bpl/sil/dil/r8b+).
fn rex_for(w: bool, regfield: u8, rm: &Op, force8: bool) -> Option<u8> {
    // high-byte (ah..bh) prohibe REX
    let hib = |o: &Op| matches!(o, Op::Reg(_, 8, true));
    if hib(rm) { return None; }
    let ext8 = |o: &Op| matches!(o, Op::Reg(c, 8, false) if *c >= 4);
    let force = force8 || ext8(rm);
    match rm {
        Op::Reg(c, _, _) => rex_byte(w, regfield, 0, *c, force),
        Op::Mem { base, index, riplab, .. } => {
            if riplab.is_some() { return rex_byte(w, regfield, 0, 0, force); }
            let x = index.map(|(i, _)| i).unwrap_or(0);
            let b = base.unwrap_or(0);
            rex_byte(w, regfield, x, b, force)
        }
        _ => rex_byte(w, regfield, 0, 0, force),
    }
}

// ¿el registro del campo reg necesita REX forzado por ser r8 extendido?
fn force8_of(o: &Op) -> bool { matches!(o, Op::Reg(c, 8, false) if *c >= 4) }

// REX para instrucción con DOS regs donde regfield va en .reg y el otro en .rm (cubierto arriba),
// o para formas de un solo operando con /digit.
fn emit_modrm(out: &mut Vec<u8>, ripp: &mut RipPatches, e: &Enc, regfield: u8, rm: &Op) -> Result<(), String> {
    match rm {
        Op::Reg(c, _, _) => { out.push(modrm(3, regfield, *c)); Ok(()) }
        Op::Mem { disp, base, index, riplab, .. } => {
            if let Some(lab) = riplab {
                out.push(modrm(0, regfield, 5));
                ripp.push((out.len(), lab.clone()));
                out.extend_from_slice(&[0; 4]);
                return Ok(());
            }
            let dv: Option<i64> = match disp { Some(x) => Some(e.eval(x)?), None => None };
            match (base, index) {
                (Some(b), idx) => {
                    // rbp/r13 (b&7==5) no admiten mod 00; r12 sí (vía SIB base=4)
                    let forced = b & 7 == 5;
                    let (md, db): (u8, Vec<u8>) = match dv {
                        None => if forced { (1, vec![0]) } else { (0, vec![]) },
                        Some(0) => if forced { (1, vec![0]) } else { (0, vec![]) },
                        Some(v) if (-128..=127).contains(&v) => (1, vec![v as u8]),
                        Some(v) => (2, (v as i32).to_le_bytes().to_vec()),
                    };
                    if let Some((i, s)) = idx {
                        out.push(modrm(md, regfield, 4));
                        out.push((s << 6) | ((i & 7) << 3) | (b & 7));
                    } else if b & 7 == 4 {
                        out.push(modrm(md, regfield, 4));
                        out.push(0x24);
                    } else {
                        out.push(modrm(md, regfield, b & 7));
                    }
                    out.extend_from_slice(&db);
                    Ok(())
                }
                (None, Some((i, s))) => {
                    out.push(modrm(0, regfield, 4));
                    out.push((s << 6) | ((i & 7) << 3) | 5);
                    out.extend_from_slice(&(dv.unwrap_or(0) as i32).to_le_bytes());
                    Ok(())
                }
                (None, None) => {
                    out.push(modrm(0, regfield, 4));
                    out.push(0x25);
                    out.extend_from_slice(&(dv.unwrap_or(0) as i32).to_le_bytes());
                    Ok(())
                }
            }
        }
        _ => Err("rm inválido".into()),
    }
}

fn fits_i8(v: i64) -> bool { (-128..=127).contains(&v) }
fn fits_i32(v: i64) -> bool { (i32::MIN as i64..=i32::MAX as i64).contains(&v) }

fn suffix_width(m: &str) -> (&str, Option<u8>) {
    // mnemónicos con significado propio que terminan en letra de sufijo: no tocar
    const EXACT: &[&str] = &[
        "ret","leave","syscall","pause","endbr64","nop","rep movsb",
        "fyl2x","fscale","frndint","fld1","f2xm1","fprem","fnstsw",
        "fldl","fstpl","fld","fstp","fxch","faddp","fsub",
        "movsd","addsd","subsd","mulsd","divsd","ucomisd","xorpd","cvtsi2sd","cvttsd2si","roundsd",
        "movsbq","movzbl","movzbq","movzwl","movzx","movabs","movq","comisd",
    ];
    for x in EXACT { if m == *x { return (m, None); } }
    if m.starts_with("set") || m.starts_with("cmov") || m.starts_with('j') { return (m, None); }
    const BASES: &[&str] = &[
        "mov","cmp","add","sub","and","or","xor","test","inc","dec",
        "shl","sal","shr","sar","neg","not","lea","push","pop","bt","bts","btr",
        "imul","div","xchg","cmpxchg",
    ];
    for (suf, w) in [('q', 64u8), ('l', 32), ('b', 8), ('w', 16)] {
        if let Some(p) = m.strip_suffix(suf) {
            if BASES.contains(&p) { return (p, Some(w)); }
        }
    }
    (m, None)
}

fn reg_width(ops: &[Op]) -> Option<u8> {
    for o in ops { if let Op::Reg(_, w, _) = o { return Some(*w); } }
    None
}

fn encode_ins(e: &Enc, mnem: &str, ops: &[Op], lock: bool, cur_va: u64, near: bool) -> Result<Vec<u8>, String> {
    let mut out: Vec<u8> = Vec::with_capacity(16);
    let mut ripp: RipPatches = Vec::new();
    if lock { out.push(0xF0); }
    if ops.iter().any(|o| matches!(o, Op::Mem { fs: true, .. })) { out.push(0x64); }
    encode_into(e, &mut out, &mut ripp, mnem, ops, cur_va, near)?;
    // parches RIP-relativos: disp32 = target - fin_instrucción
    for (pos, lab) in ripp {
        let target = e.eval(&Expr(vec![(false, Term::Sym(lab.clone()))]))?;
        let disp = target - (cur_va as i64 + out.len() as i64);
        out[pos..pos + 4].copy_from_slice(&(disp as i32).to_le_bytes());
    }
    Ok(out)
}

fn encode_into(e: &Enc, out: &mut Vec<u8>, ripp: &mut RipPatches, mnem0: &str, ops: &[Op], cur_va: u64, near: bool) -> Result<(), String> {
    // sin cambio de contexto; cur_va = va del inicio de la instrucción (post lock prefix!)
    let (m, sfx) = suffix_width(mnem0);
    match m {
        "ret" => { out.push(0xC3); return Ok(()); }
        "leave" => { out.push(0xC9); return Ok(()); }
        "syscall" => { out.extend_from_slice(&[0x0F, 0x05]); return Ok(()); }
        "pause" => { out.extend_from_slice(&[0xF3, 0x90]); return Ok(()); }
        "endbr64" => { out.extend_from_slice(&[0xF3, 0x0F, 0x1E, 0xFA]); return Ok(()); }
        "rep movsb" => { out.extend_from_slice(&[0xF3, 0xA4]); return Ok(()); }
        "nop" => { out.push(0x90); return Ok(()); }
        // x87 sin operandos
        "fyl2x" => { out.extend_from_slice(&[0xD9, 0xF1]); return Ok(()); }
        "fscale" => { out.extend_from_slice(&[0xD9, 0xFD]); return Ok(()); }
        "frndint" => { out.extend_from_slice(&[0xD9, 0xFC]); return Ok(()); }
        "fld1" => { out.extend_from_slice(&[0xD9, 0xE8]); return Ok(()); }
        "f2xm1" => { out.extend_from_slice(&[0xD9, 0xF0]); return Ok(()); }
        "fprem" => { out.extend_from_slice(&[0xD9, 0xF8]); return Ok(()); }
        "fnstsw" => { out.extend_from_slice(&[0xDF, 0xE0]); return Ok(()); } // %ax
        "fld" => { if let Op::St(i) = ops[0] { out.extend_from_slice(&[0xD9, 0xC0 + i]); return Ok(()); } }
        "fstp" => { if let Op::St(i) = ops[0] { out.extend_from_slice(&[0xDD, 0xD8 + i]); return Ok(()); } }
        "fxch" => { if let Op::St(i) = ops[0] { out.extend_from_slice(&[0xD9, 0xC8 + i]); return Ok(()); } }
        "faddp" => {
            if let (Op::St(_), Op::St(j)) = (&ops[0], &ops[1]) { out.extend_from_slice(&[0xDE, 0xC0 + j]); return Ok(()); }
        }
        "fsub" => {
            if let (Op::St(i), Op::St(_)) = (&ops[0], &ops[1]) { out.extend_from_slice(&[0xD8, 0xE0 + i]); return Ok(()); }
        }
        "fldl" => { out.push(0xDD); emit_modrm(out, ripp, e, 0, &ops[0])?; return Ok(()); }
        "fstpl" => { out.push(0xDD); emit_modrm(out, ripp, e, 3, &ops[0])?; return Ok(()); }
        _ => {}
    }
    // SSE y movq GPR<->XMM
    match m {
        "movsd" | "addsd" | "subsd" | "mulsd" | "divsd" | "ucomisd" | "xorpd"
        | "cvtsi2sd" | "cvttsd2si" | "roundsd" | "comisd" => {
            return encode_sse(e, out, ripp, m, ops);
        }
        "movq" => {
            if let (Op::Reg(_, 64, _), Op::Xmm(_)) = (&ops[0], &ops[1]) {
                out.push(0x66);
                if let (Op::Reg(g, _, _), Op::Xmm(x)) = (&ops[0], &ops[1]) {
                    if let Some(r) = rex_byte(true, *x, 0, *g, false) { out.push(r); }
                    out.extend_from_slice(&[0x0F, 0x6E]);
                    out.push(modrm(3, *x, *g));
                }
                return Ok(());
            }
            if let (Op::Xmm(_), Op::Reg(_, 64, _)) = (&ops[0], &ops[1]) {
                out.push(0x66);
                if let (Op::Xmm(x), Op::Reg(g, _, _)) = (&ops[0], &ops[1]) {
                    if let Some(r) = rex_byte(true, *x, 0, *g, false) { out.push(r); }
                    out.extend_from_slice(&[0x0F, 0x7E]);
                    out.push(modrm(3, *x, *g));
                }
                return Ok(());
            }
            // cae al camino genérico mov con w=64
        }
        _ => {}
    }
    let (m, sfx) = if m == "movq" { ("mov", Some(64u8)) } else { (m, sfx) };
    // movabs
    if m == "movabs" {
        if let (Op::Imm(x), Op::Reg(c, 64, _)) = (&ops[0], &ops[1]) {
            if let Some(r) = rex_byte(true, 0, 0, *c, false) { out.push(r); }
            out.push(0xB8 + (c & 7));
            out.extend_from_slice(&e.eval(x)?.to_le_bytes());
            return Ok(());
        }
        return Err("movabs forma".into());
    }
    // movzx/movsx
    match m {
        "movsbq" | "movzbl" | "movzbq" | "movzwl" | "movzx" => {
            let (src, dst) = (&ops[0], &ops[1]);
            let dw = if let Op::Reg(_, w, _) = dst { *w } else { return Err("movzx dst".into()); };
            let op2 = match m {
                "movsbq" => 0xBE,
                "movzbl" | "movzbq" => 0xB6,
                "movzwl" => 0xB7,
                "movzx" => {
                    let sw = match src { Op::Reg(_, w, _) => *w, Op::Mem { .. } => return Err("movzx mem sin sufijo".into()), _ => return Err("movzx src".into()) };
                    if sw == 8 { 0xB6 } else { 0xB7 }
                }
                _ => unreachable!(),
            };
            let dc = if let Op::Reg(c, _, _) = dst { *c } else { unreachable!() };
            let w = dw == 64;
            if let Some(r) = rex_for(w, dc, src, false) { out.push(r); }
            out.extend_from_slice(&[0x0F, op2]);
            emit_modrm(out, ripp, e, dc, src)?;
            return Ok(());
        }
        _ => {}
    }
    // saltos
    if m == "jmp" || (m.starts_with('j') && cc_code(&m[1..]).is_some()) {
        return encode_jump(e, out, m, ops, cur_va, near);
    }
    if m == "call" {
        match &ops[0] {
            Op::Imm(x) => {
                out.push(0xE8);
                let t = e.eval(x)?;
                let rel = t - (cur_va + 5) as i64;
                out.extend_from_slice(&(rel as i32).to_le_bytes());
                return Ok(());
            }
            Op::Star(inner) => {
                let regfield = 2u8;
                let rm: &Op = inner;
                if let Some(r) = rex_for(false, regfield, rm, false) { out.push(r); }
                out.push(0xFF);
                emit_modrm(out, ripp, e, regfield, rm)?;
                return Ok(());
            }
            _ => return Err("call forma".into()),
        }
    }
    // setcc
    if let Some(ccs) = m.strip_prefix("set") {
        if let Some(cc) = cc_code(ccs) {
            if let Op::Reg(c, 8, h) = ops[0] {
                if !h { if let Some(r) = rex_byte(false, 0, 0, c, c >= 4) { out.push(r); } }
                out.extend_from_slice(&[0x0F, 0x90 + cc]);
                out.push(modrm(3, 0, c));
                return Ok(());
            }
        }
        return Err(format!("setcc: {}", m));
    }
    // cmovcc
    if let Some(ccs) = m.strip_prefix("cmov") {
        if let Some(cc) = cc_code(ccs) {
            let (src, dst) = (&ops[0], &ops[1]);
            if let Op::Reg(dc, dw, _) = dst {
                if let Some(r) = rex_for(*dw == 64, *dc, src, false) { out.push(r); }
                out.extend_from_slice(&[0x0F, 0x40 + cc]);
                emit_modrm(out, ripp, e, *dc, src)?;
                return Ok(());
            }
        }
        return Err(format!("cmov: {}", m));
    }
    // push/pop
    if m == "push" || m == "pop" {
        if let Op::Reg(c, _, _) = ops[0] {
            if let Some(r) = rex_byte(false, 0, 0, c, false) { out.push(r); }
            out.push(if m == "push" { 0x50 } else { 0x58 } + (c & 7));
            return Ok(());
        }
        if m == "push" {
            if let Op::Imm(x) = &ops[0] {
                let v = e.eval(x)?;
                if fits_i8(v) && x.literal().is_some() { out.push(0x6A); out.push(v as u8); return Ok(()); }
                out.push(0x68);
                out.extend_from_slice(&(v as i32).to_le_bytes());
                return Ok(());
            }
        }
        return Err(format!("{} forma", m));
    }
    // lea
    if m == "lea" {
        let (src, dst) = (&ops[0], &ops[1]);
        if let Op::Reg(dc, dw, _) = dst {
            if let Some(r) = rex_for(*dw == 64, *dc, src, false) { out.push(r); }
            out.push(0x8D);
            emit_modrm(out, ripp, e, *dc, src)?;
            return Ok(());
        }
        return Err("lea forma".into());
    }
    // inc/dec/neg/not/div: FF/F7 grupos
    if let Some((op1, digit)) = match m { "inc" => Some((0xFFu8, 0u8)), "dec" => Some((0xFF, 1)), "neg" => Some((0xF7, 3)), "not" => Some((0xF7, 2)), "div" => Some((0xF7, 6)), "mul" => Some((0xF7, 4)), "idiv" => Some((0xF7, 7)), _ => None } {
        let wd = sfx.or_else(|| reg_width(ops)).ok_or(format!("{} sin ancho", m))?;
        let rm = &ops[0];
        if wd == 8 {
            // forma de 8 bits: FE (inc/dec) / F6 (neg/not/mul/div) + dígito
            if let Some(r) = rex_for(false, digit, rm, false) { out.push(r); }
            out.push(op1 - 1);
        } else {
            if let Some(r) = rex_for(wd == 64, digit, rm, false) { out.push(r); }
            if wd == 16 { out.insert(out.len().saturating_sub(0), 0x66); }
            out.push(op1);
        }
        emit_modrm(out, ripp, e, digit, rm)?;
        return Ok(());
    }
    // shifts
    if let Some(digit) = match m { "shl" | "sal" => Some(4u8), "shr" => Some(5), "sar" => Some(7), _ => None } {
        let rm = &ops[1];
        let w = sfx.or_else(|| reg_width(std::slice::from_ref(rm))).ok_or("shift sin ancho")? == 64;
        match &ops[0] {
            Op::Imm(x) => {
                let v = e.eval(x)?;
                if let Some(r) = rex_for(w, digit, rm, false) { out.push(r); }
                out.push(0xC1);
                emit_modrm(out, ripp, e, digit, rm)?;
                out.push(v as u8);
                return Ok(());
            }
            Op::Reg(1, 8, _) => {
                if let Some(r) = rex_for(w, digit, rm, false) { out.push(r); }
                out.push(0xD3);
                emit_modrm(out, ripp, e, digit, rm)?;
                return Ok(());
            }
            _ => return Err("shift forma".into()),
        }
    }
    // bt/bts/btr con inmediato
    if let Some(digit) = match m { "bt" => Some(4u8), "bts" => Some(5), "btr" => Some(6), _ => None } {
        let rm = &ops[1];
        let w = sfx.or_else(|| reg_width(ops)).ok_or("bt sin ancho")? == 64;
        if let Op::Imm(x) = &ops[0] {
            let v = e.eval(x)?;
            if let Some(r) = rex_for(w, digit, rm, false) { out.push(r); }
            out.extend_from_slice(&[0x0F, 0xBA]);
            emit_modrm(out, ripp, e, digit, rm)?;
            out.push(v as u8);
            return Ok(());
        }
        return Err("bt forma".into());
    }
    // cmpxchg
    if m == "cmpxchg" {
        let (src, rm) = (&ops[0], &ops[1]);
        let w = sfx.or_else(|| reg_width(ops)).ok_or("cmpxchg sin ancho")? == 64;
        if let Op::Reg(sc, _, _) = src {
            if let Some(r) = rex_for(w, *sc, rm, false) { out.push(r); }
            out.extend_from_slice(&[0x0F, 0xB1]);
            emit_modrm(out, ripp, e, *sc, rm)?;
            return Ok(());
        }
        return Err("cmpxchg forma".into());
    }
    // xchg
    if m == "xchg" {
        let (a, b) = (&ops[0], &ops[1]);
        let (reg, rm) = if matches!(a, Op::Reg(..)) { (a, b) } else { (b, a) };
        let w = sfx.or_else(|| reg_width(ops)).ok_or("xchg sin ancho")? == 64;
        if let Op::Reg(rc, rw, _) = reg {
            let opc = if *rw == 8 { 0x86 } else { 0x87 };
            if let Some(r) = rex_for(w, *rc, rm, false) { out.push(r); }
            out.push(opc);
            emit_modrm(out, ripp, e, *rc, rm)?;
            return Ok(());
        }
        return Err("xchg forma".into());
    }
    // imul
    if m == "imul" {
        if ops.len() == 2 {
            if let Op::Imm(x) = &ops[0] {
                // imul $I, %r  ==  imul $I, %r, %r
                if let Op::Reg(c, w, _) = ops[1] {
                    let v = e.eval(x)?;
                    return emit_imul_imm(out, e, v, &Op::Reg(c, w, false), &Op::Reg(c, w, false), w == 64);
                }
                return Err("imul forma".into());
            }
            let (src, dst) = (&ops[0], &ops[1]);
            if let Op::Reg(dc, dw, _) = dst {
                if let Some(r) = rex_for(*dw == 64, *dc, src, false) { out.push(r); }
                out.extend_from_slice(&[0x0F, 0xAF]);
                emit_modrm(out, ripp, e, *dc, src)?;
                return Ok(());
            }
            return Err("imul forma".into());
        }
        if ops.len() == 3 {
            if let (Op::Imm(x), src, Op::Reg(dc, dw, _)) = (&ops[0], &ops[1], &ops[2]) {
                let v = e.eval(x)?;
                return emit_imul_imm(out, e, v, src, &Op::Reg(*dc, *dw, false), *dw == 64);
            }
        }
        return Err("imul forma".into());
    }
    // mov
    if m == "mov" {
        return encode_mov(e, out, ripp, ops, sfx);
    }
    // test
    if m == "test" {
        return encode_test(e, out, ripp, ops, sfx);
    }
    // ALU genérico
    if let Some((base8, ext, acc8)) = alu_info(m) {
        return encode_alu(e, out, ripp, ops, sfx, base8, ext, acc8, m);
    }
    Err(format!("mnemónico no soportado: {}", mnem0))
}

fn emit_imul_imm(out: &mut Vec<u8>, e: &Enc, v: i64, src: &Op, dst: &Op, w: bool) -> Result<(), String> {
    let dc = if let Op::Reg(c, _, _) = dst { *c } else { return Err("imul dst".into()) };
    let mut ripp: RipPatches = Vec::new();
    if let Some(r) = rex_for(w, dc, src, false) { out.push(r); }
    if fits_i8(v) && true {
        out.push(0x6B);
        emit_modrm(out, &mut ripp, e, dc, src)?;
        out.push(v as u8);
    } else {
        out.push(0x69);
        emit_modrm(out, &mut ripp, e, dc, src)?;
        out.extend_from_slice(&(v as i32).to_le_bytes());
    }
    Ok(())
}

fn encode_mov(e: &Enc, out: &mut Vec<u8>, ripp: &mut RipPatches, ops: &[Op], sfx: Option<u8>) -> Result<(), String> {
    match (&ops[0], &ops[1]) {
        (Op::Imm(x), Op::Reg(c, w, h)) => {
            let v = e.eval(x)?;
            match w {
                64 => {
                    if fits_i32(v) {
                        if let Some(r) = rex_byte(true, 0, 0, *c, false) { out.push(r); }
                        out.push(0xC7);
                        out.push(modrm(3, 0, *c));
                        out.extend_from_slice(&(v as i32).to_le_bytes());
                    } else {
                        if let Some(r) = rex_byte(true, 0, 0, *c, false) { out.push(r); }
                        out.push(0xB8 + (c & 7));
                        out.extend_from_slice(&v.to_le_bytes());
                    }
                }
                32 => {
                    if let Some(r) = rex_byte(false, 0, 0, *c, false) { out.push(r); }
                    out.push(0xB8 + (c & 7));
                    out.extend_from_slice(&(v as i32).to_le_bytes());
                }
                8 => {
                    if !*h { if let Some(r) = rex_byte(false, 0, 0, *c, *c >= 4) { out.push(r); } }
                    out.push(0xB0 + (c & 7));
                    out.push(v as u8);
                }
                _ => return Err("mov imm ancho".into()),
            }
            Ok(())
        }
        (Op::Imm(x), dst @ Op::Mem { .. }) => {
            let w = sfx.ok_or("mov imm->mem sin sufijo")?;
            let v = e.eval(x)?;
            if let Some(r) = rex_for(w == 64, 0, dst, false) { out.push(r); }
            out.push(if w == 8 { 0xC6 } else { 0xC7 });
            emit_modrm(out, ripp, e, 0, dst)?;
            if w == 8 { out.push(v as u8); } else { out.extend_from_slice(&(v as i32).to_le_bytes()); }
            Ok(())
        }
        (Op::Reg(c, w, h), dst) => {
            let f8 = *w == 8 && *c >= 4 && !*h;
            if !(*w == 8 && *h) { if let Some(r) = rex_for(*w == 64, *c, dst, f8) { out.push(r); } }
            out.push(if *w == 8 { 0x88 } else { 0x89 });
            emit_modrm(out, ripp, e, *c, dst)?;
            Ok(())
        }
        (src @ Op::Mem { .. }, Op::Reg(c, w, _)) => {
            if let Some(r) = rex_for(*w == 64, *c, src, false) { out.push(r); }
            out.push(if *w == 8 { 0x8A } else { 0x8B });
            emit_modrm(out, ripp, e, *c, src)?;
            Ok(())
        }
        _ => Err("mov forma".into()),
    }
}

fn encode_test(e: &Enc, out: &mut Vec<u8>, ripp: &mut RipPatches, ops: &[Op], sfx: Option<u8>) -> Result<(), String> {
    match (&ops[0], &ops[1]) {
        (Op::Imm(x), rm) => {
            let w = sfx.or_else(|| reg_width(ops)).ok_or("test sin ancho")?;
            let v = e.eval(x)?;
            let acc = matches!(rm, Op::Reg(0, _, _));
            if acc && w > 8 {
                if let Some(r) = rex_byte(w == 64, 0, 0, 0, false) { out.push(r); }
                out.push(0xA9);
                out.extend_from_slice(&(v as i32).to_le_bytes());
                return Ok(());
            }
            if acc && w == 8 {
                out.push(0xA8);
                out.push(v as u8);
                return Ok(());
            }
            if let Some(r) = rex_for(w == 64, 0, rm, false) { out.push(r); }
            out.push(if w == 8 { 0xF6 } else { 0xF7 });
            emit_modrm(out, ripp, e, 0, rm)?;
            if w == 8 { out.push(v as u8); } else { out.extend_from_slice(&(v as i32).to_le_bytes()); }
            Ok(())
        }
        (Op::Reg(c, w, h), rm) => {
            let f8 = *w == 8 && *c >= 4 && !*h;
            if !(*w == 8 && *h) { if let Some(r) = rex_for(*w == 64, *c, rm, f8) { out.push(r); } }
            out.push(if *w == 8 { 0x84 } else { 0x85 });
            emit_modrm(out, ripp, e, *c, rm)?;
            Ok(())
        }
        _ => Err("test forma".into()),
    }
}

fn encode_alu(e: &Enc, out: &mut Vec<u8>, ripp: &mut RipPatches, ops: &[Op], sfx: Option<u8>,
              base8: u8, ext: u8, acc8: u8, m: &str) -> Result<(), String> {
    match (&ops[0], &ops[1]) {
        (Op::Imm(x), rm) => {
            let w = sfx.or_else(|| reg_width(ops)).ok_or(format!("{} sin ancho", m))?;
            let v = e.eval(x)?;
            if w == 8 {
                if matches!(rm, Op::Reg(0, 8, false)) {
                    // forma acumulador: 04/0C/14/... ib (la que elige as)
                    out.push(acc8);
                    out.push(v as u8);
                    return Ok(());
                }
                if let Some(r) = rex_for(false, ext, rm, false) { out.push(r); }
                out.push(0x80);
                emit_modrm(out, ripp, e, ext, rm)?;
                out.push(v as u8);
                return Ok(());
            }
            if fits_i8(v) && x.literal().is_some() {
                if let Some(r) = rex_for(w == 64, ext, rm, false) { out.push(r); }
                out.push(0x83);
                emit_modrm(out, ripp, e, ext, rm)?;
                out.push(v as u8);
                return Ok(());
            }
            let acc = matches!(rm, Op::Reg(0, _, _));
            if acc {
                if let Some(r) = rex_byte(w == 64, 0, 0, 0, false) { out.push(r); }
                out.push(acc8 + 1);
                out.extend_from_slice(&(v as i32).to_le_bytes());
                return Ok(());
            }
            if let Some(r) = rex_for(w == 64, ext, rm, false) { out.push(r); }
            out.push(0x81);
            emit_modrm(out, ripp, e, ext, rm)?;
            out.extend_from_slice(&(v as i32).to_le_bytes());
            Ok(())
        }
        (Op::Reg(c, w, h), rm) => {
            let f8 = *w == 8 && *c >= 4 && !*h;
            if !(*w == 8 && *h) { if let Some(r) = rex_for(*w == 64, *c, rm, f8) { out.push(r); } }
            out.push(if *w == 8 { base8 } else { base8 + 1 });
            emit_modrm(out, ripp, e, *c, rm)?;
            Ok(())
        }
        (src @ Op::Mem { .. }, Op::Reg(c, w, _)) => {
            if let Some(r) = rex_for(*w == 64, *c, src, false) { out.push(r); }
            out.push(if *w == 8 { base8 + 2 } else { base8 + 3 });
            emit_modrm(out, ripp, e, *c, src)?;
            Ok(())
        }
        _ => Err(format!("{} forma", m)),
    }
}

fn encode_sse(e: &Enc, out: &mut Vec<u8>, ripp: &mut RipPatches, m: &str, ops: &[Op]) -> Result<(), String> {
    match m {
        "movsd" => {
            match (&ops[0], &ops[1]) {
                (Op::Xmm(s), Op::Xmm(d)) => {
                    out.push(0xF2);
                    if let Some(r) = rex_byte(false, *d, 0, *s, false) { out.push(r); }
                    out.extend_from_slice(&[0x0F, 0x10]);
                    out.push(modrm(3, *d, *s));
                }
                (src @ Op::Mem { .. }, Op::Xmm(d)) => {
                    out.push(0xF2);
                    if let Some(r) = rex_for(false, *d, src, false) { out.push(r); }
                    out.extend_from_slice(&[0x0F, 0x10]);
                    emit_modrm(out, ripp, e, *d, src)?;
                }
                (Op::Xmm(s), dst @ Op::Mem { .. }) => {
                    out.push(0xF2);
                    if let Some(r) = rex_for(false, *s, dst, false) { out.push(r); }
                    out.extend_from_slice(&[0x0F, 0x11]);
                    emit_modrm(out, ripp, e, *s, dst)?;
                }
                _ => return Err("movsd forma".into()),
            }
            Ok(())
        }
        "addsd" | "subsd" | "mulsd" | "divsd" | "ucomisd" | "xorpd" | "comisd" => {
            let (p1, p2, op2) = match m {
                "addsd" => (0xF2u8, false, 0x58u8), "subsd" => (0xF2, false, 0x5C),
                "mulsd" => (0xF2, false, 0x59), "divsd" => (0xF2, false, 0x5E),
                "ucomisd" => (0x66, false, 0x2E), "xorpd" => (0x66, false, 0x57),
                "comisd" => (0x66, false, 0x2F),
                _ => unreachable!(),
            };
            let _ = p2;
            let (src, dst) = (&ops[0], &ops[1]);
            let dc = if let Op::Xmm(d) = dst { *d } else { return Err(format!("{} dst", m)); };
            out.push(p1);
            match src {
                Op::Xmm(s) => {
                    if let Some(r) = rex_byte(false, dc, 0, *s, false) { out.push(r); }
                    out.extend_from_slice(&[0x0F, op2]);
                    out.push(modrm(3, dc, *s));
                }
                mem @ Op::Mem { .. } => {
                    if let Some(r) = rex_for(false, dc, mem, false) { out.push(r); }
                    out.extend_from_slice(&[0x0F, op2]);
                    emit_modrm(out, ripp, e, dc, mem)?;
                }
                _ => return Err(format!("{} src", m)),
            }
            Ok(())
        }
        "cvtsi2sd" => {
            // cvtsi2sd %r64, %xmm
            let (src, dst) = (&ops[0], &ops[1]);
            let dc = if let Op::Xmm(d) = dst { *d } else { return Err("cvtsi2sd dst".into()) };
            out.push(0xF2);
            if let Some(r) = rex_for(true, dc, src, false) { out.push(r); }
            out.extend_from_slice(&[0x0F, 0x2A]);
            emit_modrm(out, ripp, e, dc, src)?;
            Ok(())
        }
        "cvttsd2si" => {
            let (src, dst) = (&ops[0], &ops[1]);
            let dc = if let Op::Reg(c, _, _) = dst { *c } else { return Err("cvttsd2si dst".into()) };
            out.push(0xF2);
            let sc = if let Op::Xmm(s) = src { *s } else { return Err("cvttsd2si src".into()) };
            if let Some(r) = rex_byte(true, dc, 0, sc, false) { out.push(r); }
            out.extend_from_slice(&[0x0F, 0x2C]);
            out.push(modrm(3, dc, sc));
            Ok(())
        }
        "roundsd" => {
            if let (Op::Imm(x), Op::Xmm(s), Op::Xmm(d)) = (&ops[0], &ops[1], &ops[2]) {
                out.push(0x66);
                if let Some(r) = rex_byte(false, *d, 0, *s, false) { out.push(r); }
                out.extend_from_slice(&[0x0F, 0x3A, 0x0B]);
                out.push(modrm(3, *d, *s));
                out.push(e.eval(x)? as u8);
                return Ok(());
            }
            Err("roundsd forma".into())
        }
        _ => unreachable!(),
    }
}

fn encode_jump(e: &Enc, out: &mut Vec<u8>, m: &str, ops: &[Op], cur_va: u64, near: bool) -> Result<(), String> {
    match &ops[0] {
        Op::Imm(x) => {
            let t = e.eval(x)?;
            // La forma la decide EXCLUSIVAMENTE el flag `near` (relajación estable);
            // si un corto no cabe, la relajación lo marcará near en la siguiente ronda.
            if m == "jmp" {
                if !near {
                    let rel = t - (cur_va + 2) as i64;
                    out.push(0xEB); out.push(rel as u8); return Ok(());
                }
                out.push(0xE9);
                let rel = t - (cur_va + 5) as i64;
                out.extend_from_slice(&(rel as i32).to_le_bytes());
                return Ok(());
            }
            let cc = cc_code(&m[1..]).ok_or(format!("jcc: {}", m))?;
            if !near {
                let rel = t - (cur_va + 2) as i64;
                out.push(0x70 + cc); out.push(rel as u8); return Ok(());
            }
            out.extend_from_slice(&[0x0F, 0x80 + cc]);
            let rel = t - (cur_va + 6) as i64;
            out.extend_from_slice(&(rel as i32).to_le_bytes());
            Ok(())
        }
        Op::Star(inner) => {
            let mut ripp: RipPatches = Vec::new();
            if let Some(r) = rex_for(false, 4, inner, false) { out.push(r); }
            out.push(0xFF);
            emit_modrm(out, &mut ripp, e, 4, inner)?;
            Ok(())
        }
        _ => Err("salto forma".into()),
    }
}

fn is_jump(mnem: &str) -> bool {
    let (m, _) = suffix_width(mnem);
    m == "jmp" || (m.starts_with('j') && m.len() > 1 && cc_code(&m[1..]).is_some())
}

fn jump_short_len(mnem: &str) -> u64 { let _ = mnem; 2 }
fn jump_near_len(mnem: &str) -> u64 { if mnem == "jmp" { 5 } else { 6 } }

// ---------------------------------------------------------------- layout + ELF

struct Layout {
    text_offs: Vec<u64>,   // offset de cada TItem
    text_size: u64,
    rod_size: u64, dat_size: u64, bss_size: u64, note_size: u64,
    note_off: u64, text_off: u64, rod_off: u64, dat_off: u64, bss_off: u64,
    text_va: u64, rod_va: u64, dat_va: u64, bss_va: u64, note_va: u64,
    has_rod: bool, has_dat: bool, has_bss: bool, has_note: bool,
    phnum: u64, headers_end: u64,
    // PE64: símbolos importados de kernel32 -> VA de su thunk (Fase 2).
    pe_imports: Option<std::collections::HashMap<String, u64>>,
}

impl Asm {
    fn resolve_num(&self, n: u32, fwd: bool, ref_seq: u64) -> Result<Loc, String> {
        let defs = self.p.numlabels.get(&n).ok_or_else(|| format!("etiqueta {} sin defs", n))?;
        if fwd {
            defs.iter().find(|(s, _)| *s > ref_seq).map(|(_, l)| *l)
                .ok_or_else(|| format!("{}f sin def posterior", n))
        } else {
            defs.iter().rev().find(|(s, _)| *s < ref_seq).map(|(_, l)| *l)
                .ok_or_else(|| format!("{}b sin def anterior", n))
        }
    }

    fn loc_offset(&self, loc: Loc, text_offs: &[u64], text_size: u64) -> u64 {
        match loc.sec {
            Sec::Text => if loc.idx >= text_offs.len() { text_size } else { text_offs[loc.idx] },
            Sec::Rodata => ditems_size(&self.rodata[..loc.idx]),
            Sec::Data => ditems_size(&self.data[..loc.idx]),
            Sec::Bss => ditems_size(&self.bss[..loc.idx]),
            Sec::Note => ditems_size(&self.note[..loc.idx]),
        }
    }

    fn make_resolver<'a>(&'a self, l: &'a Layout) -> impl Fn(&Expr) -> Result<i64, String> + 'a {
        move |e: &Expr| {
            let mut acc: i64 = 0;
            for (neg, t) in &e.0 {
                let v: i64 = match t {
                    Term::Num(n) => *n,
                    Term::Sym(name) => {
                        if let Some(c) = self.p.consts.get(name) { *c }
                        else if let Some(loc) = self.p.labels.get(name) {
                            let va = match loc.sec {
                                Sec::Text => l.text_va, Sec::Rodata => l.rod_va,
                                Sec::Data => l.dat_va, Sec::Bss => l.bss_va, Sec::Note => l.note_va,
                            };
                            (va + self.loc_offset(*loc, &l.text_offs, l.text_size)) as i64
                        }
                        else if let Some(v) = l.pe_imports.as_ref().and_then(|m| m.get(name)) {
                            *v as i64
                        }
                        else { return Err(format!("símbolo no definido: {}", name)); }
                    }
                    Term::Fwd(n, s) => {
                        let loc = self.resolve_num(*n, true, *s)?;
                        let va = match loc.sec { Sec::Text => l.text_va, Sec::Rodata => l.rod_va, Sec::Data => l.dat_va, Sec::Bss => l.bss_va, Sec::Note => l.note_va };
                        (va + self.loc_offset(loc, &l.text_offs, l.text_size)) as i64
                    }
                    Term::Back(n, s) => {
                        let loc = self.resolve_num(*n, false, *s)?;
                        let va = match loc.sec { Sec::Text => l.text_va, Sec::Rodata => l.rod_va, Sec::Data => l.dat_va, Sec::Bss => l.bss_va, Sec::Note => l.note_va };
                        (va + self.loc_offset(loc, &l.text_offs, l.text_size)) as i64
                    }
                };
                acc += if *neg { -v } else { v };
            }
            Ok(acc)
        }
    }

    fn encode_all(&self, near: &[bool], l: &Layout) -> Result<(Vec<u8>, Vec<u64>), String> {
        let resolve = self.make_resolver(l);
        let enc = Enc { resolve: &resolve };
        let mut bytes = Vec::with_capacity(l.text_size as usize + 16);
        let mut offs = Vec::with_capacity(self.text.len());
        for (i, it) in self.text.iter().enumerate() {
            offs.push(bytes.len() as u64);
            match it {
                TItem::P2 { bits, maxskip } => {
                    let al = 1u64 << bits;
                    let pad = (((bytes.len() as u64) + al - 1) & !(al - 1)) - bytes.len() as u64;
                    let do_fill = match maxskip { Some(ms) => pad <= *ms as u64, None => true };
                    if do_fill { bytes.extend_from_slice(&nop_fill(pad as usize)); }
                }
                TItem::Ins { mnem, ops, lock } => {
                    let cur_va = l.text_va + bytes.len() as u64;
                    let b = encode_ins(&enc, mnem, ops, *lock, cur_va, near[i])
                        .map_err(|e| format!("item {} ({} {:?}): {}", i, mnem, ops, e))?;
                    bytes.extend_from_slice(&b);
                }
                TItem::Raw(d) => {
                    match d {
                        DItem::Bytes(b) => bytes.extend_from_slice(b),
                        DItem::Align(n) => {
                            let pad = (((bytes.len() as u64) + n - 1) & !(n - 1)) - bytes.len() as u64;
                            bytes.extend_from_slice(&nop_fill(pad as usize));
                        }
                        DItem::Patch4(e2) => bytes.extend_from_slice(&(enc.eval(e2)? as u32).to_le_bytes()),
                        DItem::Patch8(e2) => bytes.extend_from_slice(&(enc.eval(e2)? as u64).to_le_bytes()),
                    }
                }
            }
        }
        Ok((bytes, offs))
    }

    fn finish(self, pe: bool) -> Result<Vec<u8>, String> {
        // PE64: los imports se escanean antes de la relajación (el resolver
        // los necesita ya en las pasadas provisionales; a VA 0, los call
        // rel32 no cambian de tamaño).
        let pe_import_names = if pe { Some(self.scan_imports()?) } else { None };
        // --- relajación de saltos: crecer a near hasta punto fijo
        let mut near: Vec<bool> = self.text.iter().map(|_| false).collect();
        let prov = Layout {
            text_offs: vec![0; self.text.len()], text_size: 0,
            rod_size: ditems_size(&self.rodata), dat_size: ditems_size(&self.data),
            bss_size: ditems_size(&self.bss), note_size: ditems_size(&self.note),
            note_off: 0, text_off: 0x1000, rod_off: 0, dat_off: 0, bss_off: 0,
            text_va: 0x401000, rod_va: 0, dat_va: 0, bss_va: 0, note_va: 0,
            has_rod: false, has_dat: false, has_bss: false, has_note: false,
            phnum: 4, headers_end: 0,
            pe_imports: pe_import_names.as_ref()
                .map(|v| v.iter().map(|s| (s.clone(), 0u64)).collect()),
        };
        // Relajación tipo GAS: los saltos solo crecen; los pads de .p2align se
        // recalculan cada pasada (pueden encoger). El sistema no es monótono por
        // los pads, así que tras converger hacemos búsqueda local: para cada salto
        // near, probamos a encogerlo y re-relajar; si el .text total queda más
        // corto, aceptamos y repetimos. Converge al punto fijo mínimo que halla as.
        let mut final_offs: Vec<u64> = Vec::new();
        let mut relax = |near: &mut Vec<bool>, final_offs: &mut Vec<u64>| -> Result<u64, String> {
            loop {
                let (bytes, offs) = self.encode_all(near, &prov)?;
                *final_offs = offs.clone();
                let lprov = Layout { text_offs: offs.clone(), text_size: bytes.len() as u64, ..prov_clone(&prov) };
                let resolve = self.make_resolver(&lprov);
                let enc = Enc { resolve: &resolve };
                let mut changed = false;
                for (i, it) in self.text.iter().enumerate() {
                    if near[i] { continue; }
                    if let TItem::Ins { mnem, ops, .. } = it {
                        if is_jump(mnem) {
                            if let Op::Imm(x) = &ops[0] {
                                let t = enc.eval(x)?;
                                let rel = t - (0x401000 + offs[i]) as i64 - 2;
                                if !fits_i8(rel) { near[i] = true; changed = true; }
                            }
                        }
                    }
                }
                if !changed { return Ok(bytes.len() as u64); }
            }
        };
        let mut best_size = relax(&mut near, &mut final_offs)?;
        let mut guard = 0;
        'busqueda: loop {
            guard += 1;
            if guard > 64 { break; }
            let cands: Vec<usize> = (0..near.len()).filter(|&i| near[i]).collect();
            for j in cands {
                let mut cand = near.clone();
                cand[j] = false;
                let mut co = Vec::new();
                let s = relax(&mut cand, &mut co)?;
                if s < best_size {
                    near = cand;
                    final_offs = co;
                    best_size = s;
                    continue 'busqueda;
                }
            }
            break;
        }
        if pe {
            self.finish_pe(near, final_offs, pe_import_names.unwrap())
        } else {
            self.finish_layout(near, final_offs)
        }
    }

    // Símbolos referenciados y no definidos: candidatos a import kernel32.
    // Validados contra la lista blanca medida y devueltos ordenados.
    fn scan_imports(&self) -> Result<Vec<String>, String> {
        const WHITELIST: [&str; 11] = ["VirtualAlloc", "VirtualFree", "GetSystemInfo", "ExitProcess", "GetEnvironmentVariableA", "GetLocalTime", "GetProcessHeap",
            "GetStdHandle", "HeapAlloc", "HeapFree", "WriteFile"];
        fn scan_expr(p: &Parser, e: &Expr, names: &mut Vec<String>) {
            for (_, t) in &e.0 {
                if let Term::Sym(n) = t {
                    if !p.labels.contains_key(n) && !p.consts.contains_key(n) && !names.contains(n) {
                        names.push(n.clone());
                    }
                }
            }
        }
        let mut imports: Vec<String> = Vec::new();
        for it in &self.text {
            match it {
                TItem::Ins { ops, .. } => {
                    for o in ops {
                        match o {
                            Op::Imm(e) => scan_expr(&self.p, e, &mut imports),
                            Op::Mem { disp, riplab, .. } => {
                                if let Some(e) = disp { scan_expr(&self.p, e, &mut imports); }
                                if let Some(n) = riplab {
                                    if !self.p.labels.contains_key(n) && !self.p.consts.contains_key(n)
                                        && !imports.contains(n) {
                                        imports.push(n.clone());
                                    }
                                }
                            }
                            Op::Star(inner) => {
                                if let Op::Imm(e) = &**inner { scan_expr(&self.p, e, &mut imports); }
                                if let Op::Mem { disp, riplab, .. } = &**inner {
                                    if let Some(e) = disp { scan_expr(&self.p, e, &mut imports); }
                                    if let Some(n) = riplab {
                                        if !self.p.labels.contains_key(n) && !imports.contains(n) {
                                            imports.push(n.clone());
                                        }
                                    }
                                }
                            }
                            _ => {}
                        }
                    }
                }
                TItem::Raw(DItem::Patch4(e)) | TItem::Raw(DItem::Patch8(e)) => {
                    scan_expr(&self.p, e, &mut imports);
                }
                _ => {}
            }
        }
        for sec in [&self.rodata, &self.data] {
            for d in sec {
                match d {
                    DItem::Patch4(e) | DItem::Patch8(e) => scan_expr(&self.p, e, &mut imports),
                    _ => {}
                }
            }
        }
        for n in &imports {
            if !WHITELIST.contains(&n.as_str()) {
                return Err(format!("PE64: símbolo indefinido '{}' no es un import kernel32 conocido", n));
            }
        }
        imports.sort();
        Ok(imports)
    }

    // ---------------------------------------------------------------- PE64 (Fase 2)
    // Layout medido del oráculo mingw-w64 ld 2.38 con `-s` (ver STATUS Fase 2):
    // secciones en orden .text,.data,.rdata,.bss,.idata, cada una en página
    // 0x1000 propia desde RVA 0x1000; ImageBase 0x140000000; thunks de import
    // al final de .text (FF 25 rel32 + 2 NOP, 8B, orden alfabético INVERSO);
    // cola de .text: NOPs hasta 16, luego 32B (FF x8, 00 x8) x2.
    fn finish_pe(self, near: Vec<bool>, offs_pre: Vec<u64>, imports: Vec<String>) -> Result<Vec<u8>, String> {
        if ditems_size(&self.note) > 0 || self.has_gnu_stack {
            return Err("PE64: secciones .note no soportadas en windows".into());
        }
        // as PE redondea cada sección al alineamiento de sección (mínimo 16).
        let sec_round = |sz: u64, a: u32| {
            let a = (a as u64).max(16);
            (sz + a - 1) & !(a - 1)
        };
        let rod_size = sec_round(ditems_size(&self.rodata), self.rod_align);
        let dat_size = sec_round(ditems_size(&self.data), self.dat_align);
        let bss_size = sec_round(ditems_size(&self.bss), self.bss_align);
        let has_rod = rod_size > 0;
        let has_dat = dat_size > 0;
        let has_bss = bss_size > 0;

        let n = imports.len() as u64;
        if n == 0 {
            return Err("PE64: sin imports (debe llamarse al menos a ExitProcess)".into());
        }

        const BASE: u64 = 0x140000000;
        let pad16 = |x: u64| (x + 15) & !15;
        let next_page = |x: u64| (x + 0xfff) & !0xfff;

        // tamaño de .idata: dir(20)+null(20)+ILT(8(n+1))+IAT(8(n+1))+strings+pad4+n*4+13+pad4
        let strs_len: u64 = imports.iter()
            .map(|s| { let l = 2 + s.len() as u64 + 1; (l + 1) & !1 }).sum();
        let iat_off = 0x28 + 8 * (n + 1);
        let idata_pre = iat_off + 8 * (n + 1) + strs_len;
        let idata_size = (((idata_pre + 3) & !3) + 4 * n + 13 + 3) & !3;

        // pasada provisional: imports -> 0 (los call rel32 no cambian de tamaño)
        let imp0: std::collections::HashMap<String, u64> =
            imports.iter().map(|s| (s.clone(), 0u64)).collect();
        let prov = Layout {
            text_offs: offs_pre.clone(), text_size: 0,
            rod_size, dat_size, bss_size, note_size: 0,
            note_off: 0, text_off: 0, rod_off: 0, dat_off: 0, bss_off: 0,
            text_va: BASE + 0x1000, rod_va: 0, dat_va: 0, bss_va: 0, note_va: 0,
            has_rod, has_dat, has_bss, has_note: false,
            phnum: 0, headers_end: 0, pe_imports: Some(imp0),
        };
        let (text_pre, _) = self.encode_all(&near, &prov)?;
        let code_size = text_pre.len() as u64;

        // layout definitivo
        let thunk_base = pad16(code_size);
        let after_thunks = thunk_base + 8 * n;
        let text_total = pad16(after_thunks) + 32;
        let text_rva: u64 = 0x1000;
        let mut rva = next_page(text_rva + text_total);
        let data_rva = if has_dat { let r = rva; rva = next_page(r + dat_size); r } else { 0 };
        let rdata_rva = if has_rod { let r = rva; rva = next_page(r + rod_size); r } else { 0 };
        let bss_rva = if has_bss { let r = rva; rva = next_page(r + bss_size); r } else { 0 };
        let idata_rva = rva;
        let iat_rva = idata_rva + iat_off;

        // thunks: orden alfabético inverso; import j (alfabético) -> IAT[j]
        let mut imp_va: std::collections::HashMap<String, u64> =
            std::collections::HashMap::new();
        let mut thunk_bytes: Vec<u8> = Vec::new();
        for (k, name) in imports.iter().rev().enumerate() {
            let j = (n - 1 - k as u64) as usize; // índice alfabético
            let off = thunk_base + 8 * k as u64;
            imp_va.insert(name.clone(), BASE + text_rva + off);
            let target = iat_rva + 8 * j as u64;
            let rel = target as i64 - (text_rva + off + 6) as i64;
            thunk_bytes.extend_from_slice(&[0xFF, 0x25]);
            thunk_bytes.extend_from_slice(&(rel as i32).to_le_bytes());
            thunk_bytes.extend_from_slice(&[0x90, 0x90]);
        }

        let l = Layout {
            text_offs: offs_pre, text_size: code_size,
            rod_size, dat_size, bss_size, note_size: 0,
            note_off: 0, text_off: 0, rod_off: 0, dat_off: 0, bss_off: 0,
            text_va: BASE + text_rva,
            rod_va: if has_rod { BASE + rdata_rva } else { 0 },
            dat_va: if has_dat { BASE + data_rva } else { 0 },
            bss_va: if has_bss { BASE + bss_rva } else { 0 },
            note_va: 0,
            has_rod, has_dat, has_bss, has_note: false,
            phnum: 0, headers_end: 0, pe_imports: Some(imp_va),
        };
        let (text_bytes, _) = self.encode_all(&near, &l)?;
        if text_bytes.len() as u64 != code_size {
            return Err(format!("PE64: oscilación interna {} vs {}", code_size, text_bytes.len()));
        }
        let mut text = text_bytes;
        // Medido en ld: el relleno pre-thunks es 0x90 simple; el post-thunks
        // (hasta 16) usa la tabla NOP multibyte de siempre.
        text.extend_from_slice(&vec![0x90u8; (thunk_base - code_size) as usize]);
        text.extend_from_slice(&thunk_bytes);
        text.extend_from_slice(&nop_fill((pad16(after_thunks) - after_thunks) as usize));
        for _ in 0..2 { text.extend_from_slice(&[0xFF; 8]); text.extend_from_slice(&[0u8; 8]); }

        let resolve = self.make_resolver(&l);
        let mut rod_bytes = materialize(&self.rodata, &resolve)?;
        rod_bytes.resize(rod_size as usize, 0);
        let mut dat_bytes = materialize(&self.data, &resolve)?;
        dat_bytes.resize(dat_size as usize, 0);

        let entry_off = match self.p.labels.get("_start") {
            Some(loc) if loc.sec == Sec::Text => self.loc_offset(*loc, &l.text_offs, code_size),
            _ => return Err("sin _start".into()),
        };

        Ok(crate::hpe::write_pe(&crate::hpe::PeImage {
            text, text_rva: text_rva as u32,
            data: if has_dat { Some((dat_bytes, data_rva as u32)) } else { None },
            rdata: if has_rod { Some((rod_bytes, rdata_rva as u32)) } else { None },
            bss: if has_bss { Some((bss_size, bss_rva as u32)) } else { None },
            idata_rva: idata_rva as u32,
            iat_rva: iat_rva as u32,
            idata_size: idata_size as u32,
            imports,
            entry_rva: (text_rva + entry_off) as u32,
        }))
    }

    fn finish_layout(self, near: Vec<bool>, offs_pre: Vec<u64>) -> Result<Vec<u8>, String> {
        // tamaños de datos
        let rod_size = ditems_size(&self.rodata);
        let dat_size = ditems_size(&self.data);
        let bss_size = ditems_size(&self.bss);
        let note_size = ditems_size(&self.note);
        let has_note = note_size > 0;
        let has_rod = rod_size > 0;
        let has_dat = dat_size > 0;
        let has_bss = bss_size > 0;
        let phnum: u64 = 2 + has_rod as u64 + (has_dat || has_bss) as u64
            + if has_note { 2 } else { 0 } + self.has_gnu_stack as u64;
        let note_off: u64 = if has_note { (64 + phnum * 56 + 7) & !7 } else { 0 };
        let headers_end: u64 = if has_note { note_off + note_size } else { 64 + phnum * 56 };
        let _ = headers_end;

        // primera pasada de texto con layout provisional para conocer text_size
        let prov = Layout {
            text_offs: offs_pre.clone(), text_size: 0,
            rod_size, dat_size, bss_size, note_size,
            note_off, text_off: 0x1000, rod_off: 0, dat_off: 0, bss_off: 0,
            text_va: 0x401000, rod_va: 0, dat_va: 0, bss_va: 0, note_va: 0,
            has_rod, has_dat, has_bss, has_note, phnum, headers_end, pe_imports: None,
        };
        let (text_bytes_pre, offs_pre) = self.encode_all(&near, &prov)?;
        let text_size = text_bytes_pre.len() as u64;
        let _ = offs_pre;

        let text_off: u64 = 0x1000;
        let text_va: u64 = 0x401000;
        let text_end_off = text_off + text_size;
        let (rod_off, rod_va) = if has_rod {
            let o = (text_end_off + 0xfff) & !0xfff;
            (o, 0x400000 + o)
        } else { (0, 0) };
        let rod_end_off = rod_off + rod_size;
        let prev_end_off = if has_rod { rod_end_off } else { text_end_off };
        // Regla medida de ld: el segmento RW (data+bss) comparte la página de
        // rodata solo si CABE entero en lo que queda de página; si no, salta a
        // página nueva (y FormA da entonces va = identidad limpia).
        let page_end = (prev_end_off + 0xfff) & !0xfff;
        let rw_total = |o: u64| -> u64 {
            let after_dat = if has_dat { o + dat_size } else { o };
            if has_bss {
                let ba = self.bss_align as u64;
                ((after_dat + ba - 1) & !(ba - 1)) + bss_size
            } else { after_dat }
        };
        let fit_bump = |o: u64| -> u64 {
            if has_rod && rw_total(o) > page_end { page_end } else { o }
        };
        let (dat_off, dat_va) = if has_dat {
            let a = self.dat_align as u64;
            let o = fit_bump((prev_end_off + a - 1) & !(a - 1));
            let va = if has_rod { 0x400000 + ((o + 0xfff) & !0xfff) + (o & 0xfff) }
                     else { 0x400000 + ((o + 0xfff) & !0xfff) };
            (o, va)
        } else { (0, 0) };
        let dat_end_off = if has_dat { dat_off + dat_size } else { prev_end_off };
        let (bss_off, bss_va) = if has_bss {
            let a = self.bss_align as u64;
            let o = if has_dat { (dat_end_off + a - 1) & !(a - 1) } else { fit_bump((dat_end_off + a - 1) & !(a - 1)) };
            let va = if has_dat { dat_va + (o - dat_off) }
                     else if has_rod { 0x400000 + ((o + 0xfff) & !0xfff) + (o & 0xfff) }
                     else { 0x400000 + ((o + 0xfff) & !0xfff) };
            (o, va)
        } else { (0, 0) };

        let l = Layout {
            text_offs: vec![], text_size,
            rod_size, dat_size, bss_size, note_size,
            note_off, text_off, rod_off, dat_off, bss_off,
            text_va, rod_va, dat_va, bss_va, note_va: 0x400000 + note_off,
            has_rod, has_dat, has_bss, has_note, phnum, headers_end, pe_imports: None,
        };
        // pasada final de texto con resolver completo
        let l2 = Layout { text_offs: Vec::new(), ..layout_clone(&l) };
        let _ = l2;
        // encode_all necesita text_offs: los produce incrementalmente; el resolver
        // para etiquetas de texto necesita los offsets FINALES: usamos offs_pre
        // (los offsets no cambian entre pasadas con el mismo `near`).
        let l = Layout { text_offs: offs_pre, ..l };
        if std::env::var("HASM_DEBUG").is_ok() {
            let mut v: Vec<(u64, &String)> = self.p.labels.iter()
                .filter(|(_, lo)| lo.sec == Sec::Text)
                .map(|(n, lo)| (self.loc_offset(*lo, &l.text_offs, l.text_size), n)).collect();
            v.sort();
            for (o, n) in v { eprintln!("{:016x} {}", o, n); }
            let mut w: Vec<(u32, u64, u64)> = Vec::new();
            for (n, defs) in &self.p.numlabels {
                for (s, lo) in defs {
                    if lo.sec == Sec::Text { w.push((*n, *s, self.loc_offset(*lo, &l.text_offs, l.text_size))); }
                }
            }
            w.sort();
            for (n, s, o) in w { eprintln!("num {} seq {} = {:x}", n, s, o); }
        }
        let (text_bytes, _offs) = self.encode_all(&near, &l)?;
        if std::env::var("HASM_DEBUG").is_ok() {
            for (i, (a, b)) in l.text_offs.iter().zip(_offs.iter()).enumerate() {
                if a != b {
                    if let TItem::Ins { mnem, ops, .. } = &self.text[i] {
                        eprintln!("DRIFT item {} ({} {:?}): prov={:x} final={:x}", i, mnem, ops, a, b);
                    } else {
                        eprintln!("DRIFT item {} (P2): prov={:x} final={:x}", i, a, b);
                    }
                }
            }
        }
        if text_bytes.len() as u64 != text_size {
            // diagnóstico: compara tamaños por item
            let mut o1 = 0u64; let mut o2 = 0u64;
            let resolve2 = self.make_resolver(&prov);
            let enc2 = Enc { resolve: &resolve2 };
            let resolve3 = self.make_resolver(&l);
            let enc3 = Enc { resolve: &resolve3 };
            for (i, it) in self.text.iter().enumerate() {
                let s1 = match it {
                    TItem::P2 { bits, maxskip } => { let al = 1u64 << bits; let pad = ((o1 + al - 1) & !(al - 1)) - o1; match maxskip { Some(ms) if pad > *ms as u64 => 0, _ => pad } }
                    TItem::Ins { mnem, ops, lock } => encode_ins(&enc2, mnem, ops, *lock, 0x401000 + o1, near[i]).map(|b| b.len() as u64).unwrap_or(999),
                    TItem::Raw(d) => match d { DItem::Bytes(b) => b.len() as u64, DItem::Patch4(_) => 4, DItem::Patch8(_) => 8, DItem::Align(n) => ((o1 + n - 1) & !(n - 1)) - o1 },
                };
                let s2 = match it {
                    TItem::P2 { bits, maxskip } => { let al = 1u64 << bits; let pad = ((o2 + al - 1) & !(al - 1)) - o2; match maxskip { Some(ms) if pad > *ms as u64 => 0, _ => pad } }
                    TItem::Ins { mnem, ops, lock } => encode_ins(&enc3, mnem, ops, *lock, 0x401000 + o2, near[i]).map(|b| b.len() as u64).unwrap_or(998),
                    TItem::Raw(d) => match d { DItem::Bytes(b) => b.len() as u64, DItem::Patch4(_) => 4, DItem::Patch8(_) => 8, DItem::Align(n) => ((o2 + n - 1) & !(n - 1)) - o2 },
                };
                if s1 != s2 {
                    let dbg = if let TItem::Ins { ops, .. } = it {
                        if let Op::Imm(x) = &ops[0] {
                            let t2 = enc2.eval(x).unwrap_or(0); let t3 = enc3.eval(x).unwrap_or(0);
                            format!(" t2={} t3={} rel2={} rel3={} near={}", t2, t3, t2-(0x401000+o1) as i64-2, t3-(0x401000+o2) as i64-2, near[i])
                        } else { String::new() }
                    } else { String::new() };
                    return Err(format!("oscilación item {} ({:?}): {} vs {}{} o1={} o2={}", i, it, s1, s2, dbg, o1, o2));
                }
                o1 += s1; o2 += s2;
            }
            return Err(format!("oscilación total: {} vs {}", text_size, text_bytes.len()));
        }

        // --- materializar datos
        let resolve = self.make_resolver(&l);
        let rod_bytes = materialize(&self.rodata, &resolve)?;
        let dat_bytes_v = materialize(&self.data, &resolve)?;
        let note_bytes_v = materialize(&self.note, &resolve)?;

        // --- entrada
        let entry = match self.p.labels.get("_start") {
            Some(loc) if loc.sec == Sec::Text => l.text_va + self.loc_offset(*loc, &l.text_offs, l.text_size),
            _ => return Err("sin _start".into()),
        };

        Ok(build_elf(ElfSpec {
            entry,
            note: if has_note { Some((note_off, note_bytes_v)) } else { None },
            text: (text_off, text_va, text_bytes, self.text_align),
            rodata: if has_rod { Some((rod_off, rod_va, rod_bytes, self.rod_align)) } else { None },
            data: if has_dat { Some((dat_off, dat_va, dat_bytes_v, self.dat_align)) } else { None },
            bss: if has_bss { Some((bss_off, bss_va, bss_size, self.bss_align)) } else { None },
            gnu_stack: self.has_gnu_stack,
            phnum, headers_end,
        }))
    }
}

fn prov_clone(l: &Layout) -> Layout {
    Layout {
        text_offs: l.text_offs.clone(), text_size: l.text_size,
        rod_size: l.rod_size, dat_size: l.dat_size, bss_size: l.bss_size, note_size: l.note_size,
        note_off: l.note_off, text_off: l.text_off, rod_off: l.rod_off, dat_off: l.dat_off, bss_off: l.bss_off,
        text_va: l.text_va, rod_va: l.rod_va, dat_va: l.dat_va, bss_va: l.bss_va, note_va: l.note_va,
        has_rod: l.has_rod, has_dat: l.has_dat, has_bss: l.has_bss, has_note: l.has_note,
        phnum: l.phnum, headers_end: l.headers_end,
        pe_imports: l.pe_imports.clone(),
    }
}
fn layout_clone(l: &Layout) -> Layout { prov_clone(l) }

fn materialize(items: &[DItem], resolve: &dyn Fn(&Expr) -> Result<i64, String>) -> Result<Vec<u8>, String> {
    let mut out = Vec::new();
    for it in items {
        match it {
            DItem::Bytes(b) => out.extend_from_slice(b),
            DItem::Align(n) => {
                let target = ((out.len() as u64) + n - 1) & !(n - 1);
                out.resize(target as usize, 0);
            }
            DItem::Patch4(e) => out.extend_from_slice(&(resolve(e)? as u32).to_le_bytes()),
            DItem::Patch8(e) => out.extend_from_slice(&(resolve(e)? as u64).to_le_bytes()),
        }
    }
    Ok(out)
}

struct ElfSpec {
    entry: u64,
    note: Option<(u64, Vec<u8>)>,
    text: (u64, u64, Vec<u8>, u32),
    rodata: Option<(u64, u64, Vec<u8>, u32)>,
    data: Option<(u64, u64, Vec<u8>, u32)>,
    bss: Option<(u64, u64, u64, u32)>,
    gnu_stack: bool,
    phnum: u64,
    headers_end: u64,
}

fn build_elf(s: ElfSpec) -> Vec<u8> {
    let text_end = s.text.0 + s.text.2.len() as u64;
    let rod_end = s.rodata.as_ref().map(|(o, _, b, _)| o + b.len() as u64).unwrap_or(text_end);
    let dat_end = s.data.as_ref().map(|(o, _, b, _)| o + b.len() as u64).unwrap_or(rod_end);
    let file_end_secs = dat_end; // .bss no ocupa fichero

    // shstrtab
    let mut shstr: Vec<u8> = b"\0.shstrtab\0".to_vec();
    let mut name_off = |name: &str, shstr: &mut Vec<u8>| -> u32 {
        let o = shstr.len() as u32;
        shstr.extend_from_slice(name.as_bytes());
        shstr.push(0);
        o
    };
    let note_name = if s.note.is_some() { Some(name_off(".note.gnu.property", &mut shstr)) } else { None };
    let text_name = name_off(".text", &mut shstr);
    let rod_name = s.rodata.as_ref().map(|_| name_off(".rodata", &mut shstr));
    let dat_name = s.data.as_ref().map(|_| name_off(".data", &mut shstr));
    let bss_name = s.bss.as_ref().map(|_| name_off(".bss", &mut shstr));

    let shstr_off = file_end_secs;
    let shoff = (shstr_off + shstr.len() as u64 + 7) & !7;

    let mut out: Vec<u8> = Vec::with_capacity(shoff as usize + 4096);
    // ---- cabecera ELF
    out.extend_from_slice(&[0x7f, 0x45, 0x4c, 0x46, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    out.extend_from_slice(&2u16.to_le_bytes());        // ET_EXEC
    out.extend_from_slice(&0x3eu16.to_le_bytes());     // x86-64
    out.extend_from_slice(&1u32.to_le_bytes());
    out.extend_from_slice(&s.entry.to_le_bytes());
    out.extend_from_slice(&64u64.to_le_bytes());       // phoff
    out.extend_from_slice(&shoff.to_le_bytes());       // shoff
    out.extend_from_slice(&0u32.to_le_bytes());        // flags
    out.extend_from_slice(&64u16.to_le_bytes());       // ehsize
    out.extend_from_slice(&56u16.to_le_bytes());       // phentsize
    out.extend_from_slice(&(s.phnum as u16).to_le_bytes());
    out.extend_from_slice(&64u16.to_le_bytes());       // shentsize
    let shnum: u16 = 2 /*null+shstrtab*/ + s.note.is_some() as u16 + 1 + s.rodata.is_some() as u16
        + s.data.is_some() as u16 + s.bss.is_some() as u16;
    out.extend_from_slice(&shnum.to_le_bytes());
    out.extend_from_slice(&(shnum - 1).to_le_bytes()); // shstrndx

    // ---- program headers
    let mut ph = |typ: u32, flags: u32, off: u64, va: u64, fs: u64, ms: u64, align: u64| {
        out.extend_from_slice(&typ.to_le_bytes());
        out.extend_from_slice(&flags.to_le_bytes());
        out.extend_from_slice(&off.to_le_bytes());
        out.extend_from_slice(&va.to_le_bytes());
        out.extend_from_slice(&va.to_le_bytes());
        out.extend_from_slice(&fs.to_le_bytes());
        out.extend_from_slice(&ms.to_le_bytes());
        out.extend_from_slice(&align.to_le_bytes());
    };
    ph(1, 4, 0, 0x400000, s.headers_end, s.headers_end, 0x1000);
    ph(1, 5, s.text.0, s.text.1, s.text.2.len() as u64, s.text.2.len() as u64, 0x1000);
    if let Some((o, v, b, _)) = &s.rodata { ph(1, 4, *o, *v, b.len() as u64, b.len() as u64, 0x1000); }
    if s.data.is_some() || s.bss.is_some() {
        let (o, v, fs) = match &s.data {
            Some((o, v, b, _)) => (*o, *v, b.len() as u64),
            None => { let (o, v, sz, _) = s.bss.as_ref().unwrap(); (*o, *v, 0u64.max(*sz * 0)) }
        };
        let ms = fs + s.bss.as_ref().map(|(_, _, sz, _)| *sz).unwrap_or(0);
        ph(1, 6, o, v, fs, ms, 0x1000);
    }
    if let Some((o, b)) = &s.note {
        let va = 0x400000 + o;
        ph(4, 4, *o, va, b.len() as u64, b.len() as u64, 8);          // PT_NOTE
        ph(0x6474e553, 4, *o, va, b.len() as u64, b.len() as u64, 8); // GNU_PROPERTY
    }
    if s.gnu_stack {
        ph(0x6474e551, 6, 0, 0, 0, 0, 0x10); // GNU_STACK RW
    }

    // ---- contenido de secciones
    if let Some((o, b)) = &s.note {
        out.resize(*o as usize, 0);
        out.extend_from_slice(b);
    }
    out.resize(s.text.0 as usize, 0);
    out.extend_from_slice(&s.text.2);
    if let Some((o, _, b, _)) = &s.rodata {
        out.resize(*o as usize, 0);
        out.extend_from_slice(b);
    }
    if let Some((o, _, b, _)) = &s.data {
        out.resize(*o as usize, 0);
        out.extend_from_slice(b);
    }
    // ---- shstrtab + shdrs
    out.resize(shstr_off as usize, 0);
    out.extend_from_slice(&shstr);
    out.resize(shoff as usize, 0);
    let mut sh = |name: u32, typ: u32, flags: u64, addr: u64, off: u64, size: u64, align: u64| {
        out.extend_from_slice(&name.to_le_bytes());
        out.extend_from_slice(&typ.to_le_bytes());
        out.extend_from_slice(&flags.to_le_bytes());
        out.extend_from_slice(&addr.to_le_bytes());
        out.extend_from_slice(&off.to_le_bytes());
        out.extend_from_slice(&size.to_le_bytes());
        out.extend_from_slice(&0u32.to_le_bytes()); // link
        out.extend_from_slice(&0u32.to_le_bytes()); // info
        out.extend_from_slice(&align.to_le_bytes());
        out.extend_from_slice(&0u64.to_le_bytes()); // entsize
    };
    sh(0, 0, 0, 0, 0, 0, 0); // null
    if let (Some(n), Some((o, b))) = (note_name, &s.note) {
        sh(n, 7, 2, 0x400000 + o, *o, b.len() as u64, 8);
    }
    sh(text_name, 1, 6, s.text.1, s.text.0, s.text.2.len() as u64, s.text.3 as u64);
    if let (Some(n), Some((o, v, b, a))) = (rod_name, &s.rodata) { sh(n, 1, 2, *v, *o, b.len() as u64, *a as u64); }
    if let (Some(n), Some((o, v, b, a))) = (dat_name, &s.data) { sh(n, 1, 3, *v, *o, b.len() as u64, *a as u64); }
    if let (Some(n), Some((o, v, sz, a))) = (bss_name, &s.bss) { sh(n, 8, 3, *v, *o, *sz, *a as u64); }
    sh(1, 3, 0, 0, shstr_off, shstr.len() as u64, 1);
    out
}

fn assemble_target(src: &str, pe: bool) -> Result<Vec<u8>, String> {
    let expanded = expand_rept(src)?;
    let mut a = Asm {
        p: Parser { consts: HashMap::new(), labels: HashMap::new(), numlabels: HashMap::new(), seq: Cell::new(0) },
        text: Vec::new(), rodata: Vec::new(), data: Vec::new(), bss: Vec::new(), note: Vec::new(),
        has_gnu_stack: false, cur: Sec::Text, secstack: Vec::new(),
        text_align: 1, rod_align: 1, dat_align: 1, bss_align: 1,
    };
    for (ln, raw) in expanded.lines().enumerate() {
        a.parse_line(raw).map_err(|e| format!("línea {}: {}: {}", ln + 1, raw.trim(), e))?;
    }
    a.finish(pe)
}

pub fn assemble(src: &str) -> Result<Vec<u8>, String> {
    assemble_target(src, false)
}

pub fn assemble_pe(src: &str) -> Result<Vec<u8>, String> {
    assemble_target(src, true)
}
