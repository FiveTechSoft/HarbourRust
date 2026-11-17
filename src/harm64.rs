// harm64.rs — native AArch64 Mach-O backend.
//
// hbc's code generator emits one well-defined x86-64 subset (the same text
// the own x86 assembler `hasm` encodes). This module, a child of hasm that
// reuses its parser, translates every instruction of that subset into
// AArch64 and writes an ad hoc signed arm64 Mach-O executable. It does not
// emulate an x86 CPU at run time: each x86 instruction becomes a fixed
// sequence of ARM instructions chosen at compile time.
//
// Machine model
//   x86 GPRs map to fixed ARM registers (RMAP); rsp is x28, which addresses
//   an emulated downward stack mmap'ed at start-up, so x86 push/pop/call/ret
//   keep their 8-byte slot layout. The real ARM sp is only used to call
//   libSystem (pow/fmod) through one wrapper. xmm0-15 map to v0-v15.
//   x86 flags are not kept in a register: a backward scan pairs every flag
//   consumer (jcc/setcc/cmovcc) with its producer; producers that feed a
//   consumer use flag-setting ARM forms, and the condition is mapped through
//   the producer kind (sub/add/logic/fp compare...). Unknown pairings are
//   compile-time errors, never silent guesses.
//   Linux syscalls are lowered to the Darwin numbers at compile time (svc
//   #0x80); unsupported ones are rejected.

use super::*;

const RMAP: [u8; 16] = [9, 10, 11, 12, 28, 29, 13, 14, 19, 20, 21, 22, 23, 24, 25, 26];
const T0: u8 = 15;
const T1: u8 = 16;
const T2: u8 = 17; // address scratch
const T3: u8 = 8; // secondary address scratch
const T4: u8 = 27;
const ZR: u8 = 31;
const XSP: u8 = 28;
const LR: u8 = 30;
const FSR: u8 = 7; // x86 %fs base (thread-local block), per thread
const AX: u8 = 6;  // address scratch for ordered/atomic accesses
const DMB_ISH: u32 = 0xD503_3BBF;
const FT0: u8 = 16;
const FT1: u8 = 17;

const BASE: u64 = 0x1_0000_0000;
const HDR: u64 = 0x4000;
const TEXT_VA: u64 = BASE + HDR;
const ESTACK: u64 = 64 << 20;

const EQ: u8 = 0; const NE: u8 = 1; const CS: u8 = 2; const CC: u8 = 3; const MI: u8 = 4; const PL: u8 = 5;
const VS: u8 = 6; const VC: u8 = 7; const HI: u8 = 8; const LS: u8 = 9; const GE: u8 = 10; const LT: u8 = 11;
const GT: u8 = 12; const LE: u8 = 13;

// ------------------------------------------------------------------ encoders

fn sf(x: bool) -> u32 { if x { 0x8000_0000 } else { 0 } }
fn r(n: u8) -> u32 { (n & 31) as u32 }
fn e_addsub_reg(x: bool, sub: bool, s: bool, rd: u8, rn: u8, rm: u8, sh: u8, amt: u8) -> u32 {
    sf(x) | if sub { 0x4B00_0000 } else { 0x0B00_0000 } | if s { 0x2000_0000 } else { 0 }
        | (sh as u32) << 22 | r(rm) << 16 | (amt as u32) << 10 | r(rn) << 5 | r(rd)
}
fn e_addsub_imm(x: bool, sub: bool, s: bool, rd: u8, rn: u8, imm12: u32, sh12: bool) -> u32 {
    sf(x) | if sub { 0x5100_0000 } else { 0x1100_0000 } | if s { 0x2000_0000 } else { 0 }
        | if sh12 { 1 << 22 } else { 0 } | (imm12 & 0xfff) << 10 | r(rn) << 5 | r(rd)
}
fn e_addsub_ext(x: bool, sub: bool, s: bool, rd: u8, rn: u8, rm: u8, option: u8, imm3: u8) -> u32 {
    sf(x) | if sub { 0x4B20_0000 } else { 0x0B20_0000 } | if s { 0x2000_0000 } else { 0 }
        | r(rm) << 16 | (option as u32) << 13 | (imm3 as u32) << 10 | r(rn) << 5 | r(rd)
}
// opc: 0 and, 1 orr, 2 eor, 3 ands; n: invert rm (bic/orn/eon/bics)
fn e_log_reg(x: bool, opc: u32, n: bool, rd: u8, rn: u8, rm: u8, sh: u8, amt: u8) -> u32 {
    sf(x) | opc << 29 | 0x0A00_0000 | if n { 1 << 21 } else { 0 } | (sh as u32) << 22
        | r(rm) << 16 | (amt as u32) << 10 | r(rn) << 5 | r(rd)
}
fn e_log_imm(x: bool, opc: u32, rd: u8, rn: u8, enc: u32) -> u32 {
    sf(x) | opc << 29 | 0x1200_0000 | enc << 10 | r(rn) << 5 | r(rd)
}
fn e_mov(x: bool, rd: u8, rm: u8) -> u32 { e_log_reg(x, 1, false, rd, ZR, rm, 0, 0) }
fn e_cmp_zero_w(rn: u8) -> u32 { e_addsub_imm(false, true, true, ZR, rn, 0, false) }
// N:immr:imms packed as 13 bits, or None if not a bitmask immediate.
fn bitmask_imm(v: u64, x: bool) -> Option<u32> {
    let v = if x { v } else {
        let lo = v & 0xffff_ffff;
        if v >> 32 != 0 && v >> 32 != 0xffff_ffff { return None; }
        lo | lo << 32
    };
    if v == 0 || v == u64::MAX { return None; }
    let mut size = 64u32;
    while size > 2 {
        let h = size / 2;
        let m = (1u64 << h) - 1;
        if v & m != (v >> h) & m { break; }
        size = h;
    }
    let mask = if size == 64 { u64::MAX } else { (1u64 << size) - 1 };
    let e = v & mask;
    let ones = e.count_ones();
    let pat = if ones == 64 { u64::MAX } else { (1u64 << ones) - 1 };
    for rot in 0..size {
        let rr = if rot == 0 { e } else { ((e >> rot) | (e << (size - rot))) & mask };
        if rr == pat {
            let immr = (size - rot) % size;
            let n = if size == 64 { 1 } else { 0 };
            let imms = ((!(size - 1) << 1) & 0x3f) | (ones - 1);
            if !x && n == 1 { return None; }
            return Some(n << 12 | immr << 6 | imms);
        }
    }
    None
}
fn e_movw(x: bool, opc: u32, rd: u8, imm16: u32, hw: u32) -> u32 {
    // opc: 0 movn, 2 movz, 3 movk
    sf(x) | opc << 29 | 0x1280_0000 | hw << 21 | (imm16 & 0xffff) << 5 | r(rd)
}
fn e_bfm(x: bool, opc: u32, rd: u8, rn: u8, immr: u32, imms: u32) -> u32 {
    // opc: 0 sbfm, 1 bfm, 2 ubfm
    sf(x) | opc << 29 | 0x1300_0000 | if x { 1 << 22 } else { 0 } | immr << 16 | imms << 10 | r(rn) << 5 | r(rd)
}
fn e_lsl(x: bool, rd: u8, rn: u8, s: u32) -> u32 {
    let w = if x { 64 } else { 32 };
    e_bfm(x, 2, rd, rn, (w - s) % w, w - 1 - s)
}
fn e_lsr(x: bool, rd: u8, rn: u8, s: u32) -> u32 { e_bfm(x, 2, rd, rn, s, if x { 63 } else { 31 }) }
fn e_asr(x: bool, rd: u8, rn: u8, s: u32) -> u32 { e_bfm(x, 0, rd, rn, s, if x { 63 } else { 31 }) }
fn e_bfi(rd: u8, rn: u8, lsb: u32, w: u32) -> u32 { e_bfm(true, 1, rd, rn, (64 - lsb) % 64, w - 1) }
fn e_ubfx(x: bool, rd: u8, rn: u8, lsb: u32, w: u32) -> u32 { e_bfm(x, 2, rd, rn, lsb, lsb + w - 1) }
fn e_sbfx(x: bool, rd: u8, rn: u8, lsb: u32, w: u32) -> u32 { e_bfm(x, 0, rd, rn, lsb, lsb + w - 1) }
fn e_madd(x: bool, sub: bool, rd: u8, rn: u8, rm: u8, ra: u8) -> u32 {
    sf(x) | 0x1B00_0000 | if sub { 0x8000 } else { 0 } | r(rm) << 16 | r(ra) << 10 | r(rn) << 5 | r(rd)
}
fn e_smulh(rd: u8, rn: u8, rm: u8) -> u32 { 0x9B40_7C00 | r(rm) << 16 | r(rn) << 5 | r(rd) }
fn e_smull(rd: u8, rn: u8, rm: u8) -> u32 { 0x9B20_7C00 | r(rm) << 16 | r(rn) << 5 | r(rd) }
fn e_udiv(x: bool, rd: u8, rn: u8, rm: u8) -> u32 { sf(x) | 0x1AC0_0800 | r(rm) << 16 | r(rn) << 5 | r(rd) }
fn e_csel(x: bool, rd: u8, rn: u8, rm: u8, c: u8) -> u32 { sf(x) | 0x1A80_0000 | r(rm) << 16 | (c as u32) << 12 | r(rn) << 5 | r(rd) }
fn e_csinc(x: bool, rd: u8, rn: u8, rm: u8, c: u8) -> u32 { e_csel(x, rd, rn, rm, c) | 0x400 }
fn e_csneg(x: bool, rd: u8, rn: u8, rm: u8, c: u8) -> u32 { e_csel(x, rd, rn, rm, c) | 0x4000_0400 }
fn e_cset(rd: u8, c: u8) -> u32 { e_csinc(false, rd, ZR, ZR, c ^ 1) }
fn e_extr(rd: u8, rn: u8, rm: u8, lsb: u32) -> u32 { 0x93C0_0000 | r(rm) << 16 | lsb << 10 | r(rn) << 5 | r(rd) }
// loads/stores. size 0..3 (b,h,w,x); opc 0 store, 1 load, 2 load signed->64, 3 load signed->32
fn e_ldst_u(size: u32, v: bool, opc: u32, rt: u8, rn: u8, imm12: u32) -> u32 {
    size << 30 | 0x3900_0000 | if v { 0x0400_0000 } else { 0 } | opc << 22 | (imm12 & 0xfff) << 10 | r(rn) << 5 | r(rt)
}
// mode: 0 unscaled, 1 post-index, 3 pre-index
fn e_ldst_9(size: u32, v: bool, opc: u32, rt: u8, rn: u8, imm9: i64, mode: u32) -> u32 {
    size << 30 | 0x3800_0000 | if v { 0x0400_0000 } else { 0 } | opc << 22 | ((imm9 as u32) & 0x1ff) << 12 | mode << 10 | r(rn) << 5 | r(rt)
}
fn e_ldst_reg(size: u32, opc: u32, rt: u8, rn: u8, rm: u8, shift: bool) -> u32 {
    size << 30 | 0x3820_0800 | opc << 22 | r(rm) << 16 | 3 << 13 | if shift { 1 << 12 } else { 0 } | r(rn) << 5 | r(rt)
}
fn e_stp(x: bool, v: bool, load: bool, rt: u8, rt2: u8, rn: u8, imm: i64) -> u32 {
    // signed offset form, scaled by 8
    let opc = if v { 1u32 } else if x { 2 } else { 0 };
    opc << 30 | 0x2900_0000 | if v { 0x0400_0000 } else { 0 } | if load { 1 << 22 } else { 0 }
        | (((imm / 8) as u32) & 0x7f) << 15 | r(rt2) << 10 | r(rn) << 5 | r(rt)
}
const SVC80: u32 = 0xD400_1001;
fn e_br(rn: u8) -> u32 { 0xD61F_0000 | r(rn) << 5 }
fn e_blr(rn: u8) -> u32 { 0xD63F_0000 | r(rn) << 5 }
const RET: u32 = 0xD65F_03C0;
fn e_adr(rd: u8, off: i64) -> u32 { let o = off as u32; 0x1000_0000 | (o & 3) << 29 | ((o >> 2) & 0x7ffff) << 5 | r(rd) }
fn e_cbz(x: bool, nz: bool, rt: u8, off: i64) -> u32 {
    sf(x) | if nz { 0x3500_0000 } else { 0x3400_0000 } | (((off / 4) as u32) & 0x7ffff) << 5 | r(rt)
}
fn e_b(off: i64) -> u32 { 0x1400_0000 | (((off / 4) as u32) & 0x3ff_ffff) }
fn e_bc(c: u8, off: i64) -> u32 { 0x5400_0000 | (((off / 4) as u32) & 0x7ffff) << 5 | c as u32 }
fn e_mrs_nzcv(rt: u8) -> u32 { 0xD53B_4200 | r(rt) }
fn e_msr_nzcv(rt: u8) -> u32 { 0xD51B_4200 | r(rt) }
// FP double scalar
fn e_fop(op: u32, dd: u8, dn: u8, dm: u8) -> u32 { 0x1E60_0000 | op | r(dm) << 16 | r(dn) << 5 | r(dd) }
const F_MUL: u32 = 0x0800; const F_DIV: u32 = 0x1800; const F_ADD: u32 = 0x2800; const F_SUB: u32 = 0x3800;
fn e_fcmp(dn: u8, dm: u8) -> u32 { 0x1E60_2000 | r(dm) << 16 | r(dn) << 5 }
fn e_fmov(dd: u8, dn: u8) -> u32 { 0x1E60_4000 | r(dn) << 5 | r(dd) }
fn e_fmov_from_x(dd: u8, xn: u8) -> u32 { 0x9E67_0000 | r(xn) << 5 | r(dd) }
fn e_fmov_to_x(xd: u8, dn: u8) -> u32 { 0x9E66_0000 | r(dn) << 5 | r(xd) }
fn e_scvtf(x: bool, dd: u8, rn: u8) -> u32 { (if x { 0x9E62_0000 } else { 0x1E62_0000 }) | r(rn) << 5 | r(dd) }
fn e_fcvtzs(x: bool, rd: u8, dn: u8) -> u32 { (if x { 0x9E78_0000 } else { 0x1E78_0000 }) | r(dn) << 5 | r(rd) }
fn e_movi_d0(dd: u8) -> u32 { 0x2F00_E400 | r(dd) }
fn e_eor16b(dd: u8, dn: u8, dm: u8) -> u32 { 0x6E20_1C00 | r(dm) << 16 | r(dn) << 5 | r(dd) }
fn e_fcmeq(dd: u8, dn: u8, dm: u8) -> u32 { 0x5E60_E400 | r(dm) << 16 | r(dn) << 5 | r(dd) }

// ------------------------------------------------------------------ IR

#[derive(Clone)]
#[derive(Debug)]
enum Tg { E(Expr), H(&'static str), Got(usize), L(u32) }

#[derive(Clone)]
enum AI {
    W(u32),
    B { link: bool, t: Tg },
    Bc { c: u8, t: Tg },
    Adr { rd: u8, t: Tg }, // adrp + add: 8 bytes
    Hl(&'static str),      // helper label definition (0 bytes)
    Lab(u32),              // local label (0 bytes)
    Bytes(Vec<u8>),        // data inside .text
    Align(u64),
}

#[derive(Clone, Copy, PartialEq, Debug)]
enum FK { Sub, Add, Logic, IncDec, Imul, Fp, Bt, Shift }

enum Cd { One(u8), Never, Always, EqOrVs, NeAndVc }

fn norm_cc(cc: &str) -> &str {
    match cc { "c" | "nae" => "b", "nc" | "nb" => "ae", "z" => "e", "nz" => "ne", "na" => "be", "nbe" => "a",
        "nge" => "l", "nl" => "ge", "ng" => "le", "nle" => "g", "pe" => "p", "po" => "np", x => x }
}

fn map_cc(k: FK, cc: &str) -> Result<Cd, String> {
    let cc = norm_cc(cc);
    use Cd::*;
    let signed = |cc: &str| -> Option<Cd> { Some(match cc {
        "e" => One(EQ), "ne" => One(NE), "s" => One(MI), "ns" => One(PL), "o" => One(VS), "no" => One(VC),
        "l" => One(LT), "ge" => One(GE), "le" => One(LE), "g" => One(GT), _ => return None }) };
    let r = match k {
        FK::Sub => match cc { "b" => Some(One(CC)), "ae" => Some(One(CS)), "be" => Some(One(LS)), "a" => Some(One(HI)), _ => signed(cc) },
        FK::Add => match cc { "b" => Some(One(CS)), "ae" => Some(One(CC)), _ => signed(cc) },
        FK::IncDec => signed(cc),
        FK::Logic => match cc { "o" | "b" => Some(Never), "no" | "ae" => Some(Always), "be" => Some(One(EQ)), "a" => Some(One(NE)), _ => signed(cc) },
        FK::Shift => match cc { "e" => Some(One(EQ)), "ne" => Some(One(NE)), "s" => Some(One(MI)), "ns" => Some(One(PL)), _ => None },
        FK::Imul => match cc { "o" => Some(One(NE)), "no" => Some(One(EQ)), _ => None },
        FK::Bt => match cc { "b" => Some(One(NE)), "ae" => Some(One(EQ)), _ => None },
        FK::Fp => match cc { "a" => Some(One(GT)), "ae" => Some(One(GE)), "b" => Some(One(LT)), "be" => Some(One(LE)),
            "e" => Some(EqOrVs), "ne" => Some(NeAndVc), "p" => Some(One(VS)), "np" => Some(One(VC)), _ => None },
    };
    r.ok_or_else(|| format!("ARM64: condition {} after {:?} flags is not translated", cc, k))
}

fn setter_kind(base: &str) -> Option<FK> {
    Some(match base {
        "cmp" | "sub" | "neg" | "sbb" | "cmpxchg" => FK::Sub,
        "add" => FK::Add,
        "and" | "or" | "xor" | "test" => FK::Logic,
        "inc" | "dec" => FK::IncDec,
        "imul" => FK::Imul,
        "ucomisd" | "comisd" => FK::Fp,
        "mul" => FK::Imul,
        "bt" | "bts" | "btr" => FK::Bt,
        "shl" | "sal" | "shr" | "sar" => FK::Shift,
        _ => return None,
    })
}
// Instructions after which x86 flags are undefined or clobbered in a way no
// consumer may rely on.
fn kills_flags(base: &str) -> bool {
    matches!(base, "call" | "syscall" | "div" | "fnstsw" | "fprem" | "fyl2x")
}
fn consumer_cc(m: &str) -> Option<&str> {
    if m == "jmp" { return None; }
    if m == "sbb" || m == "adc" { return Some("b"); }
    if let Some(c) = m.strip_prefix("cmov") { return Some(c); }
    if let Some(c) = m.strip_prefix("set") { return Some(c); }
    if let Some(c) = m.strip_prefix('j') { return Some(c); }
    None
}

fn base_of(m: &str) -> (&str, Option<u8>) { suffix_width(m) }

// ------------------------------------------------------------------ translator

struct Tr<'a> {
    a: &'a Asm,
    out: Vec<AI>,
    need: Vec<bool>,        // setter i must produce ARM flags
    live: Vec<bool>,        // flags live across item i (its translation must preserve NZCV)
    ckind: Vec<Option<FK>>, // consumer i: producer kind
    imports: Vec<&'static str>,
    used_helpers: std::collections::HashSet<&'static str>,
    threaded: bool,         // program uses the thread runtime: TSO-ordered memory, pthread clone
    ext: bool,              // EXTERNAL program: undefined symbols come from the extension dylib
    ext_imports: std::collections::HashSet<&'static str>,
}

impl<'a> Tr<'a> {
    fn w(&mut self, x: u32) { self.out.push(AI::W(x)); }

    fn cval(&self, e: &Expr) -> Option<i64> {
        let mut acc = 0i64;
        let mut labs: Vec<(bool, Loc)> = Vec::new();
        for (neg, t) in &e.0 {
            let v = match t {
                Term::Num(n) => *n,
                Term::Sym(s) => match self.a.p.consts.get(s) {
                    Some(c) => *c,
                    None => { labs.push((*neg, *self.a.p.labels.get(s)?)); 0 }
                },
                _ => return None,
            };
            acc = if *neg { acc.wrapping_sub(v) } else { acc.wrapping_add(v) };
        }
        if !labs.is_empty() {
            // label differences inside one data section: data bytes are laid
            // out unchanged, so the distance is the x86 one
            let sec = labs[0].1.sec;
            let net: i64 = labs.iter().map(|(n, _)| if *n { -1 } else { 1 }).sum();
            if net != 0 || sec == Sec::Text || labs.iter().any(|(_, l)| l.sec != sec) { return None; }
            let items = match sec { Sec::Rodata => &self.a.rodata, Sec::Data => &self.a.data, Sec::Bss => &self.a.bss, _ => return None };
            let pre = prefix_sizes(items);
            for (n, l) in labs { let v = pre[l.idx] as i64; acc = if n { acc.wrapping_sub(v) } else { acc.wrapping_add(v) }; }
        }
        Some(acc)
    }

    fn mov_imm(&mut self, x: bool, rd: u8, v: u64) {
        let v = if x { v } else { v & 0xffff_ffff };
        let n = if x { 4 } else { 2 };
        let chunks: Vec<u32> = (0..n).map(|i| ((v >> (16 * i)) & 0xffff) as u32).collect();
        let zeros = chunks.iter().filter(|c| **c == 0).count();
        let ones = chunks.iter().filter(|c| **c == 0xffff).count();
        if zeros >= n - 1 {
            let hw = chunks.iter().position(|c| *c != 0).unwrap_or(0);
            self.w(e_movw(x, 2, rd, chunks[hw], hw as u32));
            return;
        }
        if ones >= n - 1 {
            let hw = chunks.iter().position(|c| *c != 0xffff).unwrap_or(0);
            self.w(e_movw(x, 0, rd, !chunks[hw] & 0xffff, hw as u32));
            return;
        }
        if let Some(enc) = bitmask_imm(v, x) {
            self.w(e_log_imm(x, 1, rd, ZR, enc));
            return;
        }
        let inv = ones > zeros;
        let mut first = true;
        for (i, c) in chunks.iter().enumerate() {
            let skip = if inv { *c == 0xffff } else { *c == 0 };
            if skip { continue; }
            if first {
                if inv { self.w(e_movw(x, 0, rd, !c & 0xffff, i as u32)); } else { self.w(e_movw(x, 2, rd, *c, i as u32)); }
                first = false;
            } else {
                self.w(e_movw(x, 3, rd, *c, i as u32));
            }
        }
    }

    // rd = rn + v (64-bit); rn may be any GPR except 31.
    fn add_imm(&mut self, rd: u8, rn: u8, v: i64) {
        if v == 0 { if rd != rn { self.w(e_mov(true, rd, rn)); } return; }
        let (sub, m) = if v < 0 { (true, v.unsigned_abs()) } else { (false, v as u64) };
        if m < 4096 { self.w(e_addsub_imm(true, sub, false, rd, rn, m as u32, false)); return; }
        if m & 0xfff == 0 && m < (1 << 24) { self.w(e_addsub_imm(true, sub, false, rd, rn, (m >> 12) as u32, true)); return; }
        let tmp = if rd == rn { T3 } else { rd };
        let tmp = if tmp == rn { T4 } else { tmp };
        self.mov_imm(true, tmp, v as u64);
        self.w(e_addsub_reg(true, false, false, rd, rn, tmp, 0, 0));
    }

    // Memory operand -> (base register, offset). The offset is either 0 or
    // directly encodable for an access of `size` bytes.
    fn maddr(&mut self, o: &Op, size: u64) -> Result<(u8, i64), String> {
        let (disp, base, index, riplab) = match o {
            Op::Mem { disp, base, index, riplab, seg } => {
                if *seg == 2 { return Err("ARM64: %gs memory is not translated".into()); }
                if *seg == 1 {
                    // %fs:disp(base,index,sc) -> FSR + disp + base + index<<sc
                    let d = match disp { None => 0, Some(e) => self.cval(e).ok_or("ARM64: symbolic %fs displacement")? };
                    let b = match (base, index) {
                        (None, None) => FSR,
                        _ => {
                            self.w(e_mov(true, T2, FSR));
                            if let Some(bb) = base { self.w(e_addsub_reg(true, false, false, T2, T2, RMAP[*bb as usize], 0, 0)); }
                            if let Some((ix, sc)) = index { self.w(e_addsub_reg(true, false, false, T2, T2, RMAP[*ix as usize], 0, *sc)); }
                            T2
                        }
                    };
                    let ok = (-256..256).contains(&d) || (d >= 0 && d % size as i64 == 0 && d / (size as i64) < 4096);
                    if ok { return Ok((b, d)); }
                    self.mov_imm(true, T3, d as u64);
                    self.w(e_addsub_reg(true, false, false, T2, b, T3, 0, 0));
                    return Ok((T2, 0));
                }
                (disp, base, index, riplab)
            }
            _ => return Err("ARM64: memory operand expected".into()),
        };
        let dconst = match disp { None => Some(0), Some(e) => self.cval(e) };
        if riplab.is_some() || dconst.is_none() {
            let e = disp.clone().ok_or("ARM64: empty symbolic displacement")?;
            if base.is_none() && index.is_none() {
                if let Some(g) = self.ext_symbol(&e) {
                    self.out.push(AI::Adr { rd: T2, t: Tg::Got(g) });
                    self.w(e_ldst_u(3, false, 1, T2, T2, 0));
                    return Ok((T2, 0));
                }
            }
            self.out.push(AI::Adr { rd: T2, t: Tg::E(e) });
            if let Some(bb) = base { self.w(e_addsub_reg(true, false, false, T2, T2, RMAP[*bb as usize], 0, 0)); }
            if let Some((ix, sc)) = index { self.w(e_addsub_reg(true, false, false, T2, T2, RMAP[*ix as usize], 0, *sc)); }
            return Ok((T2, 0));
        }
        let d = dconst.unwrap();
        let (mut b, mut off) = match (base, index) {
            (Some(bb), None) => (RMAP[*bb as usize], d),
            (Some(bb), Some((ix, sc))) => {
                self.w(e_addsub_reg(true, false, false, T2, RMAP[*bb as usize], RMAP[*ix as usize], 0, *sc));
                (T2, d)
            }
            (None, Some((ix, sc))) => {
                self.w(e_lsl(true, T2, RMAP[*ix as usize], *sc as u32));
                (T2, d)
            }
            (None, None) => { self.mov_imm(true, T2, d as u64); return Ok((T2, 0)); }
        };
        let ok = (-256..256).contains(&off) || (off >= 0 && off % size as i64 == 0 && off / (size as i64) < 4096);
        if !ok {
            self.add_imm(T2, b, off);
            b = T2; off = 0;
        }
        Ok((b, off))
    }

    // size bytes 1,2,4,8 (16: q register); opc 0 st, 1 ld, 2 ldrs->64, 3 ldrs->32
    fn ldst(&mut self, size: u64, v: bool, opc: u32, rt: u8, b: u8, off: i64) {
        if self.threaded && !v && b != XSP && b != RMAP[5] && b != FSR {
            // x86 TSO on a weakly ordered machine: shared-memory loads are
            // acquires and stores are releases (thread-private stack, frame
            // and %fs accesses stay plain).
            let sz = size.trailing_zeros();
            let a = if off == 0 { b } else {
                if (0..4096).contains(&off) { self.w(e_addsub_imm(true, false, false, AX, b, off as u32, false)); }
                else if (-4095..0).contains(&off) { self.w(e_addsub_imm(true, true, false, AX, b, (-off) as u32, false)); }
                else { self.mov_imm(true, AX, off as u64); self.w(e_addsub_reg(true, false, false, AX, AX, b, 0, 0)); }
                AX
            };
            if opc == 0 { self.w(sz << 30 | 0x089F_FC00 | r(a) << 5 | r(rt)); return; }
            self.w(sz << 30 | 0x08DF_FC00 | r(a) << 5 | r(rt));
            if opc >= 2 && sz < 3 { self.w(e_sbfx(opc == 2, rt, rt, 0, 8 << sz)); }
            return;
        }
        let (sz, opc) = if v && size == 16 { (0u32, opc | 2) } else { (size.trailing_zeros(), opc) };
        if off >= 0 && off % size as i64 == 0 && off / (size as i64) < 4096 {
            self.w(e_ldst_u(sz, v, opc, rt, b, (off / size as i64) as u32));
        } else {
            self.w(e_ldst_9(sz, v, opc, rt, b, off, 0));
        }
    }

    // Value of operand (low w bits significant) in some register.
    fn val(&mut self, o: &Op, w: u8, scratch: u8) -> Result<u8, String> {
        match o {
            Op::Reg(c, _, true) => { self.w(e_ubfx(false, scratch, RMAP[(*c - 4) as usize], 8, 8)); Ok(scratch) }
            Op::Reg(c, _, false) => Ok(RMAP[*c as usize]),
            Op::Imm(e) => {
                if let Some(v) = self.cval(e) { self.mov_imm(w == 64, scratch, v as u64); }
                else { self.out.push(AI::Adr { rd: scratch, t: Tg::E(e.clone()) }); }
                Ok(scratch)
            }
            Op::Mem { .. } => {
                let (b, off) = self.maddr(o, (w / 8) as u64)?;
                self.ldst((w / 8) as u64, false, 1, scratch, b, off);
                Ok(scratch)
            }
            _ => Err("ARM64: unsupported operand".into()),
        }
    }

    // Write the low w bits of src into operand.
    fn put(&mut self, o: &Op, w: u8, src: u8) -> Result<(), String> {
        match o {
            Op::Reg(c, _, true) => { self.w(e_bfi(RMAP[(*c - 4) as usize], src, 8, 8)); }
            Op::Reg(c, rw, false) => {
                let d = RMAP[*c as usize];
                match rw { 64 => if d != src { self.w(e_mov(true, d, src)) }, 32 => self.w(e_mov(false, d, src)),
                    _ => self.w(e_bfi(d, src, 0, *rw as u32)) }
            }
            Op::Mem { .. } => {
                let (b, off) = self.maddr(o, (w / 8) as u64)?;
                self.ldst((w / 8) as u64, false, 0, src, b, off);
            }
            _ => return Err("ARM64: bad destination".into()),
        }
        Ok(())
    }

    fn xmm(o: &Op) -> Option<u8> { if let Op::Xmm(x) = o { Some(*x) } else { None } }

    fn target(&self, o: &Op) -> Result<Tg, String> {
        match o { Op::Imm(e) => Ok(Tg::E(e.clone())), _ => Err("ARM64: bad branch target".into()) }
    }

    fn call_seq(&mut self, t: Option<Tg>, reg: u8) {
        // push the return address on the emulated stack, then branch
        self.w(e_adr(LR, 12));
        self.w(e_ldst_9(3, false, 0, LR, XSP, -8, 3));
        // bl/blr set x30 to the same return address and feed the return
        // predictor; the emulated stack slot stays authoritative.
        match t { Some(t) => self.out.push(AI::B { link: true, t }), None => self.w(e_blr(reg)) }
    }

    fn cond_branch(&mut self, cd: Cd, t: Tg) {
        match cd {
            Cd::One(c) => self.out.push(AI::Bc { c, t }),
            Cd::Never => {}
            Cd::Always => self.out.push(AI::B { link: false, t }),
            Cd::EqOrVs => { self.out.push(AI::Bc { c: EQ, t: t.clone() }); self.out.push(AI::Bc { c: VS, t }); }
            Cd::NeAndVc => { self.w(e_bc(EQ, 12)); self.w(e_bc(VS, 8)); self.out.push(AI::B { link: false, t }); }
        }
    }

    fn cset(&mut self, cd: Cd, rd: u8) {
        match cd {
            Cd::One(c) => self.w(e_cset(rd, c)),
            Cd::Never => self.w(e_movw(false, 2, rd, 0, 0)),
            Cd::Always => self.w(e_movw(false, 2, rd, 1, 0)),
            Cd::EqOrVs => { self.w(e_cset(rd, EQ)); self.w(e_cset(T4, VS)); self.w(e_log_reg(false, 1, false, rd, rd, T4, 0, 0)); }
            Cd::NeAndVc => { self.w(e_cset(rd, NE)); self.w(e_cset(T4, VC)); self.w(e_log_reg(false, 0, false, rd, rd, T4, 0, 0)); }
        }
    }

    // The Linux system call number in rax, when a constant reaches the
    // syscall on straight-line code (no label in between); None = dynamic.
    fn syscall_number(&self, i: usize) -> Option<u64> {
        let lo = i.saturating_sub(12);
        let mut last_lab: Option<usize> = None; // highest text label position in (lo, i]
        let mut see = |l: &Loc| if l.sec == Sec::Text && l.idx > lo && l.idx <= i { last_lab = Some(last_lab.map_or(l.idx, |m: usize| m.max(l.idx))); };
        for l in self.a.p.labels.values() { see(l); }
        for v in self.a.p.numlabels.values() { for (_, l) in v { see(l); } }
        let labelled = |k: usize| last_lab.map_or(false, |m| m > k);
        for k in (lo..i).rev() {
            if let TItem::Ins { mnem, ops, .. } = &self.a.text[k] {
                let writes_rax = match ops.last() { Some(Op::Reg(0, _, _)) => true, _ => false };
                if writes_rax || mnem.starts_with('j') || mnem == "call" || mnem == "ret" || mnem == "syscall" {
                    if labelled(k) { return None; }
                    if ops.len() == 2 && (mnem == "mov" || mnem == "movl" || mnem == "movq") {
                        if let (Op::Imm(e), Op::Reg(0, 32 | 64, false)) = (&ops[0], &ops[1]) { return self.cval(e).map(|v| v as u64); }
                    }
                    return None;
                }
            }
        }
        None
    }

    fn syscall(&mut self, i: usize) -> Result<(), String> {
        let n = self.syscall_number(i);
        if let Some(raw) = n.filter(|v| *v >= 0x200_0000 && *v < 0x200_1000) {
            // runtime pseudo form: Darwin BSD call number raw, no conversion
            if self.live[i] { self.w(e_mrs_nzcv(T4)); }
            for (k, src) in [14u8, 13, 11, 21, 19, 20].iter().enumerate() { self.w(e_mov(true, k as u8, *src)); }
            self.mov_imm(true, 16, raw - 0x200_0000);
            self.w(SVC80);
            self.w(e_csneg(true, 0, 0, 0, CC));
            self.w(e_mov(true, 9, 0));
            if self.live[i] { self.w(e_msr_nzcv(T4)); }
            return Ok(());
        }
        match n {
            Some(35) => {
                // Darwin has no BSD nanosleep syscall. In particular 334 is
                // __semwait_signal, NOT a timespec-pointer API. Use the stable
                // libSystem nanosleep ABI through a preserving wrapper.
                self.used_helpers.insert("__a64_nanosleep");
                self.out.push(AI::B { link: true, t: Tg::H("__a64_nanosleep") });
                return Ok(());
            }
            Some(158) => {
                // arch_prctl(ARCH_SET_FS, rsi): the %fs base register
                self.w(e_mov(true, FSR, 13));
                self.w(e_movw(true, 2, 9, 0, 0));
                return Ok(());
            }
            Some(56) => {
                if !self.threaded { return Err("ARM64: clone outside the thread runtime".into()); }
                self.used_helpers.insert("__a64_clone");
                self.used_helpers.insert("__a64_thread_tramp");
                self.out.push(AI::B { link: true, t: Tg::H("__a64_clone") });
                return Ok(());
            }
            Some(60) if self.threaded => {
                // Linux exit = this thread only; the stack may already be unmapped
                self.used_helpers.insert("__a64_exit_thread");
                self.out.push(AI::B { link: true, t: Tg::H("__a64_exit_thread") });
                return Ok(());
            }
            _ => {}
        }
        let mac = match n { Some(1) => 4, Some(231) => 1, Some(186) => 372, Some(2) => 5, Some(3) => 6, Some(9) => 197, Some(11) => 73, Some(60) => 1, Some(72) => 92, Some(96) => 116,
            Some(0) => 3, Some(8) => 199, Some(18) => 154, Some(83) => 136,
            _ => {
                // dynamic number or a call that needs argument/structure
                // conversion: the run-time dispatcher (x9 = Linux number)
                if self.live[i] { return Err("ARM64: flags live across a dispatched system call".into()); }
                self.w(e_addsub_imm(true, true, false, XSP, XSP, 128, false)); // keep the x86 red zone
                self.call_seq(Some(Tg::E(Expr(vec![(false, Term::Sym("__a64_linux_syscall".into()))]))), 0);
                self.w(e_addsub_imm(true, false, false, XSP, XSP, 128, false));
                return Ok(());
            } };
        let n = n.unwrap();
        if self.live[i] { self.w(e_mrs_nzcv(T4)); }
        for (k, src) in [14u8, 13, 11, 21, 19, 20].iter().enumerate() { self.w(e_mov(true, k as u8, *src)); }
        match n {
            9 => self.mov_imm(true, 3, 0x1002),
            2 => {
                // Linux open flags -> Darwin: CREAT 0x40->0x200, EXCL 0x80->0x800, TRUNC 0x200->0x400, APPEND 0x400->0x8
                self.w(e_log_imm(true, 0, 1, 13, bitmask_imm(3, true).unwrap()));
                for (from, to) in [(6u32, 9u8), (7, 11), (9, 10), (10, 3)] {
                    self.w(e_ubfx(true, T1, 13, from, 1));
                    self.w(e_log_reg(true, 1, false, 1, 1, T1, 0, to));
                }
            }
            96 => self.w(e_movw(true, 2, 2, 0, 0)),
            _ => {}
        }
        self.mov_imm(true, 16, mac);
        self.w(SVC80);
        self.w(e_csneg(true, 0, 0, 0, CC));
        if n == 96 {
            // legacy Darwin return: seconds in x0, usec in x1 when nonzero;
            // Darwin tv_usec is 32-bit, Linux readers load 64 bits.
            self.w(e_cbz(true, false, 0, 16));
            self.w(e_ldst_u(3, false, 0, 0, 14, 0));
            self.w(e_ldst_u(3, false, 0, 1, 14, 1));
            self.w(e_movw(true, 2, 0, 0, 0));
            self.w(e_ldst_u(2, false, 1, T1, 14, 2));
            self.w(e_ldst_u(3, false, 0, T1, 14, 1));
        }
        self.w(e_mov(true, 9, 0));
        if self.live[i] { self.w(e_msr_nzcv(T4)); }
        Ok(())
    }

    fn x87_idiom(&self, i: usize) -> Option<(usize, &'static str, Op, Op, Op)> {
        let get = |k: usize| -> Option<(&str, &Vec<Op>)> {
            match self.a.text.get(k)? { TItem::Ins { mnem, ops, .. } => Some((mnem.as_str(), ops)), _ => None }
        };
        let (m0, o0) = get(i)?;
        let (m1, o1) = get(i + 1)?;
        if m0 != "fldl" { return None; }
        let seq_exp = ["fld", "frndint", "fxch", "fsub", "f2xm1", "fld1", "faddp", "fscale", "fstp", "fstpl"];
        if seq_exp.iter().enumerate().all(|(k, m)| get(i + 1 + k).map(|g| g.0 == *m).unwrap_or(false)) {
            let (_, o) = get(i + 10)?;
            return Some((11, "_exp2", o0[0].clone(), o0[0].clone(), o[0].clone()));
        }
        if m1 != "fldl" { return None; }
        let seq_pow = ["fyl2x", "fld", "frndint", "fxch", "fsub", "f2xm1", "fld1", "faddp", "fscale", "fstp", "fstpl"];
        if seq_pow.iter().enumerate().all(|(k, m)| get(i + 2 + k).map(|g| g.0 == *m).unwrap_or(false)) {
            let (_, o) = get(i + 12)?;
            // st1 = first load (exponent), st0 = second load (base): base ^ exponent
            return Some((13, "_pow", o1[0].clone(), o0[0].clone(), o[0].clone()));
        }
        if get(i + 2).map(|g| g.0 == "fyl2x").unwrap_or(false) && get(i + 3).map(|g| g.0 == "fstpl").unwrap_or(false) {
            let (_, o) = get(i + 3)?;
            // st1 (first load) * log2(st0 (second load))
            return Some((4, "fyl2x", o1[0].clone(), o0[0].clone(), o[0].clone()));
        }
        let seq_rem = ["fprem", "fnstsw", "test", "jnz", "fstpl", "fstp"];
        if seq_rem.iter().enumerate().all(|(k, m)| get(i + 2 + k).map(|g| g.0 == *m).unwrap_or(false)) {
            let (_, o) = get(i + 6)?;
            // st0 = second load (dividend) rem st1 = first load (divisor)
            return Some((8, "_fmod", o1[0].clone(), o0[0].clone(), o[0].clone()));
        }
        None
    }

    // Symbol neither a label nor a constant: in an EXTERNAL program it is
    // provided by the extension dylib (bound at load time, ordinal 2).
    fn ext_symbol(&mut self, e: &Expr) -> Option<usize> {
        if !self.ext || e.0.len() != 1 { return None; }
        let name = match &e.0[0] { (false, Term::Sym(n)) => n, _ => return None };
        if self.a.p.labels.contains_key(name) || self.a.p.consts.contains_key(name) { return None; }
        let m: &'static str = Box::leak(format!("_{}", name).into_boxed_str());
        self.ext_imports.insert(m);
        Some(self.import(m))
    }

    fn import(&mut self, s: &'static str) -> usize {
        if let Some(p) = self.imports.iter().position(|x| *x == s) { return p; }
        self.imports.push(s);
        self.imports.len() - 1
    }

    // Locked read-modify-write and xchg with memory: LL/SC loop + full barrier.
    fn atomic(&mut self, i: usize, base: &str, ops: &[Op], w: u8) -> Result<(), String> {
        let x = w == 64;
        let need = self.need[i];
        let sz = (w / 8).trailing_zeros();
        let (mi, m) = match ops.iter().enumerate().find(|(_, o)| matches!(o, Op::Mem { .. })) { Some((k, m)) => (k, m.clone()), None => return Err("ARM64: atomic without memory".into()) };
        let (b, off) = self.maddr(&m, (w / 8) as u64)?;
        if off == 0 { if b != AX { self.w(e_mov(true, AX, b)); } }
        else if (0..4096).contains(&off) { self.w(e_addsub_imm(true, false, false, AX, b, off as u32, false)); }
        else { self.mov_imm(true, AX, off as u64); self.w(e_addsub_reg(true, false, false, AX, AX, b, 0, 0)); }
        let ldaxr = |rt: u8| sz << 30 | 0x085F_FC00 | r(AX) << 5 | r(rt);
        let stlxr = |rs: u8, rt: u8| sz << 30 | 0x0800_FC00 | r(rs) << 16 | r(AX) << 5 | r(rt);
        match base {
            "bts" | "btr" => {
                let n = match &ops[0] { Op::Imm(e) => self.cval(e).ok_or("ARM64: bt index")? as u32, _ => return Err("ARM64: locked bt form".into()) } & (w as u32 - 1);
                let bit = bitmask_imm(1u64 << n, x).unwrap();
                let nbit = bitmask_imm(!(1u64 << n) & if x { u64::MAX } else { 0xffff_ffff }, x).unwrap();
                self.w(ldaxr(T0));
                if base == "bts" { self.w(e_log_imm(x, 1, T1, T0, bit)); } else { self.w(e_log_imm(x, 0, T1, T0, nbit)); }
                self.w(stlxr(T3, T1));
                self.w(e_cbz(false, true, T3, -12));
                self.w(DMB_ISH);
                if need { self.w(e_log_imm(x, 3, ZR, T0, bit)); }
            }
            "inc" | "dec" | "add" | "sub" => {
                let sub = base == "dec" || base == "sub";
                let v = if base == "inc" || base == "dec" { None } else { Some(&ops[0]) };
                let imm = match v { None => Some(1i64), Some(Op::Imm(e)) => self.cval(e).filter(|c| (0..4096).contains(c)), _ => None };
                let src = if imm.is_none() { Some(self.val(v.unwrap(), w, T4)?) } else { None };
                self.w(ldaxr(T0));
                match (imm, src) {
                    (Some(c), _) => self.w(e_addsub_imm(x, sub, need, T1, T0, c as u32, false)),
                    (_, Some(sr)) => self.w(e_addsub_reg(x, sub, need, T1, T0, sr, 0, 0)),
                    _ => unreachable!(),
                }
                self.w(stlxr(T3, T1));
                self.w(e_cbz(false, true, T3, -12));
                self.w(DMB_ISH);
            }
            "xchg" => {
                let rg = match &ops[1 - mi] { Op::Reg(c, _, false) => RMAP[*c as usize], _ => return Err("ARM64: xchg register".into()) };
                self.w(ldaxr(T0));
                self.w(stlxr(T3, rg));
                self.w(e_cbz(false, true, T3, -8));
                self.w(DMB_ISH);
                self.w(e_mov(x, rg, T0));
            }
            "cmpxchg" => {
                let rg = match &ops[0] { Op::Reg(c, _, false) => RMAP[*c as usize], _ => return Err("ARM64: cmpxchg register".into()) };
                self.w(ldaxr(T0));
                self.w(e_addsub_reg(x, true, true, ZR, T0, 9, 0, 0));
                self.w(e_bc(NE, 16));
                self.w(stlxr(T3, rg));
                self.w(e_cbz(false, true, T3, -16));
                self.w(e_b(8));
                self.w(0xD503_305F); // clrex
                self.w(DMB_ISH);
                self.w(e_addsub_reg(x, true, true, ZR, 9, T0, 0, 0)); // ZF: rax == old
                self.w(e_mov(x, 9, T0));
            }
            _ => return Err(format!("ARM64: locked {} is not translated", base)),
        }
        Ok(())
    }

    fn ins(&mut self, i: usize, mnem: &str, ops: &[Op]) -> Result<usize, String> {
        let locked = matches!(&self.a.text[i], TItem::Ins { lock: true, .. });
        {
            let (b0, sw0) = base_of(mnem);
            let xmem = b0 == "xchg" && ops.iter().any(|o| matches!(o, Op::Mem { .. }));
            if locked || xmem {
                let w = sw0.or_else(|| reg_width(ops)).unwrap_or(64);
                self.atomic(i, b0, ops, w)?;
                return Ok(1);
            }
            if b0 == "pause" { self.w(0xD503_203F); return Ok(1); } // yield
            if b0 == "mfence" { self.w(DMB_ISH); return Ok(1); }
        }
        if mnem == "fldl" {
            let (n, f, a, b, d) = self.x87_idiom(i).ok_or("ARM64: x87 sequence is not a known idiom")?;
            // d = f(a, b) through libSystem
            let (ba, oa) = self.maddr(&a, 8)?; self.ldst(8, true, 1, FT0, ba, oa);
            let (bb, ob) = self.maddr(&b, 8)?; self.ldst(8, true, 1, FT1, bb, ob);
            if f == "fyl2x" {
                self.used_helpers.insert("__a64_fyl2x");
                self.used_helpers.insert("__a64_ccall2");
                self.out.push(AI::B { link: true, t: Tg::H("__a64_fyl2x") });
            } else {
                let g = self.import(f);
                self.out.push(AI::Adr { rd: T1, t: Tg::Got(g) });
                self.used_helpers.insert("__a64_ccall2");
                self.out.push(AI::B { link: true, t: Tg::H("__a64_ccall2") });
            }
            let (bd, od) = self.maddr(&d, 8)?; self.ldst(8, true, 0, FT0, bd, od);
            return Ok(n);
        }
        let renamed;
        let mnem = if (mnem == "movzx" || mnem == "movsx") && ops.len() == 2 {
            let sw = match &ops[0] { Op::Reg(_, w, _) => *w, _ => return Err("ARM64: movzx/movsx memory source needs a suffix".into()) };
            let dw = match &ops[1] { Op::Reg(_, w, _) => *w, _ => 64 };
            renamed = format!("mov{}{}{}", if mnem == "movzx" { "z" } else { "s" }, if sw == 8 { "b" } else { "w" }, match dw { 64 => "q", 32 => "l", _ => "w" });
            renamed.as_str()
        } else { mnem };
        let (base, sw) = base_of(mnem);
        let w = sw.or_else(|| reg_width(ops)).unwrap_or(64);
        let x = w == 64;
        let need = self.need[i];
        match base {
            "nop" | "endbr64" => {}
            "ud2" => self.w(0xD420_0020), // brk #1
            "ror" | "rol" => {
                let n = match &ops[0] { Op::Imm(e) => self.cval(e).ok_or("ARM64: rotate count")? as u32, _ => return Err("ARM64: variable rotate".into()) };
                if need { return Err("ARM64: flags of a rotate".into()); }
                let a = self.val(&ops[1], w, T0)?;
                if w == 16 && n & 15 == 8 {
                    self.w(e_ubfx(false, T0, a, 0, 16));
                    self.w(0x5AC0_0400 | r(T0) << 5 | r(T0)); // rev16
                    self.put(&ops[1], w, T0)?;
                } else if w >= 32 {
                    let bits = w as u32;
                    let n = n & (bits - 1);
                    let rr = if base == "ror" { n } else { (bits - n) % bits };
                    let direct = matches!(ops[1], Op::Reg(..));
                    let d = if direct { a } else { T0 };
                    self.w(if x { 0x93C0_0000 } else { 0x1380_0000 } | r(a) << 16 | rr << 10 | r(a) << 5 | r(d));
                    if !direct { self.put(&ops[1], w, d)?; }
                } else { return Err("ARM64: narrow rotate".into()); }
            }
            "bswap" => match &ops[0] {
                Op::Reg(c, 64, false) => { let d = RMAP[*c as usize]; self.w(0xDAC0_0C00 | r(d) << 5 | r(d)); }
                Op::Reg(c, 32, false) => { let d = RMAP[*c as usize]; self.w(0x5AC0_0800 | r(d) << 5 | r(d)); }
                _ => return Err("ARM64: bswap form".into()),
            },
            "mov" | "movabs" | "movq" if ops.iter().any(|o| matches!(o, Op::Xmm(_))) => {
                match (&ops[0], &ops[1]) {
                    (Op::Xmm(s), Op::Xmm(d)) => self.w(e_fmov(*d, *s)),
                    (Op::Reg(c, _, false), Op::Xmm(d)) => self.w(e_fmov_from_x(*d, RMAP[*c as usize])),
                    (Op::Xmm(s), Op::Reg(c, _, false)) => self.w(e_fmov_to_x(RMAP[*c as usize], *s)),
                    (m @ Op::Mem { .. }, Op::Xmm(d)) => { let (b, o) = self.maddr(m, 8)?; self.ldst(8, true, 1, *d, b, o); }
                    (Op::Xmm(s), m @ Op::Mem { .. }) => { let (b, o) = self.maddr(m, 8)?; self.ldst(8, true, 0, *s, b, o); }
                    _ => return Err("ARM64: movq form".into()),
                }
            }
            "mov" | "movabs" | "movq" => {
                let w = if base == "movq" { 64 } else { w };
                match (&ops[0], &ops[1]) {
                    (Op::Imm(e), Op::Mem { .. }) => {
                        let src = match self.cval(e) {
                            Some(0) => ZR,
                            Some(v) => { self.mov_imm(w == 64, T1, v as u64); T1 }
                            None => { if w != 64 { return Err("ARM64: 32-bit absolute address store".into()); } self.out.push(AI::Adr { rd: T1, t: Tg::E(e.clone()) }); T1 }
                        };
                        self.put(&ops[1], w, src)?;
                    }
                    (Op::Imm(e), Op::Reg(c, rw, false)) if *rw >= 32 => {
                        let d = RMAP[*c as usize];
                        match self.cval(e) {
                            Some(v) => self.mov_imm(*rw == 64, d, v as u64),
                            // non-PIC code (gcc blobs) loads absolute addresses with a
                            // 32-bit move: the address is zero-extended there, here it is 64-bit
                            None => self.out.push(AI::Adr { rd: d, t: Tg::E(e.clone()) }),
                        }
                    }
                    (Op::Mem { .. }, Op::Reg(c, rw, false)) if *rw >= 32 => {
                        let (b, o) = self.maddr(&ops[0], (*rw / 8) as u64)?;
                        self.ldst((*rw / 8) as u64, false, 1, RMAP[*c as usize], b, o);
                    }
                    (s, d) => { let v = self.val(s, w, T1)?; self.put(d, w, v)?; }
                }
            }
            "movzbl" | "movzbq" | "movzwl" | "movsbq" | "movslq" | "movsbl" | "movzwq" | "movswq" | "movswl" | "movzbw" => {
                let (sw, signed) = match base { "movzbl" | "movzbq" | "movzbw" => (8u64, false), "movzwl" | "movzwq" => (16, false),
                    "movsbq" | "movsbl" => (8, true), "movswq" | "movswl" => (16, true), _ => (32, true) };
                let dst32 = matches!(base, "movsbl" | "movswl");
                let d = match &ops[1] { Op::Reg(c, _, false) => RMAP[*c as usize], _ => return Err("ARM64: movzx dst".into()) };
                match &ops[0] {
                    m @ Op::Mem { .. } => { let (b, o) = self.maddr(m, sw / 8)?; self.ldst(sw / 8, false, if signed { if dst32 { 3 } else { 2 } } else { 1 }, d, b, o); }
                    s => {
                        let v = self.val(s, sw as u8, T1)?;
                        if signed { self.w(e_sbfx(!dst32, d, v, 0, sw as u32)); } else { self.w(e_ubfx(true, d, v, 0, sw as u32)); }
                    }
                }
            }
            "lea" => {
                let (b, o) = self.maddr(&ops[0], 1)?;
                let d = match &ops[1] { Op::Reg(c, _, false) => RMAP[*c as usize], _ => return Err("ARM64: lea dst".into()) };
                self.add_imm(d, b, o);
                if w == 32 { self.w(e_mov(false, d, d)); }
            }
            "push" => { let v = self.val(&ops[0], 64, T1)?; self.w(e_ldst_9(3, false, 0, v, XSP, -8, 3)); }
            "pop" => {
                match &ops[0] { Op::Reg(c, 64, false) => self.w(e_ldst_9(3, false, 1, RMAP[*c as usize], XSP, 8, 1)),
                    _ => { self.w(e_ldst_9(3, false, 1, T1, XSP, 8, 1)); self.put(&ops[0], 64, T1)?; } }
            }
            "leave" => { self.w(e_mov(true, XSP, 29)); self.w(e_ldst_9(3, false, 1, 29, XSP, 8, 1)); }
            "ret" => { self.w(e_ldst_9(3, false, 1, LR, XSP, 8, 1)); self.w(RET); }
            "call" => match &ops[0] {
                Op::Imm(e) if self.ext && self.cval(e).is_none() && self.ext_symbol(e).is_some() => {
                    let g = self.ext_symbol(e).unwrap();
                    self.out.push(AI::Adr { rd: T1, t: Tg::Got(g) });
                    self.used_helpers.insert("__a64_cout");
                    self.out.push(AI::B { link: true, t: Tg::H("__a64_cout") });
                }
                Op::Imm(_) => { let t = self.target(&ops[0])?; self.call_seq(Some(t), 0); }
                Op::Star(inner) => { let v = self.val(inner, 64, T1)?; self.call_seq(None, v); }
                _ => return Err("ARM64: call form".into()),
            },
            "jmp" => match &ops[0] {
                Op::Imm(_) => { let t = self.target(&ops[0])?; self.out.push(AI::B { link: false, t }); }
                Op::Star(inner) => { let v = self.val(inner, 64, T1)?; self.w(e_br(v)); }
                _ => return Err("ARM64: jmp form".into()),
            },
            "syscall" => self.syscall(i)?,
            "rep movsb" => {
                self.w(e_cbz(true, false, 10, 20));
                self.w(e_ldst_9(0, false, 1, T0, 13, 1, 1));
                self.w(e_ldst_9(0, false, 0, T0, 14, 1, 1));
                self.w(e_addsub_imm(true, true, false, 10, 10, 1, false));
                self.w(e_b(-16));
            }
            "rep movsq" | "rep movsl" | "rep movsw" => {
                let (sz, step) = match base { "rep movsq" => (3u32, 8i64), "rep movsl" => (2, 4), _ => (1, 2) };
                self.w(e_cbz(true, false, 10, 20));
                self.w(e_ldst_9(sz, false, 1, T0, 13, step, 1));
                self.w(e_ldst_9(sz, false, 0, T0, 14, step, 1));
                self.w(e_addsub_imm(true, true, false, 10, 10, 1, false));
                self.w(e_b(-16));
            }
            "rep stosq" => {
                self.w(e_cbz(true, false, 10, 16));
                self.w(e_ldst_9(3, false, 0, 9, 14, 8, 1));
                self.w(e_addsub_imm(true, true, false, 10, 10, 1, false));
                self.w(e_b(-12));
            }
            "rep stosb" => {
                self.w(e_cbz(true, false, 10, 16));
                self.w(e_ldst_9(0, false, 0, 9, 14, 1, 1));
                self.w(e_addsub_imm(true, true, false, 10, 10, 1, false));
                self.w(e_b(-12));
            }
            "cmp" | "sub" | "add" | "and" | "or" | "xor" | "test" => self.alu(base, ops, w, need)?,
            "inc" | "dec" => {
                let one = Op::Imm(Expr(vec![(false, Term::Num(1))]));
                self.alu(if base == "inc" { "add" } else { "sub" }, &[one, ops[0].clone()], w, need)?;
            }
            "neg" | "not" => {
                let direct = matches!(ops[0], Op::Reg(_, 32 | 64, false));
                let a = self.val(&ops[0], w, T0)?;
                let d = if direct { a } else { T0 };
                if base == "not" { self.w(e_log_reg(x || w < 32, 1, true, d, ZR, a, 0, 0)); }
                else if w >= 32 { self.w(e_addsub_reg(x, true, need, d, ZR, a, 0, 0)); }
                else {
                    if need { self.w(e_addsub_reg(false, true, true, ZR, ZR, a, 0, (32 - w) as u8)); }
                    self.w(e_addsub_reg(false, true, false, d, ZR, a, 0, 0));
                }
                if !direct { self.put(&ops[0], w, d)?; }
            }
            "shl" | "sal" | "shr" | "sar" => {
                if let (Op::Reg(1, 8, false), true) = (&ops[0], ops.len() == 2) {
                    // shift by %cl: ARM lslv/lsrv/asrv mask the count like x86 (mod 32/64)
                    let w = match &ops[1] { Op::Reg(_, rw, _) => *rw, _ => sw.unwrap_or(64) };
                    let x = w == 64;
                    if w < 32 { return Err("ARM64: narrow variable shift".into()); }
                    if need { return Err("ARM64: flags of a variable shift".into()); }
                    let a = self.val(&ops[1], w, T0)?;
                    let direct = matches!(ops[1], Op::Reg(..));
                    let d = if direct { a } else { T0 };
                    let op = match base { "shr" => 0x1AC0_2400u32, "sar" => 0x1AC0_2800, _ => 0x1AC0_2000 };
                    self.w(sf(x) | op | r(RMAP[1]) << 16 | r(a) << 5 | r(d));
                    if !direct { self.put(&ops[1], w, d)?; }
                    return Ok(1);
                }
                let n = match &ops[0] { Op::Imm(e) => self.cval(e).ok_or("ARM64: shift count")? as u32, _ => return Err("ARM64: variable shift".into()) };
                if w < 32 {
                    // 8/16-bit: x86 masks the count to 5 bits; work on the extended value
                    if need { return Err("ARM64: flags of a narrow shift".into()); }
                    let n = n & 31;
                    let a = self.val(&ops[1], w, T0)?;
                    if base == "sar" { self.w(e_sbfx(false, T0, a, 0, w as u32)); } else { self.w(e_ubfx(false, T0, a, 0, w as u32)); }
                    match base { "shr" => self.w(e_lsr(false, T0, T0, n)), "sar" => self.w(e_asr(false, T0, T0, n)), _ => self.w(e_lsl(false, T0, T0, n)) }
                    self.put(&ops[1], w, T0)?;
                    return Ok(1);
                }
                let a = self.val(&ops[1], w, T0)?;
                let direct = matches!(ops[1], Op::Reg(..));
                let d = if direct { a } else { T0 };
                let n = n & if x { 63 } else { 31 };
                match base { "shr" => self.w(e_lsr(x, d, a, n)), "sar" => self.w(e_asr(x, d, a, n)), _ => self.w(e_lsl(x, d, a, n)) }
                if need { self.w(e_log_reg(x, 3, false, ZR, d, d, 0, 0)); }
                if !direct { self.put(&ops[1], w, d)?; }
            }
            "imul" => {
                let (src, s2, dst) = match ops.len() { 1 => {
                    // rdx:rax = rax * src (signed)
                    if !x || need { return Err("ARM64: one-operand imul form".into()); }
                    let s = self.val(&ops[0], 64, T1)?;
                    self.w(0x9B40_7C00 | r(s) << 16 | r(9) << 5 | r(T0)); // smulh
                    self.w(e_madd(true, false, 9, 9, s, ZR));
                    self.w(e_mov(true, 11, T0));
                    return Ok(1);
                }
                    2 => (&ops[0], &ops[1], &ops[1]), _ => (&ops[0], &ops[1], &ops[2]) };
                let a = self.val(src, w, T1)?;
                let b = self.val(s2, w, T0)?;
                let d = match dst { Op::Reg(c, _, false) => RMAP[*c as usize], _ => return Err("ARM64: imul dst".into()) };
                if need {
                    if x { self.w(e_smulh(T3, a, b)); } else { self.w(e_smull(T3, a, b)); }
                }
                self.w(e_madd(x, false, d, a, b, ZR));
                if need {
                    if x { self.w(e_addsub_reg(true, true, true, ZR, T3, d, 2, 63)); }
                    else { self.w(e_addsub_ext(true, true, true, ZR, T3, T3, 6, 0)); }
                }
            }
            "div" => {
                let s = self.val(&ops[0], w, T4)?;
                if s != T4 { self.w(e_mov(true, T4, s)); }
                let s = T4;
                if x {
                    self.w(e_cbz(true, true, 11, 20));
                    self.w(e_udiv(true, T0, 9, s));
                    self.w(e_madd(true, true, 11, T0, s, 9));
                    self.w(e_mov(true, 9, T0));
                    self.w(e_b(12));
                    self.w(e_mov(true, T1, s));
                    self.used_helpers.insert("__a64_udiv128");
                    self.out.push(AI::B { link: true, t: Tg::H("__a64_udiv128") });
                } else {
                    self.w(e_mov(false, T4, s));
                    self.w(e_mov(false, T0, 9));
                    self.w(e_log_reg(true, 1, false, T0, T0, 11, 0, 32));
                    self.w(e_udiv(true, T1, T0, T4));
                    self.w(e_madd(true, true, T2, T1, T4, T0));
                    self.w(e_mov(false, 9, T1));
                    self.w(e_mov(false, 11, T2));
                }
            }
            "bt" if matches!(ops[0], Op::Reg(_, 64, false)) => {
                // CF = bit (index mod 64) of the destination
                let (ix, d) = match (&ops[0], &ops[1]) { (Op::Reg(a, 64, false), Op::Reg(b, 64, false)) => (RMAP[*a as usize], RMAP[*b as usize]),
                    _ => return Err("ARM64: bt form".into()) };
                self.w(0x9AC0_2400 | r(ix) << 16 | r(d) << 5 | r(T0)); // lsrv
                self.w(e_log_imm(true, 3, ZR, T0, bitmask_imm(1, true).unwrap()));
            }
            "bt" | "bts" | "btr" => {
                let n = match &ops[0] { Op::Imm(e) => self.cval(e).ok_or("ARM64: bt index")? as u32, _ => return Err("ARM64: bt form".into()) };
                if w < 32 { return Err("ARM64: narrow bt".into()); }
                let n = n & if x { 63 } else { 31 };
                let (d, mem) = match &ops[1] {
                    Op::Reg(c, _, false) => (RMAP[*c as usize], false),
                    m @ Op::Mem { .. } => { let v = self.val(m, w, T0)?; (v, true) }
                    _ => return Err("ARM64: bt dst".into()),
                };
                let bit = bitmask_imm(1u64 << n, x).unwrap();
                if base == "bt" || need { self.w(e_log_imm(x, 3, ZR, d, bit)); }
                if base == "bts" { self.w(e_log_imm(x, 1, d, d, bit)); }
                if base == "btr" { self.w(e_log_imm(x, 0, d, d, bitmask_imm(!(1u64 << n) & if x { u64::MAX } else { 0xffff_ffff }, x).unwrap())); }
                if mem && base != "bt" { self.put(&ops[1], w, d)?; }
            }
            "movdqu" | "movups" | "movdqa" | "movaps" | "movapd" | "movupd" => match (&ops[0], &ops[1]) {
                (Op::Xmm(s), Op::Xmm(d)) => self.w(0x4EA0_1C00 | r(*s) << 16 | r(*s) << 5 | r(*d)),
                (m @ Op::Mem { .. }, Op::Xmm(d)) => { let (b, o) = self.maddr(m, 16)?; self.ldst(16, true, 1, *d, b, o); }
                (Op::Xmm(s), m @ Op::Mem { .. }) => { let (b, o) = self.maddr(m, 16)?; self.ldst(16, true, 0, *s, b, o); }
                _ => return Err("ARM64: movdqu form".into()),
            },
            "pxor" | "pand" | "por" | "pcmpgtb" | "pcmpeqb" | "xorps" | "andpd" | "andnpd" | "orpd" => {
                let d = Self::xmm(&ops[1]).ok_or("ARM64: simd dst")?;
                let s = match &ops[0] { Op::Xmm(s) => *s,
                    m @ Op::Mem { .. } => { let (b, o) = self.maddr(m, 16)?; self.ldst(16, true, 1, FT0, b, o); FT0 }
                    _ => return Err("ARM64: simd src".into()) };
                let rr = |op: u32, n: u8, m: u8| op | r(m) << 16 | r(n) << 5 | r(d);
                match base {
                    "pxor" | "xorps" if s == d => self.w(0x6F00_E400 | r(d)),
                    "pxor" | "xorps" => self.w(rr(0x6E20_1C00, d, s)),
                    "pand" | "andpd" => self.w(rr(0x4E20_1C00, d, s)),
                    "andnpd" => self.w(rr(0x4E60_1C00, s, d)), // (~d) & s  ==  bic s, d
                    "por" | "orpd" => self.w(rr(0x4EA0_1C00, d, s)),
                    "pcmpgtb" => self.w(rr(0x4E20_3400, d, s)),
                    _ => self.w(rr(0x6E20_8C00, d, s)), // cmeq
                }
            }
            "pshufd" => {
                let m = match &ops[0] { Op::Imm(e) => self.cval(e).ok_or("ARM64: pshufd imm")?, _ => return Err("ARM64: pshufd".into()) };
                let s = Self::xmm(&ops[1]).ok_or("ARM64: pshufd")?;
                let d = Self::xmm(&ops[2]).ok_or("ARM64: pshufd")?;
                if m != 0 { return Err("ARM64: pshufd only broadcasts lane 0".into()); }
                self.w(0x4E04_0400 | r(s) << 5 | r(d));
            }
            "sbb" => {
                let k = self.ckind[i].ok_or("ARM64: sbb without producer")?;
                if k != FK::Sub { return Err(format!("ARM64: sbb after {:?} flags", k)); }
                if w < 32 { return Err("ARM64: narrow sbb".into()); }
                let a = match &ops[1] { Op::Reg(c, _, false) => RMAP[*c as usize], _ => return Err("ARM64: sbb dst".into()) };
                let b = match &ops[0] { Op::Imm(e) => { let v = self.cval(e).ok_or("ARM64: sbb imm")?; self.mov_imm(x, T1, v as u64); T1 }
                    o => self.val(o, w, T1)? };
                self.w(sf(x) | 0x5A00_0000 | if need { 0x2000_0000 } else { 0 } | r(b) << 16 | r(a) << 5 | r(a));
            }
            "adc" => {
                // x86 CF: borrow after a subtract (ARM C clear), carry after an add (ARM C set)
                let c = match self.ckind[i] { Some(FK::Sub) => CC, Some(FK::Add) => CS, k => return Err(format!("ARM64: adc after {:?} flags", k)) };
                if need { return Err("ARM64: flags of adc".into()); }
                if w < 32 { return Err("ARM64: narrow adc".into()); }
                let a = match &ops[1] { Op::Reg(c, _, false) => RMAP[*c as usize], _ => return Err("ARM64: adc dst".into()) };
                self.w(e_cset(T2, c));
                let b = match &ops[0] { Op::Imm(e) => { let v = self.cval(e).ok_or("ARM64: adc imm")?; self.mov_imm(x, T1, v as u64); T1 }
                    o => self.val(o, w, T1)? };
                self.w(e_addsub_reg(x, false, false, a, a, b, 0, 0));
                self.w(e_addsub_reg(x, false, false, a, a, T2, 0, 0));
            }
            "mul" => {
                if !x { return Err("ARM64: 32-bit mul".into()); }
                let s = self.val(&ops[0], 64, T1)?;
                self.w(0x9BC0_7C00 | r(s) << 16 | r(9) << 5 | r(T0)); // umulh
                self.w(e_madd(true, false, 9, 9, s, ZR));
                self.w(e_mov(true, 11, T0));
                if need { self.w(e_addsub_reg(true, true, true, ZR, ZR, 11, 0, 0)); } // hi != 0 -> ne
            }
            "cqto" | "cqo" => self.w(e_asr(true, 11, 9, 63)),
            "cltq" | "cdqe" => self.w(e_sbfx(true, 9, 9, 0, 32)),
            "idiv" => {
                if !x { return Err("ARM64: 32-bit idiv".into()); }
                let s = self.val(&ops[0], 64, T4)?;
                self.w(sf(true) | 0x1AC0_0C00 | r(s) << 16 | r(9) << 5 | r(T0)); // sdiv
                self.w(e_madd(true, true, 11, T0, s, 9));
                self.w(e_mov(true, 9, T0));
            }
            "movd" => match (&ops[0], &ops[1]) {
                (Op::Reg(c, 32, false), Op::Xmm(d)) => self.w(0x1E27_0000 | r(RMAP[*c as usize]) << 5 | r(*d)),
                (Op::Xmm(s), Op::Reg(c, 32, false)) => self.w(0x1E26_0000 | r(*s) << 5 | r(RMAP[*c as usize])),
                _ => return Err("ARM64: movd form".into()),
            },
            "movsd" => match (&ops[0], &ops[1]) {
                (Op::Xmm(s), Op::Xmm(d)) => self.w(e_fmov(*d, *s)),
                (m @ Op::Mem { .. }, Op::Xmm(d)) => { let (b, o) = self.maddr(m, 8)?; self.ldst(8, true, 1, *d, b, o); }
                (Op::Xmm(s), m @ Op::Mem { .. }) => { let (b, o) = self.maddr(m, 8)?; self.ldst(8, true, 0, *s, b, o); }
                _ => return Err("ARM64: movsd form".into()),
            },
            "addsd" | "subsd" | "mulsd" | "divsd" | "ucomisd" | "comisd" => {
                let d = Self::xmm(&ops[1]).ok_or("ARM64: sse dst")?;
                let s = match &ops[0] { Op::Xmm(s) => *s,
                    m @ Op::Mem { .. } => { let (b, o) = self.maddr(m, 8)?; self.ldst(8, true, 1, FT0, b, o); FT0 }
                    _ => return Err("ARM64: sse src".into()) };
                match base { "addsd" => self.w(e_fop(F_ADD, d, d, s)), "subsd" => self.w(e_fop(F_SUB, d, d, s)),
                    "mulsd" => self.w(e_fop(F_MUL, d, d, s)), "divsd" => self.w(e_fop(F_DIV, d, d, s)), _ => self.w(e_fcmp(d, s)) }
            }
            "xorpd" => {
                let d = Self::xmm(&ops[1]).ok_or("ARM64: xorpd")?;
                let s = match &ops[0] { Op::Xmm(s) => *s,
                    m @ Op::Mem { .. } => { let (b, o) = self.maddr(m, 16)?; self.ldst(16, true, 1, FT0, b, o); FT0 }
                    _ => return Err("ARM64: xorpd src".into()) };
                if s == d { self.w(e_movi_d0(d)); } else { self.w(e_eor16b(d, d, s)); }
            }
            "cvtsi2sd" | "cvtsi2sdq" | "cvtsi2sdl" => {
                let d = Self::xmm(&ops[1]).ok_or("ARM64: cvtsi2sd")?;
                let sx = match &ops[0] { Op::Reg(_, rw, _) => *rw == 64, _ => base != "cvtsi2sdl" };
                let v = self.val(&ops[0], if sx { 64 } else { 32 }, T1)?;
                self.w(e_scvtf(sx, d, v));
            }
            "cvttsd2si" | "cvttsd2siq" => {
                let s = Self::xmm(&ops[0]).ok_or("ARM64: cvttsd2si")?;
                let (c, rw) = match &ops[1] { Op::Reg(c, rw, false) => (*c, *rw), _ => return Err("ARM64: cvttsd2si dst".into()) };
                let xx = rw == 64;
                let d = RMAP[c as usize];
                // x86 returns the "integer indefinite" MIN for NaN and out of
                // range; ARM saturates (MAX/MIN) and gives 0 for NaN. Fix up
                // without touching NZCV: MIN unless (ordered && T0 != MAX).
                self.w(e_fcvtzs(xx, T0, s));
                self.w(e_fcmeq(FT1, s, s));
                self.w(e_fmov_to_x(T1, FT1));                       // all ones iff ordered
                self.mov_imm(xx, T2, if xx { 1u64 << 63 } else { 1u64 << 31 });
                self.w(e_addsub_imm(xx, false, false, T3, T0, 1, false));
                self.w(e_log_reg(xx, 2, false, T3, T3, T2, 0, 0)); // 0 iff T0 == MAX
                self.w(e_addsub_reg(xx, true, false, T4, ZR, T3, 0, 0));
                self.w(e_log_reg(xx, 1, false, T4, T4, T3, 0, 0));
                self.w(e_asr(xx, T4, T4, if xx { 63 } else { 31 })); // all ones iff T0 != MAX
                self.w(e_log_reg(xx, 0, false, T4, T4, T1, 0, 0));
                self.w(e_log_reg(xx, 0, false, T0, T0, T4, 0, 0));
                self.w(e_log_reg(xx, 0, true, T2, T2, T4, 0, 0));
                self.w(e_log_reg(xx, 1, false, d, T0, T2, 0, 0));
            }
            "roundsd" => {
                let m = match &ops[0] { Op::Imm(e) => self.cval(e).ok_or("ARM64: roundsd mode")?, _ => return Err("ARM64: roundsd".into()) };
                let s = Self::xmm(&ops[1]).ok_or("ARM64: roundsd")?;
                let d = Self::xmm(&ops[2]).ok_or("ARM64: roundsd")?;
                let op = if m & 4 != 0 { 0x1E67_C000 } else { [0x1E64_4000, 0x1E65_4000, 0x1E64_C000, 0x1E65_C000][(m & 3) as usize] };
                self.w(op | r(s) << 5 | r(d));
            }
            _ if base.starts_with("set") => {
                let k = self.ckind[i].ok_or("ARM64: setcc without producer")?;
                let cd = map_cc(k, &base[3..])?;
                self.cset(cd, T0);
                self.put(&ops[0], 8, T0)?;
            }
            _ if base.starts_with("cmov") => {
                let k = self.ckind[i].ok_or("ARM64: cmov without producer")?;
                let c = match map_cc(k, &base[4..])? { Cd::One(c) => c, cd => {
                    // compound (FP parity) condition: materialize, then select on it
                    self.cset(cd, T2);
                    self.w(e_addsub_imm(true, true, true, ZR, T2, 0, false));
                    NE
                } };
                let s = self.val(&ops[0], w, T1)?;
                let d = match &ops[1] { Op::Reg(c, _, false) => RMAP[*c as usize], _ => return Err("ARM64: cmov dst".into()) };
                self.w(e_csel(x, d, s, d, c));
            }
            _ if base.starts_with('j') => {
                let k = self.ckind[i].ok_or_else(|| format!("ARM64: {} without flag producer", base))?;
                let cd = map_cc(k, &base[1..])?;
                let t = self.target(&ops[0])?;
                self.cond_branch(cd, t);
            }
            _ => return Err(format!("ARM64: instruction {} is not translated", mnem)),
        }
        Ok(1)
    }

    fn alu(&mut self, base: &str, ops: &[Op], w: u8, need: bool) -> Result<(), String> {
        let x = w == 64;
        let (src, dst) = (&ops[0], &ops[1]);
        let wide = w >= 32;
        let flag_only = base == "cmp" || base == "test";
        let direct = wide && matches!(dst, Op::Reg(_, _, false));
        let is_mem = matches!(dst, Op::Mem { .. });
        let a = if is_mem {
            let (b, o) = self.maddr(dst, (w / 8) as u64)?;
            self.ldst((w / 8) as u64, false, 1, T0, b, o);
            T0
        } else { self.val(dst, w, T0)? };
        let res = if flag_only { ZR } else if direct { a } else { T0 };
        let arith = matches!(base, "cmp" | "sub" | "add");
        let sub = base == "cmp" || base == "sub";
        let s_flag = need || flag_only;
        let mut done = false;
        if let (Op::Imm(e), true) = (src, wide) {
            if let Some(v) = self.cval(e) {
                let v = if x { v } else { v as i32 as i64 };
                if arith {
                    let (s2, m) = if v < 0 && v != i64::MIN { (!sub, v.unsigned_abs()) } else { (sub, v as u64) };
                    let enc = if m < 4096 { Some((m as u32, false)) } else if m & 0xfff == 0 && m < (1 << 24) { Some(((m >> 12) as u32, true)) } else { None };
                    if let Some((imm, sh)) = enc {
                        self.w(e_addsub_imm(x, s2, s_flag, res, a, imm, sh));
                        done = true;
                    }
                } else if let Some(enc) = bitmask_imm(v as u64, x) {
                    let opc = match base { "and" | "test" => if s_flag { 3 } else { 0 }, "or" => 1, _ => 2 };
                    self.w(e_log_imm(x, opc, res, a, enc));
                    if need && (base == "or" || base == "xor") { self.w(e_log_reg(x, 3, false, ZR, res, res, 0, 0)); }
                    done = true;
                }
            }
        }
        if !done {
            let b = match src {
                Op::Imm(e) if !wide => {
                    match self.cval(e) { Some(v) => { self.mov_imm(false, T1, v as u64 & if w == 8 { 0xff } else { 0xffff }); T1 }
                        None => return Err("ARM64: symbolic narrow immediate".into()) }
                }
                _ => self.val(src, w, T1)?,
            };
            if wide {
                if arith {
                    self.w(e_addsub_reg(x, sub, s_flag, res, a, b, 0, 0));
                } else {
                    let opc = match base { "and" | "test" => if s_flag { 3 } else { 0 }, "or" => 1, _ => 2 };
                    self.w(e_log_reg(x, opc, false, res, a, b, 0, 0));
                    if need && (base == "or" || base == "xor") { self.w(e_log_reg(x, 3, false, ZR, res, res, 0, 0)); }
                }
            } else {
                let sh = (32 - w) as u8;
                if arith {
                    if s_flag {
                        self.w(e_lsl(false, T2, a, sh as u32));
                        self.w(e_addsub_reg(false, sub, true, ZR, T2, b, 0, sh));
                    }
                    if !flag_only { self.w(e_addsub_reg(false, sub, false, res, a, b, 0, 0)); }
                } else {
                    let opc = match base { "and" | "test" => 0, "or" => 1, _ => 2 };
                    let rr = if flag_only { T2 } else { res };
                    self.w(e_log_reg(false, opc, false, rr, a, b, 0, 0));
                    if s_flag {
                        self.w(e_lsl(false, T2, rr, sh as u32));
                        self.w(e_log_reg(false, 3, false, ZR, T2, T2, 0, 0));
                    }
                }
            }
        }
        if flag_only { return Ok(()); }
        if is_mem {
            // the address registers may have been reused by the source; recompute
            let (b2, o2) = self.maddr(dst, (w / 8) as u64)?;
            self.ldst((w / 8) as u64, false, 0, res, b2, o2);
        } else if !direct { self.put(dst, w, res)?; }
        Ok(())
    }
}

// ------------------------------------------------------------------ flag analysis

fn analyze(a: &Asm) -> Result<(Vec<bool>, Vec<bool>, Vec<Option<FK>>), String> {
    // Backward search over the control-flow graph from every flag consumer:
    // predecessors are the fall-through item (unless it is jmp/ret) and every
    // jump whose target label sits at the position. Paths reaching a call or
    // another flag-killing instruction are dead for flag purposes (x86 code
    // never consumes flags across them; such edges only come from noreturn
    // calls). All producers found must agree on their kind.
    let n = a.text.len();
    let mut jsrc: Vec<Vec<usize>> = vec![Vec::new(); n + 1];
    let loc_of = |e: &Expr| -> Option<usize> {
        if e.0.len() != 1 { return None; }
        let l = match &e.0[0].1 {
            Term::Sym(s) => *a.p.labels.get(s)?,
            Term::Fwd(nl, seq) => a.resolve_num(*nl, true, *seq).ok()?,
            Term::Back(nl, seq) => a.resolve_num(*nl, false, *seq).ok()?,
            _ => return None,
        };
        if l.sec == Sec::Text { Some(l.idx) } else { None }
    };
    for (j, it) in a.text.iter().enumerate() {
        if let TItem::Ins { mnem, ops, .. } = it {
            if mnem.starts_with('j') {
                if let Some(Op::Imm(e)) = ops.first() { if let Some(t) = loc_of(e) { jsrc[t].push(j); } }
            }
        }
    }
    let ends_flow = |k: usize| -> bool {
        match &a.text[k] { TItem::Ins { mnem, .. } => mnem == "jmp" || mnem == "ret", _ => false }
    };
    let mut need = vec![false; n];
    let mut live = vec![false; n];
    let mut ck = vec![None; n];
    let mut seen = vec![0usize; n + 1];
    let mut stamp = 0usize;
    for i in 0..n {
        let m = match &a.text[i] { TItem::Ins { mnem, .. } => mnem.as_str(), _ => continue };
        let (base, _) = base_of(m);
        if consumer_cc(base).is_none() { continue; }
        stamp += 1;
        let mut kind: Option<FK> = None;
        let mut work = vec![i];
        let mut path = Vec::new();
        let mut steps = 0;
        seen[i] = stamp;
        while let Some(p) = work.pop() {
            steps += 1;
            if steps > 4000 { return Err(format!("ARM64: flag search too long at item {}", i)); }
            let mut preds: Vec<usize> = jsrc[p].clone();
            if p > 0 && !ends_flow(p - 1) { preds.push(p - 1); }
            for q in preds {
                if seen[q] == stamp { continue; }
                seen[q] = stamp;
                match &a.text[q] {
                    TItem::Ins { mnem, .. } => {
                        let (b, _) = base_of(mnem);
                        if let Some(fk) = setter_kind(b) {
                            if kind.map_or(false, |k0| k0 != fk) {
                                return Err(format!("ARM64: flag consumer {} at item {} has producers of different kinds", m, i));
                            }
                            kind = Some(fk);
                            need[q] = true;
                        } else if kills_flags(b) {
                            // dead path
                        } else {
                            path.push(q);
                            work.push(q);
                        }
                    }
                    _ => { path.push(q); work.push(q); }
                }
            }
        }
        let fk = kind.ok_or_else(|| format!("ARM64: flag consumer {} at item {} has no producer", m, i))?;
        ck[i] = Some(fk);
        for q in path { live[q] = true; }
    }
    Ok((need, live, ck))
}

// ------------------------------------------------------------------ runtime helpers

fn helper(name: &'static str, tr: &mut Tr) -> Vec<AI> {
    let mut v = vec![AI::Hl(name)];
    if name == "__a64_nanosleep" {
        let ns = tr.import("_nanosleep");
        let er = tr.import("___error");
        let mut t = Tr { a: tr.a, out: Vec::new(), need: Vec::new(), live: Vec::new(), ckind: Vec::new(), imports: Vec::new(), used_helpers: Default::default(), threaded: false, ext: false, ext_imports: Default::default() };
        // Native SP stays 16-byte aligned. Save every mapped caller-saved
        // GPR, the TLS/atomic scratch registers, NZCV and all 16 full XMM
        // registers. C preserves x19-x29, including the emulated RSP x28.
        t.w(e_addsub_imm(true, true, false, 31, 31, 352, false));
        for (k, (a,b)) in [(10u8,11u8),(12,13),(14,15),(FSR,AX),(LR,9)].iter().enumerate() {
            t.w(e_stp(true,false,false,*a,*b,31,(k*16) as i64));
        }
        t.w(e_mrs_nzcv(T0));
        t.ldst(8,false,0,T0,31,80);
        for q in 0..16u8 { t.ldst(16,true,0,q,31,96+16*q as i64); }
        t.w(e_mov(true,0,14)); // rqtp = emulated RDI
        t.w(e_mov(true,1,13)); // rmtp = emulated RSI
        t.out.push(AI::Adr { rd:T1, t:Tg::Got(ns) });
        t.ldst(8,false,1,T1,T1,0);
        t.w(e_blr(T1));
        // C int is w0 only. Clear unspecified upper x0 bits before the
        // success path can copy it to the 64-bit emulated RAX.
        t.w(e_mov(false,0,0));
        // libc returns 0 or -1 and sets errno, not BSD carry. Relevant
        // nanosleep errno values EINTR/EFAULT/EINVAL match Linux 4/14/22.
        // Other errno values pass through as Darwin numbers, NOT a
        // universal Linux mapping (Darwin ENOSYS=78, Linux=38).
        t.w(e_addsub_imm(false,false,true,ZR,0,0,false));
        t.out.push(AI::Bc { c:EQ, t:Tg::L(9052) });
        t.out.push(AI::Adr { rd:T1, t:Tg::Got(er) });
        t.ldst(8,false,1,T1,T1,0);
        t.w(e_blr(T1));
        t.ldst(4,false,1,0,0,0);
        t.w(e_addsub_reg(true,true,false,0,ZR,0,0,0));
        t.out.push(AI::Lab(9052));
        t.w(e_mov(true,9,0));
        for q in 0..16u8 { t.ldst(16,true,1,q,31,96+16*q as i64); }
        t.ldst(8,false,1,T0,31,80);
        t.w(e_msr_nzcv(T0));
        for (k, (a,b)) in [(10u8,11u8),(12,13),(14,15),(FSR,AX)].iter().enumerate() {
            t.w(e_stp(true,false,true,*a,*b,31,(k*16) as i64));
        }
        t.ldst(8,false,1,LR,31,64); // old RAX intentionally replaced
        t.w(e_addsub_imm(true,false,false,31,31,352,false));
        t.w(RET);
        v.extend(t.out);
        return v;
    }
    if name == "__a64_fyl2x" {
        // d16 = d17 * log2(d16); exact libm log/log10 when d17 is ln2/log10(2)
        let (glog, glog10, glog2) = (tr.import("_log"), tr.import("_log10"), tr.import("_log2"));
        let mut t = Tr { a: tr.a, out: Vec::new(), need: Vec::new(), live: Vec::new(), ckind: Vec::new(), imports: Vec::new(), used_helpers: Default::default(), threaded: false, ext: false, ext_imports: Default::default() };
        t.w(e_ldst_9(3, false, 0, LR, XSP, -8, 3));
        t.w(e_fmov_to_x(T0, FT1));
        for (bits, g, lab) in [(0x3FE6_2E42_FEFA_39EFu64, glog, 9001u32), (0x3FD3_4413_509F_79FF, glog10, 9002)] {
            t.mov_imm(true, T2, bits);
            t.w(e_addsub_reg(true, true, true, ZR, T0, T2, 0, 0));
            t.out.push(AI::Bc { c: NE, t: Tg::L(lab) });
            t.out.push(AI::Adr { rd: T1, t: Tg::Got(g) });
            t.out.push(AI::B { link: true, t: Tg::H("__a64_ccall2") });
            t.out.push(AI::B { link: false, t: Tg::L(9003) });
            t.out.push(AI::Lab(lab));
        }
        t.w(e_ldst_9(3, true, 0, FT1, XSP, -8, 3));
        t.out.push(AI::Adr { rd: T1, t: Tg::Got(glog2) });
        t.out.push(AI::B { link: true, t: Tg::H("__a64_ccall2") });
        t.w(e_ldst_9(3, true, 1, FT1, XSP, 8, 1));
        t.w(e_fop(F_MUL, FT0, FT0, FT1));
        t.out.push(AI::Lab(9003));
        t.w(e_ldst_9(3, false, 1, LR, XSP, 8, 1));
        t.w(RET);
        v.extend(t.out);
        return v;
    }
    if name == "__a64_cout" {
        // translated code -> C function at [x16] (SysV argument registers
        // -> AAPCS64). x86 callee-saved rbx and the %fs register are
        // caller-saved in C. The emulated stack pointer and %fs base are
        // published per thread (pthread TSD key __a64_tkey) for C -> hbc
        // callbacks; nested calls chain to and restore the previous record.
        let mut t = Tr { a: tr.a, out: Vec::new(), need: Vec::new(), live: Vec::new(), ckind: Vec::new(), imports: Vec::new(), used_helpers: Default::default(), threaded: false, ext: false, ext_imports: Default::default() };
        let (gg, gs) = (tr.import("_pthread_getspecific"), tr.import("_pthread_setspecific"));
        let key = Tg::E(Expr(vec![(false, Term::Sym("__a64_tkey".into()))]));
        let call = |t: &mut Tr, g: usize| {
            t.out.push(AI::Adr { rd: T2, t: Tg::Got(g) });
            t.w(e_ldst_u(3, false, 1, T2, T2, 0));
            t.w(e_blr(T2));
        };
        let ldkey = |t: &mut Tr| { t.out.push(AI::Adr { rd: 0, t: key.clone() }); t.w(e_ldst_u(3, false, 1, 0, 0, 0)); };
        // frame: [0] x29,x30 [16] x7,x12 [32] record {x28, x7} [48] prev, target [64] x14,x13 [80] x11,x10
        t.w(e_ldst_u(3, false, 1, T1, T1, 0));
        t.w(e_stp(true, false, false, 29, LR, 31, -96) | 0x0080_0000); // stp x29, x30, [sp, #-96]! (pre-index)
        t.w(e_stp(true, false, false, FSR, 12, 31, 16));
        t.w(e_stp(true, false, false, XSP, FSR, 31, 32));
        t.w(e_ldst_u(3, false, 0, T1, 31, 7));
        t.w(e_stp(true, false, false, 14, 13, 31, 64));
        t.w(e_stp(true, false, false, 11, 10, 31, 80));
        ldkey(&mut t); call(&mut t, gg);
        t.w(e_ldst_u(3, false, 0, 0, 31, 6));
        ldkey(&mut t); t.w(e_addsub_imm(true, false, false, 1, 31, 32, false)); call(&mut t, gs);
        t.w(e_ldst_u(3, false, 1, T1, 31, 7));
        t.w(e_stp(true, false, true, 14, 13, 31, 64));
        t.w(e_stp(true, false, true, 11, 10, 31, 80));
        for (k, src) in [14u8, 13, 11, 10, 19, 20].iter().enumerate() { t.w(e_mov(true, k as u8, *src)); }
        t.w(e_blr(T1));
        t.w(e_stp(true, false, false, 0, 1, 31, 64));
        ldkey(&mut t); t.w(e_ldst_u(3, false, 1, 1, 31, 6)); call(&mut t, gs);
        t.w(e_stp(true, false, true, 9, 11, 31, 64));
        t.w(e_stp(true, false, true, FSR, 12, 31, 16));
        t.w(e_stp(true, false, true, 29, LR, 31, 0));
        t.w(e_addsub_imm(true, false, false, 31, 31, 96, false));
        t.w(RET);
        v.extend(t.out);
        return v;
    }
    if let Some(target) = name.strip_prefix("__a64_cin_") {
        // C caller -> translated hbc function (AAPCS64 -> SysV registers),
        // on the emulated stack recorded by this thread's outgoing thunk.
        let mut t = Tr { a: tr.a, out: Vec::new(), need: Vec::new(), live: Vec::new(), ckind: Vec::new(), imports: Vec::new(), used_helpers: Default::default(), threaded: false, ext: false, ext_imports: Default::default() };
        let gg = tr.import("_pthread_getspecific");
        let key = Tg::E(Expr(vec![(false, Term::Sym("__a64_tkey".into()))]));
        t.w(e_stp(true, false, false, 29, LR, 31, -96) | 0x0080_0000);
        for (k, p) in [(19u8, 20u8), (21, 22), (23, 24), (25, 26), (27, 28)].iter().enumerate() { t.w(e_stp(true, false, false, p.0, p.1, 31, 16 + 16 * k as i64)); }
        for (dst, src) in [(21u8, 0u8), (22, 1), (23, 2), (24, 3), (19, 4), (20, 5)] { t.w(e_mov(true, dst, src)); }
        t.out.push(AI::Adr { rd: 0, t: key });
        t.w(e_ldst_u(3, false, 1, 0, 0, 0));
        t.out.push(AI::Adr { rd: T2, t: Tg::Got(gg) });
        t.w(e_ldst_u(3, false, 1, T2, T2, 0));
        t.w(e_blr(T2));
        t.w(e_stp(true, false, true, XSP, FSR, 0, 0));
        t.w(e_addsub_imm(true, true, false, XSP, XSP, 256, false)); // below the caller's red zone
        for (dst, src) in [(14u8, 21u8), (13, 22), (11, 23), (10, 24)] { t.w(e_mov(true, dst, src)); }
        t.call_seq(Some(Tg::E(Expr(vec![(false, Term::Sym(target.to_string()))]))), 0);
        t.w(e_mov(true, 0, 9));
        t.w(e_mov(true, 1, 11));
        for (k, p) in [(19u8, 20u8), (21, 22), (23, 24), (25, 26), (27, 28)].iter().enumerate() { t.w(e_stp(true, false, true, p.0, p.1, 31, 16 + 16 * k as i64)); }
        t.w(e_stp(true, false, true, 29, LR, 31, 0));
        t.w(e_addsub_imm(true, false, false, 31, 31, 96, false));
        t.w(RET);
        v.extend(t.out);
        return v;
    }
    if name == "__a64_clone" || name == "__a64_exit_thread" || name == "__a64_thread_tramp" {
        let mut t = Tr { a: tr.a, out: Vec::new(), need: Vec::new(), live: Vec::new(), ckind: Vec::new(), imports: Vec::new(), used_helpers: Default::default(), threaded: false, ext: false, ext_imports: Default::default() };
        let ctx_regs: [(u8, u8); 9] = [(FSR, 9), (10, 11), (12, 13), (14, 19), (20, 21), (22, 23), (24, 25), (26, 29), (LR, 13)];
        match name {
            "__a64_clone" => {
                // Linux clone(flags, child_stack): the child resumes after the
                // syscall with the parent's registers, rax = 0, rsp = child_stack.
                // Context lives just below the child stack top; the child reads
                // it before its first push.
                let (gc, gd) = (tr.import("_pthread_create"), tr.import("_pthread_detach"));
                t.w(e_addsub_imm(true, true, false, AX, 13, 256, false));
                for (k, p) in ctx_regs.iter().enumerate() { t.w(e_stp(true, false, false, p.0, p.1, AX, 16 * k as i64)); }
                t.w(e_addsub_imm(true, true, false, 31, 31, 96, false));
                for (k, p) in [(9u8, 10u8), (11, 12), (13, 14), (15, LR), (FSR, AX)].iter().enumerate() { t.w(e_stp(true, false, false, p.0, p.1, 31, 16 * k as i64)); }
                t.w(e_addsub_imm(true, false, false, 0, 31, 80, false));
                t.w(e_mov(true, 1, ZR));
                t.out.push(AI::Adr { rd: 2, t: Tg::H("__a64_thread_tramp") });
                t.w(e_mov(true, 3, AX));
                t.out.push(AI::Adr { rd: T1, t: Tg::Got(gc) });
                t.w(e_ldst_u(3, false, 1, T1, T1, 0));
                t.w(e_blr(T1));
                t.w(e_ldst_u(3, false, 0, 0, 31, 11)); // rc -> [sp+88]
                t.w(e_cbz(false, true, 0, 20));
                t.w(e_ldst_u(3, false, 1, 0, 31, 10)); // tid
                t.out.push(AI::Adr { rd: T1, t: Tg::Got(gd) });
                t.w(e_ldst_u(3, false, 1, T1, T1, 0));
                t.w(e_blr(T1));
                for (k, p) in [(9u8, 10u8), (11, 12), (13, 14), (15, LR), (FSR, AX)].iter().enumerate() { t.w(e_stp(true, false, true, p.0, p.1, 31, 16 * k as i64)); }
                t.w(e_ldst_u(3, false, 1, T0, 31, 11));
                t.w(e_movw(true, 2, 9, 1, 0));
                t.w(e_movw(true, 0, T1, 10, 0)); // -11 (EAGAIN)
                t.w(e_cmp_zero_w(T0));
                t.w(e_csel(true, 9, 9, T1, EQ));
                t.w(e_addsub_imm(true, false, false, 31, 31, 96, false));
                t.w(RET);
            }
            "__a64_thread_tramp" => {
                // pthread start routine, x0 = context; never returns
                t.w(e_mov(true, AX, 0));
                for (k, p) in ctx_regs.iter().enumerate() {
                    let (a0, a1) = if k == 8 { (T0, XSP) } else { *p };
                    t.w(e_stp(true, false, true, a0, a1, AX, 16 * k as i64));
                }
                t.w(e_movw(true, 2, 9, 0, 0));
                t.w(0xD61F_0000 | r(T0) << 5); // br
            }
            _ => {
                // Linux exit(2) ends the calling thread; the process exit when it is the main thread
                let (gm, ge) = (tr.import("_pthread_main_np"), tr.import("_pthread_exit"));
                t.w(e_mov(true, 19, 14));
                t.out.push(AI::Adr { rd: T1, t: Tg::Got(gm) });
                t.w(e_ldst_u(3, false, 1, T1, T1, 0));
                t.w(e_blr(T1));
                t.w(e_cbz(false, false, 0, 16));
                t.w(e_mov(true, 0, 19));
                t.w(e_movw(true, 2, 16, 1, 0));
                t.w(SVC80);
                t.w(e_mov(true, 0, ZR));
                t.out.push(AI::Adr { rd: T1, t: Tg::Got(ge) });
                t.w(e_ldst_u(3, false, 1, T1, T1, 0));
                t.w(e_blr(T1));
                t.w(0xD420_0020);
            }
        }
        v.extend(t.out);
        return v;
    }
    let mut w = |x: u32| v.push(AI::W(x));
    match name {
        "__a64_udiv128" => {
            // (x11:x9) / x16 -> x9 quotient, x11 remainder; quotient must fit 64 bits
            w(e_movw(true, 2, T3, 64, 0));
            w(e_lsr(true, T2, 11, 63));
            w(e_extr(11, 11, 9, 63));
            w(e_lsl(true, 9, 9, 1));
            w(e_addsub_reg(true, true, true, ZR, 11, T1, 0, 0));
            w(e_cset(T0, CS));
            w(e_log_reg(true, 1, false, T0, T0, T2, 0, 0));
            w(e_cbz(true, false, T0, 12));
            w(e_addsub_reg(true, true, false, 11, 11, T1, 0, 0));
            w(e_log_imm(true, 1, 9, 9, bitmask_imm(1, true).unwrap()));
            w(e_addsub_imm(true, true, true, T3, T3, 1, false));
            w(e_bc(NE, -40));
            w(RET);
        }
        "__a64_ccall2" => {
            // d16 = f(d16, d17), f = [x16]; preserves every mapped register
            w(e_addsub_imm(true, true, false, 31, 31, 144, false));
            w(e_stp(true, false, false, FSR, AX, 31, 128));
            let mut off = 0;
            for p in [(9u8, 10u8), (11, 12), (13, 14), (15, 30)] { w(e_stp(true, false, false, p.0, p.1, 31, off)); off += 16; }
            for p in [(0u8, 1u8), (2, 3), (4, 5), (6, 7)] { w(e_stp(true, true, false, p.0, p.1, 31, off)); off += 16; }
            w(e_fmov(0, FT0));
            w(e_fmov(1, FT1));
            w(e_ldst_u(3, false, 1, T1, T1, 0));
            w(e_blr(T1));
            w(e_fmov(FT0, 0));
            let mut off = 0;
            for p in [(9u8, 10u8), (11, 12), (13, 14), (15, 30)] { w(e_stp(true, false, true, p.0, p.1, 31, off)); off += 16; }
            for p in [(0u8, 1u8), (2, 3), (4, 5), (6, 7)] { w(e_stp(true, true, true, p.0, p.1, 31, off)); off += 16; }
            w(e_stp(true, false, true, FSR, AX, 31, 128));
            w(e_addsub_imm(true, false, false, 31, 31, 144, false));
            w(RET);
        }
        _ => unreachable!(),
    }
    v
}

// Darwin entry (LC_MAIN): x0 argc, x1 argv, x2 envp. Builds a Linux-style
// initial stack (argc, argv..., 0, envp..., 0, AT_NULL) on an mmap'ed
// emulated stack and jumps to the translated _start.
// key_create: GOT slot of pthread_key_create (EXTERNAL programs: the key
// of the per-thread emulated stack record used by the C ABI thunks).
fn entry_stub(scratch: &Asm, key_create: Option<usize>) -> Vec<AI> {
    let mut t = Tr { a: scratch, out: vec![AI::Hl("__a64_entry")], need: Vec::new(), live: Vec::new(), ckind: Vec::new(),
        imports: Vec::new(), used_helpers: Default::default(), threaded: false, ext: false, ext_imports: Default::default() };
    t.w(e_mov(true, 19, 0)); t.w(e_mov(true, 20, 1)); t.w(e_mov(true, 21, 2));
    if let Some(g) = key_create {
        t.out.push(AI::Adr { rd: 0, t: Tg::E(Expr(vec![(false, Term::Sym("__a64_tkey".into()))])) });
        t.w(e_mov(true, 1, ZR));
        t.out.push(AI::Adr { rd: T2, t: Tg::Got(g) });
        t.w(e_ldst_u(3, false, 1, T2, T2, 0));
        t.w(e_blr(T2));
    }
    t.w(e_movw(true, 2, 0, 0, 0));
    t.mov_imm(true, 1, ESTACK);
    t.w(e_movw(true, 2, 2, 3, 0));
    t.mov_imm(true, 3, 0x1002);
    t.w(e_movw(true, 0, 4, 0, 0));
    t.w(e_movw(true, 2, 5, 0, 0));
    t.mov_imm(true, 16, 197);
    t.w(SVC80);
    // on failure, exit(111)
    t.w(e_bc(CC, 16));
    t.w(e_movw(true, 2, 0, 111, 0));
    t.w(e_movw(true, 2, 16, 1, 0));
    t.w(SVC80);
    t.mov_imm(true, 1, ESTACK);
    t.w(e_addsub_reg(true, false, false, XSP, 0, 1, 0, 0));
    // envc -> x22
    t.w(e_movw(true, 2, 22, 0, 0));
    t.w(e_ldst_reg(3, 1, 23, 21, 22, true));
    t.w(e_cbz(true, false, 23, 12));
    t.w(e_addsub_imm(true, false, false, 22, 22, 1, false));
    t.w(e_b(-12));
    // slots = argc + envc + 5 ; x28 -= slots*8 ; align 16
    t.w(e_addsub_reg(true, false, false, 23, 19, 22, 0, 0));
    t.w(e_addsub_imm(true, false, false, 23, 23, 5, false));
    t.w(e_addsub_reg(true, true, false, XSP, XSP, 23, 0, 3));
    t.w(e_log_imm(true, 0, XSP, XSP, bitmask_imm(!15u64, true).unwrap()));
    // [x28] = argc ; copy argv (argc+1 incl NULL), envp (envc+1 incl NULL), then AT_NULL pair
    t.w(e_ldst_u(3, false, 0, 19, XSP, 0));
    t.w(e_addsub_imm(true, false, false, 24, XSP, 8, false));
    t.w(e_addsub_imm(true, false, false, 25, 19, 1, false));
    t.w(e_cbz(true, false, 25, 20));
    t.w(e_ldst_9(3, false, 1, 23, 20, 8, 1));
    t.w(e_ldst_9(3, false, 0, 23, 24, 8, 1));
    t.w(e_addsub_imm(true, true, false, 25, 25, 1, false));
    t.w(e_b(-16));
    t.w(e_addsub_imm(true, false, false, 25, 22, 1, false));
    t.w(e_cbz(true, false, 25, 20));
    t.w(e_ldst_9(3, false, 1, 23, 21, 8, 1));
    t.w(e_ldst_9(3, false, 0, 23, 24, 8, 1));
    t.w(e_addsub_imm(true, true, false, 25, 25, 1, false));
    t.w(e_b(-16));
    t.w(e_ldst_9(3, false, 0, ZR, 24, 8, 1));
    t.w(e_ldst_9(3, false, 0, ZR, 24, 8, 1));
    t.out.push(AI::B { link: false, t: Tg::E(Expr(vec![(false, Term::Sym("_start".into()))])) });
    t.out
}

// ------------------------------------------------------------------ layout, encoding, Mach-O

pub(crate) fn uleb(b: &mut Vec<u8>, mut v: u64) {
    loop { let mut x = (v & 0x7f) as u8; v >>= 7; if v != 0 { x |= 0x80; } b.push(x); if v == 0 { break; } }
}

// Run-time Linux -> Darwin system call dispatcher, written in the same
// x86 subset and translated with the program. In: rax Linux number,
// rdi rsi rdx r10 r8 r9 arguments. Out: rax (negative errno on error).
// Preserves every register but rax, rcx and r11, like the syscall
// instruction. "mov $0x2000000+N, %eax; syscall" is a raw Darwin call.
pub(crate) const LINUX_SYSCALL_DISPATCH: &str = r#"
    .text
__a64_linux_syscall:
    cmp $217, %rax
    je .La64s_getdents
    cmp $262, %rax
    je .La64s_fstatat
    cmp $257, %rax
    je .La64s_openat
    cmp $228, %rax
    je .La64s_clock
    cmp $9, %rax
    je .La64s_mmap
    cmp $202, %rax
    je .La64s_futex
    cmp $0, %rax
    je .La64s_n0
    cmp $1, %rax
    je .La64s_n1
    cmp $2, %rax
    je .La64s_n2
    cmp $3, %rax
    je .La64s_n3
    cmp $8, %rax
    je .La64s_n8
    cmp $11, %rax
    je .La64s_n11
    cmp $18, %rax
    je .La64s_n18
    cmp $60, %rax
    je .La64s_n60
    cmp $72, %rax
    je .La64s_n72
    cmp $96, %rax
    je .La64s_n96
    mov $-38, %rax
    ret
.La64s_n0:
    mov $0, %eax
    syscall
    ret
.La64s_n1:
    mov $1, %eax
    syscall
    ret
.La64s_n2:
    mov $2, %eax
    syscall
    ret
.La64s_n3:
    mov $3, %eax
    syscall
    ret
.La64s_n8:
    mov $8, %eax
    syscall
    ret
.La64s_n11:
    mov $11, %eax
    syscall
    ret
.La64s_n18:
    mov $18, %eax
    syscall
    ret
.La64s_n60:
    mov $60, %eax
    syscall
    ret
.La64s_n72:
    mov $72, %eax
    syscall
    ret
.La64s_n96:
    mov $96, %eax
    syscall
    ret
.La64s_mmap:
    push %r10
    mov %r10, %rcx
    and $-33, %rcx
    test $32, %r10
    jz .La64s_mmap1
    or $4096, %rcx
.La64s_mmap1:
    mov %rcx, %r10
    mov $33554629, %eax
    syscall
    pop %r10
    ret
.La64s_openat:
    push %rdi
    push %rdx
    cmp $-100, %rdi
    jne .La64s_oa1
    mov $-2, %rdi
.La64s_oa1:
    mov %rdx, %rcx
    and $3, %rcx
    test $64, %rdx
    jz .La64s_of0
    or $512, %rcx
.La64s_of0:
    test $128, %rdx
    jz .La64s_of1
    or $2048, %rcx
.La64s_of1:
    test $512, %rdx
    jz .La64s_of2
    or $1024, %rcx
.La64s_of2:
    test $1024, %rdx
    jz .La64s_of3
    or $8, %rcx
.La64s_of3:
    test $2048, %rdx
    jz .La64s_of4
    or $4, %rcx
.La64s_of4:
    test $65536, %rdx
    jz .La64s_of5
    or $1048576, %rcx
.La64s_of5:
    test $131072, %rdx
    jz .La64s_of6
    or $256, %rcx
.La64s_of6:
    test $524288, %rdx
    jz .La64s_of7
    or $16777216, %rcx
.La64s_of7:
    mov %rcx, %rdx
    mov $33554895, %eax
    syscall
    pop %rdx
    pop %rdi
    ret
.La64s_fstatat:
    push %rdi
    push %r10
    cmp $-100, %rdi
    jne .La64s_fs1
    mov $-2, %rdi
.La64s_fs1:
    xor %ecx, %ecx
    test $256, %r10
    jz .La64s_fs2
    mov $32, %ecx
.La64s_fs2:
    mov %rcx, %r10
    mov $33554902, %eax
    syscall
    pop %r10
    pop %rdi
    test %rax, %rax
    jne .La64s_fs9
    sub $144, %rsp
    mov 0(%rdx), %rcx
    mov %rcx, 0(%rsp)
    mov 8(%rdx), %rcx
    mov %rcx, 8(%rsp)
    mov 16(%rdx), %rcx
    mov %rcx, 16(%rsp)
    mov 24(%rdx), %rcx
    mov %rcx, 24(%rsp)
    mov 32(%rdx), %rcx
    mov %rcx, 32(%rsp)
    mov 40(%rdx), %rcx
    mov %rcx, 40(%rsp)
    mov 48(%rdx), %rcx
    mov %rcx, 48(%rsp)
    mov 56(%rdx), %rcx
    mov %rcx, 56(%rsp)
    mov 64(%rdx), %rcx
    mov %rcx, 64(%rsp)
    mov 72(%rdx), %rcx
    mov %rcx, 72(%rsp)
    mov 80(%rdx), %rcx
    mov %rcx, 80(%rsp)
    mov 88(%rdx), %rcx
    mov %rcx, 88(%rsp)
    mov 96(%rdx), %rcx
    mov %rcx, 96(%rsp)
    mov 104(%rdx), %rcx
    mov %rcx, 104(%rsp)
    mov 112(%rdx), %rcx
    mov %rcx, 112(%rsp)
    mov 120(%rdx), %rcx
    mov %rcx, 120(%rsp)
    mov 128(%rdx), %rcx
    mov %rcx, 128(%rsp)
    mov 136(%rdx), %rcx
    mov %rcx, 136(%rsp)
    movslq 0(%rsp), %rcx
    mov %rcx, 0(%rdx)
    movq 8(%rsp), %rcx
    mov %rcx, 8(%rdx)
    movzwl 6(%rsp), %ecx
    mov %rcx, 16(%rdx)
    movzwl 4(%rsp), %ecx
    movl %ecx, 24(%rdx)
    movl 16(%rsp), %ecx
    movl %ecx, 28(%rdx)
    movl 20(%rsp), %ecx
    movl %ecx, 32(%rdx)
    movl $0, 36(%rdx)
    movslq 24(%rsp), %rcx
    mov %rcx, 40(%rdx)
    movq 96(%rsp), %rcx
    mov %rcx, 48(%rdx)
    movslq 112(%rsp), %rcx
    mov %rcx, 56(%rdx)
    movq 104(%rsp), %rcx
    mov %rcx, 64(%rdx)
    movq 32(%rsp), %rcx
    mov %rcx, 72(%rdx)
    movq 40(%rsp), %rcx
    mov %rcx, 80(%rdx)
    movq 48(%rsp), %rcx
    mov %rcx, 88(%rdx)
    movq 56(%rsp), %rcx
    mov %rcx, 96(%rdx)
    movq 64(%rsp), %rcx
    mov %rcx, 104(%rdx)
    movq 72(%rsp), %rcx
    mov %rcx, 112(%rdx)
    movq $0, 120(%rdx)
    movq $0, 128(%rdx)
    movq $0, 136(%rdx)
    add $144, %rsp
    xor %eax, %eax
.La64s_fs9:
    ret
.La64s_getdents:
    push %r10
    sub $8, %rsp
    movq $0, (%rsp)
    mov %rsp, %r10
    mov $33554776, %eax
    syscall
    add $8, %rsp
    pop %r10
    test %rax, %rax
    jle .La64s_gd9
    push %rax
    push %rsi
    push %rdx
    mov %rsi, %rdx
    add %rax, %rdx
.La64s_gd1:
    cmp %rdx, %rsi
    jae .La64s_gd8
    movzwl 18(%rsi), %r11d
    movzbl 20(%rsi), %ecx
    movb %cl, 18(%rsi)
    lea 1(%r11), %rcx
    xor %r11d, %r11d
.La64s_gd2:
    movzbl 21(%rsi,%r11), %eax
    movb %al, 19(%rsi,%r11)
    inc %r11
    cmp %rcx, %r11
    jb .La64s_gd2
    movzwl 16(%rsi), %ecx
    test %rcx, %rcx
    jz .La64s_gd8
    add %rcx, %rsi
    jmp .La64s_gd1
.La64s_gd8:
    pop %rdx
    pop %rsi
    pop %rax
.La64s_gd9:
    ret
.La64s_futex:
    push %rdi
    push %rsi
    push %rdx
    push %r10
    mov %rsi, %rcx
    and $127, %rcx
    cmp $1, %rcx
    je .La64s_fwake
    test %rcx, %rcx
    jne .La64s_fnosys
    xor %ecx, %ecx
    test %r10, %r10
    je .La64s_fw1
    mov 8(%r10), %rax
    xor %edx, %edx
    mov $1000, %r11
    div %r11
    mov (%r10), %rcx
    imul $1000000, %rcx, %rcx
    add %rax, %rcx
    cmp $1, %rcx
    jae .La64s_fw2
    mov $1, %ecx
.La64s_fw2:
    mov $4294967295, %rax
    cmp %rax, %rcx
    jbe .La64s_fw1
    mov %rax, %rcx
.La64s_fw1:
    mov 8(%rsp), %rdx
    mov %rdi, %rsi
    mov $1, %edi
    mov %rcx, %r10
    mov $33554947, %eax
    syscall
    cmp $-60, %rax
    jne .La64s_fw3
    mov $-110, %rax
    jmp .La64s_fout
.La64s_fw3:
    test %rax, %rax
    js .La64s_fout
    xor %eax, %eax
    jmp .La64s_fout
.La64s_fwake:
    mov %rdi, %rsi
    mov $257, %edi
    xor %edx, %edx
    mov $33554948, %eax
    syscall
    xor %eax, %eax
    jmp .La64s_fout
.La64s_fnosys:
    mov $-38, %rax
.La64s_fout:
    pop %r10
    pop %rdx
    pop %rsi
    pop %rdi
    ret
.La64s_clock:
    push %rdi
    push %rsi
    push %rdx
    mov %rsi, %rdi
    xor %esi, %esi
    mov $96, %eax
    syscall
    pop %rdx
    pop %rsi
    pop %rdi
    test %rax, %rax
    jne .La64s_ck9
    mov 8(%rsi), %rcx
    imul $1000, %rcx, %rcx
    mov %rcx, 8(%rsi)
.La64s_ck9:
    ret
"#;

// hbc_blk_launch (SysV, from extend/hbhbr.c): C evaluates an hbc
// codeblock through it, so in the dylib model it lives in the executable.
pub(crate) const EXT_BRIDGE_TEXT: &str = r#"
    .text
hbc_blk_launch:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    mov %rdx, %rcx
    mov %rdi, %rbx
    test %rcx, %rcx
    jz .La64blk2
.La64blk1:
    sub $16, %rsp
    mov (%rsi), %rax
    mov %rax, (%rsp)
    movq $0, 8(%rsp)
    add $8, %rsi
    dec %rcx
    jnz .La64blk1
.La64blk2:
    call *%rbx
    lea -16(%rbp), %rsp
    pop %r12
    pop %rbx
    pop %rbp
    ret
    .data
    .p2align 3
__a64_tkey: .quad 0
    .text
"#;

// C-callable entry points the executable exports to the extension dylib.
const EXT_EXPORTS: [(&str, &str); 4] = [
    ("hbc_strcpy", "__a64_cin_hbc_strcpy"), ("hbc_freestr", "__a64_cin_hbc_freestr"),
    ("hbc_blk_launch", "__a64_cin_hbc_blk_launch"), ("hrdbf_app_close", "__a64_cin_hrdbf_app_close"),
];

// Intel reuses the baseline dispatcher. Add syscall35 ONLY to the
// ARM64 copy: otherwise Intel's unmapped 35 would reenter its dispatcher.
fn arm64_linux_syscall_dispatch() -> String {
    LINUX_SYSCALL_DISPATCH.replacen("    cmp $60, %rax\n", "    cmp $35, %rax\n    je .La64s_n35\n    cmp $60, %rax\n", 1)
        + "\n.La64s_n35:\n    mov $35, %eax\n    syscall\n    ret\n"
}

pub fn assemble_macho_arm64(src: &str) -> Result<Vec<u8>, String> { assemble_macho_arm64_ext(src, None) }

// ext: install name of the EXTERNAL extension dylib (LC_LOAD_DYLIB).
pub fn assemble_macho_arm64_ext(src: &str, ext: Option<&str>) -> Result<Vec<u8>, String> {
    let src = format!("{}\n{}{}", src, arm64_linux_syscall_dispatch(), if ext.is_some() { EXT_BRIDGE_TEXT } else { "" });
    let expanded = expand_rept(&src)?;
    let mut a = Asm {
        p: Parser { consts: HashMap::new(), labels: HashMap::new(), numlabels: HashMap::new(), seq: Cell::new(0) },
        text: Vec::new(), rodata: Vec::new(), data: Vec::new(), bss: Vec::new(), note: Vec::new(),
        has_gnu_stack: false, cur: Sec::Text, secstack: Vec::new(),
        text_align: 1, rod_align: 1, dat_align: 1, bss_align: 1,
    };
    for (ln, raw) in expanded.lines().enumerate() {
        a.parse_line(raw).map_err(|e| format!("line {}: {}: {}", ln + 1, raw.trim(), e))?;
    }
    let (need, live, ckind) = analyze(&a)?;
    let threaded = a.p.labels.contains_key("hbc_thread_start");
    let mut t = Tr { a: &a, out: Vec::new(), need, live, ckind, imports: Vec::new(), used_helpers: Default::default(), threaded, ext: ext.is_some(), ext_imports: Default::default() };
    let n = a.text.len();
    let mut starts = vec![0usize; n + 1];
    let mut i = 0;
    while i < n {
        starts[i] = t.out.len();
        let adv = match &a.text[i] {
            TItem::Ins { mnem, ops, .. } => {
                let m = mnem.clone();
                let ops = ops.clone();
                t.ins(i, &m, &ops).map_err(|e| format!("{} (x86 item {}: {} {:?})", e, i, m, ops))?
            }
            TItem::P2 { .. } => 1,
            // gcc blobs spell a few instructions as raw bytes
            TItem::Raw(DItem::Bytes(b)) if b.as_slice() == [0xf3, 0xab] => {
                // rep stosl: store eax rcx times at rdi
                t.w(e_cbz(true, false, 10, 16));
                t.w(e_ldst_9(2, false, 0, 9, 14, 4, 1));
                t.w(e_addsub_imm(true, true, false, 10, 10, 1, false));
                t.w(e_b(-12));
                1
            }
            TItem::Raw(DItem::Bytes(b)) if b.as_slice() == [0x41, 0xff, 0x72, 0xf8] => {
                // push -8(%r10)
                t.w(e_ldst_9(3, false, 1, T1, RMAP[10], -8, 0));
                t.w(e_ldst_9(3, false, 0, T1, XSP, -8, 3));
                1
            }
            TItem::Raw(DItem::Bytes(b)) => { t.out.push(AI::Bytes(b.clone())); 1 }
            TItem::Raw(DItem::Align(al)) => { t.out.push(AI::Align(*al)); 1 }
            TItem::Raw(_) => return Err("ARM64: relocated data inside .text is not supported".into()),
        };
        for k in i + 1..i + adv { starts[k] = t.out.len(); }
        i += adv;
    }
    starts[n] = t.out.len();
    if ext.is_some() {
        for (lab, h) in EXT_EXPORTS { if a.p.labels.contains_key(lab) { t.used_helpers.insert(h); } }
    }
    let mut helpers: Vec<&'static str> = t.used_helpers.iter().copied().collect();
    helpers.sort();
    let mut items = std::mem::take(&mut t.out);
    for h in helpers { let v = helper(h, &mut t); items.extend(v); }
    let key_create = if ext.is_some() { Some(t.import("_pthread_key_create")) } else { None };
    items.extend(entry_stub(&a, key_create));
    let imports = t.imports.clone();

    let mut hpos: HashMap<&'static str, usize> = HashMap::new();
    let mut lpos: HashMap<u32, usize> = HashMap::new();
    for (k, it) in items.iter().enumerate() {
        if let AI::Hl(h) = it { hpos.insert(h, k); }
        if let AI::Lab(l) = it { if lpos.insert(*l, k).is_some() { return Err("ARM64: duplicate local label".into()); } }
    }

    // data layout (all in __DATA): rodata, data, GOT, bss
    let align_up = |v: u64, a: u64| (v + a - 1) & !(a - 1);
    let pre_rod = prefix_sizes(&a.rodata);
    let pre_dat = prefix_sizes(&a.data);
    let pre_bss = prefix_sizes(&a.bss);
    let rod_size = *pre_rod.last().unwrap();
    let dat_size = *pre_dat.last().unwrap();
    let bss_size = *pre_bss.last().unwrap();

    let mut far = vec![false; items.len()];
    let mut offs = vec![0u64; items.len() + 1];
    loop {
        let mut o = 0u64;
        for (k, it) in items.iter().enumerate() {
            match it {
                AI::W(_) | AI::B { .. } | AI::Bc { .. } | AI::Adr { .. } | AI::Hl(_) | AI::Lab(_) => o = (o + 3) & !3,
                AI::Align(al) => o = (o + al - 1) & !(al - 1),
                AI::Bytes(_) => {}
            }
            offs[k] = o;
            o += match it { AI::W(_) | AI::B { .. } => 4, AI::Bc { .. } => if far[k] { 8 } else { 4 }, AI::Adr { .. } => 8,
                AI::Hl(_) | AI::Lab(_) | AI::Align(_) => 0, AI::Bytes(b) => b.len() as u64 };
        }
        o = (o + 3) & !3;
        offs[items.len()] = o;
        let text_size = o;
        let data_va = align_up(TEXT_VA + text_size, 0x4000);
        let rod_va = data_va;
        let dat_va = align_up(rod_va + rod_size, 64);
        let got_va = align_up(dat_va + dat_size, 8);
        let bss_va = align_up(got_va + 8 * imports.len() as u64, 64);
        let loc_va = |l: &Loc| -> u64 {
            match l.sec {
                Sec::Text => TEXT_VA + offs[starts[l.idx.min(n)]],
                Sec::Rodata => rod_va + pre_rod[l.idx],
                Sec::Data => dat_va + pre_dat[l.idx],
                Sec::Bss => bss_va + pre_bss[l.idx],
                Sec::Note => 0,
            }
        };
        let resolve = |e: &Expr| -> Result<i64, String> {
            let mut acc = 0i64;
            for (neg, term) in &e.0 {
                let v = match term {
                    Term::Num(v) => *v,
                    Term::Sym(s) => {
                        if let Some(c) = a.p.consts.get(s) { *c }
                        else if let Some(l) = a.p.labels.get(s) { loc_va(l) as i64 }
                        else { return Err(format!("ARM64: undefined symbol {}", s)); }
                    }
                    Term::Fwd(nl, seq) => loc_va(&a.resolve_num(*nl, true, *seq)?) as i64,
                    Term::Back(nl, seq) => loc_va(&a.resolve_num(*nl, false, *seq)?) as i64,
                };
                acc = if *neg { acc.wrapping_sub(v) } else { acc.wrapping_add(v) };
            }
            Ok(acc)
        };
        let tgt = |tg: &Tg| -> Result<u64, String> {
            match tg {
                Tg::E(e) => Ok(resolve(e)? as u64),
                Tg::H(h) => Ok(TEXT_VA + offs[*hpos.get(h).ok_or("ARM64: missing helper")?]),
                Tg::Got(g) => Ok(got_va + 8 * *g as u64),
                Tg::L(l) => Ok(TEXT_VA + offs[*lpos.get(l).ok_or("ARM64: missing local label")?]),
            }
        };
        let mut changed = false;
        for (k, it) in items.iter().enumerate() {
            if let AI::Bc { t: tg, .. } = it {
                if far[k] { continue; }
                let d = tgt(tg)? as i64 - (TEXT_VA + offs[k]) as i64;
                if !(-(1 << 20)..(1 << 20)).contains(&d) { far[k] = true; changed = true; }
            }
        }
        if changed { continue; }

        let mut code: Vec<u8> = Vec::with_capacity(text_size as usize);
        for (k, it) in items.iter().enumerate() {
            let pc = (TEXT_VA + offs[k]) as i64;
            code.resize(offs[k] as usize, 0);
            let mut put = |x: u32| code.extend_from_slice(&x.to_le_bytes());
            match it {
                AI::W(x) => put(*x),
                AI::Hl(_) | AI::Lab(_) | AI::Align(_) => {}
                AI::Bytes(b) => code.extend_from_slice(b),
                AI::B { link, t: tg } => {
                    let d = tgt(tg)? as i64 - pc;
                    if d % 4 != 0 || !(-(1 << 27)..(1 << 27)).contains(&d) { return Err("ARM64: branch out of range".into()); }
                    put(e_b(d) | if *link { 0x8000_0000 } else { 0 });
                }
                AI::Bc { c, t: tg } => {
                    let d = tgt(tg)? as i64 - pc;
                    if far[k] {
                        put(e_bc(c ^ 1, 8));
                        let d2 = d - 4;
                        if !(-(1 << 27)..(1 << 27)).contains(&d2) { return Err("ARM64: branch out of range".into()); }
                        put(e_b(d2));
                    } else { put(e_bc(*c, d)); }
                }
                AI::Adr { rd, t: tg } => {
                    let v = tgt(tg)?;
                    let page = (v as i64 >> 12) - (pc >> 12);
                    if !(-(1 << 20)..(1 << 20)).contains(&page) { return Err(format!("ARM64: adrp out of range ({:?} = {:#x})", tg, v)); }
                    let p = page as u32;
                    put(0x9000_0000 | (p & 3) << 29 | ((p >> 2) & 0x7ffff) << 5 | r(*rd));
                    put(e_addsub_imm(true, false, false, *rd, *rd, (v & 0xfff) as u32, false));
                }
            }
        }
        code.resize(text_size as usize, 0);
        let entry_off = offs[*hpos.get("__a64_entry").unwrap()];
        let mut data = vec![0u8; (got_va + 8 * imports.len() as u64 - data_va) as usize];
        let rod = materialize(&a.rodata, &resolve)?;
        let dat = materialize(&a.data, &resolve)?;
        data[..rod.len()].copy_from_slice(&rod);
        let d0 = (dat_va - data_va) as usize;
        data[d0..d0 + dat.len()].copy_from_slice(&dat);
        // rebases: 8-byte patches that hold a label address
        let mut rebases = Vec::new();
        let is_addr = |e: &Expr| -> bool {
            let mut cnt = 0i32;
            for (neg, term) in &e.0 {
                let lab = match term { Term::Sym(s) => !a.p.consts.contains_key(s), Term::Fwd(..) | Term::Back(..) => true, _ => false };
                if lab { cnt += if *neg { -1 } else { 1 }; }
            }
            cnt != 0
        };
        for (its, pre, base) in [(&a.rodata, &pre_rod, rod_va), (&a.data, &pre_dat, dat_va)] {
            for (k, it) in its.iter().enumerate() {
                match it {
                    DItem::Patch8(e) if is_addr(e) => rebases.push(base + pre[k] - data_va),
                    DItem::Patch4(e) if is_addr(e) => return Err("ARM64: 32-bit absolute address in data".into()),
                    _ => {}
                }
            }
        }
        let binds: Vec<(&str, u64, u8)> = imports.iter().enumerate()
            .map(|(g, s)| (*s, got_va + 8 * g as u64 - data_va, if t.ext_imports.contains(s) { 2 } else { 1 })).collect();
        let exports: Vec<(String, u64)> = EXT_EXPORTS.iter().filter_map(|(lab, h)| hpos.get(h).map(|k| (format!("_{}", lab), HDR + offs[*k]))).collect();
        let total_vm = bss_va + bss_size - data_va;
        return write_macho(&code, entry_off, &data, total_vm, &rebases, &binds, ext, &exports);
    }
}

fn w32(b: &mut Vec<u8>, n: u32) { b.extend_from_slice(&n.to_le_bytes()); }
fn w64(b: &mut Vec<u8>, n: u64) { b.extend_from_slice(&n.to_le_bytes()); }
fn name16(b: &mut Vec<u8>, s: &str) { b.extend_from_slice(s.as_bytes()); b.resize(b.len() + 16 - s.len(), 0); }
// Mach-O export trie: a root with one terminal child per exported symbol
// (address relative to the Mach-O header), padded to 8 bytes.
pub(crate) fn export_trie(exports: &[(String, u64)]) -> Vec<u8> {
    let mut trie = Vec::new();
    if exports.is_empty() { return trie; }
    let nodes: Vec<Vec<u8>> = exports.iter().map(|(_, addr)| {
        let mut body = vec![0u8]; uleb(&mut body, *addr);
        let mut n = Vec::new(); uleb(&mut n, body.len() as u64); n.extend(body); n.push(0); n
    }).collect();
    let mut root_len = 0usize;
    loop {
        let mut root = vec![0u8, exports.len() as u8];
        let mut at = root_len;
        for ((name, _), node) in exports.iter().zip(&nodes) {
            root.extend_from_slice(name.as_bytes()); root.push(0);
            uleb(&mut root, at as u64); at += node.len();
        }
        if root.len() == root_len { trie = root; for n in &nodes { trie.extend_from_slice(n); } break; }
        root_len = root.len();
    }
    while trie.len() % 8 != 0 { trie.push(0); }
    trie
}

pub(crate) fn segment(s: &str, va: u64, ms: u64, off: u64, fs: u64, prot: u32, sections: &[(&str, u64, u64, u32, u32)]) -> Vec<u8> {
    let mut b = Vec::new();
    w32(&mut b, 25); w32(&mut b, 72 + 80 * sections.len() as u32);
    name16(&mut b, s);
    for n in [va, ms, off, fs] { w64(&mut b, n); }
    for n in [prot, prot, sections.len() as u32, 0] { w32(&mut b, n); }
    for &(sec, addr, size, offset, flags) in sections {
        name16(&mut b, sec); name16(&mut b, s);
        w64(&mut b, addr); w64(&mut b, size);
        for n in [offset, 4, 0, 0, flags, 0, 0, 0] { w32(&mut b, n); }
    }
    b
}
pub(crate) fn string_command(cmd: u32, path: &str) -> Vec<u8> {
    let extra = if cmd == 14 { 0 } else { 12 };
    let size = (12 + extra + path.len() + 1 + 7) & !7;
    let mut b = Vec::new();
    for n in [cmd, size as u32, 12 + extra as u32] { w32(&mut b, n); }
    if cmd != 14 { for n in [2, 0x10000, 0x10000] { w32(&mut b, n); } }
    b.extend_from_slice(path.as_bytes());
    b.resize(size, 0);
    b
}
pub(crate) fn words(v: &[u32]) -> Vec<u8> { v.iter().flat_map(|n| n.to_le_bytes()).collect() }

fn write_macho(code: &[u8], entry_off: u64, data: &[u8], data_vm: u64, rebases: &[u64], binds: &[(&str, u64, u8)],
               ext: Option<&str>, exports: &[(String, u64)]) -> Result<Vec<u8>, String> {
    let align_up = |v: u64, a: u64| (v + a - 1) & !(a - 1);
    let textsize = align_up(HDR + code.len() as u64, 0x4000);
    let data_off = textsize;
    let data_va = BASE + textsize;
    let data_fs = align_up(data.len().max(1) as u64, 0x4000);
    let data_ms = align_up(data_vm.max(data.len() as u64).max(1), 0x4000);
    let link_off = data_off + data_fs;
    let mut reb = Vec::new();
    if !rebases.is_empty() {
        reb.push(0x11); // REBASE_TYPE_POINTER
        for off in rebases { reb.push(0x22); uleb(&mut reb, *off); reb.push(0x51); }
    }
    reb.push(0);
    while reb.len() % 8 != 0 { reb.push(0); }
    let mut bind = Vec::new();
    if !binds.is_empty() {
        bind.push(0x51); // BIND_TYPE_POINTER
        for (s, off, ord) in binds {
            bind.push(0x10 | ord); // dylib ordinal: 1 libSystem, 2 extension
            bind.push(0x40); bind.extend_from_slice(s.as_bytes()); bind.push(0);
            bind.push(0x72); uleb(&mut bind, *off);
            bind.push(0x90);
        }
    }
    bind.push(0);
    while bind.len() % 8 != 0 { bind.push(0); }
    let trie = export_trie(exports);
    let reb_off = link_off;
    let bind_off = reb_off + reb.len() as u64;
    let export_off = bind_off + bind.len() as u64;
    let strtab_off = export_off + trie.len() as u64;
    let sigoff = align_up(strtab_off + 8, 16);
    let ident = b"hbc-arm64\0";
    let cdheader = 88u64;
    let hashoff = align_up(cdheader + ident.len() as u64, 8);
    let pages = (sigoff + 4095) / 4096;
    let cdsize = hashoff + pages * 32;
    let sigsize = 20 + cdsize;
    let fileend = sigoff + sigsize;
    let mut cmds = vec![
        segment("__PAGEZERO", 0, BASE, 0, 0, 0, &[]),
        segment("__TEXT", BASE, textsize, 0, textsize, 5, &[("__text", TEXT_VA, code.len() as u64, HDR as u32, 0x8000_0400)]),
        segment("__DATA", data_va, data_ms, data_off, data_fs, 3, &[("__data", data_va, data.len() as u64, data_off as u32, 0)]),
        segment("__LINKEDIT", BASE + textsize + data_ms, align_up(fileend - link_off, 0x4000), link_off, fileend - link_off, 1, &[]),
    ];
    cmds.push(words(&[0x8000_0022, 48, reb_off as u32, reb.len() as u32, bind_off as u32, bind.len() as u32, 0, 0, 0, 0,
        if trie.is_empty() { 0 } else { export_off as u32 }, trie.len() as u32]));
    cmds.push(words(&[2, 24, strtab_off as u32, 0, strtab_off as u32, 8]));
    cmds.push(words(&[11, 80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
    cmds.push(string_command(14, "/usr/lib/dyld"));
    let mut uuid = words(&[27, 24]);
    let mut h = sha256(code);
    h[6] = (h[6] & 0x0f) | 0x40; h[8] = (h[8] & 0x3f) | 0x80;
    uuid.extend_from_slice(&h[..16]);
    cmds.push(uuid);
    cmds.push(words(&[50, 24, 1, 0xb0000, 0xb0000, 0]));
    let mut m = words(&[0x8000_0028, 24]);
    w64(&mut m, HDR + entry_off);
    w64(&mut m, 0);
    cmds.push(m);
    cmds.push(string_command(12, "/usr/lib/libSystem.B.dylib"));
    if let Some(path) = ext { cmds.push(string_command(12, path)); }
    cmds.push(words(&[29, 16, sigoff as u32, sigsize as u32]));
    let cmdsize: usize = cmds.iter().map(Vec::len).sum();
    let mut b = words(&[0xfeed_facf, 0x0100_000c, 0, 2, cmds.len() as u32, cmdsize as u32, 0x0020_0085, 0]);
    for c in cmds { b.extend(c); }
    if b.len() > HDR as usize { return Err("ARM64: Mach-O load commands too large".into()); }
    b.resize(HDR as usize, 0);
    b.extend_from_slice(code);
    b.resize(data_off as usize, 0);
    b.extend_from_slice(data);
    b.resize(link_off as usize, 0);
    b.extend(reb);
    b.extend(bind);
    b.extend(trie);
    b.resize(sigoff as usize, 0);
    // ad hoc code signature (CodeDirectory, SHA-256 per 4 KiB page)
    let be = |b: &mut Vec<u8>, n: u32| b.extend_from_slice(&n.to_be_bytes());
    let mut cd = Vec::new();
    for n in [0xfade_0c02, cdsize as u32, 0x20400, 0x20002, hashoff as u32, cdheader as u32, 0, pages as u32, sigoff as u32] { be(&mut cd, n); }
    cd.extend_from_slice(&[32, 2, 0, 12]);
    for _ in 0..4 { be(&mut cd, 0); }
    cd.extend_from_slice(&0u64.to_be_bytes());
    for n in [0u64, textsize, 1] { cd.extend_from_slice(&n.to_be_bytes()); }
    cd.extend_from_slice(ident);
    cd.resize(hashoff as usize, 0);
    for page in b.chunks(4096) { cd.extend_from_slice(&sha256(page)); }
    for n in [0xfade_0cc0, sigsize as u32, 1, 0, 20] { be(&mut b, n); }
    b.extend(cd);
    if b.len() as u64 != fileend { return Err("ARM64: signature size mismatch".into()); }
    Ok(b)
}

// Own SHA-256 (FIPS 180-4), used only for the ad hoc code signature.
pub(crate) fn sha256(data: &[u8]) -> [u8; 32] {
    const K: [u32; 64] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ];
    let mut h: [u32; 8] = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19];
    let mut m = data.to_vec();
    let bits = (data.len() as u64).wrapping_mul(8);
    m.push(0x80);
    while m.len() % 64 != 56 { m.push(0); }
    m.extend_from_slice(&bits.to_be_bytes());
    for chunk in m.chunks(64) {
        let mut w = [0u32; 64];
        for i in 0..16 { w[i] = u32::from_be_bytes(chunk[4 * i..4 * i + 4].try_into().unwrap()); }
        for i in 16..64 {
            let s0 = w[i - 15].rotate_right(7) ^ w[i - 15].rotate_right(18) ^ (w[i - 15] >> 3);
            let s1 = w[i - 2].rotate_right(17) ^ w[i - 2].rotate_right(19) ^ (w[i - 2] >> 10);
            w[i] = w[i - 16].wrapping_add(s0).wrapping_add(w[i - 7]).wrapping_add(s1);
        }
        let mut v = h;
        for i in 0..64 {
            let s1 = v[4].rotate_right(6) ^ v[4].rotate_right(11) ^ v[4].rotate_right(25);
            let ch = (v[4] & v[5]) ^ (!v[4] & v[6]);
            let t1 = v[7].wrapping_add(s1).wrapping_add(ch).wrapping_add(K[i]).wrapping_add(w[i]);
            let s0 = v[0].rotate_right(2) ^ v[0].rotate_right(13) ^ v[0].rotate_right(22);
            let maj = (v[0] & v[1]) ^ (v[0] & v[2]) ^ (v[1] & v[2]);
            let t2 = s0.wrapping_add(maj);
            v = [t1.wrapping_add(t2), v[0], v[1], v[2], v[3].wrapping_add(t1), v[4], v[5], v[6]];
        }
        for i in 0..8 { h[i] = h[i].wrapping_add(v[i]); }
    }
    let mut out = [0u8; 32];
    for i in 0..8 { out[4 * i..4 * i + 4].copy_from_slice(&h[i].to_be_bytes()); }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn sha256_vectors() {
        let hex = |b: [u8; 32]| b.iter().map(|x| format!("{:02x}", x)).collect::<String>();
        assert_eq!(hex(sha256(b"")), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
        assert_eq!(hex(sha256(b"abc")), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
    }
    #[test]
    fn nanosleep_static_and_dynamic_lower_to_libsystem() {
        assert!(!LINUX_SYSCALL_DISPATCH.contains(".La64s_n35"));
        assert!(arm64_linux_syscall_dispatch().contains(".La64s_n35"));
        for code in [
            "mov $35, %eax\n syscall\n",
            "mov $35, %r10\n mov %r10, %rax\n syscall\n",
        ] {
            let src = format!(".text\n.globl _start\n_start:\n{}mov $60, %eax\n xor %edi, %edi\n syscall\n", code);
            let bin = assemble_macho_arm64(&src).unwrap();
            assert!(bin.windows(10).any(|w|w==b"_nanosleep"));
            assert!(bin.windows(9).any(|w|w==b"___error\0"));
            // Actual emitted call -> normalize int32 -> compare w0.
            // MOV W0,W0 clears upper bits even for a mock C return whose
            // x0 is 0xdeadbeef00000000 (successful w0=0).
            let seq = [e_blr(T1),e_mov(false,0,0),e_addsub_imm(false,false,true,ZR,0,0,false)]
                .iter().flat_map(|w|w.to_le_bytes()).collect::<Vec<_>>();
            assert!(bin.windows(seq.len()).any(|w|w==seq));
            let dirty_success = 0xdead_beef_0000_0000u64;
            assert_eq!(dirty_success as u32 as u64,0);
            // Never mistake BSD __semwait_signal(334) for nanosleep.
            let wrong = e_movw(true,2,16,334,0).to_le_bytes();
            assert!(!bin.windows(4).any(|w|w==wrong));
        }
    }
    #[test]
    fn bitmask_immediates() {
        assert_eq!(bitmask_imm(1, true), Some(0x1000));
        assert_eq!(bitmask_imm(0xff, true), Some(0x1007));
        assert_eq!(bitmask_imm(3, false), Some(0x0001));
        assert_eq!(bitmask_imm(0x5555_5555_5555_5555, true), Some(0x003c));
        assert!(bitmask_imm(0, true).is_none());
        assert!(bitmask_imm(0x1234, true).is_none());
    }
}
