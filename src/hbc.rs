// hbc - PoC compiler: Harbour syntax (closed subset) -> x86-64 assembly.
//
// Pipeline: hbc does tokenizing, parsing, semantic analysis (types AND
// ownership/move checking) and code generation itself. The only external
// tools in the pipeline are the system assembler and linker (GNU binutils).
// The produced executables are freestanding: no VM, no libc, no external
// runtime; I/O is two small hand-written syscall helpers emitted into every
// binary. rustc is used to build hbc itself (the compiler's implementation
// language), never to compile Harbour programs.
//
// Targets: linux (default) emits freestanding ELF assembly (raw syscalls);
// windows emits Win64 assembly that calls kernel32 (GetStdHandle /
// WriteFile / ExitProcess) and is assembled/linked with mingw-w64
// binutils. The analysis passes and the internal value convention
// (i64 in rax, Str ptr+len in rax/rdx) are target-independent; only the
// process entry and the two print helpers change.
//
// Fail-closed: tokenizer + parser validate every token; only a known AST is
// ever analyzed or emitted. No raw user text ever reaches the output.
//
// Type contract: integers are i64 (Copy, like Rust), strings are (ptr, len)
// slices of .rodata (they move on assignment; they do not copy, like Rust's
// String ownership). Printing borrows; it does not move.

use std::env;
use std::fs;
use std::process;

// The preprocessor is part of hbc: every compile runs it automatically
// (shared engine in pp.rs; hpp is only a standalone debug frontend).
#[path = "pp.rs"]
mod pp;

#[derive(Clone, Copy, PartialEq, Debug)]
enum Ty { F64, I64, Str, Bool, Arr(usize), Block(usize), DArr, DArrU, DArr2, DArr3, DArr4, DArrS, StrOwn, Dyn, Hash, DArrRef, DArrRef2, RefI64, RefStrOwn }

// Dyn is the tagged-union value for any route that can carry NIL (probes
// n1/n2/n3): a 16-byte {tag, payload} pair, tag 0 = i64 payload, tag 1 =
// NIL. No integer is reserved - i64::MIN is an ordinary payload. Pure i64
// stays 8 bytes wherever NIL is proven absent. In registers a Dyn travels
// as rax=tag, rdx=payload (the Str ptr/len convention reused); on the
// stack the tag is the first word, payload the second.

#[derive(Clone, PartialEq, Debug)]
enum Tok {
    Ident(String),
    Int(String),
    Str(String), // already unescaped content
    IncTok, DecTok, Plus, Minus, Star, Slash, Pct, Dollar, Caret,
    LParen, RParen, Comma,
    LBrace, RBrace, LBracket, RBracket, Pipe,
    Assign,   // :=
    Float(String, u8), // float literal: normalized text, written decimals
    Question, // ?
    QuestionQ, // ?? (QOut without the leading newline)
    At,       // @ by-reference call argument (hk216 family)
    Eq,       // =
    FatArrow, // =>
    Ne,       // <> or !=
    Lt, Le, Gt, Ge,
    KwFunction, KwLocal, KwReturn, KwNil, KwIf, KwElseif, KwElse, KwEndif, KwWhile, KwEnddo, KwExit, KwLoop,
    KwFor, KwTo, KwStep, KwNext, KwEach, KwIn,
    EqEq,       // == (measured: integers hk124, DArr identity hk126; object identity cl7/cl19 class-gated)
    Colon,      // : (message send, o:name)
    ColonColon, // :: (self member, inside a method)
    KwCreate, KwClass, KwEndclass, KwMethod, KwData, KwInherit, KwConstructor, KwInit, KwSelfTok,
    LogT, LogF, LogAnd, LogOr, LogNot, // dotted logical words (hk197-hk200)
}

#[derive(Clone, Copy, PartialEq, Debug)]
enum CmpOp { Eq, EqEq, Ne, Lt, Le, Gt, Ge, Contains } // EqEq: == measured for integers (hk124) and DArr identity (hk126)

static BLOCK_ID: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);

// Set only while a bare call STATEMENT is type-checked: a procedure-style
// call (no return value) is legal in statement position (hk216) even
// though its result cannot be USED in an expression. Single-threaded
// compiler; the flag is reset right after the call returns.
thread_local! {
    static CALL_STMT_CTX: std::cell::Cell<bool> = std::cell::Cell::new(false);
}

// f64 literal constants for the current program (rodata .Lf64cN), cleared
// per compilation unit where `strs` is created.
thread_local! {
    static F64_CONSTS: std::cell::RefCell<Vec<u64>> = std::cell::RefCell::new(Vec::new());
}
// Exact powers of ten for the single division in Harbour's literal parse
// (10^0..=10^22 are exactly representable in f64; the lexer caps written
// decimals at 17).
const P10: [f64; 18] = [
    1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9,
    1e10, 1e11, 1e12, 1e13, 1e14, 1e15, 1e16, 1e17,
];

// Harbour float-literal parse semantics (compiler branch of hb_str2number),
// measured against oracles hk278-hk289: digits accumulate in an i64 while
// they fit, the total converts to f64 and is divided ONCE by 10^decimals.
// This is NOT correct rounding: `9.999999999999999` accumulates to
// 9999999999999999, whose nearest f64 is exactly 1e16, so the literal IS
// 10.0 and prints "10.000000000000000" (oracle hk285); Rust's str::parse
// would give 9.9999999999999982 and print "...999999999999998". Own
// implementation written against oracles (Harbour is GPL+runtime-exception;
// no code copied). Reachability bound, by lexer/frontier rules (not
// hypothesis): the lexer caps written decimals at 17 and the precision
// frontier admits only (a) |x| < 1 with dec <= 17: the literal is "0" +
// "." + <= 17 fraction digits, so at most 18 digits accumulate, worst
// 999999999999999999 < i64::MAX; (b) int <= 14 with int+dec <= 15: <= 15
// digits; (c) int <= 9 with int+dec = 16: <= 16 digits; (d) int <= 2 with
// int+dec = 17: <= 17 digits. The switchover threshold LLIMV ~ 9.2e17 is
// only reachable from a 19th accumulated digit, which no admitted rule can
// produce, so the f64 fallback below (Harbour's overflow path) is
// unreachable from admitted literals; it is kept so the function stays
// total, and literals beyond these rules stay rejected by name.
fn harbour_parse_f64(txt: &str) -> Option<f64> {
    let (neg, s) = match txt.strip_prefix('-') {
        Some(r) => (true, r),
        None => (false, txt),
    };
    const LLIMV: i64 = i64::MAX / 10;
    const LLIMC: i64 = (i64::MAX % 10) as i64;
    let mut lval: i64 = 0;
    let mut dval: f64 = 0.0;
    let mut fdbl = false;
    let mut dec: usize = 0;
    let mut seen_dot = false;
    let mut any = false;
    for &b in s.as_bytes() {
        if b == b'.' && !seen_dot {
            seen_dot = true;
            continue;
        }
        if !b.is_ascii_digit() {
            return None;
        }
        any = true;
        let c = (b - b'0') as i64;
        if fdbl {
            dval = dval * 10.0 + c as f64;
        } else if lval < LLIMV || (lval == LLIMV && c <= LLIMC) {
            lval = lval * 10 + c;
        } else {
            dval = lval as f64 * 10.0 + c as f64;
            fdbl = true;
        }
        if seen_dot {
            dec += 1;
        }
    }
    if !any {
        return None;
    }
    let mut v = if fdbl { dval } else { lval as f64 };
    if dec > 0 {
        if dec >= P10.len() {
            return None;
        }
        v /= P10[dec];
    }
    Some(if neg { -v } else { v })
}

fn f64_const(bits: u64) -> usize {
    F64_CONSTS.with(|c| { let mut v = c.borrow_mut(); v.push(bits); v.len() - 1 })
}
// Numeric literal view for Harbour's compile-time fold (expropt2.c):
// Float/FloatV are doubles with their written/folded dec; Int is a long
// (dec 0). Returns (value, dec).
fn num_lit(e: &Expr) -> Option<(f64, u8)> {
    match e {
        Expr::Int(v) => v.parse::<i64>().ok().map(|k| (k as f64, 0)),
        Expr::Float(txt, dec) => harbour_parse_f64(txt).map(|v| (v, *dec)),
        Expr::FloatV(bits, dec) => Some((f64::from_bits(*bits), *dec)),
        _ => None,
    }
}

// Harbour compile-time fold of a constant numeric binary op (expropt2.c
// hb_compExprReducePlus/Minus/Mult/Div; oracles hk291/hk296/hk298).
// LONG x LONG: exact +,-,* fold to LONG; on i64 overflow they fold to a
// dec-0 DOUBLE like the VM's non-exact path (HB_DBL_LIM_LONG). / folds to
// LONG only when exact, otherwise to a DOUBLE whose dec is the current
// SET DECIMALS (the folded bDec = HB_DEFAULT_DECIMALS defers to the
// runtime setting, fixed at 2 in this PoC). With any DOUBLE operand the
// result is a DOUBLE with dec = max(+,-) / sum(*) / SET DECIMALS (2) for
// /. Returns None when Harbour itself would not fold (a zero divisor or
// unrepresentable int division): the runtime path handles those.
fn fold_num_bin(op: char, a: &Expr, b: &Expr) -> Option<Expr> {
    let ia = if let Expr::Int(v) = a { v.parse::<i64>().ok() } else { None };
    let ib = if let Expr::Int(v) = b { v.parse::<i64>().ok() } else { None };
    if let (Some(x), Some(y)) = (ia, ib) {
        match op {
            '+' => return Some(match x.checked_add(y) {
                Some(r) => Expr::Int(r.to_string()),
                None => Expr::FloatV((x as f64 + y as f64).to_bits(), 0),
            }),
            '-' => return Some(match x.checked_sub(y) {
                Some(r) => Expr::Int(r.to_string()),
                None => Expr::FloatV((x as f64 - y as f64).to_bits(), 0),
            }),
            '*' => return Some(match x.checked_mul(y) {
                Some(r) => Expr::Int(r.to_string()),
                None => Expr::FloatV((x as f64 * y as f64).to_bits(), 0),
            }),
            '/' => {
                if y != 0 && !(x == i64::MIN && y == -1) {
                    return Some(if x % y == 0 {
                        Expr::Int((x / y).to_string())
                    } else {
                        Expr::FloatV(((x as f64) / (y as f64)).to_bits(), 2)
                    });
                }
                return None;
            }
            // hb_compExprReduceMod: a nonzero divisor folds int%int to a
            // LONG (bDec=0; oracle hk340); zero defers to the runtime
            // (EG_ZERODIV substitution -> 0, oracle hk343).
            '%' => {
                if y != 0 { return Some(Expr::Int(x.checked_rem(y)?.to_string())); }
                return None;
            }
            // hb_compExprReducePower: literal ^ folds to a DOUBLE with
            // dec = HB_DEFAULT_DECIMALS (-> SET, 2) ALWAYS - unlike %,
            // no integer-preserving case (oracle hk350: 2^3 prints 8.00).
            // Harbour's fold calls C pow; this fold calls the same libm
            // powf, so folded literals track Harbour's fold.
            // NOTE: this fold uses libm powf while the runtime emits an
            // x87 fyl2x/f2xm1/fscale core - two DIFFERENT routes whose
            // agreement is only oracle-verified on the measured cases
            // (hk350-hk356), not a proven general bit-equality (63zj).
            '^' => return Some(Expr::FloatV((x as f64).powf(y as f64).to_bits(), 2)),
            _ => return None,
        }
    }
    let (va, da) = num_lit(a)?;
    let (vb, db) = num_lit(b)?;
    let (v, d) = match op {
        '+' => (va + vb, da.max(db)),
        '-' => (va - vb, da.max(db)),
        '*' => {
            // The folded dec lives in a u8 (FloatV); a sum that does not
            // fit DEFERS to the runtime path (63zd: saturating silently
            // printed the wrong dec; the runtime computes the real sum
            // and applies the 435-dec frontier guard).
            let s = da as u16 + db as u16;
            if s > 255 { return None; }
            (va * vb, s as u8)
        }
        '/' => {
            if vb == 0.0 { return None; }
            (va / vb, 2)
        }
        // fmod fold, dec = HB_DEFAULT_DECIMALS (SET, 2) like the runtime
        // (hk345); zero divisor defers (hk344).
        '%' => {
            if vb == 0.0 { return None; }
            (va % vb, 2)
        }
        '^' => (va.powf(vb), 2),
        _ => return None,
    };
    Some(Expr::FloatV(v.to_bits(), d))
}

// Load a float value into %xmm0 (value) and %rdi (packed metadata:
// Harbour item length in the high bits, dec in the low 16): literals,
// F64 locals and checked +,-,*,/ arithmetic on numeric values (phase 2). (hb_vmDivide: EVERY numeric division is a
// double with dec = SET DECIMALS, 2 by default - oracle hk292 prints 5.00
// for variable 10/2 while the compiler fold prints 5 for literal 10/2,
// expropt2.c hb_compExprReduceDiv + oracle hk291). Everything else is
// rejected by the checker before codegen.
fn cg_f64_load(e: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    match e {
        Expr::Seq(es) => {
            for e in &es[..es.len()-1] {
                if expr_ty(e, env, sigs) == Ty::F64 { cg_f64_load(e, env, sigs, strs, out, target); }
                else { cg_value(e, env, sigs, strs, out, target); }
            }
            cg_f64_load(es.last().expect("nonempty"), env, sigs, strs, out, target);
        }

        Expr::Float(txt, dec) => {
            let v: f64 = harbour_parse_f64(txt).expect("frontier-checked at parse");
            let k = f64_const(v.to_bits());
            // Packed metadata: Harbour literal length HB_DEFAULT_WIDTH (10)
            // in the high bits, dec in the low 16 bits.
            out.push_str(&format!("    movsd .Lf64c{}(%rip), %xmm0
    mov ${}, %rdi
", k, (10u32 << 16) | (*dec as u32)));
        }
        Expr::FloatV(bits, dec) => {
            // Harbour's fold sets bWidth = HB_DEFAULT_WIDTH (255): the
            // literal item resolves length from the VALUE with the
            // asymmetric HB_DBL_LENGTH rule - 20 when d > 9999999999.0 or
            // d < -999999999.0, else 10 (hbdefs.h:570; oracle hk298's
            // 9223372036854775807/3 pads to width 23, not 13).
            let v = f64::from_bits(*bits);
            let len: u32 = if v > 9999999999.0 || v < -999999999.0 { 20 } else { 10 };
            let k = f64_const(*bits);
            out.push_str(&format!("    movsd .Lf64c{}(%rip), %xmm0
    mov ${}, %rdi
", k, (len << 16) | (*dec as u32)));
        }
        Expr::Var(v) => {
            let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
            out.push_str(&format!("    movsd -{}(%rbp), %xmm0
    mov -{}(%rbp), %rdi
", var.off, var.off - 8));
        }
        Expr::Bin(op, a, b) => {
            // Harbour numeric arithmetic on values (hb_vmPlus/Minus/Mult/
            // Divide; oracles hk279/hk292/hk296/hk297): both operands are
            // doubles, integer operands convert with cvtsi2sd like the
            // VM's (double)n reads (hk300). dec = max(+,-), sum(*), SET
            // DECIMALS = 2 (/). Division by a real zero (0.0 or -0.0)
            // raises EG_ZERODIV (hk296 line 33); a NaN divisor is NOT
            // zero (ucomisd sets PF on unordered) and divides through to
            // NaN. The packed metadata carries the asymmetric
            // HB_DBL_LENGTH of the RESULT (hbdefs.h:570, 63zb).
            cg_f64_operand(a, env, sigs, strs, out, target);
            out.push_str("    sub $32, %rsp\n    movsd %xmm0, (%rsp)\n    mov %rcx, 8(%rsp)\n");
            cg_f64_operand(b, env, sigs, strs, out, target);
            if *op == '/' {
                let l = fresh_lbl();
                out.push_str(&format!("    xorpd %xmm2, %xmm2\n    ucomisd %xmm2, %xmm0\n    jp .Ldivok{}\n    jne .Ldivok{}\n    call hbc_div0_error\n.Ldivok{}:\n", l, l, l));
            }
            if *op == '^' {
                // pow(base, exp) via x87 fyl2x/f2xm1/fscale - hb_vmPower
                // (src/vm/hvm.c): hb_itemPutND(pow(...)), ALWAYS a double
                // with dec = SET(2) ("Clipper always returns the result of
                // power with the SET number of decimal places"; oracles
                // hk350-hk354). hb_compExprReducePower folds
                // literal^literal to a DOUBLE too (no integer-preserving
                // case, unlike %). Domain rules measured (hk353/hk355):
                // exp == 0 -> 1 (0^0 = 1); base 0 with exp > 0 -> 0, with
                // exp < 0 -> +Inf; base < 0 with a non-integer exp ->
                // NaN, with an integer exp -> the sign comes from its
                // oddness; NaN operands propagate. Non-finite results
                // print stars via the shared rule (NaN at length 10 = 13
                // wide, +Inf at 20 = 23 wide, hk355). pow(-0.0, negative)
                // yields +Inf here where C gives -Inf for odd integer
                // exponents - unmeasured frontier, registered.
                let b = fresh_lbl();
                let gen = fresh_lbl();
                let neg = fresh_lbl();
                let nan = fresh_lbl();
                let zero = fresh_lbl();
                let done = fresh_lbl();
                let cone = f64_const(0x3FF0000000000000u64); // 1.0
                let cinf = f64_const(0x7FF0000000000000u64); // +Inf
                let cnan = f64_const(0x7FF8000000000000u64); // quiet NaN
                let core = "    sub $16, %rsp\n    movsd %xmm0, 8(%rsp)\n    movsd %xmm1, (%rsp)\n    fldl 8(%rsp)\n    fldl (%rsp)\n    fyl2x\n    fld %st(0)\n    frndint\n    fxch %st(1)\n    fsub %st(1), %st(0)\n    f2xm1\n    fld1\n    faddp %st(0), %st(1)\n    fscale\n    fstp %st(1)\n    fstpl (%rsp)\n    movsd (%rsp), %xmm1\n    add $16, %rsp\n";
                out.push_str(&format!("    movsd (%rsp), %xmm1\n    xorpd %xmm2, %xmm2\n    ucomisd %xmm2, %xmm0\n    jp .LpB{b}\n    jne .LpB{b}\n    movsd .Lf64c{cone}(%rip), %xmm1\n    jmp .LpD{done}\n.LpB{b}:\n    ucomisd %xmm2, %xmm1\n    jp .LpG{gen}\n    ja .LpG{gen}\n    jne .LpN{neg}\n    ucomisd %xmm2, %xmm0\n    jp .LpNaN{nan}\n    ja .LpZ{zero}\n    movsd .Lf64c{cinf}(%rip), %xmm1\n    jmp .LpD{done}\n.LpZ{zero}:\n    xorpd %xmm1, %xmm1\n    jmp .LpD{done}\n.LpNaN{nan}:\n    movsd .Lf64c{cnan}(%rip), %xmm1\n    jmp .LpD{done}\n.LpN{neg}:\n    cvttsd2si %xmm0, %rax\n    cvtsi2sd %rax, %xmm3\n    ucomisd %xmm3, %xmm0\n    jp .LpNaN{nan}\n    jne .LpNaN{nan}\n    and $1, %eax\n    mov %eax, %r10d\n    xorpd %xmm3, %xmm3\n    subsd %xmm1, %xmm3\n    movsd %xmm3, %xmm1\n{core}    test %r10d, %r10d\n    jz .LpD{done}\n    xorpd %xmm4, %xmm4\n    subsd %xmm1, %xmm4\n    movsd %xmm4, %xmm1\n    jmp .LpD{done}\n.LpG{gen}:\n{core}.LpD{done}:\n    mov $2, %edi\n"));
            } else if *op == '%' {
                // fmod via x87 fprem (hk345: float % result has dec =
                // SET(2) like /). Zero divisor: integer-image 0.0 with
                // dec 0 (hk344); a NaN divisor is NOT zero and fmods
                // through to NaN (same rule as /, hk296).
                let mz = fresh_lbl();
                let mr = fresh_lbl();
                let md = fresh_lbl();
                out.push_str(&format!("    xorpd %xmm2, %xmm2\n    ucomisd %xmm2, %xmm0\n    jp .Lpmod{mz}\n    jne .Lpmod{mz}\n    xorpd %xmm1, %xmm1\n    xor %edi, %edi\n    jmp .Lpmodd{md}\n.Lpmod{mz}:\n    movsd (%rsp), %xmm1\n    sub $16, %rsp\n    movsd %xmm1, 8(%rsp)\n    movsd %xmm0, (%rsp)\n    fldl (%rsp)\n    fldl 8(%rsp)\n.Lpmr{mr}:\n    fprem\n    fnstsw %ax\n    test $4, %ah\n    jnz .Lpmr{mr}\n    fstpl 8(%rsp)\n    fstp %st(0)\n    movsd 8(%rsp), %xmm1\n    add $16, %rsp\n    mov $2, %edi\n.Lpmodd{md}:\n"));
            } else {
                out.push_str("    movsd (%rsp), %xmm1\n");
                let inst = match op { '+' => "addsd", '-' => "subsd", '*' => "mulsd", '/' => "divsd", _ => unreachable!("checked") };
                out.push_str(&format!("    {} %xmm0, %xmm1\n", inst));
            }
            // Result dec in %rdi: max for +,-, sum for *, SET(2) for /.
            match op {
                '+' | '-' => out.push_str("    mov 8(%rsp), %rdi\n    cmp %rcx, %rdi\n    cmovb %rcx, %rdi\n"),
                // dec = sum. Guard the sum against the u16 metadata and
                // the bounded 456-byte print scratch TOGETHER: dec <= 435
                // keeps length(<=20)+1+dec <= 456 for every length, so a
                // compute-produced value can never reach the printer's
                // range check, and no silent u16 wrap can launder an
                // overflowing dec into the length field (63zd; the fold
                // defers sums it cannot represent, so this runtime path
                // is the only dec producer that can reach the bound).
                '*' => {
                    // call, not ja: the helper's prologue expects a
                    // return-address stack layout (Wine ExitProcess faults
                    // on the jump form - battery t757/t769 on Wine).
                    let lok = fresh_lbl();
                    out.push_str(&format!("    mov 8(%rsp), %rdi\n    add %rcx, %rdi\n    cmp $435, %rdi\n    jbe .Lf64m{lok}\n    call hbc_f64range_error\n.Lf64m{lok}:\n"));
                }
                '/' => out.push_str("    mov $2, %edi\n"),
                '%' => {} // dec emitted with the fprem sequence above
                '^' => {} // dec emitted with the pow sequence above
                _ => unreachable!("checked"),
            }
            out.push_str("    add $32, %rsp\n");
            // Length: asymmetric HB_DBL_LENGTH - 20 when x > 9999999999.0
            // or x < -999999999.0, else 10 (hbdefs.h:570; hk297). NaN
            // fails both tests (unordered) and keeps 10.
            let kc = f64_const(9999999999.0f64.to_bits());
            let kn = f64_const(999999999.0f64.to_bits());
            let la = fresh_lbl();
            let lb = fresh_lbl();
            out.push_str(&format!("    mov $10, %eax\n    movsd .Lf64c{}(%rip), %xmm2\n    ucomisd %xmm2, %xmm1\n    ja .Lf64la{}\n    xorpd %xmm2, %xmm2\n    subsd %xmm1, %xmm2\n    movsd .Lf64c{}(%rip), %xmm3\n    ucomisd %xmm3, %xmm2\n    jbe .Lf64lb{}\n.Lf64la{}:\n    mov $20, %eax\n.Lf64lb{}:\n    shl $16, %rax\n    or %rax, %rdi\n    movsd %xmm1, %xmm0\n", kc, la, kn, lb, la, lb));
        }
        Expr::Call(..) => {
            // A float-returning call (63zd): the declared F64 return
            // convention IS the cg_f64_load pair - xmm0 = value bits,
            // rdi = packed metadata - so the ordinary call emission
            // leaves the result exactly where this loader promises it.
            cg_expr(e, env, sigs, strs, out, target);
        }
        _ => unreachable!("float expressions are literals, locals, calls or checked +,-,*,/ arithmetic"),
    }
}

// Load one operand of float arithmetic: value into %xmm0, its Harbour
// dec metadata into %ecx (0 for integers - hb_itemGetNDDec). Integers
// convert with cvtsi2sd like the VM's (double)n reads (oracle hk300:
// 2^53+1 rounds to 2^53 and compares .T. against 9007199254740992.0).
fn cg_f64_operand(e: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    if expr_ty(e, env, sigs) == Ty::F64 {
        cg_f64_load(e, env, sigs, strs, out, target);
        out.push_str("    mov %rdi, %rcx\n    movzwl %cx, %ecx\n");
    } else {
        cg_expr(e, env, sigs, strs, out, target);
        out.push_str("    cvtsi2sd %rax, %xmm0\n    xor %ecx, %ecx\n");
    }
}
thread_local! {
    static TRACE_ORIGINS: std::cell::RefCell<Vec<(String, usize)>> = std::cell::RefCell::new(Vec::new());
    static TRACE_BLOCK_LINES: std::cell::RefCell<std::collections::HashMap<usize, usize>> = std::cell::RefCell::new(std::collections::HashMap::new());
    static PROC_LINES: std::cell::RefCell<Vec<usize>> = std::cell::RefCell::new(Vec::new());
    static PROC_NAME: std::cell::RefCell<String> = std::cell::RefCell::new(String::new());
    // CUR_FN: the function whose body is being checked/emitted right now
    // (hb_PValue exposes ITS declared parameters - multiarg). IN_BLOCK:
    // set while a codeblock body is checked/emitted, where hb_PValue is a
    // named rejection (it would expose the block's own parameters).
    static CUR_FN: std::cell::RefCell<String> = std::cell::RefCell::new(String::new());
    static IN_BLOCK: std::cell::Cell<bool> = std::cell::Cell::new(false);
    static TRACE_LINE: std::cell::Cell<usize> = std::cell::Cell::new(0);
    static TRACE_OFFSET: std::cell::Cell<usize> = std::cell::Cell::new(0);
}
fn new_block_id() -> usize { BLOCK_ID.fetch_add(1, std::sync::atomic::Ordering::SeqCst) }

// Diagnostic records are native-frame locals, not a value stack or evaluator.
fn trace_location(name: &str, line: usize, strs: &mut Vec<String>, out: &mut String) {
    let (path, original) = TRACE_ORIGINS.with(|m| m.borrow().get(line.saturating_sub(1)).cloned())
        .unwrap_or_else(|| ("<unknown>".to_string(), line));
    let proc_line = PROC_LINES.with(|v| v.borrow().get(line.saturating_sub(1)).copied()).unwrap_or(original);
    TRACE_LINE.with(|v| v.set(proc_line));
    let text = format!("  at {} ({}:{})\n", name, path, original);
    let len = text.len();
    let id = strs.len(); strs.push(text);
    let off = TRACE_OFFSET.with(|o| o.get());
    // r11 is scratch in generated code; flags and value registers survive.
    out.push_str(&format!("    lea .Lstr{}(%rip), %r11\n    mov %r11, -{}(%rbp)\n    movq ${}, -{}(%rbp)\n", id, off - 8, len, off - 16));
}
fn trace_link(off: usize, out: &mut String) {
    TRACE_OFFSET.with(|o| o.set(off));
    out.push_str(&format!("    mov hbc_trace_top(%rip), %r11\n    mov %r11, -{}(%rbp)\n    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n    lea -{}(%rbp), %r11\n    mov %r11, hbc_trace_top(%rip)\n", off, off - 8, off - 16, off));
}
fn trace_unlink(off: usize, out: &mut String) {
    out.push_str(&format!("    mov -{}(%rbp), %r11\n    mov %r11, hbc_trace_top(%rip)\n", off));
}
fn stmt_line(s: &Stmt) -> usize {
    match s {
        Stmt::Local(n,..) | Stmt::Print(n,..) | Stmt::Ret(n,..) | Stmt::If(n,..) |
        Stmt::While(n,..) | Stmt::Assign(n,..) | Stmt::HDel(n,..) | Stmt::HDelAt(n,..) |
        Stmt::HClear(n,..) | Stmt::HFill(n,..) | Stmt::HMerge(n,..) | Stmt::HCopy(n,..) |
        Stmt::HSet(n,..) | Stmt::HSetCaseMatch(n,..) | Stmt::ArrSet(n,..) |
        Stmt::ArrSet2(n,..) | Stmt::ArrSet3(n,..) | Stmt::ArrSet4(n,..) |
        Stmt::SelfSet(n,..) | Stmt::SendSet(n,..) | Stmt::SendStmt(n,..) |
        Stmt::CallStmt(n,..) | Stmt::AAdd(n,..) | Stmt::AAddSub(n,..) |
        Stmt::ASizeSub(n,..) | Stmt::AAddSub2(n,..) | Stmt::ASizeSub2(n,..) |
        Stmt::AAddSub3(n,..) | Stmt::ASizeSub3(n,..) | Stmt::ASize(n,..) |
        Stmt::Exit(n) | Stmt::Loop(n) | Stmt::For(n,..) | Stmt::ForEach(n,..) => *n,
    }
}

// Unique-label counter for inline branches emitted by codegen: every
// emission of the same construct gets a fresh id, so two comparisons in
// one function (or one construct emitted twice) can never collide.
// Fixed numeric labels caused two silent miscompares (iteration 33b).
static LBL_ID: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
fn fresh_lbl() -> usize { LBL_ID.fetch_add(1, std::sync::atomic::Ordering::SeqCst) }

fn tokenize(line: &str, n: usize) -> Result<Vec<Tok>, String> {
    let mut toks = Vec::new();
    let mut it = line.char_indices().peekable();
    while let Some(&(i, c)) = it.peek() {
        if let Some(end)=pp::escape_literal_end(line,i) {
            let value=pp::decode_escape_literal(&line[i..end]).map_err(|e|format!("line {}: {}",n,e))?;
            while it.peek().map(|(at,_)|*at<end).unwrap_or(false){it.next();}
            toks.push(Tok::Str(value));continue;
        }
        match c {
            ' ' | '\t' => { it.next(); }
            '/' => {
                let mut look = it.clone();
                look.next();
                if look.peek().map(|&(_, c2)| c2) == Some('/') { break; } // comment
                toks.push(Tok::Slash);
                it.next();
            }
            '+' => { it.next(); if it.peek().map(|&(_,c)|c) == Some('+') { it.next(); toks.push(Tok::IncTok); } else { toks.push(Tok::Plus); } }
            '-' => { it.next(); if it.peek().map(|&(_,c)|c) == Some('-') { it.next(); toks.push(Tok::DecTok); } else { toks.push(Tok::Minus); } }
            '*' => {
                // Harbour `**` is the same power operator as `^` (hk356).
                it.next();
                if it.peek().map(|&(_, c2)| c2) == Some('*') { toks.push(Tok::Caret); it.next(); } else { toks.push(Tok::Star); }
            }
            '%' => { toks.push(Tok::Pct); it.next(); }
            '^' => { toks.push(Tok::Caret); it.next(); }
            '$' => { toks.push(Tok::Dollar); it.next(); }
            // The macro operator is runtime dynamic evaluation (oracles
            // hk369-hk373: it evaluates string contents as Harbour code
            // with real types, sees no locals in the expanded text, and
            // works in expression, statement and dynamic-send positions) -
            // it needs an evaluator embedded in the emitted binary, out of
            // this native increment. `&&` comments never reach the lexer
            // (the preprocessor strips them).
            '&' => return Err(format!("line {}: the macro operator `&` is runtime dynamic evaluation (hk369-hk373): it would need an evaluator embedded in the emitted binary - a named limit of this native increment, not a Harbour error", n)),
            '(' => { toks.push(Tok::LParen); it.next(); }
            ')' => { toks.push(Tok::RParen); it.next(); }
            ',' => { toks.push(Tok::Comma); it.next(); }
            '?' => {
                it.next();
                if it.peek().map(|&(_, c2)| c2) == Some('?') { toks.push(Tok::QuestionQ); it.next(); } else { toks.push(Tok::Question); }
            }
            ':' => {
                it.next();
                match it.peek() {
                    Some(&(_, '=')) => { toks.push(Tok::Assign); it.next(); }
                    Some(&(_, ':')) => { toks.push(Tok::ColonColon); it.next(); }
                    _ => toks.push(Tok::Colon),
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
                        // Ordinary Harbour quotes are raw, including a
                        // backslash directly before the closing quote.
                        // Escape strings e"..." are a separate syntax.
                        c3 => s.push(c3),
                    }
                }
                if !closed { return Err(format!("line {}: unterminated string", n)); }
                toks.push(Tok::Str(s));
            }
            '\'' => {
                // Single-quoted strings (oracle hk213): same string type,
                // the other quote nests freely. NO escapes (hk213b: a
                // backslash is a literal character), like ordinary double quotes.
                it.next();
                let mut s = String::new();
                let mut closed = false;
                while let Some(&(_, c2)) = it.peek() {
                    it.next();
                    if c2 == '\'' { closed = true; break; }
                    s.push(c2);
                }
                if !closed { return Err(format!("line {}: unterminated string", n)); }
                toks.push(Tok::Str(s));
            }
            c if c.is_ascii_digit() => {
                let mut num = String::new();
                while let Some(&(_, c2)) = it.peek() {
                    if c2.is_ascii_digit() { num.push(c2); it.next(); } else { break; }
                }
                // Hex literal 0xABAB (oracle hk281: prints as a plain
                // integer, 43947, 10-column field).
                if num == "0" && matches!(it.peek(), Some(&(_, 'x')) | Some(&(_, 'X'))) {
                    it.next();
                    let mut hx = String::new();
                    while let Some(&(_, c2)) = it.peek() {
                        if c2.is_ascii_hexdigit() { hx.push(c2); it.next(); } else { break; }
                    }
                    if hx.is_empty() { return Err(format!("line {}: `0x` needs at least one hex digit", n)); }
                    let v = u128::from_str_radix(&hx, 16).map_err(|_| format!("line {}: bad hex literal", n))?;
                    toks.push(Tok::Int(v.to_string()));
                    continue;
                }
                // Float literal digits.digits (the dot joins only when a
                // digit follows; otherwise it starts a dotted word).
                if it.peek().map(|&(_, c2)| c2) == Some('.') {
                    let mut look = it.clone();
                    look.next();
                    if look.peek().map(|&(_, c2)| c2).map(|c| c.is_ascii_digit()) == Some(true) {
                        it.next();
                        let mut frac = String::new();
                        while let Some(&(_, c2)) = it.peek() {
                            if c2.is_ascii_digit() { frac.push(c2); it.next(); } else { break; }
                        }
                        if frac.len() > 17 {
                            return Err(format!("line {}: float literal with more than 17 written decimals is outside this increment's measured precision frontier (oracles hk278-hk284)", n));
                        }
                        let d = frac.len() as u8;
                        toks.push(Tok::Float(format!("{}.{}", num, frac), d));
                        continue;
                    }
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
                    "func" => Tok::KwFunction, // 4-letter abbreviation (hk249)
                    // Harbour PROCEDURE: a function without an explicit
                    // return value (it answers NIL in expression context;
                    // a RETURN <expr> inside one is a registered
                    // difference, not oracle-measured yet).
                    "procedure" => Tok::KwFunction,
                    "proc" => Tok::KwFunction, // 4-letter abbreviation (hk249)
                    "local" => Tok::KwLocal,
                    "return" => Tok::KwReturn,
                    "nil" => Tok::KwNil,
                    "if" => Tok::KwIf,
                    "elseif" => Tok::KwElseif,
                    "else" => Tok::KwElse,
                    "endif" => Tok::KwEndif,
                    "while" => Tok::KwWhile,
                    "enddo" => Tok::KwEnddo,
                    "exit" => Tok::KwExit,
                    "loop" => Tok::KwLoop,
                    "for" => Tok::KwFor,
                    "each" => Tok::KwEach,
                    "in" => Tok::KwIn,
                    "to" => Tok::KwTo,
                    "step" => Tok::KwStep,
                    "next" => Tok::KwNext,
                    "create" => Tok::KwCreate,
                    "class" => Tok::KwClass,
                    "endclass" => Tok::KwEndclass,
                    "method" => Tok::KwMethod,
                    "data" => Tok::KwData,
                    "inherit" => Tok::KwInherit,
                    "constructor" => Tok::KwConstructor,
                    "init" => Tok::KwInit,
                    "self" => Tok::KwSelfTok,
                    // Harbour identifiers are case-insensitive: MAIN/main,
                    // QOut/qout and locals in any casing are the same name.
                    // Normalize at the token level so every later pass
                    // (defs, calls, locals) compares one canonical form.
                    _ => Tok::Ident(id.to_ascii_lowercase()),
                });
            }
            '=' => {
                it.next();
                match it.peek() {
                    Some(&(_, '>')) => { toks.push(Tok::FatArrow); it.next(); }
                    Some(&(_, '=')) => { toks.push(Tok::EqEq); it.next(); }
                    _ => toks.push(Tok::Eq),
                }
            }
            '!' => {
                // Harbour `!` is the prefix .NOT. (oracle hk212: same
                // operand and precedence as the dotted word); `!=` stays
                // the not-equal comparison.
                it.next();
                match it.peek() {
                    Some(&(_, '=')) => { toks.push(Tok::Ne); it.next(); }
                    _ => toks.push(Tok::LogNot),
                }
            }
            '<' => {
                it.next();
                match it.peek() {
                    Some(&(_, '=')) => { toks.push(Tok::Le); it.next(); }
                    Some(&(_, '>')) => { toks.push(Tok::Ne); it.next(); }
                    _ => toks.push(Tok::Lt),
                }
            }
            '>' => {
                it.next();
                match it.peek() {
                    Some(&(_, '=')) => { toks.push(Tok::Ge); it.next(); }
                    _ => toks.push(Tok::Gt),
                }
            }
            '@' => { toks.push(Tok::At); it.next(); }
            '{' => { toks.push(Tok::LBrace); it.next(); }
            '}' => { toks.push(Tok::RBrace); it.next(); }
            '[' => {
                let expression_end=matches!(toks.last(),Some(Tok::Ident(_)|Tok::Int(_)|Tok::Float(_,_)|Tok::Str(_)|Tok::KwNil|Tok::LogT|Tok::LogF|Tok::KwSelfTok|Tok::RParen|Tok::RBracket|Tok::RBrace|Tok::IncTok|Tok::DecTok));
                if expression_end {toks.push(Tok::LBracket);it.next();}
                else {
                    it.next();let mut value=String::new();let mut closed=false;
                    while let Some((_,c))=it.next() {if c==']' {closed=true;break;}value.push(c);}
                    if !closed {return Err(format!("line {}: unterminated bracket string",n));}
                    toks.push(Tok::Str(value));
                }
            }
            '|' => { toks.push(Tok::Pipe); it.next(); }
            ']' => { toks.push(Tok::RBracket); it.next(); }
            '.' => {
                // Leading-dot float literal `.12` (oracle hk278: prints
                // exactly like `0.12`).
                if it.clone().nth(1).map(|(_, c2)| c2.is_ascii_digit()) == Some(true) {
                    it.next();
                    let mut frac = String::new();
                    while let Some(&(_, c2)) = it.peek() {
                        if c2.is_ascii_digit() { frac.push(c2); it.next(); } else { break; }
                    }
                    if frac.len() > 17 {
                        return Err(format!("line {}: float literal with more than 17 written decimals is outside this increment's measured precision frontier (oracles hk278-hk284)", n));
                    }
                    let d = frac.len() as u8;
                    toks.push(Tok::Float(format!("0.{}", frac), d));
                    continue;
                }
                // Dotted logical words (hk197-hk200): .T. .F. .AND. .OR.
                // .NOT. - case-insensitive, no inner spaces, closing dot
                // required (hk199c: .NOT..F. is valid).
                it.next();
                let mut w = String::new();
                while let Some(&(_, c2)) = it.peek() {
                    if c2.is_ascii_alphabetic() { w.push(c2); it.next(); } else { break; }
                }
                match it.peek() {
                    Some(&(_, '.')) => { it.next(); }
                    _ => return Err(format!("line {}: unterminated dotted word `.{}` (Harbour logical tokens need a closing dot)", n, w)),
                }
                toks.push(match w.to_ascii_lowercase().as_str() {
                    "t" => Tok::LogT,
                    "f" => Tok::LogF,
                    "and" => Tok::LogAnd,
                    "or" => Tok::LogOr,
                    "not" => Tok::LogNot,
                    _ => return Err(format!("line {}: unknown dotted word `.{}.` (only .T. .F. .AND. .OR. .NOT. measured, hk197-hk200)", n, w)),
                });
            }
            o => return Err(format!("line {}: character not allowed `{}` (U+{:04X})", n, o, o as u32)),
        }
    }
    Ok(toks)
}

#[derive(Debug, Clone)]
enum Expr {
    FloatV(u64, u8), // compiler-folded float constant (Harbour division fold, expropt2.c hb_compExprReduceDiv): IEEE-754 bits, decimal metadata
    Float(String, u8), // float literal: normalized text, written decimal count
    Int(String),
    Str(String),
    Var(String),
    Seq(Vec<Expr>), // parenthesized scalar list, value is the last expression
    Inc(String, i8, bool), // variable lvalue, delta +1/-1, prefix flag
    Call(String, Vec<Expr>),
    ByRef(String),             // `@x` call argument: exclusive borrow of the caller's slot (hk216 family; alias rejection diverges from hk219, registered)
    Bin(char, Box<Expr>, Box<Expr>),
    Cmp(CmpOp, Box<Expr>, Box<Expr>), // i64 operands only (checked in analysis)
    ArrLit(Vec<Expr>),             // {e1, ..., eN}; i64 elements, fixed size
    Index(String, Box<Expr>),      // a[i]; Harbour base 1 (probe a1)
    Index2(String, Box<Expr>, Box<Expr>),
    Index3(String, Box<Expr>, Box<Expr>, Box<Expr>), // a[i][j] / a[i,j] on a DArr2 (probe m1/m2)
    Index4(String, Box<Expr>, Box<Expr>, Box<Expr>, Box<Expr>), // a[i,j,k,l] / a[i][j][k][l] on a DArr4 (hk103-hk107)
    IdxCompound(String, Box<Expr>, char, Box<Expr>), // a[i] op= e as a value (op +,-,*; tests/arrayidx.prg): the index runs once and first, the right side once and second, the expression yields the NEW cell
    BlockLit(usize, Vec<String>, Vec<Expr>), // {|p1, p2| e1, e2} -> last (probes c1-c5)
    DArrNew,                     // {} : empty DYNAMIC array (probes d1, e4)
    SelfObj,                     // Self (oracle cl2: return Self chains)
    SelfGet(String),             // ::name inside a method (class parser landed; codegen pending)
    Send(Box<Expr>, String, Vec<Expr>), // obj:name(args) / obj:name - Harbour message send (cl1/cl10)
    Nil,                         // NIL: tagged i64 sentinel (probes n1: prints NIL, NIL==NIL .T., NIL==0 .F.)
    // Hash literal: string keys, i64 values (v1). {=>} is the empty
    // hash; {} stays the empty dynamic array.
    HashLit(Vec<(Expr, Expr)>),
    Log(bool),                   // .T./.F. (hk197)
    LNot(Box<Expr>),             // .NOT. x (hk197)
    LAnd(Box<Expr>, Box<Expr>),  // x .AND. y, short-circuit (hk203)
    LOr(Box<Expr>, Box<Expr>),   // x .OR. y, short-circuit (hk203)
}

#[derive(Debug)]
enum Stmt {
    Local(usize, String, Expr),
    Print(usize, Vec<Expr>, bool), // bool: true = `??` (no leading newline)
    Ret(usize, Option<Expr>),
    If(usize, Expr, Vec<Stmt>, Vec<Stmt>), // line, condition, then, else (possibly empty)
    While(usize, Expr, Vec<Stmt>), // line, condition, body
    Assign(usize, String, Expr),   // x := expr on an already-declared local
    HDel(usize, String, Expr), // hb_HDel(h, key) statement: remove the key's entry (hk155/hk156)
    HDelAt(usize, String, Expr), // hb_HDelAt(h, n) statement: remove the entry at the 1-based position (hk187/hk190)
    HClear(usize, String), // hb_HClear(h) statement: empty the hash, resetting the CaseMatch flag (hk191/hk193)
    HFill(usize, String, Expr), // hb_HFill(h, value) statement: overwrite every value, keys/order kept (hk192)
    HMerge(usize, String, String), // hb_HMerge(dst, src) statement: upsert every src entry into dst (hk164/hk165)
    HCopy(usize, String, String, Option<Expr>, Option<Expr>), // hb_HCopy(src, dst [, start [, count]]) statement: upsert the src range into dst (hk195 family)
    HSet(usize, String, Expr, Expr), // hb_HSet(h, key, value) statement: functional hash write (hk159/hk161); the hash it returns is out of the statement surface (registered)
    HSetCaseMatch(usize, String, Expr), // hb_HSetCaseMatch(h, flag) statement: set the hash's key-matching mode (hk169/hk170); the hash it returns is out of the statement surface (registered, like hb_HSet's)
    ArrSet(usize, String, Expr, Expr), // a[i] := expr (index is 1-based)
    ArrSet2(usize, String, Expr, Expr, Expr), // a[i][j] := expr / a[i,j] := expr
    ArrSet3(usize, String, Expr, Expr, Expr, Expr), // a[i][j][k] := expr
    ArrSet4(usize, String, Expr, Expr, Expr, Expr, Expr), // a[i][j][k][l] := expr / comma form (hk104/hk107)
    SelfSet(usize, String, Expr),       // ::name := expr
    SendSet(usize, Expr, String, Expr), // obj:name := expr (simple receiver)
    SendStmt(usize, Expr),              // obj:name(args) used as a statement
    CallStmt(usize, Expr),              // bare f(args) statement (oracle hk216): runs for effect, return discarded
    AAdd(usize, String, Expr),  // AAdd(a, x): grow dynamic array in place (probe d1)
    AAddSub(usize, String, Expr, Expr), // AAdd(a[i], x): grow the subarray (probe m5)
    ASizeSub(usize, String, Expr, Expr), // ASize(a[i], n): resize the subarray
    AAddSub2(usize, String, Expr, Expr, Expr), // AAdd(a[i][j], x): grow the innermost subarray (oracle pr8)
    ASizeSub2(usize, String, Expr, Expr, Expr), // ASize(a[i][j], n): resize the innermost subarray
    AAddSub3(usize, String, Expr, Expr, Expr, Expr), // AAdd(a[i][j][k], x) on a DArr4 (hk105/hk108)
    ASizeSub3(usize, String, Expr, Expr, Expr, Expr), // ASize(a[i][j][k], n) on a DArr4 (hk105)
    ASize(usize, String, Expr), // ASize(a, n): resize in place (probe d3)
    Exit(usize),                 // exit: leave the innermost loop
    Loop(usize),                 // loop: jump to the next iteration of the innermost loop
    For(usize, String, Expr, Expr, i64, Vec<Stmt>), // line, var, start, end, step (non-zero literal), body
    ForEach(usize, String, Expr, Vec<Stmt>), // line, var, collection (borrowed), body
}

struct Func {
    name: String,
    params: Vec<String>,
    ret: Option<Ty>,
    stmts: Vec<Stmt>,
    // Locals widened to Dyn by prescan (a later assignment can deliver a
    // NIL-capable value, probe n2). Filled in the infer loop, used by cg.
    dyn_names: std::collections::HashSet<String>,
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
                Some(Tok::Plus) => {
                    self.pos += 1;
                    '+'
                }
                Some(Tok::Minus) => {
                    self.pos += 1;
                    '-'
                }
                _ => break,
            };
            let rhs = self.term()?;
            // Harbour compile-time fold (expropt2.c; fold_num_bin).
            if let Some(f) = fold_num_bin(op, &lhs, &rhs) {
                lhs = f;
            } else {
                lhs = Expr::Bin(op, Box::new(lhs), Box::new(rhs));
            }
        }
        Ok(lhs)
    }
    fn power(&mut self) -> Result<Expr, String> {
        // Harbour `^` / `**` (oracles hk350-hk356): LEFT-associative
        // (2^3^2 = 64.00, hk353) and binds LOOSER than unary minus
        // (-2^2 = 4.00, hk351), so the operands are factor-level.
        // Always a DOUBLE with dec = SET(2), literal or runtime
        // (hb_compExprReducePower / hb_vmPower).
        let mut lhs = self.factor()?;
        while self.peek() == Some(&Tok::Caret) {
            self.pos += 1;
            let rhs = self.factor()?;
            if let Some(f) = fold_num_bin('^', &lhs, &rhs) {
                lhs = f;
            } else {
                lhs = Expr::Bin('^', Box::new(lhs), Box::new(rhs));
            }
        }
        Ok(lhs)
    }
    fn term(&mut self) -> Result<Expr, String> {
        let mut lhs = self.power()?;
        loop {
            let op = match self.peek() {
                Some(Tok::Star) => '*',
                Some(Tok::Slash) => '/',
                Some(Tok::Pct) => '%',
                _ => break,
            };
            self.pos += 1;
            let rhs = self.power()?;
            // Harbour compile-time fold of constant numeric arithmetic
            // (expropt2.c hb_compExprReducePlus/Minus/Mult/Div; oracles
            // hk291/hk296/hk298): see fold_num_bin. A zero divisor is NOT
            // folded (runtime EG_ZERODIV); i64::MIN / -1 takes the
            // runtime double path (oracle hk293).
            if let Some(f) = fold_num_bin(op, &lhs, &rhs) {
                lhs = f;
            } else {
                lhs = Expr::Bin(op, Box::new(lhs), Box::new(rhs));
            }
        }
        Ok(lhs)
    }
    fn factor(&mut self) -> Result<Expr, String> {
        // Message-send postfix (oracles cl1/cl2/cl10): o:name, o:name(args),
        // chains o:M():N(). o:name without parens is ALSO a send - the
        // method wins over a same-named DATA (cl10), DATA read is the
        // fallback; both resolve in codegen, not here.
        let mut e = self.factor_primary()?;
        while self.peek() == Some(&Tok::Colon) {
            self.pos += 1;
            let name = match self.bump() {
                Some(Tok::Ident(id)) => { check_ident(&id, self.n)?; id }
                other => return Err(format!("line {}: expected a member name after `:`, got {:?}", self.n, other)),
            };
            let mut args: Vec<Expr> = Vec::new();
            if self.peek() == Some(&Tok::LParen) {
                self.pos += 1;
                if self.peek() != Some(&Tok::RParen) {
                    loop {
                        args.push(self.expr()?);
                        match self.bump() {
                            Some(Tok::Comma) => continue,
                            Some(Tok::RParen) => break,
                            other => return Err(format!("line {}: expected `,` or `)` in the message arguments, got {:?}", self.n, other)),
                        }
                    }
                } else {
                    self.pos += 1;
                }
            }
            e = Expr::Send(Box::new(e), name, args);
        }
        if matches!(self.peek(), Some(Tok::IncTok | Tok::DecTok)) {
            let delta = if self.peek() == Some(&Tok::IncTok) { 1 } else { -1 };
            self.pos += 1;
            let id = match e {
                Expr::Var(id) => id,
                _ => return Err(format!("line {}: expression ++/-- requires a variable lvalue in this increment", self.n)),
            };
            e = Expr::Inc(id, delta, false);
        }
        Ok(e)
    }
    fn factor_primary(&mut self) -> Result<Expr, String> {
        match self.bump() {
            Some(Tok::KwIf) if self.peek() == Some(&Tok::LParen) => {
                // IF(...) is Harbour's inline IIF alias, not a block IF.
                self.pos -= 1;
                self.toks[self.pos] = Tok::Ident("iif".to_string());
                self.factor_primary()
            }
            Some(Tok::IncTok) => {
                let e = self.factor()?;
                match e {
                    Expr::Var(id) => Ok(Expr::Inc(id, 1, true)),
                    _ => Err(format!("line {}: expression ++/-- requires a variable lvalue in this increment", self.n)),
                }
            }
            Some(Tok::DecTok) => {
                let e = self.factor()?;
                match e {
                    Expr::Var(id) => Ok(Expr::Inc(id, -1, true)),
                    _ => Err(format!("line {}: expression ++/-- requires a variable lvalue in this increment", self.n)),
                }
            }
            // Harbour parser discards unary plus without coercion:
            // harbour.y: '+' Expression %prec UNARY { $$ = $2; }.
            // Keep lexical ++ distinct, so spaced + +x is not a mutation.
            Some(Tok::Plus) => self.factor(),
            // Harbour unary minus (probe q1: `? -7`): sugar for 0 - e, so
            // the i64 typing/codegen path applies unchanged.
            Some(Tok::Minus) => {
                let e = self.factor()?;
                // Unary minus on a float LITERAL folds at parse time (hk278
                // measures -5.5 printing; float arithmetic is not in).
                if let Expr::Float(txt, dec) = e {
                    return Ok(Expr::Float(format!("-{}", txt), dec));
                }
                if let Expr::FloatV(bits, dec) = e {
                    return Ok(Expr::FloatV(bits ^ (1u64 << 63), dec));
                }
                // Folded integer negation keeps Harbour's constant fold
                // intact through division: `-8/2` folds to LONG -4 like
                // Harbour (expropt2.c), not a runtime 0-8 double divide
                // printing "-4.00".
                if let Expr::Int(v) = e {
                    return Ok(Expr::Int(format!("-{}", v)));
                }
                Ok(Expr::Bin('-', Box::new(Expr::Int("0".to_string())), Box::new(e)))
            }
            Some(Tok::Int(v)) => {
                match v.parse::<u128>() {
                    Ok(k) if k <= i64::MAX as u128 => Ok(Expr::Int(v)),
                    _ => Err(format!("line {}: integer literal out of range (i64)", self.n)),
                }
            }
            Some(Tok::Float(txt, dec)) => {
                // Measured precision frontier (oracles hk278-hk288).
                // Harbour's `*` overflow is a value-dependent artifact of
                // its hb_itemStrBuf digit-extraction loop (carry running
                // off the left edge of the field), not a clean magnitude
                // rule: measured stars at (int,dec) = (14,2) (10,6) (11,5)
                // (12,4) (13,3) (10,7) (15,1) (16,1-all-nines) and printing
                // at (14,1) (9,7) (8,8) (5,11) (3,13) (12,3) (16,1) (17,1).
                // We reject the whole artifact zone instead of imitating
                // it: admitted = |x| < 1 with dec <= 17, or int+dec <= 15
                // with int <= 14, or int <= 9 with int+dec = 16, or
                // int <= 2 with int+dec = 17; nonzero |x| >= 1e-17;
                // <= 17 written decimals (checked at the lexer).
                let v: f64 = harbour_parse_f64(&txt).ok_or_else(|| format!("line {}: bad float literal", self.n))?;
                let a = v.abs();
                let intd = txt.split('.').next().unwrap_or("").len() as u32;
                let decd = txt.split('.').nth(1).map(|f| f.len() as u32).unwrap_or(0);
                let ok = a == 0.0
                    || (a >= 1e-17 && a < 1.0)
                    || (a >= 1.0 && intd <= 14 && intd + decd <= 15)
                    || (a >= 1.0 && intd <= 9 && intd + decd == 16)
                    || (a >= 1.0 && intd <= 2 && intd + decd == 17);
                if !ok {
                    return Err(format!("line {}: float literal outside this increment's measured precision frontier (oracles hk278-hk288)", self.n));
                }
                Ok(Expr::Float(txt, dec))
            }
            Some(Tok::Str(s)) => Ok(Expr::Str(s)),
            Some(Tok::KwNil) => Ok(Expr::Nil),
            Some(Tok::KwSelfTok) => Ok(Expr::SelfObj),
            Some(Tok::ColonColon) => {
                match self.bump() {
                    Some(Tok::Ident(id)) => { check_ident(&id, self.n)?; Ok(Expr::SelfGet(id)) }
                    other => return Err(format!("line {}: expected a member name after `::`, got {:?}", self.n, other)),
                }
            }
            Some(Tok::Ident(id)) => {
                if self.peek() == Some(&Tok::LParen) {
                    self.pos += 1;
                    let mut args: Vec<Expr> = Vec::new();
                    if self.peek() != Some(&Tok::RParen) {
                        loop {
                            if id == "iif" && !args.is_empty() && matches!(self.peek(), Some(Tok::Comma | Tok::RParen)) {
                                // Only inline-IF branch arguments may be empty
                                // here. Harbour Argument -> empty means NIL.
                                args.push(Expr::Nil);
                            } else if self.peek() == Some(&Tok::At) {
                                // `@x`: by-reference argument (hk216). One
                                // variable only, never an expression -
                                // Harbour rejects `@x + 1` at compile time
                                // too (oracle hk221).
                                self.pos += 1;
                                match self.bump() {
                                    Some(Tok::Ident(vn)) => args.push(Expr::ByRef(vn)),
                                    other => return Err(format!("line {}: `@` expects a variable name, got {:?}", self.n, other)),
                                }
                            } else {
                                // Full expression level (63ze; oracle
                                // hk322): a comparison/logical is a
                                // first-class Bool VALUE (hk198), legal
                                // in argument position.
                                args.push(self.or_expr()?);
                            }
                            match self.bump() {
                                Some(Tok::Comma) => continue,
                                Some(Tok::RParen) => break,
                                other => return Err(format!("line {}: expected `,` or `)` in call arguments, got {:?}", self.n, other)),
                            }
                        }
                    } else {
                        self.pos += 1;
                    }
                    Ok(Expr::Call(id, args))
                } else if self.peek() == Some(&Tok::LBracket) {
                    // a[i], a[i][j] and a[i,j] (probe m2: the comma form
                    // is the same nested access in Harbour)
                    self.pos += 1;
                    let idx = self.expr()?;
                    match self.bump() {
                        Some(Tok::RBracket) => {}
                        Some(Tok::Comma) => {
                            let idx2 = self.expr()?;
                            match self.bump() {
                                Some(Tok::RBracket) => return Ok(Expr::Index2(id, Box::new(idx), Box::new(idx2))),
                                Some(Tok::Comma) => {
                                    let idx3 = self.expr()?;
                                    match self.bump() {
                                        Some(Tok::RBracket) => return Ok(Expr::Index3(id, Box::new(idx), Box::new(idx2), Box::new(idx3))),
                                        Some(Tok::Comma) => {
                                            let idx4 = self.expr()?;
                                            if self.bump() != Some(Tok::RBracket) {
                                                return Err(format!("line {}: more than four index levels are not in this increment", self.n));
                                            }
                                            return Ok(Expr::Index4(id, Box::new(idx), Box::new(idx2), Box::new(idx3), Box::new(idx4)));
                                        }
                                        other => return Err(format!("line {}: expected `]` after the third array index, got {:?}", self.n, other)),
                                    }
                                }
                                other => return Err(format!("line {}: expected `]` after the second array index, got {:?}", self.n, other)),
                            }
                        }
                        other => return Err(format!("line {}: expected `]` after the array index, got {:?}", self.n, other)),
                    }
                    if self.peek() == Some(&Tok::LBracket) {
                        self.pos += 1;
                        let idx2 = self.expr()?;
                        if self.bump() != Some(Tok::RBracket) {
                            return Err(format!("line {}: expected `]` after the second array index", self.n));
                        }
                        if self.peek() == Some(&Tok::LBracket) {
                            self.pos += 1;
                            let idx3 = self.expr()?;
                            if self.bump() != Some(Tok::RBracket) {
                                return Err(format!("line {}: expected `]` after the third array index", self.n));
                            }
                            if self.peek() == Some(&Tok::LBracket) {
                                self.pos += 1;
                                let idx4 = self.expr()?;
                                if self.bump() != Some(Tok::RBracket) {
                                    return Err(format!("line {}: expected `]` after the fourth array index", self.n));
                                }
                                if self.peek() == Some(&Tok::LBracket) {
                                    return Err(format!("line {}: more than four index levels are not in this increment", self.n));
                                }
                                return Ok(Expr::Index4(id, Box::new(idx), Box::new(idx2), Box::new(idx3), Box::new(idx4)));
                            }
                            return Ok(Expr::Index3(id, Box::new(idx), Box::new(idx2), Box::new(idx3)));
                        }
                        return Ok(Expr::Index2(id, Box::new(idx), Box::new(idx2)));
                    }
                    Ok(Expr::Index(id, Box::new(idx)))
                } else {
                    Ok(Expr::Var(id))
                }
            }
            Some(Tok::LParen) => {
                let e = self.or_expr()?;
                if self.peek() == Some(&Tok::Comma) {
                    let mut es = vec![e];
                    while self.peek() == Some(&Tok::Comma) {
                        self.pos += 1;
                        es.push(self.or_expr()?);
                    }
                    if self.bump() != Some(Tok::RParen) {
                        return Err(format!("line {}: missing ) after expression list", self.n));
                    }
                    return Ok(Expr::Seq(es));
                }
                if self.bump() != Some(Tok::RParen) {
                    return Err(format!("line {}: missing )", self.n));
                }
                Ok(e)
            }
            Some(Tok::LBrace) => {
                if self.peek() == Some(&Tok::Pipe) {
                    // Codeblock {|p1, p2| e1, ..., eN}: comma-separated
                    // expressions, the value is the LAST one (probe c4).
                    // No captures in this increment (v1).
                    self.pos += 1;
                    let mut params: Vec<String> = Vec::new();
                    loop {
                        match self.bump() {
                            Some(Tok::Pipe) => break,
                            Some(Tok::Ident(id)) => {
                                check_ident(&id, self.n)?;
                                if params.iter().any(|p| *p == id) {
                                    return Err(format!("line {}: duplicate codeblock parameter `{}`", self.n, id));
                                }
                                params.push(id);
                                match self.bump() {
                                    Some(Tok::Comma) => continue,
                                    Some(Tok::Pipe) => break,
                                    other => return Err(format!("line {}: expected `,` or `|` in the codeblock parameters, got {:?}", self.n, other)),
                                }
                            }
                            other => return Err(format!("line {}: expected codeblock parameters between `|`, got {:?}", self.n, other)),
                        }
                    }
                    let mut body = Vec::new();
                    loop {
                        body.push(self.expr()?);
                        match self.bump() {
                            Some(Tok::Comma) => continue,
                            Some(Tok::RBrace) => break,
                            other => return Err(format!("line {}: expected `,` or `}}` in the codeblock body, got {:?}", self.n, other)),
                        }
                    }
                    let id = new_block_id();
                    TRACE_BLOCK_LINES.with(|m| m.borrow_mut().insert(id, self.n));
                    return Ok(Expr::BlockLit(id, params, body));
                }
                // {} is the empty DYNAMIC array value (probes d1, e4);
                // non-empty literals stay fixed-size stack arrays.
                if self.peek() == Some(&Tok::RBrace) {
                    self.pos += 1;
                    return Ok(Expr::DArrNew);
                }
                // {=>} is the EMPTY HASH (probe h2: len 0); {} above is
                // the empty dynamic array - different types in Harbour too.
                if self.peek() == Some(&Tok::FatArrow) {
                    self.pos += 1;
                    if self.bump() != Some(Tok::RBrace) {
                        return Err(format!("line {}: expected `}}` after `{{=>`", self.n));
                    }
                    return Ok(Expr::HashLit(Vec::new()));
                }
                let mut items = Vec::new();
                let first = self.expr()?;
                if self.peek() == Some(&Tok::FatArrow) {
                    // Hash literal {k => v, ...} (probes d4, h5).
                    let mut pairs = Vec::new();
                    let mut key = first;
                    loop {
                        if self.bump() != Some(Tok::FatArrow) {
                            return Err(format!("line {}: expected `=>` after the hash key, got {:?}", self.n, self.peek()));
                        }
                        let val = self.expr()?;
                        pairs.push((key, val));
                        match self.bump() {
                            Some(Tok::Comma) => { key = self.expr()?; continue; }
                            Some(Tok::RBrace) => break,
                            other => return Err(format!("line {}: expected `,` or `}}` in the hash literal, got {:?}", self.n, other)),
                        }
                    }
                    return Ok(Expr::HashLit(pairs));
                }
                items.push(first);
                loop {
                    match self.bump() {
                        Some(Tok::Comma) => { items.push(self.expr()?); continue; }
                        Some(Tok::RBrace) => break,
                        other => return Err(format!("line {}: expected `,` or `}}` in the array literal, got {:?}", self.n, other)),
                    }
                }
                Ok(Expr::ArrLit(items))
            }
            Some(Tok::LogT) => Ok(Expr::Log(true)),
            Some(Tok::LogF) => Ok(Expr::Log(false)),
            Some(Tok::LogNot) => {
                // .NOT. binds tighter than comparisons (xBase precedence).
                let e = self.factor()?;
                Ok(Expr::LNot(Box::new(e)))
            }
            None => Err(format!("line {}: incomplete expression (operand or ) missing)", self.n)),
            Some(t) => Err(format!("line {}: unexpected token {:?} in expression", self.n, t)),
        }
    }
    fn peek_cmp(&self) -> Option<CmpOp> {
        match self.peek() {
            Some(Tok::Eq) => Some(CmpOp::Eq),
            Some(Tok::EqEq) => Some(CmpOp::EqEq),
            Some(Tok::Ne) => Some(CmpOp::Ne),
            Some(Tok::Lt) => Some(CmpOp::Lt),
            Some(Tok::Le) => Some(CmpOp::Le),
            Some(Tok::Gt) => Some(CmpOp::Gt),
            Some(Tok::Ge) => Some(CmpOp::Ge),
            Some(Tok::Dollar) => Some(CmpOp::Contains),
            _ => None,
        }
    }
    // Comparison level: at most one comparison, non-associative. Produces a
    // Bool that only `if` accepts (locals/prints/returns reject it later).
    fn cmp_expr(&mut self) -> Result<Expr, String> {
        let lhs = self.expr()?;
        if let Some(op) = self.peek_cmp() {
            self.pos += 1;
            let rhs = self.expr()?;
            return Ok(Expr::Cmp(op, Box::new(lhs), Box::new(rhs)));
        }
        Ok(lhs)
    }
    // Logical level (hk197-hk200): dotted .AND./.OR. (short-circuit in
    // codegen). The bare words AND/OR/NOT are a Harbour syntax error too
    // (E0030, probe hk199) and get a differentiated rejection.
    fn and_expr(&mut self) -> Result<Expr, String> {
        let mut lhs = self.cmp_expr()?;
        while self.peek() == Some(&Tok::LogAnd) {
            self.pos += 1;
            let rhs = self.cmp_expr()?;
            lhs = Expr::LAnd(Box::new(lhs), Box::new(rhs));
        }
        Ok(lhs)
    }
    fn or_expr(&mut self) -> Result<Expr, String> {
        let mut lhs = self.and_expr()?;
        while self.peek() == Some(&Tok::LogOr) {
            self.pos += 1;
            let rhs = self.and_expr()?;
            lhs = Expr::LOr(Box::new(lhs), Box::new(rhs));
        }
        if let Some(Tok::Ident(id)) = self.peek() {
            let l = id.to_ascii_lowercase();
            if l == "and" || l == "or" || l == "not" {
                return Err(format!("line {}: bare `{}` is not an operator in Harbour either (E0030, probe hk199); use the dotted form .AND./.OR./.NOT.", self.n, id));
            }
        }
        Ok(lhs)
    }
    // Indexed compound assignment as an expression (tests/arrayidx.prg,
    // original-contract 20261031): `a[i] op= e` with op in +, -, *. The
    // index is evaluated ONCE and BEFORE the right side (order oracle:
    // a[++index] += Bump(@index) stores into the original cell), the
    // right side once, and the value of the expression is the NEW cell
    // content. Integer cells and an integer right side only: `/=`, `^=`
    // and `%=` yield decimals in Harbour and stay parked with the
    // numeric-cell decision (proposal recorded, not approved).
    fn assign_expr(&mut self) -> Result<Expr, String> {
        let save = self.pos;
        match self.try_index_compound()? {
            Some(e) => Ok(e),
            None => {
                self.pos = save;
                self.or_expr()
            }
        }
    }
    fn try_index_compound(&mut self) -> Result<Option<Expr>, String> {
        if !matches!(self.peek(), Some(Tok::Ident(_))) || self.toks.get(self.pos + 1) != Some(&Tok::LBracket) {
            return Ok(None);
        }
        // Find the bracket that closes this first index and note whether
        // the index itself uses the multi-dimension comma form.
        let mut depth = 0i32;
        let mut close = None;
        let mut comma_form = false;
        for k in self.pos + 1..self.toks.len() {
            match &self.toks[k] {
                Tok::LBracket | Tok::LParen | Tok::LBrace => depth += 1,
                Tok::RBracket | Tok::RParen | Tok::RBrace => {
                    depth -= 1;
                    if depth == 0 {
                        close = Some(k);
                        break;
                    }
                }
                Tok::Comma if depth == 1 => comma_form = true,
                _ => {}
            }
        }
        let close = match close {
            Some(c) => c,
            None => return Ok(None),
        };
        if self.toks.get(close + 1) == Some(&Tok::LBracket) {
            // a[i][j] op= e and deeper: name the limit rather than
            // failing later with a generic expression error.
            let mut c = close;
            loop {
                let mut d = 0i32;
                let mut nxt = None;
                for k in c + 1..self.toks.len() {
                    match &self.toks[k] {
                        Tok::LBracket | Tok::LParen | Tok::LBrace => d += 1,
                        Tok::RBracket | Tok::RParen | Tok::RBrace => {
                            d -= 1;
                            if d == 0 {
                                nxt = Some(k);
                                break;
                            }
                        }
                        _ => {}
                    }
                }
                match nxt {
                    Some(k) if self.toks.get(k + 1) == Some(&Tok::LBracket) => c = k,
                    Some(k) => {
                        if matches!(self.toks.get(k + 1), Some(Tok::Plus | Tok::Minus | Tok::Star | Tok::Slash | Tok::Caret | Tok::Pct))
                            && self.toks.get(k + 2) == Some(&Tok::Eq)
                        {
                            return Err(format!("line {}: compound assignment on a multi-level index (`a[i][j] op= e`) is not in this increment; the covered lvalue is the one-level a[i]", self.n));
                        }
                        return Ok(None);
                    }
                    None => return Ok(None),
                }
            }
        }
        let is_eq = self.toks.get(close + 2) == Some(&Tok::Eq);
        let op = match self.toks.get(close + 1) {
            Some(Tok::Plus) => '+',
            Some(Tok::Minus) => '-',
            Some(Tok::Star) => '*',
            Some(Tok::Slash) | Some(Tok::Caret) | Some(Tok::Pct) if is_eq => {
                let sym = match self.toks.get(close + 1) {
                    Some(Tok::Slash) => "/",
                    Some(Tok::Caret) => "^",
                    _ => "%",
                };
                return Err(format!("line {}: `a[i] {}= e` is parked: Harbour `{}` always yields decimals (0.80 for 4/5) and the integer array cell cannot hold them until the numeric-cell decision (proposal recorded, not approved)", self.n, sym, sym));
            }
            _ => return Ok(None),
        };
        if !is_eq {
            return Ok(None);
        }
        if comma_form {
            return Err(format!("line {}: `a[i,j] {}= e` (the comma index form) is not in this increment; the covered lvalue is the one-level a[i]", self.n, op));
        }
        let id = match &self.toks[self.pos] {
            Tok::Ident(id) => id.clone(),
            _ => unreachable!("checked"),
        };
        self.pos += 2; // Ident and LBracket
        let idx = self.or_expr()?;
        if self.peek() != Some(&Tok::RBracket) {
            return Err(format!("line {}: expected `]` after the array index", self.n));
        }
        self.pos += 3; // `]`, the operator and `=`
        if self.pos >= self.toks.len() {
            return Err(format!("line {}: missing the right-hand side after `{}=`", self.n, op));
        }
        let rhs = self.assign_expr()?;
        Ok(Some(Expr::IdxCompound(id, Box::new(idx), op, Box::new(rhs))))
    }
    fn done(&self) -> Result<(), String> {
        if self.pos != self.toks.len() {
            Err(format!("line {}: trailing tokens after expression", self.n))
        } else {
            Ok(())
        }
    }
}

const ASM_RESERVED: &[&str] = &[
    // Not backend keywords (there is no textual backend anymore), but labels
    // hbc itself emits; a user function with one of these names would
    // collide with a helper symbol.
    "qout", "qqout", "outstd", "outerr", "empty", "procname", "min", "max", "hb_bitand", "hb_bitor", "hb_bitxor", "hb_bitnot", "hb_bittest", "hb_bitset", "hb_bitreset", "eprint_str", "eprint_sep", "eprint_i64", "eprint_i64c", "eprint_dyn", "eprint_f64", "hb_eol", "procline", "asc", "trim", "ltrim", "rtrim", "alltrim", "chr", "trace_top", "print_trace", "panic_exit", "print_i64", "print_str", "bound_error", "eval", "len", "round", "round_range_error", "hb_memcheck", "aadd", "asize", "alloc", "free", "oom", "asize_neg", "mem_allocs", "mem_frees", "hb_hdel", "hb_hhaskey", "hb_hget", "hb_hgetdef", "hb_hsetdef", "hb_hset", "hb_hpos", "hb_hmerge", "hb_hcopy", "hb_hclone", "hb_hcasematch", "hb_hsetcasematch", "hb_hscan", "hb_hkeyat", "hb_hvalueat", "hb_hdelat", "hb_hclear", "hb_hfill",
];

fn is_builtin(id: &str, name: &str) -> bool { id.eq_ignore_ascii_case(name) }

// Output calls share NIL result and existing value/ownership checks.
fn is_output_call(id: &str) -> bool { ["qout", "qqout", "outstd", "outerr"].iter().any(|v| is_builtin(id, v)) }

fn is_bitop(id: &str) -> bool { ["hb_bitand", "hb_bitor", "hb_bitxor", "hb_bitnot"].iter().any(|v| is_builtin(id,v)) }

fn is_bitindex(id: &str) -> bool { ["hb_bittest", "hb_bitset", "hb_bitreset"].iter().any(|v| is_builtin(id,v)) }

fn check_ident(id: &str, n: usize) -> Result<(), String> {
    if id.is_empty() || id.len() > 64 {
        return Err(format!("line {}: invalid identifier length", n));
    }
    if ASM_RESERVED.contains(&id) {
        return Err(format!("line {}: `{}` is reserved by the code generator", n, id));
    }
    Ok(())
}

fn parse_expr_tokens(toks: Vec<Tok>, n: usize) -> Result<Expr, String> {
    if toks.is_empty() {
        return Err(format!("line {}: missing expression", n));
    }
    let mut p = P { toks, pos: 0, n };
    let e = p.assign_expr()?;
    p.done()?;
    Ok(e)
}

// Bare END closes the innermost supported block; END used as an assigned
// identifier remains a statement in parse_stmts's existing disambiguation.
fn closes_block(t: &Tok, expected: &Tok) -> bool {
    t == expected || matches!(t, Tok::Ident(id) if id.eq_ignore_ascii_case("end"))
}

const MAX_DEPTH: usize = 64;

// Parses statements until a line starting with else / endif / return /
// function (left unconsumed) or the end of input. Branch bodies recurse;
// locals declared inside a branch are scoped to that branch.
fn parse_stmts(lines: &[(usize, Vec<Tok>)], i: &mut usize, out: &mut Vec<Stmt>, depth: usize) -> Result<(), String> {
    if depth > MAX_DEPTH {
        return Err("nesting too deep (64 levels max)".to_string());
    }
    while *i < lines.len() {
        let (n, toks) = &lines[*i];
        let n = *n;
        match toks[0].clone() {
            Tok::KwFunction => return Ok(()),
            Tok::KwMethod | Tok::KwCreate => return Ok(()),
            Tok::KwReturn if depth == 0 => return Ok(()),
            Tok::KwReturn => {
                // Early return inside a block (oracles hk378-hk381): a
                // BARE `return` is Harbour-valid anywhere and returns NIL
                // (hk378: inside an `if`, hk380: inside `do while`, hk381:
                // inside a `do case` arm); it maps to the same Ret(None)
                // the closing top-level bare return already uses, so the
                // existing single-epilogue cleanup is preserved untouched.
                let stmt = match toks.len() {
                    1 => Stmt::Ret(n, None),
                    // `return nil` IS a value since v2c: NIL is a real
                    // tagged value, so an early nil return unifies with the
                    // other returns like any expression (probe n2 order-
                    // independence).
                    2 if toks[1] == Tok::KwNil => Stmt::Ret(n, None),
                    _ => Stmt::Ret(n, Some(parse_expr_tokens(toks[1..].to_vec(), n)?)),
                };
                out.push(stmt);
                *i += 1;
            }
            Tok::KwElseif | Tok::KwElse | Tok::KwEndif => {
                if depth == 0 {
                    return Err(format!("line {}: `elseif`/`else`/`endif` without `if`", n));
                }
                return Ok(());
            }
            Tok::KwEnddo => {
                if depth == 0 {
                    return Err(format!("line {}: `enddo` without `while`", n));
                }
                return Ok(());
            }
            Tok::KwNext => {
                if depth == 0 {
                    return Err(format!("line {}: `next` without `for`", n));
                }
                return Ok(());
            }
            Tok::KwFor => {
                // `for each x in <collection>`: Harbour REQUIRES the EACH
                // keyword - `for x in a` is its E0030 syntax error
                // (oracle hk17). Iterates array elements and hash VALUES
                // (hk17/hk18/hk26).
                if toks.get(1) == Some(&Tok::KwEach) {
                    let id = match toks.get(2) {
                        Some(Tok::Ident(id)) => { check_ident(id, n)?; id.clone() }
                        _ => return Err(format!("line {}: expected `for each <var> in <collection>`", n)),
                    };
                    if toks.get(3) != Some(&Tok::KwIn) || toks.len() < 5 {
                        return Err(format!("line {}: expected `for each <var> in <collection>`", n));
                    }
                    let coll = parse_expr_tokens(toks[4..].to_vec(), n)?;
                    *i += 1;
                    let mut body = Vec::new();
                    parse_stmts(lines, i, &mut body, depth + 1)?;
                    if *i >= lines.len() || !closes_block(&lines[*i].1[0], &Tok::KwNext) {
                        return Err(format!("line {}: `for each` without `next`", n));
                    }
                    if lines[*i].1.len() != 1 {
                        return Err(format!("line {}: `next` takes no expression", n));
                    }
                    *i += 1;
                    out.push(Stmt::ForEach(n, id, coll, body));
                    continue;
                }
                if toks.iter().any(|t| *t == Tok::KwIn) {
                    return Err(format!("line {}: Harbour requires EACH here: `for each <var> in <collection>` (without EACH it is its E0030 syntax error, oracle hk17)", n));
                }
                // for i := <start> to <end> [step <n>]
                // The step must be a non-zero integer literal in this PoC:
                // the counting direction is then fixed at compile time.
                let id = match toks.get(1) {
                    Some(Tok::Ident(id)) => { check_ident(id, n)?; id.clone() }
                    _ => return Err(format!("line {}: expected `for i := <start> to <end> [step <n>]`", n)),
                };
                if toks.len() < 6 || toks[2] != Tok::Assign {
                    return Err(format!("line {}: expected `for i := <start> to <end> [step <n>]`", n));
                }
                let to_pos = match toks[3..].iter().position(|t| *t == Tok::KwTo) {
                    Some(p) => p + 3,
                    None => return Err(format!("line {}: expected `for i := <start> to <end> [step <n>]`", n)),
                };
                let step_pos = toks[to_pos + 1..].iter().position(|t| *t == Tok::KwStep).map(|p| p + to_pos + 1);
                let end_slice_end = step_pos.unwrap_or(toks.len());
                if to_pos == 3 || end_slice_end == to_pos + 1 {
                    return Err(format!("line {}: expected `for i := <start> to <end> [step <n>]`", n));
                }
                let start = parse_expr_tokens(toks[3..to_pos].to_vec(), n)?;
                let end = parse_expr_tokens(toks[to_pos + 1..end_slice_end].to_vec(), n)?;
                let step = match step_pos {
                    None => 1,
                    Some(p) => {
                        let (neg, vtok) = match &toks[p + 1..] {
                            [Tok::Int(v)] => (false, v),
                            [Tok::Minus, Tok::Int(v)] => (true, v),
                            _ => return Err(format!("line {}: the `for` step must be a non-zero integer literal in this PoC", n)),
                        };
                        let mag = match vtok.parse::<u128>() {
                            Ok(k) if k <= i64::MAX as u128 => k as i64,
                            _ => return Err(format!("line {}: integer literal out of range (i64)", n)),
                        };
                        let s = if neg { -mag } else { mag };
                        if s == 0 {
                            return Err(format!("line {}: the `for` step must be a non-zero integer literal in this PoC", n));
                        }
                        s
                    }
                };
                *i += 1;
                let mut body = Vec::new();
                parse_stmts(lines, i, &mut body, depth + 1)?;
                if *i >= lines.len() || !closes_block(&lines[*i].1[0], &Tok::KwNext) {
                    return Err(format!("line {}: `for` without `next`", n));
                }
                if lines[*i].1.len() != 1 {
                    return Err(format!("line {}: `next` takes no expression", n));
                }
                *i += 1;
                out.push(Stmt::For(n, id, start, end, step, body));
            }
            Tok::KwWhile => {
                if toks.len() < 2 {
                    return Err(format!("line {}: expected `while <expr> <comparison> <expr>`", n));
                }
                let cond = parse_expr_tokens(toks[1..].to_vec(), n)?;
                *i += 1;
                let mut body = Vec::new();
                parse_stmts(lines, i, &mut body, depth + 1)?;
                if *i >= lines.len() || !closes_block(&lines[*i].1[0], &Tok::KwEnddo) {
                    return Err(format!("line {}: `while` without `enddo`", n));
                }
                if lines[*i].1.len() != 1 {
                    return Err(format!("line {}: `enddo` takes no expression", lines[*i].0));
                }
                *i += 1;
                out.push(Stmt::While(n, cond, body));
            }
            Tok::KwIf => {
                // A comma at the outer call depth distinguishes IF(c,a,b)
                // from block IF (condition), including parenthesized lists.
                let mut parens = 0i32;
                let inline = toks.get(1) == Some(&Tok::LParen) && toks.iter().any(|t| {
                    match t {
                        Tok::LParen | Tok::LBracket | Tok::LBrace => parens += 1,
                        Tok::RParen | Tok::RBracket | Tok::RBrace => parens -= 1,
                        Tok::Comma if parens == 1 => return true,
                        _ => {}
                    }
                    false
                });
                if inline {
                    let e = parse_expr_tokens(toks.clone(), n)?;
                    out.push(Stmt::CallStmt(n, e));
                    *i += 1;
                    continue;
                }
                if toks.len() < 2 {
                    return Err(format!("line {}: expected `if <expr> <comparison> <expr>`", n));
                }
                let cond = parse_expr_tokens(toks[1..].to_vec(), n)?;
                *i += 1;
                let mut then_stmts = Vec::new();
                parse_stmts(lines, i, &mut then_stmts, depth + 1)?;
                // ELSEIF arms (stock ifelse.prg): exactly Harbour's nested
                // IF - collect, then fold from the last arm behind the
                // optional ELSE body.
                let mut arms: Vec<(usize, Expr, Vec<Stmt>)> = Vec::new();
                while *i < lines.len() && lines[*i].1[0] == Tok::KwElseif {
                    let en = lines[*i].0;
                    if lines[*i].1.len() < 2 {
                        return Err(format!("line {}: `elseif` takes a condition", en));
                    }
                    let ec = parse_expr_tokens(lines[*i].1[1..].to_vec(), en)?;
                    *i += 1;
                    let mut ebody = Vec::new();
                    parse_stmts(lines, i, &mut ebody, depth + 1)?;
                    arms.push((en, ec, ebody));
                }
                let mut else_stmts = Vec::new();
                if *i < lines.len() && lines[*i].1[0] == Tok::KwElse {
                    if lines[*i].1.len() != 1 {
                        return Err(format!("line {}: `else` takes no expression", lines[*i].0));
                    }
                    *i += 1;
                    parse_stmts(lines, i, &mut else_stmts, depth + 1)?;
                }
                for (en, ec, ebody) in arms.into_iter().rev() {
                    else_stmts = vec![Stmt::If(en, ec, ebody, else_stmts)];
                }
                if *i >= lines.len() || !closes_block(&lines[*i].1[0], &Tok::KwEndif) {
                    return Err(format!("line {}: `if` without `endif`", n));
                }
                if lines[*i].1.len() != 1 {
                    return Err(format!("line {}: `endif` takes no expression", lines[*i].0));
                }
                *i += 1;
                out.push(Stmt::If(n, cond, then_stmts, else_stmts));
            }
            Tok::KwLocal => {
                // Harbour: `local name [:= expr] [, name [:= expr] ...]`.
                // Without an initializer the variable starts NIL (hk239:
                // prints NIL, ValType "U"); a NIL slot is Dyn, so the
                // usual Dyn rules apply to what it can later receive.
                if toks.len() < 2 {
                    return Err(format!("line {}: expected `local name [:= expr] [, ...]`", n));
                }
                let rest = &toks[1..];
                let mut depth = 0i32;
                let mut start = 0usize;
                let mut spans: Vec<&[Tok]> = Vec::new();
                for (k, t) in rest.iter().enumerate() {
                    match t {
                        Tok::LParen | Tok::LBracket | Tok::LBrace => depth += 1,
                        Tok::RParen | Tok::RBracket | Tok::RBrace => depth -= 1,
                        Tok::Comma if depth == 0 => { spans.push(&rest[start..k]); start = k + 1; }
                        _ => {}
                    }
                }
                spans.push(&rest[start..]);
                for it in spans {
                    let id = match it.first() {
                        Some(Tok::Ident(id)) => { check_ident(id, n)?; id.clone() }
                        t => return Err(format!("line {}: expected identifier, got {:?}", n, t)),
                    };
                    if it.len() == 1 {
                        out.push(Stmt::Local(n, id, Expr::Nil));
                    } else if it.len() >= 3 && it[1] == Tok::Assign {
                        let e = parse_expr_tokens(it[2..].to_vec(), n)?;
                        out.push(Stmt::Local(n, id, e));
                    } else {
                        return Err(format!("line {}: expected `local name [:= expr]`", n));
                    }
                }
                *i += 1;
            }
            Tok::Question => {
                // Harbour `?`: bare prints a blank line; otherwise a
                // comma-separated expression list (probes b51/b57).
                let rest = &toks[1..];
                let mut exprs = Vec::new();
                if !rest.is_empty() {
                    let mut depth = 0i32;
                    let mut start = 0usize;
                    for (k, t) in rest.iter().enumerate() {
                        match t {
                            Tok::LParen | Tok::LBracket => depth += 1,
                            Tok::RParen | Tok::RBracket => depth -= 1,
                            Tok::Comma if depth == 0 => {
                                exprs.push(parse_expr_tokens(rest[start..k].to_vec(), n)?);
                                start = k + 1;
                            }
                            _ => {}
                        }
                    }
                    exprs.push(parse_expr_tokens(rest[start..].to_vec(), n)?);
                }
                out.push(Stmt::Print(n, exprs, false));
                *i += 1;
            }
            Tok::QuestionQ => {
                // Harbour `??`: same QOut item list as `?` but WITHOUT
                // the leading newline (hk274-hk276); bare `??` prints
                // nothing at all.
                let rest = &toks[1..];
                let mut exprs = Vec::new();
                if !rest.is_empty() {
                    let mut depth = 0i32;
                    let mut start = 0usize;
                    for (k, t) in rest.iter().enumerate() {
                        match t {
                            Tok::LParen | Tok::LBracket => depth += 1,
                            Tok::RParen | Tok::RBracket => depth -= 1,
                            Tok::Comma if depth == 0 => {
                                exprs.push(parse_expr_tokens(rest[start..k].to_vec(), n)?);
                                start = k + 1;
                            }
                            _ => {}
                        }
                    }
                    exprs.push(parse_expr_tokens(rest[start..].to_vec(), n)?);
                }
                out.push(Stmt::Print(n, exprs, true));
                *i += 1;
            }
            Tok::KwExit => {
                if toks.len() != 1 {
                    return Err(format!("line {}: `exit` takes no expression", n));
                }
                out.push(Stmt::Exit(n));
                *i += 1;
            }
            Tok::KwLoop => {
                if toks.len() != 1 {
                    return Err(format!("line {}: `loop` takes no expression", n));
                }
                out.push(Stmt::Loop(n));
                *i += 1;
            }
            Tok::Ident(id) if id.eq_ignore_ascii_case("do") => {
                // Harbour command forms (oracle hk244): `DO WHILE <cond>`
                // is the plain `while` loop (same ENDDO); `DO name` and
                // `DO name WITH arg, ...` run the call for its effect
                // (the bare-call statement of hk216 with command sugar).
                if toks.len() >= 2 && toks[1] == Tok::KwWhile {
                    if toks.len() < 3 {
                        return Err(format!("line {}: expected `do while <expr>`", n));
                    }
                    let cond = parse_expr_tokens(toks[2..].to_vec(), n)?;
                    *i += 1;
                    let mut body = Vec::new();
                    parse_stmts(lines, i, &mut body, depth + 1)?;
                    if *i >= lines.len() || !closes_block(&lines[*i].1[0], &Tok::KwEnddo) {
                        return Err(format!("line {}: `do while` without `enddo`", n));
                    }
                    if lines[*i].1.len() != 1 {
                        return Err(format!("line {}: `enddo` takes no expression", lines[*i].0));
                    }
                    *i += 1;
                    out.push(Stmt::While(n, cond, body));
                } else if toks.len() >= 2 {
                    let fname = match &toks[1] {
                        Tok::Ident(f) => f.clone(),
                        t => return Err(format!("line {}: expected `do while` or `do name [WITH args]`, got {:?}", n, t)),
                    };
                    if fname.eq_ignore_ascii_case("case") {
                        // DO CASE (oracles hk374-hk376): the FIRST matching
                        // CASE runs, then control continues past ENDCASE -
                        // no fall-through; OTHERWISE runs when nothing
                        // matched (hk374/hk375); a bare `end` also closes
                        // (hk375); nothing runs when no CASE matches and
                        // there is no OTHERWISE (hk375); nesting works
                        // (hk376). Desugars to the nested-IF shape ELSEIF
                        // already uses (63zg) - no checker/codegen change.
                        if toks.len() != 2 {
                            return Err(format!("line {}: `do case` takes no expression", n));
                        }
                        *i += 1;
                        let mut arms: Vec<(usize, Expr, Vec<Stmt>)> = Vec::new();
                        while *i < lines.len() && matches!(&lines[*i].1[0], Tok::Ident(id) if id.eq_ignore_ascii_case("case")) {
                            let cn = lines[*i].0;
                            if lines[*i].1.len() < 2 {
                                return Err(format!("line {}: `case` takes a condition", cn));
                            }
                            let cc = parse_expr_tokens(lines[*i].1[1..].to_vec(), cn)?;
                            *i += 1;
                            let mut cbody = Vec::new();
                            parse_stmts(lines, i, &mut cbody, depth + 1)?;
                            arms.push((cn, cc, cbody));
                        }
                        let mut else_stmts: Vec<Stmt> = Vec::new();
                        if *i < lines.len() && matches!(&lines[*i].1[0], Tok::Ident(id) if id.eq_ignore_ascii_case("otherwise")) {
                            if lines[*i].1.len() != 1 {
                                return Err(format!("line {}: `otherwise` takes no expression", lines[*i].0));
                            }
                            *i += 1;
                            parse_stmts(lines, i, &mut else_stmts, depth + 1)?;
                        }
                        if *i >= lines.len() || !matches!(&lines[*i].1[0], Tok::Ident(id) if id.eq_ignore_ascii_case("endcase") || id.eq_ignore_ascii_case("end")) {
                            return Err(format!("line {}: `do case` without `endcase`", n));
                        }
                        if lines[*i].1.len() != 1 {
                            return Err(format!("line {}: `endcase` takes no expression", lines[*i].0));
                        }
                        *i += 1;
                        for (cn, cc, cbody) in arms.into_iter().rev() {
                            else_stmts = vec![Stmt::If(cn, cc, cbody, else_stmts)];
                        }
                        out.extend(else_stmts);
                        continue;
                    }
                    check_ident(&fname, n)?;
                    let args: Vec<Expr> = if toks.len() == 2 {
                        Vec::new()
                    } else if toks.len() >= 4 && matches!(&toks[2], Tok::Ident(w) if w.eq_ignore_ascii_case("with")) {
                        let rest = &toks[3..];
                        let mut d = 0i32;
                        let mut start = 0usize;
                        let mut spans: Vec<&[Tok]> = Vec::new();
                        for (k, t) in rest.iter().enumerate() {
                            match t {
                                Tok::LParen | Tok::LBracket | Tok::LBrace => d += 1,
                                Tok::RParen | Tok::RBracket | Tok::RBrace => d -= 1,
                                Tok::Comma if d == 0 => { spans.push(&rest[start..k]); start = k + 1; }
                                _ => {}
                            }
                        }
                        spans.push(&rest[start..]);
                        let mut v = Vec::new();
                        for sp in spans {
                            v.push(parse_expr_tokens(sp.to_vec(), n)?);
                        }
                        v
                    } else {
                        return Err(format!("line {}: expected `do {} [WITH arg, ...]`", n, fname));
                    };
                    out.push(Stmt::CallStmt(n, Expr::Call(fname, args)));
                    *i += 1;
                } else {
                    return Err(format!("line {}: expected `do while` or `do name [WITH args]`", n));
                }
            }
            Tok::Ident(id) => {
                // DO CASE body terminators (oracles hk374-hk376): inside a
                // nested body these hand control back to the enclosing
                // `do case` loop. A same-named variable being ASSIGNED
                // stays a statement (the NOTE precedent, oracle hk249).
                if depth > 0
                    && (id.eq_ignore_ascii_case("case") || id.eq_ignore_ascii_case("otherwise") || id.eq_ignore_ascii_case("endcase") || id.eq_ignore_ascii_case("end"))
                    && !matches!(toks.get(1), Some(Tok::Assign) | Some(Tok::Eq))
                {
                    return Ok(());
                }
                if id.eq_ignore_ascii_case("set") && !(toks.len() >= 2 && toks[1] == Tok::LParen) {
                    // SET commands switch runtime state. Measured sweep
                    // forms (63zk): SET PRINTER/DEVICE/ALTERNATE/MARGIN
                    // belong to the output-routing subsystem (dev/longdev/
                    // output), SET EXCLUSIVE to the RDD layer (rdd), SET
                    // CENTURY to the date subsystem (say) - all parked
                    // WITH their subsystems; a no-op accept would send
                    // output to the wrong place silently. SET DECIMALS
                    // stays fixed at the Harbour default 2 (oracle hk295:
                    // 10/3 prints 3.3333 under `set decimals to 4`).
                    // `Set(` with parens is the Set() FUNCTION call, not
                    // a SET command - it falls through to the ordinary
                    // call-statement path (dates2/dates3/directry/extend1/
                    // say/vmasort were misclassified here before 63zk).
                    return Err(format!("line {}: SET commands are not in this increment (measured forms: SET PRINTER/DEVICE/ALTERNATE/MARGIN belong to output routing, SET EXCLUSIVE to the RDD layer, SET CENTURY/DATEFORMAT to the date subsystem - each parked with its subsystem; SET DECIMALS is fixed at the Harbour default 2, oracle hk295)", n));
                }
                if toks.len() >= 2 && toks[1] == Tok::LBracket {
                    // a[i] := v, a[i][j] := v or a[i,j] := v (probe m2: the
                    // comma form is the same nested access in Harbour)
                    check_ident(&id, n)?;
                    let mut depth = 0i32;
                    let mut rb = 0usize;
                    let mut commas: Vec<usize> = Vec::new();
                    for (p, t) in toks.iter().enumerate().skip(1) {
                        match t {
                            Tok::LBracket | Tok::LParen => depth += 1,
                            Tok::RBracket | Tok::RParen => {
                                depth -= 1;
                                if depth == 0 { rb = p; break; }
                            }
                            Tok::Comma if depth == 1 => commas.push(p),
                            _ => {}
                        }
                    }
                    if rb == 0 {
                        return Err(format!("line {}: expected `name[idx] := expr`", n));
                    }
                    if commas.is_empty()
                        && matches!(toks.get(rb + 1), Some(Tok::Plus | Tok::Minus | Tok::Star | Tok::Slash | Tok::Caret | Tok::Pct))
                        && toks.get(rb + 2) == Some(&Tok::Eq)
                    {
                        // `a[i] op= e` as a statement (arrayidx family):
                        // the same indexed compound assignment with its
                        // value discarded, like a bare call statement
                        // (hk216). `/=`, `^=`, `%=` keep their parked
                        // error from the expression parser.
                        let e = parse_expr_tokens(toks.clone(), n)?;
                        out.push(Stmt::CallStmt(n, e));
                        *i += 1;
                        continue;
                    }
                    if !commas.is_empty() {
                        // a[i, j] := v, a[i, j, k] := v, a[i, j, k, l] := v
                        // (probe m2 extended: the comma form is the same
                        // nested access; 4-level write measured in hk104)
                        if toks.len() <= rb + 1 || !matches!(toks[rb + 1], Tok::Assign | Tok::Eq) {
                            return Err(format!("line {}: expected `name[idx, ...] := expr`", n));
                        }
                        if commas.len() > 3 {
                            return Err(format!("line {}: more than four index levels are not in this increment", n));
                        }
                        let mut idxs: Vec<Expr> = Vec::new();
                        let mut start = 2usize;
                        for &c in &commas {
                            idxs.push(parse_expr_tokens(toks[start..c].to_vec(), n)?);
                            start = c + 1;
                        }
                        idxs.push(parse_expr_tokens(toks[start..rb].to_vec(), n)?);
                        let e = parse_expr_tokens(toks[rb + 2..].to_vec(), n)?;
                        let mut it = idxs.into_iter();
                        let (i1, i2) = (it.next().unwrap(), it.next().unwrap());
                        match (it.next(), it.next()) {
                            (None, None) => out.push(Stmt::ArrSet2(n, id, i1, i2, e)),
                            (Some(i3), None) => out.push(Stmt::ArrSet3(n, id, i1, i2, i3, e)),
                            (Some(i3), Some(i4)) => out.push(Stmt::ArrSet4(n, id, i1, i2, i3, i4, e)),
                            _ => unreachable!(),
                        }
                        *i += 1;
                        continue;
                    }
                    if toks.len() > rb + 1 && toks[rb + 1] == Tok::LBracket {
                        // a[i][j] := v
                        let mut depth2 = 0i32;
                        let mut rb2 = 0usize;
                        for (p, t) in toks.iter().enumerate().skip(rb + 1) {
                            match t {
                                Tok::LBracket | Tok::LParen => depth2 += 1,
                                Tok::RBracket | Tok::RParen => {
                                    depth2 -= 1;
                                    if depth2 == 0 { rb2 = p; break; }
                                }
                                _ => {}
                            }
                        }
                        if rb2 == 0 || toks.len() <= rb2 + 1 {
                            return Err(format!("line {}: expected `name[idx][idx2] := expr`", n));
                        }
                        if toks[rb2 + 1] == Tok::LBracket {
                            // a[i][j][k] := v
                            let mut depth3 = 0i32;
                            let mut rb3 = 0usize;
                            for (p, t) in toks.iter().enumerate().skip(rb2 + 1) {
                                match t {
                                    Tok::LBracket | Tok::LParen => depth3 += 1,
                                    Tok::RBracket | Tok::RParen => {
                                        depth3 -= 1;
                                        if depth3 == 0 { rb3 = p; break; }
                                    }
                                    _ => {}
                                }
                            }
                            if rb3 == 0 || toks.len() <= rb3 + 1 {
                                return Err(format!("line {}: expected `name[idx][idx2][idx3] := expr`", n));
                            }
                            if toks[rb3 + 1] == Tok::LBracket {
                                // a[i][j][k][l] := v (hk107)
                                let mut depth4 = 0i32;
                                let mut rb4 = 0usize;
                                for (p, t) in toks.iter().enumerate().skip(rb3 + 1) {
                                    match t {
                                        Tok::LBracket | Tok::LParen => depth4 += 1,
                                        Tok::RBracket | Tok::RParen => {
                                            depth4 -= 1;
                                            if depth4 == 0 { rb4 = p; break; }
                                        }
                                        _ => {}
                                    }
                                }
                                if rb4 == 0 || toks.len() <= rb4 + 1 || !matches!(toks[rb4 + 1], Tok::Assign | Tok::Eq) {
                                    return Err(format!("line {}: expected `name[idx][idx2][idx3][idx4] := expr`", n));
                                }
                                let i1 = parse_expr_tokens(toks[2..rb].to_vec(), n)?;
                                let i2 = parse_expr_tokens(toks[rb + 2..rb2].to_vec(), n)?;
                                let i3 = parse_expr_tokens(toks[rb2 + 2..rb3].to_vec(), n)?;
                                let i4 = parse_expr_tokens(toks[rb3 + 2..rb4].to_vec(), n)?;
                                let e = parse_expr_tokens(toks[rb4 + 2..].to_vec(), n)?;
                                out.push(Stmt::ArrSet4(n, id, i1, i2, i3, i4, e));
                                *i += 1;
                                continue;
                            }
                            if !matches!(toks[rb3 + 1], Tok::Assign | Tok::Eq) {
                                return Err(format!("line {}: expected `name[idx][idx2][idx3] := expr`", n));
                            }
                            let i1 = parse_expr_tokens(toks[2..rb].to_vec(), n)?;
                            let i2 = parse_expr_tokens(toks[rb + 2..rb2].to_vec(), n)?;
                            let i3 = parse_expr_tokens(toks[rb2 + 2..rb3].to_vec(), n)?;
                            let e = parse_expr_tokens(toks[rb3 + 2..].to_vec(), n)?;
                            out.push(Stmt::ArrSet3(n, id, i1, i2, i3, e));
                            *i += 1;
                            continue;
                        }
                        if !matches!(toks[rb2 + 1], Tok::Assign | Tok::Eq) {
                            return Err(format!("line {}: expected `name[idx][idx2] := expr`", n));
                        }
                        let i1 = parse_expr_tokens(toks[2..rb].to_vec(), n)?;
                        let i2 = parse_expr_tokens(toks[rb + 2..rb2].to_vec(), n)?;
                        let e = parse_expr_tokens(toks[rb2 + 2..].to_vec(), n)?;
                        out.push(Stmt::ArrSet2(n, id, i1, i2, e));
                        *i += 1;
                        continue;
                    }
                    if rb == 2 || toks.len() <= rb + 1 || !matches!(toks[rb + 1], Tok::Assign | Tok::Eq) {
                        return Err(format!("line {}: expected `name[idx] := expr`", n));
                    }
                    let idx = parse_expr_tokens(toks[2..rb].to_vec(), n)?;
                    let e = parse_expr_tokens(toks[rb + 2..].to_vec(), n)?;
                    out.push(Stmt::ArrSet(n, id, idx, e));
                    *i += 1;
                    continue;
                }
                if (is_builtin(&id, "aadd") || is_builtin(&id, "asize") || is_builtin(&id, "hb_hdel") || is_builtin(&id, "hb_hdelat") || is_builtin(&id, "hb_hclear") || is_builtin(&id, "hb_hfill") || is_builtin(&id, "hb_hset") || is_builtin(&id, "hb_hmerge") || is_builtin(&id, "hb_hcopy") || is_builtin(&id, "hb_hsetcasematch")) && toks.len() >= 4 && toks[1] == Tok::LParen && toks[toks.len() - 1] == Tok::RParen {
                    // AAdd(a, x) / ASize(a, n) as a STATEMENT: in-place
                    // mutation of the named local (Harbour writes these as
                    // calls; the statement form is the PoC surface - probe
                    // e5's return value is out of scope, registered).
                    let inner = &toks[2..toks.len() - 1];
                    if is_builtin(&id, "hb_hclear") {
                        // hb_HClear(h) as a STATEMENT (hk191/hk193;
                        // the hash it returns is out of the statement
                        // surface, like hb_HDel's).
                        match inner {
                            [Tok::Ident(v)] => {
                                check_ident(v, n)?;
                                out.push(Stmt::HClear(n, v.clone()));
                            }
                            _ => return Err(format!("line {}: `hb_HClear` takes a single hash variable", n)),
                        }
                        *i += 1;
                        continue;
                    }
                    if is_builtin(&id, "hb_hcopy") {
                        // hb_HCopy(src, dst [, start [, count]]) as a
                        // STATEMENT (hk195/hk195b/hk195c; the hash it
                        // returns is out of the statement surface, like
                        // hb_HMerge's). Both must be hash variables and
                        // NOT the same one: Harbour raises a self-copy
                        // runtime error there (hk195b); with no aliases
                        // in this dialect that is a named compile-time
                        // rejection.
                        let mut parts: Vec<&[Tok]> = Vec::new();
                        let mut d0c = 0i32;
                        let mut last = 0usize;
                        for (p, tk) in inner.iter().enumerate() {
                            match tk {
                                Tok::LBracket | Tok::LParen => d0c += 1,
                                Tok::RBracket | Tok::RParen => d0c -= 1,
                                Tok::Comma if d0c == 0 => { parts.push(&inner[last..p]); last = p + 1; }
                                _ => {}
                            }
                        }
                        parts.push(&inner[last..]);
                        if parts.len() < 2 || parts.len() > 4 {
                            return Err(format!("line {}: `hb_HCopy` takes two to four arguments", n));
                        }
                        let (src, dst) = match (parts[0], parts[1]) {
                            ([Tok::Ident(a)], [Tok::Ident(b)]) => { check_ident(a, n)?; check_ident(b, n)?; (a.clone(), b.clone()) }
                            _ => return Err(format!("line {}: the first two arguments of `hb_HCopy` must be hash variables", n)),
                        };
                        if src == dst {
                            return Err(format!("line {}: `hb_HCopy` cannot copy a hash onto itself (Harbour's self-copy error family, hk195b)", n));
                        }
                        let start = if parts.len() >= 3 { Some(parse_expr_tokens(parts[2].to_vec(), n)?) } else { None };
                        let count = if parts.len() == 4 { Some(parse_expr_tokens(parts[3].to_vec(), n)?) } else { None };
                        out.push(Stmt::HCopy(n, src, dst, start, count));
                        *i += 1;
                        continue;
                    }
                    // First comma at depth 0: commas inside the bracket
                    // index group (a[i, j, k] comma form, hk105/hk108)
                    // belong to the head, not to the head/value split.
                    let mut d0 = 0i32;
                    let mut comma: Option<usize> = None;
                    for (p, t) in inner.iter().enumerate() {
                        match t {
                            Tok::LBracket | Tok::LParen => d0 += 1,
                            Tok::RBracket | Tok::RParen => d0 -= 1,
                            Tok::Comma if d0 == 0 => { comma = Some(p); break; }
                            _ => {}
                        }
                    }
                    let comma = match comma {
                        Some(p) => p,
                        None => return Err(format!("line {}: `{}` takes two arguments", n, id)),
                    };
                    let head = &inner[..comma];
                    if is_builtin(&id, "hb_hset") {
                        // hb_HSet(h, key, value) as a STATEMENT (the
                        // functional hash write, hk159/hk161; the hash it
                        // returns is out of the statement surface, like
                        // AAdd's return). The value side is re-split at
                        // its own first depth-0 comma.
                        let rest = &inner[comma + 1..];
                        let mut d0b = 0i32;
                        let mut comma2: Option<usize> = None;
                        for (p, tk) in rest.iter().enumerate() {
                            match tk {
                                Tok::LBracket | Tok::LParen => d0b += 1,
                                Tok::RBracket | Tok::RParen => d0b -= 1,
                                Tok::Comma if d0b == 0 => { comma2 = Some(p); break; }
                                _ => {}
                            }
                        }
                        let comma2 = match comma2 {
                            Some(p) => p,
                            None => return Err(format!("line {}: `hb_HSet` takes three arguments", n)),
                        };
                        let ke = parse_expr_tokens(rest[..comma2].to_vec(), n)?;
                        let ve = parse_expr_tokens(rest[comma2 + 1..].to_vec(), n)?;
                        match head {
                            [Tok::Ident(v)] => {
                                check_ident(v, n)?;
                                out.push(Stmt::HSet(n, v.clone(), ke, ve));
                            }
                            _ => return Err(format!("line {}: the first argument of `hb_HSet` must be a hash variable", n)),
                        }
                        *i += 1;
                        continue;
                    }
                    let e = parse_expr_tokens(inner[comma + 1..].to_vec(), n)?;
                    match head {
                        [Tok::Ident(v)] => {
                            check_ident(v, n)?;
                            if is_builtin(&id, "hb_hdel") {
                                out.push(Stmt::HDel(n, v.clone(), e));
                            } else if is_builtin(&id, "hb_hdelat") {
                                // hb_HDelAt(h, n) as a STATEMENT
                                // (hk187; the hash it returns is out
                                // of the statement surface, like
                                // hb_HDel's).
                                out.push(Stmt::HDelAt(n, v.clone(), e));
                            } else if is_builtin(&id, "hb_hfill") {
                                // hb_HFill(h, value) as a STATEMENT
                                // (hk192; the hash it returns is out
                                // of the statement surface).
                                out.push(Stmt::HFill(n, v.clone(), e));
                            } else if is_builtin(&id, "hb_hsetcasematch") {
                                out.push(Stmt::HSetCaseMatch(n, v.clone(), e));
                            } else if is_builtin(&id, "hb_hmerge") {
                                // hb_HMerge(dst, src) as a STATEMENT
                                // (hk164/hk165; the hash it returns is
                                // out of the statement surface, like
                                // hb_HSet's). The source must be a hash
                                // variable too.
                                match e {
                                    Expr::Var(s) => out.push(Stmt::HMerge(n, v.clone(), s)),
                                    _ => return Err(format!("line {}: the second argument of `hb_HMerge` must be a hash variable", n)),
                                }
                            } else if is_builtin(&id, "aadd") {
                                out.push(Stmt::AAdd(n, v.clone(), e));
                            } else {
                                out.push(Stmt::ASize(n, v.clone(), e));
                            }
                        }
                        _ if matches!(head.first(), Some(Tok::Ident(_)))
                            && head.len() >= 6
                            && matches!(head[1], Tok::LBracket)
                            && matches!(head[head.len() - 1], Tok::RBracket) => {
                            // AAdd/ASize on a[i][j]: split the two bracket
                            // groups by their own depth so index expressions
                            // keep full token freedom.
                            let v = match &head[0] { Tok::Ident(v) => v.clone(), _ => unreachable!() };
                            check_ident(&v, n)?;
                            let mut depth = 0i32;
                            let mut rb = 0usize;
                            for (p, tk) in head.iter().enumerate().skip(1) {
                                match tk {
                                    Tok::LBracket | Tok::LParen => depth += 1,
                                    Tok::RBracket | Tok::RParen => {
                                        depth -= 1;
                                        if depth == 0 { rb = p; break; }
                                    }
                                    _ => {}
                                }
                            }
                            if rb == head.len() - 1 {
                                // One bracket group: a[i], a[i, j] or
                                // a[i, j, k] in comma form (probe m2
                                // extended; hk105/hk108 measured comma).
                                let inner = &head[2..rb];
                                let mut d2 = 0i32;
                                let mut cs: Vec<usize> = Vec::new();
                                for (p, tk) in inner.iter().enumerate() {
                                    match tk {
                                        Tok::LBracket | Tok::LParen => d2 += 1,
                                        Tok::RBracket | Tok::RParen => d2 -= 1,
                                        Tok::Comma if d2 == 0 => cs.push(p),
                                        _ => {}
                                    }
                                }
                                if cs.len() > 2 {
                                    return Err(format!("line {}: `{}` on more than three index levels is not in this increment", n, id));
                                }
                                let mut idxs: Vec<Expr> = Vec::new();
                                let mut start = 0usize;
                                for &c in &cs {
                                    idxs.push(parse_expr_tokens(inner[start..c].to_vec(), n)?);
                                    start = c + 1;
                                }
                                idxs.push(parse_expr_tokens(inner[start..].to_vec(), n)?);
                                let mut it = idxs.into_iter();
                                let i1 = it.next().unwrap();
                                match (it.next(), it.next()) {
                                    (None, None) => {
                                        if is_builtin(&id, "hb_hdel") || is_builtin(&id, "hb_hdelat") || is_builtin(&id, "hb_hfill") || is_builtin(&id, "hb_hsetcasematch") { return Err(format!("line {}: `{}` takes a hash variable, not a subscript", n, id)); } else if is_builtin(&id, "aadd") { out.push(Stmt::AAddSub(n, v, i1, e)); } else { out.push(Stmt::ASizeSub(n, v, i1, e)); }
                                    }
                                    (Some(i2), None) => {
                                        if is_builtin(&id, "hb_hdel") || is_builtin(&id, "hb_hdelat") || is_builtin(&id, "hb_hfill") || is_builtin(&id, "hb_hsetcasematch") { return Err(format!("line {}: `{}` takes a hash variable, not a subscript", n, id)); } else if is_builtin(&id, "aadd") { out.push(Stmt::AAddSub2(n, v, i1, i2, e)); } else { out.push(Stmt::ASizeSub2(n, v, i1, i2, e)); }
                                    }
                                    (Some(i2), Some(i3)) => {
                                        if is_builtin(&id, "hb_hdel") || is_builtin(&id, "hb_hdelat") || is_builtin(&id, "hb_hfill") || is_builtin(&id, "hb_hsetcasematch") { return Err(format!("line {}: `{}` takes a hash variable, not a subscript", n, id)); } else if is_builtin(&id, "aadd") { out.push(Stmt::AAddSub3(n, v, i1, i2, i3, e)); } else { out.push(Stmt::ASizeSub3(n, v, i1, i2, i3, e)); }
                                    }
                                    _ => unreachable!(),
                                }
                                *i += 1;
                                continue;
                            }
                            if rb <= 2 || rb + 1 >= head.len() - 1 || !matches!(head[rb + 1], Tok::LBracket) {
                                return Err(format!("line {}: the first argument of `{}` must be a variable, a[i], a[i][j] or a[i][j][k]", n, id));
                            }
                            // Second group; a third may follow (hk105).
                            let mut depth3 = 0i32;
                            let mut rb2 = 0usize;
                            for (p, tk) in head.iter().enumerate().skip(rb + 1) {
                                match tk {
                                    Tok::LBracket | Tok::LParen => depth3 += 1,
                                    Tok::RBracket | Tok::RParen => {
                                        depth3 -= 1;
                                        if depth3 == 0 { rb2 = p; break; }
                                    }
                                    _ => {}
                                }
                            }
                            if rb2 == 0 {
                                return Err(format!("line {}: the first argument of `{}` must be a variable, a[i], a[i][j] or a[i][j][k]", n, id));
                            }
                            let i1 = parse_expr_tokens(head[2..rb].to_vec(), n)?;
                            let i2 = parse_expr_tokens(head[rb + 2..rb2].to_vec(), n)?;
                            if rb2 + 1 < head.len() - 1 {
                                if !matches!(head[rb2 + 1], Tok::LBracket) {
                                    return Err(format!("line {}: the first argument of `{}` must be a variable, a[i], a[i][j] or a[i][j][k]", n, id));
                                }
                                let i3 = parse_expr_tokens(head[rb2 + 2..head.len() - 1].to_vec(), n)?;
                                if is_builtin(&id, "hb_hdel") || is_builtin(&id, "hb_hdelat") || is_builtin(&id, "hb_hfill") || is_builtin(&id, "hb_hsetcasematch") {
                                    return Err(format!("line {}: `{}` takes a hash variable, not a subscript", n, id));
                                } else if is_builtin(&id, "aadd") {
                                    out.push(Stmt::AAddSub3(n, v, i1, i2, i3, e));
                                } else {
                                    out.push(Stmt::ASizeSub3(n, v, i1, i2, i3, e));
                                }
                            } else if is_builtin(&id, "hb_hdel") || is_builtin(&id, "hb_hdelat") || is_builtin(&id, "hb_hfill") || is_builtin(&id, "hb_hsetcasematch") {
                                return Err(format!("line {}: `{}` takes a hash variable, not a subscript", n, id));
                            } else if is_builtin(&id, "aadd") {
                                out.push(Stmt::AAddSub2(n, v, i1, i2, e));
                            } else {
                                out.push(Stmt::ASizeSub2(n, v, i1, i2, e));
                            }
                        }
                        [Tok::Ident(v), Tok::LBracket, rest @ .., Tok::RBracket] if !rest.is_empty() && !rest.iter().any(|t| matches!(t, Tok::LBracket | Tok::RBracket)) => {
                            check_ident(v, n)?;
                            let idx = parse_expr_tokens(rest.to_vec(), n)?;
                            if is_builtin(&id, "hb_hdel") || is_builtin(&id, "hb_hdelat") || is_builtin(&id, "hb_hfill") || is_builtin(&id, "hb_hsetcasematch") {
                                return Err(format!("line {}: `{}` takes a hash variable, not a subscript", n, id));
                            } else if is_builtin(&id, "aadd") {
                                out.push(Stmt::AAddSub(n, v.clone(), idx, e));
                            } else {
                                out.push(Stmt::ASizeSub(n, v.clone(), idx, e));
                            }
                        }
                        _ => return Err(format!("line {}: the first argument of `{}` must be a variable, a[i] or a[i][j]", n, id)),
                    }
                    *i += 1;
                    continue;
                }
                if toks.len() >= 3 && toks[1] == Tok::Colon {
                    // o:name := e (simple receiver) or o:M(...) / o:name as
                    // a statement whose value is discarded (oracle cl2).
                    if toks.len() >= 4 {
                        if let [_, Tok::Colon, Tok::Ident(mname), Tok::Assign, rest @ ..] = toks.as_slice() {
                            check_ident(mname, n)?;
                            let e = parse_expr_tokens(rest.to_vec(), n)?;
                            out.push(Stmt::SendSet(n, Expr::Var(id.clone()), mname.clone(), e));
                            *i += 1;
                            continue;
                        }
                        let e = parse_expr_tokens(toks.to_vec(), n)?;
                        match e {
                            Expr::Send(..) => { out.push(Stmt::SendStmt(n, e)); *i += 1; continue; }
                            _ => return Err(format!("line {}: message-send statement not in the subset", n)),
                        }
                    }
                }
                if id.eq_ignore_ascii_case("qout") && toks.len() >= 3 && toks[1] == Tok::LParen && toks[toks.len() - 1] == Tok::RParen {
                    // QOut (oracle hk383): on the pinned gtstd build QOut
                    // is BYTE-IDENTICAL to `?` - leading newline, space-
                    // separated items, numbers width-padded, QOut() a
                    // blank line - so it desugars to the same
                    // Stmt::Print(..., false). Expression-position QOut
                    // (it returns NIL in Harbour) stays on the unknown-
                    // function path as a named limit of this increment.
                    let inner = &toks[2..toks.len() - 1];
                    let mut exprs = Vec::new();
                    if !inner.is_empty() {
                        let mut depth = 0i32;
                        let mut start = 0usize;
                        for (k, t) in inner.iter().enumerate() {
                            match t {
                                Tok::LParen | Tok::LBracket => depth += 1,
                                Tok::RParen | Tok::RBracket => depth -= 1,
                                Tok::Comma if depth == 0 => {
                                    exprs.push(parse_expr_tokens(inner[start..k].to_vec(), n)?);
                                    start = k + 1;
                                }
                                _ => {}
                            }
                        }
                        exprs.push(parse_expr_tokens(inner[start..].to_vec(), n)?);
                    }
                    out.push(Stmt::Print(n, exprs, false));
                    *i += 1;
                    continue;
                }
                if toks.len() >= 3 && toks[1] == Tok::LParen {
                    // Bare call statement (oracle hk216): `f(args)` as a
                    // whole line runs the call for its effect and
                    // discards the return. Anything else identifier-led
                    // with a call shape stays on the old error path.
                    if let Ok(Expr::Call(..)) = parse_expr_tokens(toks.clone(), n) {
                        let ce = parse_expr_tokens(toks.clone(), n).unwrap();
                        out.push(Stmt::CallStmt(n, ce));
                        *i += 1;
                        continue;
                    }
                }
                // Standalone ++/-- retain their existing desugaring
                // (oracle hk246): `x++`/`x--` desugar to `x := x +/- 1`
                // and `x op= e` desugars to `x := x op e` for +, -, *.
                if toks.len() == 2 && toks[1] == Tok::IncTok {
                    check_ident(&id, n)?;
                    out.push(Stmt::Assign(n, id.clone(), Expr::Bin('+', Box::new(Expr::Var(id.clone())), Box::new(Expr::Int("1".to_string())))));
                    *i += 1;
                    continue;
                }
                if toks.len() == 2 && toks[1] == Tok::DecTok {
                    check_ident(&id, n)?;
                    out.push(Stmt::Assign(n, id.clone(), Expr::Bin('-', Box::new(Expr::Var(id.clone())), Box::new(Expr::Int("1".to_string())))));
                    *i += 1;
                    continue;
                }
                if toks.len() >= 4 && toks[2] == Tok::Eq && matches!(toks[1], Tok::Plus | Tok::Minus | Tok::Star) {
                    let op = match toks[1] { Tok::Plus => '+', Tok::Minus => '-', _ => '*' };
                    check_ident(&id, n)?;
                    let e = parse_expr_tokens(toks[3..].to_vec(), n)?;
                    out.push(Stmt::Assign(n, id.clone(), Expr::Bin(op, Box::new(Expr::Var(id.clone())), Box::new(e))));
                    *i += 1;
                    continue;
                }
                if toks.len() >= 3 && toks[1] == Tok::Slash && toks[2] == Tok::Eq {
                    return Err(format!("line {}: `/=` is not in this increment: Harbour division yields decimals (oracle hk246: n /= 2 prints 24.00) and the float/decimal design is parked (hk226-hk233)", n));
                }
                // Harbour also assigns with a single `=` in statement
                // position (oracle hk214: `x = 41 + 1`, `c = 'eq'`); `=`
                // stays a comparison inside expressions.
                if toks.len() < 3 || (toks[1] != Tok::Assign && toks[1] != Tok::Eq) {
                    return Err(format!("line {}: statement not in the subset (identifier-led line is not an assignment; expected `name := expr`)", n));
                }
                check_ident(&id, n)?;
                let e = parse_expr_tokens(toks[2..].to_vec(), n)?;
                out.push(Stmt::Assign(n, id, e));
                *i += 1;
            }
            Tok::ColonColon => {
                // ::name := e (statement form inside a method body)
                match toks.as_slice() {
                    [Tok::ColonColon, Tok::Ident(mname), Tok::Assign, rest @ ..] => {
                        check_ident(mname, n)?;
                        let e = parse_expr_tokens(rest.to_vec(), n)?;
                        out.push(Stmt::SelfSet(n, mname.clone(), e));
                        *i += 1;
                    }
                    _ => {
                        let e = parse_expr_tokens(toks.to_vec(), n)?;
                        match e {
                            Expr::Send(..) | Expr::SelfGet(_) | Expr::SelfObj => { out.push(Stmt::SendStmt(n, e)); *i += 1; }
                            _ => return Err(format!("line {}: `::` statement not in the subset (expected `::name := expr`)", n)),
                        }
                    }
                }
            }
            Tok::IncTok => {
                // Prefix increment statement (oracle hk246): `++x` desugars
                // to `x := x + 1`. Longer shapes keep a named rejection.
                if toks.len() == 2 {
                    if let Tok::Ident(pid) = &toks[1] {
                        check_ident(pid, n)?;
                        out.push(Stmt::Assign(n, pid.clone(), Expr::Bin('+', Box::new(Expr::Var(pid.clone())), Box::new(Expr::Int("1".to_string())))));
                        *i += 1;
                        continue;
                    }
                }
                return Err(format!("line {}: expected the statement form `++x`; expression increments require a variable lvalue and an expression context", n));
            }
            Tok::DecTok => {
                // Prefix decrement statement (oracle hk246): `--x`.
                if toks.len() == 2 {
                    if let Tok::Ident(pid) = &toks[1] {
                        check_ident(pid, n)?;
                        out.push(Stmt::Assign(n, pid.clone(), Expr::Bin('-', Box::new(Expr::Var(pid.clone())), Box::new(Expr::Int("1".to_string())))));
                        *i += 1;
                        continue;
                    }
                }
                return Err(format!("line {}: expected the statement form `--x`; expression increments require a variable lvalue and an expression context", n));
            }
            Tok::LParen => {
                // HB_SYMBOL_UNUSED expands to ((symbol)). Evaluate the
                // expression; a bare variable is only read, never moved.
                let e = parse_expr_tokens(toks.clone(), n)?;
                out.push(Stmt::CallStmt(n, e));
                *i += 1;
            }
            t => return Err(format!("line {}: statement not in the subset ({:?})", n, t)),
        }
    }
    Ok(())
}

// Class surface (parser landed; runtime representation pending the user's
// decision): CREATE CLASS / DATA / METHOD / INHERIT declarations, METHOD
// ... CLASS definitions. Semantics probed in sondas_ac/classes (cl1-cl21).
struct ClassDecl {
    name: String,
    parent: Option<String>,
    datas: Vec<(String, Option<Expr>)>,           // DATA name [INIT expr]
    methods: Vec<(String, Vec<String>, bool)>,    // name, params, is_constructor
}
struct MethodDef {
    class_name: String,
    f: Func,
}
struct Prog {
    funcs: Vec<Func>,
    classes: Vec<ClassDecl>,
    methods: Vec<MethodDef>,
}

fn parse(src: &str) -> Result<Prog, String> {
    let mut lines: Vec<(usize, Vec<Tok>)> = Vec::new();
    for (idx, raw) in src.lines().enumerate() {
        let n = idx + 1;
        let toks = tokenize(raw, n)?;
        // NOTE starts an old-style comment to end of line (oracle hk249),
        // at file scope or inside a body; a `note` variable being
        // assigned stays a statement.
        if matches!(toks.first(), Some(Tok::Ident(id)) if id.eq_ignore_ascii_case("note"))
            && !matches!(toks.get(1), Some(Tok::Assign) | Some(Tok::Eq)) {
            continue;
        }
        if !toks.is_empty() { lines.push((n, toks)); }
    }

    let mut funcs: Vec<Func> = Vec::new();
    let mut classes: Vec<ClassDecl> = Vec::new();
    let mut methods: Vec<MethodDef> = Vec::new();
    let mut requests: Vec<(usize, String)> = Vec::new();
    let mut i = 0usize;
    while i < lines.len() {
        let (n, toks) = &lines[i];
        let n = *n;
        // File-scope declaration lines, measured on the pinned Harbour:
        // MEMVAR (hk247b) only relaxes Harbour's compile-time memvar name
        // resolution - memvars are not in this subset, the declaration
        // alone has no runtime effect, so it is accepted and ignored.
        // REQUEST (hk250a) is a link-time module request with no meaning
        // for this compiler. INIT/EXIT PROCEDURE (startup/teardown
        // semantics) and file-scope STATIC variables (global storage, not
        // in the subset) keep named rejections.
        if matches!(&toks[0], Tok::Ident(id) if id.eq_ignore_ascii_case("memvar")) {
            // Declaration only: it creates NO storage. Any later memvar
            // reference still fails with the usual unknown-variable error,
            // so accepting the line can never fabricate a working memvar.
            i += 1;
            continue;
        }
        if matches!(&toks[0], Tok::Ident(id) if id.eq_ignore_ascii_case("request")) {
            // REQUEST pulls a module (and its init code) into the link.
            // This subset has no module linking, so the only REQUEST that
            // is genuinely inert names a function defined in this same
            // file; anything else would silently skip a required effect.
            // Validated after the whole file is parsed.
            match toks.get(1) {
                Some(Tok::Ident(sym)) if toks.len() == 2 => requests.push((n, sym.to_lowercase())),
                _ => return Err(format!("line {}: REQUEST with a symbol list is not in this increment (the subset has no module linking)", n)),
            }
            i += 1;
            continue;
        }
        if (toks[0] == Tok::KwInit || toks[0] == Tok::KwExit)
            && toks.len() >= 2 && toks[1] == Tok::KwFunction {
            return Err(format!("line {}: INIT/EXIT PROCEDURE is not in this increment (startup/teardown ordering needs its own design)", n));
        }
        // STATIC FUNCTION/PROCEDURE is plain visibility: a single-module
        // compiler has one visibility domain (oracle hk249). File-scope
        // STATIC variables are global storage, not in this subset.
        let toks: &[Tok] = if matches!(&toks[0], Tok::Ident(id) if id.eq_ignore_ascii_case("static")) {
            if toks.len() >= 2 && toks[1] == Tok::KwFunction {
                &toks[1..]
            } else {
                return Err(format!("line {}: file-scope STATIC variables are not in this increment (global storage needs its own design); STATIC FUNCTION/PROCEDURE works", n));
            }
        } else {
            &toks[..]
        };
        // CREATE CLASS Name [INHERIT Base] ... ENDCLASS
        if toks[0] == Tok::KwCreate {
            let (cname, parent) = match toks {
                [Tok::KwCreate, Tok::KwClass, Tok::Ident(c)] => { check_ident(c, n)?; (c.clone(), None) }
                [Tok::KwCreate, Tok::KwClass, Tok::Ident(c), Tok::KwInherit, Tok::Ident(b)] => {
                    check_ident(c, n)?; check_ident(b, n)?; (c.clone(), Some(b.clone()))
                }
                [Tok::KwCreate, Tok::KwClass, Tok::Ident(_), Tok::KwInherit, Tok::Ident(_), Tok::Comma, ..] => {
                    return Err(format!("line {}: multiple inheritance is not in this increment (oracle cl21: Harbour accepts it)", n));
                }
                _ => return Err(format!("line {}: expected `CREATE CLASS Name [INHERIT Base]`", n)),
            };
            if classes.iter().any(|c| c.name == cname) {
                return Err(format!("line {}: duplicate class `{}`", n, cname));
            }
            i += 1;
            let mut decl = ClassDecl { name: cname, parent, datas: Vec::new(), methods: Vec::new() };
            loop {
                if i >= lines.len() { return Err(format!("class `{}` without ENDCLASS", decl.name)); }
                let (ln, lt) = &lines[i];
                let ln = *ln;
                match lt.as_slice() {
                    [Tok::KwEndclass] => { i += 1; break; }
                    [Tok::KwData, Tok::Ident(d)] => { check_ident(d, ln)?; decl.datas.push((d.clone(), None)); i += 1; }
                    [Tok::KwData, Tok::Ident(d), Tok::KwInit, rest @ ..] => {
                        check_ident(d, ln)?;
                        decl.datas.push((d.clone(), Some(parse_expr_tokens(rest.to_vec(), ln)?)));
                        i += 1;
                    }
                    [Tok::KwMethod, Tok::Ident(m), Tok::LParen, rest @ .., Tok::RParen] => {
                        check_ident(m, ln)?;
                        let ps = parse_param_names(rest, ln)?;
                        decl.methods.push((m.clone(), ps, false));
                        i += 1;
                    }
                    [Tok::KwMethod, Tok::Ident(m), Tok::LParen, rest @ .., Tok::RParen, Tok::KwConstructor] => {
                        check_ident(m, ln)?;
                        let ps = parse_param_names(rest, ln)?;
                        decl.methods.push((m.clone(), ps, true));
                        i += 1;
                    }
                    [Tok::Ident(scope), Tok::Colon] | [Tok::Ident(scope)] if matches!(scope.to_ascii_lowercase().as_str(), "protected" | "hidden" | "exported") => {
                        return Err(format!("line {}: class scopes ({}:, ...) are not in this increment - Harbour enforces them at runtime (oracle cl8)", ln, scope));
                    }
                    _ => return Err(format!("line {}: class member line not in the subset (DATA / METHOD / ENDCLASS)", ln)),
                }
            }
            classes.push(decl);
            continue;
        }
        // METHOD Name(params) CLASS CName ... return ...
        if toks[0] == Tok::KwMethod {
            let (mname, params, cname) = match toks {
                [Tok::KwMethod, Tok::Ident(m), Tok::LParen, rest @ .., Tok::RParen, Tok::KwClass, Tok::Ident(c)] => {
                    check_ident(m, n)?; check_ident(c, n)?;
                    (m.clone(), parse_param_names(rest, n)?, c.clone())
                }
                [Tok::KwMethod, Tok::Ident(m), Tok::LParen, Tok::RParen, Tok::KwClass, Tok::Ident(c)] => {
                    check_ident(m, n)?; check_ident(c, n)?;
                    (m.clone(), Vec::new(), c.clone())
                }
                _ => return Err(format!("line {}: expected `METHOD Name(params) CLASS ClassName`", n)),
            };
            if !classes.iter().any(|c| c.name == cname) {
                return Err(format!("line {}: method `{}` defined for unknown class `{}`", n, mname, cname));
            }
            i += 1;
            let mut f = Func { name: format!("{}__{}", cname, mname), params, ret: None, stmts: Vec::new(), dyn_names: std::collections::HashSet::new() };
            parse_stmts(&lines, &mut i, &mut f.stmts, 0)?;
            if i >= lines.len() || lines[i].1[0] != Tok::KwReturn {
                return Err(format!("method `{}` of `{}` without closing return", mname, cname));
            }
            let (rn, rt) = &lines[i];
            let stmt = match rt.len() {
                1 => Stmt::Ret(*rn, None),
                2 if rt[1] == Tok::KwNil => Stmt::Ret(*rn, None),
                _ => Stmt::Ret(*rn, Some(parse_expr_tokens(rt[1..].to_vec(), *rn)?)),
            };
            f.stmts.push(stmt);
            methods.push(MethodDef { class_name: cname, f });
            i += 1;
            continue;
        }
        if toks[0] != Tok::KwFunction {
            if funcs.is_empty() && classes.is_empty() && methods.is_empty() {
                // Implicit main (oracle hk247a): the FIRST group of
                // top-level statements is the module entry when the file
                // declares no explicit `main`. Later groups are silently
                // dropped by Harbour (hk247c/hk247f) - this increment
                // rejects them by name below instead, and an explicit
                // `function main()` after an implicit group trips the
                // duplicate-function check (Harbour silently prefers the
                // explicit one, hk247e).
                let mut f = Func { name: "main".to_string(), params: Vec::new(), ret: None, stmts: Vec::new(), dyn_names: std::collections::HashSet::new() };
                parse_stmts(&lines, &mut i, &mut f.stmts, 0)?;
                if i < lines.len() && lines[i].1[0] == Tok::KwReturn {
                    let (rn, rt) = &lines[i];
                    let stmt = match rt.len() {
                        1 => Stmt::Ret(*rn, None),
                        2 if rt[1] == Tok::KwNil => Stmt::Ret(*rn, None),
                        _ => Stmt::Ret(*rn, Some(parse_expr_tokens(rt[1..].to_vec(), *rn)?)),
                    };
                    f.stmts.push(stmt);
                    i += 1;
                } else {
                    f.stmts.push(Stmt::Ret(n, None));
                }
                funcs.push(f);
                continue;
            }
            return Err(format!("line {}: code outside a function (Harbour silently drops top-level statements after the first group - hk247c/hk247f; this increment rejects them by name)", n));
        }
        let (name, params) = match toks {
            [Tok::KwFunction, Tok::Ident(id), Tok::LParen, Tok::RParen] => {
                check_ident(id, n)?;
                (id.clone(), Vec::new())
            }
            [Tok::KwFunction, Tok::Ident(id), Tok::LParen, rest @ .., Tok::RParen] if !rest.is_empty() => {
                check_ident(id, n)?;
                let mut ps: Vec<String> = Vec::new();
                for (k, t) in rest.iter().enumerate() {
                    let want_ident = k % 2 == 0;
                    match (want_ident, t) {
                        (true, Tok::Ident(p)) => {
                            check_ident(p, n)?;
                            if ps.iter().any(|q| q == p) {
                                return Err(format!("line {}: duplicate parameter `{}`", n, p));
                            }
                            ps.push(p.clone());
                        }
                        (false, Tok::Comma) => {}
                        _ => return Err(format!("line {}: expected `function name(a, b)` with comma-separated parameters", n)),
                    }
                }
                (id.clone(), ps)
            }
            _ => return Err(format!("line {}: expected `function name(...)`", n)),
        };
        i += 1;
        let mut f = Func { name, params, ret: None, stmts: Vec::new(), dyn_names: std::collections::HashSet::new() };
        parse_stmts(&lines, &mut i, &mut f.stmts, 0)?;
        if i >= lines.len() || lines[i].1[0] != Tok::KwReturn {
            return Err(format!("function `{}` without closing return", f.name));
        }
        let (n, toks) = &lines[i];
        let stmt = match toks.len() {
            1 => Stmt::Ret(*n, None),
            2 if toks[1] == Tok::KwNil => Stmt::Ret(*n, None),
            _ => Stmt::Ret(*n, Some(parse_expr_tokens(toks[1..].to_vec(), *n)?)),
        };
        f.stmts.push(stmt);
        funcs.push(f);
        i += 1;
    }
    if funcs.is_empty() {
        return Err("no functions found".to_string());
    }
    // REQUEST honored only when genuinely inert: the symbol is a
    // function defined in this same file (validated post-parse so the
    // definition may appear after the REQUEST line). Anything else
    // would silently skip Harbour's link/module-init effect.
    for (ln, sym) in &requests {
        if !funcs.iter().any(|f| f.name.eq_ignore_ascii_case(sym)) {
            return Err(format!("line {}: REQUEST `{}` cannot be honored: the subset has no module linking; only functions defined in this file may be requested", ln, sym));
        }
    }
    Ok(Prog { funcs, classes, methods })
}

// Comma-separated parameter names out of a method declaration's token
// slice (same rules as `function name(a, b)`).
fn parse_param_names(rest: &[Tok], n: usize) -> Result<Vec<String>, String> {
    let mut ps: Vec<String> = Vec::new();
    for (k, tk) in rest.iter().enumerate() {
        match (k % 2 == 0, tk) {
            (true, Tok::Ident(p)) => {
                check_ident(p, n)?;
                if ps.iter().any(|q| q == p) { return Err(format!("line {}: duplicate parameter `{}`", n, p)); }
                ps.push(p.clone());
            }
            (false, Tok::Comma) => {}
            _ => return Err(format!("line {}: expected comma-separated parameters", n)),
        }
    }
    Ok(ps)
}

// ---------------------------------------------------------------------------
// Function signature: name, parameter types (i64 only in this increment),
// return type. Passing an integer argument COPIES it (Rust i64 is Copy);
// passing a string is a type error at the call site in this increment.
#[derive(Clone)]
struct Sig {
    name: String,
    params: Vec<Ty>,
    // None when the function ends in `return nil` (void): its result cannot
    // be used in an expression in this PoC.
    ret: Option<Ty>,
    // Per-parameter calling-convention flags for array parameters.
    // borrowed[i]: some call site passes a[i] (a MIDDLE cell of an array of
    // arrays) - the callee receives the cell's ADDRESS and borrows it for
    // the call (oracles hk73/hk78/hk86/hk87). arr_moved[i]: some call site
    // moves an owned array variable in (the established contract). The two
    // modes exclude each other for the same parameter.
    borrowed: Vec<bool>,
    arr_moved: Vec<bool>,
    // inferred[i]: parameter i's type genuinely comes from the callee's
    // own body evidence (pin). FALSE only for placeholder entries of the
    // order-independent fixpoint (seed, or still-unpinned after a round);
    // call sites skip their per-argument checks against an uninferred
    // parameter - the callee's pin error is the honest diagnostic, and a
    // check against a placeholder would be a placeholder artifact.
    inferred: Vec<bool>,
    // arg_ev[i]: at least one call site passes a FLOAT argument for
    // parameter i (63zd). Recorded by the checker's call-argument walk
    // even while the parameter is a placeholder; pin_params merges it
    // with the body's own evidence (I64 + float argument -> F64, since
    // Harbour's integer argument converts at the boundary - oracles
    // hk302/hk303/hk306). Reset at the start of every inference round so
    // a stale mid-convergence reading cannot stick.
    arg_ev: Vec<Option<Ty>>,
    // nil_ev[i]: at least one call site OMITS parameter i (multiarg).
    // Harbour fills omitted trailing arguments with NIL, so the parameter
    // must carry NIL: the fixpoint forces it to the tagged union (Dyn).
    // Sticky and monotone like arg_ev.
    nil_ev: Vec<bool>,
}

// Semantic analysis: types + ownership/move tracking. This pass is OURS:
// nothing here is delegated to another compiler.
//
// Locals: (name, type, moved). Strings move on assignment / return (like a
// Rust String); integers are Copy (like a Rust i64). Printing borrows.
// ---------------------------------------------------------------------------

#[derive(Clone)]
struct Local {
    name: String,
    ty: Ty,
    moved: bool,
    ro: bool, // read-only: the `for` loop variable cannot be assigned
    byref: bool, // a parameter some caller passes as `@p`: borrowed from its owner, never moved out
}

// ---------------------------------------------------------------------------
// Parameter type pinning (pre-pass, syntactic). Harbour parameters are
// untyped; this PoC is statically typed, so a parameter's type is pinned by
// how the body uses it: under arithmetic it is an integer, compared against
// a string literal (or a literal-initialized local) it is a string, passed
// to another function it takes that parameter's type. A parameter the body
// only prints pins to the tagged union (oracles hk257/hk259: Harbour routes
// any scalar through a print-only parameter); printing is weak evidence,
// so any arithmetic/concat/known-type compare still wins. A parameter the
// body only returns or copies is NOT pinnable: report it honestly instead
// of guessing.
// ---------------------------------------------------------------------------
fn pin_params(f: &Func, sigs: &[Sig]) -> Result<(Vec<Option<Ty>>, Option<String>), String> {
    let n = f.params.len();
    let mut pin: Vec<Option<Ty>> = vec![None; n];
    let mut lit: Vec<(String, Ty)> = Vec::new(); // literal-initialized locals
    let mut printed: Vec<bool> = vec![false; n]; // params printed as a whole-variable item
    fn is_param(f: &Func, id: &str) -> Option<usize> {
        f.params.iter().position(|p| p == id)
    }
    // Evidence that an expression is a string at pin time: a literal, a
    // literal-initialized local, or a call whose signature returns one.
    fn str_evidence(e: &Expr, lit: &[(String, Ty)], sigs: &[Sig]) -> bool {
        match e {
            Expr::Str(_) => true,
            Expr::Var(v) => lit.iter().any(|(x, t)| x == v && matches!(*t, Ty::Str | Ty::StrOwn)),
            Expr::Call(id, _) => sigs.iter().any(|s| s.name == *id && matches!(s.ret, Some(Ty::Str) | Some(Ty::StrOwn))),
            _ => false,
        }
    }
    // Evidence that an expression is float-TYPED at pin time (63zd): a
    // float literal or fold, a literal-initialized float local, a call
    // whose signature returns a float, a parameter already pinned F64, or
    // arithmetic that yields a double - Harbour divides EVERY numeric
    // pair as doubles (hb_vmDivide, oracle hk292), so `/` is always
    // float-typed, while +,-,* are float-typed when either side is.
    fn f64_typed(e: &Expr, lit: &[(String, Ty)], sigs: &[Sig], f: &Func, pin: &[Option<Ty>]) -> bool {
        match e {
            Expr::Seq(es) => f64_typed(es.last().expect("nonempty"), lit, sigs, f, pin),
            Expr::Float(..) | Expr::FloatV(..) => true,
            Expr::Var(v) => lit.iter().any(|(x, t)| x == v && *t == Ty::F64)
                || is_param(f, v).map(|i| pin[i] == Some(Ty::F64)).unwrap_or(false),
            Expr::Call(id, _) => sigs.iter().any(|s| s.name == *id && s.ret == Some(Ty::F64)),
            Expr::Bin(op, a, b) => *op == '/' || *op == '%' || *op == '^' || f64_typed(a, lit, sigs, f, pin) || f64_typed(b, lit, sigs, f, pin),
            _ => false,
        }
    }
    fn str_typed(e: &Expr, lit: &[(String, Ty)], sigs: &[Sig], f: &Func, pin: &[Option<Ty>]) -> bool {
        match e {
            Expr::Str(_) => true,
            Expr::Var(v) => lit.iter().any(|(x, t)| x == v && matches!(*t, Ty::Str | Ty::StrOwn))
                || is_param(f, v).map(|i| matches!(pin[i], Some(Ty::Str | Ty::StrOwn))).unwrap_or(false),
            Expr::Call(id, _) => sigs.iter().any(|s| s.name == *id && matches!(s.ret, Some(Ty::Str | Ty::StrOwn))),
            Expr::Bin('+', a, b) => str_typed(a, lit, sigs, f, pin) || str_typed(b, lit, sigs, f, pin),
            _ => false,
        }
    }
    fn setpin(pin: &mut Vec<Option<Ty>>, idx: usize, ty: Ty, n: usize) -> Result<(), String> {
        fn tname(t: Ty) -> &'static str {
            match t {
                Ty::I64 => "an integer",
                Ty::F64 => "a float",
                Ty::Str => "a string",
                Ty::Dyn => "a NIL-capable value",
                Ty::StrOwn => "a string",
                Ty::DArrS => "an array of strings",
                Ty::Hash => "a hash",
                _ => "a value of another type",
            }
        }
        match pin[idx] {
            None => { pin[idx] = Some(ty); Ok(()) }
            Some(t) if t == ty => Ok(()),
            // A parameter used numerically in one place and as NIL in
            // another pins to the tagged union (probe n2: x := NIL / x := 9).
            Some(t) if matches!((t, ty), (Ty::I64, Ty::Dyn) | (Ty::Dyn, Ty::I64)) => {
                pin[idx] = Some(Ty::Dyn);
                Ok(())
            }
            // Whole-array evidence (len(p)) and nested evidence (p[i][j],
            // len(p[i])) describe the same array of arrays (oracle pr1).
            Some(t) if matches!((t, ty), (Ty::DArr, Ty::DArr2) | (Ty::DArr2, Ty::DArr)) => {
                pin[idx] = Some(Ty::DArr2);
                Ok(())
            }
            Some(t) if matches!((t, ty), (Ty::DArr, Ty::DArr3) | (Ty::DArr3, Ty::DArr) | (Ty::DArr2, Ty::DArr3) | (Ty::DArr3, Ty::DArr2)) => {
                pin[idx] = Some(Ty::DArr3);
                Ok(())
            }
            // Four-level evidence (p[i][j][k][l], len(p[i][j][k])) merges
            // with every shallower whole-array evidence (hk111).
            Some(t) if matches!((t, ty), (Ty::DArr, Ty::DArr4) | (Ty::DArr4, Ty::DArr) | (Ty::DArr2, Ty::DArr4) | (Ty::DArr4, Ty::DArr2) | (Ty::DArr3, Ty::DArr4) | (Ty::DArr4, Ty::DArr3)) => {
                pin[idx] = Some(Ty::DArr4);
                Ok(())
            }
            // Whole-array evidence (len(p) pins DArr) merges with
            // string-element evidence (AAdd(p, "x"), p[i] := "x", p[i] in
            // a string context): an array of strings (hb_HKeys shape).
            Some(t) if matches!((t, ty), (Ty::DArr, Ty::DArrS) | (Ty::DArrS, Ty::DArr)) => {
                pin[idx] = Some(Ty::DArrS);
                Ok(())
            }
            // len(p) pins a flat dynamic array and a string key pins a
            // hash; both layouts carry the count in the same word and
            // len() of a hash is its pair count (oracle hk11), so the
            // hash pin - the evidence that can tell the two apart - wins.
            Some(t) if matches!((t, ty), (Ty::DArr, Ty::Hash) | (Ty::Hash, Ty::DArr)) => {
                pin[idx] = Some(Ty::Hash);
                Ok(())
            }
            // NIL/comparison evidence pins Dyn and a string assignment
            // pins StrOwn; the tagged union already carries owned
            // strings (tag 4), so Dyn absorbs the string pin (63ze;
            // t659/t662: `v := "callee"` after `if v = NIL`).
            Some(t) if matches!((t, ty), (Ty::Dyn, Ty::StrOwn) | (Ty::StrOwn, Ty::Dyn) | (Ty::Dyn, Ty::Str) | (Ty::Str, Ty::Dyn)) => {
                pin[idx] = Some(Ty::Dyn);
                Ok(())
            }
            Some(t) => Err(format!("line {}: parameter used as both {} and {}", n, tname(t), tname(ty))),
        }
    }
    // Pin parameter vars appearing directly (not under a call) in e.
    fn pin_vars(f: &Func, e: &Expr, ty: Ty, pin: &mut Vec<Option<Ty>>, n: usize) -> Result<(), String> {
        // String parameters are uniformly OWNED strings (StrOwn): the
        // callee owns and frees its parameter, a rodata argument is
        // copied at the call boundary and an owned argument moves. One
        // kind keeps the freeing behaviour unambiguous.
        let ty = if ty == Ty::Str { Ty::StrOwn } else { ty };
        // Float evidence pins a VARIABLE only (63zd): the operands of a
        // float-typed compound expression may legitimately stay integers
        // (Harbour promotes them inside float arithmetic), so there is
        // nothing to pin through.
        if ty == Ty::F64 {
            return match e {
                Expr::Seq(es) => pin_vars(f, es.last().expect("nonempty"), ty, pin, n),
                Expr::Var(id) => { if let Some(i) = is_param(f, id) { setpin(pin, i, ty, n)?; } Ok(()) }
                _ => Ok(()),
            };
        }
        match e {
            Expr::Seq(es) => pin_vars(f, es.last().expect("nonempty"), ty, pin, n),
            Expr::Inc(id, _, _) => { if let Some(i) = is_param(f, id) { setpin(pin, i, Ty::I64, n)?; } Ok(()) }
            Expr::Var(id) => { if let Some(i) = is_param(f, id) { setpin(pin, i, ty, n)?; } Ok(()) }
            Expr::Bin(_, a, b) => { pin_vars(f, a, Ty::I64, pin, n)?; pin_vars(f, b, Ty::I64, pin, n) }
            Expr::Cmp(_, a, b) => { pin_vars(f, a, ty, pin, n)?; pin_vars(f, b, ty, pin, n) }
            Expr::Log(_) => Ok(()),
            Expr::LNot(a) => pin_vars(f, a, Ty::Bool, pin, n),
            Expr::LAnd(a, b) | Expr::LOr(a, b) => { pin_vars(f, a, Ty::Bool, pin, n)?; pin_vars(f, b, Ty::Bool, pin, n) }
            Expr::Call(_, _) => Ok(()), // call arguments pin via the callee's signature, not the outer context
            Expr::SelfObj | Expr::SelfGet(_) => Ok(()),
            Expr::Send(_, _, _) => Ok(()), // like a call: nothing pins through the message syntax
            Expr::ArrLit(es) => { for e in es { pin_vars(f, e, Ty::I64, pin, n)?; } Ok(()) }
            Expr::IdxCompound(id, ie, _, re) => {
                if is_param(f, id).is_some() {
                    // Fixed arrays cannot be parameters here, so an
                    // indexed compound assignment never pins one.
                    return Err(format!("line {}: `a[i] op= e` through a parameter is not in this increment (fixed arrays cannot be parameters)", n));
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, re, Ty::I64, pin, n)
            }
            Expr::Index(id, ie) => {
                if is_param(f, id).is_some() {
                    // p["key"]: a literal string key pins a hash parameter
                    // (oracles hk11/hk12).
                    if matches!(**ie, Expr::Str(_)) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, n)?;
                    // p[i] in a string context (compared against a string
                    // or passed to a string parameter): the parameter is
                    // an array of strings (the hb_HKeys shape).
                    } else if ty == Ty::StrOwn {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArrS, pin, n)?;
                    } else {
                        return Err(format!("line {}: array parameters are not in this increment", n));
                    }
                }
                pin_vars(f, ie, Ty::I64, pin, n)
            }
            Expr::Index2(id, ie, ie2) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j] pins the parameter to an array of
                    // arrays (oracle pr1).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)
            }
            Expr::Index3(id, ie, ie2, ie3) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j][k] pins the parameter to an array of
                    // arrays of arrays (oracle pr9).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)?;
                pin_vars(f, ie3, Ty::I64, pin, n)
            }
            Expr::Index4(id, ie, ie2, ie3, ie4) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j][k][l] pins the parameter to an array of
                    // arrays of arrays (oracle pr9).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr4, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)?;
                pin_vars(f, ie3, Ty::I64, pin, n)?;
                pin_vars(f, ie4, Ty::I64, pin, n)
            }
            _ => Ok(()),
        }
    }
    fn walk(f: &Func, e: &Expr, sigs: &[Sig], lit: &[(String, Ty)], pin: &mut Vec<Option<Ty>>, printed: &mut Vec<bool>, n: usize) -> Result<(), String> {
        match e {
            Expr::Seq(es) => { for e in es { walk(f, e, sigs, lit, pin, printed, n)?; } Ok(()) }
            Expr::Inc(id, _, _) => pin_vars(f, &Expr::Var(id.clone()), Ty::I64, pin, n),
            Expr::Bin(op, a, b) => {
                // String `+` (oracle hk215): a `+` with string evidence on
                // either side pins both sides to strings, not integers.
                let str_side = str_evidence(a, lit, sigs) || str_evidence(b, lit, sigs)
                    || matches!(a.as_ref(), Expr::Var(v) if is_param(f, v).map(|i| matches!(pin[i], Some(Ty::Str | Ty::StrOwn))).unwrap_or(false))
                    || matches!(b.as_ref(), Expr::Var(v) if is_param(f, v).map(|i| matches!(pin[i], Some(Ty::Str | Ty::StrOwn))).unwrap_or(false));
                // Float arithmetic (63zd): a float-typed operand of
                // +,-,* pins a parameter operand F64. Division pins
                // nothing: `p / 2` is float-VALUED with an integer p
                // (hb_vmDivide, oracle hk292), so p keeps its own type
                // and converts inside the op like Harbour's (double)n.
                let f64_side = *op != '/' && (f64_typed(a, lit, sigs, f, pin) || f64_typed(b, lit, sigs, f, pin));
                if *op == '+' && str_side {
                    pin_vars(f, a, Ty::Str, pin, n)?;
                    pin_vars(f, b, Ty::Str, pin, n)?;
                } else if f64_side {
                    pin_vars(f, a, Ty::F64, pin, n)?;
                    pin_vars(f, b, Ty::F64, pin, n)?;
                } else {
                    pin_vars(f, a, Ty::I64, pin, n)?;
                    pin_vars(f, b, Ty::I64, pin, n)?;
                }
                walk(f, a, sigs, lit, pin, printed, n)?;
                walk(f, b, sigs, lit, pin, printed, n)
            }
            Expr::Cmp(_, a, b) => {
                let ta = match a.as_ref() {
                    Expr::Str(_) => Some(Ty::Str),
                    Expr::Int(_) => Some(Ty::I64),
                    Expr::Float(..) | Expr::FloatV(..) => Some(Ty::F64),
                    Expr::Nil => Some(Ty::Dyn),
                    Expr::Var(v) => lit.iter().find(|(x, _)| x == v).map(|(_, t)| *t),
                    _ => None,
                };
                let tb = match b.as_ref() {
                    Expr::Str(_) => Some(Ty::Str),
                    Expr::Int(_) => Some(Ty::I64),
                    Expr::Float(..) | Expr::FloatV(..) => Some(Ty::F64),
                    Expr::Nil => Some(Ty::Dyn),
                    Expr::Var(v) => lit.iter().find(|(x, _)| x == v).map(|(_, t)| *t),
                    _ => None,
                };
                if let Some(t) = ta { pin_vars(f, b, t, pin, n)?; }
                if let Some(t) = tb { pin_vars(f, a, t, pin, n)?; }
                walk(f, a, sigs, lit, pin, printed, n)?; walk(f, b, sigs, lit, pin, printed, n)
            }
            Expr::Log(_) => Ok(()),
            Expr::LNot(a) => { pin_vars(f, a, Ty::Bool, pin, n)?; walk(f, a, sigs, lit, pin, printed, n) }
            Expr::LAnd(a, b) | Expr::LOr(a, b) => {
                pin_vars(f, a, Ty::Bool, pin, n)?;
                pin_vars(f, b, Ty::Bool, pin, n)?;
                walk(f, a, sigs, lit, pin, printed, n)?;
                walk(f, b, sigs, lit, pin, printed, n)
            }
            Expr::Call(id, args) => {
                if is_output_call(id) {
                    for a in args {
                        if let Expr::Var(v) = a {
                            if let Some(i) = is_param(f, v) { printed[i] = true; }
                        }
                        walk(f, a, sigs, lit, pin, printed, n)?;
                    }
                    return Ok(());
                }
                if is_builtin(id, "hb_memcheck") {
                    return Ok(());
                }
                if is_builtin(id, "procline") { return Ok(()); }
                if is_builtin(id, "len") && !args.is_empty() {
                    match &args[0] {
                        Expr::Index(v, _) if is_param(f, v).is_some() => {
                            // len(p[i]) borrows a child: the parameter is an
                            // array of arrays (oracle pr1).
                            pin_vars(f, &Expr::Var(v.clone()), Ty::DArr2, pin, n)?;
                        }
                        Expr::Index2(v, _, _) if is_param(f, v).is_some() => {
                            // len(p[i][j]) borrows two levels: the parameter
                            // is an array of arrays of arrays (oracle pr9).
                            pin_vars(f, &Expr::Var(v.clone()), Ty::DArr3, pin, n)?;
                        }
                        Expr::Index3(v, _, _, _) if is_param(f, v).is_some() => {
                            // len(p[i][j][k]) borrows three levels: the
                            // parameter is a four-level array (hk111).
                            pin_vars(f, &Expr::Var(v.clone()), Ty::DArr4, pin, n)?;
                        }
                        _ => pin_vars(f, &args[0], Ty::DArr, pin, n)?,
                    }
                    return walk(f, &args[0], sigs, lit, pin, printed, n);
                }
                if ["asc", "ltrim", "rtrim", "alltrim", "trim"].iter().any(|b| is_builtin(id,b)) {
                    for a in args { pin_vars(f,a,Ty::Str,pin,n)?; walk(f,a,sigs,lit,pin,printed,n)?; }
                    return Ok(());
                }
                if is_builtin(id, "chr") {
                    for a in args { pin_vars(f, a, Ty::I64, pin, n)?; walk(f, a, sigs, lit, pin, printed, n)?; }
                    return Ok(());
                }
                if is_builtin(id, "eval") {
                    // eval(b, a1..an) PINS a codeblock parameter (33p):
                    // the arity evidence is the argument count. Harbour
                    // tolerates EXTRA ignored arguments (probes c7/c7b);
                    // with a parameter the pin must match the block's
                    // arity exactly - a conservative named rejection, not
                    // a miscompile (registered limitation).
                    if !args.is_empty() {
                        pin_vars(f, &args[0], Ty::Block(args.len() - 1), pin, n)?;
                        // The extra eval arguments are integers here (same
                        // contract as the checker), so they pin I64 too.
                        for a in &args[1..] { pin_vars(f, a, Ty::I64, pin, n)?; }
                    }
                    for a in args { walk(f, a, sigs, lit, pin, printed, n)?; }
                    return Ok(());
                }
                if is_builtin(id, "array") {
                    // Array(n[, m]) dimensions are integers (oracles
                    // m3/m10); a parameter used as a dimension pins I64.
                    for a in args { pin_vars(f, a, Ty::I64, pin, n)?; walk(f, a, sigs, lit, pin, printed, n)?; }
                    return Ok(());
                }
                if is_builtin(id, "hb_pvalue") {
                    // hb_PValue(n): the index is an integer (multiarg).
                    if args.len() == 1 {
                        pin_vars(f, &args[0], Ty::I64, pin, n)?;
                        return walk(f, &args[0], sigs, lit, pin, printed, n);
                    }
                }
                if let Some(sig) = sigs.iter().find(|v| v.name == *id) {
                    for (i, a) in args.iter().enumerate() {
                        // Only GENUINELY inferred parameter types are
                        // evidence; pinning against a fixpoint placeholder
                        // would launder it into a concrete type (63o).
                        if i < sig.params.len() && sig.inferred.get(i).copied().unwrap_or(false) {
                            match a {
                                Expr::ByRef(vn) => pin_vars(f, &Expr::Var(vn.clone()), sig.params[i], pin, n)?,
                                _ => pin_vars(f, a, sig.params[i], pin, n)?,
                            }
                        }
                    }
                }
                for a in args { walk(f, a, sigs, lit, pin, printed, n)?; }
                Ok(())
            }
            Expr::ArrLit(es) => {
                for e in es { pin_vars(f, e, Ty::I64, pin, n)?; walk(f, e, sigs, lit, pin, printed, n)?; }
                Ok(())
            }
            Expr::IdxCompound(id, ie, _, re) => {
                if is_param(f, id).is_some() {
                    return Err(format!("line {}: `a[i] op= e` through a parameter is not in this increment (fixed arrays cannot be parameters)", n));
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, re, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, printed, n)?;
                walk(f, re, sigs, lit, pin, printed, n)
            }
            Expr::Index(id, ie) => {
                if is_param(f, id).is_some() {
                    // p["key"]: a string key pins a hash parameter
                    // (oracles hk11/hk12); a numeric index pins a DYNAMIC
                    // array (fixed arrays cannot be parameters here).
                    if str_evidence(ie, lit, sigs) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, n)?;
                    } else {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, n)?;
                    }
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, printed, n)
            }
            Expr::Index2(id, ie, ie2) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j] pins the parameter to an array of
                    // arrays (oracle pr1).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, printed, n)?;
                walk(f, ie2, sigs, lit, pin, printed, n)
            }
            Expr::Index3(id, ie, ie2, ie3) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j][k] pins the parameter to an array of
                    // arrays of arrays (oracle pr9).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)?;
                pin_vars(f, ie3, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, printed, n)?;
                walk(f, ie2, sigs, lit, pin, printed, n)?;
                walk(f, ie3, sigs, lit, pin, printed, n)
            }
            Expr::Index4(id, ie, ie2, ie3, ie4) => {
                if is_param(f, id).is_some() {
                    // Reading p[i][j][k][l] pins the parameter one level
                    // deeper (hk103).
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr4, pin, n)?;
                }
                pin_vars(f, ie, Ty::I64, pin, n)?;
                pin_vars(f, ie2, Ty::I64, pin, n)?;
                pin_vars(f, ie3, Ty::I64, pin, n)?;
                pin_vars(f, ie4, Ty::I64, pin, n)?;
                walk(f, ie, sigs, lit, pin, printed, n)?;
                walk(f, ie2, sigs, lit, pin, printed, n)?;
                walk(f, ie3, sigs, lit, pin, printed, n)?;
                walk(f, ie4, sigs, lit, pin, printed, n)
            }
            Expr::DArrNew => Ok(()),
            Expr::SelfObj | Expr::SelfGet(_) => Ok(()),
            Expr::Send(o, _, args) => {
                walk(f, o, sigs, lit, pin, printed, n)?;
                for a in args { walk(f, a, sigs, lit, pin, printed, n)?; }
                Ok(())
            }
            _ => Ok(()),
        }
    }
    fn walk_stmts(f: &Func, stmts: &[Stmt], sigs: &[Sig], lit: &mut Vec<(String, Ty)>, pin: &mut Vec<Option<Ty>>, printed: &mut Vec<bool>, nil_ret: bool) -> Result<(), String> {
        for st in stmts {
            match st {
                Stmt::Local(n, name, e) => {
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                    match e {
                        Expr::Str(_) => lit.push((name.clone(), Ty::Str)),
                        Expr::Int(_) => lit.push((name.clone(), Ty::I64)),
                        Expr::Float(..) | Expr::FloatV(..) => lit.push((name.clone(), Ty::F64)),
                        _ => {}
                    }
                }
                Stmt::Assign(n, id, e) => {
                    // `x := NIL` pins a parameter to the tagged union.
                    if matches!(e, Expr::Nil) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::Dyn, pin, *n)?;
                    }
                    // `x := <float-typed>` pins a parameter F64 (63zd).
                    if f64_typed(e, lit, sigs, f, pin) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::F64, pin, *n)?;
                    }
                    // `x := <string>` pins a parameter Str (63ze; hk324 /
                    // passref.prg: a byref-received string parameter is
                    // assigned in the callee - the byref remap turns the
                    // pinned Str into RefStrOwn at codegen).
                    if str_typed(e, lit, sigs, f, pin) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::Str, pin, *n)?;
                    }
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::Print(n, es, _) => {
                    for e in es {
                        // A whole-variable print is Dyn evidence for a
                        // parameter (hk257/hk259): Harbour accepts a
                        // string, an integer, .T./.F. or NIL through a
                        // print-only parameter.
                        if let Expr::Var(v) = e {
                            if let Some(idx) = is_param(f, v) { printed[idx] = true; }
                        }
                        walk(f, e, sigs, lit, pin, printed, *n)?;
                    }
                }
                Stmt::Ret(n, Some(e)) => {
                    // Mixed return (a value here, bare `return` / `return
                    // nil` elsewhere): the value is tagged, so a returned
                    // parameter pins Dyn (probe n2).
                    if nil_ret { pin_vars(f, e, Ty::Dyn, pin, *n)?; }
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::Ret(_, None) => {}
                Stmt::If(n, c, a, b) => {
                    walk(f, c, sigs, lit, pin, printed, *n)?;
                    walk_stmts(f, a, sigs, lit, pin, printed, nil_ret)?;
                    walk_stmts(f, b, sigs, lit, pin, printed, nil_ret)?;
                }
                Stmt::While(n, c, body) => {
                    walk(f, c, sigs, lit, pin, printed, *n)?;
                    walk_stmts(f, body, sigs, lit, pin, printed, nil_ret)?;
                }
                Stmt::For(n, _, a, b, _, body) => {
                    // for bounds are i64 by construction (integer counters
                    // only): they pin a parameter used as a bound (t61).
                    pin_vars(f, a, Ty::I64, pin, *n)?;
                    pin_vars(f, b, Ty::I64, pin, *n)?;
                    walk(f, a, sigs, lit, pin, printed, *n)?; walk(f, b, sigs, lit, pin, printed, *n)?;
                    walk_stmts(f, body, sigs, lit, pin, printed, nil_ret)?;
                }
                Stmt::ForEach(n, _, c, body) => {
                    walk(f, c, sigs, lit, pin, printed, *n)?;
                    walk_stmts(f, body, sigs, lit, pin, printed, nil_ret)?;
                }
                Stmt::ArrSet(n, id, ie, e) => {
                    // p["key"] := v: a string key pins a hash parameter
                    // (oracle hk11); p[i] := "x": a string value pins an
                    // array of strings; a scalar value pins a flat dynamic
                    // array (a borrowed middle array writes scalars this
                    // way - oracle hk86).
                    if str_evidence(ie, lit, sigs) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                    } else if str_evidence(e, lit, sigs) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArrS, pin, *n)?;
                    } else if is_param(f, id).is_some() {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, *n)?;
                    }
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, printed, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::HDel(n, id, e) => {
                    // hb_HDel's target is a hash (hk155): pins a
                    // parameter; the key's string shape is enforced by
                    // the semantic pass.
                    pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::HDelAt(n, id, e) => {
                    // hb_HDelAt's target is a hash (hk187): pins a
                    // parameter; the position's integer shape is
                    // enforced by the semantic pass.
                    pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::HClear(n, id) => {
                    // hb_HClear's target is a hash (hk191): pins a
                    // parameter.
                    pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                }
                Stmt::HFill(n, id, e) => {
                    // hb_HFill's target is a hash (hk192): pins a
                    // parameter; the value shape is enforced by the
                    // semantic pass.
                    pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::HSetCaseMatch(n, id, e) => {
                    // hb_HSetCaseMatch's target is a hash (hk169): pins
                    // a parameter; the flag's integer shape is enforced
                    // by the semantic pass.
                    pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::HSet(n, id, ke, ve) => {
                    // hb_HSet's target is a hash (hk159): pins a
                    // parameter; key and value shapes are enforced by
                    // the semantic pass.
                    pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                    walk(f, ke, sigs, lit, pin, printed, *n)?;
                    walk(f, ve, sigs, lit, pin, printed, *n)?;
                }
                Stmt::HMerge(n, id, s) => {
                    // hb_HMerge's target AND source are hashes (hk164):
                    // both pin parameters; the semantic pass enforces
                    // the shapes.
                    pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                    pin_vars(f, &Expr::Var(s.clone()), Ty::Hash, pin, *n)?;
                }
                Stmt::HCopy(n, id, s2, se, ce) => {
                    // hb_HCopy's source AND target are hashes (hk195):
                    // both pin parameters; start/count pin as integers.
                    pin_vars(f, &Expr::Var(id.clone()), Ty::Hash, pin, *n)?;
                    pin_vars(f, &Expr::Var(s2.clone()), Ty::Hash, pin, *n)?;
                    if let Some(e) = se { walk(f, e, sigs, lit, pin, printed, *n)?; }
                    if let Some(e) = ce { walk(f, e, sigs, lit, pin, printed, *n)?; }
                }
                Stmt::AAdd(n, id, e) => {
                    // AAdd's target is a dynamic array: pins a parameter.
                    // A string element pins an array of strings (the
                    // hb_HKeys shape); an ARRAY literal element pins one
                    // level deeper (a borrowed middle of a three-level
                    // array grows this way - oracle hk94); anything else
                    // keeps the flat pin.
                    if str_evidence(e, lit, sigs) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArrS, pin, *n)?;
                    } else if matches!(e, Expr::ArrLit(es) if es.iter().any(|x| matches!(x, Expr::ArrLit(_) | Expr::DArrNew))) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, *n)?;
                    } else if matches!(e, Expr::ArrLit(_)) {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, *n)?;
                    } else {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, *n)?;
                        pin_vars(f, e, Ty::I64, pin, *n)?;
                    }
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::ASize(n, id, e) => {
                    pin_vars(f, &Expr::Var(id.clone()), Ty::DArr, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::AAddSub(n, id, ie, e) | Stmt::ASizeSub(n, id, ie, e) => {
                    if is_param(f, id).is_some() {
                        // AAdd/ASize on p[i] pins the parameter to an array
                        // of arrays; the callee owns the moved value.
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, *n)?;
                    }
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, printed, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::ArrSet2(n, id, ie, ie2, e) => {
                    if is_param(f, id).is_some() {
                        // Writing p[i][j] pins the parameter to an array of
                        // arrays; the callee owns the moved value, so the
                        // caller cannot observe this write (see the
                        // registered sharing difference, probes pr2/pr5).
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr2, pin, *n)?;
                    }
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, ie2, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, printed, *n)?;
                    walk(f, ie2, sigs, lit, pin, printed, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::SelfSet(n, _, e) | Stmt::SendStmt(n, e) | Stmt::CallStmt(n, e) => {
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::SendSet(n, o, _, e) => {
                    walk(f, o, sigs, lit, pin, printed, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::AAddSub3(n, id, ie, ie2, ie3, e) | Stmt::ASizeSub3(n, id, ie, ie2, ie3, e) => {
                    if is_param(f, id).is_some() {
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr4, pin, *n)?;
                    }
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, ie2, Ty::I64, pin, *n)?;
                    pin_vars(f, ie3, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, printed, *n)?;
                    walk(f, ie2, sigs, lit, pin, printed, *n)?;
                    walk(f, ie3, sigs, lit, pin, printed, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::AAddSub2(n, id, ie, ie2, e) | Stmt::ASizeSub2(n, id, ie, ie2, e) => {
                    if is_param(f, id).is_some() {
                        // AAdd/ASize on p[i][j] pins the parameter to an
                        // array of arrays of arrays; the callee owns the
                        // moved value.
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, *n)?;
                    }
                    // AAdd/ASize on a[i][j]: indices and value pin i64
                    // (oracle pr8: indices first, then the value).
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, ie2, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, printed, *n)?;
                    walk(f, ie2, sigs, lit, pin, printed, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::ArrSet3(n, id, ie, ie2, ie3, e) => {
                    if is_param(f, id).is_some() {
                        // Writing p[i][j][k] pins the parameter to an array
                        // of arrays of arrays; the callee owns the moved
                        // value, so the caller cannot observe this write
                        // (registered sharing difference, oracle pr9).
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr3, pin, *n)?;
                    }
                    // a[i][j][k] := v: indices and value pin i64 (oracle
                    // pr6). Three-level parameters stay rejected, so no
                    // parameter pinning here.
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, ie2, Ty::I64, pin, *n)?;
                    pin_vars(f, ie3, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, printed, *n)?;
                    walk(f, ie2, sigs, lit, pin, printed, *n)?;
                    walk(f, ie3, sigs, lit, pin, printed, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::ArrSet4(n, id, ie, ie2, ie3, ie4, e) => {
                    if is_param(f, id).is_some() {
                        // Writing p[i][j][k][l] pins the parameter to an array
                        // of arrays of arrays; the callee owns the moved
                        // value, so the caller cannot observe this write
                        // (registered sharing difference, oracle pr9).
                        pin_vars(f, &Expr::Var(id.clone()), Ty::DArr4, pin, *n)?;
                    }
                    // a[i][j][k] := v: indices and value pin i64 (oracle
                    // pr6). Three-level parameters stay rejected, so no
                    // parameter pinning here.
                    pin_vars(f, ie, Ty::I64, pin, *n)?;
                    pin_vars(f, ie2, Ty::I64, pin, *n)?;
                    pin_vars(f, ie3, Ty::I64, pin, *n)?;
                    pin_vars(f, ie4, Ty::I64, pin, *n)?;
                    pin_vars(f, e, Ty::I64, pin, *n)?;
                    walk(f, ie, sigs, lit, pin, printed, *n)?;
                    walk(f, ie2, sigs, lit, pin, printed, *n)?;
                    walk(f, ie3, sigs, lit, pin, printed, *n)?;
                    walk(f, ie4, sigs, lit, pin, printed, *n)?;
                    walk(f, e, sigs, lit, pin, printed, *n)?;
                }
                Stmt::Exit(_) | Stmt::Loop(_) => {}
            }
        }
        Ok(())
    }
    fn any_nil_ret(stmts: &[Stmt]) -> bool {
        stmts.iter().any(|s| match s {
            Stmt::Ret(_, None) => true,
            Stmt::If(_, _, a, b) => any_nil_ret(a) || any_nil_ret(b),
            Stmt::While(_, _, b) | Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => any_nil_ret(b),
            _ => false,
        })
    }
    let nil_ret = any_nil_ret(&f.stmts);
    walk_stmts(f, &f.stmts, sigs, &mut lit, &mut pin, &mut printed, nil_ret)?;
    // Report the first uninferable parameter, but return the partial pins:
    // one uninferable parameter must not mask the evidence of the others
    // (an i64 placeholder for a string parameter turned a later
    // `param == "literal"` into the Dyn/integer `==` named rejection,
    // hiding the real problem - probes v2/v3 in the 63k notes).
    let mut pin_err = None;
    // Float arguments observed at call sites (63zd, oracles hk303/hk306:
    // Harbour passes the same numeric parameter integers in one call and
    // floats in another; the integer converts at the boundary). Merged
    // with the body's own evidence: I64 body + float argument -> F64; a
    // body Dyn stays Dyn (the float call site is then the registered
    // Dyn-payload covered limit); any other body type conflicts by name.
    let self_ev: Vec<Option<Ty>> = sigs.iter().find(|s| s.name == f.name)
        .map(|s| s.arg_ev.clone())
        .unwrap_or_else(|| vec![None; n]);
    let nil_ev: Vec<bool> = sigs.iter().find(|s| s.name == f.name)
        .map(|s| s.nil_ev.clone())
        .unwrap_or_else(|| vec![false; n]);
    for (i, p) in f.params.iter().enumerate() {
        match (pin[i], self_ev[i]) {
            (Some(Ty::I64), Some(Ty::F64)) => pin[i] = Some(Ty::F64),
            (Some(Ty::Dyn), _) | (_, None) => {}
            (Some(t), Some(Ty::F64)) if t != Ty::F64 => {
                if pin_err.is_none() {
                    pin_err = Some(format!("parameter `{}` of function `{}` is {} by its body but receives a float argument", p, f.name, ty_name(t)));
                }
            }
            (Some(a), Some(b)) if a == b => {}
            // An integer argument to a float parameter converts at the
            // boundary (63zd; oracles hk302/hk303/hk307).
            (Some(Ty::F64), Some(Ty::I64)) => {}
            // Borrowed vs owned string is one family at this boundary.
            (Some(Ty::StrOwn), Some(Ty::Str)) | (Some(Ty::Str), Some(Ty::StrOwn)) => {}
            // Varying argument types across call sites merge to the tagged
            // union in the evidence itself; the body's scalar pin absorbs
            // into it (Harbour retypes the parameter per call).
            (Some(t), Some(Ty::Dyn)) if matches!(t, Ty::I64 | Ty::Bool | Ty::Str | Ty::StrOwn | Ty::F64) => {
                pin[i] = Some(Ty::Dyn);
            }
            (Some(t), Some(e)) => {
                if pin_err.is_none() {
                    pin_err = Some(format!("parameter `{}` of function `{}` is {} by its body but a call passes {}", p, f.name, ty_name(t), ty_name(e)));
                }
            }
            _ => {}
        }
        // Print as the sole non-copy evidence pins the tagged union
        // (oracles hk257/hk259). This runs AFTER the walk so pinning
        // evidence (arithmetic, concatenation, known-type compare) wins
        // order-independently (hk260/hk261). Print-only still wins over
        // a float argument: Dyn has no float payload (covered limit at
        // the call site).
        if pin[i].is_none() && printed[i] {
            pin[i] = Some(Ty::Dyn);
        }
        // A float argument as the SOLE evidence pins F64.
        if pin[i].is_none() {
            pin[i] = self_ev[i];
        }
        // Omitted trailing arguments (multiarg): Harbour fills them with
        // NIL, so the parameter must carry NIL - the tagged union absorbs
        // any scalar pin. A float, array, hash or codeblock pin conflicts
        // with the NIL fill by name: Dyn has no such payload in this
        // increment (the float-payload representation decision is pending).
        if nil_ev.get(i).copied().unwrap_or(false) {
            pin[i] = match pin[i] {
                None | Some(Ty::Dyn) => Some(Ty::Dyn),
                Some(Ty::I64) | Some(Ty::Bool) | Some(Ty::Str) | Some(Ty::StrOwn) => Some(Ty::Dyn),
                Some(t) => {
                    if pin_err.is_none() {
                        pin_err = Some(format!("parameter `{}` of function `{}` is {} by its body but a call site omits it; Harbour fills it with NIL and this increment's Dyn casilla cannot carry {}", p, f.name, ty_name(t), ty_name(t)));
                    }
                    pin[i]
                }
            };
        }
        if pin[i].is_none() && pin_err.is_none() {
            pin_err = Some(format!("cannot infer the type of parameter `{}` of function `{}` (returning or copying it is not enough; print it, use it in arithmetic, or compare it against a value of known type)", p, f.name));
        }
    }
    Ok((pin, pin_err))
}

// Does expression `e` mention variable `name` anywhere (including index
// positions)? Used by the borrowed-argument aliasing check.
fn expr_has_call(e: &Expr) -> bool {
    // Any function call in the expression. The move-LHS grow guard excludes
    // these wholesale: a callee's effects on the destination through shapes
    // we have not probed (nested @ pass-on chains, future globals) are not
    // reconciled, so only call-free RHS forms are justified for in-place
    // growth (main's rule: reject or exclude unjustified forms).
    match e {
        Expr::Seq(_) => true, // effectful form excluded from in-place growth
        Expr::Call(_, _) => true,
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => expr_has_call(a) || expr_has_call(b),
        Expr::Var(_) | Expr::Str(_) | Expr::Int(_) | Expr::Log(_) => false,
        Expr::LNot(a) | Expr::Index(_, a) => expr_has_call(a),
        Expr::IdxCompound(_, a, _, b) => expr_has_call(a) || expr_has_call(b),
        Expr::LAnd(a, b) | Expr::LOr(a, b) => expr_has_call(a) || expr_has_call(b),
        _ => true, // any other shape: not justified - exclude
    }
}

fn expr_mentions(e: &Expr, name: &str) -> bool {
    match e {
        Expr::Seq(es) => es.iter().any(|e| expr_mentions(e, name)),
        Expr::Var(v) | Expr::Inc(v, _, _) => v == name,
        Expr::ByRef(v) => v == name,
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) | Expr::LAnd(a, b) | Expr::LOr(a, b) => expr_mentions(a, name) || expr_mentions(b, name),
        Expr::LNot(a) => expr_mentions(a, name),
        Expr::Call(_, args) => args.iter().any(|a| expr_mentions(a, name)),
        Expr::Index(id, i) => id == name || expr_mentions(i, name),
        Expr::IdxCompound(id, i, _, r) => id == name || expr_mentions(i, name) || expr_mentions(r, name),
        Expr::Index2(id, i, j) => id == name || expr_mentions(i, name) || expr_mentions(j, name),
        Expr::Index3(id, i, j, k) => id == name || expr_mentions(i, name) || expr_mentions(j, name) || expr_mentions(k, name),
        Expr::Index4(id, i, j, k, l) => id == name || expr_mentions(i, name) || expr_mentions(j, name) || expr_mentions(k, name) || expr_mentions(l, name),
        Expr::ArrLit(es) => es.iter().any(|e| expr_mentions(e, name)),
        _ => false,
    }
}

// Borrowed-parameter escape post-pass (iteration 33i). A parameter that
// some call site feeds as `a[i]` is BORROWED: the callee holds the child
// cell's address only for the duration of the call. It may be read
// (len(p), p[i], printing), written (p[i] := v) and resized (AAdd/ASize)
// in place - everything Harbour shows through its sharing (oracles
// hk73/hk78/hk86/hk87) - but it must NOT escape or be aliased: returning
// it, reassigning it, declaring over it, iterating it with FOR EACH
// (deferred) or passing it on to another function would outlive or
// duplicate the borrow. The body already type-checked under the owned
// shape (same allowed operations); this pass rejects the rest by
// whitelist.
fn borrow_expr_ok(e: &Expr, pname: &str) -> bool {
    match e {
        Expr::Seq(es) => es.iter().all(|e| borrow_expr_ok(e, pname)),
        // a[i] op= e on a local fixed array: no borrow escapes through an
        // i64 cell; the index and right side must still be borrow-clean.
        Expr::IdxCompound(_, ie, _, re) => borrow_expr_ok(ie, pname) && borrow_expr_ok(re, pname),
        Expr::Var(v) => v != pname,
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => borrow_expr_ok(a, pname) && borrow_expr_ok(b, pname),
        Expr::Call(id, args) => {
            if is_builtin(id, "len") && args.len() == 1 && matches!(&args[0], Expr::Var(v) if v == pname) {
                return true; // len(p) borrows for the length only
            }
            if is_builtin(id, "valtype") && args.len() == 1 && matches!(&args[0], Expr::Var(v) if v == pname) {
                return true; // ValType(p) reads the tag only (hk88)
            }
            args.iter().all(|a| borrow_expr_ok(a, pname))
        }
        Expr::Index(_, ie) => borrow_expr_ok(ie, pname), // p[i] read: the base is the borrow itself
        Expr::Index2(_, a, b) => borrow_expr_ok(a, pname) && borrow_expr_ok(b, pname),
        Expr::Index3(_, a, b, c) => borrow_expr_ok(a, pname) && borrow_expr_ok(b, pname) && borrow_expr_ok(c, pname),
        Expr::Index4(_, a, b, c, d) => borrow_expr_ok(a, pname) && borrow_expr_ok(b, pname) && borrow_expr_ok(c, pname) && borrow_expr_ok(d, pname),
        Expr::ArrLit(es) => es.iter().all(|e| borrow_expr_ok(e, pname)),
        _ => true,
    }
}

fn borrow_stmts_ok(stmts: &[Stmt], pname: &str) -> Option<usize> {
    for s in stmts {
        let bad = match s {
            Stmt::Local(n, id, e) => {
                if id == pname || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::Print(n, items, _) => {
                let ok = items.iter().all(|i| matches!(i, Expr::Var(v) if v == pname) || borrow_expr_ok(i, pname));
                if ok { None } else { Some(*n) }
            }
            Stmt::Ret(n, Some(e)) => if borrow_expr_ok(e, pname) { None } else { Some(*n) },
            Stmt::Assign(n, id, e) => {
                if id == pname || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::ArrSet(n, id, ie, e) => {
                // p[i] := v writes THROUGH the borrow: allowed.
                if !borrow_expr_ok(ie, pname) || !borrow_expr_ok(e, pname) || (id == pname && false) { Some(*n) } else { None }
            }
            Stmt::ArrSet2(n, id, a, b, e) | Stmt::ArrSet3(n, id, a, b, e, ..) => {
                let _ = id;
                if !borrow_expr_ok(a, pname) || !borrow_expr_ok(b, pname) || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::ArrSet4(n, id, a, b, c, d, e) => {
                let _ = id;
                if !borrow_expr_ok(a, pname) || !borrow_expr_ok(b, pname) || !borrow_expr_ok(c, pname) || !borrow_expr_ok(d, pname) || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::SelfSet(_, _, e) | Stmt::SendStmt(_, e) | Stmt::CallStmt(_, e) => if borrow_expr_ok(e, pname) { None } else { Some(0) },
            Stmt::SendSet(n, r, _, e) => {
                if !borrow_expr_ok(r, pname) || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::AAdd(_, _, e) | Stmt::ASize(_, _, e) | Stmt::AAddSub(_, _, _, e) | Stmt::ASizeSub(_, _, _, e) => {
                if borrow_expr_ok(e, pname) { None } else { Some(0) }
            }
            Stmt::AAddSub3(n, _, a, b, c, e) | Stmt::ASizeSub3(n, _, a, b, c, e) => {
                if !borrow_expr_ok(a, pname) || !borrow_expr_ok(b, pname) || !borrow_expr_ok(c, pname) || !borrow_expr_ok(e, pname) { Some(*n) } else { None }
            }
            Stmt::AAddSub2(_, _, a, b, e) | Stmt::ASizeSub2(_, _, a, b, e) => {
                if borrow_expr_ok(a, pname) && borrow_expr_ok(b, pname) && borrow_expr_ok(e, pname) { None } else { Some(0) }
            }
            Stmt::If(n, c, a, b) => {
                if !borrow_expr_ok(c, pname) { Some(*n) }
                else if let Some(m) = borrow_stmts_ok(a, pname) { Some(m) }
                else { borrow_stmts_ok(b, pname) }
            }
            Stmt::While(n, c, b) => {
                if !borrow_expr_ok(c, pname) { Some(*n) } else { borrow_stmts_ok(b, pname) }
            }
            Stmt::For(n, lv, a, b, _, body) => {
                if lv == pname || !borrow_expr_ok(a, pname) || !borrow_expr_ok(b, pname) { Some(*n) }
                else { borrow_stmts_ok(body, pname) }
            }
            Stmt::ForEach(n, lv, coll, body) => {
                // FOR EACH over (or into) a borrowed parameter: deferred.
                if lv == pname || !borrow_expr_ok(coll, pname) { Some(*n) }
                else { borrow_stmts_ok(body, pname) }
            }
            _ => None,
        };
        if let Some(m) = bad {
            return Some(if m == 0 { 1 } else { m });
        }
    }
    None
}

fn type_expr(e: &Expr, env: &mut [Local], sigs: &mut Vec<Sig>, n: usize) -> Result<Ty, String> {
    match e {
        Expr::Seq(es) => {
            let mut local = env.to_vec();
            let mut last = Ty::I64;
            for e in es {
                let t = type_expr(e, &mut local, sigs, n)?;
                // Only direct output calls add a payload-free NIL result.
                // Generic Dyn variables/calls retain the ownership limit.
                let nil_output = matches!(e, Expr::Call(id, _) if is_output_call(id));
                if !matches!(t, Ty::I64 | Ty::Bool | Ty::F64) && !nil_output {
                    return Err(format!("line {}: parenthesized comma expressions support numeric/logical results only in this increment; owned, Dyn, array and block results remain a named limit", n));
                }
                apply_moves(e, &mut local, sigs, false);
                last = t;
            }
            // Effects inside the list also precede sibling expressions.
            // Keep the caller's ownership state, not only the list-local
            // checks, so `(consume(s),1) + Len(s)` cannot read freed memory.
            for (outer, inner) in env.iter_mut().zip(local.iter()) {
                outer.moved |= inner.moved;
            }
            Ok(last)
        }
        Expr::Int(_) => Ok(Ty::I64),
        Expr::Float(..) | Expr::FloatV(..) => Ok(Ty::F64),
        Expr::Str(_) => Ok(Ty::Str),
        Expr::Inc(id, _, _) => {
            let v = env.iter().find(|v| v.name == *id)
                .ok_or_else(|| format!("line {}: undefined variable `{}`", n, id))?;
            if v.moved { return Err(format!("line {}: use of moved value `{}`", n, id)); }
            if v.ro { return Err(format!("line {}: expression ++/-- cannot modify read-only variable `{}`", n, id)); }
            if v.ty != Ty::I64 {
                return Err(format!("line {}: expression ++/-- supports integer variable lvalues only; floats, Dyn and other lvalues remain a named limit", n));
            }
            Ok(Ty::I64)
        }
        Expr::Var(id) => match env.iter().find(|v| v.name == *id) {
            None => Err(format!("line {}: undefined variable `{}`", n, id)),
            Some(v) if v.moved => Err(format!(
                "line {}: use of moved value `{}` (heap values - strings and dynamic arrays - move on assignment, call or return; they do not copy)", n, id)),
            Some(v) => Ok(v.ty),
        },
        Expr::Call(id, args) => {
            if is_bitindex(id) {
                if args.len() != 2 { return Err(format!("line {}: `{}` takes two arguments in this increment",n,id)); }
                if type_expr(&args[0],env,sigs,n)? != Ty::I64 {
                    return Err(format!("line {}: `{}` value must be an integer in this increment",n,id));
                }
                match &args[1] {
                    Expr::Int(v) if v.parse::<u32>().ok().map_or(false, |v| v < 64) => {}
                    _ => return Err(format!("line {}: `{}` bit index must be a literal from 0 to 63; dynamic/out-of-range semantics are not in this increment",n,id)),
                }
                return Ok(if is_builtin(id,"hb_bittest") {Ty::Bool} else {Ty::I64});
            }
            if is_bitop(id) {
                let unary = is_builtin(id, "hb_bitnot");
                if (unary && args.len() != 1) || (!unary && args.len() < 2) {
                    return Err(format!("line {}: `{}` needs {} argument(s) in this increment", n,id, if unary {"exactly one"} else {"at least two"}));
                }
                for a in args {
                    if type_expr(a, env, sigs, n)? != Ty::I64 {
                        return Err(format!("line {}: `{}` arguments must be integers in this increment; float/Dyn conversions are not covered", n,id));
                    }
                    apply_moves(a,env,sigs,false);
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "min") || is_builtin(id, "max") {
                if args.len() != 2 { return Err(format!("line {}: `{}` takes two arguments in this increment", n, id)); }
                let a = type_expr(&args[0], env, sigs, n)?;
                apply_moves(&args[0], env, sigs, false);
                let b = type_expr(&args[1], env, sigs, n)?;
                if a != b || !matches!(a, Ty::I64 | Ty::F64 | Ty::Bool) {
                    return Err(format!("line {}: `{}` needs matching integer, float or logical arguments; mixed numeric/Dyn/other types are not in this increment", n, id));
                }
                return Ok(a);
            }
            if is_builtin(id, "empty") {
                if args.len() != 1 { return Err(format!("line {}: `Empty` takes one argument in this increment", n)); }
                let t = type_expr(&args[0], env, sigs, n)?;
                let arr = matches!(t, Ty::Arr(_) | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Hash);
                if arr && !matches!(&args[0], Expr::Var(_)) {
                    return Err(format!("line {}: `Empty` on an array/hash needs a variable in this increment", n));
                }
                if t == Ty::Dyn && !matches!(&args[0], Expr::Nil) {
                    return Err(format!("line {}: `Empty` on generic Dyn values is not in this increment", n));
                }
                if matches!(t, Ty::DArrRef | Ty::DArrRef2) {
                    return Err(format!("line {}: `Empty` on borrowed nested arrays is not in this increment", n));
                }
                return Ok(Ty::Bool);
            }
            if is_builtin(id, "procname") {
                if args.len() > 1 || (args.len() == 1 && !matches!(&args[0], Expr::Int(v) if v == "0")) {
                    return Err(format!("line {}: `ProcName` supports only no argument or literal zero (current frame); ancestor/dynamic levels are not in this increment", n));
                }
                return Ok(Ty::Str);
            }
            if is_builtin(id, "hb_eol") {
                if !args.is_empty() { return Err(format!("line {}: `hb_eol` takes no arguments in this increment", n)); }
                return Ok(Ty::Str);
            }
            if is_builtin(id, "procline") {
                if args.len() > 1 || (args.len() == 1 && !matches!(&args[0], Expr::Int(v) if v == "0")) {
                    return Err(format!("line {}: `ProcLine` supports only no argument or literal zero (current frame); ancestor/dynamic levels are not in this increment", n));
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "hb_memcheck") {
                // alloc/free balance counters (test harness only).
                if !args.is_empty() {
                    return Err(format!("line {}: `hb_memcheck` takes no arguments", n));
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "array") {
                // Array(n[, m[, k]]) constructor (oracles m3/m10/a0/avar/pr7).
                // Harbour accepts more dimensions and answers Array() /
                // Array(-1) with dialogs that hang headless (BASE/1111,
                // BASE/1131): arity errors are compile errors here and a
                // negative dimension is a clean runtime error - registered
                // failure modes, same error conditions.
                if args.is_empty() {
                    return Err(format!("line {}: `Array` needs at least one dimension", n));
                }
                if args.len() > 4 {
                    return Err(format!("line {}: `Array` with more than four dimensions is not in this increment", n));
                }
                for a in args {
                    if !matches!(type_expr(a, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                        return Err(format!("line {}: `Array` dimensions are integers", n));
                    }
                }
                return Ok(match args.len() { 1 => Ty::DArr, 2 => Ty::DArr2, 3 => Ty::DArr3, _ => Ty::DArr4 });
            }
            if is_builtin(id, "valtype") {
                // ValType(x): a one-character type tag (hk88-hk92). Borrows
                // its argument; the argument evaluates fully with its
                // effects (hk89). Only measured shapes: literals, plain
                // variables, and one/two-level casillas of measured roots.
                // Deeper indexing and other expressions are named
                // rejections - unmeasured, never inferred across depths.
                if args.len() != 1 {
                    return Err(format!("line {}: `ValType` takes one argument", n));
                }
                match &args[0] {
                    Expr::Int(_) | Expr::Str(_) | Expr::Nil | Expr::Var(_) => {}
                    Expr::Call(id, _) if is_output_call(id) => {}
                    Expr::Index(v, _) => {
                        // DArr4 first level: child-array casilla -
                        // "A" (hk114, byte-measured via hk117 markers).
                        match env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()) {
                            Some(Ty::DArr) | Some(Ty::DArr2) | Some(Ty::DArrRef) | Some(Ty::DArrS) | Some(Ty::DArr4) | Some(Ty::Hash) => {}
                            _ => return Err(format!("line {}: `ValType` over this array depth is not measured in this PoC", n)),
                        }
                    }
                    Expr::Index2(v, _, _) => {
                        // DArr4 second level: child-array casilla - "A"
                        // (hk114); a NIL middle is the registered clean
                        // bound-error failure mode.
                        match env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()) {
                            Some(Ty::DArr2) | Some(Ty::DArr4) => {}
                            _ => return Err(format!("line {}: `ValType` over this array depth is not measured in this PoC", n)),
                        }
                    }
                    Expr::Index3(v, ..) | Expr::Index4(v, ..) => {
                        // hk103: ValType(a[i][j][k]) = "A" (child-array
                        // casilla) and ValType(a[i][j][k][l]) = "U" (NIL
                        // scalar casilla) on a four-level root.
                        match env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()) {
                            Some(Ty::DArr4) => {}
                            _ => return Err(format!("line {}: `ValType` over this array depth is not measured in this PoC", n)),
                        }
                    }
                    _ => return Err(format!("line {}: `ValType` over this expression is not measured in this PoC", n)),
                }
                match &args[0] {
                    // a[i] on a DArr2 is a child-array casilla: ValType
                    // reads its pointer only (hk90/hk91), never extracts
                    // the subarray by value - so the generic Index typing
                    // (which rejects that extraction) is bypassed here;
                    // the index expression still must type as an integer.
                    Expr::Index(v, ie) if matches!(env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()), Some(Ty::DArr2)) => {
                        match type_expr(ie, env, sigs, n)? {
                            Ty::I64 | Ty::Dyn => {}
                            _ => return Err(format!("line {}: array index must be an integer", n)),
                        }
                    }
                    Expr::Index(v, ie) if matches!(env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()), Some(Ty::DArr4)) => {
                        // hk114: the first-level casilla of a four-level
                        // root classifies as the EMPTY string by pointer
                        // shape, never extracted - bypass the generic
                        // Index typing (which rejects that extraction).
                        match type_expr(ie, env, sigs, n)? {
                            Ty::I64 | Ty::Dyn => {}
                            _ => return Err(format!("line {}: array index must be an integer", n)),
                        }
                    }
                    Expr::Index2(v, ie, ie2) if matches!(env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()), Some(Ty::DArr4)) => {
                        // Second-level casilla is a child-array {ptr,
                        // len}, classified by pointer (hk114) - bypass
                        // the generic Index2 typing (which rejects the
                        // extraction).
                        for ie in [ie, ie2] {
                            match type_expr(ie, env, sigs, n)? {
                                Ty::I64 | Ty::Dyn => {}
                                _ => return Err(format!("line {}: array index must be an integer", n)),
                            }
                        }
                    }
                    Expr::Index3(v, ie, ie2, ie3) if matches!(env.iter().rev().find(|x| x.name == *v).map(|x| x.ty.clone()), Some(Ty::DArr4)) => {
                        // The child-array casilla is classified by pointer,
                        // never extracted - bypass the generic Index3
                        // typing (which rejects that extraction).
                        for ie in [ie, ie2, ie3] {
                            match type_expr(ie, env, sigs, n)? {
                                Ty::I64 | Ty::Dyn => {}
                                _ => return Err(format!("line {}: array index must be an integer", n)),
                            }
                        }
                    }
                    e => match type_expr(e, env, sigs, n)? {
                        Ty::I64 | Ty::Str | Ty::StrOwn | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::DArrRef | Ty::Arr(_) | Ty::Dyn | Ty::Bool => {}
                        _ => return Err(format!("line {}: `ValType` is not measured for this type in this PoC", n)),
                    },
                }
                return Ok(Ty::Str);
            }
            if is_builtin(id, "len") {
                // len(a): number of elements of an array (probe e4:
                // len({}) == 0). Borrows its argument.
                if args.len() != 1 {
                    return Err(format!("line {}: `len` takes one argument", n));
                }
                match &args[0] {
                    Expr::Index(id, ie) => {
                        // len(a[i]): the subarray length, a borrow (probe m6).
                        if type_expr(ie, env, sigs, n)? != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        return match env.iter().find(|v| v.name == *id) {
                            Some(v) if (v.ty == Ty::DArr2 || v.ty == Ty::DArr3 || v.ty == Ty::DArr4) && !v.moved => Ok(Ty::I64),
                            Some(v) if v.ty == Ty::DArr2 || v.ty == Ty::DArr3 || v.ty == Ty::DArr4 => Err(format!("line {}: use of moved value `{}`", n, id)),
                            _ => Err(format!("line {}: `len` of a[i] needs an array of arrays", n)),
                        };
                    }
                    Expr::Index3(id, ie, ie2, ie3) => {
                        // len(a[i][j][k]) on a four-level array: borrow
                        // three levels (hk103).
                        if type_expr(ie, env, sigs, n)? != Ty::I64 || type_expr(ie2, env, sigs, n)? != Ty::I64 || type_expr(ie3, env, sigs, n)? != Ty::I64 {
                            return Err(format!("line {}: array indices must be integers", n));
                        }
                        return match env.iter().find(|v| v.name == *id) {
                            Some(v) if v.ty == Ty::DArr4 && !v.moved => Ok(Ty::I64),
                            Some(v) if v.ty == Ty::DArr4 => Err(format!("line {}: use of moved value `{}`", n, id)),
                            _ => Err(format!("line {}: `len` of a[i][j][k] needs an array of arrays of arrays of arrays", n)),
                        };
                    }
                    Expr::Index2(id, ie, ie2) => {
                        // len(a[i][j]): borrow two levels (oracle pr4).
                        if type_expr(ie, env, sigs, n)? != Ty::I64 || type_expr(ie2, env, sigs, n)? != Ty::I64 {
                            return Err(format!("line {}: array indices must be integers", n));
                        }
                        return match env.iter().find(|v| v.name == *id) {
                            Some(v) if (v.ty == Ty::DArr3 || v.ty == Ty::DArr4) && !v.moved => Ok(Ty::I64),
                            Some(v) if v.ty == Ty::DArr3 || v.ty == Ty::DArr4 => Err(format!("line {}: use of moved value `{}`", n, id)),
                            _ => Err(format!("line {}: `len` of a[i][j] needs an array of arrays of arrays", n)),
                        };
                    }
                    _ => {}
                }
                return match type_expr(&args[0], env, sigs, n)? {
                    Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Arr(_) | Ty::Hash => {
                        // Only variables: an array TEMPORARY in expression
                        // position has no free point in this increment
                        // (the FOR EACH temp machinery does not apply
                        // here). Reachable since 33m via static returns;
                        // it also existed for dynamic ones - named
                        // rejection instead of the cg unreachable.
                        if !matches!(&args[0], Expr::Var(_)) {
                            return Err(format!("line {}: `len` of an array temporary is not in this increment (assign it to a variable first)", n));
                        }
                        Ok(Ty::I64)
                    }
                    // len() of a string is its byte count (oracle hk217:
                    // "abcde" -> 5, "" -> 0). A string PARAMETER under
                    // len() still pins an array (the registered pin rule
                    // predates string len and Harbour's len is
                    // polymorphic) - named limitation, not silent.
                    Ty::Str | Ty::StrOwn => Ok(Ty::I64),
                    _ => return Err(format!("line {}: `len` expects an array", n)),
                };
            }
            if is_builtin(id, "hb_hkeys") {
                // hb_HKeys(h): NEW array of owned key strings in insertion
                // order (oracles hk4/hk5/hk6, core hb_HKeys). The hash is
                // borrowed; the result is a DArrS the caller owns.
                if args.len() != 1 {
                    return Err(format!("line {}: `hb_HKeys` takes exactly one argument", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HKeys` expects a hash variable (its slot is passed by address)", n));
                }
                return Ok(Ty::DArrS);
            }
            if is_builtin(id, "hb_hhaskey") {
                // hb_HHasKey(h, key): .T./.F. by a byte-exact,
                // case-sensitive key (oracle hk157, core hb_HHasKey).
                // The hash and the key are borrowed. The result is 1/0
                // (the dialect has no logical type - its `if` takes only
                // comparisons - so the PoC surface prints and compares
                // 1/0; the oracle's .T./.F. is the registered boolean
                // rendering family).
                if args.len() != 2 {
                    return Err(format!("line {}: `hb_HHasKey` takes exactly two arguments", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HHasKey` expects a hash variable (its slot is passed by address)", n));
                }
                if !matches!(type_expr(&args[1], env, sigs, n)?, Ty::Str | Ty::StrOwn) {
                    return Err(format!("line {}: hash keys are strings in this increment", n));
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "hb_hpos") {
                // hb_HPos(h, key): the entry's 1-based position among
                // the LIVE entries in insertion order, 0 when absent
                // (hk162: present keys answer 1..n, missing and ""
                // answer 0; hk163: positions COMPACT after a delete).
                // Hash and key borrowed.
                if args.len() != 2 {
                    return Err(format!("line {}: `hb_HPos` takes exactly two arguments", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HPos` expects a hash variable (its slot is passed by address)", n));
                }
                if !matches!(type_expr(&args[1], env, sigs, n)?, Ty::Str | Ty::StrOwn) {
                    return Err(format!("line {}: hash keys are strings in this increment", n));
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "hb_hkeyat") {
                // hb_HKeyAt(h, n): the key at the 1-based
                // insertion-order position n (hk184: bb/ccc by
                // position; positions COMPACT after a delete - hk186).
                // EVERY out-of-range position (0, past the end,
                // negative) is Harbour's BASE/1187 dialog, which hangs
                // headless (hk184, separate binaries): the registered
                // dialogo-sin-oraculo family - the PoC takes the clean
                // bound-error exit, never a compat success. Float
                // indices truncate in the oracle (hk186) and stay
                // outside this dialect's numeric syntax. Hash borrowed;
                // the returned key is an OWNED copy.
                if args.len() != 2 {
                    return Err(format!("line {}: `hb_HKeyAt` takes exactly two arguments", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HKeyAt` expects a hash variable (its slot is passed by address)", n));
                }
                if type_expr(&args[1], env, sigs, n)? != Ty::I64 {
                    return Err(format!("line {}: the hb_HKeyAt position is an integer in this increment", n));
                }
                return Ok(Ty::StrOwn);
            }
            if is_builtin(id, "hb_hvalueat") {
                // hb_HValueAt(h, n): the value casilla at the 1-based
                // insertion-order position n (hk185: 10/NIL/30 by
                // position; a stored NIL comes back as NIL). Same
                // out-of-range family as hb_HKeyAt (hk185: BASE/1187
                // dialog, clean bound-error exit here). Hash borrowed.
                if args.len() != 2 {
                    return Err(format!("line {}: `hb_HValueAt` takes exactly two arguments", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HValueAt` expects a hash variable (its slot is passed by address)", n));
                }
                if type_expr(&args[1], env, sigs, n)? != Ty::I64 {
                    return Err(format!("line {}: the hb_HValueAt position is an integer in this increment", n));
                }
                return Ok(Ty::Dyn);
            }
            if is_builtin(id, "hb_hscan") {
                // hb_HScan(h, value [, start]): the 1-based position in
                // insertion order of the first entry whose VALUE equals
                // the argument, 0 when absent (hk178-hk180). The scan
                // starts at `start` inclusive (hk178: hb_HScan(h,10,2)
                // skips the 10 at position 1 and answers 3); start
                // omitted/NIL/0 scans from the first entry, a negative
                // start or one past the last entry finds nothing
                // (hk179), and a float start truncates (hk183 - floats
                // stay outside this increment's syntax). Values are the
                // tagged int/NIL scalars of this increment: a stored NIL
                // matches a NIL argument (hk180); an int argument never
                // matches a stored NIL. Hash and value borrowed. A
                // missing value argument is Harbour's BASE/1123 dialog
                // (hk182): the registered dialogo-sin-oraculo family,
                // never a compat target.
                if args.len() != 2 && args.len() != 3 {
                    return Err(format!("line {}: `hb_HScan` takes two or three arguments", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HScan` expects a hash variable (its slot is passed by address)", n));
                }
                if !matches!(type_expr(&args[1], env, sigs, n)?, Ty::I64 | Ty::Bool | Ty::Dyn) {
                    return Err(format!("line {}: hash values are integers or NIL in this increment", n));
                }
                if args.len() == 3 && !matches!(&args[2], Expr::Nil) && type_expr(&args[2], env, sigs, n)? != Ty::I64 {
                    return Err(format!("line {}: the hb_HScan start is an integer in this increment (NIL scans from the first entry)", n));
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "hb_hcasematch") {
                // hb_HCaseMatch(h): the hash's CaseMatch flag (hk169:
                // default .T.; core hb_HCaseMatch). The hash is
                // borrowed. The result is 1/0 (the dialect has no
                // logical type; the oracle's .T./.F. is the registered
                // boolean rendering family).
                if args.len() != 1 {
                    return Err(format!("line {}: `hb_HCaseMatch` takes exactly one argument", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HCaseMatch` expects a hash variable (its slot is passed by address)", n));
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "hb_hget") {
                // hb_HGet(h, key [, default]): the value casilla of an
                // existing key (hk158a/e, with or without the default).
                // A MISSING key is the same BASE/1132 condition as an
                // h[k] read miss: Harbour shows its dialog and hangs
                // headless even WITH a default (hk158a/b/d), so the PoC
                // takes the registered clean bound-error exit - a
                // failure-mode registration, never a compat success. The
                // default IS evaluated - its effects fire on present,
                // NIL and even missing keys, before the error
                // (hk158f1/f2/f3) - but its value is discarded: it never
                // rescues a miss and never overrides an existing NIL
                // (hk158b/c). Hash and key borrowed.
                if args.len() != 2 && args.len() != 3 {
                    return Err(format!("line {}: `hb_HGet` takes two or three arguments", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HGet` expects a hash variable (its slot is passed by address)", n));
                }
                if !matches!(type_expr(&args[1], env, sigs, n)?, Ty::Str | Ty::StrOwn) {
                    return Err(format!("line {}: hash keys are strings in this increment", n));
                }
                if args.len() == 3 && type_expr(&args[2], env, sigs, n)? != Ty::I64 {
                    return Err(format!("line {}: the hb_HGet default is an integer in this increment", n));
                }
                return Ok(Ty::Dyn);
            }
            if is_builtin(id, "hb_hgetdef") {
                // hb_HGetDef(h, key [, default]): on a HIT it returns the
                // entry's value; on a MISS it returns the default WITHOUT
                // adding the key - or NIL when no default is given (hk194).
                // Unlike hb_HGet, a miss is not an error here. The default
                // is an integer or NIL in this increment. Hash and key
                // borrowed.
                if args.len() != 2 && args.len() != 3 {
                    return Err(format!("line {}: `hb_HGetDef` takes two or three arguments", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HGetDef` expects a hash variable (its slot is passed by address)", n));
                }
                if !matches!(type_expr(&args[1], env, sigs, n)?, Ty::Str | Ty::StrOwn) {
                    return Err(format!("line {}: hash keys are strings in this increment", n));
                }
                if args.len() == 3 && !matches!(type_expr(&args[2], env, sigs, n)?, Ty::I64 | Ty::Bool | Ty::Dyn) {
                    return Err(format!("line {}: the hb_HGetDef default is an integer or NIL in this increment", n));
                }
                return Ok(Ty::Dyn);
            }
            if is_builtin(id, "hb_hsetdef") {
                // hb_HSetDef(h, key [, default]): an expression WITH an
                // effect - an absent key is ADDED (default, or NIL with
                // no default) and returned; a present key returns its
                // stored value, overwritten only when the stored Dyn tag
                // differs from the default's (hk196/hk196b/hk196d). The
                // default is an integer or NIL in this increment. The
                // hash is borrowed for the mutation (hbc_hsetdef copies
                // the key and the default cell), the key is borrowed.
                if args.len() != 2 && args.len() != 3 {
                    return Err(format!("line {}: `hb_HSetDef` takes two or three arguments", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HSetDef` expects a hash variable (its slot is passed by address)", n));
                }
                if !matches!(type_expr(&args[1], env, sigs, n)?, Ty::Str | Ty::StrOwn) {
                    return Err(format!("line {}: hash keys are strings in this increment", n));
                }
                if args.len() == 3 && !matches!(type_expr(&args[2], env, sigs, n)?, Ty::I64 | Ty::Bool | Ty::Dyn) {
                    return Err(format!("line {}: the hb_HSetDef default is an integer or NIL in this increment", n));
                }
                return Ok(Ty::Dyn);
            }
            if is_builtin(id, "hb_hclone") {
                // hb_HClone(h): a NEW hash whose entries are DEEP copies
                // (hk166: fully independent - later writes on either side
                // do not cross) in the SAME insertion order, NILs
                // preserved (hk167); cloning an empty hash gives an
                // empty one. The source is BORROWED (only read).
                if args.len() != 1 {
                    return Err(format!("line {}: `hb_HClone` takes exactly one argument", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HClone` expects a hash variable (its slot is passed by address)", n));
                }
                return Ok(Ty::Hash);
            }
            if is_builtin(id, "hb_hvalues") {
                // hb_HValues(h): NEW array of the hash's value casillas
                // (tagged int/NIL scalars) in insertion order (oracles
                // hk153/hk154, core hb_HValues). The hash is borrowed;
                // the result is a DArr the caller owns, independent of
                // the hash (hk153: writing it does not touch the hash).
                if args.len() != 1 {
                    return Err(format!("line {}: `hb_HValues` takes exactly one argument", n));
                }
                if !matches!(&args[0], Expr::Var(_)) || type_expr(&args[0], env, sigs, n)? != Ty::Hash {
                    return Err(format!("line {}: `hb_HValues` expects a hash variable (its slot is passed by address)", n));
                }
                return Ok(Ty::DArr);
            }
            if is_builtin(id, "eval") {
                // eval(b, a1..an): b is a codeblock value. Extra arguments
                // are evaluated and IGNORED, as Harbour does (probes c7 and
                // c7b: side effects run, the result ignores them); fewer
                // arguments than parameters are a COMPILE error here
                // (Harbour fails at runtime with an interactive dialog -
                // probe c8). Arguments are integers in this increment.
                if args.is_empty() {
                    return Err(format!("line {}: `eval` needs a codeblock as its first argument", n));
                }
                let t0 = type_expr(&args[0], env, sigs, n)?;
                let k = match t0 {
                    Ty::Block(k) => k,
                    _ => return Err(format!("line {}: `eval` expects a codeblock as its first argument", n)),
                };
                if args.len() - 1 < k {
                    return Err(format!("line {}: codeblock takes {} argument(s), `eval` got {}", n, k, args.len() - 1));
                }
                for a in &args[1..] {
                    if type_expr(a, env, sigs, n)? != Ty::I64 {
                        return Err(format!("line {}: codeblock arguments must be integers in this increment", n));
                    }
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "iif") {
                // iif(cond, a, b) (oracle hk321): LAZY - only the chosen
                // branch evaluates (side effects on the dead branch do
                // not happen). Branches unify: identical scalar types,
                // or F64 absorbs an I64 side through the 63zd boundary
                // conversion (dec 0 + provenance length). Anything else
                // (Dyn, arrays, owned strings, mismatched scalars) keeps
                // a named rejection.
                if args.len() != 3 {
                    return Err(format!("line {}: `iif` takes 3 arguments, got {}", n, args.len()));
                }
                if type_expr(&args[0], env, sigs, n)? != Ty::Bool {
                    return Err(format!("line {}: `iif` condition must be logical", n));
                }
                let ta = type_expr(&args[1], env, sigs, n)?;
                let tb = type_expr(&args[2], env, sigs, n)?;
                if ta == tb && matches!(ta, Ty::I64 | Ty::Bool | Ty::Str | Ty::F64) { return Ok(ta); }
                // NIL-producing arms use the existing Dyn pair but own no
                // payload. Do not generalize this to Dyn variables/owned
                // tag4 strings without a separate transfer/lifetime design.
                let nil_arm = |e: &Expr| matches!(e, Expr::Nil)
                    || matches!(e, Expr::Call(id, _) if is_output_call(id));
                if ta == Ty::Dyn && tb == Ty::Dyn && nil_arm(&args[1]) && nil_arm(&args[2]) { return Ok(Ty::Dyn); }
                if matches!((ta, tb), (Ty::F64, Ty::I64) | (Ty::I64, Ty::F64)) { return Ok(Ty::F64); }
                // Owned-string unification (63zf, hk329): the result is
                // OWNED. A borrowed side materializes a clone only when
                // its arm is taken; an owned-variable side moves only
                // when its arm is taken (laziness keeps single ownership).
                if matches!(ta, Ty::Str | Ty::StrOwn) && matches!(tb, Ty::Str | Ty::StrOwn) { return Ok(Ty::StrOwn); }
                return Err(format!("line {}: `iif` branches must share a scalar type (float absorbs an int side), got {:?} and {:?}", n, ta, tb));
            }
            if ["ltrim", "rtrim", "alltrim", "trim"].iter().any(|b| is_builtin(id,b)) {
                if args.len()!=1 { return Err(format!("line {}: `{}` takes one argument in this increment",n,id)); }
                if !matches!(type_expr(&args[0],env,sigs,n)?,Ty::Str|Ty::StrOwn) {
                    return Err(format!("line {}: `{}` expects a string",n,id));
                }
                return Ok(Ty::StrOwn);
            }
            if is_output_call(id) {
                let mut item_env = env.to_vec();
                for a in args {
                    let t = type_expr(a, &mut item_env, sigs, n)?;
                    if matches!(t, Ty::Block(_)) { return Err(format!("line {}: cannot print a codeblock in this increment", n)); }
                    if matches!(t, Ty::Arr(_) | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Hash) && !matches!(a, Expr::Var(_)) {
                        return Err(format!("line {}: cannot print a temporary array or hash directly in this increment (assign it to a variable and print the variable)", n));
                    }
                    apply_moves(a, &mut item_env, sigs, false);
                }
                // Item evaluation precedes siblings of the QOut result too.
                for (outer, inner) in env.iter_mut().zip(item_env.iter()) {
                    outer.moved |= inner.moved;
                }
                return Ok(Ty::Dyn); // NIL, using the existing tagged return pair.
            }
            if is_builtin(id, "asc") {
                if args.len() != 1 { return Err(format!("line {}: `asc` takes one argument", n)); }
                if !matches!(type_expr(&args[0], env, sigs, n)?, Ty::Str | Ty::StrOwn) {
                    return Err(format!("line {}: `asc` expects a string (Harbour raises 1107; statically typed here)", n));
                }
                return Ok(Ty::I64);
            }
            if is_builtin(id, "chr") {
                if args.len() != 1 { return Err(format!("line {}: `chr` takes one argument", n)); }
                if type_expr(&args[0], env, sigs, n)? != Ty::I64 {
                    return Err(format!("line {}: `chr` expects an integer in this increment (Harbour converts numeric arguments; float conversion is not covered here)", n));
                }
                return Ok(Ty::StrOwn);
            }
            if is_builtin(id, "round") {
                // Round(n, d) - hb_numRound measured (src/common/hbstr.c;
                // oracles hk384-hk386): half away from zero with the
                // HB_DBLFL_PREC_FACTOR ulp lift (hbdefs.h:665), result
                // dec = max(d, 0), exact pow10 table for |d| <= 15.
                if args.len() != 2 {
                    return Err(format!("line {}: `round` takes two arguments", n));
                }
                let tn = type_expr(&args[0], env, sigs, n)?;
                if !matches!(tn, Ty::I64 | Ty::F64) {
                    return Err(format!("line {}: `round` expects a numeric first argument (Harbour raises RT error EG_ARG; compile-time typed here)", n));
                }
                let td = type_expr(&args[1], env, sigs, n)?;
                if td != Ty::I64 {
                    return Err(format!("line {}: `round` expects an integer dec argument (Harbour hb_parni converts; a named limit of this increment)", n));
                }
                if let Expr::Int(v) = &args[1] {
                    if let Ok(dv) = v.parse::<i64>() {
                        if dv.abs() > 15 {
                            return Err(format!("line {}: `round` dec beyond +/-15 is parked (Harbour switches to pow(10,d) there; the exact-table zone is the measured one)", n));
                        }
                    }
                }
                return Ok(Ty::F64);
            }
            if is_builtin(id, "pcount") {
                // PCount() needs the CALLER's argument count; the calling
                // convention carries no count in this increment (extra
                // arguments are already rejected by name), so the
                // introspection is a named rejection, not a silent 0.
                return Err(format!("line {}: `PCount` is not in this increment (the calling convention carries no argument count; `hb_PValue` over the declared parameters is the supported introspection)", n));
            }
            if is_builtin(id, "hb_pvalue") {
                // hb_PValue(n) (multiarg): the n-th DECLARED parameter of the
                // enclosing function as a Dyn casilla; an out-of-range index
                // is NIL. Extra call arguments beyond the declared list stay
                // rejected (registered limit), so declared parameters are the
                // whole observable range. Every declared parameter must be
                // Dyn-representable: integers, logicals, strings and Dyn
                // casillas tag in place; a FLOAT parameter would need a Dyn
                // float payload tag - the representation decision is pending
                // (63zc family), so it is a named rejection, as are arrays,
                // hashes and codeblocks.
                if args.len() != 1 {
                    return Err(format!("line {}: `hb_PValue` takes one argument", n));
                }
                if IN_BLOCK.with(|c| c.get()) {
                    return Err(format!("line {}: `hb_PValue` inside a codeblock is not in this increment (it would expose the codeblock's own parameters)", n));
                }
                let ti = type_expr(&args[0], env, sigs, n)?;
                if !matches!(ti, Ty::I64 | Ty::Dyn) {
                    return Err(format!("line {}: `hb_PValue` takes an integer index", n));
                }
                let cur = CUR_FN.with(|c| c.borrow().clone());
                if let Some(s) = sigs.iter().find(|v| v.name == cur) {
                    for (pi, pt) in s.params.iter().enumerate() {
                        match pt {
                            Ty::I64 | Ty::Bool | Ty::Str | Ty::StrOwn | Ty::Dyn => {}
                            Ty::F64 => return Err(format!("line {}: `hb_PValue` in `{}` would expose parameter #{} as Dyn, but Dyn has no float payload tag in this increment (the representation decision is pending)", n, cur, pi + 1)),
                            other => return Err(format!("line {}: `hb_PValue` in `{}` cannot expose parameter #{} ({}) as a Dyn casilla in this increment", n, cur, pi + 1, ty_name(*other))),
                        }
                    }
                }
                // `main` has no signature entry: command-line arguments are
                // not passed in this increment, so every index is NIL there
                // (registered absence of Harbour's CLI channel).
                return Ok(Ty::Dyn);
            }
            let si = sigs.iter().position(|v| v.name == *id)
                .ok_or_else(|| format!("line {}: unknown function `{}` (must be defined before use)", n, id))?;
            let (sig_params, sig_borrowed, sig_arr_moved, sig_ret, sig_inferred) = {
                let s = &sigs[si];
                (s.params.clone(), s.borrowed.clone(), s.arr_moved.clone(), s.ret, s.inferred.clone())
            };
            if args.len() > sig_params.len() {
                // EXTRA arguments stay rejected (multiarg registered limit):
                // hb_PValue introspection names only the declared list.
                return Err(format!("line {}: `{}` takes {} argument(s), got {}", n, id, sig_params.len(), args.len()));
            }
            if args.len() < sig_params.len() {
                // Harbour fills omitted trailing parameters with NIL
                // (multiarg). Sticky evidence: the fixpoint forces those
                // parameters to the tagged union (Dyn); codegen pads the
                // boundary with NIL casillas (tag 1). Monotone false->true.
                for i in args.len()..sig_params.len() {
                    sigs[si].nil_ev[i] = true;
                }
            }
            for (i, a) in args.iter().enumerate() {
                // Float-argument evidence for the NEXT inference round
                // (63zd): recorded even against a placeholder parameter,
                // ahead of every per-argument check below. Only F64 is
                // tracked - every other type already has body evidence
                // or an established boundary contract. A mid-round error
                // here is swallowed on purpose: the placeholder path
                // skips checks anyway, and the inferred path re-runs
                // type_expr below, where the same error propagates.
                if !matches!(a, Expr::ByRef(_)) && i < sigs[si].arg_ev.len() {
                    // Literal argument-type evidence (multiarg): integer,
                    // string and logical literals are stable across the
                    // fixpoint, like the established float trail. Varying
                    // types across call sites merge to the tagged union
                    // (Harbour retypes the parameter per call; Dyn is that
                    // union here); an integer/float mix keeps the 63zd
                    // I64 -> F64 lift.
                    let ev = match a {
                        Expr::Int(_) => Some(Ty::I64),
                        Expr::Str(_) => Some(Ty::Str),
                        Expr::Log(_) => Some(Ty::Bool),
                        _ => match type_expr(a, env, sigs, n) { Ok(Ty::F64) => Some(Ty::F64), _ => None },
                    };
                    if let Some(e) = ev {
                        sigs[si].arg_ev[i] = match (sigs[si].arg_ev[i], e) {
                            (None, x) => Some(x),
                            (Some(x), y) if x == y => Some(x),
                            (Some(Ty::I64), Ty::F64) | (Some(Ty::F64), Ty::I64) => Some(Ty::F64),
                            (Some(_), _) => Some(Ty::Dyn),
                        };
                    }
                }
                if !sig_inferred.get(i).copied().unwrap_or(false) {
                    // Placeholder parameter (order-independent fixpoint,
                    // pre-convergence or genuinely uninferable): no
                    // per-argument TYPE check is meaningful against it, and
                    // flags flipped on a placeholder could persist into
                    // the converged table. The callee's pin error is
                    // the diagnostic; when the parameter gains evidence
                    // in a later round, this call site is re-checked.
                    // The argument expression itself must still be VALID:
                    // an unknown function nested here otherwise escaped
                    // every check and panicked apply_moves' expect (t1369;
                    // preexisting since the placeholder skip, verifier
                    // results-63f29286/panic-minimized-afc00014). Mid-round
                    // errors are dropped like any other; the converged
                    // round reports them by name.
                    if !matches!(a, Expr::ByRef(_)) {
                        type_expr(a, env, sigs, n)?;
                    }
                    continue;
                }
                if let Expr::ByRef(vn) = a {
                    // `@x` (hk216 family): the callee gets an EXCLUSIVE
                    // borrow of the caller's own slot for the duration of
                    // the call; writes land in the caller's variable.
                    // Scalars and owned strings only in this increment;
                    // collections wait on the user's RC decision (analysis
                    // not done). Divergence REGISTERED: Harbour allows
                    // aliasing `@x, @x` (hk219); here one exclusive borrow
                    // per call, so the original program is not compatible.
                    let (vty, vmoved) = match env.iter().find(|x| x.name == *vn) {
                        Some(v) => (v.ty, v.moved),
                        None => return Err(format!("line {}: `@{}` names no visible variable", n, vn)),
                    };
                    if vmoved {
                        return Err(format!("line {}: `@{}` after its value moved out", n, vn));
                    }
                    if vty == Ty::Str {
                        return Err(format!("line {}: `@{}` needs an owned string slot; `{}` holds a borrowed (rodata) string in this increment", n, vn, vn));
                    }
                    if !matches!(vty, Ty::I64 | Ty::Bool | Ty::StrOwn) {
                        return Err(format!("line {}: `@` on arrays, hashes, codeblocks and Dyn is not in this increment (the sharing analysis is pending the user's RC decision)", n));
                    }
                    if !(sig_params[i] == vty || (vty == Ty::StrOwn && sig_params[i] == Ty::Str)) {
                        return Err(format!("line {}: argument {} of `{}` must be {}, got {}",
                            n, i + 1, id, ty_name(sig_params[i]), ty_name(vty)));
                    }
                    for (j, b) in args.iter().enumerate() {
                        if j == i { continue; }
                        let clash = match b {
                            Expr::ByRef(w) => w == vn,
                            other => expr_mentions(other, vn),
                        };
                        if clash {
                            return Err(format!("line {}: cannot borrow `{}` exclusively: another argument uses it in the same call (Harbour allows this alias, hk219 - registered divergence)", n, vn));
                        }
                    }
                    continue;
                }
                // A MIDDLE cell as an argument: f(a[i]) on an array of
                // arrays. Harbour SHARES the child with the callee
                // (oracles hk73 reads, hk78 growth, hk86 element write,
                // hk87 shrink - all visible back in the caller). This
                // increment passes the child cell's ADDRESS: the callee
                // borrows it exclusively for the call, so growth/shrink/
                // writes land in the owner's cell and read back exactly
                // like Harbour, while the single-owner model stays intact
                // (the borrow ends at the return; escapes are rejected by
                // the post-pass). NOT Harbour sharing: no alias survives
                // the call (registered difference family D5/D7).
                if let Expr::Index(rid, ie) = a {
                    let root = env.iter().find(|v| v.name == *rid);
                    if let Some(v) = root {
                        // One level deeper (33k): f(a[i]) on a THREE-level
                        // array borrows a middle whose cells are child
                        // arrays {ptr, len} - the callee pins DArr2
                        // (oracles hk93-hk96). Same walk, same rules.
                        let borrow_match = (v.ty == Ty::DArr2 && sig_params[i] == Ty::DArr)
                            || (v.ty == Ty::DArr3 && sig_params[i] == Ty::DArr2);
                        if borrow_match {
                            if v.moved {
                                return Err(format!("line {}: use of moved value `{}`", n, rid));
                            }
                            if sig_arr_moved[i] {
                                return Err(format!("line {}: parameter {} of `{}` already receives an owned array elsewhere; it cannot also borrow `a[i]`", n, i + 1, id));
                            }
                            if type_expr(ie, env, sigs, n)? != Ty::I64 {
                                return Err(format!("line {}: array index must be an integer", n));
                            }
                            // The index expression itself may have MOVED the
                            // root (f(a[g(a)]): evaluated before the walk):
                            // reject instead of borrowing nulled slots.
                            if env.iter().find(|v| v.name == *rid).map(|v| v.moved).unwrap_or(true) {
                                return Err(format!("line {}: the index expression moves `{}`; compute the index first", n, rid));
                            }
                            // No aliasing inside one call: no other argument
                            // may mention the same root (two live borrows, or
                            // a move while borrowed, are unsound).
                            for (j, b) in args.iter().enumerate() {
                                if j != i && expr_mentions(b, rid) {
                                    return Err(format!("line {}: `{}` is borrowed by argument {}; no other argument of the same call may mention it", n, rid, i + 1));
                                }
                            }
                            sigs[si].borrowed[i] = true;
                            continue;
                        }
                    }
                }
                let ta = type_expr(a, env, sigs, n)?;
                if let Ty::Arr(_) = ta {
                    // A static root array argument is COPIED at the
                    // boundary into a flat dynamic array the callee owns
                    // and frees (33l). Oracle hk98: Harbour SHARES the
                    // array (callee writes and growth are visible in the
                    // caller), so the copy is a registered D5/D7-family
                    // difference pending the user's contract decision -
                    // NOT sharing. Only a variable argument and only a
                    // flat dynamic-array parameter pin; anything deeper
                    // stays a named rejection.
                    if sig_params[i] != Ty::DArr || !matches!(a, Expr::Var(_)) {
                        return Err(format!("line {}: a static array argument is copied at the boundary only into a flat dynamic-array parameter, from a variable, in this increment", n));
                    }
                    continue;
                }

                if ta == Ty::DArrU {
                    return Err(format!("line {}: the element type of the argument is unknown until its first `AAdd` (pin it first)", n));
                }
                // A string argument moves out of its variable right away, so
                // a second use later in the same expression (e.g. the other
                // side of a `+`) is rejected like any other use-after-move.
                if ta == Ty::Str || ta == Ty::StrOwn {
                    if let Expr::Var(v) = a {
                        if let Some(x) = env.iter().find(|x| x.name == *v && x.byref && matches!(x.ty, Ty::Str | Ty::StrOwn)) {
                            return Err(format!("line {}: passing borrowed parameter `{}` by value moves it out of its owner - not Harbour semantics; derive a value instead (for example a concatenation)", n, v));
                        }
                        // A Dyn target CLONES at the boundary (the
                        // caller keeps its value), so no move is marked.
                        if sig_params[i] != Ty::Dyn {
                            if let Some(x) = env.iter_mut().find(|x| x.name == *v && matches!(x.ty, Ty::Str | Ty::StrOwn)) { x.moved = true; }
                        }
                    }
                }
                // A hash LITERAL argument has no emission path in
                // argument position (33o): only variables move into a
                // hash parameter. Named rejection instead of the cg
                // unreachable.
                if ta == Ty::Hash && !matches!(a, Expr::Var(_)) {
                    return Err(format!("line {}: a hash argument is a variable in this increment (assign the literal first)", n));
                }
                let ok = ta == sig_params[i]
                    || (ta == Ty::Dyn && sig_params[i] == Ty::I64)  // runtime extract (nil -> clean type error)
                    || (ta == Ty::I64 && sig_params[i] == Ty::F64) // integer converts to a double at the boundary (63zd; oracles hk302/hk303/hk307)
                    || (ta == Ty::I64 && sig_params[i] == Ty::Dyn) // tagged at the call
                    || ((ta == Ty::Str || ta == Ty::StrOwn) && sig_params[i] == Ty::Dyn) // cloned to an owned tag-4 payload at the boundary (hk259)
                    || (ta == Ty::Bool && sig_params[i] == Ty::Dyn) // tagged 3 at the call (hk264)
                    || (ta == Ty::Str && sig_params[i] == Ty::StrOwn); // rodata: copied at the call boundary
                if !ok {
                    // Two codeblocks of different arity: name both arities so
                    // the diagnostic is not "must be a codeblock, got a
                    // codeblock" (33q, parent-reported defect on t446).
                    if let (Ty::Block(want), Ty::Block(got)) = (sig_params[i], ta) {
                        return Err(format!("line {}: argument {} of `{}` must be a codeblock of {} argument(s), got a codeblock of {} argument(s)",
                            n, i + 1, id, want, got));
                    }
                    return Err(format!("line {}: argument {} of `{}` must be {}, got {}",
                        n, i + 1, id,
                        ty_name(sig_params[i]), ty_name(ta)));
                }
                // An owned array variable moves into the parameter (the
                // established contract): exclusive with the borrow mode.
                if matches!(ta, Ty::DArr | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS) {
                    if sig_borrowed[i] {
                        return Err(format!("line {}: parameter {} of `{}` already borrows `a[i]` elsewhere; it cannot also receive an owned array", n, i + 1, id));
                    }
                    sigs[si].arr_moved[i] = true;
                }
            }
            match sig_ret {
                Some(t) => Ok(t),
                None if CALL_STMT_CTX.with(|c| c.get()) => Ok(Ty::I64), // statement position: value discarded, nothing to release
                None => Err(format!("line {}: `{}` never returns a value; its result cannot be used in an expression in this PoC", n, id)),
            }
        }
        Expr::Bin(op, a, b) => {
            let ta = type_expr(a, env, sigs, n)?;
            let tb = type_expr(b, env, sigs, n)?;
            // String `+` concatenation (oracle hk215): both operands
            // strings, result a fresh owned buffer copying both - Harbour
            // value semantics, variables keep their own copies.
            if *op == '+' && matches!(ta, Ty::Str | Ty::StrOwn) && matches!(tb, Ty::Str | Ty::StrOwn) {
                return Ok(Ty::StrOwn);
            }
            // Dyn operands are extracted at runtime: a NIL payload is a
            // clean type error (Harbour's interactive dialog is the
            // registered failure-mode difference, same condition).
            // `%` (hb_vmModulus; oracles hk340-hk348): any numeric mix
            // produces a DOUBLE with dec = SET DECIMALS at runtime
            // ("Clipper always returns modulus with the SET number of
            // decimal places"; hk348 shows variable int%int printing
            // 1.00), so the static type is F64; only literal int%int
            // folds to a LONG at parse (hk340). A zero divisor yields
            // integer-image 0 (hk343/hk344). Dyn payloads extract to
            // i64 first, exactly like +,-,* (NIL payload -> clean type
            // error; Harbour's dialog is the registered difference).
            if *op == '%' {
                if !matches!(ta, Ty::I64 | Ty::F64 | Ty::Dyn) || !matches!(tb, Ty::I64 | Ty::F64 | Ty::Dyn) {
                    return Err(format!("line {}: `%` needs numeric operands (strings, logicals and arrays are a Harbour type error, EG_ARG 1085)", n));
                }
                return Ok(Ty::F64);
            }
            if *op == '^' {
                // hb_vmPower: pow() on the (double) reads of both
                // operands, result ALWAYS a double with dec = SET(2)
                // (oracles hk350-hk354; non-numeric -> EG_ARG 1088).
                // Dyn payloads extract to i64 exactly like % (pow on
                // integral doubles is exact - no truncation divergence
                // like Dyn division).
                if !matches!(ta, Ty::I64 | Ty::F64 | Ty::Dyn) || !matches!(tb, Ty::I64 | Ty::F64 | Ty::Dyn) {
                    return Err(format!("line {}: `^` needs numeric operands (strings, logicals and arrays are a Harbour type error, EG_ARG 1088)", n));
                }
                return Ok(Ty::F64);
            }
            if *op == '/' && ta == Ty::I64 && tb == Ty::I64 {
                // hb_vmDivide: every numeric division produces a double
                // with dec = SET DECIMALS (oracle hk292); literal-only
                // division folded at parse (oracle hk291).
                return Ok(Ty::F64);
            }
            if *op == '/' && matches!(ta, Ty::Dyn) || *op == '/' && matches!(tb, Ty::Dyn) {
                // A Dyn payload extracts to i64 in this PoC, so a Dyn
                // division would TRUNCATE (10/3 -> 3) where Harbour
                // produces a double (hb_vmDivide) - a silent semantic bug
                // on valid programs. Rejected by name until Dyn carries
                // F64 payloads (no Dyn float tag in this increment).
                return Err(format!("line {}: division with a NIL-able (Dyn) operand is not in this increment (Harbour always divides as doubles; an i64 payload path would silently truncate)", n));
            }
            if ta == Ty::F64 || tb == Ty::F64 {
                // Float arithmetic on values (oracles hk279/hk292/hk296:
                // +,- keep dec = max; * sums the decs; / takes SET
                // DECIMALS = 2; integer operands promote with dec 0).
                // Mixed float/string, float/logical, float/array and
                // float/Dyn stay Harbour type errors (BASE/1081+); Dyn
                // has no float payload tag in this increment.
                if matches!(ta, Ty::Dyn) || matches!(tb, Ty::Dyn) {
                    // Covered LIMIT, not a Harbour error: Harbour runs a
                    // float op with a number-holding Dyn fine; this PoC's
                    // Dyn has no float payload tag, so the op is rejected
                    // by name instead of silently truncating (63zc).
                    return Err(format!("line {}: arithmetic between a NIL-able (Dyn) value and a float is a covered LIMIT of this increment (Harbour runs it when the Dyn holds a number; this PoC's Dyn has no float payload - registered divergence, no silent truncation)", n));
                }
                if !matches!(ta, Ty::I64 | Ty::F64) || !matches!(tb, Ty::I64 | Ty::F64) {
                    return Err(format!("line {}: arithmetic needs numeric operands (float mixed with strings, logicals or arrays is a Harbour type error)", n));
                }
                return Ok(Ty::F64);
            }
            if !matches!(ta, Ty::I64 | Ty::Dyn) || !matches!(tb, Ty::I64 | Ty::Dyn) {
                return Err(format!("line {}: arithmetic requires integers", n));
            }
            Ok(Ty::I64)
        }
        Expr::Nil => Ok(Ty::Dyn),
        Expr::ByRef(_) => Err(format!("line {}: `@` is only valid directly as a call argument (hk221)", n)),
        Expr::Log(_) => Ok(Ty::Bool),
        Expr::LNot(a) => {
            if !matches!(type_expr(a, env, sigs, n)?, Ty::Bool | Ty::Dyn) {
                return Err(format!("line {}: `.NOT.` needs a logical operand (hk197)", n));
            }
            Ok(Ty::Bool)
        }
        Expr::LAnd(a, b) | Expr::LOr(a, b) => {
            if !matches!(type_expr(a, env, sigs, n)?, Ty::Bool | Ty::Dyn) || !matches!(type_expr(b, env, sigs, n)?, Ty::Bool | Ty::Dyn) {
                return Err(format!("line {}: `.AND.`/`.OR.` need logical operands (hk197/hk198)", n));
            }
            Ok(Ty::Bool)
        }
        Expr::Cmp(op, a, b) => {
            // `$` containment (oracle hk341): string-in-string only in
            // this increment - case-sensitive byte scan; an empty or
            // longer-than-haystack needle is .F. (measured). Array
            // membership `$` stays out (registered).
            if matches!(op, CmpOp::Contains) {
                let ta = type_expr(a, env, sigs, n)?;
                let tb = type_expr(b, env, sigs, n)?;
                if matches!(ta, Ty::Str | Ty::StrOwn) && matches!(tb, Ty::Str | Ty::StrOwn) {
                    return Ok(Ty::Bool);
                }
                return Err(format!("line {}: containment `$` is measured for string-in-string only (oracle hk341); array membership is not in this increment", n));
            }
            // A grown casilla of an array of arrays compares against NIL
            // with `=` / `#` (oracle n4): the borrow reads the child
            // pointer, it never extracts the subarray. A real empty child
            // ({}) owns a block and is NOT NIL.
            if matches!(op, CmpOp::EqEq) {
                // NIL first: the other side may be a casilla read that
                // type_expr rejects by value (hk129), so classify before
                // computing both types.
                if matches!(&**a, Expr::Nil) || matches!(&**b, Expr::Nil) {
                    let other = if matches!(&**a, Expr::Nil) { &**b } else { &**a };
                    if let Expr::Index(v, ie) = other {
                        if env.iter().any(|x| x.name == *v && matches!(x.ty, Ty::DArr2 | Ty::DArr3)) {
                            if type_expr(ie, env, sigs, n)? != Ty::I64 {
                                return Err(format!("line {}: array index must be an integer in this increment", n));
                            }
                            return Ok(Ty::Bool);
                        }
                    }
                    let tother = type_expr(other, env, sigs, n)?;
                    if matches!(tother, Ty::Str | Ty::StrOwn | Ty::I64 | Ty::Dyn) { return Ok(Ty::Bool); }
                    return Err(format!("line {}: `==` against NIL is measured only for numbers, strings, NIL and dynamic casillas (hk128/hk129)", n));
                }
                let ta = type_expr(a, env, sigs, n)?;
                let tb = type_expr(b, env, sigs, n)?;
                // `==` measured so far. Between integers (hk124: 1==1
                // .T., 1==2 .F.). Between two one-level DYNAMIC array
                // VARIABLES as reference identity (hk126: a==a .T.,
                // a==b .F. even with equal contents - the frame slot
                // holds the heap pointer and that pointer is the
                // identity). Static arrays stay rejected: Harbour
                // compares references while our static arrays are
                // copied into the frame (D5/D7 family), so an element
                // compare would answer .T. where Harbour answers .F.
                if matches!(ta, Ty::I64 | Ty::F64) && matches!(tb, Ty::I64 | Ty::F64) { return Ok(Ty::Bool); } // numeric `==` compares values like `=` (hk124; floats hk296)
                if ta == Ty::Bool && tb == Ty::Bool { return Ok(Ty::Bool); } // hk202: t == t is .T.
                // NIL handled above (hk128/hk129): identity and equality
                // coincide where NIL is one side; same codegen as `=`.
                // Strings: `==` is the EXACT comparison (hk124: "a"=="a"
                // .T., "a"=="a " .F., "a "=="a" .F.) - not the prefix
                // rule of `=`. Codegen calls hbc_str_xeq.
                if matches!(ta, Ty::Str | Ty::StrOwn) && matches!(tb, Ty::Str | Ty::StrOwn) {
                    return Ok(Ty::Bool);
                }
                if matches!(ta, Ty::DArr | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::Hash) && ta == tb
                    && matches!(&**a, Expr::Var(_)) && matches!(&**b, Expr::Var(_)) {
                    // hk130: nested dynamic arrays answer identity too
                    // (a==a .T., a==b .F.). The frame slot's first qword
                    // is the heap pointer - the identity - at every depth.
                    // hk134: hash variables answer identity the same way
                    // (h==h .T., h==k .F. even with equal contents).
                    return Ok(Ty::Bool);
                }
                // Dynamic casillas (hk132/hk133/hk138/hk140): `==`
                // between two casillas, or between a casilla and a
                // string/integer, dispatches on the runtime tag -
                // string x string is the EXACT byte compare, number x
                // number the value compare, NIL x NIL .T., NIL x
                // payload .F. Mixed number x string raises Harbour's
                // BASE/1070 (hk139/hk139b/hk139c: dialog that hangs
                // headless) - a clean named exit 1 here, registered
                // failure mode, not exact equivalence.
                if (matches!(ta, Ty::Dyn) || matches!(tb, Ty::Dyn))
                    && matches!(ta, Ty::Dyn | Ty::Str | Ty::StrOwn | Ty::I64)
                    && matches!(tb, Ty::Dyn | Ty::Str | Ty::StrOwn | Ty::I64) {
                    return Ok(Ty::Bool);
                }
                // Codeblocks stay rejected: Harbour's identity is per
                // EVALUATION (hk131: x==x .T., x==y .F. between literals;
                // hk136: make()==make() .F. for the same literal returned
                // twice; hk137: the same literal assigned in two loop
                // iterations is .F.) while our slot holds a per-literal
                // STATIC pointer, which would answer .T. where Harbour
                // says .F. A truthful rejection beats fake compatibility.
                return Err(format!("line {}: `==` is measured only between two integers, between two strings, between two one-level dynamic array variables and against NIL in this increment (hk124/hk126/hk128/hk129); static arrays, codeblocks (identity is per evaluation - hk131/hk136/hk137 - and our slot is per literal) and non-NIL Dyn payloads keep their named rejections (object identity oracles cl7/cl19 stay class-gated)", n));
            }
            if matches!(op, CmpOp::Eq | CmpOp::Ne) {
                let cas = |e: &Expr| matches!(e, Expr::Index(v, _) if env.iter().any(|x| x.name == *v && matches!(x.ty, Ty::DArr2 | Ty::DArr3)));
                let idx = if cas(a) && matches!(**b, Expr::Nil) {
                    if let Expr::Index(_, ie) = &**a { Some(ie) } else { None }
                } else if cas(b) && matches!(**a, Expr::Nil) {
                    if let Expr::Index(_, ie) = &**b { Some(ie) } else { None }
                } else { None };
                if let Some(ie) = idx {
                    if type_expr(ie, env, sigs, n)? != Ty::I64 {
                        return Err(format!("line {}: array index must be an integer", n));
                    }
                    return Ok(Ty::Bool);
                }
            }
            let ta = type_expr(a, env, sigs, n)?;
            let tb = type_expr(b, env, sigs, n)?;
            // NIL against a string: Harbour answers .F. for `=` (probe n1:
            // "" == NIL is .F., no error). Only `=` / `#` are accepted;
            // ordering NIL is a Harbour runtime error (no headless oracle).
            // Ordering a NIL literal is a Harbour type error (no headless
            // oracle): reject it at compile time. A NIL held in a variable
            // still compares numerically - the documented sentinel cost.
            if (matches!(**a, Expr::Nil) || matches!(**b, Expr::Nil)) && !matches!(op, CmpOp::Eq | CmpOp::Ne) {
                return Err(format!("line {}: NIL only compares with `=` or `#` in this PoC (Harbour raises a type error on ordering NIL)", n));
            }
            let nil_str = (matches!(**a, Expr::Nil) && matches!(tb, Ty::Str | Ty::StrOwn)) || (matches!(**b, Expr::Nil) && matches!(ta, Ty::Str | Ty::StrOwn));
            if nil_str {
                return Ok(Ty::Bool);
            }
            if let Ty::Arr(_) = ta {
                return Err(format!("line {}: arrays do not compare in this increment", n));
            }
            if let Ty::Arr(_) = tb {
                return Err(format!("line {}: arrays do not compare in this increment", n));
            }
            if let Ty::Block(_) = ta {
                return Err(format!("line {}: codeblocks do not compare in this increment", n));
            }
            if ta == Ty::DArr || tb == Ty::DArr {
                return Err(format!("line {}: dynamic arrays do not compare in this increment", n));
            }
            if let Ty::Block(_) = tb {
                return Err(format!("line {}: codeblocks do not compare in this increment", n));
            }
            if ta == Ty::I64 && tb == Ty::I64 {
                return Ok(Ty::Bool);
            }
            if matches!(ta, Ty::I64 | Ty::F64) && matches!(tb, Ty::I64 | Ty::F64) {
                // Float comparisons: plain IEEE double compare with
                // integer operands converted (oracles hk280/hk296/hk300).
                return Ok(Ty::Bool);
            }
            if ta == Ty::Bool && tb == Ty::Bool && matches!(op, CmpOp::Eq | CmpOp::Ne) {
                // hk202: .T. = .T. is .T., .T. <> .F. is .T.
                return Ok(Ty::Bool);
            }
            if (ta == Ty::Bool || tb == Ty::Bool) && ta != Ty::Dyn && tb != Ty::Dyn {
                // hk202: `.T. = 1` raises Harbour's BASE/1071 argument
                // error at runtime; ordering logicals is unmeasured. A
                // compile-time rejection in both cases (a Dyn operand is
                // dispatched at runtime instead, below).
                return Err(format!("line {}: logicals compare only with another logical under `=`/`#`/`==` (hk202); mixed logical/number raises Harbour's BASE/1071 and stays a compile-time rejection here", n));
            }
            if matches!(ta, Ty::Str | Ty::StrOwn) && matches!(tb, Ty::Str | Ty::StrOwn) {
                // Comparison BORROWS both operands (nothing is moved).
                // Ordering is byte-wise (memcmp-like): no collation.
                let _ = op;
                return Ok(Ty::Bool);
            }
            // Dyn against a Dyn: tag dispatch at runtime (nil = nil is
            // .T.; nil against a payload is .F. under `=` - n1-n3, both
            // directions against string casillas too - hk147; two string
            // casillas compare by content with the prefix rule - hk145;
            // string against integer is a clean named exit 1 mirroring
            // Harbour's BASE/1071 - hk146, registered failure mode).
            if matches!(ta, Ty::Dyn | Ty::I64) && matches!(tb, Ty::Dyn | Ty::I64) {
                return Ok(Ty::Bool);
            }
            if (ta == Ty::Dyn && tb == Ty::Bool) || (ta == Ty::Bool && tb == Ty::Dyn) {
                return Ok(Ty::Bool);
            }
            // Dyn against a string: runtime dispatch on the Dyn tag.
            // `=`/`#`: xBase prefix rule over the right operand's length
            // (hk33/hk37); a NIL casilla is .F./.T. (hk35); a numeric
            // casilla is a clean named exit 1 (hk34/hk38). Ordering:
            // byte-wise over the right operand's length for string
            // casillas (hk36/hk39/hk40/hk43/hk51); NIL or numeric
            // casillas are a clean named exit 1 mirroring Harbour's
            // BASE/1073-1076 error condition (hk41/hk42/hk44-hk50,
            // dialogs that hang headless) - registered failure modes,
            // not exact equivalence.
            if (ta == Ty::Dyn && matches!(tb, Ty::Str | Ty::StrOwn)) || (matches!(ta, Ty::Str | Ty::StrOwn) && tb == Ty::Dyn) {
                return Ok(Ty::Bool);
            }
            if (ta == Ty::Dyn && tb == Ty::F64) || (ta == Ty::F64 && tb == Ty::Dyn) {
                // Covered LIMIT (same reason as arithmetic): a number-
                // holding Dyn compares fine in Harbour; this PoC's Dyn
                // has no float payload tag - named rejection instead of
                // a silent i64 extraction (63zc).
                return Err(format!("line {}: comparing a NIL-able (Dyn) value with a float is a covered LIMIT of this increment (Harbour runs it when the Dyn holds a number; this PoC's Dyn has no float payload - registered divergence)", n));
            }
            if ta != tb {
                return Err(format!("line {}: cannot compare a string with an integer in this PoC", n));
            }
            Err(format!("line {}: comparisons require integers", n))
        }
        Expr::ArrLit(es) => {
            let deep3 = es.iter().any(|e| matches!(e, Expr::ArrLit(inner) if inner.iter().any(|x| matches!(x, Expr::ArrLit(_) | Expr::DArrNew))));
            if deep3 {
                // {{{1,2}},{{3}}}: a DArr3 (oracle pr4). Elements of the
                // innermost arrays are tagged scalars (integer or NIL).
                for e in es {
                    match e {
                        Expr::ArrLit(inner) => {
                            for ie in inner {
                                match ie {
                                    Expr::ArrLit(innermost) => {
                                        for xe in innermost {
                                            if !matches!(type_expr(xe, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                                                return Err(format!("line {}: nested array elements are tagged scalars (integer or NIL)", n));
                                            }
                                        }
                                    }
                                    Expr::DArrNew => {}
                                    _ => return Err(format!("line {}: array elements cannot mix integers and arrays in this increment", n)),
                                }
                            }
                        }
                        Expr::DArrNew => {}
                        _ => return Err(format!("line {}: array elements cannot mix integers and arrays in this increment", n)),
                    }
                }
                return Ok(Ty::DArr3);
            }
            let nested = es.iter().any(|e| matches!(e, Expr::ArrLit(_) | Expr::DArrNew));
            if nested {
                // {{1,2},{3,4}}: a DArr2 - dynamic array of dynamic arrays
                // of i64 (probe m1). Two levels in this increment.
                for e in es {
                    match e {
                        Expr::ArrLit(inner) => {
                            for ie in inner {
                                if !matches!(type_expr(ie, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                                    return Err(format!("line {}: nested array elements are tagged scalars (integer or NIL)", n));
                                }
                            }
                        }
                        Expr::DArrNew => {}
                        _ => return Err(format!("line {}: array elements cannot mix integers and arrays in this increment", n)),
                    }
                }
                return Ok(Ty::DArr2);
            }
            // All-strings literal: a dynamic string array, the same shape as an
        // AAdd-grown string array (33n; oracle hk254). Pure string elements
        // only; a string/integer mix keeps the named rejection below (a
        // mixed Dyn-leaf array is parked new storage).
        if !es.is_empty() && es.iter().all(|e| matches!(e, Expr::Str(_))) { return Ok(Ty::DArrS); }
        let mut has_log = false;
            for e in es {
                let t = type_expr(e, env, sigs, n)?;
                if !matches!(t, Ty::I64 | Ty::Bool) {
                    return Err(format!("line {}: array elements must be integers or logicals in this increment", n));
                }
                if t == Ty::Bool { has_log = true; }
            }
            if has_log && !es.iter().all(|e| matches!(e, Expr::Int(_) | Expr::Log(_))) {
                return Err(format!("line {}: a literal mixing logicals is all literal elements in this increment", n));
            }
            if has_log { Ok(Ty::DArr) } else { Ok(Ty::Arr(es.len())) }
        }
        Expr::IdxCompound(id, ie, _, re) => {
            // a[i] op= e: fixed integer arrays only in this increment
            // (arrayidx contract). The index types as i64; the right
            // side as i64 or Dyn (runtime tag check, like Bin); a float
            // right side cannot be stored in an integer cell until the
            // numeric-cell decision (proposal recorded, not approved).
            let it = type_expr(ie, env, sigs, n)?;
            if it != Ty::I64 {
                return Err(format!("line {}: array index must be an integer", n));
            }
            let rt = type_expr(re, env, sigs, n)?;
            if rt != Ty::I64 && rt != Ty::Dyn {
                return Err(format!("line {}: `a[i] op= e` on an integer array cell takes an integer right side in this increment; a float result cannot be stored until the numeric-cell decision (proposal recorded, not approved)", n));
            }
            match env.iter().find(|v| v.name == *id) {
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                Some(v) if v.ty == Ty::DArr || v.ty == Ty::DArrU || v.ty == Ty::DArrS || v.ty == Ty::Hash => {
                    Err(format!("line {}: `a[i] op= e` covers fixed integer arrays in this increment; dynamic cells and hashes keep their own update paths", n))
                }
                Some(v) if v.ty == Ty::DArr2 || v.ty == Ty::DArr3 || v.ty == Ty::DArr4 => {
                    Err(format!("line {}: `a[i] op= e` covers fixed integer arrays in this increment; nested dynamic arrays stay a named limit", n))
                }
                Some(v) => match v.ty {
                    Ty::Arr(k) => {
                        if let Expr::Int(lit) = ie.as_ref() {
                            let bad = lit.parse::<i64>().map(|x| x < 1 || x > k as i64).unwrap_or(true);
                            if bad {
                                return Err(format!("line {}: array index {} out of bounds (`{}` has {} element(s), base 1)", n, lit, id, k));
                            }
                        }
                        Ok(Ty::I64)
                    }
                    _ => Err(format!("line {}: `a[i] op= e` applies to fixed integer arrays in this increment; `{}` is not one", n, id)),
                },
            }
        }
        Expr::Index(id, ie) => {
            // Arrays are [i64; N] in the Rust model: Copy elements, no
            // moves, no ownership involvement (rustc-verified semantics).
            let it = type_expr(ie, env, sigs, n)?;
            match env.iter().find(|v| v.name == *id) {
                Some(v) if v.ty == Ty::Hash => {
                    // h["k"]: string keys (probes h3b case-sensitive, h12
                    // prefix-distinct); a read borrows and yields the
                    // stored Dyn scalar.
                    if v.moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                    if it != Ty::Str && it != Ty::StrOwn {
                        return Err(format!("line {}: hash keys are strings in this increment", n));
                    }
                    Ok(Ty::Dyn)
                }
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                _ => {
            if it != Ty::I64 && it != Ty::Dyn {
                return Err(format!("line {}: array index must be an integer", n));
            }
            match env.iter().find(|v| v.name == *id) {
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                Some(v) if v.ty == Ty::DArr => {
                    if v.moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                    // Elements are {tag, payload}: a read is a Dyn value
                    // (probes n1/n2: a grown or NIL-stored slot reads NIL).
                    Ok(Ty::Dyn)
                }
                Some(v) if v.ty == Ty::DArrU => {
                    Err(format!("line {}: the element type of `{}` is unknown until its first `AAdd` (pin it first)", n, id))
                }
                Some(v) if v.ty == Ty::DArrS => {
                    if v.moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                    // Reading a key out of an hb_HKeys result COPIES the
                    // string: the reader owns the copy (Ty::StrOwn), so a
                    // later free/move of the array cannot dangle it.
                    Ok(Ty::StrOwn)
                }
                Some(v) if v.ty == Ty::DArr2 => {
                    // a[i] on an array of arrays would EXTRACT the child by
                    // value: rejected in this increment (indexed borrows
                    // only: a[i][j], len(a[i]), AAdd/ASize(a[i], ...)).
                    Err(format!("line {}: cannot extract the subarray `{}[i]` by value in this increment (use a[i][j], len(a[i]) or AAdd/ASize on a[i])", n, id))
                }
                Some(v) if v.ty == Ty::DArr4 => {
                    // Same extraction rejection one level down (hk103).
                    Err(format!("line {}: cannot extract the subarray `{}[i]` by value in this increment (use a[i][j][k][l], len(a[i]) or ValType on it)", n, id))
                }
                Some(v) => match v.ty {
                    Ty::Arr(k) => {
                        if it != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        if let Expr::Int(lit) = ie.as_ref() {
                            let bad = lit.parse::<i64>().map(|x| x < 1 || x > k as i64).unwrap_or(true);
                            if bad {
                                return Err(format!("line {}: array index {} out of bounds (`{}` has {} element(s), base 1)", n, lit, id, k));
                            }
                        }
                        Ok(Ty::I64)
                    }
                    _ => Err(format!("line {}: indexing applies to arrays in this increment; `{}` is not an array", n, id)),
                },
            }
                }
            }
        }
        Expr::Index2(id, ie, ie2) => {
            // a[i][j]: a transient indexed BORROW of the subarray (probe
            // m1). Both indices are integers; the child is never moved out.
            if !matches!(type_expr(ie, env, sigs, n)?, Ty::I64 | Ty::Dyn)
                || !matches!(type_expr(ie2, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                return Err(format!("line {}: array indices must be integers", n));
            }
            match env.iter().find(|v| v.name == *id) {
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                Some(v) if v.moved => Err(format!("line {}: use of moved value `{}`", n, id)),
                Some(v) if v.ty == Ty::DArr2 => Ok(Ty::Dyn),
                Some(v) if v.ty == Ty::DArrU => Err(format!("line {}: the element type of `{}` is unknown until its first `AAdd` (pin it first)", n, id)),
                Some(v) if v.ty == Ty::DArr4 => Err(format!("line {}: cannot extract the subarray `{}[i][j]` by value in this increment (use a[i][j][k][l], len(a[i][j]) or ValType on it)", n, id)),
                Some(_) => Err(format!("line {}: two-level indexing needs an array of arrays; `{}` is not one", n, id)),
            }
        }
        Expr::Index3(id, ie, ie2, ie3) => {
            // a[i][j][k]: three transient indexed borrows then a tagged
            // scalar read (oracle pr4). Child blocks are never moved out.
            if !matches!(type_expr(ie, env, sigs, n)?, Ty::I64 | Ty::Dyn)
                || !matches!(type_expr(ie2, env, sigs, n)?, Ty::I64 | Ty::Dyn)
                || !matches!(type_expr(ie3, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                return Err(format!("line {}: array indices must be integers", n));
            }
            match env.iter().find(|v| v.name == *id) {
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                Some(v) if v.moved => Err(format!("line {}: use of moved value `{}`", n, id)),
                Some(v) if v.ty == Ty::DArr3 => Ok(Ty::Dyn),
                Some(v) if v.ty == Ty::DArr4 => Err(format!("line {}: cannot extract the subarray `{}[i][j][k]` by value in this increment (use a[i][j][k][l], len(a[i][j][k]) or ValType on it)", n, id)),
                Some(_) => Err(format!("line {}: three-level indexing needs an array of arrays of arrays; `{}` is not one", n, id)),
            }
        }
        Expr::Index4(id, ie, ie2, ie3, ie4) => {
            // a[i][j][k][l]: four transient indexed borrows then a tagged
            // scalar read (hk103). Child blocks are never moved out.
            if !matches!(type_expr(ie, env, sigs, n)?, Ty::I64 | Ty::Dyn)
                || !matches!(type_expr(ie2, env, sigs, n)?, Ty::I64 | Ty::Dyn)
                || !matches!(type_expr(ie3, env, sigs, n)?, Ty::I64 | Ty::Dyn)
                || !matches!(type_expr(ie4, env, sigs, n)?, Ty::I64 | Ty::Dyn) {
                return Err(format!("line {}: array indices must be integers", n));
            }
            match env.iter().find(|v| v.name == *id) {
                None => Err(format!("line {}: undefined variable `{}`", n, id)),
                Some(v) if v.moved => Err(format!("line {}: use of moved value `{}`", n, id)),
                Some(v) if v.ty == Ty::DArr4 => Ok(Ty::Dyn),
                Some(_) => Err(format!("line {}: four-level indexing needs an array of arrays of arrays of arrays; `{}` is not one", n, id)),
            }
        }
        Expr::BlockLit(_, params, body) => {
            let prev_block = IN_BLOCK.with(|c| c.replace(true));
            let r = check_block_body(params, body, sigs, n);
            IN_BLOCK.with(|c| c.set(prev_block));
            r
        }
        Expr::SelfObj | Expr::SelfGet(_) | Expr::Send(_, _, _) => {
            Err(format!("line {}: classes are not in this increment yet (parser landed; runtime representation pending)", n))
        }
        Expr::DArrNew => Ok(Ty::DArrU),
        // Hash literal (probes h1/h2/h8/h9): string keys, tagged-scalar
        // values in v1. Duplicate keys in one literal overwrite in place
        // (h8: len stays 1, last value wins); each pair evaluates its key
        // first, then its value (h9) - the opposite of `h[k] := v` (h4).
        Expr::HashLit(ps) => {
            for (k, v) in ps {
                if type_expr(k, env, sigs, n)? != Ty::Str {
                    return Err(format!("line {}: hash keys are strings in this increment", n));
                }
                let vt = type_expr(v, env, sigs, n)?;
                if !matches!(vt, Ty::I64 | Ty::Bool | Ty::Dyn) {
                    return Err(format!("line {}: hash values are tagged scalars (integer, logical or NIL) in this increment", n));
                }
            }
            Ok(Ty::Hash)
        }
    }
}

// Free VARIABLE names used inside an expression (callees are not variables).
// The codeblock body check (Expr::BlockLit arm), extracted so the IN_BLOCK
// guard restores on every path.
fn check_block_body(params: &[String], body: &[Expr], sigs: &mut Vec<Sig>, n: usize) -> Result<Ty, String> {
    // v1: no captures - the body sees ONLY its parameters (probe
    // c3 captures a function local in Harbour; that is the next
    // increment, not this one). Parameters are integers here.
    for e in body {
        let mut found = Vec::new();
        free_vars(e, &mut found);
        for v in found {
            if !params.iter().any(|p| *p == v) {
                return Err(format!("line {}: codeblock captures are not in this increment (`{}` is not a codeblock parameter)", n, v));
            }
        }
    }
    let mut benv: Vec<Local> = params.iter().map(|p| Local { name: p.clone(), ty: Ty::I64, moved: false, ro: false, byref: false }).collect();
    for (i, e) in body.iter().enumerate() {
        let t = type_expr(e, &mut benv, sigs, n)?;
        let discarded_print = i + 1 < body.len() && matches!(e, Expr::Call(id, _) if is_output_call(id));
        if t != Ty::I64 && !discarded_print {
            return Err(format!("line {}: codeblock bodies are integer expressions in this increment", n));
        }
    }
    Ok(Ty::Block(params.len()))
}

fn ty_name(t: Ty) -> &'static str {
    match t {
        Ty::F64 => "a float",
        Ty::I64 => "an integer",
        Ty::RefI64 => "a by-reference integer",
        Ty::RefStrOwn => "a by-reference string",
        Ty::Str => "a string",
        Ty::Bool => "a boolean",
        Ty::DArr3 => "an array of arrays of arrays",
        Ty::DArr4 => "an array of arrays of arrays of arrays",
        Ty::DArrS => "an array of strings",
        Ty::StrOwn => "a string",
        Ty::DArrU => "a dynamic array",
        Ty::DArr2 => "an array of arrays",
        Ty::Arr(_) => "an array",
        Ty::Block(_) => "a codeblock",
        Ty::DArr => "a dynamic array",
        Ty::DArrRef => "a borrowed array",
        Ty::DArrRef2 => "a borrowed array",
        Ty::Dyn => "a dynamic value",
        Ty::Hash => "a hash",
    }
}

fn free_vars(e: &Expr, out: &mut Vec<String>) {
    match e {
        Expr::Seq(es) => { for e in es { free_vars(e, out); } }
        Expr::Var(id) | Expr::Inc(id, _, _) => { if !out.iter().any(|x| x == id) { out.push(id.clone()); } }
        Expr::SelfObj | Expr::SelfGet(_) => {}
        Expr::Send(o, _, args) => { free_vars(o, out); for a in args { free_vars(a, out); } }
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) | Expr::LAnd(a, b) | Expr::LOr(a, b) => { free_vars(a, out); free_vars(b, out); }
        Expr::LNot(a) => free_vars(a, out),
        Expr::Call(_, args) => { for a in args { free_vars(a, out); } }
        Expr::ArrLit(es) => { for e in es { free_vars(e, out); } }
        Expr::Index(_, ie) => free_vars(ie, out),
        Expr::IdxCompound(_, ie, _, re) => { free_vars(ie, out); free_vars(re, out); }
        Expr::Index2(_, ie, ie2) => { free_vars(ie, out); free_vars(ie2, out); }
        Expr::Index3(_, ie, ie2, ie3) => { free_vars(ie, out); free_vars(ie2, out); free_vars(ie3, out); }
        Expr::Index4(_, ie, ie2, ie3, ie4) => { free_vars(ie, out); free_vars(ie2, out); free_vars(ie3, out); free_vars(ie4, out); }
        Expr::HashLit(ps) => { for (k, v) in ps { free_vars(k, out); free_vars(v, out); } }
        Expr::BlockLit(_, _, _) => {} // nested blocks: rejected by the integer-body rule
        _ => {}
    }
}

// Recursive statement checker: types + ownership/move tracking, including
// branch joining for `if`. Rust-like rule: a value moved on ANY reachable
// path counts as moved at the join (union of moved flags); a local declared
// inside a branch is scoped to that branch (sibling branches may reuse a
// name). This pass is OURS; nothing is delegated to another compiler.
// Returns whether the block can fall through to its end (false when every
// path exits via return / exit / loop). `loop_pre` is Some(moved flags of
// the outer env captured before the innermost `while`) inside a loop body;
// `exits` collects the outer-env moved flags at each `exit` of that loop.
// Does this statement list contain a `return <expr>` anywhere (nested
// blocks included)? Used to keep main value-free: main's own `return nil`
// returns NIL like any function (probe n1c) but must not yield a value.
fn has_value_return(stmts: &[Stmt]) -> bool {
    stmts.iter().any(|s| match s {
        Stmt::Ret(_, Some(_)) => true,
        Stmt::If(_, _, t, e) => has_value_return(t) || has_value_return(e),
        Stmt::While(_, _, b) => has_value_return(b),
        Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => has_value_return(b),
        _ => false,
    })
}

// Pre-scan: which locals can ever hold a Dyn (NIL-capable) value? Seeds:
// a NIL literal, a dynamic-array element read, or a call to a Dyn-returning
// function on the RHS of any local/assign; propagation through plain Var
// copies to a fixpoint (probe n2: a variable is re-tagged live, so the
// width must be known before the frame is laid out). Params pinned Dyn by
// the pin pass seed the set too. Only I64 declarations widen; strings,
// arrays and codeblocks never change type.
fn prescan_dyn(f: &Func, sigs: &[Sig], ptys: &[Ty]) -> std::collections::HashSet<String> {
    use std::collections::HashSet;
    let mut dyn_names: HashSet<String> = HashSet::new();
    let mut darr_names: HashSet<String> = HashSet::new();
    for (i, p) in f.params.iter().enumerate() {
        if ptys[i] == Ty::Dyn { dyn_names.insert(p.clone()); }
        if matches!(ptys[i], Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4) { darr_names.insert(p.clone()); }
    }
    // dynamic arrays declared in the body ({} or a nested literal)
    fn scan_darr(stmts: &[Stmt], darr: &mut HashSet<String>) {
        for st in stmts {
            match st {
                Stmt::Local(_, id, Expr::DArrNew) => { darr.insert(id.clone()); }
                Stmt::Local(_, id, Expr::ArrLit(es)) if es.iter().any(|e| matches!(e, Expr::ArrLit(_) | Expr::DArrNew)) => { darr.insert(id.clone()); }
                Stmt::If(_, _, t, e) => { scan_darr(t, darr); scan_darr(e, darr); }
                Stmt::While(_, _, b) => scan_darr(b, darr),
                Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => scan_darr(b, darr),
                _ => {}
            }
        }
    }
    scan_darr(&f.stmts, &mut darr_names);
    // assignments/local inits as (name, expr) pairs, flattened
    fn collect<'a>(stmts: &'a [Stmt], out: &mut Vec<(&'a String, &'a Expr)>) {
        for st in stmts {
            match st {
                Stmt::Local(_, id, e) | Stmt::Assign(_, id, e) => out.push((id, e)),
                Stmt::If(_, _, t, e) => { collect(t, out); collect(e, out); }
                Stmt::While(_, _, b) => collect(b, out),
                Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => collect(b, out),
                _ => {}
            }
        }
    }
    let mut pairs: Vec<(&String, &Expr)> = Vec::new();
    collect(&f.stmts, &mut pairs);
    let may_be_dyn = |e: &Expr, dyn_names: &HashSet<String>, darr: &HashSet<String>| -> bool {
        match e {
            Expr::Nil => true,
            Expr::Index(id, _) | Expr::Index2(id, _, _) => darr.contains(id),
            Expr::Var(v) => dyn_names.contains(v),
            Expr::Call(id, _) if !is_builtin(id, "len") && !is_builtin(id, "eval") && !is_builtin(id, "hb_memcheck") => {
                sigs.iter().find(|s| s.name == *id).map(|s| s.ret == Some(Ty::Dyn)).unwrap_or(false)
            }
            _ => false,
        }
    };
    loop {
        let before = dyn_names.len();
        for (name, e) in &pairs {
            if may_be_dyn(e, &dyn_names, &darr_names) {
                dyn_names.insert((*name).clone());
            }
        }
        if dyn_names.len() == before { break; }
    }
    dyn_names
}

// Return-type unification (probe n2): an i64 return and a NIL return in
// the same function unify to Dyn ({tag,payload}); Harbour's mixed returns
// are supported, not registered as a static-model difference.
fn unify_ret(ret: Option<Ty>, t: Ty, n: usize) -> Result<Ty, String> {
    match (ret, t) {
        (None, t) => Ok(t),
        (Some(p), t) if p == t => Ok(t),
        (Some(Ty::I64), Ty::Dyn) | (Some(Ty::Dyn), Ty::I64) => Ok(Ty::Dyn),
        // A rodata string and an owned string unify to owned (the caller
        // always owns the result; a rodata return point emits a copy).
        (Some(Ty::Str), Ty::StrOwn) | (Some(Ty::StrOwn), Ty::Str) => Ok(Ty::StrOwn),
        (Some(p), _) => Err(format!("line {}: return type mismatch (this function already returns {:?} elsewhere; all returns must agree)", n, p)),
    }
}

// The FOR EACH collection is BORROWED for the whole loop: any body
// statement that reassigns it, sets its elements, moves it (checked via
// the moved flag) or grows it through the mutating builtins would
// invalidate the borrowed (pointer, count) pair - a reallocation leaves
// it dangling. This increment rejects all of them (registered
// limitation; Harbour's own docs advise against mutating while
// iterating).
fn foreach_coll_untouched(stmts: &[Stmt], name: &str) -> bool {
    fn expr_ok(e: &Expr, name: &str) -> bool {
        match e {
            Expr::Seq(es) => es.iter().all(|e| expr_ok(e, name)),
            Expr::Call(id, args) => {
                if (is_builtin(id, "AAdd") || is_builtin(id, "ASize"))
                    && matches!(args.first(), Some(Expr::Var(v)) if v == name)
                {
                    return false;
                }
                // Passing a[i] of the loop's root to a user function hands
                // the callee a borrow it may grow through: the current
                // element's Dyn view could dangle. Rejected like the
                // direct mutations above (safe named rejection).
                if !is_builtin(id, "len") && !is_builtin(id, "valtype")
                    && args.iter().any(|a| matches!(a, Expr::Index(r, _) | Expr::Index2(r, _, _) | Expr::Index3(r, _, _, _) | Expr::Index4(r, ..) if r == name))
                {
                    return false;
                }
                args.iter().all(|a| expr_ok(a, name))
            }
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => expr_ok(a, name) && expr_ok(b, name),
            Expr::IdxCompound(id, ie, _, re) => id != name && expr_ok(ie, name) && expr_ok(re, name),
            _ => true,
        }
    }
    stmts.iter().all(|s| match s {
        Stmt::Assign(_, id, e) => id != name && expr_ok(e, name),
        Stmt::ArrSet(_, id, ie, e) | Stmt::ArrSet2(_, id, ie, e, _) | Stmt::ArrSet3(_, id, ie, e, _, _) | Stmt::ArrSet4(_, id, ie, e, ..) => id != name && expr_ok(ie, name) && expr_ok(e, name),
        Stmt::AAdd(_, id, _) | Stmt::ASize(_, id, _) | Stmt::AAddSub(_, id, _, _) | Stmt::ASizeSub(_, id, _, _) | Stmt::AAddSub2(_, id, _, _, _) | Stmt::ASizeSub2(_, id, _, _, _) | Stmt::AAddSub3(_, id, ..) | Stmt::ASizeSub3(_, id, ..) => id != name,
        Stmt::SendStmt(_, e) => expr_ok(e, name),
        Stmt::If(_, c, a, b) => expr_ok(c, name) && foreach_coll_untouched(a, name) && foreach_coll_untouched(b, name),
        Stmt::While(_, c, b) => expr_ok(c, name) && foreach_coll_untouched(b, name),
        Stmt::For(_, _, a, b, _, body) => expr_ok(a, name) && expr_ok(b, name) && foreach_coll_untouched(body, name),
        Stmt::ForEach(_, _, c, body) => expr_ok(c, name) && foreach_coll_untouched(body, name),
        Stmt::Print(_, items, _) => items.iter().all(|i| expr_ok(i, name)),
        Stmt::Ret(_, Some(e)) => expr_ok(e, name),
        Stmt::CallStmt(_, e) => expr_ok(e, name),
        _ => true,
    })
}

// The FOR EACH loop variable is a Dyn view of the CURRENT ELEMENT: a
// tag-2 payload is a pointer INTO the borrowed collection, owned by it.
// That pointer must not escape the body: returning it (the collection is
// freed at the epilogue), copying it to another local (survives the
// iteration), passing it to a function or storing it into a collection
// would all leave a dangling or doubly-owned pointer. Dyn owns nothing
// anywhere in this PoC, so nobody ever copies or frees such a payload -
// this increment allows the variable only in reads that consume it
// immediately: print items, comparisons, arithmetic. Everything else is
// a named compile error (registered limitation).
// Validator for the borrowed-ARRAY `for each` loop variable
// (hk118/hk119): x may be indexed and read (x[j]), written through
// (x[j] := v), and measured (len(x), ValType(x)); it may not be
// assigned, returned, passed to a function, grown or shrunk.
fn foreach_barr_lv_ok(stmts: &[Stmt], name: &str) -> bool {
    fn mentions(e: &Expr, name: &str) -> bool {
        match e {
            Expr::Seq(es) => es.iter().any(|e| mentions(e, name)),
            Expr::Var(v) => v == name,
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => mentions(a, name) || mentions(b, name),
            Expr::Call(_, args) => args.iter().any(|a| mentions(a, name)),
            Expr::Index(id, i) | Expr::Index2(id, i, _) | Expr::Index3(id, i, _, _) | Expr::Index4(id, i, ..) => id == name || mentions(i, name),
            Expr::IdxCompound(id, i, _, r) => id == name || mentions(i, name) || mentions(r, name),
            _ => false,
        }
    }
    // A print item may READ the borrowed array: an element read x[j],
    // len(x) or ValType(x) - never the whole array and never x as a
    // call argument.
    fn print_ok(e: &Expr, name: &str) -> bool {
        match e {
            Expr::Index(id, ie) if id == name => !mentions(ie, name),
            Expr::Call(f, args)
                if (is_builtin(f, "valtype") || is_builtin(f, "len"))
                    && args.len() == 1
                    && matches!(&args[0], Expr::Var(v) if v == name) =>
            {
                true
            }
            _ => !mentions(e, name),
        }
    }
    stmts.iter().all(|s| match s {
        Stmt::Print(_, items, _) => items.iter().all(|i| print_ok(i, name)),
        Stmt::Assign(_, _, e) | Stmt::Ret(_, Some(e)) => !mentions(e, name),
        Stmt::CallStmt(_, e) => !mentions(e, name),
        Stmt::ArrSet(_, _, ie, e) => !mentions(ie, name) && !mentions(e, name),
        Stmt::ArrSet2(_, _, i1, i2, e) => !mentions(i1, name) && !mentions(i2, name) && !mentions(e, name),
        Stmt::ArrSet3(_, _, i1, i2, i3, e) => !mentions(i1, name) && !mentions(i2, name) && !mentions(i3, name) && !mentions(e, name),
        Stmt::ArrSet4(_, _, i1, i2, i3, i4, e) => !mentions(i1, name) && !mentions(i2, name) && !mentions(i3, name) && !mentions(i4, name) && !mentions(e, name),
        Stmt::AAdd(_, id, e) | Stmt::ASize(_, id, e) => id != name && !mentions(e, name),
        Stmt::AAddSub(_, id, i, e) | Stmt::ASizeSub(_, id, i, e) => id != name && !mentions(i, name) && !mentions(e, name),
        Stmt::AAddSub2(_, id, i, j, e) | Stmt::ASizeSub2(_, id, i, j, e) => id != name && !mentions(i, name) && !mentions(j, name) && !mentions(e, name),
        Stmt::AAddSub3(_, id, i, j, k, e) | Stmt::ASizeSub3(_, id, i, j, k, e) => id != name && !mentions(i, name) && !mentions(j, name) && !mentions(k, name) && !mentions(e, name),
        Stmt::Local(_, _, e) => !mentions(e, name),
        Stmt::If(_, _, a, b) => foreach_barr_lv_ok(a, name) && foreach_barr_lv_ok(b, name),
        Stmt::While(_, _, b) => foreach_barr_lv_ok(b, name),
        Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => foreach_barr_lv_ok(b, name),
        _ => true,
    })
}

fn foreach_lv_readonly(stmts: &[Stmt], name: &str) -> bool {
    fn mentions(e: &Expr, name: &str) -> bool {
        match e {
            Expr::Seq(es) => es.iter().any(|e| mentions(e, name)),
            Expr::Var(v) => v == name,
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => mentions(a, name) || mentions(b, name),
            Expr::Call(_, args) => args.iter().any(|a| mentions(a, name)),
            Expr::Index(id, i) | Expr::Index2(id, i, _) | Expr::Index3(id, i, _, _) | Expr::Index4(id, i, ..) => id == name || mentions(i, name),
            Expr::IdxCompound(id, i, _, r) => id == name || mentions(i, name) || mentions(r, name),
            _ => false,
        }
    }
    fn in_call(e: &Expr, name: &str) -> bool {
        match e {
            Expr::Seq(es) => es.iter().any(|e| in_call(e, name)),
            Expr::Call(_, args) => args.iter().any(|a| mentions(a, name)),
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => in_call(a, name) || in_call(b, name),
            Expr::Index(_, i) | Expr::Index2(_, i, _) | Expr::Index3(_, i, _, _) | Expr::Index4(_, i, ..) => in_call(i, name),
            _ => false,
        }
    }
    stmts.iter().all(|s| match s {
        Stmt::Print(_, items, _) => items.iter().all(|i| !in_call(i, name)),
        Stmt::Assign(_, _, e) | Stmt::Ret(_, Some(e)) => !mentions(e, name),
        Stmt::CallStmt(_, e) => !mentions(e, name),
        Stmt::ArrSet(_, _, ie, e) => !mentions(ie, name) && !mentions(e, name),
        Stmt::ArrSet2(_, _, i1, i2, e) => !mentions(i1, name) && !mentions(i2, name) && !mentions(e, name),
        Stmt::ArrSet3(_, _, i1, i2, i3, e) => !mentions(i1, name) && !mentions(i2, name) && !mentions(i3, name) && !mentions(e, name),
        Stmt::ArrSet4(_, _, i1, i2, i3, i4, e) => !mentions(i1, name) && !mentions(i2, name) && !mentions(i3, name) && !mentions(i4, name) && !mentions(e, name),
        Stmt::AAdd(_, _, e) | Stmt::ASize(_, _, e) => !mentions(e, name),
        Stmt::AAddSub(_, _, i, e) | Stmt::ASizeSub(_, _, i, e) => !mentions(i, name) && !mentions(e, name),
        Stmt::AAddSub2(_, _, i, j, e) | Stmt::ASizeSub2(_, _, i, j, e) => !mentions(i, name) && !mentions(j, name) && !mentions(e, name),
        Stmt::AAddSub3(_, _, i, j, k, e) | Stmt::ASizeSub3(_, _, i, j, k, e) => !mentions(i, name) && !mentions(j, name) && !mentions(k, name) && !mentions(e, name),
        Stmt::Local(_, _, e) => !mentions(e, name),
        Stmt::If(_, _, a, b) => foreach_lv_readonly(a, name) && foreach_lv_readonly(b, name),
        Stmt::While(_, _, b) => foreach_lv_readonly(b, name),
        Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => foreach_lv_readonly(b, name),
        _ => true,
    })
}

// Bare `local i` (or `local i := NIL`) whose FIRST mention in the same
// block is the counter of a top-level `for i := start to end`: Harbour
// reuses the visible variable (oracle hk336; natural exit leaves the
// counter one step past the bound), and the NIL it holds between the
// LOCAL and the FOR is unobservable because nothing reads it there. This
// PoC types such a slot i64 from declaration. Any read, write, call
// argument, nested use, or a start/end expression mentioning the name
// before the FOR keeps the Dyn slot and the named `for` rejection: a
// covered limit of this increment, not a Harbour rule. Checker, layout
// and codegen must agree, so all three call this one pure predicate.
fn bare_local_is_for_counter(stmts: &[Stmt], idx: usize, name: &str) -> bool {
    for s in &stmts[idx + 1..] {
        match s {
            Stmt::For(_, lv, start, end, _, _) if lv == name => {
                return !expr_mentions(start, name) && !expr_mentions(end, name);
            }
            _ => {
                if stmt_mentions(s, name) {
                    return false;
                }
            }
        }
    }
    false
}

fn stmts_mention(stmts: &[Stmt], name: &str) -> bool {
    stmts.iter().any(|s| stmt_mentions(s, name))
}

fn stmt_mentions(s: &Stmt, name: &str) -> bool {
    match s {
        Stmt::Local(_, id, e) => id == name || expr_mentions(e, name),
        Stmt::Print(_, items, _) => items.iter().any(|e| expr_mentions(e, name)),
        Stmt::Ret(_, Some(e)) => expr_mentions(e, name),
        Stmt::Ret(_, None) | Stmt::Exit(_) | Stmt::Loop(_) => false,
        Stmt::If(_, c, a, b) => {
            expr_mentions(c, name) || stmts_mention(a, name) || stmts_mention(b, name)
        }
        Stmt::While(_, c, b) => expr_mentions(c, name) || stmts_mention(b, name),
        Stmt::Assign(_, id, e) => id == name || expr_mentions(e, name),
        Stmt::HDel(_, id, e) | Stmt::HDelAt(_, id, e) | Stmt::HFill(_, id, e) => {
            id == name || expr_mentions(e, name)
        }
        Stmt::HClear(_, id) => id == name,
        Stmt::HMerge(_, a, b) => a == name || b == name,
        Stmt::HCopy(_, a, b, start, count) => {
            a == name
                || b == name
                || start.as_ref().map_or(false, |e| expr_mentions(e, name))
                || count.as_ref().map_or(false, |e| expr_mentions(e, name))
        }
        Stmt::HSet(_, id, k, v) => {
            id == name || expr_mentions(k, name) || expr_mentions(v, name)
        }
        Stmt::HSetCaseMatch(_, id, f) => id == name || expr_mentions(f, name),
        Stmt::ArrSet(_, id, i, e) => {
            id == name || expr_mentions(i, name) || expr_mentions(e, name)
        }
        Stmt::ArrSet2(_, id, i, j, e) => {
            id == name
                || expr_mentions(i, name)
                || expr_mentions(j, name)
                || expr_mentions(e, name)
        }
        Stmt::ArrSet3(_, id, i, j, k, e) => {
            id == name
                || expr_mentions(i, name)
                || expr_mentions(j, name)
                || expr_mentions(k, name)
                || expr_mentions(e, name)
        }
        Stmt::ArrSet4(_, id, i, j, k, l, e) => {
            id == name
                || expr_mentions(i, name)
                || expr_mentions(j, name)
                || expr_mentions(k, name)
                || expr_mentions(l, name)
                || expr_mentions(e, name)
        }
        Stmt::SelfSet(_, _, e) => expr_mentions(e, name),
        Stmt::SendSet(_, r, _, e) => expr_mentions(r, name) || expr_mentions(e, name),
        Stmt::SendStmt(_, e) | Stmt::CallStmt(_, e) => expr_mentions(e, name),
        Stmt::AAdd(_, id, e) | Stmt::ASize(_, id, e) => id == name || expr_mentions(e, name),
        Stmt::AAddSub(_, id, i, e) | Stmt::ASizeSub(_, id, i, e) => {
            id == name || expr_mentions(i, name) || expr_mentions(e, name)
        }
        Stmt::AAddSub2(_, id, i, j, e) | Stmt::ASizeSub2(_, id, i, j, e) => {
            id == name
                || expr_mentions(i, name)
                || expr_mentions(j, name)
                || expr_mentions(e, name)
        }
        Stmt::AAddSub3(_, id, i, j, k, e) | Stmt::ASizeSub3(_, id, i, j, k, e) => {
            id == name
                || expr_mentions(i, name)
                || expr_mentions(j, name)
                || expr_mentions(k, name)
                || expr_mentions(e, name)
        }
        Stmt::For(_, lv, a, b, _, body) => {
            lv == name
                || expr_mentions(a, name)
                || expr_mentions(b, name)
                || stmts_mention(body, name)
        }
        Stmt::ForEach(_, lv, c, body) => {
            lv == name || expr_mentions(c, name) || stmts_mention(body, name)
        }
    }
}

fn check_stmts(stmts: &[Stmt], env: &mut Vec<Local>, sigs: &mut Vec<Sig>, ret: &mut Option<Ty>, loop_pre: Option<&Vec<bool>>, exits: &mut Vec<Vec<bool>>, dyn_names: &std::collections::HashSet<String>, byref_names: &std::collections::HashSet<String>) -> Result<bool, String> {
    let mut falls = true;
    for (si, s) in stmts.iter().enumerate() {
        match s {
            Stmt::SelfSet(n, _, _) | Stmt::SendSet(n, _, _, _) | Stmt::SendStmt(n, _) => {
                return Err(format!("line {}: classes are not in this increment yet (parser landed; runtime representation pending)", n));
            }
            Stmt::CallStmt(n, e) => {
                if matches!(e, Expr::Var(_)) {
                    type_expr(e, env, sigs, *n)?;
                    continue; // parenthesized variable: borrow for a read
                }
                // Bare call (hk216): runs for effect; the return is
                // DISCARDED. Discarding is defined only for returns the
                // established discipline can release: no value, scalars
                // (Copy), a Dyn (owns nothing anywhere in this PoC), one
                // owned string, or an owned array of up to two levels
                // (all freed right after the call with the same helpers
                // the epilogue uses; oracle hk256). Hashes, deeper arrays
                // and codeblocks stay a named rejection here.
                CALL_STMT_CTX.with(|c| c.set(true));
                let t = type_expr(e, env, sigs, *n);
                CALL_STMT_CTX.with(|c| c.set(false));
                match t? {
                    Ty::I64 | Ty::Str | Ty::Bool | Ty::StrOwn | Ty::Dyn | Ty::DArr | Ty::DArrS | Ty::DArr2 | Ty::F64 => {}
                    other => return Err(format!("line {}: discarding {} return is not in this increment", n, ty_name(other))),
                }
                apply_moves(e, env, sigs, true);
            }
            Stmt::Local(n, id, e) => {
                if env.iter().any(|v| v.name == *id) {
                    return Err(format!("line {}: duplicate local `{}`", n, id));
                }
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::Bool && dyn_names.contains(id) {
                    return Err(format!("line {}: dynamic logical cells are not in this increment (tag-L Dyn cells land separately)", n));
                }
                if let Expr::Var(v) = e {
                    if let Some(x) = env.iter().find(|x| x.name == *v && x.byref && matches!(x.ty, Ty::Str | Ty::StrOwn)) {
                        return Err(format!("line {}: initializing from borrowed parameter `{}` moves it out of its owner - not Harbour semantics; derive a value instead (for example a concatenation)", n, v));
                    }
                }
                apply_moves(e, env, sigs, true);
                let t = if t == Ty::I64 && dyn_names.contains(id) { Ty::Dyn } else { t };
                // A local passed as `@s` anywhere in this function needs an
                // owned-capable slot from the start: the callee frees and
                // re-stores through the pointer (hk218).
                let t = if t == Ty::Str && byref_names.contains(id) { Ty::StrOwn } else { t };
                // Bare-local FOR counter (oracle hk336): the slot types
                // i64 from declaration via the one shared predicate;
                // every other shape keeps Dyn and the named `for`
                // rejection.
                let t = if t == Ty::Dyn
                    && matches!(e, Expr::Nil)
                    && !byref_names.contains(id)
                    && bare_local_is_for_counter(stmts, si, id)
                {
                    Ty::I64
                } else {
                    t
                };
                env.push(Local { name: id.clone(), ty: t, moved: false, ro: false, byref: false });
            }
            Stmt::Print(n, es, _) => {
                // Printing borrows the value; it never moves it.
                for e in es {
                    // `? a[i]` on an array of arrays is allowed: a
                    // NIL-grown casilla prints NIL (oracle n1) and a live
                    // child prints nothing (oracle n5) - the dispatch is
                    // at runtime, so the static type stays opaque here.
                    if let Expr::Index(v, ie) = e {
                        if let Some(var) = env.iter().find(|x| x.name == *v && x.ty == Ty::DArr2) {
                            let _ = var;
                            if type_expr(ie, env, sigs, *n)? != Ty::I64 && !matches!(type_expr(ie, env, sigs, *n)?, Ty::Dyn) {
                                return Err(format!("line {}: array index must be an integer", n));
                            }
                            continue;
                        }
                    }
                    let t = type_expr(e, env, sigs, *n)?;
                    if let Ty::Block(_) = t {
                        return Err(format!("line {}: cannot print a codeblock in this increment", n));
                    }
                    if matches!(t, Ty::Arr(_) | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Hash) {
                        // Whole dynamic arrays and hashes print EMPTY in
                        // Harbour (oracles hk16/hk20/hk21/hk24: QOut
                        // renders an array or hash value as nothing) and
                        // the variable stays alive afterwards (hk23), so
                        // the item is a plain borrow. This increment
                        // accepts only a variable in this position:
                        // printing a temporary (literal, call result) is
                        // a registered PoC limitation.
                        if !matches!(e, Expr::Var(_)) {
                            return Err(format!("line {}: cannot print a temporary array or hash directly in this increment (assign it to a variable and print the variable)", n));
                        }
                    }
                    // Printing the RESULT borrows it (moving=false at the
                    // root), but a call INSIDE the item moves the arguments
                    // the callee owns - this arm must apply moves like any
                    // other statement, or `? consume(a)` would leave `a`
                    // usable after the callee took it (hole caught by the
                    // pr9 mirror: 2-level arrays had it too).
                    apply_moves(e, env, sigs, false);
                }
            }
            Stmt::Ret(n, Some(e)) => {
                let t = type_expr(e, env, sigs, *n)?;
                if t == Ty::F64 {
                    // Float return (63zd): the caller receives a COPY of
                    // the {value, metadata} pair - scalars own nothing
                    // (oracles hk302-hk306). A float return must agree
                    // with every other return of the function: mixed
                    // int/float returns stay a named rejection through
                    // unify_ret - Harbour's item KIND varies per path
                    // there and arithmetic on the result differs beyond
                    // the measured dec-0 byte shape (oracle hk312).
                    *ret = Some(unify_ret(*ret, Ty::F64, *n)?);
                    falls = false;
                } else if let Ty::Arr(_) = t {
                    // Returning a static array materializes a dynamic
                    // COPY the caller owns (33m). Oracle hk99: Harbour's
                    // local array survives the return and the caller gets
                    // a fully working array; a fresh owner matches that
                    // observably for the measured non-aliasing shape.
                    // Only a variable return this increment.
                    if !matches!(e, Expr::Var(_)) {
                        return Err(format!("line {}: a static array return is a variable in this increment", n));
                    }
                    apply_moves(e, env, sigs, false);
                    *ret = Some(unify_ret(*ret, Ty::DArr, *n)?);
                    falls = false;
                } else
                {
                if let Ty::Block(_) = t {
                    return Err(format!("line {}: codeblocks cannot be returned in this increment", n));
                }

                if t == Ty::DArrU {
                    return Err(format!("line {}: cannot return an empty array whose element type was never pinned by `AAdd`", n));
                }
                // Returning a borrowed parameter is a value COPY (hk237):
                // Harbour hands the caller the string value while the
                // owner's variable keeps it; codegen copies through the
                // pointer. Scalars copy by the same rule (hk236).
                apply_moves(e, env, sigs, true);
                *ret = Some(unify_ret(*ret, t, *n)?);
                falls = false;
                }
            }
            Stmt::Ret(n, None) => {
                // `return` / `return nil` return NIL (probe n1c): the Dyn
                // value {tag=1}. Mixed `return 5` / `return nil` unifies to
                // a Dyn return (probe n2) - Harbour behaviour, not a
                // registered difference.
                *ret = Some(unify_ret(*ret, Ty::Dyn, *n)?);
                falls = false;
            }
            Stmt::If(n, cond, then_s, else_s) => {
                let ct = type_expr(cond, env, sigs, *n)?;
                apply_moves(cond, env, sigs, false);
                if !matches!(ct, Ty::Bool | Ty::Dyn) {
                    return Err(format!("line {}: `if` needs a comparison (e.g. `if x >= 1`); a bare value is not a condition in this PoC", n));
                }
                let outer = env.len();
                let mut env_then = env.clone();
                let ft = check_stmts(then_s, &mut env_then, sigs, ret, loop_pre, exits, dyn_names, byref_names)?;
                let mut env_else = env.clone();
                let fe = check_stmts(else_s, &mut env_else, sigs, ret, loop_pre, exits, dyn_names, byref_names)?;
                for k in 0..outer {
                    env[k].moved = env_then[k].moved || env_else[k].moved;
                }
                falls = ft || fe;
            }
            Stmt::While(n, cond, body) => {
                let ct = type_expr(cond, env, sigs, *n)?;
                apply_moves(cond, env, sigs, false);
                if !matches!(ct, Ty::Bool | Ty::Dyn) {
                    return Err(format!("line {}: `while` needs a comparison (e.g. `while x >= 1`); a bare value is not a condition in this PoC", n));
                }
                let outer = env.len();
                let pre: Vec<bool> = env.iter().map(|v| v.moved).collect();
                let mut env_body = env.clone();
                let mut wexits: Vec<Vec<bool>> = Vec::new();
                let fb = check_stmts(body, &mut env_body, sigs, ret, Some(&pre), &mut wexits, dyn_names, byref_names)?;
                // A variable moved on a path that reaches the next
                // iteration must be live again there (Rust's loop rule).
                if fb {
                    for k in 0..outer {
                        if !pre[k] && env_body[k].moved {
                            return Err(format!("line {}: `{}` is moved inside the `while` body and not reassigned before `enddo` (the next iteration would use a moved value)", n, env[k].name));
                        }
                    }
                }
                // Post-loop state: the body may run zero times, may fall
                // through, and may leave via any `exit` - join them all.
                for k in 0..outer {
                    env[k].moved = pre[k] || (fb && env_body[k].moved) || wexits.iter().any(|xs| xs[k]);
                    // Element-type pinning is monotonic: an AAdd inside the
                    // body pins the outer variable for every later use too
                    // (the body ran at least... may run zero times - but a
                    // pin only NARROWS the unknown element type, so joining
                    // it forward is sound: unpinned loops still reject at
                    // the use site if the body never pins).
                    if env[k].ty == Ty::DArrU && matches!(env_body[k].ty, Ty::DArr | Ty::DArr2) {
                        env[k].ty = env_body[k].ty;
                    }
                }
            }
            Stmt::For(n, var, start, end, _step, body) => {
                let ts = type_expr(start, env, sigs, *n)?;
                let te = type_expr(end, env, sigs, *n)?;
                apply_moves(start, env, sigs, false);
                apply_moves(end, env, sigs, false);
                if ts != Ty::I64 || te != Ty::I64 {
                    return Err(format!("line {}: `for` bounds must be integers", n));
                }
                // Harbour REUSES a visible integer variable as the loop
                // counter (oracle hk323 / exit.prg: `for x := 1 to 5`
                // over an outer `x` leaves x at 5, no shadowing). A
                // non-integer or read-only slot keeps a named rejection.
                let reuse = if let Some(pos) = env.iter().position(|v| v.name == *var) {
                    if env[pos].ty != Ty::I64 || env[pos].ro {
                        return Err(format!("line {}: `for` loop variable `{}` reuses a non-integer or read-only slot in this PoC", n, var));
                    }
                    true
                } else { false };
                if !reuse {
                    env.push(Local { name: var.clone(), ty: Ty::I64, moved: false, ro: true, byref: false });
                }
                let outer = env.len();
                let pre: Vec<bool> = env.iter().map(|v| v.moved).collect();
                let mut env_body = env.clone();
                let mut fexits: Vec<Vec<bool>> = Vec::new();
                let fb = check_stmts(body, &mut env_body, sigs, ret, Some(&pre), &mut fexits, dyn_names, byref_names)?;
                if fb {
                    for k in 0..outer {
                        if !pre[k] && env_body[k].moved {
                            return Err(format!("line {}: `{}` is moved inside the `for` body and not reassigned before `next` (the next iteration would use a moved value)", n, env[k].name));
                        }
                    }
                }
                for k in 0..outer {
                    env[k].moved = pre[k] || (fb && env_body[k].moved) || fexits.iter().any(|xs| xs[k]);
                    if env[k].ty == Ty::DArrU && matches!(env_body[k].ty, Ty::DArr | Ty::DArr2) {
                        env[k].ty = env_body[k].ty;
                    }
                }
                env.truncate(if reuse { outer } else { outer - 1 });
            }
            Stmt::ForEach(n, var, coll, body) => {
                // FOR EACH (oracles hk17-hk32): the collection is a
                // VARIABLE, borrowed for the loop and alive afterwards
                // (hk26). The loop variable must already exist - Harbour
                // errors BASE/1003 on an undeclared one - and inside the
                // body it is the CURRENT ELEMENT as a Dyn: i64/NIL for
                // flat arrays (hk26/hk30), string-or-NIL for key arrays
                // (hk17/hk27), value-or-NIL for hashes (hk18/hk31). The
                // outer value is RESTORED after the loop, naturally or
                // via `exit` (hk28/hk29): the outer slot is never
                // touched. Assigning to it is rejected (ro): Harbour
                // writes THROUGH to the element (hk32), a borrow of a
                // mutable cell this increment does not implement -
                // registered limitation.
                apply_moves(coll, env, sigs, false);
                // A nested collection a[i] whose root is an array of
                // arrays is BORROWED from the root owner for the loop
                // (hk53/hk54): the index expression is evaluated once,
                // bounds-checked, and a NIL casilla (a null child)
                // raises Harbour's BASE/1068 condition (hk58) - a clean
                // named exit 1, registered failure mode. The root
                // cannot be mutated, moved or grown inside the body
                // (that covers reseating a[i] and growing the borrowed
                // child, which could reallocate the borrowed cells).
                let sub = matches!(coll, Expr::Index(id, _) if matches!(env.iter().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr2)));
                // Depth 3 (hk60-hk64): a[i][j] on an array of arrays of
                // arrays borrows the innermost child the same way; both
                // index expressions evaluate once, each level is
                // bounds-checked, and a NIL casilla at either level is
                // the BASE/1068 failure mode.
                let sub2 = matches!(coll, Expr::Index2(id, _, _) if matches!(env.iter().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr3)));
                // Depth 4 (hk109/hk110): a[i][j][k] on an array of four
                // levels borrows the level-3 child the same way; the
                // three index expressions evaluate once, left to right,
                // each level is bounds-checked, and a NIL casilla at any
                // level is the BASE/1068 failure mode.
                let sub3 = matches!(coll, Expr::Index3(id, _, _, _) if matches!(env.iter().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr4)));
                // Four-level root, MIDDLE collection (hk118/hk119):
                // a[i][j] borrows the level-2 child; its elements are
                // live flat child arrays, so the loop variable is a
                // BORROWED FLAT ARRAY - typed DArr for checking and
                // DArrRef (the param-borrow layout: slot = current
                // casilla address) in codegen. x[j] reads and
                // x[j] := v writes THROUGH the shared casilla (hk119);
                // ValType(x) is "A" (hk118). Both indices evaluate
                // once, each level is bounds-checked, and a NIL
                // casilla at either level is the BASE/1068 failure
                // mode.
                let sub_mid = matches!(coll, Expr::Index2(id, _, _) if matches!(env.iter().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr4)));
                let ct = if sub {
                    if let Expr::Index(id, ie) = coll {
                        if env.iter().find(|v| v.name == *id).map(|v| v.moved).unwrap_or(false) {
                            return Err(format!("line {}: use of moved value `{}`", n, id));
                        }
                        let it = type_expr(ie, env, sigs, *n)?;
                        if !matches!(it, Ty::I64 | Ty::Dyn) {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                    }
                    Ty::DArr
                } else if sub2 {
                    if let Expr::Index2(id, ie, ie2) = coll {
                        if env.iter().find(|v| v.name == *id).map(|v| v.moved).unwrap_or(false) {
                            return Err(format!("line {}: use of moved value `{}`", n, id));
                        }
                        for ix in [ie, ie2] {
                            let it = type_expr(ix, env, sigs, *n)?;
                            if !matches!(it, Ty::I64 | Ty::Dyn) {
                                return Err(format!("line {}: array index must be an integer", n));
                            }
                        }
                    }
                    Ty::DArr
                } else if sub_mid {
                    if let Expr::Index2(id, ie, ie2) = coll {
                        if env.iter().find(|v| v.name == *id).map(|v| v.moved).unwrap_or(false) {
                            return Err(format!("line {}: use of moved value `{}`", n, id));
                        }
                        for ix in [ie, ie2] {
                            let it = type_expr(ix, env, sigs, *n)?;
                            if !matches!(it, Ty::I64 | Ty::Dyn) {
                                return Err(format!("line {}: array index must be an integer", n));
                            }
                        }
                    }
                    Ty::DArr
                } else if sub3 {
                    if let Expr::Index3(id, ie, ie2, ie3) = coll {
                        if env.iter().find(|v| v.name == *id).map(|v| v.moved).unwrap_or(false) {
                            return Err(format!("line {}: use of moved value `{}`", n, id));
                        }
                        for ix in [ie, ie2, ie3] {
                            let it = type_expr(ix, env, sigs, *n)?;
                            if !matches!(it, Ty::I64 | Ty::Dyn) {
                                return Err(format!("line {}: array index must be an integer", n));
                            }
                        }
                    }
                    Ty::DArr
                } else {
                    type_expr(coll, env, sigs, *n)?
                };
                // A temporary collection (a call result: hb_HKeys(h),
                // Array(n) or a user function returning an array or a
                // hash; oracles hk52/hk55/hk56) is OWNED by the loop:
                // it gets a registered slot, zeroed by the prologue,
                // freed-if-nonnull on (re)entry and freed by the
                // epilogue on every exit path (natural, `exit`,
                // `return`). A variable collection is borrowed.
                // An Index3 collection that is not a DArr4 level-3
                    // borrow falls through to type_expr: on a shallower
                    // root it types as an element read (Dyn) and the
                    // collection-type check below names the real problem.
                    if !matches!(coll, Expr::Var(_) | Expr::Call(..) | Expr::Index3(..)) && !sub && !sub2 && !sub3 && !sub_mid {
                    return Err(format!("line {}: `for each` iterates a variable or a function result in this increment (assign the expression to a variable first)", n));
                }
                if matches!(ct, Ty::Arr(_)) {
                    return Err(format!("line {}: `for each` over fixed-size stack arrays is not in this increment; use a dynamic array collection (the native iterator requires tagged cells)", n));
                }
                if !matches!(ct, Ty::DArr | Ty::DArrU | Ty::DArrS | Ty::Hash) {
                    return Err(format!("line {}: `for each` needs a flat or string array or a hash in this increment", n));
                }
                let kp = match env.iter().position(|v| v.name == *var) {
                    Some(k) => k,
                    None => return Err(format!("line {}: `for each` loop variable `{}` must be declared first (Harbour errors BASE/1003 on an undeclared one)", n, var)),
                };
                let cname = match coll {
                    Expr::Var(cn) => Some(cn.clone()),
                    Expr::Index(cn, _) if sub => Some(cn.clone()),
                    Expr::Index2(cn, _, _) if sub2 || sub_mid => Some(cn.clone()),
                    Expr::Index3(cn, _, _, _) if sub3 => Some(cn.clone()),
                    _ => None,
                };
                if let Some(cn) = &cname {
                    if cn == var {
                        return Err(format!("line {}: `for each` loop variable cannot be the collection itself", n));
                    }
                }
                let saved = (env[kp].ty, env[kp].ro);
                // The borrowed-array loop variable (sub_mid) checks as a
                // flat DArr so indexed reads/writes type naturally; it
                // stays read-only for PLAIN assignment (reseat), while
                // element writes go through (hk119).
                env[kp].ty = if sub_mid { Ty::DArr } else { Ty::Dyn };
                env[kp].ro = true;
                let outer = env.len();
                let pre: Vec<bool> = env.iter().map(|v| v.moved).collect();
                let mut env_body = env.clone();
                let mut fexits: Vec<Vec<bool>> = Vec::new();
                let fb = check_stmts(body, &mut env_body, sigs, ret, Some(&pre), &mut fexits, dyn_names, byref_names)?;
                if let Some(cn) = &cname {
                    let kc = env.iter().position(|v| v.name == *cn).expect("collection exists");
                    if env_body[kc].moved || !foreach_coll_untouched(body, cn) {
                        return Err(format!("line {}: the `for each` collection `{}` cannot be modified, moved or grown inside its own loop in this increment (the loop borrows it)", n, cn));
                    }
                }
                let lv_ok = if sub_mid {
                    foreach_barr_lv_ok(body, var)
                } else {
                    foreach_lv_readonly(body, var)
                };
                if !lv_ok {
                    if sub_mid {
                        return Err(format!("line {}: the `for each` variable `{}` borrows an element array from the collection: it can be indexed, read, written through and measured with len/ValType, but not assigned, returned, passed to a function or grown (registered limitation)", n, var));
                    }
                    return Err(format!("line {}: the `for each` variable `{}` can only be printed, compared or used in arithmetic in this increment - its value borrows from the collection, so it cannot be returned, assigned, passed to a function or stored (registered limitation)", n, var));
                }

                if fb {
                    for k in 0..outer {
                        if !pre[k] && env_body[k].moved {
                            return Err(format!("line {}: `{}` is moved inside the `for each` body and not reassigned before `next` (the next iteration would use a moved value)", n, env[k].name));
                        }
                    }
                }
                for k in 0..outer {
                    env[k].moved = pre[k] || (fb && env_body[k].moved) || fexits.iter().any(|xs| xs[k]);
                    if env[k].ty == Ty::DArrU && matches!(env_body[k].ty, Ty::DArr | Ty::DArr2) {
                        env[k].ty = env_body[k].ty;
                    }
                }
                env[kp].ty = saved.0;
                env[kp].ro = saved.1;
            }
            Stmt::Exit(n) => {
                let pre = match loop_pre {
                    Some(p) => p,
                    None => return Err(format!("line {}: `exit` outside a `while` loop or `for` loop", n)),
                };
                exits.push(env[..pre.len()].iter().map(|v| v.moved).collect());
                falls = false;
            }
            Stmt::Loop(n) => {
                let pre = match loop_pre {
                    Some(p) => p,
                    None => return Err(format!("line {}: `loop` outside a `while` loop or `for` loop", n)),
                };
                for k in 0..pre.len() {
                    if !pre[k] && env[k].moved {
                        return Err(format!("line {}: `{}` is moved inside the `while` body and not reassigned before `loop` (the next iteration would use a moved value)", n, env[k].name));
                    }
                }
                falls = false;
            }
            Stmt::AAdd(n, id, e) => {
                // AAdd(a, x): borrows `a` MUTABLY (grows in place, may
                // realloc); does NOT move or null it. The FIRST AAdd pins
                // the element type of an unpinned `{}`: an integer pins a
                // flat array, a dynamic array pins an array of arrays and
                // MOVES the element in (the parent owns it; probe m5's
                // shared-reference behaviour is a registered MODEL
                // divergence).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if env[kp].ty == Ty::DArr4 {
                    return Err(format!("line {}: `AAdd` on the root of a four-level array is not in this increment", n));
                }
                if !matches!(env[kp].ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArrS) {
                    return Err(format!("line {}: `AAdd` applies to dynamic arrays (`{{}}`); `{}` is not one", n, id));
                }
                let t = type_expr(e, env, sigs, *n)?;
                let moves = match env[kp].ty {
                    Ty::DArrU => {
                        match t {
                            Ty::I64 | Ty::Bool | Ty::Dyn => { env[kp].ty = Ty::DArr; false }
                            Ty::DArr | Ty::DArrU => { env[kp].ty = Ty::DArr2; true }
                            // A string pins an array of strings; an owned
                            // string moves in, a rodata one is copied.
                            Ty::Str | Ty::StrOwn => { env[kp].ty = Ty::DArrS; t == Ty::StrOwn }
                            _ => return Err(format!("line {}: `AAdd` grows with integer, string or dynamic-array elements in this increment", n)),
                        }
                    }
                    Ty::DArrS => {
                        if !matches!(t, Ty::Str | Ty::StrOwn) {
                            return Err(format!("line {}: the elements of `{}` are strings", n, id));
                        }
                        t == Ty::StrOwn
                    }
                    Ty::DArr => {
                        // Elements are tagged values: an i64 or a Dyn (NIL
                        // included) both store with their tag.
                        if !matches!(t, Ty::I64 | Ty::Bool | Ty::Dyn) {
                            return Err(format!("line {}: the elements of `{}` are tagged scalars (integer, logical or NIL)", n, id));
                        }
                        false
                    }
                    Ty::DArr2 => {
                        // A dynamic value MOVES in; a static literal
                        // materializes as a dynamic child (the borrowed
                        // middle of a three-level array grows this way -
                        // oracle hk94).
                        if !matches!(t, Ty::DArr | Ty::Arr(_)) {
                            return Err(format!("line {}: the elements of `{}` are dynamic arrays", n, id));
                        }
                        true
                    }
                    _ => unreachable!(),
                };
                if moves {
                    if let Expr::Var(v) = e {
                        if v == id {
                            return Err(format!("line {}: cannot insert `{}` into itself", n, id));
                        }
                    }
                    apply_moves(e, env, sigs, true);
                    if env[kp].moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                } else {
                    apply_moves(e, env, sigs, false);
                    if env[kp].moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                }
            }
            Stmt::AAddSub(n, id, ie, e) => {
                // AAdd(a[i], x): grows the SUBARRAY a[i] in place (probe
                // m5). Runtime order: the target index first, then the
                // value (probe m7). The parent must not move inside either.
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].ty == Ty::DArr4 {
                    return Err(format!("line {}: `AAdd` on a[i] of a four-level array is not in this increment", n));
                }
                if !matches!(env[kp].ty, Ty::DArr2 | Ty::DArr3) {
                    return Err(format!("line {}: `AAdd` on a[i] needs an array of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array index must be an integer", n));
                }
                apply_moves(ie, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if env[kp].ty == Ty::DArr3 {
                    // Middle level of three levels (hk66/hk67/hk69): the
                    // element is a FLAT dynamic array - a static literal
                    // materializes as a dynamic child, a call result or a
                    // variable MOVES in (the source is nulled; the move
                    // contract of root AAdd extends here - Harbour would
                    // SHARE a variable element, registered difference
                    // D5/D7 pending the user's contract decision; this
                    // does NOT implement sharing). Nested literals or
                    // array-of-arrays elements would make a fourth level:
                    // rejected.
                    let t = type_expr(e, env, sigs, *n)?;
                    if !matches!(t, Ty::Arr(_) | Ty::DArr | Ty::DArrU) {
                        return Err(format!("line {}: the elements of the middle level of `{}` are flat dynamic arrays in this increment", n, id));
                    }
                    if let Expr::Var(v) = e {
                        if v == id {
                            return Err(format!("line {}: cannot insert `{}` into itself", n, id));
                        }
                    }
                    apply_moves(e, env, sigs, true);
                    if env[kp].moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                } else {
                    if type_expr(e, env, sigs, *n)? != Ty::I64 {
                        return Err(format!("line {}: nested array elements must be integers in this increment", n));
                    }
                    apply_moves(e, env, sigs, false);
                    if env[kp].moved {
                        return Err(format!("line {}: use of moved value `{}`", n, id));
                    }
                }
            }
            Stmt::ASize(n, id, e) => {
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                match env[kp].ty {
                    // DArr2 shrink frees the removed children recursively
                    // (they are owned by the parent); grow zero-fills, so
                    // fresh children are the empty (null, 0) array. DArrS
                    // shrink frees the removed string copies; GROWING an
                    // array of strings is a clean runtime error in this
                    // increment (Harbour grows with NIL casillas, hk13).
                    Ty::DArr | Ty::DArr2 | Ty::DArrS | Ty::DArr3 => {}
                    Ty::DArrU => return Err(format!("line {}: the element type of `{}` is unknown until its first `AAdd` (pin it first)", n, id)),
                    Ty::DArr4 => return Err(format!("line {}: `ASize` on the root of a four-level array is not in this increment", n)),
                    _ => return Err(format!("line {}: `ASize` applies to dynamic arrays (`{{}}`); `{}` is not one", n, id)),
                }
                let t = type_expr(e, env, sigs, *n)?;
                if t != Ty::I64 {
                    return Err(format!("line {}: `ASize` takes an integer size", n));
                }
                apply_moves(e, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::ASizeSub(n, id, ie, e) => {
                // ASize(a[i], n): resize the subarray in place. Runtime
                // order: the target index first, then the size (probe m7).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                // DArr3 root: the middle child resizes in place (hk65:
                // grow with NIL casillas; shrink frees removed innermost
                // children).
                if env[kp].ty == Ty::DArr4 {
                    return Err(format!("line {}: `ASize` on a[i] of a four-level array is not in this increment", n));
                }
                if !matches!(env[kp].ty, Ty::DArr2 | Ty::DArr3) {
                    return Err(format!("line {}: `ASize` on a[i] needs an array of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array index must be an integer", n));
                }
                apply_moves(ie, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: `ASize` takes an integer size", n));
                }
                apply_moves(e, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::AAddSub2(n, id, ie, ie2, e) => {
                // AAdd(a[i][j], x): grows the INNERMOST subarray in place
                // (oracle pr8). Runtime order: i, then j, then the value
                // (pr8 measured; NOT inferred from the two-level m7).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].ty != Ty::DArr3 {
                    return Err(format!("line {}: `AAdd` on a[i][j] needs an array of arrays of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: nested array elements must be integers in this increment", n));
                }
                apply_moves(e, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::ASizeSub2(n, id, ie, ie2, e) => {
                // ASize(a[i][j], n): resize the innermost subarray in
                // place (oracle pr8: grow leaves fresh slots NIL).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].ty != Ty::DArr3 {
                    return Err(format!("line {}: `ASize` on a[i][j] needs an array of arrays of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: `ASize` takes an integer size", n));
                }
                apply_moves(e, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::AAddSub3(n, id, ie, ie2, ie3, e) => {
                // AAdd(a[i][j][k], x) on a four-level array: grows the
                // level-4 subarray in place (hk105). Runtime order: i, j,
                // k, then the value (hk108 measured; NOT inferred).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].ty != Ty::DArr4 {
                    return Err(format!("line {}: `AAdd` on a[i][j][k] needs an array of arrays of arrays of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 || type_expr(ie3, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
                apply_moves(ie3, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: nested array elements must be integers in this increment", n));
                }
                apply_moves(e, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::ASizeSub3(n, id, ie, ie2, ie3, e) => {
                // ASize(a[i][j][k], n) on a four-level array (hk105: grow
                // leaves fresh slots NIL; shrink frees).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: undeclared variable `{}`", n, id)),
                };
                if env[kp].ty != Ty::DArr4 {
                    return Err(format!("line {}: `ASize` on a[i][j][k] needs an array of arrays of arrays of arrays; `{}` is not one", n, id));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 || type_expr(ie3, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
                apply_moves(ie3, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: `ASize` takes an integer size", n));
                }
                apply_moves(e, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::HDel(n, id, e) => {
                // hb_HDel(h, key): the hash must be live and the key a
                // string; the key is only borrowed (hbc_hdel reads it).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: hb_HDel on undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ty != Ty::Hash {
                    return Err(format!("line {}: hb_HDel expects a hash variable in this increment", n));
                }
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if !matches!(type_expr(e, env, sigs, *n)?, Ty::Str | Ty::StrOwn) {
                    return Err(format!("line {}: hash keys are strings in this increment", n));
                }
                apply_moves(e, env, sigs, false);
            }
            Stmt::HDelAt(n, id, e) => {
                // hb_HDelAt(h, pos): the hash must be live (its slot
                // goes by address; the helper frees the deleted
                // entry's key copy and compacts); the position is an
                // integer (hk187) and moves nothing. An out-of-range
                // position is Harbour's BASE/1187 dialog family
                // (hk189) - the clean bound-error exit at runtime,
                // checked in codegen.
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: hb_HDelAt on undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ty != Ty::Hash {
                    return Err(format!("line {}: hb_HDelAt expects a hash variable in this increment", n));
                }
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: the hb_HDelAt position is an integer in this increment", n));
                }
                apply_moves(e, env, sigs, false);
            }
            Stmt::HClear(n, id) => {
                // hb_HClear(h): the hash must be live; the helper
                // frees every key copy and the whole data block, so
                // the CaseMatch flag resets to the default (hk191/
                // hk193: sensitive after a clear).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: hb_HClear on undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ty != Ty::Hash {
                    return Err(format!("line {}: hb_HClear expects a hash variable in this increment", n));
                }
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::HFill(n, id, e) => {
                // hb_HFill(h, value): the hash must be live; the value
                // is a tagged int/NIL scalar (hk192: 7 over everything
                // including a stored NIL, NIL over everything), only
                // read - it moves nothing.
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: hb_HFill on undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ty != Ty::Hash {
                    return Err(format!("line {}: hb_HFill expects a hash variable in this increment", n));
                }
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if !matches!(type_expr(e, env, sigs, *n)?, Ty::I64 | Ty::Bool | Ty::Dyn) {
                    return Err(format!("line {}: hash values are integers, logicals or NIL in this increment", n));
                }
                apply_moves(e, env, sigs, false);
            }
            Stmt::HSetCaseMatch(n, id, e) => {
                // hb_HSetCaseMatch(h, flag): the hash must be live
                // (its slot goes by address; the helper only writes the
                // header flag or grows a header-only block); the flag is
                // an integer (1 sensitive, 0 insensitive - hk169) and
                // moves nothing.
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: hb_HSetCaseMatch on undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ty != Ty::Hash {
                    return Err(format!("line {}: hb_HSetCaseMatch expects a hash variable in this increment", n));
                }
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: the hb_HSetCaseMatch flag is an integer in this increment (1 sensitive, 0 insensitive)", n));
                }
                apply_moves(e, env, sigs, true);
            }
            Stmt::HSet(n, id, ke, ve) => {
                // hb_HSet(h, key, value): the hash must be live, the key
                // a string, the value a tagged scalar (integer or NIL) -
                // same contract as h[k] := v; the value moves, the key
                // is borrowed (hbc_hput copies it).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: hb_HSet on undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ty != Ty::Hash {
                    return Err(format!("line {}: hb_HSet expects a hash variable in this increment", n));
                }
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if !matches!(type_expr(ke, env, sigs, *n)?, Ty::Str | Ty::StrOwn) {
                    return Err(format!("line {}: hash keys are strings in this increment", n));
                }
                if !matches!(type_expr(ve, env, sigs, *n)?, Ty::I64 | Ty::Dyn) {
                    return Err(format!("line {}: hash values are tagged scalars (integer or NIL) in this increment", n));
                }
                apply_moves(ve, env, sigs, true);
                apply_moves(ke, env, sigs, false);
            }
            Stmt::HCopy(n, id, s2, se, ce) => {
                // hb_HCopy(src, dst): both must be live hash variables;
                // both are only BORROWED (hbc_hcopy copies every key
                // and value through hbc_hput). start/count are integers
                // and move nothing. src == dst is rejected at parse
                // time (hk195b self-copy family).
                for nm in [&*id, &*s2] {
                    let kp = match env.iter().position(|v| v.name == *nm) {
                        Some(k) => k,
                        None => return Err(format!("line {}: hb_HCopy on undeclared variable `{}` (declare it with `local` first)", n, nm)),
                    };
                    if env[kp].ty != Ty::Hash {
                        return Err(format!("line {}: hb_HCopy expects hash variables in this increment", n));
                    }
                    if env[kp].moved {
                        return Err(format!("line {}: use of moved value `{}`", n, nm));
                    }
                }
                for oe in [se.as_ref(), ce.as_ref()].into_iter().flatten() {
                    if type_expr(oe, env, sigs, *n)? != Ty::I64 {
                        return Err(format!("line {}: hb_HCopy start/count are integers in this increment", n));
                    }
                    apply_moves(oe, env, sigs, false);
                }
            }
            Stmt::HMerge(n, id, s) => {
                // hb_HMerge(dst, src): both must be live hash variables;
                // both are only BORROWED (hbc_hmerge copies every key
                // and value it upserts; the source is only read and
                // keeps owning its copies - hk165).
                for nm in [id, s] {
                    let kp = match env.iter().position(|v| v.name == *nm) {
                        Some(k) => k,
                        None => return Err(format!("line {}: hb_HMerge on undeclared variable `{}` (declare it with `local` first)", n, nm)),
                    };
                    if env[kp].ty != Ty::Hash {
                        return Err(format!("line {}: hb_HMerge expects hash variables in this increment", n));
                    }
                    if env[kp].moved {
                        return Err(format!("line {}: use of moved value `{}`", n, nm));
                    }
                }
            }
            Stmt::ArrSet(n, id, ie, e) => {
                // Value first, then the index: the runtime order (probe
                // adv2, shared by Harbour and Rust) decides which of two
                // consuming expressions is the use-after-move.
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                // A read-only DArr local arises only as the `for each`
                // borrowed-array loop variable (hk118/hk119): element
                // writes go THROUGH to the shared casilla and are
                // allowed; plain assignment to it stays rejected by the
                // Assign check.
                if env[kp].ro && env[kp].ty != Ty::DArr {
                    return Err(format!("line {}: cannot assign through the `for` loop variable `{}`", n, id));
                }
                let root_ty = env[kp].ty;
                match root_ty {
                    Ty::Hash => {
                        if env[kp].moved {
                            return Err(format!("line {}: use of moved value `{}`", n, id));
                        }
                        // Value first, then the key (probe h4).
                        let vt = type_expr(e, env, sigs, *n)?;
                        if !matches!(vt, Ty::I64 | Ty::Bool | Ty::Dyn) {
                            return Err(format!("line {}: hash values are tagged scalars (integer, logical or NIL) in this increment", n));
                        }
                        if !matches!(type_expr(ie, env, sigs, *n)?, Ty::Str | Ty::StrOwn) {
                            return Err(format!("line {}: hash keys are strings in this increment", n));
                        }
                        apply_moves(e, env, sigs, true);
                        apply_moves(ie, env, sigs, false);
                    }
                    Ty::DArr => {
                        let vt = type_expr(e, env, sigs, *n)?;
                        if !matches!(vt, Ty::I64 | Ty::Bool | Ty::Dyn) {
                            return Err(format!("line {}: dynamic-array elements are tagged scalars (integer, logical or NIL)", n));
                        }
                        if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        apply_moves(e, env, sigs, true);
                        apply_moves(ie, env, sigs, false);
                    }
                    Ty::DArrS => {
                        // Element overwrite on an array of strings: an
                        // owned string moves in, a rodata one is copied;
                        // the old owned copy is freed in codegen.
                        let vt = type_expr(e, env, sigs, *n)?;
                        if !matches!(vt, Ty::Str | Ty::StrOwn) {
                            return Err(format!("line {}: the elements of `{}` are strings", n, id));
                        }
                        if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        apply_moves(e, env, sigs, true);
                        apply_moves(ie, env, sigs, false);
                    }
                    Ty::Arr(_) => {
                        if type_expr(e, env, sigs, *n)? != Ty::I64 {
                            return Err(format!("line {}: array elements must be integers in this increment", n));
                        }
                        if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        apply_moves(e, env, sigs, true);
                        apply_moves(ie, env, sigs, false);
                    }
                    Ty::DArr2 => {
                        // Child overwrite: the RHS is a dynamic array and
                        // MOVES in; the old child is freed once, AFTER the
                        // new value exists (parent rule).
                        let t = type_expr(e, env, sigs, *n)?;
                        // An i64 literal converts to a Dyn-element child
                        // (oracle n3: a[3] := {9, 9} works in Harbour).
                        if !matches!(t, Ty::DArr | Ty::DArrU | Ty::Arr(_)) {
                            return Err(format!("line {}: the elements of `{}` are dynamic arrays; assign one (or `{{}}`)", n, id));
                        }
                        if let Expr::Var(v) = e {
                            if v == id {
                                return Err(format!("line {}: cannot assign `{}` into its own element", n, id));
                            }
                        }
                        if type_expr(ie, env, sigs, *n)? != Ty::I64 {
                            return Err(format!("line {}: array index must be an integer", n));
                        }
                        apply_moves(e, env, sigs, true);
                        apply_moves(ie, env, sigs, false);
                    }
                    Ty::DArrU => {
                        return Err(format!("line {}: the element type of `{}` is unknown until its first `AAdd` (pin it first)", n, id));
                    }
                    Ty::DArr4 => {
                        return Err(format!("line {}: assigning into an element of a four-level array is not in this increment", n));
                    }
                    _ => return Err(format!("line {}: indexed assignment applies to arrays; `{}` is not an array", n, id)),
                }
                // The parent must not move while the indexed borrow exists
                // (e.g. a[give(a)] := 1 moves `a` inside the index).
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
                if let Ty::Arr(k) = root_ty {
                    if let Expr::Int(lit) = ie {
                        let bad = lit.parse::<i64>().map(|x| x < 1 || x > k as i64).unwrap_or(true);
                        if bad {
                            return Err(format!("line {}: array index {} out of bounds (`{}` has {} element(s), base 1)", n, lit, id, k));
                        }
                    }
                }
            }
            Stmt::ArrSet2(n, id, ie, ie2, e) => {
                // a[i][j] := v: value first, then outer index, then inner
                // index (probe m7). Transient indexed borrows only; the
                // parent must not move while any borrow exists.
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ro {
                    return Err(format!("line {}: cannot assign through the `for` loop variable `{}`", n, id));
                }
                if env[kp].ty != Ty::DArr2 {
                    return Err(format!("line {}: two-level assignment needs an array of arrays; `{}` is not one", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: nested array elements must be integers in this increment", n));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(e, env, sigs, true);
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::ArrSet3(n, id, ie, ie2, ie3, e) => {
                // a[i][j][k] := v: value first, then the indices (probe
                // m7 order); three transient indexed borrows (oracle pr6).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ro {
                    return Err(format!("line {}: cannot assign through the `for` loop variable `{}`", n, id));
                }
                if env[kp].ty != Ty::DArr3 {
                    return Err(format!("line {}: three-level assignment needs an array of arrays of arrays; `{}` is not one", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: nested array elements must be integers in this increment", n));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 || type_expr(ie3, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(e, env, sigs, true);
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
                apply_moves(ie3, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::ArrSet4(n, id, ie, ie2, ie3, ie4, e) => {
                // a[i][j][k][l] := v: value first, then the indices left to
                // right (hk104); four transient indexed borrows (hk103).
                let kp = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[kp].ro {
                    return Err(format!("line {}: cannot assign through the `for` loop variable `{}`", n, id));
                }
                if env[kp].ty != Ty::DArr4 {
                    return Err(format!("line {}: four-level assignment needs an array of arrays of arrays of arrays; `{}` is not one", n, id));
                }
                if type_expr(e, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: nested array elements must be integers in this increment", n));
                }
                if type_expr(ie, env, sigs, *n)? != Ty::I64 || type_expr(ie2, env, sigs, *n)? != Ty::I64 || type_expr(ie3, env, sigs, *n)? != Ty::I64 || type_expr(ie4, env, sigs, *n)? != Ty::I64 {
                    return Err(format!("line {}: array indices must be integers", n));
                }
                apply_moves(e, env, sigs, true);
                apply_moves(ie, env, sigs, false);
                apply_moves(ie2, env, sigs, false);
                apply_moves(ie3, env, sigs, false);
                apply_moves(ie4, env, sigs, false);
                if env[kp].moved {
                    return Err(format!("line {}: use of moved value `{}`", n, id));
                }
            }
            Stmt::Assign(n, id, e) => {
                // RHS is evaluated first; a Str source variable moves.
                let t = type_expr(e, env, sigs, *n)?;
                if let Expr::Var(v) = e {
                    if *v != *id {
                        if let Some(x) = env.iter().find(|x| x.name == *v && x.byref && matches!(x.ty, Ty::Str | Ty::StrOwn)) {
                            return Err(format!("line {}: copying borrowed parameter `{}` by move is not Harbour semantics; derive a value instead (for example a concatenation)", n, v));
                        }
                    }
                }
                apply_moves(e, env, sigs, true);
                let idx = match env.iter().position(|v| v.name == *id) {
                    Some(k) => k,
                    None => return Err(format!("line {}: assignment to undeclared variable `{}` (declare it with `local` first)", n, id)),
                };
                if env[idx].ro {
                    return Err(format!("line {}: cannot assign to the `for` loop variable `{}` (it advances only via the loop itself)", n, id));
                }
                if env[idx].ty == Ty::DArrU && matches!(t, Ty::DArr | Ty::DArr2) {
                    // Assigning a pinned dynamic array pins the empty `{}`.
                    env[idx].ty = t;
                } else if env[idx].ty == Ty::Dyn && matches!(t, Ty::I64 | Ty::Dyn | Ty::Str | Ty::StrOwn) {
                    // Dyn slot: an i64 is tagged in, a Dyn is copied (probe
                    // n2: reassignment re-tags a live variable), a string
                    // becomes an OWNED tag-4 casilla (hk242): a literal is
                    // cloned at the boundary, an owned value moves in.
                } else if env[idx].ty == Ty::I64 && t == Ty::Dyn {
                    // i64 slot receiving a Dyn: the tag is checked at
                    // runtime (NIL payload -> clean type error).
                } else if env[idx].ty == Ty::StrOwn && t == Ty::Str {
                    // rodata literal into an owned slot (hk225): the
                    // assignment boundary hands over an owned copy, same
                    // contract as a rodata argument to an owned parameter.
                } else if env[idx].ty != t {
                    return Err(format!("line {}: type mismatch in assignment to `{}`", n, id));
                }
                // Reassignment makes a moved variable live again (Rust too).
                env[idx].moved = false;
            }
        }
    }
    Ok(falls)
}

// If `e` is a plain variable of type Str, using it as an initializer or a
// return value MOVES it (ownership transfer). Mark it moved.
// Mark moved-out heap vars (strings, dynamic arrays). `moving` is true where
// the position consumes the value (a local/assign/return root expression, an
// owned argument slot); a bare var in a comparison, arithmetic, index or
// len() only borrows. Call arguments move when the callee's parameter owns
// the value (string or dynamic array), like Rust String/Vec passed by value.
// i64 and codeblocks never move (Copy).
fn apply_moves(e: &Expr, env: &mut [Local], sigs: &[Sig], moving: bool) {
    match e {
        Expr::Seq(es) => { for e in es { apply_moves(e, env, sigs, false); } }
        Expr::ByRef(_) => {} // `@x` borrows the slot for the call; the owner keeps it (hk216)
        Expr::Var(id) => {
            if moving {
                if let Some(v) = env.iter_mut().find(|v| v.name == *id && !v.byref && matches!(v.ty, Ty::Str | Ty::StrOwn | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Hash)) { v.moved = true; }
            }
        }
        Expr::Bin(_, a, b) => { apply_moves(a, env, sigs, false); apply_moves(b, env, sigs, false); }
        Expr::Cmp(_, a, b) => { apply_moves(a, env, sigs, false); apply_moves(b, env, sigs, false); }
        Expr::Call(id, args) => {
            if is_builtin(id, "hb_memcheck") {
                return;
            }
            if is_builtin(id, "procline") || is_builtin(id, "hb_eol") || is_builtin(id, "procname") { return; }
            if is_bitindex(id) { apply_moves(&args[0],env,sigs,false); return; }
            if is_bitop(id) { for a in args { apply_moves(a, env, sigs, false); } return; }
            if is_builtin(id, "min") || is_builtin(id, "max") {
                for a in args { apply_moves(a, env, sigs, false); } return;
            }
            if is_builtin(id, "empty") { apply_moves(&args[0], env, sigs, false); return; }
            if is_builtin(id, "len") {
                apply_moves(&args[0], env, sigs, false);
                return;
            }
            if is_builtin(id, "valtype") {
                // ValType borrows its argument (hk88-hk92): nothing moves.
                apply_moves(&args[0], env, sigs, false);
                return;
            }
            if ["ltrim", "rtrim", "alltrim", "trim"].iter().any(|b| is_builtin(id,b)) {
                apply_moves(&args[0],env,sigs,false);
                return;
            }
            if is_output_call(id) {
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "asc") {
                apply_moves(&args[0], env, sigs, false);
                return;
            }
            if is_builtin(id, "chr") {
                apply_moves(&args[0], env, sigs, false);
                return;
            }
            if is_builtin(id, "round") {
                // Round borrows both numeric arguments: nothing moves.
                apply_moves(&args[0], env, sigs, false);
                apply_moves(&args[1], env, sigs, false);
                return;
            }
            if is_builtin(id, "eval") {
                // Block values are Copy pointers; arguments are integers:
                // nothing moves (checked in analysis).
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "array") {
                // Integer dimensions: borrowed, never moved.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hkeys") {
                // The hash is BORROWED: hbc_hkeys copies every key, the
                // hash keeps owning its own copies.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hvalues") {
                // The hash is BORROWED: hbc_hvalues copies every value
                // cell, the hash keeps owning its own cells.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hclone") {
                // The source is BORROWED: hbc_hclone deep-copies every
                // entry, the source keeps owning its own copies.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hhaskey") {
                // The hash and the lookup key are BORROWED: hbc_hhaskey
                // only reads them.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hget") {
                // The hash and the lookup key are BORROWED: hbc_hget
                // only reads them. The optional default IS evaluated
                // and its value discarded (hk158f1/f2/f3); as an
                // integer in this increment it moves nothing either.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hgetdef") {
                // The hash and the lookup key are BORROWED: hbc_hget
                // only reads them and a miss never mutates the hash
                // (hk194: no auto-add). The default is a tagged int/NIL
                // scalar; it moves nothing.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hsetdef") {
                // The hash is BORROWED for the mutation (hbc_hsetdef
                // copies the key and the default cell), the key is
                // borrowed, and the default is a tagged int/NIL scalar:
                // nothing moves.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hpos") {
                // The hash and the lookup key are BORROWED: hbc_hpos
                // only reads them.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hscan") {
                // The hash and the value are BORROWED: hbc_hscan only
                // reads them (int/NIL scalars move nothing anyway).
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hkeyat") || is_builtin(id, "hb_hvalueat") {
                // The hash is BORROWED: hbc_hkeyat/hbc_hvalueat only
                // read it; the position is an integer.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "hb_hcasematch") {
                // The hash is BORROWED: hbc_hcasematch only reads the
                // slot and the block header.
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            if is_builtin(id, "iif") {
                // Scalar branches only (checker-enforced). An owned-string
                // branch MOVES its source when its arm is taken (63zf) -
                // statically the source is moved on either outcome.
                for a in args { apply_moves(a, env, sigs, false); }
                for a in &args[1..] {
                    if let Expr::Var(v) = a {
                        if env.iter().any(|x| x.name == *v && x.ty == Ty::StrOwn) { apply_moves(a, env, sigs, true); }
                    }
                }
                return;
            }
            if is_builtin(id, "hb_pvalue") {
                // Read-only mention: the PValue index moves nothing
                // (multiarg).
                for a in args { apply_moves(a, env, sigs, false); }
                return;
            }
            let sig = sigs.iter().find(|v| v.name == *id).expect("checked");
            for (i, a) in args.iter().enumerate() {
                // A static array argument is COPIED at the boundary (33l):
                // the source variable keeps its value.
                let copy = matches!(a, Expr::Var(v) if env.iter().any(|x| x.name == *v && matches!(x.ty, Ty::Arr(_))));
                let m = !copy && i < sig.params.len() && (sig.params[i] == Ty::Str || sig.params[i] == Ty::StrOwn || sig.params[i] == Ty::DArr || sig.params[i] == Ty::DArr2 || sig.params[i] == Ty::DArr3 || sig.params[i] == Ty::DArr4 || sig.params[i] == Ty::DArrS || sig.params[i] == Ty::Hash);
                apply_moves(a, env, sigs, m);
            }
        }
        Expr::ArrLit(es) => { for e in es { apply_moves(e, env, sigs, false); } }
        Expr::Index(_, ie) => apply_moves(ie, env, sigs, false),
        Expr::IdxCompound(_, ie, _, re) => { apply_moves(ie, env, sigs, false); apply_moves(re, env, sigs, false); }
        Expr::Index2(_, ie, ie2) => { apply_moves(ie, env, sigs, false); apply_moves(ie2, env, sigs, false); }
        Expr::Index3(_, ie, ie2, ie3) => { apply_moves(ie, env, sigs, false); apply_moves(ie2, env, sigs, false); apply_moves(ie3, env, sigs, false); }
        Expr::Index4(_, ie, ie2, ie3, ie4) => { apply_moves(ie, env, sigs, false); apply_moves(ie2, env, sigs, false); apply_moves(ie3, env, sigs, false); apply_moves(ie4, env, sigs, false); }
        Expr::BlockLit(_, _, _) => {}
        _ => {}
    }
}

// ---------------------------------------------------------------------------
// Code generation: x86-64 assembly (AT&T syntax), freestanding.
//   i64 value  -> %rax
//   Str value  -> %rax = ptr, %rdx = len
// Locals live in the stack frame: i64 takes 8 bytes, Str takes 16.
// ---------------------------------------------------------------------------

// Constant fold of a pure integer expression (literal +,-,* tree):
// Harbour's compiler folds these (hk326), and the folded value prints
// with literal provenance (digits+1), unlike a runtime-computed value.
fn fold_int(e: &Expr) -> Option<i64> {
    match e {
        Expr::Call(id,args) if is_bitindex(id) && !is_builtin(id,"hb_bittest") => {
            let v = fold_int(&args[0])?;
            let bit = fold_int(&args[1])?;
            if !(0..64).contains(&bit) { return None; }
            let mask = 1i64 << bit;
            Some(if is_builtin(id,"hb_bitset") {v | mask} else {v & !mask})
        }
        Expr::Call(id, args) if is_bitop(id) => {
            let mut v = fold_int(&args[0])?;
            if is_builtin(id,"hb_bitnot") { return Some(!v); }
            for a in &args[1..] {
                let b = fold_int(a)?;
                v = if is_builtin(id,"hb_bitand") {v & b} else if is_builtin(id,"hb_bitor") {v | b} else {v ^ b};
            }
            Some(v)
        }
        Expr::Call(id, args) if (is_builtin(id, "min") || is_builtin(id, "max")) && args.len() == 2 => {
            let a = fold_int(&args[0])?; let b = fold_int(&args[1])?;
            Some(if is_builtin(id, "min") { a.min(b) } else { a.max(b) })
        }
        Expr::Seq(es) => fold_int(es.last().expect("nonempty")), // provenance only; NEVER skip prefix effects
        Expr::Int(t) => t.parse().ok(),
        Expr::Bin('+', a, b) => fold_int(a)?.checked_add(fold_int(b)?),
        Expr::Bin('-', a, b) => fold_int(a)?.checked_sub(fold_int(b)?),
        Expr::Bin('*', a, b) => fold_int(a)?.checked_mul(fold_int(b)?),
        _ => None,
    }
}
fn size_of(t: Ty) -> usize {
    match t { Ty::F64 => 16, Ty::I64 => 8, Ty::Str | Ty::StrOwn => 16, Ty::Arr(n) => 8 * n, Ty::Block(_) => 8, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Dyn | Ty::Hash | Ty::DArrRef | Ty::DArrRef2 => 16, Ty::Bool => 8, Ty::RefI64 | Ty::RefStrOwn => 8 }
}

#[derive(Clone)]
struct CgLocal {
    name: String,
    ty: Ty,
    off: usize, // offset below rbp of the FIRST slot (ptr for Str, value for i64)
}

fn cg_expr(e: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    match e {
        Expr::Seq(es) => {
            for e in es {
                if expr_ty(e, env, sigs) == Ty::F64 {
                    cg_f64_load(e, env, sigs, strs, out, target);
                } else { cg_value(e, env, sigs, strs, out, target); }
            }
        }
        Expr::SelfObj | Expr::SelfGet(_) | Expr::Send(_, _, _) => unreachable!("rejected before codegen"),
        Expr::ByRef(_) => unreachable!("`@` arguments are emitted at the call site"),
        Expr::Int(v) => {
            out.push_str(&format!("    mov ${}, %rax\n", v));
        }
        Expr::Float(..) | Expr::FloatV(..) => unreachable!("floats load through cg_f64_load (xmm0/rdi), never the rax/rdx channel"),
        Expr::Nil => {
            // NIL: the Dyn tag/payload pair (probe n1) - rax=tag, rdx=payload
            out.push_str("    mov $1, %eax\n    xor %edx, %edx\n");
        }
        Expr::Str(_) => unreachable!("string literals are emitted via cg_str_ref"),
        Expr::Log(b) => {
            out.push_str(&format!("    mov ${}, %rax\n", if *b { 1 } else { 0 }));
        }
        Expr::LNot(a) => {
            cg_expr(a, env, sigs, strs, out, target);
            out.push_str("    xor $1, %rax\n");
        }
        Expr::LAnd(_, _) | Expr::LOr(_, _) | Expr::Cmp(..) => {
            // A logical VALUE (hk198: comparisons produce logicals):
            // the same conditional-jump machinery as conditions,
            // materialized to 0/1. Short-circuit preserved (hk203).
            let k = fresh_lbl();
            cg_cond_jump(e, env, sigs, strs, out, target, &format!(".Lbt{}", k));
            out.push_str(&format!("    xor %eax, %eax\n    jmp .Lbe{}\n.Lbt{}:\n    mov $1, %rax\n.Lbe{}:\n", k, k, k));
        }
        Expr::Inc(id, delta, prefix) => {
            let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
            if v.ty == Ty::RefI64 {
                out.push_str(&format!("    mov -{}(%rbp), %r10\n", v.off));
            } else {
                out.push_str(&format!("    lea -{}(%rbp), %r10\n", v.off));
            }
            out.push_str("    mov (%r10), %rax\n    mov %rax, %r11\n");
            out.push_str(if *delta > 0 { "    add $1, %r11\n" } else { "    sub $1, %r11\n" });
            out.push_str("    jo hbc_inc_overflow\n    mov %r11, (%r10)\n");
            if *prefix { out.push_str("    mov %r11, %rax\n"); }
        }
        Expr::Var(id) => {
            let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
            match v.ty {
                Ty::RefI64 => out.push_str(&format!("    mov -{}(%rbp), %r11\n    mov (%r11), %rax\n", v.off)),
                Ty::RefStrOwn => out.push_str(&format!("    mov -{}(%rbp), %r11\n    mov (%r11), %rax\n    mov 8(%r11), %rdx\n", v.off)),
                Ty::F64 => unreachable!("floats load through cg_f64_load (xmm0/rdi), never the rax/rdx channel"),
                Ty::I64 | Ty::Block(_) | Ty::Bool => out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off)),
                Ty::Str | Ty::StrOwn | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Dyn | Ty::Hash => {
                    // ptr at -(off), len at -(off-8) — same layout as the store
                    out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off));
                    out.push_str(&format!("    mov -{}(%rbp), %rdx\n", v.off - 8));
                }
                // Only the address word is meaningful; value-position use
                // of a borrowed parameter is rejected by the escape
                // post-pass, so the second word never matters.
                Ty::DArrRef | Ty::DArrRef2 => out.push_str(&format!("    mov -{}(%rbp), %rax\n    xor %edx, %edx\n", v.off)),
                Ty::Arr(_) => unreachable!("whole-array values are emitted via cg_array_value"),
            }
        }
        Expr::Call(id, args) if is_builtin(id, "iif") => {
            // iif(cond, a, b) (oracle hk321): LAZY branch selection.
            // The false side falls through, the true side sits behind
            // the conditional jump; both leave the result on the same
            // channel (rax/rdx, or xmm0/rdi when a side is F64 - an I64
            // side converts like the 63zd call boundary: cvtsi2sd,
            // dec 0, provenance length).
            let ta = expr_ty(&args[1], env, sigs);
            let tb = expr_ty(&args[2], env, sigs);
            let k = fresh_lbl();
            cg_cond_jump(&args[0], env, sigs, strs, out, target, &format!(".Liift{}", k));
            let mut f64side = |t: Ty, a: &Expr, out: &mut String| {
                if t == Ty::F64 {
                    cg_f64_load(a, env, sigs, strs, out, target);
                } else {
                    cg_expr(a, env, sigs, strs, out, target);
                    out.push_str("    cvtsi2sd %rax, %xmm0\n");
                    let lit_len: Option<u32> = if let Expr::Int(txt) = a {
                        let neg = txt.starts_with('-');
                        let digits = txt.trim_start_matches('-').len() as u32;
                        if !neg && digits >= 10 { Some(digits + 1) } else {
                            let v: i64 = txt.parse().expect("checked");
                            Some(if v > 9999999999 || v < -999999999 { 20 } else { 10 })
                        }
                    } else { None };
                    if let Some(l) = lit_len {
                        out.push_str(&format!("    mov ${}, %edi\n", l << 16));
                    } else {
                        let lw = fresh_lbl();
                        let ld = fresh_lbl();
                        out.push_str(&format!("    mov $10, %edi\n    mov $9999999999, %r11\n    cmp %r11, %rax\n    jg .Lf64w{}\n    cmp $-999999999, %rax\n    jge .Lf64w{}\n.Lf64w{}:\n    mov $20, %edi\n.Lf64w{}:\n    shl $16, %rdi\n", lw, ld, lw, ld));
                    }
                }
            };
            if ta == Ty::F64 || tb == Ty::F64 {
                f64side(tb, &args[2], out);
                out.push_str(&format!("    jmp .Liife{}\n.Liift{}:\n", k, k));
                f64side(ta, &args[1], out);
                out.push_str(&format!(".Liife{}:\n", k));
            } else {
                let to_strown = matches!(ta, Ty::StrOwn) || matches!(tb, Ty::StrOwn);
                let mut scalar_side = |a: &Expr, out: &mut String| {
                    // String literals intern like every other emitter
                    // (cg_expr's Str arm is unreachable by design).
                    if let Expr::Str(s) = a {
                        let idx = strs.len();
                        strs.push(s.clone());
                        out.push_str(&format!("    lea .Lstr{}(%rip), %rax\n", idx));
                        out.push_str(&format!("    mov ${}, %edx\n", s.as_bytes().len()));
                    } else {
                        cg_expr(a, env, sigs, strs, out, target);
                    }
                    // Owned-string unification (63zf): a borrowed side is
                    // cloned here, on its own (taken) path only, so the
                    // unified result is a valid owned string.
                    if to_strown && expr_ty(a, env, sigs) != Ty::StrOwn {
                        out.push_str("    sub $16, %rsp\n    mov %rdx, (%rsp)\n    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n    mov (%rsp), %rdx\n    add $16, %rsp\n");
                    }
                    // An owned-variable side MOVES on this (taken) path:
                    // null the source slot so the epilogue does not free
                    // the buffer the result consumer already owns.
                    if to_strown {
                        if let Expr::Var(v) = a {
                            if let Some(lv) = env.iter().find(|x| x.name == *v && x.ty == Ty::StrOwn) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n", lv.off));
                            }
                        }
                    }
                };
                scalar_side(&args[2], out);
                out.push_str(&format!("    jmp .Liife{}\n.Liift{}:\n", k, k));
                scalar_side(&args[1], out);
                out.push_str(&format!(".Liife{}:\n", k));
            }
        }
        Expr::Call(id, args) if is_builtin(id, "valtype") => {
            // ValType(x) (hk88-hk92): a one-character tag as a 1-byte
            // string (rax=ptr, rdx=1). Static types classify at compile
            // time; Dyn casillas at runtime: a scalar casilla {tag,
            // payload} reads tag 0/1/2 as "N"/"U"/"C" (hk92), a child-array
            // casilla {ptr, len} reads ptr 0/nonzero as "U"/"A"
            // (hk90/hk91). Index arguments evaluate once, with their
            // effects, before the walk (hk89). Borrows - never moves.
            fn vt_letter(strs: &mut Vec<String>, out: &mut String, ch: &str) {
                let idx = strs.len();
                strs.push(ch.to_string());
                out.push_str(&format!("    lea .Lstr{}(%rip), %rax\n    mov $1, %edx\n", idx));
            }
            // %r10 = scalar Dyn tag: 0 i64 -> "N", 1 NIL -> "U", 2 str -> "C"
            fn vt_classify_scalar(strs: &mut Vec<String>, out: &mut String) {
                out.push_str("    cmp $1, %r10\n    je 95f\n    cmp $2, %r10\n    je 96f\n    cmp $4, %r10\n    je 96f\n    cmp $3, %r10\n    je 98f\n");
                vt_letter(strs, out, "N");
                out.push_str("    jmp 97f\n95:\n");
                vt_letter(strs, out, "U");
                out.push_str("    jmp 97f\n96:\n");
                vt_letter(strs, out, "C");
                out.push_str("    jmp 97f\n98:\n");
                vt_letter(strs, out, "L");
                out.push_str("97:\n");
            }
            match &args[0] {
                Expr::Int(_) => vt_letter(strs, out, "N"),
                Expr::Str(_) => vt_letter(strs, out, "C"),
                Expr::Nil => vt_letter(strs, out, "U"),
                Expr::Call(id, _) if is_output_call(id) => {
                    cg_expr(&args[0], env, sigs, strs, out, target);
                    vt_letter(strs, out, "U");
                }
                Expr::Var(v) => {
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    match var.ty {
                        Ty::I64 => vt_letter(strs, out, "N"),
                        Ty::Bool => vt_letter(strs, out, "L"), // hk197
                        Ty::Str | Ty::StrOwn => vt_letter(strs, out, "C"),
                        Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::DArrRef | Ty::DArrRef2 | Ty::Arr(_) => vt_letter(strs, out, "A"),
                        Ty::Dyn => {
                            // tag word of the stack pair (tag at -(off))
                            out.push_str(&format!("    mov -{}(%rbp), %r10\n", var.off));
                            vt_classify_scalar(strs, out);
                        }
                        _ => unreachable!("checked"),
                    }
                }
                Expr::Index(v, ie) => {
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    if var.ty == Ty::Hash {
                        // ValType(h[k]): the key evaluates once (hk89);
                        // hbc_hget borrows and returns the cell pointer or
                        // 0 on a miss. A miss is Harbour's BASE/1132-family
                        // error condition (hk209: the dialog hangs headless)
                        // - the registered clean bound-error exit, NOT a
                        // silent "U" read.
                        cg_value(ie, env, sigs, strs, out, target);
                        out.push_str(&format!("    mov %rax, %rsi\n    lea -{}(%rbp), %rdi\n    call hbc_hget\n", var.off));
                        out.push_str("    test %rax, %rax\n    je 85f\n    mov (%rax), %r10\n    jmp 86f\n85:\n    call hbc_bound_error\n86:\n");
                        vt_classify_scalar(strs, out);
                    } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                    match var.ty {
                        Ty::DArr | Ty::DArrS => {
                            out.push_str(&format!("    cmp $1, %rax\n    jl 87f\n    cmp -{}(%rbp), %rax\n    jg 87f\n", var.off - 8));
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                            out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                            vt_classify_scalar(strs, out);
                        }
                        Ty::DArrRef => {
                            // Borrowed middle array: bounds and base load
                            // through the owner's cell address (hk86).
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rax\n    jl 87f\n    cmp 8(%r11), %rax\n    jg 87f\n", var.off));
                            out.push_str("    mov (%r11), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                            vt_classify_scalar(strs, out);
                        }
                        Ty::DArrRef2 => {
                            // Borrowed middle of a THREE-level array: the
                            // cell content is a child-array {ptr, len} -
                            // null ptr is "U", non-null "A" (hk90/hk91
                            // through the borrow, hk97).
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rax\n    jl 87f\n    cmp 8(%r11), %rax\n    jg 87f\n", var.off));
                            out.push_str("    mov (%r11), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    test %r10, %r10\n    jz 85f\n    jmp 86f\n87:\n    call hbc_bound_error\n85:\n");
                            vt_letter(strs, out, "U");
                            out.push_str("    jmp 88f\n86:\n");
                            vt_letter(strs, out, "A");
                            out.push_str("88:\n");
                        }
                        Ty::DArr2 | Ty::DArr4 => {
                            // Child-array casilla {ptr, len}: null ptr is
                            // "U", non-null "A" (hk90/hk91 on DArr2;
                            // hk114 on DArr4, byte-measured).
                            out.push_str(&format!("    cmp $1, %rax\n    jl 87f\n    cmp -{}(%rbp), %rax\n    jg 87f\n", var.off - 8));
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                            out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    test %r10, %r10\n    jz 85f\n    jmp 86f\n87:\n    call hbc_bound_error\n85:\n");
                            vt_letter(strs, out, "U");
                            out.push_str("    jmp 88f\n86:\n");
                            vt_letter(strs, out, "A");
                            out.push_str("88:\n");
                        }
                        _ => unreachable!("checked"),
                    }
                    }
                }
                Expr::Index2(v, ie, ie2) => {
                    // DArr2 two-level read (hk88): middle casilla {ptr,
                    // len}, innermost {payload, tag}. A NIL middle cannot
                    // be walked: Harbour's dialog hangs headless - the
                    // registered clean bound-error failure mode, not a
                    // compat success.
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                    if var.ty == Ty::DArrRef2 {
                        // Through the borrowed middle of a three-level
                        // array (hk97): root bounds and base load through
                        // the owner's cell address.
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%r11), %rcx\n    jg 87f\n", var.off));
                        out.push_str("    mov (%r11), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    } else {
                        out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", var.off - 8));
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                        out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    }
                    out.push_str("    mov (%r10), %r11\n    test %r11, %r11\n    jz 87f\n");
                    out.push_str("    cmp $1, %rax\n    jl 87f\n    cmp 8(%r10), %rax\n    jg 87f\n");
                    if var.ty == Ty::DArr4 {
                        // Final casilla is a child-array {ptr, len}:
                        // null ptr is "U", non-null "A" (hk114).
                        out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    test %r10, %r10\n    jz 85f\n    jmp 86f\n87:\n    call hbc_bound_error\n85:\n");
                        vt_letter(strs, out, "U");
                        out.push_str("    jmp 88f\n86:\n");
                        vt_letter(strs, out, "A");
                        out.push_str("88:\n");
                    } else {
                        out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                        vt_classify_scalar(strs, out);
                    }
                }
                Expr::Index3(v, ie, ie2, ie3) => {
                    // ValType(a[i][j][k]) on a four-level root: the level-3
                    // child casilla {ptr, len} - null ptr is "U", non-null
                    // is "A" (hk103). Indices evaluate once, in order.
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, 8(%rsp)\n");
                    cg_expr(ie3, env, sigs, strs, out, target);
                    out.push_str(&format!("    mov (%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", var.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                    out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    out.push_str("    mov 8(%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%r10), %rcx\n    jg 87f\n");
                    out.push_str("    mov (%r10), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    out.push_str("    cmp $1, %rax\n    jl 87f\n    cmp 8(%r10), %rax\n    jg 87f\n");
                    out.push_str("    mov (%r10), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    add $16, %rsp\n    jmp 88f\n87:\n    add $16, %rsp\n    call hbc_bound_error\n88:\n");
                    out.push_str("    test %r10, %r10\n    jz 85f\n");
                    vt_letter(strs, out, "A");
                    out.push_str("    jmp 86f\n85:\n");
                    vt_letter(strs, out, "U");
                    out.push_str("86:\n");
                }
                Expr::Index4(v, ie, ie2, ie3, ie4) => {
                    // ValType(a[i][j][k][l]): the scalar Dyn casilla (hk103).
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, 8(%rsp)\n");
                    cg_expr(ie3, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, 16(%rsp)\n");
                    cg_expr(ie4, env, sigs, strs, out, target);
                    out.push_str(&format!("    mov (%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", var.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                    out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    out.push_str("    mov 8(%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%r10), %rcx\n    jg 87f\n");
                    out.push_str("    mov (%r10), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    out.push_str("    mov 16(%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%r10), %rcx\n    jg 87f\n");
                    out.push_str("    mov (%r10), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    out.push_str("    cmp $1, %rax\n    jl 87f\n    cmp 8(%r10), %rax\n    jg 87f\n");
                    out.push_str("    mov (%r10), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    add $32, %rsp\n    jmp 88f\n87:\n    add $32, %rsp\n    call hbc_bound_error\n88:\n");
                    vt_classify_scalar(strs, out);
                }
                _ => unreachable!("checked"),
            }
        }
        Expr::Call(id,args) if ["ltrim", "rtrim", "alltrim", "trim"].iter().any(|b| is_builtin(id,b)) => {
            let temp=expr_ty(&args[0],env,sigs)==Ty::StrOwn && !matches!(&args[0],Expr::Var(_));
            cg_value(&args[0],env,sigs,strs,out,target);
            out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n    mov %rax, %rdi\n    mov %rdx, %rsi\n");
            let mode=if is_builtin(id,"ltrim") {1} else if is_builtin(id,"alltrim") {3} else {2};
            out.push_str(&format!("    mov ${}, %edx\n    call hbc_trim\n",mode));
            if temp {
                out.push_str("    mov %rax, 8(%rsp)\n    mov %rdx, 16(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 8(%rsp), %rax\n    mov 16(%rsp), %rdx\n");
            }
            out.push_str("    add $32, %rsp\n");
        }
        Expr::Call(id, args) if is_output_call(id) => {
            cg_print_items(args, !is_builtin(id, "qout"), !is_builtin(id, "qout") && !is_builtin(id, "qqout"), is_builtin(id, "outerr"), env, sigs, strs, out, target);
            out.push_str("    mov $1, %eax\n    xor %edx, %edx\n"); // NIL tag/payload.
        }
        Expr::Call(id, args) if is_builtin(id, "asc") => {
            let temp = expr_ty(&args[0], env, sigs) == Ty::StrOwn && !matches!(&args[0], Expr::Var(_));
            cg_value(&args[0], env, sigs, strs, out, target);
            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_asc\n");
            if temp {
                out.push_str("    mov %rax, 8(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 8(%rsp), %rax\n");
            }
            out.push_str("    add $16, %rsp\n");
        }
        Expr::Call(id, args) if is_builtin(id, "chr") => {
            cg_expr(&args[0], env, sigs, strs, out, target);
            out.push_str("    mov %rax, %rdi\n    call hbc_chr\n");
        }
        Expr::Call(id, args) if is_builtin(id, "round") => {
            // Round(n, d) - hb_numRound (oracles hk384-hk386): the helper
            // returns the f64 pair convention (xmm0 = value, rdi = packed
            // dec | length<<16), like any float-returning call (63zd).
            cg_f64_operand(&args[0], env, sigs, strs, out, target);
            out.push_str("    sub $16, %rsp\n    movsd %xmm0, (%rsp)\n");
            cg_expr(&args[1], env, sigs, strs, out, target);
            out.push_str("    mov %rax, %rdi\n    movsd (%rsp), %xmm0\n    add $16, %rsp\n    call hbc_round\n");
        }
        Expr::Call(id, args) if is_builtin(id, "len") => {
            // len(s) for a string (hk217): the value pair's len half.
            if matches!(expr_ty(&args[0], env, sigs), Ty::Str | Ty::StrOwn) {
                cg_value(&args[0], env, sigs, strs, out, target);
                if expr_ty(&args[0], env, sigs) == Ty::StrOwn && !matches!(&args[0], Expr::Var(_)) {
                    out.push_str("    sub $16, %rsp\n    mov %rdx, (%rsp)\n    mov %rax, %rdi\n    call hbc_freestr\n    mov (%rsp), %rax\n    add $16, %rsp\n");
                } else {
                    out.push_str("    mov %rdx, %rax\n");
                }
                return;
            }
            // len(a) for a dynamic array: the length word of the slot.
            match &args[0] {
                Expr::Var(v) => {
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    match var.ty {
                        Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Hash => out.push_str(&format!("    mov -{}(%rbp), %rax\n", var.off - 8)),
                        Ty::DArrRef | Ty::DArrRef2 => out.push_str(&format!("    mov -{}(%rbp), %rax\n    mov 8(%rax), %rax\n", var.off)),
                        Ty::Arr(k) => out.push_str(&format!("    mov ${}, %rax\n", k)),
                        _ => unreachable!("checked"),
                    }
                }
                Expr::Index(v, ie) => {
                    // len(a[i]): borrow the child slot (probe m6). A
                    // null child (fresh ASize growth) is Harbour's NIL
                    // casilla: len() of it is Harbour's BASE/1111
                    // (hangs headless, oracle n2) - here a clean
                    // "Argument error: LEN", exit 1 (registered failure
                    // mode). An EMPTY child ({}) owns a header block and
                    // still reads 0 (oracle e4).
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    if var.ty == Ty::DArrRef2 {
                        // len(p[i]) through the borrowed middle of a
                        // three-level array (hk93): bounds and base load
                        // through the owner's cell address; the cell holds
                        // a child {ptr, len} and a null child is the same
                        // registered "Argument error: LEN" failure mode.
                        cg_expr(ie, env, sigs, strs, out, target);
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rax\n    jl 87f\n    cmp 8(%r11), %rax\n    jg 87f\n", var.off));
                        out.push_str("    mov (%r11), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r10\n    test %r10, %r10\n    jz hbc_len_error\n    mov 8(%rax), %rax\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                        return;
                    }
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str(&format!("    cmp $1, %rax\n    jl 87f\n    cmp -{}(%rbp), %rax\n    jg 87f\n", var.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                    out.push_str("    dec %rax\n    shl $4, %rax\n    mov 0(%r11,%rax), %r10\n    test %r10, %r10\n    jz hbc_len_error\n    mov 8(%r11,%rax), %rax\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                }
                Expr::Index2(v, ie, ie2) => {
                    // len(a[i][j]): borrow two levels (oracle pr4). A null
                    // child at either level is the NIL casilla: Harbour's
                    // BASE/1111 dialog hangs headless, so this is the same
                    // registered clean "Argument error: LEN" failure mode.
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                    out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", var.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                    out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    out.push_str("    mov (%r10), %r11\n    test %r11, %r11\n    jz hbc_len_error\n");
                    out.push_str("    cmp $1, %rax\n    jl 87f\n    cmp 8(%r10), %rax\n    jg 87f\n");
                    out.push_str("    dec %rax\n    shl $4, %rax\n    mov 0(%r11,%rax), %r10\n    test %r10, %r10\n    jz hbc_len_error\n    mov 8(%r11,%rax), %rax\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                }
                Expr::Index3(v, ie, ie2, ie3) => {
                    // len(a[i][j][k]) on a four-level array: borrow three
                    // levels (hk103). A null child at any level is the NIL
                    // casilla: Harbour's BASE/1111 dialog hangs headless,
                    // so this is the same registered clean "Argument
                    // error: LEN" failure mode.
                    let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, 8(%rsp)\n");
                    cg_expr(ie3, env, sigs, strs, out, target);
                    out.push_str(&format!("    mov (%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", var.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                    out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    out.push_str("    mov (%r10), %r11\n    test %r11, %r11\n    jz hbc_len_error\n");
                    out.push_str("    mov 8(%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%r10), %rcx\n    jg 87f\n");
                    out.push_str("    mov (%r10), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    out.push_str("    mov (%r10), %r11\n    test %r11, %r11\n    jz hbc_len_error\n");
                    out.push_str("    cmp $1, %rax\n    jl 87f\n    cmp 8(%r10), %rax\n    jg 87f\n");
                    out.push_str("    dec %rax\n    shl $4, %rax\n    mov 0(%r11,%rax), %r10\n    test %r10, %r10\n    jz hbc_len_error\n    mov 8(%r11,%rax), %rax\n    add $16, %rsp\n    jmp 88f\n87:\n    add $16, %rsp\n    call hbc_bound_error\n88:\n");
                }
                _ => unreachable!("len() of a non-variable in this increment"),
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hkeys") => {
            // hb_HKeys(h): the helper copies every key into a NEW array
            // the caller owns; the hash slot is passed by address and
            // never mutated. Returns rax = data pointer, rdx = count.
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    call hbc_hkeys\n", var.off));
            } else {
                unreachable!("checked: hb_HKeys takes a hash variable");
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hhaskey") => {
            // hb_HHasKey(h, key): the key evaluates first (borrowed),
            // then the hash slot goes by address. Returns rax = 1/0.
            // An owned key temporary (e.g. hb_HHasKey(h, keys[i])) is
            // freed right after the call - the helper only reads it
            // (leak found and fixed in iteration 52; t544).
            cg_value(&args[1], env, sigs, strs, out, target);
            let temp_key = expr_ty(&args[1], env, sigs) == Ty::StrOwn && !matches!(&args[1], Expr::Var(_));
            if temp_key {
                out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            } else {
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            }
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                if temp_key {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    call hbc_hhaskey\n    mov %rax, 16(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 16(%rsp), %rax\n    add $32, %rsp\n", var.off));
                } else {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    call hbc_hhaskey\n    add $16, %rsp\n", var.off));
                }
            } else {
                unreachable!("checked: hb_HHasKey takes a hash variable");
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hpos") => {
            // hb_HPos(h, key): the key evaluates first (borrowed),
            // then the hash slot goes by address. Returns rax = the
            // 1-based live position or 0 (hk162/hk163). An owned key
            // temporary is freed right after the call (the helper only
            // reads it).
            cg_value(&args[1], env, sigs, strs, out, target);
            let temp_key = expr_ty(&args[1], env, sigs) == Ty::StrOwn && !matches!(&args[1], Expr::Var(_));
            if temp_key {
                out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            } else {
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            }
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                if temp_key {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    call hbc_hpos\n    mov %rax, 16(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 16(%rsp), %rax\n    add $32, %rsp\n", var.off));
                } else {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    call hbc_hpos\n    add $16, %rsp\n", var.off));
                }
            } else {
                unreachable!("checked: hb_HPos takes a hash variable");
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hcasematch") => {
            // hb_HCaseMatch(h): the slot goes by address; returns
            // rax = the flag (1 sensitive, 0 insensitive; an untouched
            // empty hash answers the default 1 - hk169).
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                out.push_str(&format!("    lea -{}(%rbp), %rdi
    call hbc_hcasematch
", var.off));
            } else {
                unreachable!("checked: hb_HCaseMatch takes a hash variable");
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hscan") => {
            // hb_HScan(h, value [, start]): the value evaluates first
            // (borrowed), normalized to the Dyn pair rsi=tag,
            // rdx=payload (a plain integer gets tag 0); then the start
            // (rcx: 0 = scan from the first entry - omitted, NIL and an
            // explicit 0 all mean the same to the oracle, hk179/hk182);
            // then the slot by address. Returns rax = the 1-based
            // insertion-order position or 0 (hk178-hk183).
            cg_value(&args[1], env, sigs, strs, out, target);
            if expr_ty(&args[1], env, sigs) == Ty::I64 {
                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
            }
            if expr_ty(&args[1], env, sigs) == Ty::Bool {
                out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
            }
            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            if args.len() == 3 && !matches!(&args[2], Expr::Nil) {
                cg_value(&args[2], env, sigs, strs, out, target);
                out.push_str("    mov %rax, %rcx\n");
            } else {
                out.push_str("    xor %ecx, %ecx\n");
            }
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    call hbc_hscan\n", var.off));
            } else {
                unreachable!("checked: hb_HScan takes a hash variable");
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hkeyat") => {
            // hb_HKeyAt(h, n): the position evaluates first, then the
            // slot by address. hbc_hkeyat returns the stored key
            // ptr/len or 0 out of range, which takes the registered
            // clean bound-error exit (BASE/1187 dialog family -
            // hk184). The key is COPIED out with hbc_strcpy: the
            // caller owns an independent copy that survives the hash.
            cg_value(&args[1], env, sigs, strs, out, target);
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                out.push_str(&format!("    mov %rax, %rsi\n    lea -{}(%rbp), %rdi\n    call hbc_hkeyat\n", var.off));
            } else {
                unreachable!("checked: hb_HKeyAt takes a hash variable");
            }
            out.push_str("    test %rax, %rax\n    je 83f\n    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n    jmp 84f\n83:\n    call hbc_bound_error\n84:\n");
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hvalueat") => {
            // hb_HValueAt(h, n): the position evaluates first, then
            // the slot by address. hbc_hvalueat returns the entry's
            // {tag, payload} pointer or 0 out of range, which takes
            // the registered clean bound-error exit (hk185). Returns
            // rax = tag, rdx = payload (the value is only read).
            cg_value(&args[1], env, sigs, strs, out, target);
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                out.push_str(&format!("    mov %rax, %rsi\n    lea -{}(%rbp), %rdi\n    call hbc_hvalueat\n", var.off));
            } else {
                unreachable!("checked: hb_HValueAt takes a hash variable");
            }
            out.push_str("    test %rax, %rax\n    je 85f\n    mov (%rax), %rcx\n    mov 8(%rax), %rdx\n    mov %rcx, %rax\n    jmp 86f\n85:\n    call hbc_bound_error\n86:\n");
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hget") => {
            // hb_HGet(h, key [, default]): key first (borrowed), then
            // the slot by address; hbc_hget returns the entry's
            // {tag, payload} pointer or 0 on a miss, which takes the
            // registered clean bound-error exit (hk158a/b/d). The
            // default IS evaluated after the key and its value
            // discarded (hk158f1/f2/f3: effects fire even on a miss,
            // before the error). Returns rax = tag, rdx = payload.
            cg_value(&args[1], env, sigs, strs, out, target);
            let temp_key = expr_ty(&args[1], env, sigs) == Ty::StrOwn && !matches!(&args[1], Expr::Var(_));
            if temp_key {
                // An owned key copy (e.g. hb_HGet(h, keys[i])): the
                // lookup borrows it; free it right after hbc_hget
                // returns (same pattern as the h[k] read).
                out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            } else {
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            }
            if args.len() == 3 {
                // The default is EVALUATED after the key and its value
                // discarded (hk158f1/f2/f3).
                cg_value(&args[2], env, sigs, strs, out, target);
            }
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                if temp_key {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    call hbc_hget\n    mov %rax, 16(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 16(%rsp), %rax\n    add $32, %rsp\n", var.off));
                } else {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    call hbc_hget\n", var.off));
                }
            } else {
                unreachable!("checked: hb_HGet takes a hash variable");
            }
            out.push_str("    test %rax, %rax\n    je 81f\n    mov (%rax), %rcx\n    mov 8(%rax), %rdx\n    mov %rcx, %rax\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hgetdef") => {
            // hb_HGetDef(h, key [, default]): hbc_hget does the lookup
            // (borrowed hash and key); a miss is NOT an error here -
            // the default's saved Dyn cells are returned instead (or
            // NIL when no default was given), and the key is never
            // added (hk194). The default evaluates after the key,
            // before the lookup. Returns rax = tag, rdx = payload.
            cg_value(&args[1], env, sigs, strs, out, target);
            let temp_key = expr_ty(&args[1], env, sigs) == Ty::StrOwn && !matches!(&args[1], Expr::Var(_));
            if temp_key {
                out.push_str("    sub $48, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            } else {
                out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            }
            if args.len() == 3 {
                cg_value(&args[2], env, sigs, strs, out, target);
                if expr_ty(&args[2], env, sigs) == Ty::Dyn {
                    // Already a Dyn pair (rax = tag, rdx = payload).
                    out.push_str("    mov %rax, 16(%rsp)\n    mov %rdx, 24(%rsp)\n");
                } else if expr_ty(&args[2], env, sigs) == Ty::Bool {
                    // A logical: tag 3, payload 0/1.
                    out.push_str("    movq $3, 16(%rsp)\n    mov %rax, 24(%rsp)\n");
                } else {
                    // A pure i64 is 8 bytes: materialize its Dyn pair
                    // (tag 0, payload = value).
                    out.push_str("    movq $0, 16(%rsp)\n    mov %rax, 24(%rsp)\n");
                }
            } else {
                // No default: a miss yields NIL (tag 1, payload 0).
                out.push_str("    movq $1, 16(%rsp)\n    movq $0, 24(%rsp)\n");
            }
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                if temp_key {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    call hbc_hget\n    mov %rax, 32(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 32(%rsp), %rax\n", var.off));
                } else {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    call hbc_hget\n", var.off));
                }
            } else {
                unreachable!("checked: hb_HGetDef takes a hash variable");
            }
            let addend = if temp_key { 48 } else { 32 };
            out.push_str(&format!("    test %rax, %rax\n    je 81f\n    mov (%rax), %rcx\n    mov 8(%rax), %rdx\n    mov %rcx, %rax\n    jmp 82f\n81:\n    mov 16(%rsp), %rax\n    mov 24(%rsp), %rdx\n82:\n    add ${}, %rsp\n", addend));
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hsetdef") => {
            // hb_HSetDef(h, key [, default]): key first (borrowed),
            // then the default's Dyn cells (a pure i64 is materialized
            // as tag 0; no default becomes a NIL cell) plus the has_def
            // flag, then the slot by address; hbc_hsetdef applies the
            // measured add/keep/overwrite rules (hk196/hk196b/hk196d).
            // Returns rax = tag, rdx = payload.
            cg_value(&args[1], env, sigs, strs, out, target);
            let temp_key = expr_ty(&args[1], env, sigs) == Ty::StrOwn && !matches!(&args[1], Expr::Var(_));
            if temp_key {
                out.push_str("    sub $48, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            } else {
                out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
            }
            if args.len() == 3 {
                cg_value(&args[2], env, sigs, strs, out, target);
                if expr_ty(&args[2], env, sigs) == Ty::Dyn {
                    out.push_str("    mov %rax, 16(%rsp)\n    mov %rdx, 24(%rsp)\n");
                } else if expr_ty(&args[2], env, sigs) == Ty::Bool {
                    out.push_str("    movq $3, 16(%rsp)\n    mov %rax, 24(%rsp)\n");
                } else {
                    out.push_str("    movq $0, 16(%rsp)\n    mov %rax, 24(%rsp)\n");
                }
            } else {
                // No default: the cell is NIL (tag 1, payload 0); the
                // helper only writes it when the key is absent (hk196b)
                // and never overwrites a present key with it (hk196d).
                out.push_str("    movq $1, 16(%rsp)\n    movq $0, 24(%rsp)\n");
            }
            let has_def = args.len() == 3;
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                // r8 (has_def) is set right before the call: the def
                // evaluation above may clobber it, nothing below does.
                let setflag = if has_def { "    mov $1, %r8d\n" } else { "    xor %r8d, %r8d\n" };
                if temp_key {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    lea 16(%rsp), %rcx\n{}    call hbc_hsetdef\n    mov %rax, 32(%rsp)\n    mov %rdx, 40(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 32(%rsp), %rax\n    mov 40(%rsp), %rdx\n    add $48, %rsp\n", var.off, setflag));
                } else {
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    lea 16(%rsp), %rcx\n{}    call hbc_hsetdef\n    add $32, %rsp\n", var.off, setflag));
                }
            } else {
                unreachable!("checked: hb_HSetDef takes a hash variable");
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hclone") => {
            // hb_HClone(h): the helper deep-copies every entry into a
            // NEW block the caller owns (hk166: fully independent);
            // the source slot is passed by address and never mutated.
            // Returns rax = data pointer, rdx = count.
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    call hbc_hclone\n", var.off));
            } else {
                unreachable!("checked: hb_HClone takes a hash variable");
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_hvalues") => {
            // hb_HValues(h): the helper copies every value cell into a
            // NEW array the caller owns; the hash slot is passed by
            // address and never mutated. Returns rax = data pointer,
            // rdx = count.
            if let Expr::Var(v) = &args[0] {
                let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    call hbc_hvalues\n", var.off));
            } else {
                unreachable!("checked: hb_HValues takes a hash variable");
            }
        }
        Expr::Call(id, args) if is_builtin(id, "array") => {
            // Array(n): Dyn-element array with n NIL slots (oracle m10).
            // Array(n, m): n children of m NILs each (oracle m3). The
            // dimensions evaluate left to right; the value comes back as
            // {ptr, len} from a temporary slot (the caller owns the move).
            if args.len() == 1 {
                cg_expr(&args[0], env, sigs, strs, out, target);
                if expr_ty(&args[0], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    movq $0, (%rsp)\n    movq $0, 8(%rsp)\n");
                out.push_str("    mov %rax, %rsi\n    mov %rsp, %rdi\n    mov $16, %edx\n    xor %ecx, %ecx\n    call hbc_asize\n");
                out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
            } else if args.len() == 2 {
                cg_expr(&args[0], env, sigs, strs, out, target);
                if expr_ty(&args[0], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[1], env, sigs, strs, out, target);
                if expr_ty(&args[1], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    mov %rax, %rdx\n    mov (%rsp), %rsi\n    add $16, %rsp\n");
                out.push_str("    sub $16, %rsp\n    movq $0, (%rsp)\n    movq $0, 8(%rsp)\n");
                out.push_str("    mov %rsp, %rdi\n    call hbc_arraym\n");
                out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
            } else if args.len() == 3 {
                // Array(n, m, k): dimensions left to right, then the
                // composed constructor (oracle pr7).
                cg_expr(&args[0], env, sigs, strs, out, target);
                if expr_ty(&args[0], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[1], env, sigs, strs, out, target);
                if expr_ty(&args[1], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[2], env, sigs, strs, out, target);
                if expr_ty(&args[2], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    mov %rax, %rcx\n    mov (%rsp), %rdx\n    add $16, %rsp\n    mov (%rsp), %rsi\n    add $16, %rsp\n");
                out.push_str("    sub $16, %rsp\n    movq $0, (%rsp)\n    movq $0, 8(%rsp)\n");
                out.push_str("    mov %rsp, %rdi\n    call hbc_array3m\n");
                out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
            } else {
                // Array(n, m, k, l): dimensions left to right, then the
                // composed constructor (hk103).
                cg_expr(&args[0], env, sigs, strs, out, target);
                if expr_ty(&args[0], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[1], env, sigs, strs, out, target);
                if expr_ty(&args[1], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[2], env, sigs, strs, out, target);
                if expr_ty(&args[2], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[3], env, sigs, strs, out, target);
                if expr_ty(&args[3], env, sigs) == Ty::Dyn {
                    out.push_str("    call hbc_dyn_to_i64\n");
                }
                out.push_str("    mov %rax, %r8\n    mov (%rsp), %rcx\n    add $16, %rsp\n    mov (%rsp), %rdx\n    add $16, %rsp\n    mov (%rsp), %rsi\n    add $16, %rsp\n");
                out.push_str("    sub $16, %rsp\n    movq $0, (%rsp)\n    movq $0, 8(%rsp)\n");
                out.push_str("    mov %rsp, %rdi\n    call hbc_array4m\n");
                out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
            }
        }
        Expr::Call(id,args) if is_bitindex(id) => {
            cg_expr(&args[0],env,sigs,strs,out,target);
            let bit = match &args[1] { Expr::Int(v) => v.parse::<u32>().expect("checked"), _ => unreachable!("checked") };
            let op = if is_builtin(id,"hb_bittest") {"bt"} else if is_builtin(id,"hb_bitset") {"bts"} else {"btr"};
            out.push_str(&format!("    {} ${}, %rax\n",op,bit));
            if is_builtin(id,"hb_bittest") { out.push_str("    setc %al\n    movzbq %al, %rax\n"); }
        }
        Expr::Call(id, args) if is_bitop(id) => {
            cg_expr(&args[0], env, sigs, strs, out, target);
            if is_builtin(id,"hb_bitnot") { out.push_str("    not %rax\n"); }
            else {
                for a in &args[1..] {
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(a, env, sigs, strs, out, target);
                    let op = if is_builtin(id,"hb_bitand") {"and"} else if is_builtin(id,"hb_bitor") {"or"} else {"xor"};
                    out.push_str(&format!("    {} (%rsp), %rax\n    add $16, %rsp\n",op));
                }
            }
        }
        Expr::Call(id, args) if is_builtin(id, "min") || is_builtin(id, "max") => {
            let k = fresh_lbl();
            if expr_ty(&args[0], env, sigs) == Ty::F64 {
                cg_f64_load(&args[0], env, sigs, strs, out, target);
                out.push_str("    sub $32, %rsp\n    movsd %xmm0, (%rsp)\n    mov %rdi, 8(%rsp)\n");
                cg_f64_load(&args[1], env, sigs, strs, out, target);
                out.push_str("    movsd (%rsp), %xmm1\n    ucomisd %xmm0, %xmm1\n");
                let jump = if is_builtin(id, "min") { "jbe" } else { "jae" };
                // Ordered ties choose the FIRST item, including decimal metadata.
                out.push_str(&format!("    jp .Lmm_done{}\n    {} .Lmm_first{}\n    jmp .Lmm_done{}\n.Lmm_first{}:\n    movsd (%rsp), %xmm0\n    mov 8(%rsp), %rdi\n.Lmm_done{}:\n    add $32, %rsp\n", k,jump,k,k,k,k));
            } else {
                cg_expr(&args[0], env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(&args[1], env, sigs, strs, out, target);
                out.push_str("    mov (%rsp), %r10\n    cmp %rax, %r10\n");
                let jump = if is_builtin(id, "min") { "jle" } else { "jge" };
                out.push_str(&format!("    {} .Lmm_first{}\n    jmp .Lmm_done{}\n.Lmm_first{}:\n    mov %r10, %rax\n.Lmm_done{}:\n    add $16, %rsp\n", jump,k,k,k,k));
            }
        }
        Expr::Call(id, args) if is_builtin(id, "empty") => {
            let e = &args[0];
            let t = expr_ty(e, env, sigs);
            match t {
                Ty::F64 => {
                    cg_f64_load(e, env, sigs, strs, out, target);
                    out.push_str("    xorpd %xmm1, %xmm1\n    ucomisd %xmm1, %xmm0\n    sete %al\n    setnp %dl\n    and %dl, %al\n    movzbq %al, %rax\n");
                }
                Ty::Str | Ty::StrOwn => {
                    cg_value(e, env, sigs, strs, out, target);
                    let tmp = t == Ty::StrOwn && !matches!(e, Expr::Var(_));
                    if tmp { out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"); }
                    let k = fresh_lbl();
                    out.push_str(&format!("    mov %rax, %r10\n    mov %rdx, %rcx\n    mov $1, %eax\n.Lempty_loop{}:\n    test %rcx, %rcx\n    jz .Lempty_done{}\n    movzbl (%r10), %edx\n    cmp $32, %edx\n    je .Lempty_next{}\n    cmp $9, %edx\n    je .Lempty_next{}\n    cmp $10, %edx\n    je .Lempty_next{}\n    cmp $13, %edx\n    jne .Lempty_bad{}\n.Lempty_next{}:\n    inc %r10\n    dec %rcx\n    jmp .Lempty_loop{}\n.Lempty_bad{}:\n    xor %eax, %eax\n.Lempty_done{}:\n", k,k,k,k,k,k,k,k,k,k));
                    if tmp { out.push_str("    mov %rax, 8(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 8(%rsp), %rax\n    add $16, %rsp\n"); }
                }
                Ty::Arr(k) => { out.push_str(&format!("    mov ${}, %eax\n", if k == 0 {1} else {0})); }
                Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Hash => {
                    cg_value(e, env, sigs, strs, out, target);
                    out.push_str("    test %rdx, %rdx\n    sete %al\n    movzbq %al, %rax\n");
                }
                Ty::Dyn => { out.push_str("    mov $1, %eax\n"); } // literal NIL only
                Ty::Block(_) => { cg_expr(e, env, sigs, strs, out, target); out.push_str("    xor %eax, %eax\n"); }
                Ty::I64 | Ty::Bool => {
                    cg_expr(e, env, sigs, strs, out, target);
                    out.push_str("    test %rax, %rax\n    sete %al\n    movzbq %al, %rax\n");
                }
                _ => unreachable!("checked Empty shape"),
            }
        }
        Expr::Call(id, _) if is_builtin(id, "procname") => {
            let name = PROC_NAME.with(|v| v.borrow().clone());
            let ix = strs.len(); let len = name.len(); strs.push(name);
            out.push_str(&format!("    lea .Lstr{}(%rip), %rax\n    mov ${}, %edx\n", ix, len));
        }
        Expr::Call(id, _) if is_builtin(id, "hb_eol") => {
            let eol = if matches!(target, Target::Windows) { "\r\n" } else { "\n" };
            let ix = strs.len(); strs.push(eol.to_string());
            out.push_str(&format!("    lea .Lstr{}(%rip), %rax\n    mov ${}, %edx\n", ix, eol.len()));
        }
        Expr::Call(id, _) if is_builtin(id, "procline") => {
            let line = TRACE_LINE.with(|v| v.get());
            out.push_str(&format!("    mov ${}, %rax\n", line));
        }
        Expr::Call(id, _) if is_builtin(id, "hb_memcheck") => {
            // alloc/free balance counters (test harness only).
            out.push_str("    mov hbc_mem_allocs(%rip), %rax\n    sub hbc_mem_frees(%rip), %rax\n");
        }
        Expr::DArrNew => {
            // {} : the empty dynamic array owns a header-only block
            // (cap 0), so it is distinguishable from a NIL slot left by
            // ASize growth (null, 0) - Harbour types {} as ARRAY and the
            // grown casillas as NIL (oracles e4, n1, n2). len({}) == 0
            // either way.
            out.push_str("    mov $8, %rdi\n    call hbc_alloc\n    movq $0, (%rax)\n    add $8, %rax\n    xor %edx, %edx\n");
        }
        Expr::HashLit(_) => unreachable!("hash literals are emitted in statement position (local/assign initializers)"),
        Expr::BlockLit(id, _, _) => {
            // The block's value is its code pointer (8 bytes, Copy).
            out.push_str(&format!("    lea hbc_blk_{}(%rip), %rax\n", id));
        }
        Expr::Call(id, args) if is_builtin(id, "eval") => {
            // eval(b, a1..an): evaluate ALL arguments left to right (extras
            // are discarded afterwards, matching probe c7b), push the first
            // k as call arguments, then call the block pointer indirectly
            // with the standard convention.
            let k = match expr_ty(&args[0], env, sigs) { Ty::Block(k) => k, _ => unreachable!("checked") };
            for a in &args[1..] {
                cg_expr(a, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
            }
            if args.len() - 1 > k {
                out.push_str(&format!("    add ${}, %rsp\n", 16 * (args.len() - 1 - k)));
            }
            cg_expr(&args[0], env, sigs, strs, out, target);
            out.push_str("    mov %rax, %r11\n    call *%r11\n");
            if k > 0 {
                out.push_str(&format!("    add ${}, %rsp\n", 16 * k));
            }
        }
        Expr::Call(id, args) if is_builtin(id, "hb_pvalue") => {
            // hb_PValue(n) (multiarg): the n-th declared parameter of the
            // enclosing function as a Dyn casilla in rax=tag, rdx=payload;
            // an out-of-range index is NIL (tag 1). Integers tag 0 in
            // place, logicals tag 3, strings are COPIED to an owned tag-4
            // payload (the parameter keeps its own slot; a printed
            // temporary is freed by the `?` path, an assigned Dyn local at
            // the epilogue - hk259 ownership), a Dyn parameter shares its
            // casilla with the same string-clone contract as the call
            // boundary. `@`-received parameters load through the owner's
            // slot. The checker guarantees the index is I64/Dyn and every
            // declared parameter is Dyn-representable.
            let k = fresh_lbl();
            cg_expr(&args[0], env, sigs, strs, out, target);
            if expr_ty(&args[0], env, sigs) == Ty::Dyn {
                out.push_str("    call hbc_dyn_to_i64\n");
            }
            let cur = CUR_FN.with(|c| c.borrow().clone());
            let nparams = sigs.iter().find(|v| v.name == cur).map(|s| s.params.len()).unwrap_or(0);
            for i in 0..nparams {
                out.push_str(&format!("    cmp ${}, %rax\n    je .Lpv{}_{}\n", i + 1, k, i));
            }
            out.push_str(&format!("    mov $1, %eax\n    xor %edx, %edx\n    jmp .Lpve{}\n", k));
            for i in 0..nparams {
                // Parameters are the first frame slots, in declaration
                // order (cg_func).
                let v = env[i].clone();
                out.push_str(&format!(".Lpv{}_{}:\n", k, i));
                match v.ty {
                    Ty::I64 => out.push_str(&format!("    mov -{}(%rbp), %rdx\n    xor %eax, %eax\n", v.off)),
                    Ty::Bool => out.push_str(&format!("    mov -{}(%rbp), %rdx\n    mov $3, %eax\n", v.off)),
                    Ty::RefI64 => out.push_str(&format!("    mov -{}(%rbp), %r10\n    mov (%r10), %rdx\n    xor %eax, %eax\n", v.off)),
                    Ty::Str | Ty::StrOwn => {
                        out.push_str(&format!("    mov -{}(%rbp), %rdi\n    mov -{}(%rbp), %rsi\n    call hbc_strcpy\n    mov %rax, %rdx\n    mov $4, %eax\n", v.off, v.off - 8));
                    }
                    Ty::RefStrOwn => {
                        out.push_str(&format!("    mov -{}(%rbp), %r10\n    mov (%r10), %rdi\n    mov 8(%r10), %rsi\n    call hbc_strcpy\n    mov %rax, %rdx\n    mov $4, %eax\n", v.off));
                    }
                    Ty::Dyn => {
                        out.push_str(&format!("    mov -{}(%rbp), %rax\n    mov -{}(%rbp), %rdx\n", v.off, v.off - 8));
                        cg_dyn_clone_if_str(out);
                    }
                    other => unreachable!("the checker rejects hb_PValue over parameter type {:?}", other),
                }
                out.push_str(&format!("    jmp .Lpve{}\n", k));
            }
            out.push_str(&format!(".Lpve{}:\n", k));
        }
        Expr::Call(id, args) => {
            let _ = sigs;
            // Arguments are evaluated and pushed LEFT TO RIGHT (Harbour
            // order; it matters if an argument expression fails, e.g. an
            // integer division by zero), each in a 16-byte slot (keeps rsp
            // 16-aligned on both targets); arg k then sits at
            // 16*(n-k)(%rbp) in the callee after its prologue.
            let psig = sigs.iter().find(|v| v.name == *id).map(|v| v.params.clone());
            let pborrowed = sigs.iter().find(|v| v.name == *id).map(|v| v.borrowed.clone());
            for (ai, a) in args.iter().enumerate() {
                // Borrowed argument: `a[i]` on an array of arrays. The
                // index evaluates FIRST (Harbour order), then the bounds
                // walk yields the child cell's ADDRESS; the callee borrows
                // it for the call (oracles hk73/hk78/hk86/hk87). A NIL
                // casilla is Harbour's BASE/1123-family condition (his
                // dialog hangs headless - no oracle): clean exit 1 with
                // "Argument error: PARAM" (registered failure mode).
                if let Expr::ByRef(vn) = a {
                    // `@x` (hk216): the callee variant receives the ADDRESS
                    // of the owner's slot. Pass-on (`f(@p)` where p is
                    // itself @-received, hk220): the slot already holds the
                    // owner's address - forward it, never its own address.
                    let v = env.iter().rev().find(|x| x.name == *vn).expect("checked");
                    if matches!(v.ty, Ty::RefI64 | Ty::RefStrOwn) {
                        out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off));
                    } else {
                        out.push_str(&format!("    lea -{}(%rbp), %rax\n", v.off));
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    movq $0, 8(%rsp)\n");
                    continue;
                }
                if pborrowed.as_ref().and_then(|b| b.get(ai)).copied() == Some(true) {
                    if let Expr::Index(rid, rie) = a {
                        let rv = env.iter().rev().find(|x| x.name == *rid).expect("checked").clone();
                        if expr_ty(rie, env, sigs) == Ty::Dyn {
                            cg_expr(rie, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64\n");
                        } else {
                            cg_expr(rie, env, sigs, strs, out, target);
                        }
                        out.push_str(&format!("    cmp $1, %rax\n    jl 81f\n    cmp -{}(%rbp), %rax\n    jg 81f\n", rv.off - 8));
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n", rv.off));
                        out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    test %r11, %r11\n    jz hbc_param_error\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
                        out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    movq $0, 8(%rsp)\n");
                        continue;
                    }
                }
                let ta = expr_ty(a, env, sigs);
                let pty = psig.as_ref().and_then(|p| p.get(ai).copied());
                if pty == Some(Ty::F64) && ta == Ty::F64 {
                    // Float argument (63zd): the declared convention is
                    // the established F64 pair - value bits in xmm0,
                    // packed metadata in rdi (same as cg_f64_load and
                    // the F64 return convention) - stored into the
                    // argument's 16-byte stack slot like any other
                    // two-word argument. The dec is a COPY: the callee's
                    // own slot, its own arithmetic metadata.
                    cg_f64_load(a, env, sigs, strs, out, target);
                    out.push_str("    sub $16, %rsp\n    movsd %xmm0, (%rsp)\n    mov %rdi, 8(%rsp)\n");
                    continue;
                }
                if pty == Some(Ty::F64) && ta == Ty::I64 {
                    // Integer argument to a float parameter (63zd;
                    // oracles hk302/hk303/hk307): the callee holds a
                    // DOUBLE item, so the boundary converts with
                    // cvtsi2sd like the VM's (double)n reads (hk300).
                    // dec 0. The item LENGTH follows Harbour's
                    // provenance rule: a literal argument keeps the
                    // literal-text width (hb_str2number: ten or more
                    // written integer digits -> digits+1; hk307's
                    // 12345678901 prints width 12), a computed integer
                    // keeps HB_LONG_LENGTH (20 beyond 9999999999 /
                    // -999999999, else 10).
                    let lit_len: Option<u32> = if let Expr::Int(txt) = a {
                        let neg = txt.starts_with('-');
                        let digits = txt.trim_start_matches('-').len() as u32;
                        if !neg && digits >= 10 {
                            Some(digits + 1)
                        } else {
                            let v: i64 = txt.parse().expect("checked");
                            Some(if v > 9999999999 || v < -999999999 { 20 } else { 10 })
                        }
                    } else { None };
                    cg_expr(a, env, sigs, strs, out, target);
                    out.push_str("    cvtsi2sd %rax, %xmm0\n");
                    if let Some(l) = lit_len {
                        out.push_str(&format!("    mov ${}, %edi\n", l << 16));
                    } else {
                        let lw = fresh_lbl();
                        let ld = fresh_lbl();
                        out.push_str(&format!("    mov $10, %edi\n    mov $9999999999, %r11\n    cmp %r11, %rax\n    jg .Lf64w{}\n    cmp $-999999999, %rax\n    jge .Lf64w{}\n.Lf64w{}:\n    mov $20, %edi\n.Lf64w{}:\n    shl $16, %rdi\n", lw, ld, lw, ld));
                    }
                    out.push_str("    sub $16, %rsp\n    movsd %xmm0, (%rsp)\n    mov %rdi, 8(%rsp)\n");
                    continue;
                }
                if let Ty::Arr(k) = ta {
                    // Static array argument: materialize the boundary
                    // COPY as a dynamic array (header + tagged cells,
                    // same shape as cg_darr2_literal's inner block); the
                    // callee owns and frees it (33l).
                    if let Expr::Var(src) = a {
                        let sv = env.iter().rev().find(|x| x.name == *src).expect("checked").clone();
                        out.push_str("    sub $16, %rsp\n");
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + k * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", k));
                        for p in 0..k {
                            out.push_str(&format!("    mov -{}(%rbp), %r10\n", sv.off - 8 * p));
                            out.push_str(&format!("    mov (%rsp), %r11\n    movq $0, {}(%r11)\n    mov %r10, {}(%r11)\n", p * 16, p * 16 + 8));
                        }
                        out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $16, %rsp\n", k));
                        out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                        continue;
                    }
                }
                cg_value(a, env, sigs, strs, out, target);
                if ta == Ty::Dyn && pty == Some(Ty::I64) {
                    // Dyn argument to an i64 parameter: extract with the
                    // runtime tag check (NIL -> clean type error).
                    out.push_str("    call hbc_dyn_to_i64\n");
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    continue;
                }
                if ta == Ty::I64 && pty == Some(Ty::Dyn) {
                    // i64 argument to a Dyn parameter: tag it in.
                    out.push_str("    sub $16, %rsp\n    movq $0, (%rsp)\n    mov %rax, 8(%rsp)\n");
                    continue;
                }
                if ta == Ty::Bool && pty == Some(Ty::Dyn) {
                    // Logical argument to a Dyn parameter: tag 3, payload
                    // 0/1 (hk264). Scalar: no ownership transfer, the
                    // epilogue's tag-4-only free leaves it alone.
                    out.push_str("    sub $16, %rsp\n    movq $3, (%rsp)\n    mov %rax, 8(%rsp)\n");
                    continue;
                }
                if (ta == Ty::Str || ta == Ty::StrOwn) && pty == Some(Ty::Dyn) {
                    // String argument to a Dyn parameter: the callee owns
                    // its Dyn slot (freed at its epilogue), so the boundary
                    // hands over a fresh owned copy tagged 4 - caller and
                    // callee never share an allocation (hk259; same
                    // contract as Dyn->Dyn, cg_dyn_clone_if_str).
                    let temp = ta == Ty::StrOwn && !matches!(a, Expr::Var(_));
                    if temp { out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"); }
                    out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                    if temp {
                        // The callee gets its own copy; discard the input
                        // temporary only after copying (existing Dyn model).
                        out.push_str("    mov %rax, 8(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 8(%rsp), %rax\n    add $16, %rsp\n");
                    }
                    out.push_str("    sub $16, %rsp\n    movq $4, (%rsp)\n    mov %rax, 8(%rsp)\n");
                    continue;
                }
                if ta == Ty::Dyn {
                    // The callee OWNS its Dyn parameter (freed at its
                    // epilogue like any owned param): a string payload is
                    // cloned at the boundary so caller and callee never
                    // share an allocation.
                    cg_dyn_clone_if_str(out);
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    continue;
                }
                if ta == Ty::Str && pty == Some(Ty::StrOwn) {
                    // A rodata string argument to an owned-string
                    // parameter: the callee owns and frees its parameter,
                    // so the call boundary hands over a fresh copy.
                    out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                } else if ta == Ty::Str || ta == Ty::DArr || ta == Ty::DArr2 || ta == Ty::DArr3 || ta == Ty::DArr4 || ta == Ty::DArrS || ta == Ty::StrOwn || ta == Ty::Hash {
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    // An owned (moved) argument: null the source slot
                    // right after the copy, so the callee is the only
                    // owner and the caller's later frees see null.
                    if let Expr::Var(src) = a {
                        if matches!(ta, Ty::DArr | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::StrOwn | Ty::Hash) {
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::StrOwn | Ty::Hash)) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                            }
                        }
                    }
                } else {
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                }
            }
            // Omitted trailing parameters (multiarg): pad the boundary
            // with NIL casillas (tag 1, payload 0); the checker pinned
            // those parameters Dyn. The byref mask keeps the PROVIDED
            // arguments only - the padded positions are never `@`, and the
            // variant label must match collect_byref_variants exactly.
            let total = psig.as_ref().map(|p| p.len()).unwrap_or(args.len());
            for _ in args.len()..total {
                out.push_str("    sub $16, %rsp\n    movq $1, (%rsp)\n    movq $0, 8(%rsp)\n");
            }
            let brmask: Vec<bool> = args.iter().map(|a| matches!(a, Expr::ByRef(_))).collect();
            let call_lbl = if brmask.iter().any(|b| *b) {
                format!("{}__br{}", id, brmask.iter().map(|b| if *b { "1" } else { "0" }).collect::<String>())
            } else { id.clone() };
            out.push_str(&format!("    call hbc_fn_{}\n", call_lbl));
            if total > 0 {
                out.push_str(&format!("    add ${}, %rsp\n", 16 * total));
            }
        }
        Expr::ArrLit(_) => unreachable!("array literals are emitted via cg_array_value"),
        Expr::IdxCompound(id, ie, op, re) => {
            // a[i] op= e on a fixed integer array (arrayidx contract):
            // the index is evaluated once and FIRST, the BOUNDS CHECK
            // runs before the right side, then the right side once, and
            // the load, operation and store together. Harbour order,
            // verifier-observed (results-6de7d717 bounds_rhs_order):
            // a[0] += bump(@n) under ErrorBlock/RECOVER leaves n = 0 -
            // the bound error pre-empts the right side entirely, so no
            // rhs effect may run before the cell is known in range.
            // (The in-range order oracle is unchanged: a[++i] += Bump(@i)
            // stores into the cell the first index evaluation named.)
            // The cell is Copy i64, so no ownership is involved; the
            // expression yields the NEW cell value in rax. Wrapping
            // arithmetic, exactly like the scalar `x op= e` desugar into
            // Bin (hk246); Harbour's integer promotion to double on
            // overflow is the parked numeric decision (registered).
            let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
            let k = match v.ty { Ty::Arr(k) => k, _ => unreachable!("checked") };
            cg_expr(ie, env, sigs, strs, out, target);
            out.push_str(&format!("    cmp $1, %rax\n    jl 81f\n    cmp ${}, %rax\n    jg 81f\n", k));
            match target {
                Target::Linux => out.push_str("    push %rax\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
            }
            cg_expr(re, env, sigs, strs, out, target);
            if expr_ty(re, env, sigs) == Ty::Dyn {
                out.push_str("    call hbc_dyn_to_i64\n");
            }
            match target {
                Target::Linux => out.push_str("    mov %rax, %rcx\n    pop %r10\n"),
                Target::Windows => out.push_str("    mov %rax, %rcx\n    mov (%rsp), %r10\n    add $16, %rsp\n"),
            }
            // %r10 = index (evaluated once, bounds already checked),
            // %rcx = right side (evaluated once, after the bounds check)
            out.push_str(&format!("    lea -{}(%rbp), %r11\n    mov -8(%r11,%r10,8), %rax\n", v.off));
            match op {
                '+' => out.push_str("    add %rcx, %rax\n"),
                '-' => out.push_str("    sub %rcx, %rax\n"),
                '*' => out.push_str("    imul %rcx, %rax\n"),
                _ => unreachable!("checked"),
            }
            out.push_str("    mov %rax, -8(%r11,%r10,8)\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
        }
        Expr::Index(id, ie) => {
            let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
            if v.ty == Ty::Hash {
                // h["k"] read: hbc_hget scans live entries (byte compare
                // with length - probes h3b/h12). A miss is a clean bound
                // error here; Harbour shows its interactive dialog and
                // hangs headless (probes h3/h3c) - registered failure-mode
                // difference, same error condition. The lookup never
                // mutates the hash.
                cg_value(ie, env, sigs, strs, out, target);
                out.push_str("    mov %rax, %rsi\n");
                let temp_key = expr_ty(ie, env, sigs) == Ty::StrOwn && !matches!(&**ie, Expr::Var(_));
                if temp_key {
                    // An owned key copy (e.g. h[keys[i]]): the lookup
                    // borrows it; free it right after hbc_hget returns
                    // (the lookup never retains the key bytes).
                    out.push_str("    sub $32, %rsp\n    mov %rsi, (%rsp)\n");
                }
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    call hbc_hget\n", v.off));
                if temp_key {
                    out.push_str("    mov %rax, 8(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 8(%rsp), %rax\n    add $32, %rsp\n");
                }
                out.push_str("    test %rax, %rax\n    je 81f\n    mov (%rax), %rcx\n    mov 8(%rax), %rdx\n    mov %rcx, %rax\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
                return;
            }
            if v.ty == Ty::DArr {
                // Dynamic array read: bounds are 1..=len (runtime word);
                // elements are {tag, payload} pairs (rax=tag, rdx=payload).
                // Borrow only - nothing is moved or nulled.
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str(&format!("    cmp $1, %rax\n    jl 81f\n    cmp -{}(%rbp), %rax\n    jg 81f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n    jmp 82f\n");
                out.push_str("81:\n    call hbc_bound_error\n82:\n");
                return;
            }
            if v.ty == Ty::DArrRef {
                // Borrowed middle array (a[i] passed to this function):
                // the slot holds the child cell's ADDRESS; bounds and the
                // element pointer load THROUGH it, so callee reads see the
                // owner's current contents (oracle hk73).
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rax\n    jl 81f\n    cmp 8(%r11), %rax\n    jg 81f\n", v.off));
                out.push_str("    mov (%r11), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n    jmp 82f\n");
                out.push_str("81:\n    call hbc_bound_error\n82:\n");
                return;
            }
            if v.ty == Ty::DArrS {
                // Reading a key out of an hb_HKeys result COPIES it via
                // hbc_strcpy: the value in rax/rdx is owned by the
                // consumer (a StrOwn slot, a print item, or a hash
                // lookup), never a borrow into the array.
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str(&format!("    cmp $1, %rax\n    jl 81f\n    cmp -{}(%rbp), %rax\n    jg 81f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    # A grown casilla (ASize, hk13/hk14) is NIL: a string context\n    # gets a clean error; `? k[i]` prints NIL instead (Print arm).\n    cmpq $2, (%rax)\n    jne hbc_snil_error\n    mov 8(%rax), %rdi\n    mov -8(%rdi), %rsi\n    call hbc_strcpy\n    jmp 82f\n");
                out.push_str("81:\n    call hbc_bound_error\n82:\n");
                return;
            }
            let k = match v.ty { Ty::Arr(k) => k, _ => unreachable!("checked") };
            cg_expr(ie, env, sigs, strs, out, target);
            // Harbour base 1: valid indexes are 1..=k (probe a1). A runtime
            // miss exits via hbc_bound_error (noreturn); Harbour instead
            // opens an interactive error dialog (probes a1/a2) - a
            // registered failure-mode difference, same error condition.
            out.push_str(&format!("    cmp $1, %rax\n    jl 81f\n    cmp ${}, %rax\n    jg 81f\n", k));
            out.push_str(&format!("    lea -{}(%rbp), %r11\n    mov -8(%r11,%rax,8), %rax\n    jmp 82f\n", v.off));
            out.push_str("81:\n    call hbc_bound_error\n82:\n");
        }
        Expr::Index2(id, ie, ie2) => {
            // a[i][j] read: two transient indexed borrows (probe m1). The
            // indices are evaluated left to right, then both bounds are
            // checked; a null child has length 0, so indexing it is a
            // clean bound error (Harbour would show its dialog instead -
            // registered DIVERGE-FAILMODE).
            let var = env.iter().rev().find(|v| v.name == *id).expect("checked");
            if var.ty == Ty::DArrRef2 {
                // p[i][j] through the borrowed middle of a three-level
                // array (hk93): root bounds and base load through the
                // owner's cell address; the middle cell holds the child's
                // {ptr, len}; a null child has length 0 (same bound
                // error); the innermost cell is a scalar {tag, payload}.
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                if expr_ty(ie2, env, sigs) == Ty::Dyn {
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie2, env, sigs, strs, out, target);
                }
                out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rcx\n    jl 81f\n    cmp 8(%r11), %rcx\n    jg 81f\n", var.off));
                out.push_str("    mov (%r11), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                out.push_str("    cmp $1, %rax\n    jl 81f\n    cmp 8(%r10), %rax\n    jg 81f\n");
                out.push_str("    mov (%r10), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
                return;
            }
            if expr_ty(ie, env, sigs) == Ty::Dyn {
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie, env, sigs, strs, out, target);
            }
            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
            if expr_ty(ie2, env, sigs) == Ty::Dyn {
                cg_expr(ie2, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie2, env, sigs, strs, out, target);
            }
            out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
            // rcx = i, rax = j
            out.push_str(&format!("    cmp $1, %rcx\n    jl 81f\n    cmp -{}(%rbp), %rcx\n    jg 81f\n", var.off - 8));
            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
            out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
            // r10 = child slot; bounds-check j against the child length
            out.push_str("    cmp $1, %rax\n    jl 81f\n    cmp 8(%r10), %rax\n    jg 81f\n");
            out.push_str("    mov (%r10), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n    jmp 82f\n81:\n    call hbc_bound_error\n82:\n");
        }
        Expr::Index3(id, ie, ie2, ie3) => {
            // a[i][j][k] read: three transient borrows; indices evaluate
            // left to right, every level bounds-checked. A null child has
            // length 0, so indexing it is a clean bound error (same
            // registered failure mode as the two-level read).
            let var = env.iter().rev().find(|v| v.name == *id).expect("checked");
            if expr_ty(ie, env, sigs) == Ty::Dyn {
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie, env, sigs, strs, out, target);
            }
            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
            if expr_ty(ie2, env, sigs) == Ty::Dyn {
                cg_expr(ie2, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie2, env, sigs, strs, out, target);
            }
            out.push_str("    mov %rax, 8(%rsp)\n");
            if expr_ty(ie3, env, sigs) == Ty::Dyn {
                cg_expr(ie3, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie3, env, sigs, strs, out, target);
            }
            // (%rsp)=i, 8(%rsp)=j, rax=k
            out.push_str(&format!("    mov (%rsp), %rcx\n    cmp $1, %rcx\n    jl 81f\n    cmp -{}(%rbp), %rcx\n    jg 81f\n", var.off - 8));
            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
            out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
            // r10 = level-2 child slot; bounds-check j against its length
            out.push_str("    mov 8(%rsp), %rcx\n    cmp $1, %rcx\n    jl 81f\n    cmp 8(%r10), %rcx\n    jg 81f\n");
            out.push_str("    mov (%r10), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
            // r10 = level-3 child slot; bounds-check k against its length
            out.push_str("    cmp $1, %rax\n    jl 81f\n    cmp 8(%r10), %rax\n    jg 81f\n");
            out.push_str("    mov (%r10), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n");
            out.push_str("    add $16, %rsp\n    jmp 82f\n81:\n    add $16, %rsp\n    call hbc_bound_error\n82:\n");
        }
        Expr::Index4(id, ie, ie2, ie3, ie4) => {
            // a[i][j][k][l]: indices evaluate once, left to right (hk106),
            // every level bounds-checked; a null child has length 0, so
            // indexing it is a clean bound error (same registered failure
            // mode as the two/three-level read).
            let var = env.iter().rev().find(|v| v.name == *id).expect("checked");
            if expr_ty(ie, env, sigs) == Ty::Dyn {
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie, env, sigs, strs, out, target);
            }
            out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n");
            if expr_ty(ie2, env, sigs) == Ty::Dyn {
                cg_expr(ie2, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie2, env, sigs, strs, out, target);
            }
            out.push_str("    mov %rax, 8(%rsp)\n");
            if expr_ty(ie3, env, sigs) == Ty::Dyn {
                cg_expr(ie3, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie3, env, sigs, strs, out, target);
            }
            out.push_str("    mov %rax, 16(%rsp)\n");
            if expr_ty(ie4, env, sigs) == Ty::Dyn {
                cg_expr(ie4, env, sigs, strs, out, target);
                out.push_str("    call hbc_dyn_to_i64\n");
            } else {
                cg_expr(ie4, env, sigs, strs, out, target);
            }
            // (%rsp)=i, 8(%rsp)=j, 16(%rsp)=k, rax=l
            out.push_str(&format!("    mov (%rsp), %rcx\n    cmp $1, %rcx\n    jl 81f\n    cmp -{}(%rbp), %rcx\n    jg 81f\n", var.off - 8));
            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
            out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
            out.push_str("    mov 8(%rsp), %rcx\n    cmp $1, %rcx\n    jl 81f\n    cmp 8(%r10), %rcx\n    jg 81f\n");
            out.push_str("    mov (%r10), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
            out.push_str("    mov 16(%rsp), %rcx\n    cmp $1, %rcx\n    jl 81f\n    cmp 8(%r10), %rcx\n    jg 81f\n");
            out.push_str("    mov (%r10), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
            out.push_str("    cmp $1, %rax\n    jl 81f\n    cmp 8(%r10), %rax\n    jg 81f\n");
            out.push_str("    mov (%r10), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov (%rax), %r11\n    mov 8(%rax), %rdx\n    mov %r11, %rax\n");
            out.push_str("    add $32, %rsp\n    jmp 82f\n81:\n    add $32, %rsp\n    call hbc_bound_error\n82:\n");
        }
        Expr::Bin(op, a, b) => {
            // String `+` (oracle hk215): hbc_strcat copies BOTH operands
            // into a fresh owned buffer; owned temporaries (a nested
            // concat) are freed right after the copy, variables keep
            // theirs. Result: rax=ptr, rdx=len, owned by the consumer
            // (StrOwn slot, print item, comparison, hash key - the
            // established consumers free non-Var StrOwn).
            if *op == '+' && matches!(expr_ty(a, env, sigs), Ty::Str | Ty::StrOwn) {
                let a_tmp = expr_ty(a, env, sigs) == Ty::StrOwn && !matches!(a.as_ref(), Expr::Var(_));
                let b_tmp = expr_ty(b, env, sigs) == Ty::StrOwn && !matches!(b.as_ref(), Expr::Var(_));
                cg_value(a, env, sigs, strs, out, target);
                out.push_str("    sub $48, %rsp
    mov %rax, (%rsp)
    mov %rdx, 8(%rsp)
");
                cg_value(b, env, sigs, strs, out, target);
                out.push_str("    mov %rax, 16(%rsp)
    mov %rdx, %rcx
    mov %rax, %rdx
    mov (%rsp), %rdi
    mov 8(%rsp), %rsi
    call hbc_strcat
");
                out.push_str("    mov %rax, 24(%rsp)
    mov %rdx, 32(%rsp)
");
                if b_tmp {
                    out.push_str("    mov 16(%rsp), %rdi
    call hbc_freestr
");
                }
                if a_tmp {
                    out.push_str("    mov (%rsp), %rdi
    call hbc_freestr
");
                }
                out.push_str("    mov 24(%rsp), %rax
    mov 32(%rsp), %rdx
    add $48, %rsp
");
                return;
            }
            // Operands are i64 or Dyn (checked in analysis): a Dyn operand
            // is extracted with the runtime tag check (NIL payload -> clean
            // type error, Harbour's dialog is the registered difference).
            cg_expr(a, env, sigs, strs, out, target);
            if expr_ty(a, env, sigs) == Ty::Dyn {
                out.push_str("    call hbc_dyn_to_i64\n");
            }
            // Keep the lhs on the stack while evaluating the rhs. On Windows
            // a plain push would break 16-byte alignment for any call inside
            // the rhs (e.g. `1 + valor()`), so reserve a full 16-byte slot.
            match target {
                Target::Linux => out.push_str("    push %rax\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
            }
            cg_expr(b, env, sigs, strs, out, target);
            if expr_ty(b, env, sigs) == Ty::Dyn {
                out.push_str("    call hbc_dyn_to_i64\n");
            }
            match target {
                Target::Linux => out.push_str("    pop %rcx\n"), // %rcx = lhs, %rax = rhs
                Target::Windows => out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n"),
            }
            match op {
                '+' => out.push_str("    add %rcx, %rax\n"),
                '-' => {
                    out.push_str("    sub %rax, %rcx\n");
                    out.push_str("    mov %rcx, %rax\n");
                }
                '*' => out.push_str("    imul %rcx, %rax\n"),
                '/' => {
                    out.push_str("    mov %rax, %r10\n");
                    out.push_str("    mov %rcx, %rax\n");
                    out.push_str("    cqo\n");
                    out.push_str("    idiv %r10\n");
                }
                _ => unreachable!(),
            }
        }
    }
}

// Build a nested literal {{1,2},{3,4}} on the heap: outer block of child
// slots, one inner block per child. Children are built left to right and
// every element expression is evaluated exactly once, in order. Capacity
// equals the length (later AAdd growth doubles). On OOM the process aborts
// via hbc_oom; partially built children die with the process (no unwinding
// in this PoC - documented).
fn cg_darr3_literal(es: &[Expr], env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    // Parent block of (ptr, len) pairs; each child is emitted by the
    // two-level literal emitter, which leaves the child in rax/rdx and
    // keeps rsp balanced, so the parent pointer survives in scratch.
    let k = es.len();
    out.push_str("    sub $16, %rsp\n"); // (%rsp)=outer ptr
    out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + k * 16));
    out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", k));
    for (j, child) in es.iter().enumerate() {
        match child {
            Expr::DArrNew => {
                out.push_str("    mov $8, %rdi\n    call hbc_alloc\n    movq $0, (%rax)\n    add $8, %rax\n");
                out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    movq $0, {}(%r11)\n", j * 16, j * 16 + 8));
            }
            Expr::ArrLit(inner) => {
                cg_darr2_literal(inner, env, sigs, strs, out, target);
                out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", j * 16, j * 16 + 8));
            }
            _ => unreachable!("checked"),
        }
    }
    out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $16, %rsp\n", k));
}

fn cg_darr2_literal(es: &[Expr], env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    let k = es.len();
    out.push_str("    sub $48, %rsp\n"); // (%rsp)=outer ptr, 8(%rsp)=child ptr
    out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + k * 16));
    out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", k));
    for (j, child) in es.iter().enumerate() {
        match child {
            Expr::DArrNew => {
                // An empty child owns a header-only block too (see the
                // DArrNew arm in cg_expr): NIL-grown slots stay (null, 0).
                out.push_str("    mov $8, %rdi\n    call hbc_alloc\n    movq $0, (%rax)\n    add $8, %rax\n");
                out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    movq $0, {}(%r11)\n", j * 16, j * 16 + 8));
            }
            Expr::ArrLit(inner) => {
                let m = inner.len();
                out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, 8(%rsp)\n", m));
                for (p, ie) in inner.iter().enumerate() {
                    cg_expr(ie, env, sigs, strs, out, target);
                    if expr_ty(ie, env, sigs) == Ty::I64 {
                        out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                    }
                    if expr_ty(ie, env, sigs) == Ty::Bool {
                        out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                    }
                    out.push_str(&format!("    mov 8(%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p * 16, p * 16 + 8));
                }
                out.push_str(&format!("    mov (%rsp), %r11\n    mov 8(%rsp), %rax\n    mov %rax, {}(%r11)\n    movq ${}, {}(%r11)\n", j * 16, m, j * 16 + 8));
            }
            _ => unreachable!("checked"),
        }
    }
    out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $48, %rsp\n", k));
    let _ = target;
}

// Evaluate any expression whose value might be a Str: string literals need a
// .rodata slot, so they are handled here with a label table.
fn cg_value(e: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    if let Expr::ArrLit(es) = e {
        if es.iter().any(|x| matches!(x, Expr::ArrLit(inner) if inner.iter().any(|y| matches!(y, Expr::ArrLit(_) | Expr::DArrNew)))) {
            return cg_darr3_literal(es, env, sigs, strs, out, target);
        }
        if es.iter().any(|x| matches!(x, Expr::ArrLit(_) | Expr::DArrNew)) {
            return cg_darr2_literal(es, env, sigs, strs, out, target);
        }
        if !es.is_empty() && es.iter().all(|x| matches!(x, Expr::Str(_))) {
            // All-strings literal: dynamic array with {tag 2, owned copy}
            // cells - the same layout the AAdd string arm appends (hk254).
            // The base pointer rides the stack because hbc_strcpy may
            // clobber caller-saved registers.
            let m = es.len();
            out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
            out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n", m));
            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
            for (i, e) in es.iter().enumerate() {
                if let Expr::Str(s) = e {
                    let idx = strs.len();
                    strs.push(s.clone());
                    out.push_str(&format!("    lea .Lstr{}(%rip), %rdi\n    mov ${}, %esi\n    call hbc_strcpy\n", idx, s.as_bytes().len()));
                    out.push_str(&format!("    mov (%rsp), %r11\n    movq $2, {}(%r11)\n    mov %rax, {}(%r11)\n", i * 16, i * 16 + 8));
                }
            }
            out.push_str(&format!("    mov (%rsp), %rax\n    add $16, %rsp\n    mov ${}, %edx\n", m));
            return;
        }
        if es.iter().all(|x| matches!(x, Expr::Int(_) | Expr::Log(_))) && es.iter().any(|x| matches!(x, Expr::Log(_))) {
            return cg_darr1_literal(es, out);
        }
    }
    if let Expr::Str(s) = e {
        let idx = strs.len();
        strs.push(s.clone());
        out.push_str(&format!("    lea .Lstr{}(%rip), %rax\n", idx));
        out.push_str(&format!("    mov ${}, %edx\n", s.as_bytes().len()));
    } else {
        cg_expr(e, env, sigs, strs, out, target);
    }
}

// The materialization of a flat literal mixing integers and logicals:
// a dynamic tagged array ({tag, payload} cells; tag 0 = integer,
// tag 3 = logical), the same shape as an AAdd-grown array (hk201).
fn cg_darr1_literal(es: &[Expr], out: &mut String) {
    let m = es.len();
    out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
    out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n", m));
    out.push_str("    mov %rax, %r11\n");
    for (i, e) in es.iter().enumerate() {
        let (tag, val) = match e {
            Expr::Int(v) => (0i64, v.clone()),
            Expr::Log(b) => (3i64, if *b { "1".to_string() } else { "0".to_string() }),
            _ => unreachable!("checker"),
        };
        out.push_str(&format!("    movq ${}, {}(%r11)\n    movq ${}, {}(%r11)\n", tag, i * 16, val, i * 16 + 8));
    }
    out.push_str(&format!("    mov %r11, %rax\n    mov ${}, %edx\n", m));
}

// Emit an array-producing expression into a frame slot: a literal stores
// each element left to right; a whole-array variable COPIES (Rust [i64; N]
// is Copy - verified against rustc: mutating the copy leaves the source
// intact; Harbour shares a reference instead, a registered MODEL
// difference). Element k sits 8*k bytes below the first slot.
fn cg_array_value(e: &Expr, off: usize, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    match e {
        Expr::ArrLit(es) => {
            for (k, item) in es.iter().enumerate() {
                cg_expr(item, env, sigs, strs, out, target);
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off - 8 * k));
            }
        }
        Expr::Var(id) => {
            let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
            let n = match v.ty { Ty::Arr(n) => n, _ => unreachable!("checked") };
            for k in 0..n {
                out.push_str(&format!("    mov -{}(%rbp), %rax\n", v.off - 8 * k));
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off - 8 * k));
            }
        }
        _ => unreachable!("only literals and variables produce array values in this increment"),
    }
}

fn expr_ty(e: &Expr, env: &[CgLocal], sigs: &[Sig]) -> Ty {
    match e {
        Expr::Seq(es) => expr_ty(es.last().expect("nonempty"), env, sigs),
        Expr::Float(..) | Expr::FloatV(..) => Ty::F64,
        Expr::Int(_) | Expr::Inc(..) | Expr::IdxCompound(..) => Ty::I64,
        Expr::Bin(op, a, b) => {
            if matches!(expr_ty(a, env, sigs), Ty::Str | Ty::StrOwn) || matches!(expr_ty(b, env, sigs), Ty::Str | Ty::StrOwn) {
                Ty::StrOwn
            } else if *op == '%' {
                // Mirror of type_expr: runtime modulus is always F64.
                Ty::F64
            } else if *op == '^' {
                // Mirror of type_expr: runtime power is always F64.
                Ty::F64
            } else if *op == '/' && expr_ty(a, env, sigs) == Ty::I64 && expr_ty(b, env, sigs) == Ty::I64 {
                // Mirror of type_expr: runtime int/int division is F64.
                Ty::F64
            } else if expr_ty(a, env, sigs) == Ty::F64 || expr_ty(b, env, sigs) == Ty::F64 {
                // Mirror of type_expr: float arithmetic is F64.
                Ty::F64
            } else {
                Ty::I64
            }
        }
        Expr::Nil => Ty::Dyn,
        Expr::SelfObj | Expr::SelfGet(_) | Expr::Send(_, _, _) => Ty::Dyn, // unreachable: the checker rejects them first
        Expr::Str(_) => Ty::Str,
        Expr::Var(id) => match env.iter().find(|v| v.name == *id).expect("checked").ty {
            // A by-reference parameter reads as its pointee type (hk216).
            Ty::RefI64 => Ty::I64,
            Ty::RefStrOwn => Ty::StrOwn,
            t => t,
        },
        Expr::ByRef(id) => match env.iter().find(|v| v.name == *id).expect("checked").ty {
            Ty::RefI64 => Ty::I64,
            Ty::RefStrOwn => Ty::StrOwn,
            t => t,
        },
        Expr::Call(id, args) => {
            if is_builtin(id, "array") { return match args.len() { 1 => Ty::DArr, 2 => Ty::DArr2, 3 => Ty::DArr3, _ => Ty::DArr4 }; }
            if is_builtin(id, "hb_hkeys") { return Ty::DArrS; }
            if is_builtin(id, "hb_hhaskey") { return Ty::I64; }
            if is_builtin(id, "hb_hpos") { return Ty::I64; }
            if is_builtin(id, "hb_hscan") { return Ty::I64; }
            if is_builtin(id, "hb_hkeyat") { return Ty::StrOwn; }
            if is_builtin(id, "hb_hvalueat") { return Ty::Dyn; }
            if is_builtin(id, "hb_hcasematch") { return Ty::I64; }
            if is_builtin(id, "hb_hget") { return Ty::Dyn; }
            if is_builtin(id, "hb_hgetdef") { return Ty::Dyn; }
            if is_builtin(id, "hb_hsetdef") { return Ty::Dyn; }
            if is_builtin(id, "hb_hvalues") { return Ty::DArr; }
            if is_builtin(id, "hb_hclone") { return Ty::Hash; }
            if is_bitindex(id) { return if is_builtin(id,"hb_bittest") {Ty::Bool} else {Ty::I64}; }
            if is_bitop(id) { return Ty::I64; }
            if is_builtin(id, "min") || is_builtin(id, "max") { return expr_ty(&args[0], env, sigs); }
            if is_builtin(id, "empty") { return Ty::Bool; }
            if is_output_call(id) { return Ty::Dyn; }
            if is_builtin(id, "hb_pvalue") { return Ty::Dyn; }
            if is_builtin(id, "asc") || is_builtin(id, "eval") || is_builtin(id, "len") || is_builtin(id, "hb_memcheck") || is_builtin(id, "procline") { return Ty::I64; }
            if is_builtin(id, "valtype") || is_builtin(id, "hb_eol") || is_builtin(id, "procname") { return Ty::Str; } // hk88-hk92
            if ["ltrim", "rtrim", "alltrim", "trim"].iter().any(|b| is_builtin(id,b)) { return Ty::StrOwn; }
            if is_builtin(id, "chr") { return Ty::StrOwn; }
            if is_builtin(id, "round") { return Ty::F64; } // hk384-hk386
            if is_builtin(id, "iif") {
                // Branch unification mirrors the checker (oracle hk321).
                let ta = expr_ty(&args[1], env, sigs);
                let tb = expr_ty(&args[2], env, sigs);
                return if ta == Ty::F64 || tb == Ty::F64 { Ty::F64 }
                    else if matches!(ta, Ty::StrOwn) || matches!(tb, Ty::StrOwn) { Ty::StrOwn } else { ta };
            }
            sigs.iter().find(|v| v.name == *id).expect("checked").ret.expect("checked")
        }
        Expr::Log(_) | Expr::LNot(_) | Expr::LAnd(_, _) | Expr::LOr(_, _) | Expr::Cmp(..) => Ty::Bool,
        Expr::ArrLit(es) => {
            if es.iter().any(|e| matches!(e, Expr::ArrLit(inner) if inner.iter().any(|x| matches!(x, Expr::ArrLit(_) | Expr::DArrNew)))) { Ty::DArr3 }
            else if es.iter().any(|e| matches!(e, Expr::ArrLit(_) | Expr::DArrNew)) { Ty::DArr2 }
            else if es.iter().all(|e| matches!(e, Expr::Int(_) | Expr::Log(_))) && es.iter().any(|e| matches!(e, Expr::Log(_))) { Ty::DArr }
            else if !es.is_empty() && es.iter().all(|e| matches!(e, Expr::Str(_))) { Ty::DArrS }
            else { Ty::Arr(es.len()) }
        }
        Expr::Index(id, _) => match env.iter().find(|v| v.name == *id).map(|v| v.ty) {
            Some(Ty::Arr(_)) => Ty::I64,
            Some(Ty::DArrS) => Ty::StrOwn,
            _ => Ty::Dyn,
        },
        Expr::Index2(_, _, _) => Ty::Dyn,
        Expr::Index3(_, _, _, _) => Ty::Dyn,
        Expr::Index4(_, _, _, _, _) => Ty::Dyn,
        Expr::BlockLit(_, ps, _) => Ty::Block(ps.len()),
        Expr::DArrNew => Ty::DArrU,
        Expr::HashLit(_) => Ty::Hash,
    }
}

// Names passed as `@x` anywhere in a body: those locals need owned-capable
// slots from the start, because the callee frees and re-stores through the
// borrowed pointer (hk218). Syntactic walk, mirrors the checker's widening.
fn byref_names_in(stmts: &[Stmt]) -> std::collections::HashSet<String> {
    fn ex(e: &Expr, out: &mut std::collections::HashSet<String>) {
        match e {
            Expr::Seq(es) => { for x in es { ex(x, out); } }
            Expr::Call(_, args) => {
                for a in args {
                    match a {
                        Expr::ByRef(vn) => { out.insert(vn.clone()); }
                        other => ex(other, out),
                    }
                }
            }
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) | Expr::LAnd(a, b) | Expr::LOr(a, b) => { ex(a, out); ex(b, out); }
            Expr::LNot(a) => ex(a, out),
            Expr::Index(_, a) => ex(a, out),
            Expr::IdxCompound(_, a, _, b) => { ex(a, out); ex(b, out); }
            Expr::Index2(_, a, b) => { ex(a, out); ex(b, out); }
            Expr::Index3(_, a, b, c) => { ex(a, out); ex(b, out); ex(c, out); }
            Expr::Index4(_, a, b, c, d) => { ex(a, out); ex(b, out); ex(c, out); ex(d, out); }
            Expr::ArrLit(es) => { for x in es { ex(x, out); } }
            Expr::HashLit(ps) => { for (k, v) in ps { ex(k, out); ex(v, out); } }
            Expr::BlockLit(_, _, body) => { for x in body { ex(x, out); } }
            Expr::Send(o, _, args) => { ex(o, out); for a in args { ex(a, out); } }
            _ => {}
        }
    }
    fn st(stmts: &[Stmt], out: &mut std::collections::HashSet<String>) {
        for s in stmts {
            match s {
                Stmt::Local(_, _, e) | Stmt::Assign(_, _, e) | Stmt::Ret(_, Some(e)) | Stmt::CallStmt(_, e) => ex(e, out),
                Stmt::Print(_, es, _) => { for e in es { ex(e, out); } }
                Stmt::If(_, c, t, el) => { ex(c, out); st(t, out); st(el, out); }
                Stmt::While(_, c, b) => { ex(c, out); st(b, out); }
                Stmt::For(_, _, a, b, _, body) => { ex(a, out); ex(b, out); st(body, out); }
                Stmt::ForEach(_, _, c, body) => { ex(c, out); st(body, out); }
                _ => {}
            }
        }
    }
    let mut out = std::collections::HashSet::new();
    st(stmts, &mut out);
    out
}

// The (callee, mask) set of `@`-receiving variants actually used, syntactic.
fn collect_byref_variants(funcs: &[Func]) -> std::collections::BTreeSet<(String, Vec<bool>)> {
    fn ex(e: &Expr, out: &mut std::collections::BTreeSet<(String, Vec<bool>)>) {
        match e {
            Expr::Seq(es) => { for x in es { ex(x, out); } }
            Expr::Call(id, args) => {
                let mask: Vec<bool> = args.iter().map(|a| matches!(a, Expr::ByRef(_))).collect();
                if mask.iter().any(|b| *b) {
                    out.insert((id.clone(), mask));
                }
                for a in args { if !matches!(a, Expr::ByRef(_)) { ex(a, out); } }
            }
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) | Expr::LAnd(a, b) | Expr::LOr(a, b) => { ex(a, out); ex(b, out); }
            Expr::LNot(a) => ex(a, out),
            Expr::Index(_, a) => ex(a, out),
            Expr::IdxCompound(_, a, _, b) => { ex(a, out); ex(b, out); }
            Expr::Index2(_, a, b) => { ex(a, out); ex(b, out); }
            Expr::Index3(_, a, b, c) => { ex(a, out); ex(b, out); ex(c, out); }
            Expr::Index4(_, a, b, c, d) => { ex(a, out); ex(b, out); ex(c, out); ex(d, out); }
            Expr::ArrLit(es) => { for x in es { ex(x, out); } }
            Expr::HashLit(ps) => { for (k, v) in ps { ex(k, out); ex(v, out); } }
            Expr::BlockLit(_, _, body) => { for x in body { ex(x, out); } }
            Expr::Send(o, _, args) => { ex(o, out); for a in args { ex(a, out); } }
            _ => {}
        }
    }
    fn st(stmts: &[Stmt], out: &mut std::collections::BTreeSet<(String, Vec<bool>)>) {
        for s in stmts {
            match s {
                Stmt::Local(_, _, e) | Stmt::Assign(_, _, e) | Stmt::Ret(_, Some(e)) | Stmt::CallStmt(_, e) => ex(e, out),
                Stmt::Print(_, es, _) => { for e in es { ex(e, out); } }
                Stmt::If(_, c, t, el) => { ex(c, out); st(t, out); st(el, out); }
                Stmt::While(_, c, b) => { ex(c, out); st(b, out); }
                Stmt::For(_, _, a, b, _, body) => { ex(a, out); ex(b, out); st(body, out); }
                Stmt::ForEach(_, _, c, body) => { ex(c, out); st(body, out); }
                _ => {}
            }
        }
    }
    let mut out = std::collections::BTreeSet::new();
    for f in funcs { st(&f.stmts, &mut out); }
    out
}

// Layout pass: assigns stack slots in declaration order and computes the
// total frame size. Branch locals get their own slots and are scoped: the
// env is truncated at each branch join. The codegen walk below rebuilds
// the exact same env, so offsets match.
// Dyn slot write preludes (hk242). INVARIANT: tag 2 = a BORROWED string
// view (FOR EACH over hash keys; payload-8 is the length header) and is
// never freed; tag 4 = an OWNED string (16-byte header layout) freed by
// exactly one owner (slot overwrite, epilogue, or a print/compare temp).
// Every store into a Dyn slot first releases a live tag-4 payload.
fn cg_dyn_free_old(out: &mut String, off: usize) {
    out.push_str(&format!("    cmpq $4, -{}(%rbp)\n    jne 87f\n    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 87f\n    call hbc_freestr\n87:\n", off, off - 8));
}

// rax=tag, rdx=payload -> the pair with any string (tag 2 or 4) cloned
// into a fresh owned tag-4 copy. Scalar tags pass through untouched.
fn cg_dyn_clone_if_str(out: &mut String) {
    out.push_str("    cmp $2, %rax\n    je 88f\n    cmp $4, %rax\n    jne 89f\n88:\n    mov %rdx, %rdi\n    mov -8(%rdx), %rsi\n    call hbc_strcpy\n    mov %rax, %rdx\n    mov $4, %eax\n89:\n");
}

fn layout_locals(stmts: &[Stmt], env: &mut Vec<CgLocal>, sigs: &[Sig], frame: &mut usize, darr_slots: &mut Vec<(usize, u8)>, dyn_names: &std::collections::HashSet<String>, byref_names: &std::collections::HashSet<String>) {
    for (si, s) in stmts.iter().enumerate() {
        match s {
            Stmt::Local(_, id, e) => {
                let mut t = expr_ty(e, env, sigs);
                // Same prescan widening as cg_stmts (probe n2): an i64
                // initializer whose local later receives a Dyn value gets
                // the 16-byte slot.
                if t == Ty::I64 && dyn_names.contains(id) { t = Ty::Dyn; }
                // Same `@s` widening as cg_stmts (hk218): owned-capable slot.
                if t == Ty::Str && byref_names.contains(id) { t = Ty::StrOwn; }
                // Bare-local FOR counter (hk336): i64 slot from
                // declaration, in lockstep with the checker through the
                // one shared predicate.
                if t == Ty::Dyn && matches!(e, Expr::Nil) && !byref_names.contains(id) && bare_local_is_for_counter(stmts, si, id) { t = Ty::I64; }
                *frame += size_of(t);
                env.push(CgLocal { name: id.clone(), ty: t, off: *frame });
                if matches!(t, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::StrOwn | Ty::Hash | Ty::Dyn) {
                    darr_slots.push((*frame, if t == Ty::Dyn { 7 } else if t == Ty::Hash { 2 } else if t == Ty::DArr3 { 3 } else if t == Ty::DArr4 { 6 } else if t == Ty::DArrS { 4 } else if t == Ty::StrOwn { 5 } else { (t == Ty::DArr2) as u8 }));
                }
            }
            Stmt::AAdd(_, id, e) => {
                // Replicate the checker's element-type pinning so later
                // expr_ty lookups and the epilogue agree with it.
                let vt = expr_ty(e, env, sigs);
                let mut flip = None;
                if let Some(v) = env.iter_mut().find(|v| v.name == *id) {
                    if v.ty == Ty::DArrU {
                        v.ty = if matches!(vt, Ty::DArr | Ty::DArrU) { Ty::DArr2 } else if matches!(vt, Ty::Str | Ty::StrOwn) { Ty::DArrS } else { Ty::DArr };
                        flip = Some((v.off, if v.ty == Ty::DArr2 { 1 } else if v.ty == Ty::DArrS { 4 } else { 0 }));
                    }
                }
                if let Some((off, deep)) = flip {
                    if let Some(slot) = darr_slots.iter_mut().find(|(o, _)| *o == off) {
                        slot.1 = deep;
                    }
                }
            }
            Stmt::Assign(_, id, e) => {
                let vt = expr_ty(e, env, sigs);
                let mut flip = None;
                if let Some(v) = env.iter_mut().find(|v| v.name == *id) {
                    if v.ty == Ty::DArrU && matches!(vt, Ty::DArr | Ty::DArr2) {
                        v.ty = vt;
                        flip = Some((v.off, (v.ty == Ty::DArr2) as u8));
                    }
                }
                if let Some((off, deep)) = flip {
                    if let Some(slot) = darr_slots.iter_mut().find(|(o, _)| *o == off) {
                        slot.1 = deep;
                    }
                }
            }
            Stmt::If(_, _, then_s, else_s) => {
                let mark = env.len();
                layout_locals(then_s, env, sigs, frame, darr_slots, dyn_names, byref_names);
                env.truncate(mark);
                layout_locals(else_s, env, sigs, frame, darr_slots, dyn_names, byref_names);
                env.truncate(mark);
            }
            Stmt::While(_, _, body) => {
                let mark = env.len();
                layout_locals(body, env, sigs, frame, darr_slots, dyn_names, byref_names);
                env.truncate(mark);
            }
            Stmt::For(_, var, _, _, _, body) => {
                let mark = env.len();
                *frame += 8; // hidden slot holding the evaluated end bound
                // Reuse (hk323): the existing slot is written, no new one.
                if !env.iter().any(|v| v.name == *var) {
                    *frame += 8;
                    env.push(CgLocal { name: var.clone(), ty: Ty::I64, off: *frame });
                }
                layout_locals(body, env, sigs, frame, darr_slots, dyn_names, byref_names);
                env.truncate(mark);
            }
            Stmt::ForEach(_, var, coll, body) => {
                // No shadow push: several codegen lookups take the FIRST
                // name match, so the existing local is RETYPED to Dyn and
                // pointed at the hidden element slot for the body, then
                // restored (the outer slot is never written).
                *frame += 16; // hidden pair: collection (ptr, count)
                if matches!(coll, Expr::Call(..)) {
                    // A temporary collection (call result) is OWNED:
                    // registered so the prologue zeroes it and the
                    // epilogue frees it on every exit path.
                    let t = expr_ty(coll, env, sigs);
                    let class = if t == Ty::Hash { 2 } else if t == Ty::DArrS { 4 } else { 0 };
                    darr_slots.push((*frame, class));
                }
                *frame += 8; // hidden slot: 1-based iteration index
                *frame += 16; // loop variable: the current element as a Dyn
                let kl = env.iter().position(|v| v.name == *var).expect("checker found the local");
                let saved = (env[kl].ty, env[kl].off);
                env[kl].ty = Ty::Dyn;
                env[kl].off = *frame;
                layout_locals(body, env, sigs, frame, darr_slots, dyn_names, byref_names);
                env[kl].ty = saved.0;
                env[kl].off = saved.1;
            }
            _ => {}
        }
    }
}

// `$` containment scan (oracle hk341): needle in rax/rdx, haystack in
// rcx/r8; result 0/1 in rax. Empty needle or needle longer than the
// haystack is .F. (measured). Case-sensitive byte compare. Clobbers rcx,
// r8, r10, r11 and rax; leaf code with no calls and no stack use, so it
// adds no ABI surface (no helper symbol, no canary needed).
fn cg_str_contains(out: &mut String, k: usize) {
    out.push_str(&format!("    test %rdx, %rdx\n    je .Lsct_f{k}\n    cmp %r8, %rdx\n    ja .Lsct_f{k}\n    sub %rdx, %r8\n    inc %r8\n.Lsct_o{k}:\n    xor %r10, %r10\n.Lsct_i{k}:\n    movzbl (%rcx,%r10), %r11d\n    cmp (%rax,%r10), %r11b\n    jne .Lsct_n{k}\n    inc %r10\n    cmp %rdx, %r10\n    jb .Lsct_i{k}\n    mov $1, %r11d\n    jmp .Lsct_d{k}\n.Lsct_n{k}:\n    inc %rcx\n    dec %r8\n    jnz .Lsct_o{k}\n.Lsct_f{k}:\n    xor %r11d, %r11d\n.Lsct_d{k}:\n    mov %r11d, %eax\n"));
}

// Emits the comparison and jumps to true_label when it holds.
// rcx = lhs, rax = rhs; cmp computes lhs - rhs. On Windows the lhs is kept
// in a 16-byte slot so a call inside either operand keeps ABI alignment.
fn cg_cond_jump(cond: &Expr, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target, true_label: &str) {
    match cond {
        Expr::Log(b) => {
            out.push_str(&format!("    mov ${}, %eax\n    test %rax, %rax\n    jnz {}\n", if *b { 1 } else { 0 }, true_label));
        }
        Expr::LNot(a) => {
            // True when the operand is FALSE.
            let k = fresh_lbl();
            cg_cond_jump(a, env, sigs, strs, out, target, &format!(".Lnot{}", k));
            out.push_str(&format!("    jmp {}\n.Lnot{}:\n", true_label, k));
        }
        Expr::LAnd(a, b) => {
            let k = fresh_lbl();
            cg_cond_jump(a, env, sigs, strs, out, target, &format!(".Land{}", k));
            out.push_str(&format!("    jmp .Lande{}\n.Land{}:\n", k, k));
            cg_cond_jump(b, env, sigs, strs, out, target, true_label);
            out.push_str(&format!(".Lande{}:\n", k));
        }
        Expr::LOr(a, b) => {
            cg_cond_jump(a, env, sigs, strs, out, target, true_label);
            cg_cond_jump(b, env, sigs, strs, out, target, true_label);
        }
        // NIL against a string is always .F. under `=` (probe n1); only
        // `=` / `#` reach codegen (analysis rejects ordering NIL).
        Expr::Cmp(op, a, b) if (matches!(**a, Expr::Nil) && matches!(expr_ty(b, env, sigs), Ty::Str | Ty::StrOwn))
            || (matches!(**b, Expr::Nil) && matches!(expr_ty(a, env, sigs), Ty::Str | Ty::StrOwn)) => {
            // The result is a constant, but BOTH operands still evaluate
            // left to right (a call may print; an index may raise a bound
            // error) - only the comparison itself is folded (probe n1).
            // An owned temporary (e.g. keys[i]) is freed after evaluation.
            let a_tmp = expr_ty(a, env, sigs) == Ty::StrOwn && !matches!(&**a, Expr::Var(_));
            let b_tmp = expr_ty(b, env, sigs) == Ty::StrOwn && !matches!(&**b, Expr::Var(_));
            cg_value(a, env, sigs, strs, out, target);
            if a_tmp { out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"); }
            cg_value(b, env, sigs, strs, out, target);
            if b_tmp { out.push_str("    mov %rax, %rdi\n    call hbc_freestr\n"); }
            if a_tmp { out.push_str("    mov (%rsp), %rdi\n    call hbc_freestr\n    add $16, %rsp\n"); }
            if matches!(op, CmpOp::Ne) {
                out.push_str(&format!("    jmp {}\n", true_label));
            }
            // Eq: the condition is never true - fall through.
        }
        Expr::Cmp(op, a, b) if {
            let cas = |e: &Expr| matches!(e, Expr::Index(v, _) if env.iter().any(|x| x.name == *v && matches!(x.ty, Ty::DArr2 | Ty::DArr3)));
            matches!(op, CmpOp::Eq | CmpOp::Ne | CmpOp::EqEq) && ((cas(a) && matches!(**b, Expr::Nil)) || (cas(b) && matches!(**a, Expr::Nil)))
        } => {
            // Casilla = NIL (oracle n4): the index evaluates ONCE
            // (bounds-checked); the child pointer 0 is the NIL casilla.
            // The NIL literal emits nothing.
            let (v, ie) = if let Expr::Index(v, ie) = &**a { (v, ie) } else if let Expr::Index(v, ie) = &**b { (v, ie) } else { unreachable!("guarded") };
            let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
            cg_expr(ie, env, sigs, strs, out, target);
            out.push_str(&format!("    cmp $1, %rax\n    jl 97f\n    cmp -{}(%rbp), %rax\n    jg 97f\n", var.off - 8));
            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
            out.push_str("    dec %rax\n    shl $4, %rax\n    mov 0(%r11,%rax), %rax\n");
            out.push_str("    test %rax, %rax\n    jmp 98f\n97:\n    call hbc_bound_error\n98:\n");
            let j = match op { CmpOp::Eq | CmpOp::EqEq => "jz", _ => "jnz" };
            out.push_str(&format!("    {} {}\n", j, true_label));
        }
        Expr::Cmp(op, a, b) if expr_ty(a, env, sigs) == Ty::Dyn || expr_ty(b, env, sigs) == Ty::Dyn => {
            let ta = expr_ty(a, env, sigs);
            let tb = expr_ty(b, env, sigs);
            if ta == Ty::Str || tb == Ty::Str || ta == Ty::StrOwn || tb == Ty::StrOwn {
                // Dyn against a string: runtime dispatch on the Dyn
                // tag. tag 2 (string element, e.g. the FOR EACH
                // variable over hb_HKeys): a REAL Harbour comparison -
                // `=`/`#` via hbc_str_eq and ordering via hbc_str_cmp,
                // both over the right operand's length with the left
                // NUL-padded (xBase prefix rule; oracles hk33/hk37 and
                // hk36/hk39/hk40/hk43/hk51, same helpers as b23/b22).
                // tag 1 (NIL): `=` .F., `#` .T. (hk35, n1); ordering
                // raises Harbour's error condition. tag 0 (a number):
                // Harbour raises BASE/1071 `=`, BASE/1072 `#`,
                // BASE/1073 `<`, 1075 `>`, 1074 `<=`, 1076 `>=`
                // (hk34/hk38/hk42/hk44-hk46; hk41/hk47/hk49/hk50 for
                // NIL; error dialogs that hang headless) - clean named
                // exit 1 here (registered failure modes, not exact
                // equivalence). Both operands evaluate left to right;
                // an owned string temporary is freed after the
                // comparison.
                let a_tmp = ta == Ty::StrOwn && !matches!(&**a, Expr::Var(_));
                let b_tmp = tb == Ty::StrOwn && !matches!(&**b, Expr::Var(_));
                let tmp = a_tmp || b_tmp;
                cg_value(a, env, sigs, strs, out, target);
                match target {
                    Target::Linux => out.push_str("    push %rax\n    push %rdx\n"),
                    Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n"),
                }
                cg_value(b, env, sigs, strs, out, target);
                out.push_str("    mov %rax, %rcx\n    mov %rdx, %r8\n");
                match target {
                    Target::Linux => out.push_str("    pop %rdx\n    pop %rax\n"),
                    Target::Windows => out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n"),
                }
                // Normalize: rax,rdx = string (ptr,len); r10 = dyn tag,
                // r11 = dyn payload. The string side is the only one
                // that can be an owned temporary.
                if ta == Ty::Dyn {
                    out.push_str("    mov %rax, %r10\n    mov %rdx, %r11\n    mov %rcx, %rax\n    mov %r8, %rdx\n");
                } else {
                    out.push_str("    mov %rcx, %r10\n    mov %r8, %r11\n");
                }
                let lid = fresh_lbl();
                out.push_str(&format!("    cmp $2, %r10\n    je .Ldys{}\n    cmp $4, %r10\n    je .Ldys{}\n", lid, lid));
                match op {
                    CmpOp::Eq | CmpOp::Ne | CmpOp::EqEq => {
                        out.push_str(&format!("    cmp $0, %r10\n    je .Ldyn{}\n", lid));
                        // tag 1 (NIL) or any other tag: the previous
                        // fold - `=` is .F., `#` is .T. (hk35, n1);
                        // `==` against a string answers .F. for a NIL
                        // casilla too (hk140).
                        if tmp { out.push_str("    mov %rax, %rdi\n    call hbc_freestr\n"); }
                        if matches!(op, CmpOp::Ne) {
                            out.push_str(&format!("    jmp {}\n", true_label));
                        }
                        out.push_str(&format!("    jmp .Ldye{}\n", lid));
                    }
                    _ => {
                        // Ordering: NIL (tag 1) and numeric (tag 0)
                        // casillas raise Harbour's error condition
                        // (BASE/1073-1076, hk41-hk50) - clean named
                        // exit 1, registered failure mode.
                        match op {
                            CmpOp::Lt => out.push_str("    call hbc_dyncmp_lt_error\n"),
                            CmpOp::Gt => out.push_str("    call hbc_dyncmp_gt_error\n"),
                            CmpOp::Le => out.push_str("    call hbc_dyncmp_le_error\n"),
                            CmpOp::Ge => out.push_str("    call hbc_dyncmp_ge_error\n"),
                            _ => unreachable!("Eq/Ne handled above"),
                        }
                    }
                }
                out.push_str(&format!(".Ldys{}:\n", lid));
                // tag 2: byte comparison. hbc_str_eq (=/#) and
                // hbc_str_cmp (ordering) both compare over the RIGHT
                // operand's length, so operand order matters.
                out.push_str("    sub $16, %rsp\n");
                if tmp { out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"); }
                if ta == Ty::Dyn {
                    // Dyn is the LEFT operand: lhs = dyn string.
                    out.push_str("    mov %rax, %rcx\n    mov %rdx, %r8\n    mov %r11, %rax\n    mov -8(%rax), %rdx\n");
                } else {
                    // Dyn is the RIGHT operand: rhs = dyn string.
                    out.push_str("    mov %r11, %rcx\n    mov -8(%r11), %r8\n");
                }
                match op {
                    CmpOp::Eq | CmpOp::Ne => out.push_str("    call hbc_str_eq\n"),
                    // `==` is the EXACT byte compare (hk132/hk133).
                    CmpOp::EqEq => out.push_str("    call hbc_str_xeq\n"),
                    _ => out.push_str("    call hbc_str_cmp\n"),
                }
                if tmp {
                    out.push_str("    mov %rax, 16(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    add $16, %rsp\n");
                } else {
                    out.push_str("    mov %rax, (%rsp)\n");
                }
                out.push_str("    mov (%rsp), %rax\n    add $16, %rsp\n");
                match op {
                    CmpOp::Eq | CmpOp::Ne | CmpOp::EqEq => {
                        out.push_str("    test %rax, %rax\n");
                        let j = match op { CmpOp::Eq | CmpOp::EqEq => "jnz", _ => "jz" };
                        out.push_str(&format!("    {} {}\n", j, true_label));
                        out.push_str(&format!("    jmp .Ldye{}\n.Ldyn{}:\n", lid, lid));
                        // tag 0: number against a string - Harbour's
                        // BASE/1071 for `=` (hk34), BASE/1072 for `#`
                        // (hk38) and BASE/1070 for `==` (hk139b/hk139c);
                        // clean named exit 1.
                        match op {
                            CmpOp::Eq => out.push_str("    call hbc_dyncmp_eq_error\n"),
                            CmpOp::EqEq => out.push_str("    call hbc_dynxeq_error\n"),
                            _ => out.push_str("    call hbc_dyncmp_ne_error\n"),
                        }
                    }
                    CmpOp::Lt => out.push_str(&format!("    test %rax, %rax\n    js {}\n", true_label)),
                    CmpOp::Gt => out.push_str(&format!("    test %rax, %rax\n    jg {}\n", true_label)),
                    CmpOp::Le => out.push_str(&format!("    test %rax, %rax\n    jle {}\n", true_label)),
                    CmpOp::Ge => out.push_str(&format!("    test %rax, %rax\n    jns {}\n", true_label)),
                    _ => unreachable!("CmpOp variants"),
                }
                out.push_str(&format!(".Ldye{}:\n", lid));
            } else {
                match op {
                    CmpOp::Eq | CmpOp::Ne | CmpOp::EqEq => {
                        // Tag-dispatch equality: NIL = NIL is .T., NIL
                        // against a payload is .F., payloads compare
                        // by hbc_dyn_eq: strings by content with the
                        // prefix rule (hk145), string x integer a clean
                        // named exit 1 (hk146), NIL x any payload .F.
                        // (n1-n3/hk147). For `==` against NIL
                        // the answers coincide with `=` (hk128/hk129);
                        // between two non-NIL casillas `==` dispatches
                        // deeper (hbc_dynxeq_dd: strings by exact
                        // content - hk132/hk133, numbers by value -
                        // hk138, mixed number x string is the BASE/1070
                        // registered failure mode - hk139/hk139b/
                        // hk139c).
                        cg_expr(a, env, sigs, strs, out, target);
                        if ta == Ty::I64 { out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n"); }
                        if ta == Ty::Bool { out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n"); }
                        match target {
                            Target::Linux => out.push_str("    push %rax\n    push %rdx\n"),
                            Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n"),
                        }
                        cg_expr(b, env, sigs, strs, out, target);
                        if tb == Ty::I64 { out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n"); }
                        if tb == Ty::Bool { out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n"); }
                        out.push_str("    mov %rax, %rcx\n    mov %rdx, %r8\n");
                        match target {
                            Target::Linux => out.push_str("    pop %rdx\n    pop %rax\n"),
                            Target::Windows => out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n"),
                        }
                        match op {
                            CmpOp::EqEq => out.push_str("    call hbc_dynxeq_dd\n"),
                            _ => out.push_str("    call hbc_dyn_eq\n"),
                        }
                        out.push_str("    test %rax, %rax\n");
                        let j = match op { CmpOp::Eq | CmpOp::EqEq => "jnz", _ => "jz" };
                        out.push_str(&format!("    {} {}\n", j, true_label));
                    }
                    _ if ta == Ty::Dyn && tb == Ty::Dyn => {
                        // Ordering between two Dyn casillas: tag dispatch
                        // in hbc_dynxcmp (hk148: int x int numeric, string
                        // x string byte-wise over the right operand's
                        // length; hk149-hk152: string x integer is the
                        // per-operator BASE/1073-1076 clean named exit 1;
                        // NIL is the registered type error).
                        cg_expr(a, env, sigs, strs, out, target);
                        match target {
                            Target::Linux => out.push_str("    push %rax\n    push %rdx\n"),
                            Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n"),
                        }
                        cg_expr(b, env, sigs, strs, out, target);
                        out.push_str("    mov %rax, %rcx\n    mov %rdx, %r8\n");
                        match target {
                            Target::Linux => out.push_str("    pop %rdx\n    pop %rax\n"),
                            Target::Windows => out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n"),
                        }
                        let sel = match op { CmpOp::Lt => 1, CmpOp::Gt => 2, CmpOp::Le => 3, CmpOp::Ge => 4, _ => unreachable!("CmpOp variants") };
                        out.push_str(&format!("    mov ${}, %r9d\n    call hbc_dynxcmp\n    test %rax, %rax\n", sel));
                        let j = match op { CmpOp::Lt => "js", CmpOp::Le => "jle", CmpOp::Gt => "jg", CmpOp::Ge => "jns", _ => unreachable!() };
                        out.push_str(&format!("    {} {}\n", j, true_label));
                    }
                    _ => {
                        // Ordering: NIL in an ordering comparison is a
                        // Harbour type error; extraction raises it (clean
                        // exit 1, registered failure mode).
                        cg_expr(a, env, sigs, strs, out, target);
                        if ta == Ty::Dyn { out.push_str("    call hbc_dyn_to_i64\n"); }
                        match target {
                            Target::Linux => out.push_str("    push %rax\n"),
                            Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
                        }
                        cg_expr(b, env, sigs, strs, out, target);
                        if tb == Ty::Dyn { out.push_str("    call hbc_dyn_to_i64\n"); }
                        match target {
                            Target::Linux => out.push_str("    pop %rcx\n"),
                            Target::Windows => out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n"),
                        }
                        out.push_str("    cmp %rax, %rcx\n");
                        let j = match op {
                            CmpOp::Lt => "jl", CmpOp::Le => "jle", CmpOp::Gt => "jg",
                            CmpOp::Ge => "jge", _ => unreachable!(),
                        };
                        out.push_str(&format!("    {} {}\n", j, true_label));
                    }
                }
            }
        }
        Expr::Cmp(op, a, b) if matches!(expr_ty(a, env, sigs), Ty::Str | Ty::StrOwn)
            && matches!(expr_ty(b, env, sigs), Ty::Str | Ty::StrOwn) => {
            // String equality/inequality: byte-compare via hbc_str_eq.
            // The lhs (ptr,len) pair is saved while the rhs is evaluated;
            // the comparison borrows both operands (no move). Owned
            // temporaries (reads like keys[i]) are freed AFTER the call,
            // with the result preserved across the frees.
            let a_tmp = expr_ty(a, env, sigs) == Ty::StrOwn && !matches!(&**a, Expr::Var(_));
            let b_tmp = expr_ty(b, env, sigs) == Ty::StrOwn && !matches!(&**b, Expr::Var(_));
            cg_value(a, env, sigs, strs, out, target);
            match target {
                Target::Linux => out.push_str("    push %rax\n    push %rdx\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n"),
            }
            cg_value(b, env, sigs, strs, out, target);
            out.push_str("    mov %rax, %rcx\n    mov %rdx, %r8\n");
            match target {
                Target::Linux => out.push_str("    pop %rdx\n    pop %rax\n"),
                Target::Windows => out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n"),
            }
            if a_tmp || b_tmp {
                // Stack above the compare (top first): result slot, then
                // the b-temp pointer, then the a-temp pointer.
                let nt = a_tmp as usize + b_tmp as usize;
                out.push_str("    sub $16, %rsp\n");
                if b_tmp { out.push_str("    sub $16, %rsp\n    mov %rcx, (%rsp)\n"); }
                if a_tmp { out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"); }
                match op {
                    CmpOp::Eq | CmpOp::Ne => { out.push_str("    call hbc_str_eq\n"); }
                    CmpOp::EqEq => { out.push_str("    call hbc_str_xeq\n"); }
                    CmpOp::Contains => { cg_str_contains(out, fresh_lbl()); }
                    _ => { out.push_str("    call hbc_str_cmp\n"); }
                }
                out.push_str(&format!("    mov %rax, {}(%rsp)\n", 16 * nt));
                if a_tmp { out.push_str(&format!("    mov {}(%rsp), %rdi\n    call hbc_freestr\n", 16 * (b_tmp as usize))); }
                if b_tmp { out.push_str("    mov (%rsp), %rdi\n    call hbc_freestr\n"); }
                out.push_str(&format!("    mov {}(%rsp), %rax\n    add ${}, %rsp\n", 16 * nt, 16 * (nt + 1)));
            }
            let j = match op {
                CmpOp::Eq | CmpOp::Ne | CmpOp::EqEq => {
                    if !a_tmp && !b_tmp {
                        match op {
                            CmpOp::EqEq => out.push_str("    call hbc_str_xeq\n"),
                            _ => out.push_str("    call hbc_str_eq\n"),
                        }
                    }
                    out.push_str("    test %rax, %rax\n");
                    match op { CmpOp::Eq | CmpOp::EqEq => "jnz", _ => "jz" }
                }
                CmpOp::Contains => {
                    if !a_tmp && !b_tmp {
                        cg_str_contains(out, fresh_lbl());
                        out.push_str("    test %rax, %rax\n");
                    }
                    "jnz"
                }
                _ => {
                    // hbc_str_cmp returns -1, 0 or 1 (byte-wise, like memcmp)
                    if !a_tmp && !b_tmp { out.push_str("    call hbc_str_cmp\n"); }
                    out.push_str("    cmp $0, %rax\n");
                    match op {
                        CmpOp::Lt => "jl", CmpOp::Le => "jle",
                        CmpOp::Gt => "jg", CmpOp::Ge => "jge",
                        _ => unreachable!(),
                    }
                }
            };
            out.push_str(&format!("    {} {}\n", j, true_label));
        }
        Expr::Cmp(op, a, b) if matches!(op, CmpOp::EqEq)
            && matches!(expr_ty(a, env, sigs), Ty::DArr | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::Hash)
            && expr_ty(a, env, sigs) == expr_ty(b, env, sigs) => {
            // hk126/hk130/hk135: dynamic array identity at every
            // implemented depth; hk134: hash identity. The frame slot holds the heap pointer
            // and that pointer IS the identity: a==a .T., a==b .F. even
            // with equal contents. The checker restricts both operands
            // to variables, so the loads borrow - no move, no free.
            // Target-independent instructions (first qword of the slot).
            if let (Expr::Var(x), Expr::Var(y)) = (&**a, &**b) {
                let vx = env.iter().rev().find(|v| v.name == *x).expect("checked");
                let vy = env.iter().rev().find(|v| v.name == *y).expect("checked");
                out.push_str(&format!("    mov -{}(%rbp), %rax\n", vx.off));
                out.push_str(&format!("    cmp -{}(%rbp), %rax\n", vy.off));
                out.push_str(&format!("    je {}\n", true_label));
            } else {
                unreachable!("checker restricts `==` on arrays to variables");
            }
        }
        Expr::Cmp(op, a, b) if expr_ty(a, env, sigs) == Ty::F64 || expr_ty(b, env, sigs) == Ty::F64 => {
            // Float comparison (oracles hk280/hk296/hk300): IEEE value
            // compare, integer operands converted with cvtsi2sd (2^53+1
            // rounds and compares .T. against 9007199254740992.0).
            // ucomisd treats NaN (reachable via inf-inf, hk299) as
            // unordered: CF=ZF=PF=1. Harbour's C operators answer .F.
            // for =,<,<=,>,>= and .T. for # on an unordered pair; the
            // setnp/setp guards below reproduce exactly that (> and >=
            // need no guard: the unordered CF=1 already answers .F.).
            cg_f64_operand(a, env, sigs, strs, out, target);
            out.push_str("    sub $16, %rsp\n    movsd %xmm0, (%rsp)\n");
            cg_f64_operand(b, env, sigs, strs, out, target);
            out.push_str("    movsd (%rsp), %xmm1\n    add $16, %rsp\n    ucomisd %xmm0, %xmm1\n");
            match op {
                CmpOp::Eq | CmpOp::EqEq => out.push_str(&format!("    sete %al\n    setnp %cl\n    and %cl, %al\n    test %al, %al\n    jnz {}\n", true_label)),
                CmpOp::Ne => out.push_str(&format!("    setne %al\n    setp %cl\n    or %cl, %al\n    test %al, %al\n    jnz {}\n", true_label)),
                CmpOp::Lt => out.push_str(&format!("    setb %al\n    setnp %cl\n    and %cl, %al\n    test %al, %al\n    jnz {}\n", true_label)),
                CmpOp::Le => out.push_str(&format!("    setbe %al\n    setnp %cl\n    and %cl, %al\n    test %al, %al\n    jnz {}\n", true_label)),
                CmpOp::Gt => out.push_str(&format!("    seta %al\n    test %al, %al\n    jnz {}\n", true_label)),
                CmpOp::Ge => out.push_str(&format!("    setae %al\n    test %al, %al\n    jnz {}\n", true_label)),
                CmpOp::Contains => unreachable!("the checker gates `$` to strings; the string arm handles it"),
            }
        }
        Expr::Cmp(op, a, b) => {
            cg_expr(a, env, sigs, strs, out, target);
            match target {
                Target::Linux => out.push_str("    push %rax\n"),
                Target::Windows => out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n"),
            }
            cg_expr(b, env, sigs, strs, out, target);
            match target {
                Target::Linux => out.push_str("    pop %rcx\n"),
                Target::Windows => out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n"),
            }
            out.push_str("    cmp %rax, %rcx\n");
            let j = match op {
                CmpOp::Lt => "jl", CmpOp::Le => "jle", CmpOp::Gt => "jg",
                CmpOp::Ge => "jge", CmpOp::Eq => "je", CmpOp::Ne => "jne",
                // Integer `==` compares like `=` (hk124).
                CmpOp::EqEq => "je",
                CmpOp::Contains => unreachable!("the checker gates `$` to strings; the string arm handles it"),
            };
            out.push_str(&format!("    {} {}\n", j, true_label));
        }
        _ => {
            // A logical VALUE as the condition (literal, variable or call
            // returning one - hk197/hk204): 0/1 in %rax. Comparisons
            // never reach here (the arms above cover every shape the
            // checker accepts). A Dyn condition materializes first: only
            // a logical cell is valid - NIL (hk266), an integer (hk267)
            // or a string is Harbour's type error (registered clean
            // exit 1; the dialog cannot be probed headless).
            cg_expr(cond, env, sigs, strs, out, target);
            if expr_ty(cond, env, sigs) == Ty::Dyn {
                out.push_str("    call hbc_dyn_to_log\n");
            }
            out.push_str(&format!("    test %rax, %rax\n    jnz {}\n", true_label));
        }
    }
}

fn cg_print_items(es: &[Expr], inline: bool, raw: bool, stderr: bool, env: &[CgLocal], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
                // Harbour `?` is a QOut( <items> ) call (probes b51-b59,
                // t12 vs -gtstd binary): ALL items are evaluated FIRST
                // (side effects like prints inside calls happen before the
                // newline), then the newline, then the items joined by one
                // space; integers right-aligned in a 10-column field,
                // strings raw; no trailing newline.
                let darr2_child = |e: &Expr, env: &[CgLocal]| matches!(e, Expr::Index(v, _) if env.iter().any(|x| x.name == *v && x.ty == Ty::DArr2));
                let darrs_elem = |e: &Expr, env: &[CgLocal]| matches!(e, Expr::Index(v, _) if env.iter().any(|x| x.name == *v && x.ty == Ty::DArrS));
                // A whole array/hash VARIABLE renders empty
                // (hk16/hk20/hk24): only borrowed, never consumed.
                let renders_empty = |e: &Expr| matches!(expr_ty(e, env, sigs), Ty::Arr(_) | Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Hash | Ty::DArrRef | Ty::DArrRef2);
                for e in es {
                    if let Expr::Index(v, ie) = e {
                        if darr2_child(e, env) {
                            // Push the child pointer (0 marks a NIL
                            // casilla); bounds-checked like len(a[i]).
                            let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                            cg_expr(ie, env, sigs, strs, out, target);
                            out.push_str(&format!("    cmp $1, %rax\n    jl 93f\n    cmp -{}(%rbp), %rax\n    jg 93f\n", var.off - 8));
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                            out.push_str("    dec %rax\n    shl $4, %rax\n    mov 0(%r11,%rax), %rax\n    jmp 94f\n93:\n    call hbc_bound_error\n94:\n");
                            out.push_str("    xor %edx, %edx\n    push %rdx\n    push %rax\n");
                            continue;
                        }
                    }
                    if let Expr::Index(v, ie) = e {
                        if darrs_elem(e, env) {
                            // Push the raw element pair {payload, tag}
                            // (no copy): a grown NIL casilla prints NIL
                            // (hk13), a string element prints borrowed.
                            let var = env.iter().rev().find(|x| x.name == *v).expect("checked");
                            if expr_ty(ie, env, sigs) == Ty::Dyn {
                                cg_expr(ie, env, sigs, strs, out, target);
                                out.push_str("    call hbc_dyn_to_i64\n");
                            } else {
                                cg_expr(ie, env, sigs, strs, out, target);
                            }
                            out.push_str(&format!("    cmp $1, %rax\n    jl 93f\n    cmp -{}(%rbp), %rax\n    jg 93f\n", var.off - 8));
                            out.push_str(&format!("    mov -{}(%rbp), %r11\n", var.off));
                            out.push_str("    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov 8(%rax), %rcx\n    mov (%rax), %rax\n    jmp 94f\n93:\n    call hbc_bound_error\n94:\n");
                            out.push_str("    push %rax\n    push %rcx\n");
                            continue;
                        }
                    }
                    if expr_ty(e, env, sigs) == Ty::F64 {
                        // Pair protocol: value bits at off, dec count at
                        // off+8 (read back with movsd/mov below).
                        cg_f64_load(e, env, sigs, strs, out, target);
                        out.push_str("    movq %xmm0, %rax\n    push %rdi\n    push %rax\n");
                        continue;
                    }
                    if renders_empty(e) {
                        // The pair is never consumed; the variable is
                        // only borrowed (hk23: alive after printing).
                        out.push_str("    xor %eax, %eax\n    push %rax\n    push %rax\n");
                        continue;
                    }
                    cg_value(e, env, sigs, strs, out, target);
                    out.push_str("    push %rdx\n    push %rax\n");
                }
                // `??` skips ONLY the leading newline (hk274-hk276);
                // item evaluation order, separators, field widths and
                // the trailing right-trim are identical to `?`.
                // Arguments (including nested output) have already evaluated.
                let render_start = out.len();
                if !inline { out.push_str("    call hbc_print_nl\n"); }
                // Harbour renders a whole dynamic array or hash as
                // NOTHING (oracles hk16/hk20/hk21/hk24) and QOut
                // space-trims the END of the line (hk22/hk24/hk25);
                // interior spacing is preserved exactly
                // (`? "ab  ", 5` keeps the string's trailing spaces).
                // The trim is reproduced by dropping the static suffix
                // of empty-rendering items together with their preceding
                // separators, and by right-trimming a surviving trailing
                // string at runtime (numbers never trail spaces).
                // Registered edge: a trailing ALL-SPACES string still
                // leaves the separator before it in this PoC; exact
                // fidelity there needs a buffered line.
                // OutStd preserves every separator and trailing byte.
                // QOut/QQOut keep their existing line-end trimming.
                let last_vis = if raw { es.len().checked_sub(1) } else { es.iter().rposition(|e| !renders_empty(e)) };
                // Right-trim spaces (0x20) off %rdx bytes at %rax.
                let rtrim = "97:    cmp $0, %rdx\n    je 98f\n    cmpb $0x20, -1(%rax,%rdx)\n    jne 98f\n    dec %rdx\n    jmp 97b\n98:\n";
                for (i, e) in es.iter().enumerate() {
                    if last_vis.map_or(true, |lv| i > lv) { break; }
                    let t = expr_ty(e, env, sigs);
                    let off = 16 * (es.len() - 1 - i);
                    if i > 0 { out.push_str("    call hbc_print_sep\n"); }
                    if renders_empty(e) { continue; }
                    let is_last = !raw && last_vis == Some(i);
                    if darrs_elem(e, env) {
                        // A grown NIL casilla prints NIL (hk13); a string
                        // element prints its bytes, borrowed (no copy).
                        // As the last visible item the string is trimmed
                        // at the line end like any other string (hk25).
                        out.push_str(&format!("    mov {}(%rsp), %rax\n    mov {}(%rsp), %rdx\n", off, off + 8));
                        if is_last {
                            out.push_str("    cmp $2, %rdx\n    jne 95f\n    mov -8(%rax), %rdx\n");
                            out.push_str(rtrim);
                            out.push_str("    call hbc_print_str\n    jmp 96f\n95:\n    mov $1, %rax\n    xor %edx, %edx\n    call hbc_print_dyn\n96:\n");
                        } else {
                            out.push_str("    cmp $2, %rdx\n    jne 95f\n    mov -8(%rax), %rdx\n    call hbc_print_str\n    jmp 96f\n95:\n    mov $1, %rax\n    xor %edx, %edx\n    call hbc_print_dyn\n96:\n");
                        }
                        continue;
                    }
                    if darr2_child(e, env) {
                        // A NIL casilla prints NIL (n1); a live child
                        // prints nothing (n5).
                        out.push_str(&format!("    mov {}(%rsp), %rax\n", off));
                        out.push_str("    test %rax, %rax\n    jz 95f\n    jmp 96f\n95:\n    mov $1, %rax\n    xor %edx, %edx\n    call hbc_print_dyn\n96:\n");
                        continue;
                    }
                    if t == Ty::F64 {
                        // Numbers never trail spaces: no line-end trim.
                        out.push_str(&format!("    movsd {}(%rsp), %xmm0\n    mov {}(%rsp), %rdi\n    call hbc_print_f64\n", off, off + 8));
                        continue;
                    }
                    out.push_str(&format!("    mov {}(%rsp), %rax\n    mov {}(%rsp), %rdx\n", off, off + 8));
                    match t {
                        Ty::RefI64 | Ty::RefStrOwn => unreachable!("expr_ty maps by-reference params to their pointee"),
                        Ty::F64 => unreachable!("handled above"),
                        // Literal (or compile-time foldable, hk326) keeps
                        // literal provenance; a runtime-computed integer
                        // follows the asymmetric 10/20 field (hk327/hk328).
                        Ty::I64 => out.push_str(if fold_int(e).is_some() { "    call hbc_print_i64\n" } else { "    call hbc_print_i64c\n" }),
                        Ty::Str | Ty::StrOwn => {
                            // Line-end space trim (hk22/hk24): only the
                            // LAST visible item can trail spaces.
                            if is_last { out.push_str(rtrim); }
                            out.push_str("    call hbc_print_str\n");
                            if t == Ty::StrOwn && !matches!(e, Expr::Var(_)) {
                                // A temporary copy (e.g. `? keys[i]`): the
                                // item owns it and frees it right after
                                // printing; the array keeps its own copy.
                                out.push_str(&format!("    mov {}(%rsp), %rdi\n    call hbc_freestr\n", off));
                            }
                        }
                        Ty::Dyn => {
                            out.push_str("    call hbc_print_dyn\n");
                            if !matches!(e, Expr::Var(_)) {
                                // An owned temporary (a call result): a
                                // tag-4 payload is released right after
                                // printing; a Var stays owned by its slot.
                                out.push_str(&format!("    cmpq $4, {}(%rsp)\n    jne 95f\n    mov {}(%rsp), %rdi\n    test %rdi, %rdi\n    je 95f\n    call hbc_freestr\n95:\n", off, off + 8));
                            }
                        }
                        Ty::Bool => {
                            // .T./.F. (hk197/hk198): the 0/1 payload picks
                            // the literal; plain 3-byte print, no trim.
                            let ti = { strs.push(".T.".to_string()); strs.len() - 1 };
                            let fi = { strs.push(".F.".to_string()); strs.len() - 1 };
                            out.push_str(&format!("    test %rax, %rax\n    jz 95f\n    lea .Lstr{}(%rip), %rax\n    jmp 96f\n95:\n    lea .Lstr{}(%rip), %rax\n96:\n    mov $3, %edx\n    call hbc_print_str\n", ti, fi));
                        }
                        Ty::Arr(_) => unreachable!("whole-array printing rejected in analysis"),
                        Ty::Block(_) => unreachable!("codeblock printing rejected in analysis"),
                        Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::DArrRef | Ty::DArrRef2 => unreachable!("whole-array printing rejected in analysis"),
                        Ty::Hash => unreachable!("whole-hash printing rejected in analysis"),
                    }
                }
                if !es.is_empty() {
                    out.push_str(&format!("    add ${}, %rsp\n", 16 * es.len()));
                }
                if stderr {
                    // Route only the rendering fragment, never argument effects.
                    let fragment = out.split_off(render_start);
                    out.push_str(&fragment.replace("hbc_print_", "hbc_eprint_"));
                }
}

fn cg_stmts(stmts: &[Stmt], env: &mut Vec<CgLocal>, frame: &mut usize, sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target, fname: &str, label: &mut usize, ll: &Option<(String, String)>, slots: &[(usize, u8)], dyn_names: &std::collections::HashSet<String>, byref_names: &std::collections::HashSet<String>) {
    for (si, s) in stmts.iter().enumerate() {
        trace_location(fname.split("__br").next().unwrap_or(fname), stmt_line(s), strs, out);
        match s {
            Stmt::SelfSet(..) | Stmt::SendSet(..) | Stmt::SendStmt(..) => unreachable!("rejected before codegen"),
            Stmt::CallStmt(_, e) => {
                if matches!(e, Expr::Var(_)) { continue; } // no owned result
                if expr_ty(e, env, sigs) == Ty::F64 {
                    cg_f64_load(e, env, sigs, strs, out, target);
                    continue;
                }
                // Run the call, then release the discarded owned return
                // with the same helper the epilogue would use on a slot
                // of that type (oracle hk256: the discard is legal).
                cg_value(e, env, sigs, strs, out, target);
                match expr_ty(e, env, sigs) {
                    Ty::StrOwn => out.push_str("    mov %rax, %rdi
    call hbc_freestr
"),
                    Ty::DArr => out.push_str("    mov %rax, %rdi
    mov $16, %esi
    call hbc_free
"),
                    Ty::DArrS => out.push_str("    mov %rax, %rdi
    mov %rdx, %rsi
    call hbc_sfree
"),
                    Ty::DArr2 => out.push_str("    mov %rax, %rdi
    mov %rdx, %rsi
    call hbc_free2
"),
                    Ty::Dyn => out.push_str("    cmp $4, %rax\n    jne 95f\n    mov %rdx, %rdi\n    test %rdi, %rdi\n    je 95f\n    call hbc_freestr\n95:\n"),
                    _ => {}
                }
            }
            Stmt::Local(_, id, e) => {
                let mut t = expr_ty(e, env, sigs);
                // Prescan widening (probe n2): an i64 initializer whose
                // local later receives a Dyn value gets the 16-byte slot;
                // the i64 initializer is tagged in as {0, payload}.
                let i64_init = t == Ty::I64 && dyn_names.contains(id);
                if i64_init { t = Ty::Dyn; }
                // `@s` widening (hk218): a local passed by reference needs an
                // owned-capable slot from the start (the callee frees and
                // re-stores through the pointer), so a rodata literal
                // initializer is copied into an owned buffer.
                let byref_str = t == Ty::Str && byref_names.contains(id);
                if byref_str { t = Ty::StrOwn; }
                // Bare-local FOR counter (hk336): i64 slot, in lockstep
                // with the checker and layout through the one shared
                // predicate. The NIL the slot would hold before the FOR
                // is unobservable (mention-clean rule); it starts at 0
                // and the FOR writes it.
                let bare_cnt = t == Ty::Dyn && matches!(e, Expr::Nil) && !byref_names.contains(id) && bare_local_is_for_counter(stmts, si, id);
                if bare_cnt { t = Ty::I64; }
                *frame += size_of(t);
                let off = *frame;
                if bare_cnt {
                    out.push_str(&format!("    movq $0, -{}(%rbp)\n", off));
                    env.push(CgLocal { name: id.clone(), ty: t, off });
                    continue;
                }
                if t == Ty::Hash {
                    if let Expr::HashLit(ps) = e {
                        // The slot starts zeroed by the prologue. Pairs are
                        // inserted in source order, key first then value
                        // (probe h9); hbc_hput copies the key bytes and the
                        // 16-byte value, so the temporaries stay owned here.
                        for (k, v) in ps {
                            cg_value(k, env, sigs, strs, out, target);
                            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                            cg_value(v, env, sigs, strs, out, target);
                            if expr_ty(v, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            if expr_ty(v, env, sigs) == Ty::Bool {
                                out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                            }
                            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                            out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov 16(%rsp), %rsi\n    mov 24(%rsp), %rdx\n    mov %rsp, %rcx\n    call hbc_hput\n    add $32, %rsp\n", off));
                        }
                        env.push(CgLocal { name: id.clone(), ty: t, off });
                        continue;
                    }
                }
                match t {
                    Ty::F64 => {
                        // Two dynamic slots: value + decimal metadata
                        // (reassignment replaces both; copies carry both).
                        cg_f64_load(e, env, sigs, strs, out, target);
                        out.push_str(&format!("    movsd %xmm0, -{}(%rbp)\n    mov %rdi, -{}(%rbp)\n", off, off - 8));
                    }
                    Ty::Arr(_) => cg_array_value(e, off, env, sigs, strs, out, target),
                    _ => {
                        cg_value(e, env, sigs, strs, out, target);
                        if i64_init {
                            out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                        }
                        if byref_str {
                            // rodata -> owned copy (hbc_strcpy), or the
                            // epilogue / a `@` callee would free rodata.
                            out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                        }
                        // A moved-out DArr SOURCE slot is nulled right after
                        // the load: every allocation keeps exactly one owner.
                        if let Expr::Var(src) = e {
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::StrOwn | Ty::Hash)) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                            }
                        }
                        match t {
                            Ty::I64 | Ty::Block(_) | Ty::Bool => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off)),
                            Ty::Str => {
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::StrOwn | Ty::Hash | Ty::Dyn => {
                                // A Dyn initialized FROM A VAR borrows its
                                // pair: clone any string payload so the new
                                // slot owns its own copy (the same boundary
                                // rule as Dyn-to-Dyn assignment).
                                if t == Ty::Dyn && matches!(e, Expr::Var(_)) {
                                    cg_dyn_clone_if_str(out);
                                }
                                // The slot can hold a live value when a
                                // `local` re-declares inside a loop body:
                                // free the old allocation first (null-safe).
                                // The new value waits on the stack: hbc_free
                                // clobbers caller-saved registers (syscall).
                                let class = slots.iter().find(|(o, _)| *o == off).map(|(_, c)| *c).unwrap_or(0);
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                if class == 1 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    call hbc_free2\n85:\n", off, off - 8));
                                } else if class == 3 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    mov $2, %edx\n    call hbc_rfree\n85:\n", off, off - 8));
                                } else if class == 6 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    mov $3, %edx\n    call hbc_rfree\n85:\n", off, off - 8));
                                } else if class == 2 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    call hbc_hfree\n85:\n", off, off - 8));
                                } else if class == 4 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov -{}(%rbp), %rsi\n    call hbc_sfree\n85:\n", off, off - 8));
                                } else if class == 5 {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    call hbc_freestr\n85:\n", off));
                                } else if class == 7 {
                                    out.push_str(&format!("    cmpq $4, -{}(%rbp)\n    jne 85f\n    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    call hbc_freestr\n85:\n", off, off - 8));
                                } else {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov $16, %esi\n    call hbc_free\n85:\n", off));
                                }
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
                            }
                            _ => unreachable!("booleans rejected in analysis"),
                        }
                    }
                }
                env.push(CgLocal { name: id.clone(), ty: t, off });
            }
            Stmt::Print(_, es, inline) => {
                cg_print_items(es, *inline, false, false, env, sigs, strs, out, target);
            }
            Stmt::Ret(_, Some(e)) => {
                if let Ty::Arr(k) = expr_ty(e, env, sigs) {
                    // Static array return: materialize the boundary COPY
                    // as a dynamic array (same shape as the argument
                    // copy, 33l); the caller owns and frees it (33m).
                    if let Expr::Var(src) = e {
                        let sv = env.iter().rev().find(|x| x.name == *src).expect("checked").clone();
                        out.push_str("    sub $16, %rsp\n");
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + k * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", k));
                        for p in 0..k {
                            out.push_str(&format!("    mov -{}(%rbp), %r10\n", sv.off - 8 * p));
                            out.push_str(&format!("    mov (%rsp), %r11\n    movq $0, {}(%r11)\n    mov %r10, {}(%r11)\n", p * 16, p * 16 + 8));
                        }
                        out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $16, %rsp\n", k));
                        out.push_str(&format!("    jmp .Lret_{}\n", fname));
                    }
                } else if expr_ty(e, env, sigs) == Ty::F64 {
                // Float return (63zd): the declared convention hands the
                // caller xmm0 = value bits and rdi = packed metadata -
                // exactly the cg_f64_load pair, so nested calls and
                // float temporaries need no shuffling. The shared
                // epilogue preserves the pair across the slot frees.
                cg_f64_load(e, env, sigs, strs, out, target);
                out.push_str(&format!("    jmp .Lret_{}\n", fname));
                } else {
                cg_value(e, env, sigs, strs, out, target);
                // Mixed int/NIL returns unify to Dyn (probe n2): an i64
                // return expression is tagged into the {0, payload} pair.
                if expr_ty(e, env, sigs) == Ty::I64
                    && sigs.iter().any(|sg| sg.name == fname && sg.ret == Some(Ty::Dyn)) {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                // A rodata string returned under an owned-string signature
                // (Str/StrOwn unification): the caller owns the result, so
                // the return point hands over a fresh copy.
                if expr_ty(e, env, sigs) == Ty::Str
                    && sigs.iter().any(|sg| sg.name == fname && sg.ret == Some(Ty::StrOwn)) {
                    out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                }
                // Returning a by-reference string parameter copies the
                // pointee for the caller (hk237); the owner's slot keeps
                // its buffer, so nothing is nulled or freed here.
                if let Expr::Var(src) = e {
                    if env.iter().rev().any(|x| x.name == *src && x.ty == Ty::RefStrOwn) {
                        out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                    }
                }
                // A Dyn return hands the caller its own clone of any
                // string payload (tag 4 owned temp): the callee's slot
                // keeps its copy and the shared epilogue frees it.
                if expr_ty(e, env, sigs) == Ty::Dyn {
                    cg_dyn_clone_if_str(out);
                }
                // Returning a dynamic array MOVES it to the caller: the
                // source slot is nulled BEFORE the shared epilogue runs, so
                // the epilogue never frees the returned allocation (parent
                // rule: move the return to the output before cleanup).
                if let Expr::Var(src) = e {
                    if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::StrOwn | Ty::Hash)) {
                        out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                    }
                }
                out.push_str(&format!("    jmp .Lret_{}\n", fname));
                }
            }
            Stmt::Ret(_, None) => {
                // `return` / `return nil` return NIL (probes n1c/n2): the
                // Dyn tag/payload pair travels like any 16-byte value.
                out.push_str("    mov $1, %eax\n    xor %edx, %edx\n");
                out.push_str(&format!("    jmp .Lret_{}\n", fname));
            }
            Stmt::If(_, cond, then_s, else_s) => {
                let id = *label;
                *label += 1;
                cg_cond_jump(cond, env, sigs, strs, out, target, &format!(".Lthen_{}_{}", fname, id));
                out.push_str(&format!("    jmp .Lelse_{}_{}\n", fname, id));
                out.push_str(&format!(".Lthen_{}_{}:\n", fname, id));
                let mark = env.len();
                cg_stmts(then_s, env, frame, sigs, strs, out, target, fname, label, ll, slots, dyn_names, byref_names);
                env.truncate(mark);
                out.push_str(&format!("    jmp .Lend_{}_{}\n", fname, id));
                out.push_str(&format!(".Lelse_{}_{}:\n", fname, id));
                cg_stmts(else_s, env, frame, sigs, strs, out, target, fname, label, ll, slots, dyn_names, byref_names);
                env.truncate(mark);
                out.push_str(&format!(".Lend_{}_{}:\n", fname, id));
            }
            Stmt::While(_, cond, body) => {
                let id = *label;
                *label += 1;
                out.push_str(&format!(".Lwhile_{}_{}:\n", fname, id));
                trace_location(fname.split("__br").next().unwrap_or(fname), stmt_line(s), strs, out);
                cg_cond_jump(cond, env, sigs, strs, out, target, &format!(".Lbody_{}_{}", fname, id));
                out.push_str(&format!("    jmp .Lendw_{}_{}\n", fname, id));
                out.push_str(&format!(".Lbody_{}_{}:\n", fname, id));
                let mark = env.len();
                let inner = Some((format!(".Lwhile_{}_{}", fname, id), format!(".Lendw_{}_{}", fname, id)));
                cg_stmts(body, env, frame, sigs, strs, out, target, fname, label, &inner, slots, dyn_names, byref_names);
                env.truncate(mark);
                out.push_str(&format!("    jmp .Lwhile_{}_{}\n", fname, id));
                out.push_str(&format!(".Lendw_{}_{}:\n", fname, id));
            }
            Stmt::For(_, var, start, end, step, body) => {
                let id = *label;
                *label += 1;
                let mark = env.len();
                // Evaluate the START first, then the END into a hidden
                // slot: Harbour's observed order (probe c11: the start's
                // side effects print first) and Rust's `a..b` order agree.
                // Bounds evaluate once, as in Rust ranges. The step is a
                // non-zero literal, so the counting direction is fixed
                // here at compile time.
                // Reuse (hk323): an already-visible integer slot is the
                // counter; otherwise a fresh slot.
                let reuse_off = env.iter().rev().find(|v| v.name == *var && v.ty == Ty::I64).map(|v| v.off);
                cg_value(start, env, sigs, strs, out, target);
                let i_off = if let Some(o) = reuse_off { o } else { *frame += 8; *frame };
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", i_off));
                cg_value(end, env, sigs, strs, out, target);
                *frame += 8;
                let end_off = *frame;
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", end_off));
                if reuse_off.is_none() {
                    env.push(CgLocal { name: var.clone(), ty: Ty::I64, off: i_off });
                }
                out.push_str(&format!(".Lforc_{}_{}:\n", fname, id));
                out.push_str(&format!("    mov -{}(%rbp), %rax\n", i_off));
                out.push_str(&format!("    cmp -{}(%rbp), %rax\n", end_off));
                if *step > 0 {
                    out.push_str(&format!("    jg .Lfore_{}_{}\n", fname, id));
                } else {
                    out.push_str(&format!("    jl .Lfore_{}_{}\n", fname, id));
                }
                let inner = Some((format!(".Lforn_{}_{}", fname, id), format!(".Lfore_{}_{}", fname, id)));
                cg_stmts(body, env, frame, sigs, strs, out, target, fname, label, &inner, slots, dyn_names, byref_names);
                env.truncate(mark);
                out.push_str(&format!(".Lforn_{}_{}:\n", fname, id));
                out.push_str(&format!("    mov -{}(%rbp), %rax\n", i_off));
                out.push_str(&format!("    add ${}, %rax\n", step));
                // Advancing past the i64 range would wrap the counter and
                // the loop would not terminate: overflow ends the loop.
                out.push_str(&format!("    jo .Lfore_{}_{}\n", fname, id));
                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", i_off));
                out.push_str(&format!("    jmp .Lforc_{}_{}\n", fname, id));
                out.push_str(&format!(".Lfore_{}_{}:\n", fname, id));
            }
            Stmt::ForEach(_, var, coll, body) => {
                let id = *label;
                *label += 1;
                let mark = env.len();
                // The collection is evaluated ONCE into a hidden pair.
                // A VARIABLE is borrowed (never freed here); a CALL
                // RESULT is an owned temporary in a registered slot:
                // the prologue zeroed it and the epilogue frees it on
                // every exit path (natural, `exit`, `return`), so a
                // statement that runs again (an enclosing loop) must
                // free the previous temporary first. The index is
                // 1-based like Harbour. The current element is rebuilt
                // as a Dyn pair on every iteration: {tag, payload}
                // directly from the 16-byte array cells, the value
                // words of the 32-byte hash entries, or a tag-0 pair
                // for static i64 arrays.
                *frame += 16;
                let coll_off = *frame;
                if matches!(coll, Expr::Call(..)) {
                    let fl = fresh_lbl();
                    match expr_ty(coll, env, sigs) {
                        Ty::Hash => out.push_str(&format!("    mov -{}(%rbp), %rdi
    test %rdi, %rdi
    je .Lfetf{}
    mov -{}(%rbp), %rsi
    call hbc_hfree
.Lfetf{}:
    movq $0, -{}(%rbp)
", coll_off, fl, coll_off - 8, fl, coll_off)),
                        Ty::DArrS => out.push_str(&format!("    mov -{}(%rbp), %rdi
    test %rdi, %rdi
    je .Lfetf{}
    mov -{}(%rbp), %rsi
    call hbc_sfree
.Lfetf{}:
    movq $0, -{}(%rbp)
", coll_off, fl, coll_off - 8, fl, coll_off)),
                        _ => out.push_str(&format!("    mov -{}(%rbp), %rdi
    test %rdi, %rdi
    je .Lfetf{}
    mov $16, %esi
    call hbc_free
.Lfetf{}:
    movq $0, -{}(%rbp)
", coll_off, fl, fl, coll_off)),
                    }
                }
                if let Expr::Index(id, ie) = coll {
                    if matches!(env.iter().rev().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr2)) {
                        // Borrow the child (ptr, len) from the root's
                        // cell: the index evaluates ONCE and is
                        // bounds-checked; a NIL casilla (null child)
                        // is Harbour's BASE/1068 condition (hk58) -
                        // hbc_arracc_error, a clean named exit 1,
                        // registered failure mode. Nothing owned here.
                        let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
                        if expr_ty(ie, env, sigs) == Ty::Dyn {
                            cg_expr(ie, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64\n");
                        } else {
                            cg_expr(ie, env, sigs, strs, out, target);
                        }
                        let fl2 = fresh_lbl();
                        out.push_str(&format!("    cmp $1, %rax\n    jl .Lfeb{}\n    cmp -{}(%rbp), %rax\n    jg .Lfeb{}\n", fl2, v.off - 8, fl2));
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n    dec %rax\n    shl $4, %rax\n    add %r11, %rax\n    mov 8(%rax), %rdx\n    mov (%rax), %rcx\n    test %rcx, %rcx\n    je .Lfen{}\n    mov %rcx, %rax\n    jmp .Lfeo{}\n.Lfeb{}:\n    call hbc_bound_error\n.Lfen{}:\n    call hbc_arracc_error\n.Lfeo{}:\n", v.off, fl2, fl2, fl2, fl2, fl2));
                    } else {
                        cg_value(coll, env, sigs, strs, out, target);
                    }
                } else if let Expr::Index2(id, ie, ie2) = coll {
                    if matches!(env.iter().rev().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr3) | Some(Ty::DArr4)) {
                        // Depth-3 borrow (hk60-hk64; the same two-level
                        // walk borrows a[i][j] of a FOUR-level root for
                        // the borrowed-array loop variable, hk118):
                        // evaluate each index
                        // ONCE, bounds-check each level, load the level-2
                        // then the level-1 cell; a NIL casilla at either
                        // level is the BASE/1068 failure mode
                        // (hbc_arracc_error). Nothing owned here.
                        let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
                        if expr_ty(ie, env, sigs) == Ty::Dyn {
                            cg_expr(ie, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64
");
                        } else {
                            cg_expr(ie, env, sigs, strs, out, target);
                        }
                        let fl2 = fresh_lbl();
                        out.push_str(&format!("    cmp $1, %rax
    jl .Lfeb{}
    cmp -{}(%rbp), %rax
    jg .Lfeb{}
", fl2, v.off - 8, fl2));
                        out.push_str(&format!("    mov -{}(%rbp), %r11
    dec %rax
    shl $4, %rax
    add %r11, %rax
    mov 8(%rax), %rdx
    mov (%rax), %rcx
    test %rcx, %rcx
    je .Lfen{}
    push %rcx
    push %rdx
", v.off, fl2));
                        if expr_ty(ie2, env, sigs) == Ty::Dyn {
                            cg_expr(ie2, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64
");
                        } else {
                            cg_expr(ie2, env, sigs, strs, out, target);
                        }
                        out.push_str(&format!("    pop %rdx
    pop %rcx
    cmp $1, %rax
    jl .Lfeb{}
    cmp %rdx, %rax
    jg .Lfeb{}
    dec %rax
    shl $4, %rax
    add %rcx, %rax
    mov 8(%rax), %rdx
    mov (%rax), %rcx
    test %rcx, %rcx
    je .Lfen{}
    mov %rcx, %rax
    jmp .Lfeo{}
.Lfeb{}:
    call hbc_bound_error
.Lfen{}:
    call hbc_arracc_error
.Lfeo{}:
", fl2, fl2, fl2, fl2, fl2, fl2, fl2));
                    } else {
                        cg_value(coll, env, sigs, strs, out, target);
                    }
                } else if let Expr::Index3(id, ie, ie2, ie3) = coll {
                    if matches!(env.iter().rev().find(|v| v.name == *id).map(|v| v.ty), Some(Ty::DArr4)) {
                        // Depth-4 borrow (hk109/hk110): evaluate each
                        // index ONCE, left to right, bounds-check each
                        // level, walk to the level-3 child; a NIL
                        // casilla at any level is the BASE/1068 failure
                        // mode (hbc_arracc_error). Nothing owned here.
                        let v = env.iter().rev().find(|v| v.name == *id).expect("checked");
                        if expr_ty(ie, env, sigs) == Ty::Dyn {
                            cg_expr(ie, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64
");
                        } else {
                            cg_expr(ie, env, sigs, strs, out, target);
                        }
                        let fl2 = fresh_lbl();
                        out.push_str(&format!("    cmp $1, %rax
    jl .Lfeb{}
    cmp -{}(%rbp), %rax
    jg .Lfeb{}
    mov -{}(%rbp), %r11
    dec %rax
    shl $4, %rax
    add %r11, %rax
    mov 8(%rax), %rdx
    mov (%rax), %rcx
    test %rcx, %rcx
    je .Lfen{}
    push %rcx
    push %rdx
", fl2, v.off - 8, fl2, v.off, fl2));
                        if expr_ty(ie2, env, sigs) == Ty::Dyn {
                            cg_expr(ie2, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64
");
                        } else {
                            cg_expr(ie2, env, sigs, strs, out, target);
                        }
                        out.push_str(&format!("    pop %rdx
    pop %rcx
    cmp $1, %rax
    jl .Lfeb{}
    cmp %rdx, %rax
    jg .Lfeb{}
    dec %rax
    shl $4, %rax
    add %rcx, %rax
    mov 8(%rax), %rdx
    mov (%rax), %rcx
    test %rcx, %rcx
    je .Lfen{}
    push %rcx
    push %rdx
", fl2, fl2, fl2));
                        if expr_ty(ie3, env, sigs) == Ty::Dyn {
                            cg_expr(ie3, env, sigs, strs, out, target);
                            out.push_str("    call hbc_dyn_to_i64
");
                        } else {
                            cg_expr(ie3, env, sigs, strs, out, target);
                        }
                        out.push_str(&format!("    pop %rdx
    pop %rcx
    cmp $1, %rax
    jl .Lfeb{}
    cmp %rdx, %rax
    jg .Lfeb{}
    dec %rax
    shl $4, %rax
    add %rcx, %rax
    mov 8(%rax), %rdx
    mov (%rax), %rcx
    test %rcx, %rcx
    je .Lfen{}
    mov %rcx, %rax
    jmp .Lfeo{}
.Lfeb{}:
    call hbc_bound_error
.Lfen{}:
    call hbc_arracc_error
.Lfeo{}:
", fl2, fl2, fl2, fl2, fl2, fl2, fl2));
                    } else {
                        cg_value(coll, env, sigs, strs, out, target);
                    }
                } else {
                    cg_value(coll, env, sigs, strs, out, target);
                }
                out.push_str(&format!("    mov %rax, -{}(%rbp)
    mov %rdx, -{}(%rbp)
", coll_off, coll_off - 8));
                *frame += 8;
                let idx_off = *frame;
                out.push_str(&format!("    movq $1, -{}(%rbp)
", idx_off));
                *frame += 16;
                let lv_off = *frame;
                let ct = expr_ty(coll, env, sigs);
                let kl = env.iter().position(|v| v.name == *var).expect("checker found the local");
                let saved_lv = (env[kl].ty, env[kl].off);
                // a[i][j] of a four-level root (hk118/hk119): the loop
                // variable is a borrowed FLAT child array - its slot
                // holds the ADDRESS of the current {ptr, len} casilla
                // (the DArrRef param layout), so reads, writes and
                // len go through the shared memory.
                let lv_borrow = matches!(coll, Expr::Index2(id2, _, _) if matches!(env.iter().rev().find(|v| v.name == *id2).map(|v| v.ty), Some(Ty::DArr4)));
                env[kl].ty = if lv_borrow { Ty::DArrRef } else { Ty::Dyn };
                env[kl].off = lv_off;
                out.push_str(&format!(".Lfec_{}_{}:
", fname, id));
                trace_location(fname.split("__br").next().unwrap_or(fname), stmt_line(s), strs, out);
                out.push_str(&format!("    mov -{}(%rbp), %rax
    cmp -{}(%rbp), %rax
    jg .Lfee_{}_{}
", idx_off, coll_off - 8, fname, id));
                out.push_str(&format!("    mov -{}(%rbp), %r11
    mov -{}(%rbp), %rax
    dec %rax
", coll_off, idx_off));
                if lv_borrow {
                    // The slot holds the casilla ADDRESS (single word).
                    out.push_str("    shl $4, %rax
    add %r11, %rax
");
                    out.push_str(&format!("    mov %rax, -{}(%rbp)
", lv_off));
                } else {
                match ct {
                    Ty::Arr(_) => out.push_str("    shl $3, %rax
    add %r11, %rax
    mov (%rax), %rdx
    xor %eax, %eax
"),
                    Ty::Hash => out.push_str("    shl $5, %rax
    add %r11, %rax
    mov 16(%rax), %rcx
    mov 24(%rax), %rdx
    mov %rcx, %rax
"),
                    _ => out.push_str("    shl $4, %rax
    add %r11, %rax
    mov (%rax), %rcx
    mov 8(%rax), %rdx
    mov %rcx, %rax
"),
                }
                out.push_str(&format!("    mov %rax, -{}(%rbp)
    mov %rdx, -{}(%rbp)
", lv_off, lv_off - 8));
                }
                let inner = Some((format!(".Lfen_{}_{}", fname, id), format!(".Lfee_{}_{}", fname, id)));
                cg_stmts(body, env, frame, sigs, strs, out, target, fname, label, &inner, slots, dyn_names, byref_names);
                env[kl].ty = saved_lv.0;
                env[kl].off = saved_lv.1;
                env.truncate(mark);
                out.push_str(&format!(".Lfen_{}_{}:
    incq -{}(%rbp)
    jmp .Lfec_{}_{}
", fname, id, idx_off, fname, id));
                out.push_str(&format!(".Lfee_{}_{}:
", fname, id));
            }
            Stmt::Exit(_) => {
                let (_, end) = ll.as_ref().expect("analysis checked `exit` is inside a loop");
                out.push_str(&format!("    jmp {}\n", end));
            }
            Stmt::Loop(_) => {
                let (cond, _) = ll.as_ref().expect("analysis checked `loop` is inside a loop");
                out.push_str(&format!("    jmp {}\n", cond));
            }
            Stmt::Assign(_, id, e) => {
                let t = expr_ty(e, env, sigs);
                let l = env.iter().find(|v| v.name == *id).expect("analysis checked the local exists");
                let off = l.off;
                let lty = l.ty;
                // Move-LHS string grow (Harbour's own pattern, hvm.c
                // hb_vmPlus + itemapi.c hb_itemReSizeString): `s := s + rhs`
                // on a plain owned local appends through hbc_strgrow - in
                // place when the capacity header allows, doubling otherwise.
                // Only when the RHS cannot alias the destination buffer
                // (expr_mentions guard); every other shape keeps hbc_strcat.
                if lty == Ty::StrOwn {
                    if let Expr::Bin('+', a, b) = e {
                        if matches!(**a, Expr::Var(ref v) if *v == *id) && !expr_mentions(b, id) && !expr_has_call(b) {
                            cg_value(b, env, sigs, strs, out, target);
                            out.push_str(&format!("    mov %rax, %rsi\n    mov -{}(%rbp), %rdi\n    call hbc_strgrow\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off, off - 8));
                            continue;
                        }
                    }
                }
                if lty == Ty::F64 {
                    // Reassignment REPLACES both slots (value and decimal
                    // metadata are dynamic): `a := 1.50` then `a := .123`
                    // reprints with the new precision.
                    cg_f64_load(e, env, sigs, strs, out, target);
                    out.push_str(&format!("    movsd %xmm0, -{}(%rbp)\n    mov %rdi, -{}(%rbp)\n", off, off - 8));
                    continue;
                }
                if lty == Ty::RefI64 {
                    // @-borrowed scalar (hk216): store THROUGH the pointer
                    // into the owner's slot.
                    cg_value(e, env, sigs, strs, out, target);
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n    mov %rax, (%r11)\n", off));
                    continue;
                }
                if lty == Ty::RefStrOwn {
                    // @-borrowed owned string (hk218). Literal self-
                    // assignment `p := p` is a no-op (Harbour-compatible);
                    // every other shape was checked to deliver a fresh or
                    // moved value, never the borrow itself.
                    if let Expr::Var(src) = e { if src == id { continue; } }
                    cg_value(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::Str {
                        // rodata RHS: the owner's slot must own a copy.
                        out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                    }
                    if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::Str | Ty::StrOwn)) {
                            // the source moved in: null its slot (one owner)
                            out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                        }
                    }
                    // Free the owner's OLD value through the pointer - only
                    // after the RHS fully exists - then store (main's UAF
                    // rule: preserve RHS before releasing the old value).
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", off));
                    out.push_str("    mov (%r11), %rdi\n    test %rdi, %rdi\n    je 86f\n    call hbc_freestr\n86:\n");
                    out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov -{}(%rbp), %r11\n    mov %rax, (%r11)\n    mov %rdx, 8(%r11)\n", off));
                    continue;
                }
                if t == Ty::Hash {
                    if let Expr::HashLit(ps) = e {
                        // Reassign from a literal: the old value goes first
                        // (live len, never capacity), the slot is zeroed,
                        // then the pairs are inserted in source order.
                        out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 87f\n    mov -{}(%rbp), %rsi\n    call hbc_hfree\n87:\n", off, off - 8));
                        out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", off, off - 8));
                        for (k, v) in ps {
                            cg_value(k, env, sigs, strs, out, target);
                            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                            cg_value(v, env, sigs, strs, out, target);
                            if expr_ty(v, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            if expr_ty(v, env, sigs) == Ty::Bool {
                                out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                            }
                            out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                            out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov 16(%rsp), %rsi\n    mov 24(%rsp), %rdx\n    mov %rsp, %rcx\n    call hbc_hput\n    add $32, %rsp\n", off));
                        }
                        continue;
                    }
                }
                match t {
                    Ty::F64 => {
                        // Two dynamic slots: value + decimal metadata
                        // (reassignment replaces both; copies carry both).
                        cg_f64_load(e, env, sigs, strs, out, target);
                        out.push_str(&format!("    movsd %xmm0, -{}(%rbp)\n    mov %rdi, -{}(%rbp)\n", off, off - 8));
                    }
                    Ty::Arr(_) => cg_array_value(e, off, env, sigs, strs, out, target),
                    _ => {
                        cg_value(e, env, sigs, strs, out, target);
                        // Null a moved-out DArr source AFTER the RHS was
                        // fully evaluated (parent rule: move transfers; the
                        // old slot must not free what it no longer owns).
                        if let Expr::Var(src) = e {
                            if let Some(sv) = env.iter().rev().find(|x| x.name == *src && matches!(x.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::StrOwn | Ty::Hash)) {
                                out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                            }
                        }
                        match t {
                            Ty::I64 | Ty::Block(_) if lty == Ty::Dyn => {
                                // Dyn slot, i64 value: tag it in (probe n2:
                                // reassignment re-tags a live variable).
                                // A live tag-4 payload is released first.
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                                cg_dyn_free_old(out, off);
                                out.push_str("    mov (%rsp), %rdx\n    add $16, %rsp\n    xor %eax, %eax\n");
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            Ty::I64 | Ty::Block(_) | Ty::Bool => out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off)),
                            Ty::Dyn if lty == Ty::I64 => {
                                // i64 slot receiving a Dyn: the tag is
                                // checked at runtime (NIL -> clean error).
                                out.push_str("    call hbc_dyn_to_i64\n");
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                            }
                            Ty::Dyn => {
                                // A Var is a borrowed VIEW of its slot: a
                                // string payload is cloned so each slot owns
                                // its own copy (Harbour value semantics). A
                                // non-Var (a call result) is already an
                                // owned temporary: it moves in as-is.
                                if matches!(e, Expr::Var(_)) {
                                    cg_dyn_clone_if_str(out);
                                }
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                cg_dyn_free_old(out, off);
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
                            }
                            Ty::Str if lty == Ty::Dyn => {
                                // rodata literal into a Dyn slot: clone to
                                // an owned tag-4 casilla at the boundary.
                                out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                                out.push_str("    mov %rax, %rdx\n    mov $4, %eax\n");
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                cg_dyn_free_old(out, off);
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
                            }
                            Ty::StrOwn if lty == Ty::Dyn => {
                                // An owned string MOVES into the Dyn slot
                                // as a tag-4 casilla (a Var source was
                                // already nulled by the generic move block).
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                                cg_dyn_free_old(out, off);
                                out.push_str(&format!("    mov $4, %eax\n    mov (%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
                            }
                            Ty::Str if lty == Ty::StrOwn => {
                                // rodata into an owned slot (hk225): own a
                                // copy, free the old value after the copy.
                                out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    call hbc_freestr\n86:\n", off));
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
                            }
                            Ty::Str => {
                                out.push_str(&format!("    mov %rax, -{}(%rbp)\n", off));
                                out.push_str(&format!("    mov %rdx, -{}(%rbp)\n", off - 8));
                            }
                            Ty::StrOwn => {
                                // Free the OLD owned copy after the RHS
                                // exists (fresh slots are zero-initialised,
                                // so the guard sees null), then store.
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    call hbc_freestr\n86:\n", off));
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
                            }
                            Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3 | Ty::DArr4 | Ty::DArrS | Ty::Hash => {
                                // Free the OLD value after the RHS exists
                                // (self-assignment `a := a` moved through a
                                // temporary: the source was nulled above, so
                                // the free sees null and nothing is dropped
                                // twice). The free kind follows the slot's
                                // CURRENT type (the old value's type).
                                let cur_ty = env.iter().find(|x| x.name == *id).map(|x| x.ty);
                                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                                if cur_ty == Some(Ty::DArrS) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    call hbc_sfree\n86:\n", off, off - 8));
                                } else if cur_ty == Some(Ty::DArr2) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    call hbc_free2\n86:\n", off, off - 8));
                                } else if cur_ty == Some(Ty::DArr3) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    mov $2, %edx\n    call hbc_rfree\n86:\n", off, off - 8));
                                } else if cur_ty == Some(Ty::DArr4) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    mov $3, %edx\n    call hbc_rfree\n86:\n", off, off - 8));
                                } else if cur_ty == Some(Ty::Hash) {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov -{}(%rbp), %rsi\n    call hbc_hfree\n86:\n", off, off - 8));
                                } else {
                                    out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 86f\n    mov $16, %esi\n    call hbc_free\n86:\n", off));
                                }
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", off, off - 8));
                                // Replicate the checker's pinning of `{}`.
                                if let Some(v) = env.iter_mut().find(|x| x.name == *id) {
                                    if v.ty == Ty::DArrU && matches!(t, Ty::DArr | Ty::DArr2) {
                                        v.ty = t;
                                    }
                                }
                            }
                            _ => unreachable!("booleans rejected in analysis"),
                        }
                    }
                }
            }
            Stmt::AAdd(_, id, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                let vt = expr_ty(e, env, sigs);
                // DArrRef (borrowed middle array): the slot holds the child
                // cell's ADDRESS - feed THAT to hbc_aadd exactly like the
                // middle arm does, so growth reallocates through the
                // owner's cell (oracle hk78).
                let aptr = if v.ty == Ty::DArrRef || v.ty == Ty::DArrRef2 { format!("mov -{}(%rbp), %rdi", v.off) } else { format!("lea -{}(%rbp), %rdi", v.off) };
                if v.ty == Ty::DArrS || (v.ty == Ty::DArrU && matches!(vt, Ty::Str | Ty::StrOwn)) {
                    // String element: a rodata value is copied (the array
                    // owns the copy); an owned value moves in (its source
                    // slot is nulled). The appended pair is {tag 2, ptr}.
                    cg_value(e, env, sigs, strs, out, target);
                    if vt == Ty::Str {
                        out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                    }
                    if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src && x.ty == Ty::StrOwn) {
                            out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                        }
                    }
                    out.push_str("    mov %rax, %r11\n    sub $16, %rsp\n    movq $2, (%rsp)\n    mov %r11, 8(%rsp)\n");
                    out.push_str(&format!("    mov %rsp, %rdx\n    mov $16, %esi\n    {}\n    call hbc_aadd\n    add $16, %rsp\n", aptr));
                } else if v.ty == Ty::DArr2 || v.ty == Ty::DArrRef2 || (v.ty == Ty::DArrU && matches!(vt, Ty::DArr | Ty::DArrU)) {
                    // Insert a dynamic array: the value MOVES into the
                    // parent (null the source right after the load). A
                    // static literal materializes as a dynamic child
                    // (header + tagged cells, the same shape as the
                    // middle arm's materialization - oracle hk94).
                    if let Expr::ArrLit(inner) = e {
                        let m = inner.len();
                        out.push_str("    sub $16, %rsp\n");
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", m));
                        for (p, xe) in inner.iter().enumerate() {
                            cg_expr(xe, env, sigs, strs, out, target);
                            if expr_ty(xe, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            if expr_ty(xe, env, sigs) == Ty::Bool {
                                out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                            }
                            out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p * 16, p * 16 + 8));
                        }
                        out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $16, %rsp\n", m));
                    } else if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src).cloned() {
                            if let Ty::Arr(m) = sv.ty {
                                // Static array VARIABLE: COPY its cells
                                // into a fresh dynamic child (the static
                                // source keeps its values - the copy
                                // contract of 33l/33m; Harbour SHARES,
                                // hk116, registered D5/D7 difference).
                                out.push_str("    sub $16, %rsp\n");
                                out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                                out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", m));
                                for p in 0..m {
                                    out.push_str(&format!("    mov -{}(%rbp), %rax\n    mov %rax, %rdx\n    xor %eax, %eax\n", sv.off - 8 * p));
                                    out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p * 16, p * 16 + 8));
                                }
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %edx\n    add $16, %rsp\n", m));
                            } else {
                                cg_value(e, env, sigs, strs, out, target);
                                if matches!(sv.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3) {
                                    out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                                }
                            }
                        } else {
                            cg_value(e, env, sigs, strs, out, target);
                        }
                    } else {
                        cg_value(e, env, sigs, strs, out, target);
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    out.push_str(&format!("    mov %rsp, %rdx\n    mov $16, %esi\n    {}\n    call hbc_aadd\n    add $16, %rsp\n", aptr));
                } else {
                    // Scalar element: tag it into the {tag, payload} pair
                    // (i64 -> {0, v}, NIL/Dyn -> copied pair).
                    cg_expr(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::I64 {
                        out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                    }
                    if expr_ty(e, env, sigs) == Ty::Bool {
                        out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    out.push_str(&format!("    mov %rsp, %rdx\n    mov $16, %esi\n    {}\n    call hbc_aadd\n    add $16, %rsp\n", aptr));
                }
                // Replicate the checker's pinning of `{}`.
                if let Some(x) = env.iter_mut().find(|x| x.name == *id) {
                    if x.ty == Ty::DArrU {
                        x.ty = if matches!(vt, Ty::DArr | Ty::DArrU) { Ty::DArr2 } else if matches!(vt, Ty::Str | Ty::StrOwn) { Ty::DArrS } else { Ty::DArr };
                    }
                }
            }
            Stmt::ASize(_, id, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                // kind 0: flat (grow NIL). kind 1: arrays (grow the empty
                // child; shrink frees children). kind 2: strings (shrink
                // frees the copies; grow is a clean runtime error here -
                // Harbour grows with NIL, oracle hk13).
                // kind 3: three levels (grow NIL casillas like kind 1;
                // shrink frees removed children RECURSIVELY via
                // hbc_rfree - they own their own children).
                let kind = if v.ty == Ty::DArr2 { 1 } else if v.ty == Ty::DArrS { 2 } else if v.ty == Ty::DArr3 || v.ty == Ty::DArrRef2 { 3 } else { 0 };
                // DArrRef: address of the owner's cell, like AAdd (hk87).
                let aptr = if v.ty == Ty::DArrRef || v.ty == Ty::DArrRef2 { format!("mov -{}(%rbp), %rdi", v.off) } else { format!("lea -{}(%rbp), %rdi", v.off) };
                cg_expr(e, env, sigs, strs, out, target);
                out.push_str(&format!("    mov %rax, %rsi\n    mov $16, %edx\n    mov ${}, %ecx\n    {}\n    call hbc_asize\n",
                    kind, aptr));
            }
            Stmt::AAddSub(_, id, ie, e) => {
                // AAdd(a[i], x): index FIRST, then the value (probe m7;
                // same order at the middle level, hk67).
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                if v.ty == Ty::DArr3 {
                    // Array element: a static literal materializes as a
                    // dynamic child (header + tagged cells, same shape as
                    // cg_darr2_literal's inner block); a call result or a
                    // variable MOVES in (source nulled right after the
                    // load - the move contract of root AAdd, NOT Harbour
                    // sharing; D5/D7 registered).
                    if let Expr::ArrLit(inner) = e {
                        let m = inner.len();
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, 8(%rsp)\n", m));
                        for (p, xe) in inner.iter().enumerate() {
                            cg_expr(xe, env, sigs, strs, out, target);
                            if expr_ty(xe, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            if expr_ty(xe, env, sigs) == Ty::Bool {
                                out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                            }
                            out.push_str(&format!("    mov 8(%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p * 16, p * 16 + 8));
                        }
                        out.push_str(&format!("    mov 8(%rsp), %rax\n    mov ${}, %edx\n", m));
                    } else if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src).cloned() {
                            if let Ty::Arr(m) = sv.ty {
                                // Static array variable: COPY (hk116;
                                // source keeps its values; D5/D7).
                                out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                                out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, 8(%rsp)\n", m));
                                for p in 0..m {
                                    out.push_str(&format!("    mov -{}(%rbp), %rax\n    mov %rax, %rdx\n    xor %eax, %eax\n", sv.off - 8 * p));
                                    out.push_str(&format!("    mov 8(%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p * 16, p * 16 + 8));
                                }
                                out.push_str(&format!("    mov 8(%rsp), %rax\n    mov ${}, %edx\n", m));
                            } else {
                                cg_value(e, env, sigs, strs, out, target);
                                if matches!(sv.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3) {
                                    out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                                }
                            }
                        } else {
                            cg_value(e, env, sigs, strs, out, target);
                        }
                    } else {
                        cg_value(e, env, sigs, strs, out, target);
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                } else {
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                if expr_ty(e, env, sigs) == Ty::Bool {
                    out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                }
                out.push_str("    mov 16(%rsp), %rcx\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                // A NIL casilla (fresh ASize growth) is Harbour's
                // BASE/1123 (hangs headless, oracle n6): clean error.
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_aadd_error\n");
                out.push_str("    mov %rsp, %rdx\n    mov $16, %esi\n    call hbc_aadd\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                out.push_str("    add $32, %rsp\n");
            }
            Stmt::ASizeSub(_, id, ie, e) => {
                // ASize(a[i], n): index first, then the size (probe m7).
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(e, env, sigs, strs, out, target);
                out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                // A NIL casilla is Harbour's BASE/2023 (hangs headless,
                // oracle n7): clean error.
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_asize_error\n");
                // DArr3 root: the middle child owns innermost arrays,
                // so its shrink frees them (kind 1); a DArr2 subarray is
                // flat (kind 0).
                let kind = if v.ty == Ty::DArr3 { 1 } else { 0 };
                out.push_str(&format!("    mov %rax, %rsi\n    mov $16, %edx\n    mov ${}, %ecx\n    call hbc_asize\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n", kind));
            }
            Stmt::AAddSub2(_, id, ie, ie2, e) => {
                // AAdd(a[i][j], x): i first, then j, then the value
                // (oracle pr8). Two bounds-checked pair walks; a null
                // child at either level is the clean AAdd error.
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                for iex in [ie, ie2] {
                    if expr_ty(iex, env, sigs) == Ty::Dyn {
                        cg_expr(iex, env, sigs, strs, out, target);
                        out.push_str("    call hbc_dyn_to_i64\n");
                    } else {
                        cg_expr(iex, env, sigs, strs, out, target);
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                }
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                if expr_ty(e, env, sigs) == Ty::Bool {
                    out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                // stack: [value 16][j 16][i 16]
                out.push_str("    mov 32(%rsp), %rcx\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_aadd_error\n");
                out.push_str("    mov 16(%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%rdi), %rcx\n    jg 87f\n");
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r10, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_aadd_error\n");
                out.push_str("    mov %rsp, %rdx\n    mov $16, %esi\n    call hbc_aadd\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                out.push_str("    add $48, %rsp\n");
            }
            Stmt::ASizeSub2(_, id, ie, ie2, e) => {
                // ASize(a[i][j], n): i first, then j, then the size
                // (oracle pr8). Grow zero-fills fresh slots (they read
                // NIL via the Dyn tag, probe pr8); shrink frees.
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(ie2, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(e, env, sigs, strs, out, target);
                // rax = size; stack: [j 16][i 16]
                out.push_str("    mov 16(%rsp), %rcx\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_asize_error\n");
                out.push_str("    mov (%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%rdi), %rcx\n    jg 87f\n");
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r10, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_asize_error\n");
                out.push_str("    mov %rax, %rsi\n    mov $16, %edx\n    xor %ecx, %ecx\n    call hbc_asize\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                out.push_str("    add $32, %rsp\n");
            }
            Stmt::AAddSub3(_, id, ie, ie2, ie3, e) => {
                // AAdd(a[i][j][k], x): i, then j, then k, then the value
                // (hk108). Three bounds-checked pair walks; a null child
                // at any level is the clean AAdd error.
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                for iex in [ie, ie2, ie3] {
                    if expr_ty(iex, env, sigs) == Ty::Dyn {
                        cg_expr(iex, env, sigs, strs, out, target);
                        out.push_str("    call hbc_dyn_to_i64\n");
                    } else {
                        cg_expr(iex, env, sigs, strs, out, target);
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                }
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                if expr_ty(e, env, sigs) == Ty::Bool {
                    out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                // stack: [value 16][k 16][j 16][i 16]
                out.push_str("    mov 48(%rsp), %rcx\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_aadd_error\n");
                out.push_str("    mov 32(%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%rdi), %rcx\n    jg 87f\n");
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r10, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_aadd_error\n");
                out.push_str("    mov 16(%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%rdi), %rcx\n    jg 87f\n");
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r10, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_aadd_error\n");
                out.push_str("    mov %rsp, %rdx\n    mov $16, %esi\n    call hbc_aadd\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                out.push_str("    add $64, %rsp\n");
            }
            Stmt::ASizeSub3(_, id, ie, ie2, ie3, e) => {
                // ASize(a[i][j][k], n): i, then j, then k, then the size
                // (hk105). Grow zero-fills fresh slots; shrink frees.
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(ie2, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(ie3, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(e, env, sigs, strs, out, target);
                // rax = size; stack: [k 16][j 16][i 16]
                out.push_str("    mov 32(%rsp), %rcx\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 87f\n    cmp -{}(%rbp), %rcx\n    jg 87f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r11, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_asize_error\n");
                out.push_str("    mov 16(%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%rdi), %rcx\n    jg 87f\n");
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r10, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_asize_error\n");
                out.push_str("    mov (%rsp), %rcx\n    cmp $1, %rcx\n    jl 87f\n    cmp 8(%rdi), %rcx\n    jg 87f\n");
                out.push_str("    mov %rcx, %rdi\n    dec %rdi\n    shl $4, %rdi\n    add %r10, %rdi\n");
                out.push_str("    mov (%rdi), %r10\n    test %r10, %r10\n    jz hbc_asize_error\n");
                out.push_str("    mov %rax, %rsi\n    mov $16, %edx\n    xor %ecx, %ecx\n    call hbc_asize\n    jmp 88f\n87:\n    call hbc_bound_error\n88:\n");
                out.push_str("    add $48, %rsp\n");
            }
            Stmt::HSet(_, id, ke, ve) => {
                // hb_HSet(h, key, value): KEY first, THEN the value
                // (probe hk161 - the OPPOSITE order of h[k] := v, h4).
                // hbc_hput copies both; an owned key temporary is freed
                // right after the call (same pattern as the h[k] write).
                let var = env.iter().rev().find(|x| x.name == *id).expect("checked");
                cg_value(ke, env, sigs, strs, out, target);
                let temp_key = expr_ty(ke, env, sigs) == Ty::StrOwn && !matches!(ke, Expr::Var(_));
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                cg_value(ve, env, sigs, strs, out, target);
                if expr_ty(ve, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                if expr_ty(ve, env, sigs) == Ty::Bool {
                    out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov 16(%rsp), %rsi\n    mov 24(%rsp), %rdx\n    mov %rsp, %rcx\n    call hbc_hput\n    add $16, %rsp\n", var.off));
                if temp_key {
                    out.push_str("    mov (%rsp), %rdi\n    call hbc_freestr\n");
                }
                out.push_str("    add $16, %rsp\n");
            }
            Stmt::HMerge(_, id, s) => {
                // hb_HMerge(dst, src): both slots by address (borrowed);
                // hbc_hmerge upserts every src entry in insertion order
                // through hbc_hput - the source WINS on overlap and keeps
                // its position (hk164), new keys append at the end, an
                // empty source is a no-op (hk165).
                let dst = env.iter().rev().find(|x| x.name == *id).expect("checked");
                let src = env.iter().rev().find(|x| x.name == *s).expect("checked");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    lea -{}(%rbp), %rsi\n    call hbc_hmerge\n", dst.off, src.off));
            }
            Stmt::HCopy(_, id, s2, se, ce) => {
                // hb_HCopy(src, dst [, start [, count]]): start
                // evaluates first, then count (left to right), then
                // both slots by address (borrowed). start 0/missing
                // becomes 1 (hk195); a NEGATIVE start is Harbour's
                // BASE/1123 dialog family (hk195d) - the registered
                // clean bound-error exit, never a compat target. count
                // missing = to the end (-1); count 0 and start > len
                // are no-ops; a long count clips at len (hk195b/hk195c).
                let src = env.iter().rev().find(|x| x.name == *id).expect("checked");
                let dst = env.iter().rev().find(|x| x.name == *s2).expect("checked");
                out.push_str("    sub $16, %rsp\n");
                match se {
                    Some(e) => {
                        cg_value(e, env, sigs, strs, out, target);
                        out.push_str("    cmp $1, %rax\n    jge 83f\n    test %rax, %rax\n    jnz 84f\n    mov $1, %eax\n    jmp 83f\n84:\n    call hbc_bound_error\n83:\n");
                    }
                    None => out.push_str("    mov $1, %eax\n"),
                }
                out.push_str("    mov %rax, (%rsp)\n");
                match ce {
                    Some(e) => { cg_value(e, env, sigs, strs, out, target); }
                    None => out.push_str("    mov $-1, %rax\n"),
                }
                out.push_str(&format!("    mov %rax, %rcx\n    lea -{}(%rbp), %rdi\n    lea -{}(%rbp), %rsi\n    mov (%rsp), %rdx\n    add $16, %rsp\n    call hbc_hcopy\n", src.off, dst.off));
            }
            Stmt::HSetCaseMatch(_, id, e) => {
                // hb_HSetCaseMatch(h, flag): the flag evaluates first,
                // then the slot address; the helper writes the header
                // flag (allocating a header-only block when the hash has
                // no block yet - hk176's empty-flagged case).
                let var = env.iter().rev().find(|x| x.name == *id).expect("checked");
                cg_value(e, env, sigs, strs, out, target);
                out.push_str(&format!("    mov %rax, %rsi
    lea -{}(%rbp), %rdi
    call hbc_hsetcasematch
", var.off));
            }
            Stmt::HDel(_, id, e) => {
                // hb_HDel: key first (borrowed - hbc_hdel only reads it),
                // then the slot address; the helper frees the hash-owned
                // key copy and shifts the remaining entries down,
                // preserving insertion order (hk155/hk156). An OWNED key
                // temporary (e.g. hb_HDel(h, keys[i])) is freed right
                // after the call (leak found and fixed in iteration 53;
                // t545).
                let var = env.iter().rev().find(|x| x.name == *id).expect("checked");
                cg_value(e, env, sigs, strs, out, target);
                let temp_key = expr_ty(e, env, sigs) == Ty::StrOwn && !matches!(e, Expr::Var(_));
                if temp_key {
                    out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    call hbc_hdel\n    mov (%rsp), %rdi\n    call hbc_freestr\n    add $32, %rsp\n", var.off));
                } else {
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov (%rsp), %rsi\n    mov 8(%rsp), %rdx\n    call hbc_hdel\n    add $16, %rsp\n", var.off));
                }
            }
            Stmt::HClear(_, id) => {
                // hb_HClear: the slot goes by address; the helper
                // frees every key copy and the whole data block and
                // zeroes the slot (hk191/hk193: reusable after a
                // clear, CaseMatch flag back to the default).
                let var = env.iter().rev().find(|x| x.name == *id).expect("checked");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    call hbc_hclear\n", var.off));
            }
            Stmt::HFill(_, id, e) => {
                // hb_HFill: the value evaluates first, normalized to
                // the Dyn pair rsi=tag, rdx=payload (a plain integer
                // gets tag 0); then the slot by address. The helper
                // writes the pair into every entry (hk192).
                let var = env.iter().rev().find(|x| x.name == *id).expect("checked");
                cg_value(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                if expr_ty(e, env, sigs) == Ty::Bool {
                    out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                }
                out.push_str("    mov %rax, %rsi\n");
                out.push_str(&format!("    lea -{}(%rbp), %rdi\n    call hbc_hfill\n", var.off));
            }
            Stmt::HDelAt(_, id, e) => {
                // hb_HDelAt: position first, then the slot address;
                // the helper frees the hash-owned key copy and shifts
                // the remaining entries down, preserving insertion
                // order (hk187/hk190). rax = 0 (out of range) takes
                // the registered clean bound-error exit (Harbour's
                // BASE/1187 dialog hangs headless - hk189, the
                // dialogo-sin-oraculo family).
                let var = env.iter().rev().find(|x| x.name == *id).expect("checked");
                cg_value(e, env, sigs, strs, out, target);
                out.push_str(&format!("    mov %rax, %rsi\n    lea -{}(%rbp), %rdi\n    call hbc_hdelat\n    test %rax, %rax\n    jne 87f\n    call hbc_bound_error\n87:\n", var.off));
            }
            Stmt::ArrSet(_, id, ie, e) => {
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                if v.ty == Ty::DArr2 {
                    // Child overwrite: RHS (a dynamic array) moves in; the
                    // OLD child is freed once, AFTER the new value exists
                    // and the source was nulled (no double free).
                    if let Expr::ArrLit(inner) = e {
                        // i64 literal -> Dyn-element child (same shape as
                        // nested-literal children; oracle n3).
                        let m = inner.len();
                        out.push_str("    sub $16, %rsp\n");
                        out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                        out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", m));
                        for (p2, ie2) in inner.iter().enumerate() {
                            cg_expr(ie2, env, sigs, strs, out, target);
                            if expr_ty(ie2, env, sigs) == Ty::I64 {
                                out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                            }
                            if expr_ty(ie2, env, sigs) == Ty::Bool {
                                out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                            }
                            out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p2 * 16, p2 * 16 + 8));
                        }
                        out.push_str(&format!("    mov (%rsp), %rax\n    add $16, %rsp\n    mov ${}, %rdx\n", m));
                    } else if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src).cloned() {
                            if let Ty::Arr(m) = sv.ty {
                                // Static array variable: COPY into a
                                // fresh child (hk116; source keeps its
                                // values; D5/D7).
                                out.push_str("    sub $16, %rsp\n");
                                out.push_str(&format!("    mov ${}, %rdi\n    call hbc_alloc\n", 8 + m * 16));
                                out.push_str(&format!("    movq ${}, (%rax)\n    add $8, %rax\n    mov %rax, (%rsp)\n", m));
                                for p in 0..m {
                                    out.push_str(&format!("    mov -{}(%rbp), %rax\n    mov %rax, %rdx\n    xor %eax, %eax\n", sv.off - 8 * p));
                                    out.push_str(&format!("    mov (%rsp), %r11\n    mov %rax, {}(%r11)\n    mov %rdx, {}(%r11)\n", p * 16, p * 16 + 8));
                                }
                                out.push_str(&format!("    mov (%rsp), %rax\n    mov ${}, %rdx\n    add $16, %rsp\n", m));
                            } else {
                                cg_value(e, env, sigs, strs, out, target);
                                if matches!(sv.ty, Ty::DArr | Ty::DArrU | Ty::DArr2 | Ty::DArr3) {
                                    out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                                }
                            }
                        } else {
                            cg_value(e, env, sigs, strs, out, target);
                        }
                    } else {
                        cg_value(e, env, sigs, strs, out, target);
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, %rcx\n");
                    out.push_str(&format!("    cmp $1, %rcx\n    jl 89f\n    cmp -{}(%rbp), %rcx\n    jg 89f\n", v.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                    out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    // free the old child (a Dyn-element array: shallow free)
                    out.push_str("    mov (%r10), %rdi\n    test %rdi, %rdi\n    je 85f\n    mov $16, %esi\n    sub $16, %rsp\n    mov %r10, (%rsp)\n    call hbc_free\n    mov (%rsp), %r10\n    add $16, %rsp\n85:\n");
                    out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    mov %rax, (%r10)\n    mov %rdx, 8(%r10)\n    add $16, %rsp\n    jmp 86f\n89:\n    call hbc_bound_error\n86:\n");
                } else if v.ty == Ty::DArrS {
                    // Element overwrite on an array of strings: the value
                    // evaluates FIRST (probe adv2's order), a rodata value
                    // is copied and an owned one moves in; the OLD owned
                    // copy is freed once, after the new one exists.
                    cg_value(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::Str {
                        out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n");
                    }
                    if let Expr::Var(src) = e {
                        if let Some(sv) = env.iter().rev().find(|x| x.name == *src && x.ty == Ty::StrOwn) {
                            out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", sv.off, sv.off - 8));
                        }
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, %rcx\n");
                    out.push_str(&format!("    cmp $1, %rcx\n    jl 89f\n    cmp -{}(%rbp), %rcx\n    jg 89f\n", v.off - 8));
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                    out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                    // free the old owned copy (payload at 8(entry); a
                    // NIL casilla from ASize growth has a null payload,
                    // skipped here and RETAGGED to a string below - hk14)
                    out.push_str("    mov 8(%r10), %rdi\n    test %rdi, %rdi\n    je 85f\n    sub $16, %rsp\n    mov %r10, (%rsp)\n    call hbc_freestr\n    mov (%rsp), %r10\n    add $16, %rsp\n85:\n");
                    out.push_str("    mov (%rsp), %rax\n    movq $2, (%r10)\n    mov %rax, 8(%r10)\n    add $16, %rsp\n    jmp 86f\n89:\n    call hbc_bound_error\n86:\n");
                } else if v.ty == Ty::Hash {
                    // h[k] := v: value FIRST, then the key (probe h4).
                    // Both wait on the stack across hbc_hput, which copies
                    // the key bytes and the value - the hash owns copies,
                    // the temporaries stay owned here.
                    cg_value(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::I64 {
                        out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                    }
                    if expr_ty(e, env, sigs) == Ty::Bool {
                        out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    cg_value(ie, env, sigs, strs, out, target);
                    out.push_str("    mov %rax, %rsi\n");
                    let temp_key = expr_ty(ie, env, sigs) == Ty::StrOwn && !matches!(ie, Expr::Var(_));
                    if temp_key {
                        // Owned key copy (h[keys[i]] := v): hbc_hput copies
                        // the bytes, so the temporary is freed right after.
                        out.push_str("    sub $16, %rsp\n    mov %rsi, (%rsp)\n");
                        out.push_str(&format!("    lea -{}(%rbp), %rdi\n    lea 16(%rsp), %rcx\n    call hbc_hput\n    mov (%rsp), %rdi\n    call hbc_freestr\n    add $32, %rsp\n", v.off));
                    } else {
                        out.push_str(&format!("    lea -{}(%rbp), %rdi\n    mov %rsp, %rcx\n    call hbc_hput\n    add $16, %rsp\n", v.off));
                    }
                } else if v.ty == Ty::DArr || v.ty == Ty::DArrRef {
                    // Dynamic array write: same value-first order; bounds
                    // 1..=len from the slot word. Elements are {tag,
                    // payload} pairs. Borrows `a` - never nulls.
                    // DArrRef (a borrowed middle array): the slot holds the
                    // child cell's ADDRESS; bounds and base load through it
                    // so the write lands in the owner's cell (oracle hk86).
                    cg_expr(e, env, sigs, strs, out, target);
                    if expr_ty(e, env, sigs) == Ty::I64 {
                        out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                    }
                    if expr_ty(e, env, sigs) == Ty::Bool {
                        out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                    if expr_ty(ie, env, sigs) == Ty::Dyn {
                        cg_expr(ie, env, sigs, strs, out, target);
                        out.push_str("    call hbc_dyn_to_i64\n");
                    } else {
                        cg_expr(ie, env, sigs, strs, out, target);
                    }
                    out.push_str("    mov %rax, %rcx\n    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
                    if v.ty == Ty::DArrRef {
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rcx\n    jl 83f\n    cmp 8(%r11), %rcx\n    jg 83f\n", v.off));
                        out.push_str("    mov (%r11), %r11\n");
                    } else {
                        out.push_str(&format!("    cmp $1, %rcx\n    jl 83f\n    cmp -{}(%rbp), %rcx\n    jg 83f\n", v.off - 8));
                        out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                    }
                    out.push_str("    dec %rcx\n    shl $4, %rcx\n    add %r11, %rcx\n    mov %rax, (%rcx)\n    mov %rdx, 8(%rcx)\n    jmp 84f\n");
                    out.push_str("83:\n    call hbc_bound_error\n84:\n");
                } else {
                let k = match v.ty { Ty::Arr(k) => k, _ => unreachable!("checked") };
                // Value FIRST, then the index: both Harbour (probe adv2,
                // `a[idx()] := give()` prints give's side effect first)
                // and Rust (`a[i] = v` evaluates the RHS before the place)
                // use this order. The value waits in a 16-byte stack slot
                // (keeps rsp 16-aligned for the Win64 ABI if the index
                // expression calls; the Linux side is our own freestanding
                // syscall convention - it imposes no external ABI, but we
                // claim no general System V compliance either).
                cg_expr(e, env, sigs, strs, out, target);
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                cg_expr(ie, env, sigs, strs, out, target);
                out.push_str("    mov %rax, %rcx\n    mov (%rsp), %rax\n    add $16, %rsp\n");
                out.push_str(&format!("    cmp $1, %rcx\n    jl 83f\n    cmp ${}, %rcx\n    jg 83f\n", k));
                out.push_str(&format!("    lea -{}(%rbp), %r11\n    mov %rax, -8(%r11,%rcx,8)\n    jmp 84f\n", v.off));
                out.push_str("83:\n    call hbc_bound_error\n84:\n");
                }
            }
            Stmt::ArrSet2(_, id, ie, ie2, e) => {
                // a[i][j] := v: value first, then outer index, then inner
                // index (probe m7); both bounds checked; transient borrows.
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                if expr_ty(e, env, sigs) == Ty::Bool {
                    out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                if expr_ty(ie, env, sigs) == Ty::Dyn {
                    cg_expr(ie, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie, env, sigs, strs, out, target);
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                if expr_ty(ie2, env, sigs) == Ty::Dyn {
                    cg_expr(ie2, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie2, env, sigs, strs, out, target);
                }
                out.push_str("    mov (%rsp), %rcx\n    add $16, %rsp\n");
                // rax = value(sp), rcx = i, then j in rax below
                out.push_str("    mov %rax, %r9\n    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
                // rax = value tag, rdx = payload, rcx = i, r9 = j
                if v.ty == Ty::DArrRef2 {
                    // p[i][j] := v through the borrowed middle of a
                    // three-level array (hk95): root bounds and base load
                    // through the owner's cell address, the write lands
                    // in the owner's innermost cell.
                    out.push_str(&format!("    mov -{}(%rbp), %r11\n    cmp $1, %rcx\n    jl 90f\n    cmp 8(%r11), %rcx\n    jg 90f\n", v.off));
                    out.push_str("    mov (%r11), %r11\n    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                } else {
                out.push_str(&format!("    cmp $1, %rcx\n    jl 90f\n    cmp -{}(%rbp), %rcx\n    jg 90f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    mov %rcx, %r10\n    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                }
                out.push_str("    cmp $1, %r9\n    jl 90f\n    cmp 8(%r10), %r9\n    jg 90f\n");
                out.push_str("    mov (%r10), %r11\n    dec %r9\n    shl $4, %r9\n    add %r11, %r9\n    mov %rax, (%r9)\n    mov %rdx, 8(%r9)\n    jmp 92f\n90:\n    call hbc_bound_error\n92:\n");
            }
            Stmt::ArrSet3(_, id, ie, ie2, ie3, e) => {
                // a[i][j][k] := v: value first, then the indices left to
                // right (probe m7 order); every level bounds checked; a
                // null child pointer is a bound error (same as reads).
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                if expr_ty(e, env, sigs) == Ty::Bool {
                    out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                for iex in [ie, ie2] {
                    if expr_ty(iex, env, sigs) == Ty::Dyn {
                        cg_expr(iex, env, sigs, strs, out, target);
                        out.push_str("    call hbc_dyn_to_i64\n");
                    } else {
                        cg_expr(iex, env, sigs, strs, out, target);
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                }
                if expr_ty(ie3, env, sigs) == Ty::Dyn {
                    cg_expr(ie3, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie3, env, sigs, strs, out, target);
                }
                // rax = k; pop j -> rcx, i -> r10, value -> rax(tag)/rdx(payload)
                out.push_str("    mov %rax, %r9\n    mov (%rsp), %rcx\n    add $16, %rsp\n    mov (%rsp), %r10\n    add $16, %rsp\n    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
                // level 1: i in r10 against the outer length
                out.push_str(&format!("    cmp $1, %r10\n    jl 90f\n    cmp -{}(%rbp), %r10\n    jg 90f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                // level 2: j in rcx against the child length
                out.push_str("    cmp $1, %rcx\n    jl 90f\n    cmp 8(%r10), %rcx\n    jg 90f\n    mov (%r10), %r11\n    test %r11, %r11\n    jz 90f\n    dec %rcx\n    shl $4, %rcx\n    add %r11, %rcx\n");
                // level 3: k in r9 against the innermost length
                out.push_str("    cmp $1, %r9\n    jl 90f\n    cmp 8(%rcx), %r9\n    jg 90f\n    mov (%rcx), %r11\n    test %r11, %r11\n    jz 90f\n    dec %r9\n    shl $4, %r9\n    add %r11, %r9\n    mov %rax, (%r9)\n    mov %rdx, 8(%r9)\n    jmp 92f\n90:\n    call hbc_bound_error\n92:\n");
            }
            Stmt::ArrSet4(_, id, ie, ie2, ie3, ie4, e) => {
                // a[i][j][k][l] := v: value first, then the indices left to
                // right (hk104); every level bounds checked; a null child
                // pointer is a bound error (same as reads).
                let v = env.iter().find(|v| v.name == *id).expect("checked").clone();
                cg_expr(e, env, sigs, strs, out, target);
                if expr_ty(e, env, sigs) == Ty::I64 {
                    out.push_str("    mov %rax, %rdx\n    xor %eax, %eax\n");
                }
                if expr_ty(e, env, sigs) == Ty::Bool {
                    out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n");
                }
                out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
                for iex in [ie, ie2, ie3] {
                    if expr_ty(iex, env, sigs) == Ty::Dyn {
                        cg_expr(iex, env, sigs, strs, out, target);
                        out.push_str("    call hbc_dyn_to_i64\n");
                    } else {
                        cg_expr(iex, env, sigs, strs, out, target);
                    }
                    out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");
                }
                if expr_ty(ie4, env, sigs) == Ty::Dyn {
                    cg_expr(ie4, env, sigs, strs, out, target);
                    out.push_str("    call hbc_dyn_to_i64\n");
                } else {
                    cg_expr(ie4, env, sigs, strs, out, target);
                }
                // rax = l -> r8; pop k -> r9, j -> rcx, i -> r10, value -> rax/rdx
                out.push_str("    mov %rax, %r8\n    mov (%rsp), %r9\n    add $16, %rsp\n    mov (%rsp), %rcx\n    add $16, %rsp\n    mov (%rsp), %r10\n    add $16, %rsp\n    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
                // level 1: i in r10 against the outer length
                out.push_str(&format!("    cmp $1, %r10\n    jl 90f\n    cmp -{}(%rbp), %r10\n    jg 90f\n", v.off - 8));
                out.push_str(&format!("    mov -{}(%rbp), %r11\n", v.off));
                out.push_str("    dec %r10\n    shl $4, %r10\n    add %r11, %r10\n");
                // level 2: j in rcx
                out.push_str("    cmp $1, %rcx\n    jl 90f\n    cmp 8(%r10), %rcx\n    jg 90f\n    mov (%r10), %r11\n    test %r11, %r11\n    jz 90f\n    dec %rcx\n    shl $4, %rcx\n    add %r11, %rcx\n");
                // level 3: k in r9
                out.push_str("    cmp $1, %r9\n    jl 90f\n    cmp 8(%rcx), %r9\n    jg 90f\n    mov (%rcx), %r11\n    test %r11, %r11\n    jz 90f\n    dec %r9\n    shl $4, %r9\n    add %r11, %r9\n");
                // level 4: l in r8 against the innermost length
                out.push_str("    cmp $1, %r8\n    jl 90f\n    cmp 8(%r9), %r8\n    jg 90f\n    mov (%r9), %r11\n    test %r11, %r11\n    jz 90f\n    dec %r8\n    shl $4, %r8\n    add %r11, %r8\n    mov %rax, (%r8)\n    mov %rdx, 8(%r8)\n    jmp 92f\n90:\n    call hbc_bound_error\n92:\n");
            }
        }
    }
}

// Collect every block literal in a statement tree (deterministic order).
fn collect_blocks_expr(e: &Expr, out: &mut Vec<(usize, Vec<String>, Vec<Expr>)>) {
    if let Expr::Send(o, _, args) = e {
        collect_blocks_expr(o, out);
        for a in args { collect_blocks_expr(a, out); }
        return;
    }
    if matches!(e, Expr::SelfObj | Expr::SelfGet(_)) { return; }
    match e {
        Expr::Seq(es) => { for x in es { collect_blocks_expr(x, out); } }
        Expr::BlockLit(id, ps, body) => {
            out.push((*id, ps.clone(), body.clone()));
            for e in body { collect_blocks_expr(e, out); }
        }
        Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) => { collect_blocks_expr(a, out); collect_blocks_expr(b, out); }
        Expr::Call(_, args) => { for a in args { collect_blocks_expr(a, out); } }
        Expr::ArrLit(es) => { for e in es { collect_blocks_expr(e, out); } }
        Expr::Index(_, ie) => collect_blocks_expr(ie, out),
        Expr::Index2(_, ie, ie2) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); }
        _ => {}
    }
}
fn collect_blocks_stmts(stmts: &[Stmt], out: &mut Vec<(usize, Vec<String>, Vec<Expr>)>) {
    for s in stmts {
        match s {
            Stmt::Local(_, _, e) | Stmt::Assign(_, _, e) => collect_blocks_expr(e, out),
            Stmt::HDel(_, _, e) => { collect_blocks_expr(e, out); }
            Stmt::HDelAt(_, _, e) => { collect_blocks_expr(e, out); }
            Stmt::HClear(_, _) => {}
            Stmt::HFill(_, _, e) => { collect_blocks_expr(e, out); }
            Stmt::HSet(_, _, ke, ve) => { collect_blocks_expr(ke, out); collect_blocks_expr(ve, out); }
            Stmt::HSetCaseMatch(_, _, e) => { collect_blocks_expr(e, out); }
            Stmt::HMerge(_, _, _) => {}
            Stmt::HCopy(_, _, _, se, ce) => { if let Some(e) = se { collect_blocks_expr(e, out); } if let Some(e) = ce { collect_blocks_expr(e, out); } }
            Stmt::ArrSet(_, _, ie, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(e, out); }
            Stmt::Print(_, es, _) => { for e in es { collect_blocks_expr(e, out); } }
            Stmt::Ret(_, Some(e)) => collect_blocks_expr(e, out),
            Stmt::SelfSet(_, _, e) | Stmt::SendStmt(_, e) | Stmt::CallStmt(_, e) => collect_blocks_expr(e, out),
            Stmt::SendSet(_, o, _, e) => { collect_blocks_expr(o, out); collect_blocks_expr(e, out); }
            Stmt::Ret(_, None) | Stmt::Exit(_) | Stmt::Loop(_) => {}
            Stmt::AAdd(_, _, e) | Stmt::ASize(_, _, e) => collect_blocks_expr(e, out),
            Stmt::ArrSet2(_, _, ie, ie2, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); collect_blocks_expr(e, out); }
            Stmt::ArrSet3(_, _, ie, ie2, ie3, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); collect_blocks_expr(ie3, out); collect_blocks_expr(e, out); }
            Stmt::ArrSet4(_, _, ie, ie2, ie3, ie4, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); collect_blocks_expr(ie3, out); collect_blocks_expr(ie4, out); collect_blocks_expr(e, out); }
            Stmt::AAddSub(_, _, ie, e) | Stmt::ASizeSub(_, _, ie, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(e, out); }
            Stmt::AAddSub2(_, _, ie, ie2, e) | Stmt::ASizeSub2(_, _, ie, ie2, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); collect_blocks_expr(e, out); }
            Stmt::AAddSub3(_, _, ie, ie2, ie3, e) | Stmt::ASizeSub3(_, _, ie, ie2, ie3, e) => { collect_blocks_expr(ie, out); collect_blocks_expr(ie2, out); collect_blocks_expr(ie3, out); collect_blocks_expr(e, out); }
            Stmt::If(_, c, a, b) => { collect_blocks_expr(c, out); collect_blocks_stmts(a, out); collect_blocks_stmts(b, out); }
            Stmt::While(_, c, body) => { collect_blocks_expr(c, out); collect_blocks_stmts(body, out); }
            Stmt::For(_, _, a, b, _, body) => { collect_blocks_expr(a, out); collect_blocks_expr(b, out); collect_blocks_stmts(body, out); }
            Stmt::ForEach(_, _, c, body) => { collect_blocks_expr(c, out); collect_blocks_stmts(body, out); }
        }
    }
}

// Emit one block as a function with the standard convention: parameters
// copied from the caller's argument slots, body expressions evaluated in
// order, the LAST one's value returned in %rax (probe c4). Integer
// parameters and bodies only in this increment (checked in analysis), so
// no strings, no drops, no heap.
fn emit_block(owner: &str, id: usize, params: &[String], body: &[Expr], sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target) {
    let mut lenv: Vec<CgLocal> = Vec::new();
    let mut frame = 0usize;
    for p in params {
        frame += 8;
        lenv.push(CgLocal { name: p.clone(), ty: Ty::I64, off: frame });
    }
    let n = lenv.len();
    let trace_off = frame + 32;
    frame = trace_off;
    out.push_str(&format!("hbc_blk_{}:\n", id));
    out.push_str("    push %rbp\n    mov %rsp, %rbp\n");
    // Blocks can now call output/string helpers: align both targets.
    let frame = (frame + 15) & !15;
    if frame > 0 {
        out.push_str(&format!("    sub ${}, %rsp\n", frame));
    }
    PROC_NAME.with(|v| *v.borrow_mut() = format!("(b){}", owner.split("__br").next().unwrap_or(owner).to_ascii_uppercase()));
    // hb_PValue never reaches a codeblock body (named checker rejection);
    // the marker keeps a missed case a panic, never a silent miscompile.
    CUR_FN.with(|c| *c.borrow_mut() = format!("(blk){}", owner));
    trace_link(trace_off, out);
    let block_line = TRACE_BLOCK_LINES.with(|m| m.borrow().get(&id).copied()).unwrap_or(0);
    trace_location(&format!("<block#{}>", id), block_line, strs, out);
    for (k, v) in lenv.iter().enumerate() {
        let src = 16 * (n - k);
        out.push_str(&format!("    mov {}(%rbp), %rax\n", src));
        out.push_str(&format!("    mov %rax, -{}(%rbp)\n", v.off));
    }
    for (i, e) in body.iter().enumerate() {
        cg_expr(e, &lenv, sigs, strs, out, target);
        if i + 1 < body.len() {
            out.push_str("    # intermediate block expression: value discarded (probe c4)\n");
        }
    }
    trace_unlink(trace_off, out);
    out.push_str("    leave\n    ret\n\n");
}

fn cg_func(f: &Func, sigs: &[Sig], strs: &mut Vec<String>, out: &mut String, target: Target, byref: Option<&Vec<bool>>) {
    // Variant label: the base body is `hbc_fn_<name>`; a `@`-variant adds
    // its mask (hk216 family).
    let lbl: String = match byref {
        None => f.name.clone(),
        Some(m) => format!("{}__br{}", f.name, m.iter().map(|b| if *b { "1" } else { "0" }).collect::<String>()),
    };
    let mut lenv: Vec<CgLocal> = Vec::new();
    let mut frame = 0usize;
    // Parameters occupy the first frame slots, sized by their pinned type.
    // (main has no signature entry: it returns nil and takes no parameters.)
    if !f.params.is_empty() {
        let own_sig = sigs.iter().find(|v| v.name == f.name).expect("checked");
        for (i, p) in f.params.iter().enumerate() {
            frame += size_of(own_sig.params[i]);
            // A parameter some caller feeds as `a[i]` arrives as the cell
            // ADDRESS (one word): borrow shape, never freed here.
            let pty = if own_sig.borrowed.get(i).copied().unwrap_or(false) && own_sig.params[i] == Ty::DArr { Ty::DArrRef } else if own_sig.borrowed.get(i).copied().unwrap_or(false) && own_sig.params[i] == Ty::DArr2 { Ty::DArrRef2 } else { own_sig.params[i] };
            let pty = if byref.map(|m| m.get(i).copied().unwrap_or(false)).unwrap_or(false) {
                // `@`-received parameter: the slot holds the OWNER's slot
                // address (one word); reads and writes go through it and
                // the slot is never freed here (hk216/hk218).
                match pty {
                    Ty::I64 | Ty::Bool => Ty::RefI64,
                    Ty::Str | Ty::StrOwn => Ty::RefStrOwn,
                    other => unreachable!("the checker rejects `@` on this parameter type: {:?}", other),
                }
            } else { pty };
            lenv.push(CgLocal { name: p.clone(), ty: pty, off: frame });
        }
    }
    let nparams = lenv.len();
    // The statement walk must start from the DECLARED param sizes (the
    // same convention as the lenv offsets above): a `@`-received string
    // param is remapped to the one-word RefStrOwn, but its slot still
    // advances the frame by size_of(StrOwn) = 16. Summing the remapped
    // types instead would start the walk 8 bytes low and collide with
    // the param slot (hk238: `for` counter overwrote the byref pointer).
    let params_frame = frame;
    let mut darr_slots: Vec<(usize, u8)> = Vec::new();
    let byref_names_layout = byref_names_in(&f.stmts);
    layout_locals(&f.stmts, &mut lenv, sigs, &mut frame, &mut darr_slots, &f.dyn_names, &byref_names_layout);
    // Dynamic-array parameters are owned by this function: their slots are
    // freed at the shared epilogue like any other DArr local.
    for v in &lenv[..lenv.len().min(f.params.len())] {
        if v.ty == Ty::DArr {
            darr_slots.push((v.off, 0));
        }
        if v.ty == Ty::DArr2 {
            darr_slots.push((v.off, 1));
        }
        if v.ty == Ty::DArr3 {
            darr_slots.push((v.off, 3));
        }
        if v.ty == Ty::DArr4 {
            darr_slots.push((v.off, 6));
        }
        if v.ty == Ty::DArrS {
            darr_slots.push((v.off, 4));
        }
        if v.ty == Ty::StrOwn {
            darr_slots.push((v.off, 5));
        }
        if v.ty == Ty::Hash {
            darr_slots.push((v.off, 2));
        }
        if v.ty == Ty::Dyn {
            // Dyn params own their casilla: the call boundary clones any
            // string payload (tag 4), so the epilogue frees it once.
            darr_slots.push((v.off, 7));
        }
    }

    let trace_off = frame + 32;
    frame = trace_off;
    out.push_str(&format!("hbc_fn_{}:\n", lbl));
    out.push_str("    push %rbp\n    mov %rsp, %rbp\n");
    // Win64 ABI: rsp must be 16-byte aligned at every call. The Linux
    // frame only needs 8-byte slots (syscalls do not care); round up to 16
    // for Windows so the helper call sites keep ABI alignment.
    let frame = if target == Target::Windows { (frame + 15) & !15 } else { frame };
    if frame > 0 {
        out.push_str(&format!("    sub ${}, %rsp\n", frame));
    }
    PROC_NAME.with(|v| *v.borrow_mut() = f.name.split("__br").next().unwrap_or(&f.name).to_ascii_uppercase());
    CUR_FN.with(|c| *c.borrow_mut() = f.name.clone());
    trace_link(trace_off, out);
    trace_location(&f.name, f.stmts.first().map(stmt_line).unwrap_or(0), strs, out);
    // Zero-init every dynamic-array slot (parameters included): the
    // epilogue and reassignment free any non-null slot, so every slot must
    // start in the known-empty state even when its declaring branch never
    // runs. Argument copy-in below overwrites the parameter slots.
    for (off, _) in &darr_slots {
        out.push_str(&format!("    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n", off, off - 8));
    }
    // Copy incoming arguments from the caller's stack into the parameter
    // slots: arguments were pushed left to right, so arg k sits at
    // 16*(n-k)(%rbp) after this prologue (the last argument is nearest).
    // A string argument occupies both words of its slot (pointer, length).
    for (k, v) in lenv[..nparams].iter().enumerate() {
        let src = 16 * (nparams - k);
        if v.ty == Ty::Str || v.ty == Ty::DArr || v.ty == Ty::Dyn || v.ty == Ty::DArr2 || v.ty == Ty::DArr3 || v.ty == Ty::DArr4 || v.ty == Ty::DArrS || v.ty == Ty::StrOwn || v.ty == Ty::Hash || v.ty == Ty::F64 {
            // Two-word slots: (pointer, length) for owned data; (value
            // bits, packed metadata) for a float parameter (63zd).
            out.push_str(&format!("    mov {}(%rbp), %rax\n    mov {}(%rbp), %rdx\n", src, src + 8));
            out.push_str(&format!("    mov %rax, -{}(%rbp)\n    mov %rdx, -{}(%rbp)\n", v.off, v.off - 8));
        } else {
            out.push_str(&format!("    mov {}(%rbp), %rax\n", src));
            out.push_str(&format!("    mov %rax, -{}(%rbp)\n", v.off));
        }
    }
    let mut env: Vec<CgLocal> = lenv[..nparams].to_vec();
    let mut walk_frame = params_frame;
    let mut label = 0usize;
    let byref_names = byref_names_in(&f.stmts);
    cg_stmts(&f.stmts, &mut env, &mut walk_frame, sigs, strs, out, target, &lbl, &mut label, &None, &darr_slots, &f.dyn_names, &byref_names);
    // Free every dynamic array still owned on this exit path. A slot is
    // null when its value was moved out (moves null the source, so each
    // allocation has exactly one freeing owner) or when it never held a
    // value; freeing checks the pointer, so both cases are safe without
    // any path tracking in codegen. The return value was moved to the
    // output registers (and its slot nulled) before this point.
    out.push_str(&format!(".Lret_{}:\n", lbl));
    // The return value waits on the stack while the frees run: hbc_free
    // clobbers rax (and rdx on Windows) and a slot still owned here must
    // not destroy it. A FLOAT return rides xmm0/rdi (63zd convention):
    // rdi is hbc_free's own argument register, so the pair waits on the
    // same 16-byte stack slot in both targets - nested calls and return
    // temporaries survive the epilogue by construction (test t770).
    let f64_ret = sigs.iter().any(|s| s.name == f.name && s.ret == Some(Ty::F64));
    if f64_ret {
        out.push_str("    sub $16, %rsp\n    movsd %xmm0, (%rsp)\n    mov %rdi, 8(%rsp)\n");
    } else {
        out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");
    }
    for (i, (off, class)) in darr_slots.iter().enumerate() {
        match class {
            1 => {
                // DArr2: free each live child, then the outer block.
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov -{}(%rbp), %rsi\n    call hbc_free2\n91{}:\n", off, i, off - 8, i));
            }
            2 => {
                // Hash: free each live key copy, then the block.
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov -{}(%rbp), %rsi\n    call hbc_hfree\n91{}:\n", off, i, off - 8, i));
            }
            3 => {
                // DArr3: recursive free, two pair-levels (rdx = depth).
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov -{}(%rbp), %rsi\n    mov $2, %edx\n    call hbc_rfree\n91{}:\n", off, i, off - 8, i));
            }
            6 => {
                // DArr4: recursive free, three pair-levels (hk103).
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov -{}(%rbp), %rsi\n    mov $3, %edx\n    call hbc_rfree\n91{}:\n", off, i, off - 8, i));
            }
            4 => {
                // DArrS: free each owned key copy, then the block.
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov -{}(%rbp), %rsi\n    call hbc_sfree\n91{}:\n", off, i, off - 8, i));
            }
            5 => {
                // StrOwn: an owned string copy; hbc_freestr(ptr) releases
                // exactly 16 + cap bytes (cap at ptr-16, len at ptr-8).
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    call hbc_freestr\n91{}:\n", off, i, i));
            }
            7 => {
                // Dyn slot: free the payload only for an OWNED string
                // (tag 4). Borrowed tag-2 views (FOR EACH over hash keys)
                // and scalar tags (0/1/3) own nothing.
                out.push_str(&format!("    cmpq $4, -{}(%rbp)\n    jne 91{}f\n    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    call hbc_freestr\n91{}:\n", off, i, off - 8, i, i));
            }
            _ => {
                out.push_str(&format!("    mov -{}(%rbp), %rdi\n    test %rdi, %rdi\n    je 91{}f\n    mov $16, %esi\n    call hbc_free\n91{}:\n", off, i, i));
            }
        }
    }
    if f64_ret {
        out.push_str("    movsd (%rsp), %xmm0\n    mov 8(%rsp), %rdi\n    add $16, %rsp\n");
    } else {
        out.push_str("    mov (%rsp), %rax\n    mov 8(%rsp), %rdx\n    add $16, %rsp\n");
    }
    trace_unlink(trace_off, out);
    out.push_str("    leave\n    ret\n\n");
    // Block literals used by this function are emitted right after it.
    let mut blocks = Vec::new();
    collect_blocks_stmts(&f.stmts, &mut blocks);
    for (id, ps, body) in blocks {
        emit_block(&f.name, id, &ps, &body, sigs, strs, out, target);
    }
}

const REG_ALLOC_L: &str = r"    # harness registry (instrumented build): record (base, bytes) so
    # hbc_free can verify the exact unmap length, not just call balance.
    # Freed entries are reused (swap-with-last in hbc_free); the 16384
    # CONCURRENT-live limit exists only in this build and reports as OOM.
    mov hbc_reg_count(%rip), %rcx
    cmp $16384, %rcx
    jae hbc_oom
    lea hbc_reg_base(%rip), %r10
    mov %rax, (%r10,%rcx,8)
    lea hbc_reg_size(%rip), %r10
    mov %rsi, (%r10,%rcx,8)
    incq hbc_reg_count(%rip)
";
const REG_FREE_L: &str = r"    # harness registry: the computed unmap length must equal the recorded
    # allocation size, and the block must be live (double free = absent).
    # Callers keep loop state in r9/r10 (hbc_asize shrink) and possibly
    # rdx across this call: preserve them; r11 is syscall-clobbered anyway.
    push %rdx
    push %r9
    push %r10
    mov hbc_reg_count(%rip), %rcx
    lea hbc_reg_base(%rip), %r10
    lea hbc_reg_size(%rip), %r11
31: test %rcx, %rcx
    jz hbc_reg_bad
    dec %rcx
    cmp %rdi, (%r10,%rcx,8)
    jne 31b
    cmp %rsi, (%r11,%rcx,8)
    jne hbc_reg_bad
    mov hbc_reg_count(%rip), %rdx
    dec %rdx
    mov (%r10,%rdx,8), %r9
    mov %r9, (%r10,%rcx,8)
    mov (%r11,%rdx,8), %r9
    mov %r9, (%r11,%rcx,8)
    mov %rdx, hbc_reg_count(%rip)
    pop %r10
    pop %r9
    pop %rdx
";
const REG_BAD_L: &str = r"# hbc_reg_bad: registry mismatch or unknown/double free (noreturn).
hbc_reg_bad:
    lea .Lregbadmsg(%rip), %rsi
    mov $45, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

";
const REG_ALLOC_W: &str = r"    # harness registry (instrumented build): record (base, bytes) so
    # hbc_free can verify the exact block size, not just call balance.
    # Freed entries are reused; the 16384 CONCURRENT-live limit exists
    # only in this build and reports as OOM.
    mov hbc_reg_count(%rip), %rcx
    cmp $16384, %rcx
    jae hbc_oom
    lea hbc_reg_base(%rip), %r10
    mov %rax, (%r10,%rcx,8)
    mov 32(%rsp), %rdx
    lea hbc_reg_size(%rip), %r10
    mov %rdx, (%r10,%rcx,8)
    incq hbc_reg_count(%rip)
";
const REG_FREE_W: &str = r"    # harness registry: computed 8 + cap*elemsize must equal the recorded
    # allocation size, and the block must be live (double free = absent).
    mov -8(%rdi), %rax
    imul %rsi, %rax
    add $8, %rax
    lea -8(%rdi), %r8
    mov hbc_reg_count(%rip), %rcx
    lea hbc_reg_base(%rip), %r10
    lea hbc_reg_size(%rip), %r11
31: test %rcx, %rcx
    jz hbc_reg_bad
    dec %rcx
    cmp %r8, (%r10,%rcx,8)
    jne 31b
    cmp %rax, (%r11,%rcx,8)
    jne hbc_reg_bad
    mov hbc_reg_count(%rip), %rdx
    dec %rdx
    mov (%r10,%rdx,8), %r9
    mov %r9, (%r10,%rcx,8)
    mov (%r11,%rdx,8), %r9
    mov %r9, (%r11,%rcx,8)
    mov %rdx, hbc_reg_count(%rip)
";
const REG_SFREE_W: &str = r"    # harness registry (string free): computed 16 + cap must equal the
    # recorded allocation size, and the block must be live (double free
    # = absent). Same swap-with-last removal as REG_FREE_W.
    mov -16(%rdi), %rax
    add $16, %rax
    lea -16(%rdi), %r8
    mov hbc_reg_count(%rip), %rcx
    lea hbc_reg_base(%rip), %r10
    lea hbc_reg_size(%rip), %r11
31: test %rcx, %rcx
    jz hbc_reg_bad
    dec %rcx
    cmp %r8, (%r10,%rcx,8)
    jne 31b
    cmp %rax, (%r11,%rcx,8)
    jne hbc_reg_bad
    mov hbc_reg_count(%rip), %rdx
    dec %rdx
    mov (%r10,%rdx,8), %r9
    mov %r9, (%r10,%rcx,8)
    mov (%r11,%rdx,8), %r9
    mov %r9, (%r11,%rcx,8)
    mov %rdx, hbc_reg_count(%rip)
";
const REG_HFREE_W: &str = r"    # harness registry (hash data block, 16-byte header): computed
    # 16 + cap*32 must equal the recorded allocation size, and the block
    # must be live (double free = absent).
    mov -8(%rdi), %rax
    shl $5, %rax
    add $16, %rax
    lea -16(%rdi), %r8
    mov hbc_reg_count(%rip), %rcx
    lea hbc_reg_base(%rip), %r10
    lea hbc_reg_size(%rip), %r11
31: test %rcx, %rcx
    jz hbc_reg_bad
    dec %rcx
    cmp %r8, (%r10,%rcx,8)
    jne 31b
    cmp %rax, (%r11,%rcx,8)
    jne hbc_reg_bad
    mov hbc_reg_count(%rip), %rdx
    dec %rdx
    mov (%r10,%rdx,8), %r9
    mov %r9, (%r10,%rcx,8)
    mov (%r11,%rdx,8), %r9
    mov %r9, (%r11,%rcx,8)
    mov %rdx, hbc_reg_count(%rip)
";
const REG_BAD_W: &str = r"# hbc_reg_bad: registry mismatch or unknown/double free (noreturn).
# Entered via a conditional JUMP: force 16-byte alignment explicitly.
hbc_reg_bad:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lregbadmsg(%rip), %rax
    mov $45, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

";
const REG_DATA: &str = r"hbc_reg_count:  .quad 0
    .bss
    .align 8
hbc_reg_base:   .skip 131072
hbc_reg_size:   .skip 131072
";

const CTOR_HELPERS: &str = r"
# --- Array(n, m) constructor -------------------------------------------
# hbc_arraym: rdi = parent slot address (zeroed by the caller), rsi =
# rows, rdx = cols. Builds n children, each a Dyn-element array of m NIL
# slots (oracle m3), via hbc_asize + hbc_aadd. A negative dimension
# aborts via hbc_asize_neg (Harbour's BASE/1131 dialog hangs headless -
# registered failure mode); OOM aborts via hbc_oom with the entries
# already appended staying a valid shorter array. Target-independent
# logic: all OS contact goes through hbc_alloc/hbc_free inside the
# called helpers.
# State lives on the frame. (Internal helper ABI, audited in iteration
# 18: every helper preserves rbx/rbp/r12-r15 on both targets - the
# Windows hbc_free2/hbc_aadd/hbc_asize were fixed to save what they use;
# generated code holds live state on the stack and in volatile registers
# only. Frame-held state keeps this helper correct even if a future
# helper regresses.)
hbc_arraym:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rdi, -8(%rbp)
    mov %rsi, -16(%rbp)
    mov %rdx, -24(%rbp)
    movq $0, -32(%rbp)
    test %rsi, %rsi
    js hbc_asize_neg
    test %rdx, %rdx
    js hbc_asize_neg
22: mov -32(%rbp), %rax
    cmp -16(%rbp), %rax
    jae 23f
    movq $0, -48(%rbp)
    movq $0, -40(%rbp)
    cmpq $0, -24(%rbp)
    jne 24f
    # Zero columns: the child is a real empty array (oracle az0b: len 0,
    # not NIL), so it owns a header-only block like `{}`.
    mov $8, %edi
    call hbc_alloc
    movq $0, (%rax)
    add $8, %rax
    mov %rax, -48(%rbp)
    jmp 25f
24: lea -48(%rbp), %rdi
    mov -24(%rbp), %rsi
    mov $16, %edx
    xor %ecx, %ecx
    call hbc_asize
25: nop
    mov -8(%rbp), %rdi
    mov $16, %esi
    lea -48(%rbp), %rdx
    call hbc_aadd
    incq -32(%rbp)
    jmp 22b
23: leave
    ret
";

const ARRAY3_HELPER: &str = r"
# --- Array(n, m, k) constructor ------------------------------------------
# hbc_array3m: rdi = parent slot address (zeroed by the caller), rsi =
# dim1, rdx = dim2, rcx = dim3. Builds dim1 children, each a full
# Array(dim2, dim3) built by hbc_arraym (oracle pr7: real child arrays,
# innermost slots NIL). A negative dimension aborts via hbc_asize_neg
# (same registered failure mode as the 2D form). Frame-held state only,
# 16-byte-aligned internal calls on both targets.
hbc_array3m:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rdi, -8(%rbp)
    mov %rsi, -16(%rbp)
    mov %rdx, -24(%rbp)
    mov %rcx, -32(%rbp)
    movq $0, -40(%rbp)
    test %rsi, %rsi
    js hbc_asize_neg
    test %rdx, %rdx
    js hbc_asize_neg
    test %rcx, %rcx
    js hbc_asize_neg
22: mov -40(%rbp), %rax
    cmp -16(%rbp), %rax
    jae 23f
    movq $0, -56(%rbp)
    movq $0, -48(%rbp)
    lea -56(%rbp), %rdi
    mov -24(%rbp), %rsi
    mov -32(%rbp), %rdx
    call hbc_arraym
    # Zero rows: hbc_arraym leaves the slot null, but as a CHILD of the
    # 3D value Harbour materializes a real empty array (oracle pr7b:
    # len(b[1]) = 0 and b[1] = NIL is .F., not a NIL casilla).
    cmpq $0, -56(%rbp)
    jne 25f
    mov $8, %edi
    call hbc_alloc
    movq $0, (%rax)
    add $8, %rax
    mov %rax, -56(%rbp)
25: nop
    mov -8(%rbp), %rdi
    mov $16, %esi
    lea -56(%rbp), %rdx
    call hbc_aadd
    incq -40(%rbp)
    jmp 22b
23: leave
    ret

# hbc_array4m: rdi = parent slot address (zeroed by the caller), rsi =
# dim1, rdx = dim2, rcx = dim3, r8 = dim4. Builds dim1 children, each a
# full Array(dim2, dim3, dim4) built by hbc_array3m (hk103: real child
# arrays, innermost slots NIL). A negative dimension aborts via
# hbc_asize_neg (same registered failure mode). Frame-held state only,
# 16-byte-aligned internal calls on both targets.
hbc_array4m:
    push %rbp
    mov %rsp, %rbp
    sub $80, %rsp
    mov %rdi, -8(%rbp)
    mov %rsi, -16(%rbp)
    mov %rdx, -24(%rbp)
    mov %rcx, -32(%rbp)
    mov %r8, -40(%rbp)
    movq $0, -48(%rbp)
    test %rsi, %rsi
    js hbc_asize_neg
    test %rdx, %rdx
    js hbc_asize_neg
    test %rcx, %rcx
    js hbc_asize_neg
    test %r8, %r8
    js hbc_asize_neg
32: mov -48(%rbp), %rax
    cmp -16(%rbp), %rax
    jae 33f
    movq $0, -64(%rbp)
    movq $0, -56(%rbp)
    lea -64(%rbp), %rdi
    mov -24(%rbp), %rsi
    mov -32(%rbp), %rdx
    mov -40(%rbp), %rcx
    call hbc_array3m
    # Zero rows: materialize a real empty child array (same as the 3D
    # form, oracle pr7b).
    cmpq $0, -64(%rbp)
    jne 35f
    mov $8, %edi
    call hbc_alloc
    movq $0, (%rax)
    add $8, %rax
    mov %rax, -64(%rbp)
35: nop
    mov -8(%rbp), %rdi
    mov $16, %esi
    lea -64(%rbp), %rdx
    call hbc_aadd
    incq -48(%rbp)
    jmp 32b
33: leave
    ret
";

const HASH_HELPERS: &str = r"
# --- hashes (v1): insertion-ordered, string-keyed maps -----------------
# The slot holds {data pointer, live pair count}; null/0 is the empty
# hash (probe h2). Block layout: capacity header (in pairs) at the base,
# then 32-byte entries {keyptr, keylen, tag, payload} from base+8, packed
# over [0, len). Keys are owned copies with an 8-byte length header, so
# hbc_free(keyptr, 1) releases exactly 8 + keylen bytes. Values are Dyn
# {tag, payload} pairs (i64 or NIL in v1). Target-independent logic: all
# OS contact goes through hbc_alloc/hbc_free.

# hbc_hget: rdi = slot address, rsi = key bytes, rdx = key length.
# Returns rax = pointer to the entry's {tag, payload} pair, or 0 on a
# miss. Read-only: a lookup never mutates the hash (probes h3/h3b/h3c).
# Matching honors the CaseMatch flag at -16(data): sensitive is byte
# exact; insensitive folds ASCII letters and returns the LAST
# insertion-order match (hk171).
hbc_hget:
    mov (%rdi), %r10
    test %r10, %r10
    je 41f
    push %rbx
    push %r12
    mov -16(%r10), %rbx
    movq $-1, %r12
    mov 8(%rdi), %r11
    xor %ecx, %ecx
42: cmp %r11, %rcx
    jae 430f
    mov %rcx, %rax
    shl $5, %rax
    add %r10, %rax
    mov 8(%rax), %r8
    cmp %rdx, %r8
    jne 43f
    xor %r9d, %r9d
44: cmp %rdx, %r9
    jae 45f
    mov (%rax), %r8
    movzbl (%r8,%r9), %edi
    movzbl (%rsi,%r9), %r8d
    test %rbx, %rbx
    jnz 440f
    cmp $97, %dil
    jb 441f
    cmp $122, %dil
    ja 441f
    sub $32, %dil
441: cmp $97, %r8b
    jb 440f
    cmp $122, %r8b
    ja 440f
    sub $32, %r8b
440: cmp %r8b, %dil
    jne 43f
    inc %r9
    jmp 44b
43: inc %rcx
    jmp 42b
45: test %rbx, %rbx
    jz 450f
    add $16, %rax
    pop %r12
    pop %rbx
    ret
450: mov %rcx, %r12
    inc %rcx
    jmp 42b
430: test %r12, %r12
    js 431f
    mov %r12, %rax
    shl $5, %rax
    add %r10, %rax
    add $16, %rax
    pop %r12
    pop %rbx
    ret
431: xor %eax, %eax
    pop %r12
    pop %rbx
    ret
41: xor %eax, %eax
    ret

# hbc_hsetdef: rdi = slot address, rsi = key bytes, rdx = key length,
# rcx = pointer to the default's 16-byte Dyn cell {tag, payload},
# r8 = has_def (1 when a default argument was given, 0 otherwise).
# Measured semantics (hk196/hk196b/hk196d): an ABSENT key is always
# added - with the default, or NIL when none was given - and the added
# value is returned. A PRESENT key returns its stored value; it is
# overwritten with the default ONLY when the stored Dyn tag differs
# from the default's tag (hk196b: stored NIL + integer default ->
# overwrite; hk196 same tag -> keep; hk196d: no default -> keep even
# though the stored tag differs from NIL). Returns rax = tag,
# rdx = payload of the resulting value.
hbc_hsetdef:
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r13
    mov %rcx, %r14
    mov %r8, %r15
    call hbc_hget
    test %rax, %rax
    jz 51f
    test %r15, %r15
    jz 52f
    mov (%rax), %rcx
    cmp (%r14), %rcx
    je 52f
    mov %rbx, %rdi
    mov %r12, %rsi
    mov %r13, %rdx
    mov %r14, %rcx
    call hbc_hput
    mov (%r14), %rax
    mov 8(%r14), %rdx
    jmp 53f
52: mov (%rax), %rcx
    mov 8(%rax), %rdx
    mov %rcx, %rax
    jmp 53f
51: mov %rbx, %rdi
    mov %r12, %rsi
    mov %r13, %rdx
    mov %r14, %rcx
    call hbc_hput
    mov (%r14), %rax
    mov 8(%r14), %rdx
53: pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret

# hbc_hcopy: rdi = src slot address, rsi = dst slot address,
# rdx = start (1-based, already normalized by the caller: 0 became 1),
# rcx = count (-1 = to the end). Upserts src[start..start+count) into
# dst through hbc_hput (hk195: new keys append, existing overwrite);
# start > len and count 0 are no-ops, a long count clips at len
# (hk195b/hk195c). Entries are 32 bytes {keyptr, keylen, tag, payload};
# the key bytes start AT keyptr (same convention as hbc_hget/hbc_hmerge).
hbc_hcopy:
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    mov (%rdi), %rbx
    test %rbx, %rbx
    jz 69f
    mov 8(%rdi), %r15
    cmp %r15, %rdx
    ja 69f
    test %rcx, %rcx
    jz 69f
    mov %rsi, %r14
    mov %rdx, %r12
    test %rcx, %rcx
    js 61f
    lea (%rdx,%rcx), %r13
    lea 1(%r15), %rax
    cmp %rax, %r13
    cmova %rax, %r13
    jmp 62f
61: lea 1(%r15), %r13
62: cmp %r13, %r12
    jae 69f
    mov %r12, %rax
    dec %rax
    shl $5, %rax
    add %rbx, %rax
    mov %r14, %rdi
    mov (%rax), %rsi
    mov 8(%rax), %rdx
    lea 16(%rax), %rcx
    call hbc_hput
    inc %r12
    jmp 62b
69: pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret

# hbc_hput: rdi = slot address, rsi = key bytes, rdx = key length,
# rcx = pointer to the 16-byte value {tag, payload}. A found key is
# overwritten in place (probe h8: len unchanged, last value wins; the
# stored key keeps its original casing, hk170). Matching honors the
# hash's CaseMatch flag in the block header (-16(data): 1 sensitive,
# 0 insensitive): sensitive mode matches byte for byte; insensitive
# mode folds ASCII letters and acts on the LAST insertion-order match
# (hk171/hk172). The data block carries a 16-byte header
# [flags @0][capacity @8]; entries start at the data pointer. On a miss
# the key bytes are copied into an owned allocation FIRST, so a failed
# grow leaves the hash untouched (hbc_alloc exits via hbc_oom with
# every temporary still owned by the caller). Growth doubles the
# capacity (first grow from zero capacity: 4 pairs, overflow is OOM),
# copies the flag forward, moves the entries, frees the OLD block
# through hbc_hfreeblock (the key copies moved with the entries) and
# commits {ptr, len} last.
hbc_hput:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $40, %rsp
    mov %rdi, %rbx
    mov %rsi, %r14
    mov %rdx, %r15
    mov %rcx, -48(%rbp)
    mov (%rbx), %r12
    mov 8(%rbx), %r13
    test %r12, %r12
    je 30f
    mov -16(%r12), %rax
    mov %rax, -72(%rbp)
    movq $-1, -80(%rbp)
    xor %ecx, %ecx
31: cmp %r13, %rcx
    jae 300f
    mov %rcx, %rax
    shl $5, %rax
    add %r12, %rax
    mov 8(%rax), %r8
    cmp %r15, %r8
    jne 32f
    mov (%rax), %r8
    xor %r9d, %r9d
33: cmp %r15, %r9
    jae 34f
    movzbl (%r8,%r9), %r10d
    movzbl (%r14,%r9), %r11d
    # case-insensitive mode (flag 0): fold both bytes to uppercase -
    # ASCII letters only, the measured scope of the hk169-hk175 oracles
    cmpq $0, -72(%rbp)
    jne 330f
    cmp $97, %r10b
    jb 331f
    cmp $122, %r10b
    ja 331f
    sub $32, %r10b
331: cmp $97, %r11b
    jb 330f
    cmp $122, %r11b
    ja 330f
    sub $32, %r11b
330: cmp %r11b, %r10b
    jne 32f
    inc %r9
    jmp 33b
32: inc %rcx
    jmp 31b
300: mov -80(%rbp), %rcx
    test %rcx, %rcx
    js 30f
    jmp 340f
34: cmpq $0, -72(%rbp)
    je 341f
    jmp 340f
341: mov %rcx, -80(%rbp)
    inc %rcx
    jmp 31b
340: mov %rcx, %rax
    shl $5, %rax
    add %r12, %rax
    mov -48(%rbp), %rcx
    mov (%rcx), %r8
    mov %r8, 16(%rax)
    mov 8(%rcx), %r8
    mov %r8, 24(%rax)
    jmp 49f
30: mov %r14, %rdi
    mov %r15, %rsi
    call hbc_strcpy
36: mov %rax, %r14
    test %r12, %r12
    je 37f
    mov -8(%r12), %rax
    cmp %rax, %r13
    jb 40f
    test %rax, %rax
    je 37f
    add %rax, %rax
    mov $0x07FFFFFFFFFFFFFF, %rcx
    cmp %rcx, %rax
    ja hbc_oom
    jmp 38f
37: mov $4, %eax
38: mov %rax, -56(%rbp)
    shl $5, %rax
    lea 16(%rax), %rdi
    call hbc_alloc
    mov -56(%rbp), %rcx
    mov %rcx, 8(%rax)
    movq $1, %rcx
    test %r12, %r12
    je 381f
    mov -16(%r12), %rcx
381: mov %rcx, (%rax)
    add $16, %rax
    mov %rax, -64(%rbp)
    mov %rax, %r9
    test %r12, %r12
    je 39f
    xor %ecx, %ecx
46: cmp %r13, %rcx
    jae 47f
    mov %rcx, %rax
    shl $5, %rax
    mov (%r12,%rax), %r8
    mov %r8, (%r9,%rax)
    mov 8(%r12,%rax), %r8
    mov %r8, 8(%r9,%rax)
    mov 16(%r12,%rax), %r8
    mov %r8, 16(%r9,%rax)
    mov 24(%r12,%rax), %r8
    mov %r8, 24(%r9,%rax)
    inc %rcx
    jmp 46b
47: mov %r12, %rdi
    call hbc_hfreeblock
39: mov -64(%rbp), %r12
40: mov %r13, %rax
    shl $5, %rax
    add %r12, %rax
    mov %r14, (%rax)
    mov %r15, 8(%rax)
    mov -48(%rbp), %rcx
    mov (%rcx), %r8
    mov %r8, 16(%rax)
    mov 8(%rcx), %r8
    mov %r8, 24(%rax)
    mov %r12, (%rbx)
    inc %r13
    mov %r13, 8(%rbx)
49: add $40, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_hfree: rdi = block data pointer (non-null), rsi = live pair count.
# Frees each live key copy, then the block (via hbc_hfreeblock, which
# accounts for the 16-byte [flags][capacity] header). Uses the LIVE
# length, never the capacity: after a grow the key copies live in the
# new block's [0, len) entries.
hbc_hfree:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $8, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    xor %r13d, %r13d
20: cmp %r12, %r13
    jae 21f
    mov %r13, %rax
    shl $5, %rax
    mov (%rbx,%rax), %rdi
    call hbc_freestr
    inc %r13
    jmp 20b
21: mov %rbx, %rdi
    call hbc_hfreeblock
    add $8, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_hdel: rdi = hash slot address, rsi = key bytes, rdx = key length.
# Removes the entry whose key matches (probes hk155/hk156; matching
# honors the CaseMatch flag: insensitive mode folds ASCII letters and
# removes the LAST insertion-order match - hk174):
# the hash-owned key copy is freed (hbc_free), the entries above it shift
# down one slot - insertion order is preserved, which is why a deleted
# key re-added later lands at the END (hk156) - and the live count drops
# by one. A missing key is a no-op (hk155); the capacity header is left
# alone. The lookup key is only read, never freed, so rodata and borrowed
# caller keys are both safe. Value payloads own no memory (strings are
# rejected at assignment), so nothing else needs releasing.
hbc_hdel:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $24, %rsp
    mov %rdi, %r15
    mov (%r15), %r12
    mov 8(%r15), %r13
    movq $1, %rax
    test %r12, %r12
    je 600f
    mov -16(%r12), %rax
600: mov %rax, -48(%rbp)
    movq $-1, -56(%rbp)
    xor %r14d, %r14d
60: cmp %r13, %r14
    jae 610f
    mov %r14, %rax
    shl $5, %rax
    lea (%r12,%rax), %rbx
    cmp 8(%rbx), %rdx
    jne 62f
    mov (%rbx), %rcx
    xor %r9d, %r9d
63: cmp %rdx, %r9
    jae 64f
    movzbl (%rcx,%r9), %r10d
    movzbl (%rsi,%r9), %r11d
    cmpq $0, -48(%rbp)
    jne 630f
    cmp $97, %r10b
    jb 631f
    cmp $122, %r10b
    ja 631f
    sub $32, %r10b
631: cmp $97, %r11b
    jb 630f
    cmp $122, %r11b
    ja 630f
    sub $32, %r11b
630: cmp %r11b, %r10b
    jne 62f
    inc %r9
    jmp 63b
62: inc %r14
    jmp 60b
610: mov -56(%rbp), %r14
    test %r14, %r14
    js 61f
    mov %r14, %rax
    shl $5, %rax
    lea (%r12,%rax), %rbx
    jmp 620f
64: cmpq $0, -48(%rbp)
    je 640f
    jmp 620f
640: mov %r14, -56(%rbp)
    inc %r14
    jmp 60b
620: mov (%rbx), %rdi
    call hbc_freestr
65: lea 1(%r14), %rax
    cmp %r13, %rax
    jae 66f
    mov %r14, %rax
    shl $5, %rax
    lea (%r12,%rax), %rcx
    lea 32(%rcx), %rdx
    mov (%rdx), %r8
    mov %r8, (%rcx)
    mov 8(%rdx), %r8
    mov %r8, 8(%rcx)
    mov 16(%rdx), %r8
    mov %r8, 16(%rcx)
    mov 24(%rdx), %r8
    mov %r8, 24(%rcx)
    inc %r14
    jmp 65b
66: dec %r13
    mov %r13, 8(%r15)
61: add $24, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_hhaskey: rdi = hash slot address, rsi = key bytes, rdx = key
# length. Returns rax = 1 when an entry's key matches byte for byte
# (case-sensitive, full length - probe hk157), 0 otherwise; an empty key is
# ordinary key. Leaf: caller-saved registers only, no allocation, the
# hash and the lookup key are only read.
hbc_hhaskey:
    push %rbx
    push %r12
    mov (%rdi), %r8
    mov 8(%rdi), %r9
    movq $1, %rbx
    test %r8, %r8
    je 700f
    mov -16(%r8), %rbx
700: movq $-1, %r12
    xor %ecx, %ecx
70: cmp %r9, %rcx
    jae 710f
    mov %rcx, %rax
    shl $5, %rax
    cmp 8(%r8,%rax), %rdx
    jne 72f
    mov (%r8,%rax), %r11
    xor %eax, %eax
73: cmp %rdx, %rax
    jae 74f
    movzbl (%r11,%rax), %edi
    movzbl (%rsi,%rax), %r10d
    test %rbx, %rbx
    jnz 730f
    cmp $97, %dil
    jb 731f
    cmp $122, %dil
    ja 731f
    sub $32, %dil
731: cmp $97, %r10b
    jb 730f
    cmp $122, %r10b
    ja 730f
    sub $32, %r10b
730: cmp %r10b, %dil
    jne 72f
    inc %rax
    jmp 73b
74: test %rbx, %rbx
    jz 740f
    mov $1, %eax
    pop %r12
    pop %rbx
    ret
740: mov %rcx, %r12
    inc %rcx
    jmp 70b
72: inc %rcx
    jmp 70b
710: test %r12, %r12
    js 711f
    mov $1, %eax
    pop %r12
    pop %rbx
    ret
711: xor %eax, %eax
    pop %r12
    pop %rbx
    ret

# hbc_hpos: rdi = hash slot address, rsi = key bytes, rdx = key
# length. Returns rax = the entry's 1-based position among the LIVE
# entries in insertion order when the key matches byte for byte
# (case-sensitive, full length - probe hk162), 0 when absent; an empty
# key is an ordinary key. Positions COMPACT after a delete (hk163).
# Leaf: caller-saved registers only, no allocation, the hash and the
# lookup key are only read.
hbc_hpos:
    push %rbx
    push %r12
    mov (%rdi), %r8
    mov 8(%rdi), %r9
    movq $1, %rbx
    test %r8, %r8
    je 700f
    mov -16(%r8), %rbx
700: movq $-1, %r12
    xor %ecx, %ecx
70: cmp %r9, %rcx
    jae 710f
    mov %rcx, %rax
    shl $5, %rax
    cmp 8(%r8,%rax), %rdx
    jne 72f
    mov (%r8,%rax), %r11
    xor %eax, %eax
73: cmp %rdx, %rax
    jae 74f
    movzbl (%r11,%rax), %edi
    movzbl (%rsi,%rax), %r10d
    test %rbx, %rbx
    jnz 730f
    cmp $97, %dil
    jb 731f
    cmp $122, %dil
    ja 731f
    sub $32, %dil
731: cmp $97, %r10b
    jb 730f
    cmp $122, %r10b
    ja 730f
    sub $32, %r10b
730: cmp %r10b, %dil
    jne 72f
    inc %rax
    jmp 73b
74: test %rbx, %rbx
    jz 740f
    lea 1(%rcx), %rax
    pop %r12
    pop %rbx
    ret
740: mov %rcx, %r12
    inc %rcx
    jmp 70b
72: inc %rcx
    jmp 70b
710: test %r12, %r12
    js 711f
    lea 1(%r12), %rax
    pop %r12
    pop %rbx
    ret
711: xor %eax, %eax
    pop %r12
    pop %rbx
    ret

# hbc_hmerge: rdi = dst hash slot address, rsi = src hash slot
# address. Every src entry, in insertion order, is upserted into dst
# through hbc_hput: key and value are COPIED (the source is only read
# and keeps owning its copies - hk165); an overlapping key is
# overwritten in place - the source WINS (hk164) - and new keys append
# at the end; an empty source is a no-op. Frame-based: hbc_hput
# allocates.
hbc_hmerge:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $8, %rsp
    mov %rdi, %r12
    mov (%rsi), %r13
    mov 8(%rsi), %r14
    xor %r15d, %r15d
50: cmp %r14, %r15
    jae 51f
    mov %r15, %rax
    shl $5, %rax
    lea (%r13,%rax), %rbx
    mov %r12, %rdi
    mov (%rbx), %rsi
    mov 8(%rbx), %rdx
    lea 16(%rbx), %rcx
    call hbc_hput
    inc %r15
    jmp 50b
51: add $8, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_hclone: rdi = hash slot address. Returns rax = data pointer of
# a NEW block whose entries are copies - every key is re-copied
# through hbc_hput and every value cell copied (hk166: the clone is
# independent of the original in both directions for string keys and
# scalar int/NIL values, the only value types of this increment),
# rdx = entry count; insertion order and NIL values are preserved
# (hk167). The clone inherits the CaseMatch flag (hk173), even for an
# empty flagged hash (hk176: a source WITH a data block clones to a
# header-only block; a source with NO block at all keeps cloning to
# the empty slot {0, 0} of hk167). The source is only read.
# Frame-based: hbc_alloc/hbc_hput allocate. A mid-copy hbc_oom exits
# the process with every temporary still owned by this helper (no
# unwinding in this PoC - documented).
hbc_hclone:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $24, %rsp
    mov (%rdi), %r13
    mov 8(%rdi), %r14
    movq $0, -56(%rbp)
    movq $0, -48(%rbp)
    # the clone inherits the CaseMatch flag (hk173), even with zero
    # entries (hk176): a source WITH a data block clones to a
    # header-only block (capacity 0) carrying the flag; a source with
    # no block at all (never assigned nor flagged) stays {0, 0}.
    test %r13, %r13
    je 52f
    mov $16, %edi
    call hbc_alloc
    mov -16(%r13), %rcx
    mov %rcx, (%rax)
    movq $0, 8(%rax)
    add $16, %rax
    mov %rax, -56(%rbp)
52: xor %r15d, %r15d
50: cmp %r14, %r15
    jae 51f
    mov %r15, %rax
    shl $5, %rax
    lea (%r13,%rax), %rbx
    lea -56(%rbp), %rdi
    mov (%rbx), %rsi
    mov 8(%rbx), %rdx
    lea 16(%rbx), %rcx
    call hbc_hput
    inc %r15
    jmp 50b
51: mov -56(%rbp), %rax
    mov -48(%rbp), %rdx
    add $24, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_hkeys: rdi = hash slot address. Returns rax = data pointer of a
# NEW array block holding one Dyn {tag 2, payload} element per live
# entry in insertion order (probes hk4/hk5/hk6), rdx = element count.
# Each key's bytes are COPIED into an own allocation with an 8-byte
# length header - the same layout as a hash key copy - so the returned
# array owns its strings independently of the hash (a later hbc_hfree
# of the hash cannot dangle them) and hbc_free(payload, 1) releases
# exactly one. Overflow of 8 + count*16 is OOM (the count is guarded
# before the shift), matching hbc_hput's rule; a mid-copy hbc_oom
# exits the process with every temporary still owned by this helper.
hbc_hkeys:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $8, %rsp
    mov (%rdi), %r12
    mov 8(%rdi), %r13
    mov $0x0FFFFFFFFFFFFFFF, %rax
    cmp %rax, %r13
    ja hbc_oom
    mov %r13, %rdi
    shl $4, %rdi
    add $8, %rdi
    call hbc_alloc
    mov %rax, %rbx
    mov %r13, (%rbx)
    xor %r14d, %r14d
50: cmp %r13, %r14
    jae 51f
    mov %r14, %rax
    shl $5, %rax
    lea (%r12,%rax), %r15
    mov (%r15), %rdi
    mov 8(%r15), %rsi
    call hbc_strcpy
    mov %r14, %rdx
    shl $4, %rdx
    lea 8(%rbx,%rdx), %r10
    mov %rax, 8(%r10)
    movq $2, (%r10)
53: inc %r14
    jmp 50b
51: lea 8(%rbx), %rax
    mov %r13, %rdx
    add $8, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_hvalues: rdi = hash slot address. Returns rax = data pointer of a
# NEW array block holding one Dyn {tag, payload} element per live entry
# in insertion order (oracles hk153/hk154, core hb_HValues), rdx =
# element count. Hash values are tagged int/NIL scalars in this dialect
# (string values are rejected at assignment), so the 16-byte cell copy
# is exact - there is no deep copy to skip. The caller owns the array
# (release with hbc_free(ptr, 16)); the hash is only borrowed. Same
# overflow rule as hbc_hkeys.
hbc_hvalues:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    sub $16, %rsp
    mov (%rdi), %r12
    mov 8(%rdi), %r13
    mov $0x0FFFFFFFFFFFFFFF, %rax
    cmp %rax, %r13
    ja hbc_oom
    mov %r13, %rdi
    shl $4, %rdi
    add $8, %rdi
    call hbc_alloc
    mov %rax, %rbx
    mov %r13, (%rbx)
    xor %r14d, %r14d
50: cmp %r13, %r14
    jae 51f
    mov %r14, %rax
    shl $5, %rax
    lea (%r12,%rax), %rcx
    mov 16(%rcx), %rax
    mov 24(%rcx), %rdx
    mov %r14, %r8
    shl $4, %r8
    lea 8(%rbx,%r8), %r9
    mov %rax, (%r9)
    mov %rdx, 8(%r9)
    inc %r14
    jmp 50b
51: lea 8(%rbx), %rax
    mov %r13, %rdx
    add $16, %rsp
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_hcasematch: rdi = hash slot address. Returns rax = the hash's
# CaseMatch flag: 1 = case-sensitive byte-exact key matching (the
# default, hk169), 0 = case-insensitive. An untouched empty hash
# (data pointer 0) reports the default 1. Leaf: the slot is only read.
hbc_hcasematch:
    mov (%rdi), %rax
    test %rax, %rax
    je 41f
    mov -16(%rax), %rax
    ret
41: mov $1, %eax
    ret

# hbc_hsetcasematch: rdi = hash slot address, rsi = flag (1 sensitive,
# 0 insensitive). The flag lives in the data block's 16-byte header at
# -16(data). A hash with no block yet (empty, data pointer 0) gets a
# header-only block (capacity 0) so the flag survives until the first
# insert; hbc_hput's grow path copies the flag forward and
# hbc_hfreeblock releases the block. Frame-based: hbc_alloc allocates.
hbc_hsetcasematch:
    mov (%rdi), %rax
    test %rax, %rax
    jne 41f
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    mov %rdi, %rbx
    mov %rsi, %r12
    mov $16, %edi
    call hbc_alloc
    mov %r12, (%rax)
    movq $0, 8(%rax)
    add $16, %rax
    mov %rax, (%rbx)
    pop %r12
    pop %rbx
    pop %rbp
    ret
41: mov %rsi, -16(%rax)
    ret

# hbc_hscan: rdi = hash slot address, rsi = value tag (0 = i64,
# 1 = NIL), rdx = value payload, rcx = start (1-based; 0 scans from
# the first live entry, negative finds nothing). Returns rax = the
# 1-based insertion-order position of the first entry whose stored
# {tag, payload} equals the value, 0 when absent (hk178-hk180: first
# match wins, the start is inclusive, a stored NIL matches a NIL
# argument; hk179: start 0/negative/out-of-range and empty-hash
# edges). Leaf: caller-saved registers only, no allocation, the hash
# is only read.
hbc_hscan:
    test %rcx, %rcx
    js 853f
    je 850f
    dec %rcx
850: mov (%rdi), %r8
    test %r8, %r8
    je 853f
    mov 8(%rdi), %r9
851: cmp %r9, %rcx
    jae 853f
    mov %rcx, %rax
    shl $5, %rax
    add %r8, %rax
    cmp 16(%rax), %rsi
    jne 852f
    cmp 24(%rax), %rdx
    jne 852f
    lea 1(%rcx), %rax
    ret
852: inc %rcx
    jmp 851b
853: xor %eax, %eax
    ret

# hbc_hkeyat: rdi = hash slot address, rsi = 1-based position.
# Returns rax = the entry's key bytes and rdx = its length, or
# rax = 0 when the position is out of range - 0, past the end or
# negative all take the caller's registered clean bound-error exit
# (Harbour's BASE/1187 dialog hangs headless, hk184: the
# dialogo-sin-oraculo family). Positions are live and compact after
# a delete (hk186). Leaf: caller-saved registers only, no
# allocation, the hash is only read.
hbc_hkeyat:
    mov (%rdi), %r8
    test %r8, %r8
    je 854f
    mov 8(%rdi), %r9
    test %rsi, %rsi
    jle 854f
    cmp %r9, %rsi
    ja 854f
    lea -1(%rsi), %rax
    shl $5, %rax
    add %r8, %rax
    mov 8(%rax), %rdx
    mov (%rax), %rax
    ret
854: xor %eax, %eax
    ret

# hbc_hvalueat: rdi = hash slot address, rsi = 1-based position.
# Returns rax = a pointer to the entry's {tag, payload} pair, or
# rax = 0 out of range (same registered bound-error family, hk185).
# Leaf: caller-saved registers only, no allocation, the hash is only
# read.
hbc_hvalueat:
    mov (%rdi), %r8
    test %r8, %r8
    je 855f
    mov 8(%rdi), %r9
    test %rsi, %rsi
    jle 855f
    cmp %r9, %rsi
    ja 855f
    lea -1(%rsi), %rax
    shl $5, %rax
    add %r8, %rax
    add $16, %rax
    ret
855: xor %eax, %eax
    ret

# hbc_hdelat: rdi = hash slot address, rsi = 1-based position.
# Removes the entry AT that position (hk187: positions compact after
# the delete and insertion order is preserved; hk190: deleting the
# only entry empties the hash): the hash-owned key copy is freed, the
# entries above shift down one slot and the live count drops by one.
# Returns rax = 1 on a delete, 0 when the position is out of range -
# 0, past the end or negative all take the caller's registered clean
# bound-error exit (Harbour's BASE/1187 dialog hangs headless,
# hk189: the dialogo-sin-oraculo family). The CaseMatch flag is
# irrelevant: matching is positional. The capacity header is left
# alone. Frame-based: hbc_free.
hbc_hdelat:
    mov (%rdi), %r8
    test %r8, %r8
    je 856f
    mov 8(%rdi), %r9
    test %rsi, %rsi
    jle 856f
    cmp %r9, %rsi
    ja 856f
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $8, %rsp
    mov %rdi, %rbx
    mov %r8, %r12
    lea -1(%rsi), %r13
    mov %r13, %rax
    shl $5, %rax
    mov (%r8,%rax), %rdi
    call hbc_freestr
    mov 8(%rbx), %r9
857: lea 1(%r13), %rax
    cmp %r9, %rax
    jae 858f
    mov %r13, %rax
    shl $5, %rax
    lea (%r12,%rax), %rcx
    lea 32(%rcx), %rdx
    mov (%rdx), %r8
    mov %r8, (%rcx)
    mov 8(%rdx), %r8
    mov %r8, 8(%rcx)
    mov 16(%rdx), %r8
    mov %r8, 16(%rcx)
    mov 24(%rdx), %r8
    mov %r8, 24(%rcx)
    inc %r13
    jmp 857b
858: dec %r9
    mov %r9, 8(%rbx)
    add $8, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    mov $1, %eax
    ret
856: xor %eax, %eax
    ret

# hbc_hfill: rdi = hash slot address, rsi = value tag, rdx = value
# payload. Writes the {tag, payload} pair into EVERY entry, keeping
# keys, positions and count (hk192: 7 over everything including a
# stored NIL; NIL over everything; an empty hash is a no-op). Leaf:
# caller-saved registers only, no allocation, values own no memory.
hbc_hfill:
    mov (%rdi), %r8
    test %r8, %r8
    je 859f
    mov 8(%rdi), %r9
    xor %ecx, %ecx
860: cmp %r9, %rcx
    jae 859f
    mov %rcx, %rax
    shl $5, %rax
    add %r8, %rax
    mov %rsi, 16(%rax)
    mov %rdx, 24(%rax)
    inc %rcx
    jmp 860b
859: ret

# hbc_hclear: rdi = hash slot address. Empties the hash: every
# hash-owned key copy is freed, the whole data block is released
# through hbc_hfreeblock and the slot goes back to (0, 0), so the
# hash is reusable and the CaseMatch flag is the default again on
# the next write (hk191/hk193: sensitive after a clear; clearing an
# empty or already-clear hash is a no-op). Frame-based: hbc_free and
# hbc_hfreeblock.
hbc_hclear:
    mov (%rdi), %r8
    test %r8, %r8
    je 861f
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $8, %rsp
    mov %rdi, %rbx
    mov %r8, %r12
    xor %r13d, %r13d
862: cmp 8(%rbx), %r13
    jae 863f
    mov %r13, %rax
    shl $5, %rax
    add %r12, %rax
    mov (%rax), %rdi
    call hbc_freestr
    inc %r13
    jmp 862b
863: mov %r12, %rdi
    call hbc_hfreeblock
    movq $0, (%rbx)
    movq $0, 8(%rbx)
    add $8, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
861: ret

# hbc_trim: rdi/ rsi bytes/len, edx mode1=left2=right3=both.
# Left whitespace: HT/LF/CR/space only (hk391/392, HB_ISSPACE).
# Right whitespace: space only. Always copy through owned-string path.
hbc_trim:
    test $2, %edx
    jz .Ltrim_left
.Ltrim_right:
    test %rsi, %rsi
    jz .Ltrim_copy
    cmpb $32, -1(%rdi,%rsi)
    jne .Ltrim_left
    dec %rsi
    jmp .Ltrim_right
.Ltrim_left:
    test $1, %edx
    jz .Ltrim_copy
.Ltrim_again:
    test %rsi, %rsi
    jz .Ltrim_copy
    movzbl (%rdi), %eax
    cmp $32, %eax
    je .Ltrim_drop
    cmp $9, %eax
    je .Ltrim_drop
    cmp $10, %eax
    je .Ltrim_drop
    cmp $13, %eax
    jne .Ltrim_copy
.Ltrim_drop:
    inc %rdi
    dec %rsi
    jmp .Ltrim_again
.Ltrim_copy:
    jmp hbc_strcpy

# hbc_asc: borrowed rdi/length rsi -> unsigned first byte, empty ->0.
# Byte-codepage only (src/rtl/chrasc.c). Never dereference empty input.
hbc_asc:
    xor %eax, %eax
    test %rsi, %rsi
    jz .Lasc_done
    movzbl (%rdi), %eax
.Lasc_done:
    ret

# hbc_chr: rdi = signed integer -> owned one-byte string rax/rdx.
# Byte-codepage semantics (hk387/hk389): n &255, NUL is still len1.
# Reuse hbc_strcpy/header/free protocol; no new string representation.
hbc_chr:
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp
    mov %dil, -8(%rbp)
    lea -8(%rbp), %rdi
    mov $1, %esi
    call hbc_strcpy
    leave
    ret

# hbc_strcpy: rdi = source bytes, rsi = length. Returns rax = pointer to
# the bytes of a NEW owned allocation with a 16-byte header: capacity at
# -16(%rax), length at -8(%rax) (fresh copies have cap == len; only
# hbc_strgrow leaves spare capacity). Freed with hbc_freestr.
# Used when a tag-2 array element is read out of its array: the reader
# owns an independent copy, so freeing or moving the array afterwards
# cannot dangle it.
hbc_strcpy:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $8, %rsp
    mov %rdi, %r13
    mov %rsi, %r12
    # Bounded cache of logically FREE short-string blocks only.
    # Eight slots indexed by capacity mod8, exact capacity match.
    # Remove before reuse: every live allocation still has one owner.
    cmp $256, %rsi
    ja .Lstr_cache_miss
    mov %rsi, %rcx
    and $7, %ecx
    lea hbc_str_cache(%rip), %r10
    mov (%r10,%rcx,8), %rax
    test %rax, %rax
    jz .Lstr_cache_miss
    cmp %rsi, (%rax)
    jne .Lstr_cache_miss
    movq $0, (%r10,%rcx,8)
    add $16, %rsi
@REG_CACHE_ALLOC@    incq hbc_mem_allocs(%rip)
    jmp .Lstr_cache_got
.Lstr_cache_miss:
    lea 16(%rsi), %rdi
    call hbc_alloc
.Lstr_cache_got:
    mov %rax, %rbx
    mov %r12, (%rbx)
    mov %r12, 8(%rbx)
    xor %ecx, %ecx
70: cmp %r12, %rcx
    jae 71f
    movzbl (%r13,%rcx), %r9d
    mov %r9b, 16(%rbx,%rcx)
    inc %rcx
    jmp 70b
71: lea 16(%rbx), %rax
    mov %r12, %rdx
    add $8, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_strcat: rdi=p1, rsi=len1, rdx=p2, rcx=len2 -> rax/rdx fresh owned
# string (length at -8(%rax), like hbc_strcpy). Copies both operands;
# neither is consumed. Platform-neutral: only hbc_alloc + register work.
hbc_strcat:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    mov %rdi, %r12
    mov %rsi, %r13
    mov %rdx, %r14
    mov %rcx, %rbx
    lea 16(%r13,%rbx), %rdi
    call hbc_alloc
    mov %r13, %r10
    add %rbx, %r10
    mov %r10, (%rax)
    mov %r10, 8(%rax)
    xor %ecx, %ecx
70: cmp %r13, %rcx
    jae 71f
    movzbl (%r12,%rcx), %r9d
    mov %r9b, 16(%rax,%rcx)
    inc %rcx
    jmp 70b
71: lea 16(%rax,%r13), %r11
    xor %ecx, %ecx
72: cmp %rbx, %rcx
    jae 73f
    movzbl (%r14,%rcx), %r9d
    mov %r9b, (%r11,%rcx)
    inc %rcx
    jmp 72b
73: mov %r13, %rdx
    add %rbx, %rdx
    lea 16(%rax), %rax
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_strgrow: rdi = owned string data pointer (non-null), rsi = bytes to
# append, rdx = append length. Appends IN PLACE when the capacity header
# allows; otherwise reallocates with doubling (the Harbour pattern:
# src/vm/itemapi.c hb_itemReSizeString reserves nSize+1 plus nSize extra,
# measured amortized O(1) there). Returns rax = data pointer (possibly a
# new one), rdx = new length. On reallocation the OLD mapping is released
# here; the caller stores rax/rdx and frees nothing itself. Codegen picks
# this path only when the appended bytes cannot alias the destination
# buffer (expr_mentions guard at the `s := s + rhs` site).
hbc_strgrow:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $24, %rsp
    mov %rdi, %rbx
    mov %rsi, %r13
    mov %rdx, %r14
    mov -8(%rbx), %r12
    lea (%r12,%r14), %rax
    mov %rax, (%rsp)
    cmp -16(%rbx), %rax
    ja 80f
    lea (%rbx,%r12), %r11
    xor %ecx, %ecx
70: cmp %r14, %rcx
    jae 71f
    movzbl (%r13,%rcx), %r9d
    mov %r9b, (%r11,%rcx)
    inc %rcx
    jmp 70b
71: mov (%rsp), %rdx
    mov %rdx, -8(%rbx)
    mov %rbx, %rax
    jmp 90f
80: mov -16(%rbx), %rdi
    add %rdi, %rdi
    cmp %rax, %rdi
    jae 81f
    mov %rax, %rdi
81: mov %rdi, 8(%rsp)
    lea 16(%rdi), %rdi
    call hbc_alloc
    mov %rax, %r15
    mov 8(%rsp), %rcx
    mov %rcx, (%r15)
    mov (%rsp), %rcx
    mov %rcx, 8(%r15)
    xor %ecx, %ecx
82: cmp %r12, %rcx
    jae 83f
    movzbl (%rbx,%rcx), %r9d
    mov %r9b, 16(%r15,%rcx)
    inc %rcx
    jmp 82b
83: lea 16(%r15,%r12), %r11
    xor %ecx, %ecx
84: cmp %r14, %rcx
    jae 85f
    movzbl (%r13,%rcx), %r9d
    mov %r9b, (%r11,%rcx)
    inc %rcx
    jmp 84b
85: mov %rbx, %rdi
    call hbc_freestr
    lea 16(%r15), %rax
    mov (%rsp), %rdx
90: add $24, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_sfree: rdi = array data pointer (non-null), rsi = live element
# count. Frees each tag-2 string payload, then the block. Uses the
# LIVE count, never capacity, like hbc_hfree; a non-2 tag is skipped,
# so a NIL casilla would be harmless.
hbc_sfree:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $8, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    xor %r13d, %r13d
60: cmp %r12, %r13
    jae 61f
    mov %r13, %rax
    shl $4, %rax
    cmpq $2, (%rbx,%rax)
    jne 62f
    mov 8(%rbx,%rax), %rdi
    call hbc_freestr
62: inc %r13
    jmp 60b
61: mov %rbx, %rdi
    mov $16, %esi
    call hbc_free
    add $8, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
";

fn emit_asm(funcs: &[Func], sigs: &[Sig], target: Target, instrument: bool) -> String {
    let mut out = String::new();
    out.push_str("# generated by hbc (PoC: Harbour syntax -> x86-64 assembly)\n");
    match target {
        Target::Linux => out.push_str("# target: linux - no libc, I/O via own syscall helpers at the end\n"),
        Target::Windows => out.push_str("# target: windows - no CRT, I/O via own helpers calling kernel32 at the end\n"),
    }
    match target {
        Target::Linux => {
            out.push_str("    .text\n    .globl _start\n_start:\n");
            out.push_str("    call hbc_fn_main\n    call hbc_str_cache_flush\n");
            out.push_str("    mov $60, %eax\n    xor %edi, %edi\n    syscall\n\n");
        }
        Target::Windows => {
            // Process entry: no CRT. rsp % 16 == 8 on entry (loader calls
            // the entry point); push rbp + sub 48 realigns to 16 and leaves
            // 32 bytes of shadow space for the Win64 calls.
            out.push_str("    .text\n    .globl _start\n_start:\n");
            out.push_str("    push %rbp\n    mov %rsp, %rbp\n");
            // The Win64 loader does not guarantee one specific rsp % 16 at
            // the entry point; align explicitly instead of assuming.
            out.push_str("    and $-16, %rsp\n    sub $48, %rsp\n");
            out.push_str("    call hbc_fn_main\n    call hbc_str_cache_flush\n");
            out.push_str("    xor %ecx, %ecx\n");
            out.push_str("    call ExitProcess\n\n");
        }
    }

    F64_CONSTS.with(|c| c.borrow_mut().clear());
    let mut strs: Vec<String> = Vec::new();
    for f in funcs {
        cg_func(f, sigs, &mut strs, &mut out, target, None);
    }
    // `@`-variants (hk216 family): one per (callee, mask) actually used;
    // the checker validated every one of these calls.
    for (vname, mask) in collect_byref_variants(funcs) {
        let f = funcs.iter().find(|f| f.name == *vname).expect("checked");
        cg_func(f, sigs, &mut strs, &mut out, target, Some(&mask));
    }

    // Runtime helpers (ours, hand-written; syscall-only on linux, three
    // kernel32 calls on windows).
    match target {
        Target::Windows => {
            out.push_str(WIN_HELPERS);
            out.push_str(F64_HELPER);
            out.push_str(CTOR_HELPERS);
            out.push_str(ARRAY3_HELPER);
            out.push_str(HASH_HELPERS);
            out.push_str("\n    .section .rdata,\"r\"\n");
            emit_strings(&mut out, &strs);
    emit_f64_consts(&mut out);
            // Allocation registry only in instrumented builds (--instrument).
            out = out.replace("@REG_CACHE_ALLOC@", if instrument { REG_ALLOC_L } else { "" });
            out = out.replace("@REG_ALLOC_W@", if instrument { REG_ALLOC_W } else { "" });
            out = out.replace("@REG_FREE_W@", if instrument { REG_FREE_W } else { "" });
            out = out.replace("@REG_SFREE_W@", if instrument { REG_SFREE_W } else { "" });
            out = out.replace("@REG_HFREE_W@", if instrument { REG_HFREE_W } else { "" });
            out = out.replace("@REG_BAD_W@", if instrument { REG_BAD_W } else { "" });
            out = out.replace("@REG_DATA@", if instrument { REG_DATA } else { "" });
            return finalize_trace(out, target);
        }
        Target::Linux => {}
    }
    out.push_str(r#"
# hbc_print_str: %rax = ptr, %rdx = len. Writes the raw bytes, no newline:
# Harbour `?` emits the newline BEFORE the items (probes b51-b57).
hbc_print_str:
    mov %rax, %rsi
    mov $1, %eax
    mov $1, %edi
    syscall
    ret

# hbc_print_nl / hbc_print_sep: the `?` leading newline / item separator.
hbc_print_nl:
    lea .Lnl(%rip), %rax
    mov $1, %edx
    jmp hbc_print_str
hbc_print_sep:
    lea .Lpad20(%rip), %rax
    mov $1, %edx
    jmp hbc_print_str

# hbc_str_eq: %rax = lhs ptr, %rdx = lhs len, %rcx = rhs ptr, %r8 = rhs len.
# Returns %rax = 1 when equal, 0 otherwise. Harbour default (SET EXACT
# OFF) `=`: compare over the length of the RIGHT operand, left read
# NUL-padded - "abcd" = "abc" is true, "abc" = "abcd" false, anything
# = "" true (probe b23). Harbour's exact `==` is not in this grammar.
# Leaf routine: no calls, only volatile registers.
hbc_str_eq:
    xor %r9, %r9
91:
    cmp %r8, %r9
    jae 92f
    movzbl (%rcx,%r9), %r10d
    cmp %rdx, %r9
    jae 94f
    movzbl (%rax,%r9), %r11d
    jmp 93f
94:
    xor %r11d, %r11d
93:
    cmp %r11b, %r10b
    jne 90f
    inc %r9
    jmp 91b
92:
    mov $1, %eax
    ret
90:
    xor %eax, %eax
    ret

# hbc_str_xeq: same inputs as hbc_str_eq. Returns %rax = 1 only when the
# lengths match AND every byte matches - Harbour's exact `==` (hk124:
# "a"=="a" .T., "a"=="a " .F., "a "=="a" .F.). Leaf routine: no calls,
# only volatile registers.
hbc_str_xeq:
    cmp %r8, %rdx
    jne 90f
    xor %r9, %r9
91:
    cmp %r8, %r9
    jae 92f
    movzbl (%rax,%r9), %r10d
    movzbl (%rcx,%r9), %r11d
    cmp %r11b, %r10b
    jne 90f
    inc %r9
    jmp 91b
92:
    mov $1, %eax
    ret
90:
    xor %eax, %eax
    ret

# hbc_str_cmp: same inputs as hbc_str_eq. Returns %rax = -1, 0 or 1.
# Harbour default (SET EXACT OFF) ordering: compare over the length of
# the RIGHT operand only; the left operand is read NUL-padded past its
# end, so "abc" < "abcd" is true but "abcd" > "abc" is false and
# "abcd" <= "abc" is true (xBase asymmetric prefix rule, probe b22).
# No collation, no Unicode awareness. Leaf: no calls, volatile regs.
hbc_str_cmp:
    xor %r9d, %r9d
95:
    cmp %r8, %r9
    jae 96f
    movzbl (%rcx,%r9), %r10d
    cmp %rdx, %r9
    jae 94f
    movzbl (%rax,%r9), %r11d
    jmp 93f
94:
    xor %r11d, %r11d
93:
    cmp %r11b, %r10b
    jb 98f
    ja 97f
    inc %r9
    jmp 95b
96:
    xor %eax, %eax
    ret
98:
    mov $1, %eax
    ret
97:
    mov $-1, %rax
    ret

# hbc_print_i64: %rax = signed value. Prints decimal + newline.
hbc_print_i64:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    xor %r9d, %r9d
    test %rax, %rax
    jns 1f
    mov $1, %r9d
    neg %rax
1:
    lea -1(%rbp), %rsi
    mov $10, %r8
2:
    xor %edx, %edx
    div %r8
    add $48, %dl
    mov %dl, (%rsi)
    dec %rsi
    test %rax, %rax
    jnz 2b
    test %r9d, %r9d
    jz 3f
    movb $45, (%rsi)
    dec %rsi
3:
    # Harbour `?` integer field (probes q1/q5/q6): positives right-align in
    # max(10, digits+1); negatives in 10 when they fit, 20 otherwise.
    lea 1(%rsi), %r9
    lea -1(%rbp), %r10
    sub %r9, %r10
    inc %r10
    cmpb $45, (%r9)
    je 5f
    lea 1(%r10), %rcx
    mov $10, %rax
    cmp %rax, %rcx
    cmovae %rcx, %rax
    jmp 6f
5:
    mov $10, %rax
    cmp %rax, %r10
    jbe 6f
    mov $20, %rax
6:
    sub %r10, %rax
    jle 7f
    mov %rax, %rdx
    lea .Lpad20(%rip), %rsi
    mov $1, %eax
    mov $1, %edi
    syscall
7:
    mov %r9, %rsi
    mov %r10, %rdx
    mov $1, %eax
    mov $1, %edi
    syscall
    leave
    ret

# hbc_print_i64c: computed (runtime) i64 field (hk327/hk328): 10 within
# -999999999..9999999999, else 20. Both threshold magnitudes are exactly
# 10 digits, so the rule is one digit-count test for either sign.
hbc_print_i64c:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    xor %r9d, %r9d
    test %rax, %rax
    jns 1f
    mov $1, %r9d
    neg %rax
1:
    lea -1(%rbp), %rsi
    mov $10, %r8
2:
    xor %edx, %edx
    div %r8
    add $48, %dl
    mov %dl, (%rsi)
    dec %rsi
    test %rax, %rax
    jnz 2b
    test %r9d, %r9d
    jz 3f
    movb $45, (%rsi)
    dec %rsi
3:
    lea 1(%rsi), %r9
    lea -1(%rbp), %r10
    sub %r9, %r10
    inc %r10
    mov $10, %rax
    cmp %rax, %r10
    jbe 6f
    mov $20, %rax
6:
    sub %r10, %rax
    jle 7f
    mov %rax, %rdx
    lea .Lpad20(%rip), %rsi
    mov $1, %eax
    mov $1, %edi
    syscall
7:
    mov %r9, %rsi
    mov %r10, %rdx
    mov $1, %eax
    mov $1, %edi
    syscall
    leave
    ret

# hbc_print_dyn: %rax = tag, %rdx = payload. Prints NIL (no field width,
# probe n1) for tag 1, the raw string bytes for tag 2 (payload points at
# the bytes, length header at payload-8 - same layout as a hash key
# copy); otherwise the numeric payload via hbc_print_i64.
hbc_print_dyn:
    test %rax, %rax
    jz 8f
    cmp $2, %rax
    je 9f
    cmp $4, %rax
    je 9f
    cmp $3, %rax
    je 11f
    lea .Lnilmsg(%rip), %rsi
    mov $3, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    ret
8:  mov %rdx, %rax
    jmp hbc_print_i64c
11: lea .Lfmsg(%rip), %rsi
    test %rdx, %rdx
    jz 12f
    lea .Ltmsg(%rip), %rsi
12: mov $3, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    ret
9:  mov %rdx, %rax
    mov -8(%rax), %rdx
    jmp hbc_print_str

# hbc_dyn_to_i64: %rax = tag, %rdx = payload -> %rax = payload. NIL here is
# a Harbour type error (arithmetic/ordering/indexing on NIL); its dialog
# cannot be probed headless, so this fails cleanly - registered failure
# mode alongside hbc_bound_error, NOT a compat success.
hbc_dyn_to_i64:
    test %rax, %rax
    jnz hbc_type_error
    mov %rdx, %rax
    ret

# hbc_dyn_to_log: %rax = tag, %rdx = payload -> %rax = 0/1 (the logical
# payload). Only tag 3 is a valid condition: NIL (hk266), integers
# (hk267) and strings are Harbour's type error (clean named exit 1).
hbc_dyn_to_log:
    # Only a logical cell is a valid condition: NIL errors (hk266) and an
    # integer errors (hk267) in Harbour - its dialog cannot be probed
    # headless, so clean named exit 1 (registered failure mode).
    cmp $3, %rax
    jne hbc_dynlog_error
    mov %rdx, %rax
    ret

# hbc_dynlog_error: a non-logical Dyn cell reached a condition (noreturn).
hbc_dynlog_error:
    lea .Llogmsg(%rip), %rsi
    mov $39, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_dyn_eq: %rax/%rdx = lhs tag/payload, %rcx/%r8 = rhs tag/payload ->
# %rax = 1/0. NIL = NIL is .T.; NIL against a payload is .F. (probes n1-n3;
# string casilla x NIL casilla .F. in both directions - hk147). Two string
# casillas compare by CONTENT with Harbour's prefix rule over the right
# operand's length (hbc_str_eq tail call - hk145; before this fix they
# answered .T. by tag alone, a divergence). A string casilla against an
# integer casilla is Harbour's BASE/1071 "Argument error: =" (hk146,
# dialog hangs headless) - clean named exit 1 via hbc_dyncmp_eq_error,
# registered failure mode, not exact equivalence. Leaf routine.
hbc_dyn_eq:
    # tag 4 (owned string) behaves exactly like tag 2 (borrowed string)
    cmp $4, %rax
    jne 80f
    mov $2, %eax
80: cmp $4, %rcx
    jne 81f
    mov $2, %ecx
81: cmp %rcx, %rax
    jne 7f
    cmp $2, %rax
    je 6f
    cmp %r8, %rdx
    jne 8f
9:  mov $1, %eax
    ret
8:  xor %eax, %eax
    ret
6:  mov -8(%rdx), %r10
    mov -8(%r8), %r9
    mov %rdx, %rax
    mov %r8, %rcx
    mov %r9, %r8
    mov %r10, %rdx
    jmp hbc_str_eq
7:  test %rax, %rax
    je 71f
    cmp $2, %rax
    je 72f
    jmp 8b
71: cmp $2, %rcx
    je hbc_dyncmp_eq_error
    jmp 8b
72: cmp $1, %rcx
    je 8b
    jmp hbc_dyncmp_eq_error

# hbc_dynxcmp: %rax/%rdx = lhs tag/payload, %rcx/%r8 = rhs tag/payload,
# %r9d = operator (1=<, 2=>, 3=<=, 4=>=) -> %rax = -1/0/1 (signed).
# Ordering between two Dyn casillas (hk148): int x int numerically;
# string x string byte-wise over the right operand's length (hbc_str_cmp
# tail call); string x integer is Harbour's BASE/1073/1075/1074/1076 per
# operator (hk149-hk152 - dialogs hang headless): clean named exit 1 via
# the hbc_dyncmp_*_error stubs, registered failure modes, not exact
# equivalence. A NIL casilla in an ordering comparison is a Harbour type
# error: hbc_type_error (registered failure mode). Leaf routine.
hbc_dynxcmp:
    # tag 4 (owned string) behaves exactly like tag 2 (borrowed string)
    cmp $4, %rax
    jne 80f
    mov $2, %eax
80: cmp $4, %rcx
    jne 81f
    mov $2, %ecx
81: cmp %rcx, %rax
    jne 70f
    test %rax, %rax
    jnz 71f
    xor %eax, %eax
    cmp %r8, %rdx
    je 79f
    jl 77f
    mov $1, %eax
    ret
77: mov $-1, %rax
79: ret
71: cmp $2, %rax
    je 72f
    jmp hbc_type_error
72: mov -8(%rdx), %r10
    mov -8(%r8), %r11
    mov %rdx, %rax
    mov %r8, %rcx
    mov %r11, %r8
    mov %r10, %rdx
    jmp hbc_str_cmp
70: cmp $1, %rax
    je hbc_type_error
    cmp $1, %rcx
    je hbc_type_error
    cmp $1, %r9d
    je hbc_dyncmp_lt_error
    cmp $2, %r9d
    je hbc_dyncmp_gt_error
    cmp $3, %r9d
    je hbc_dyncmp_le_error
    jmp hbc_dyncmp_ge_error

# hbc_dynxeq_dd: %rax/%rdx = lhs tag/payload, %rcx/%r8 = rhs tag/payload ->
# %rax = 1/0. Harbour's `==` between casillas (hk132/hk133/hk138/hk140):
# NIL x NIL .T., NIL x payload .F., number x number by value, string x
# string the EXACT byte compare (length header at payload-8). Mixed
# number x string raises Harbour's BASE/1070 (hk139/hk139b/hk139c -
# dialog hangs headless): a clean named exit 1, registered failure mode,
# not exact equivalence. Leaf routine: the error path is a noreturn stub.
hbc_dynxeq_dd:
    # tag 4 (owned string) behaves exactly like tag 2 (borrowed string)
    cmp $4, %rax
    jne 80f
    mov $2, %eax
80: cmp $4, %rcx
    jne 81f
    mov $2, %ecx
81: cmp %rcx, %rax
    jne 5f
    cmp $2, %rax
    je 2f
    cmp $1, %rax
    je 9f
    cmp %r8, %rdx
    jne 8f
9:  mov $1, %eax
    ret
2:  mov -8(%rdx), %r10
    cmp -8(%r8), %r10
    jne 8f
    xor %r9, %r9
3:  cmp %r10, %r9
    jae 9b
    movzbl (%rdx,%r9), %r11d
    movzbl (%r8,%r9), %eax
    cmp %eax, %r11d
    jne 8f
    inc %r9
    jmp 3b
5:  cmp $1, %rax
    je 8f
    cmp $1, %rcx
    je 8f
    jmp hbc_dynxeq_error
8:  xor %eax, %eax
    ret
"#);

    out.push_str(r#"
# hbc_bound_error: array index outside 1..=n at runtime (noreturn). Prints
# the Harbour wording and exits 1. Harbour itself opens an interactive
# error dialog here (probes a1/a2 hang even with stdin at EOF): a clean
# exit is the registered failure-mode difference, same error condition.
hbc_bound_error:
    lea .Lboundmsg(%rip), %rsi
    mov $26, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_div0_error: division by zero at runtime (noreturn). Harbour raises
# EG_ZERODIV (hvm.c hb_vmDivide); the default headless handler substitutes
# nothing and the stale slot prints (probe hk294), so a clean exit 1 is the
# registered failure-mode difference, same error condition.
hbc_div0_error:
    lea .Ldiv0msg(%rip), %rsi
    mov $24, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# Integer increment cannot silently wrap. Harbour promotes to double;
# this fixed-I64 increment reports that uncovered boundary before store.
hbc_inc_overflow:
    lea .Lincmsg(%rip), %rsi
    mov $50, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_f64range_error: a float field (padding + digits, or a non-finite
# star fill) exceeds the helper's bounded compose scratch (456 bytes).
# Harbour grows its print buffer dynamically; beyond this measured
# frontier a clean named exit 1 is the registered limit (63zc).
hbc_f64range_error:
    lea .Lf64rangemsg(%rip), %rsi
    mov $32, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_round: %xmm0 = n, %rdi = d (i64, sign kept) -> %xmm0 = rounded value,
# %rdi = PACKED metadata (dec low16 | length<<16). Exact hb_numRound
# transcription (src/common/hbstr.c; HB_NUM_PRECISION off;
# HB_DBLFL_PREC_FACTOR = 1.0000000000000002 active - hbdefs.h:665):
# c = n [* or /] dPow * 10; c +/- 5 by sign of n; c / 10; c * factor;
# trunc toward zero; back-scale by dPow. dec = max(d, 0); length = the
# asymmetric HB_DBL_LENGTH rule. Zero flows through uniformly.
hbc_round:
    mov %rdi, %r8
    test %rdi, %rdi
    js .Lround_neg
    cmp $15, %rdi
    jg hbc_round_range_error
    lea .Lround_pow10(%rip), %rax
    movsd (%rax,%rdi,8), %xmm1
    mulsd %xmm1, %xmm0
    jmp .Lround_common
.Lround_neg:
    cmp $-15, %rdi
    jl hbc_round_range_error
    neg %rdi
    lea .Lround_pow10(%rip), %rax
    movsd (%rax,%rdi,8), %xmm1
    divsd %xmm1, %xmm0
.Lround_common:
    movsd .Lround_ten(%rip), %xmm2
    mulsd %xmm2, %xmm0
    xorpd %xmm3, %xmm3
    ucomisd %xmm3, %xmm0
    jb .Lround_sub5
    addsd .Lround_five(%rip), %xmm0
    jmp .Lround_div
.Lround_sub5:
    subsd .Lround_five(%rip), %xmm0
.Lround_div:
    divsd %xmm2, %xmm0
    mulsd .Lround_factor(%rip), %xmm0
    roundsd $3, %xmm0, %xmm0
    test %r8, %r8
    js .Lround_mulback
    divsd %xmm1, %xmm0
    jmp .Lround_meta
.Lround_mulback:
    mulsd %xmm1, %xmm0
.Lround_meta:
    xor %edi, %edi
    test %r8, %r8
    js .Lround_len
    mov %r8, %rdi
.Lround_len:
    mov $10, %eax
    movsd .Lround_lenmax(%rip), %xmm2
    ucomisd %xmm2, %xmm0
    ja .Lround_l20
    xorpd %xmm2, %xmm2
    subsd %xmm0, %xmm2
    movsd .Lround_lenmin(%rip), %xmm3
    ucomisd %xmm3, %xmm2
    jbe .Lround_l10
.Lround_l20:
    mov $20, %eax
.Lround_l10:
    shl $16, %rax
    or %rax, %rdi
    ret

# hbc_round_range_error: runtime dec beyond +/-15 (Harbour switches to
# pow(10,d) there - parked, registered limit). Clean named exit 1.
hbc_round_range_error:
    lea .Lroundmsg(%rip), %rsi
    mov $30, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_type_error: NIL used as a number at runtime (arithmetic, ordering or
# array indexing). Harbour raises a type-error dialog; headless probes
# cannot capture it, so this PoC prints and exits 1 (registered failure
# mode, same error condition).
hbc_type_error:
    lea .Ltypemsg(%rip), %rsi
    mov $33, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_str_cache_flush: release only logically freed cached blocks.
# Registry/counters track live ownership, so flushing changes neither.
hbc_str_cache_flush:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    xor %r12d, %r12d
    lea hbc_str_cache(%rip), %r13
.Lcache_flush_l_next:
    mov (%r13,%r12,8), %rdi
    movq $0, (%r13,%r12,8)
    test %rdi, %rdi
    jz .Lcache_flush_l_skip
    mov (%rdi), %rsi
    add $16, %rsi
    mov $11, %eax
    syscall
    test %rax, %rax
    jnz hbc_os_bad
.Lcache_flush_l_skip:
    inc %r12
    cmp $8, %r12
    jb .Lcache_flush_l_next
    pop %r13
    pop %r12
    pop %rbp
    ret

# ---- dynamic array heap (mmap) ----
# hbc_alloc: rdi = bytes -> rax = base of a zeroed anonymous mapping.
# mmap failure is a negative errno in rax (range -4095..-1), never NULL.
hbc_alloc:
    mov %rdi, %rsi
    xor %edi, %edi
    mov $3, %edx
    mov $0x22, %r10d
    mov $-1, %r8
    xor %r9d, %r9d
    mov $9, %eax
    syscall
    mov $-4096, %rcx
    cmp %rcx, %rax
    ja hbc_oom
@REG_ALLOC_L@    incq hbc_mem_allocs(%rip)
    ret

# hbc_oom: allocation failure or capacity overflow (noreturn)
hbc_oom:
    lea .Loommsg(%rip), %rsi
    mov $14, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_asize_neg: ASize with a negative size (noreturn)
hbc_asize_neg:
    lea .Lasizenegmsg(%rip), %rsi
    mov $21, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_len_error: len() of a NIL slot (noreturn). Harbour's BASE/1111
# dialog hangs headless (oracle n2): this clean exit 1 is the registered
# failure mode for the same error condition, not a compat success.
hbc_len_error:
    lea .Llenerrmsg(%rip), %rsi
    mov $20, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_param_error: a NIL casilla passed as a borrowed a[i] argument
# (noreturn). Harbour's dialog hangs headless (same family as BASE/1123,
# oracle n6): clean exit 1, registered failure mode - not a compat success.
hbc_param_error:
    lea .Lparamerrmsg(%rip), %rsi
    mov $22, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_aadd_error / hbc_asize_error: AAdd/ASize on a NIL casilla
# (noreturn). Harbour's BASE/1123 and BASE/2023 dialogs hang headless
# (oracles n6/n7): clean exit 1, registered failure modes.
# hbc_snil_error: a NIL casilla (ASize growth, hk13/hk14) read in a
# string context (noreturn). Harbour yields NIL there - its typing is
# dynamic; the static StrOwn cannot, so this is the registered clean
# failure mode.
hbc_snil_error:
    lea .Lsnilmsg(%rip), %rsi
    mov $47, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_dyncmp_eq_error / hbc_dyncmp_ne_error: a numeric Dyn compared
# against a string (noreturn). Harbour raises BASE/1071 "Argument
# error: =" and BASE/1072 "Argument error: <>" (hk34/hk38, dialogs
# that hang headless) - clean named exit 1 here, registered failure
# mode, same error condition.
hbc_dyncmp_eq_error:
    lea .Ldyncmpeqmsg(%rip), %rsi
    mov $18, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_dyncmp_ne_error:
    lea .Ldyncmpnemsg(%rip), %rsi
    mov $19, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_dynxeq_error: numeric casilla compared against a string under `==`
# (noreturn). Harbour raises BASE/1070 "Argument error: ==" (hk139/
# hk139b/hk139c, dialogs that hang headless) - clean named exit 1 here,
# registered failure mode, same error condition.
hbc_dynxeq_error:
    lea .Ldynxeqmsg(%rip), %rsi
    mov $19, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_dyncmp_lt/gt/le/ge_error: a NIL or numeric Dyn ordered against
# a string (noreturn). Harbour raises BASE/1073 "Argument error: <",
# BASE/1075 "Argument error: >", BASE/1074 "Argument error: <=" and
# BASE/1076 "Argument error: >=" (hk41/hk42/hk44-hk50, dialogs that
# hang headless) - clean named exit 1 here, registered failure mode,
# same error condition.
hbc_dyncmp_lt_error:
    lea .Ldyncmpltmsg(%rip), %rsi
    mov $18, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_dyncmp_gt_error:
    lea .Ldyncmpgtmsg(%rip), %rsi
    mov $18, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_dyncmp_le_error:
    lea .Ldyncmplemsg(%rip), %rsi
    mov $19, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_dyncmp_ge_error:
    lea .Ldyncmpgemsg(%rip), %rsi
    mov $19, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_arracc_error: a NIL casilla of an array of arrays iterated with
# FOR EACH (noreturn). Harbour raises BASE/1068 "Argument error:
# array access" (hk58, dialog hangs headless) - clean named exit 1
# here, registered failure mode, same error condition.
hbc_arracc_error:
    lea .Larraccmsg(%rip), %rsi
    mov $29, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

hbc_aadd_error:
    lea .Laadderrmsg(%rip), %rsi
    mov $21, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall
hbc_asize_error:
    lea .Lasizeerrmsg(%rip), %rsi
    mov $22, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_free: rdi = data pointer (non-null), rsi = element size in bytes.
# Header at -8 holds the capacity in elements; the mapped length is
# 8 + cap*elemsize (munmap needs the allocation length).
hbc_free:
    mov -8(%rdi), %rax
    imul %rsi, %rax
    lea 8(%rax), %rsi
    sub $8, %rdi
@REG_FREE_L@    mov $11, %eax
    syscall
    # munmap result: 0 on success, negative errno otherwise - a registry
    # match alone does not prove the OS released the block.
    test %rax, %rax
    jnz hbc_os_bad
    incq hbc_mem_frees(%rip)
    ret

# hbc_freestr: rdi = string data pointer (non-null). String layout:
# capacity at -16(%rdi), length at -8(%rdi); the mapping is 16 + cap
# bytes starting at rdi-16. The Linux registry snippet is
# formula-agnostic (it validates the computed base and length).
hbc_freestr:
    mov -16(%rdi), %rsi
    add $16, %rsi
    sub $16, %rdi
@REG_FREE_L@    cmp $272, %rsi
    ja .Lstr_release_l
    mov (%rdi), %rcx
    and $7, %ecx
    lea hbc_str_cache(%rip), %r11
    cmpq $0, (%r11,%rcx,8)
    jne .Lstr_release_l
    mov %rdi, (%r11,%rcx,8)
    incq hbc_mem_frees(%rip)
    ret
.Lstr_release_l:
    mov $11, %eax
    syscall
    test %rax, %rax
    jnz hbc_os_bad
    incq hbc_mem_frees(%rip)
    ret

# hbc_hfreeblock: rdi = hash block data pointer (non-null). Frees the
# whole block: 16-byte header [flags @0][capacity @8] + entries, so the
# mapping base is rdi-16 and the length is 16 + cap*32. The registry
# snippet is the formula-agnostic Linux one (it compares the computed
# base and length against the recorded allocation).
hbc_hfreeblock:
    mov -8(%rdi), %rax
    shl $5, %rax
    lea 16(%rax), %rsi
    sub $16, %rdi
@REG_FREE_L@    mov $11, %eax
    syscall
    test %rax, %rax
    jnz hbc_os_bad
    incq hbc_mem_frees(%rip)
    ret

@REG_BAD_L@# hbc_os_bad: munmap reported failure (noreturn).
hbc_os_bad:
    lea .Losbadmsg(%rip), %rsi
    mov $31, %edx
    mov $1, %eax
    mov $1, %edi
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall

# hbc_free2: rdi = outer data pointer (non-null), rsi = outer length.
# Frees each live child (i64 arrays in this increment) then the outer block.
hbc_free2:
    push %rbx
    push %r12
    push %r13
    mov %rdi, %rbx
    mov %rsi, %r12
    xor %r13, %r13
71: cmp %r12, %r13
    jge 72f
    mov %r13, %rax
    shl $4, %rax
    mov (%rbx,%rax), %rdi
    test %rdi, %rdi
    jz 73f
    mov $16, %esi
    call hbc_free
73: inc %r13
    jmp 71b
72: mov %rbx, %rdi
    mov $16, %esi
    call hbc_free
    pop %r13
    pop %r12
    pop %rbx
    ret

# hbc_rfree: rdi = block of (ptr,len) pairs, rsi = pair count, rdx =
# pair-levels (>= 2). Generic recursive free: a child of a block with
# more than two pair-levels is freed by hbc_rfree at one level less; a
# child at exactly two pair-levels is a DArr2 block, freed by the tested
# hbc_free2. Depth 4+ needs no new helper. Callee-saved registers are
# preserved (rbx/r12-r14); the extra sub keeps rsp 16-aligned at calls.
hbc_rfree:
    push %rbx
    push %r12
    push %r13
    push %r14
    sub $8, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r14
    xor %r13, %r13
71: cmp %r12, %r13
    jge 72f
    mov %r13, %rax
    shl $4, %rax
    mov (%rbx,%rax), %rdi
    test %rdi, %rdi
    jz 73f
    mov 8(%rbx,%rax), %rsi
    cmp $2, %r14
    je 74f
    lea -1(%r14), %rdx
    call hbc_rfree
    jmp 73f
74: call hbc_free2
73: inc %r13
    jmp 71b
72: mov %rbx, %rdi
    mov $16, %esi
    call hbc_free
    add $8, %rsp
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret

# hbc_aadd: rdi = slot address (ptr,len), rsi = element size (8 or 16),
# rdx = pointer to the new element. Grows in place; a failed allocation
# leaves the old block and the slot untouched (the slot is replaced only
# after the new block is fully populated).
hbc_aadd:
    push %rbx
    push %r12
    push %r13
    push %r14
    mov %rdi, %rbx
    mov %rsi, %r14
    mov %rdx, %r12
    mov (%rbx), %r13
    xor %ecx, %ecx
    test %r13, %r13
    jz 51f
    mov -8(%r13), %rcx
51: cmp 8(%rbx), %rcx
    jg 54f
    # grow: newcap = cap ? cap*2 : 4
    mov $4, %eax
    test %rcx, %rcx
    jz 52f
    lea (%rcx,%rcx), %rax
52: mov $0x2000000000000000, %rdx
    cmp %rdx, %rax
    jae hbc_oom
    push %rcx
    push %rax
    mov %rax, %rdi
    imul %r14, %rdi
    jo hbc_oom
    add $8, %rdi
    jc hbc_oom
    call hbc_alloc
    pop %rdx
    pop %rcx
    mov %rdx, (%rax)
    test %r13, %r13
    jz 53f
    mov 8(%rbx), %r8
    xor %r9, %r9
55: cmp %r8, %r9
    jge 56f
    mov %r9, %r10
    imul %r14, %r10
    mov (%r13,%r10), %rcx
    mov %rcx, 8(%rax,%r10)
    cmp $16, %r14
    jne 57f
    mov 8(%r13,%r10), %rcx
    mov %rcx, 16(%rax,%r10)
57: inc %r9
    jmp 55b
56: sub $16, %rsp
    mov %rax, (%rsp)
    mov %r13, %rdi
    mov %r14, %rsi
    call hbc_free
    mov (%rsp), %rax
    add $16, %rsp
53: add $8, %rax
    mov %rax, (%rbx)
    mov %rax, %r13
54: mov 8(%rbx), %rcx
    mov %rcx, %r10
    imul %r14, %r10
    mov (%r12), %rax
    mov %rax, (%r13,%r10)
    cmp $16, %r14
    jne 58f
    mov 8(%r12), %rax
    mov %rax, 8(%r13,%r10)
58: inc %rcx
    mov %rcx, 8(%rbx)
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret

# hbc_asize: rdi = slot address, rsi = new length, rdx = element size,
# rcx = deep flag (1: free removed children on shrink). Grown i64 slots
# read NIL (probe e1: Harbour grows with NIL); a DArr2 grows with the empty
# (null, 0) child.
hbc_asize:
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r14
    mov %rcx, %r15
    test %r12, %r12
    js hbc_asize_neg
    mov 8(%rbx), %rcx
    cmp %rcx, %r12
    jle 59f
    mov (%rbx), %r13
    xor %edx, %edx
    test %r13, %r13
    jz 61f
    mov -8(%r13), %rdx
61: cmp %rdx, %r12
    jle 63f
    mov $4, %eax
    test %rdx, %rdx
    jz 62f
    lea (%rdx,%rdx), %rax
62: cmp %rax, %r12
    jle 64f
    mov %r12, %rax
64: mov $0x2000000000000000, %r8
    cmp %r8, %rax
    jae hbc_oom
    push %rdx
    push %rax
    mov %rax, %rdi
    imul %r14, %rdi
    jo hbc_oom
    add $8, %rdi
    jc hbc_oom
    call hbc_alloc
    pop %rdx
    pop %rcx
    mov %rdx, (%rax)
    mov 8(%rbx), %r8
    test %r13, %r13
    jz 65f
    xor %r9, %r9
66: cmp %r8, %r9
    jge 69f
    mov %r9, %r10
    imul %r14, %r10
    mov (%r13,%r10), %rcx
    mov %rcx, 8(%rax,%r10)
    cmp $16, %r14
    jne 60f
    mov 8(%r13,%r10), %rcx
    mov %rcx, 16(%rax,%r10)
60: inc %r9
    jmp 66b
69: sub $16, %rsp
    mov %rax, (%rsp)
    mov %r13, %rdi
    mov %r14, %rsi
    call hbc_free
    mov (%rsp), %rax
    add $16, %rsp
65: add $8, %rax
    mov %rax, (%rbx)
    mov %rax, %r13
63: mov 8(%rbx), %rcx
67: cmp %r12, %rcx
    jge 68f
    mov %rcx, %r10
    shl $4, %r10
    cmp $1, %r15
    je 79f
    cmp $3, %r15
    je 79f
    # flat arrays and arrays of strings grow with NIL {1, 0} (probe e1;
    # hk13/hk14 for the string array: grown casillas read NIL)
    movq $1, (%r13,%r10)
    movq $0, 8(%r13,%r10)
    jmp 74f
79: # a DArr2 grows with the empty child (null, 0) - m-probes, unchanged
    movq $0, (%r13,%r10)
    movq $0, 8(%r13,%r10)
74: inc %rcx
    jmp 67b
68: mov %r12, 8(%rbx)
    jmp 75f
59: # shrink: kind 2 frees the removed string copies, kind 1 the children
    cmp $2, %r15
    je 80f
    cmp $3, %r15
    je 83f
    test %r15, %r15
    jz 76f
    mov (%rbx), %r13
    mov %r12, %r9
77: cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    mov (%r13,%r10), %rdi
    test %rdi, %rdi
    jz 78f
    mov $16, %esi
    call hbc_free
78: inc %r9
    jmp 77b
80: mov (%rbx), %r13
    mov %r12, %r9
81: cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    cmpq $2, (%r13,%r10)
    jne 82f
    mov 8(%r13,%r10), %rdi
    test %rdi, %rdi
    jz 82f
    call hbc_freestr
82: inc %r9
    jmp 81b
    # kind 3: three levels - removed children own their own children,
    # so they are freed RECURSIVELY (hbc_rfree depth 2)
83: mov (%rbx), %r13
    mov %r12, %r9
84: cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    mov (%r13,%r10), %rdi
    test %rdi, %rdi
    jz 85f
    mov 8(%r13,%r10), %rsi
    mov $2, %edx
    call hbc_rfree
85: inc %r9
    jmp 84b
76: mov %r12, 8(%rbx)
75: pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret

    .data
    .align 8
hbc_mem_allocs: .quad 0
hbc_mem_frees:  .quad 0
hbc_str_cache: .zero 64
@REG_DATA@    .text
"#);
    out.push_str(CTOR_HELPERS);
    out.push_str(ARRAY3_HELPER);
    out.push_str(HASH_HELPERS);
    out.push_str(F64_HELPER);
    out.push_str("\n    .section .rodata\n");
    emit_strings(&mut out, &strs);
    emit_f64_consts(&mut out);
    // Allocation registry: only instrumented builds (--instrument, the
    // battery's mode) carry it; normal output has no registry at all.
    out = out.replace("@REG_ALLOC_L@", if instrument { REG_ALLOC_L } else { "" });
    out = out.replace("@REG_FREE_L@", if instrument { REG_FREE_L } else { "" });
    out = out.replace("@REG_HFREE_W@", if instrument { REG_HFREE_W } else { "" });
    out = out.replace("@REG_BAD_L@", if instrument { REG_BAD_L } else { "" });
    out = out.replace("@REG_CACHE_ALLOC@", if instrument { REG_ALLOC_L } else { "" });
            out = out.replace("@REG_ALLOC_W@", if instrument { REG_ALLOC_W } else { "" });
    out = out.replace("@REG_FREE_W@", if instrument { REG_FREE_W } else { "" });
    out = out.replace("@REG_SFREE_W@", if instrument { REG_SFREE_W } else { "" });
    out = out.replace("@REG_BAD_W@", if instrument { REG_BAD_W } else { "" });
    out = out.replace("@REG_DATA@", if instrument { REG_DATA } else { "" });
    finalize_trace(out, target)
}

// Unify controlled failures only. Normal _start exits are not rewritten.
fn finalize_trace(mut out: String, target: Target) -> String {
    // Add private stderr variants only when used. No mutable routing state:
    // nested OutStd/QOut and controlled diagnostics retain their destination.
    if out.contains("call hbc_eprint_") {
        let original = out.clone();
        out.push_str("\n    .text\n");
        for name in ["str", "sep", "i64", "i64c", "dyn", "f64"] {
            let label = format!("\nhbc_print_{}:", name);
            let start = original.find(&label).expect("print helper exists") + 1;
            let rest = &original[start..];
            let end = rest.find("\nhbc_").unwrap_or(rest.len());
            let end = rest[..end].find("\n    .section").unwrap_or(end);
            let mut helper = rest[..end].replace("hbc_print_", "hbc_eprint_")
                .replace(".Lf64_", ".Lef64_");
            helper = match target {
                Target::Linux => helper.replace("mov $1, %edi", "mov $2, %edi"),
                Target::Windows => helper.replace("mov $-11, %ecx", "mov $-12, %ecx"),
            };
            out.push_str(&helper);
            out.push('\n');
        }
    }
    let (old, new) = match target {
        Target::Linux => ("    mov $60, %eax\n    mov $1, %edi\n    syscall", "    jmp hbc_panic_exit"),
        Target::Windows => ("    mov $1, %ecx\n    call ExitProcess", "    jmp hbc_panic_exit"),
    };
    out = out.replace(old, new);
    out.push_str(r#"
    .data
    .align 8
hbc_trace_top: .quad 0
    .text
# hbc_print_trace: native diagnostic chain, youngest frame first.
# No heap, no fixed depth array. Preserve all nonvolatile GPRs.
hbc_print_trace:
    push %rbp
    mov %rsp, %rbp
    push %r12
    sub $40, %rsp
    mov hbc_trace_top(%rip), %r12
    test %r12, %r12
    jz .Ltrace_done
    lea .Ltrace_header(%rip), %rax
    mov $11, %edx
    call hbc_print_str
.Ltrace_next:
    mov 8(%r12), %rax
    mov 16(%r12), %rdx
    test %rdx, %rdx
    jz .Ltrace_skip
    call hbc_print_str
.Ltrace_skip:
    mov (%r12), %r12
    test %r12, %r12
    jnz .Ltrace_next
.Ltrace_done:
    add $40, %rsp
    pop %r12
    pop %rbp
    ret
# Error labels may jump here with arbitrary helper frames and alignment.
hbc_panic_exit:
    and $-16, %rsp
    sub $32, %rsp
    call hbc_print_trace
"#);
    match target {
        Target::Linux => out.push_str("    mov $60, %eax\n    mov $1, %edi\n    syscall\n    .section .rodata\n"),
        Target::Windows => out.push_str("    mov $1, %ecx\n    call ExitProcess\n    .section .rdata,\"r\"\n"),
    }
    out.push_str(".Ltrace_header:\n    .byte 67,97,108,108,115,116,97,99,107,58,10\n");
    out
}

fn emit_f64_consts(out: &mut String) {
    F64_CONSTS.with(|c| {
        let v = c.borrow();
        if !v.is_empty() {
            out.push_str("    .balign 8\n");
            for (i, b) in v.iter().enumerate() {
                out.push_str(&format!(".Lf64c{}:\n    .quad {}\n", i, b));
            }
        }
    });
}

fn emit_strings(out: &mut String, strs: &[String]) {
    for (i, s) in strs.iter().enumerate() {
        out.push_str(&format!(".Lstr{}:\n", i));
        for chunk in s.as_bytes().chunks(16) {
            let bytes: Vec<String> = chunk.iter().map(|b| b.to_string()).collect();
            out.push_str(&format!("    .byte {}\n", bytes.join(",")));
        }
    }
    out.push_str(".Lnl:\n    .byte 10\n");
    out.push_str(".Lpad20:\n    .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32\n");
    // "NIL" (3 bytes; the NIL print form, probe n1)
    out.push_str(".Lnilmsg:\n    .byte 78,73,76\n");
    out.push_str(".Ltmsg:\n    .byte 46,84,46\n");
    out.push_str(".Lfmsg:\n    .byte 46,70,46\n");
    // "Bound error: array access\n" (26 bytes; Harbour wording, probe a1)
    out.push_str(".Lboundmsg:\n    .byte 66,111,117,110,100,32,101,114,114,111,114,58,32,97,114,114,97,121,32,97,99,99,101,115,115,10\n");
    // "Error: division by zero\n" (24 bytes; EG_ZERODIV, probe hk294)
    out.push_str(".Ldiv0msg:\n    .byte 69,114,114,111,114,58,32,100,105,118,105,115,105,111,110,32,98,121,32,122,101,114,111,10\n");
    out.push_str(".Lincmsg:\n    .byte 76,105,109,105,116,58,32,105,110,99,114,101,109,101,110,116,32,111,118,101,114,102,108,111,119,32,110,101,101,100,115,32,110,117,109,101,114,105,99,32,112,114,111,109,111,116,105,111,110,10\n");
    out.push_str(".Lf64rangemsg:\n    .byte 69,114,114,111,114,58,32,102,108,111,97,116,32,102,105,101,108,100,32,111,117,116,32,111,102,32,114,97,110,103,101,10\n");
    out.push_str(".Lroundmsg:\n    .byte 69,114,114,111,114,58,32,114,111,117,110,100,32,100,101,99,32,111,117,116,32,111,102,32,114,97,110,103,101,10\n");
    out.push_str(".Lround_pow10:\n    .quad 4607182418800017408, 4621819117588971520, 4636737291354636288, 4652007308841189376\n    .quad 4666723172467343360, 4681608360884174848, 4696837146684686336, 4711630319722168320\n    .quad 4726483295884279808, 4741671816366391296, 4756540486875873280, 4771362005757984768\n    .quad 4786511204640096256, 4801453603149578240, 4816244402031689728, 4831355200913801216\n");
    out.push_str(".Lround_lenmax:\n    .quad 4756540486875348992\n");
    out.push_str(".Lround_lenmin:\n    .quad 4741671816358002688\n");
    out.push_str(".Lround_ten:\n    .quad 4621819117588971520\n");
    out.push_str(".Lround_five:\n    .quad 4617315517961601024\n");
    out.push_str(".Lround_factor:\n    .quad 4607182418800017409\n");
    out.push_str(".Loommsg:\n    .byte 79,117,116,32,111,102,32,109,101,109,111,114,121,10\n");
    // "Type error: NIL used as a number\n" (33 bytes; registered failure mode)
    out.push_str(".Losbadmsg:\n    .byte 73,110,116,101,114,110,97,108,32,101,114,114,111,114,58,32,79,83,32,102,114,101,101,32,102,97,105,108,101,100,10\n");
    out.push_str(".Lregbadmsg:\n    .byte 73,110,116,101,114,110,97,108,32,101,114,114,111,114,58,32,97,108,108,111,99,97,116,105,111,110,32,114,101,103,105,115,116,114,121,32,109,105,115,109,97,116,99,104,10\n");
    out.push_str(".Ltypemsg:\n    .byte 84,121,112,101,32,101,114,114,111,114,58,32,78,73,76,32,117,115,101,100,32,97,115,32,97,32,110,117,109,98,101,114,10\n");
    out.push_str(".Llogmsg:\n    .byte 84,121,112,101,32,101,114,114,111,114,58,32,99,111,110,100,105,116,105,111,110,32,105,115,32,110,111,116,32,97,32,108,111,103,105,99,97,108,10\n");
    out.push_str(".Lasizenegmsg:\n    .byte 65,83,105,122,101,58,32,110,101,103,97,116,105,118,101,32,115,105,122,101,10\n");
    // "Argument error: LEN\n" (20 bytes; Harbour BASE/1111 hangs headless - registered failure mode)
    out.push_str(".Llenerrmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,76,69,78,10\n");
    // "Argument error: AADD\n" (21 bytes; Harbour BASE/1123 hangs headless, oracle n6)
    out.push_str(".Laadderrmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,65,65,68,68,10\n");
    // "Argument error: PARAM\n" (22 bytes; NIL casilla as a borrowed argument - registered failure mode, Harbour hangs headless)
    out.push_str(".Lparamerrmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,80,65,82,65,77,10\n");
    out.push_str(".Lsnilmsg:\n    .byte 84,121,112,101,32,101,114,114,111,114,58,32,101,120,112,101,99,116,101,100,32,97,32,115,116,114,105,110,103,32,101,108,101,109,101,110,116,44,32,103,111,116,32,78,73,76,10\n");
    out.push_str(".Ldyncmpeqmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,61,10\n");
    out.push_str(".Ldynxeqmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,61,61,10\n");
    out.push_str(".Ldyncmpnemsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,60,62,10\n");
    out.push_str(".Ldyncmpltmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,60,10\n");
    out.push_str(".Ldyncmpgtmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,62,10\n");
    out.push_str(".Ldyncmplemsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,60,61,10\n");
    out.push_str(".Ldyncmpgemsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,62,61,10\n");
    out.push_str(".Larraccmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,97,114,114,97,121,32,97,99,99,101,115,115,10\n");
    // "Argument error: ASIZE\n" (22 bytes; Harbour BASE/2023 hangs headless, oracle n7)
    out.push_str(".Lasizeerrmsg:\n    .byte 65,114,103,117,109,101,110,116,32,101,114,114,111,114,58,32,65,83,73,90,69,10\n");
}

// hbc_print_f64: %xmm0 = value, %rdi = written-decimal count. Standalone-
// validated against oracles hk278-hk284 (see design/f64/): sign by bit
// (-0.0 prints "0.0"), normalize to mantissa [1,10) tracking exponent e,
// N = round(m * 1e15) half-up (16 significant digits, carry N=1e16 -> e++),
// integer digits = e+1 (or "0" for e<0), fraction = (-e-1) leading zeros +
// remaining digits of N, zero-padded to the decimal count; field width
// 11 + decimals, growing when the integer part is longer; no newline.
// Uses only xmm0-xmm2 and volatile registers plus saved r12-r15; the only
// call is hbc_print_str (same internal contract on both targets). The
// "16 significant digits" rule is OBSERVED in the probes, not proven
// universal; the half-up tie at digit 16 has no direct oracle yet.
const F64_HELPER: &str = r#"
# hbc_print_f64: %xmm0 = value, %rdi = dec_count. Frontier: nonzero |x| >= 1e-17 and the (int,dec) measured zone of hbc.rs (oracles hk278-hk288).
hbc_print_f64:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    push %r14
    push %r15
    sub $512, %rsp
    mov %rdi, -40(%rbp)          # packed metadata: (length << 16) | dec
    # Non-finite (inf from overflow, NaN from inf-inf): Harbour fills the
    # whole field with '*' - iSize = length + (dec ? 1 + dec : 0) stars
    # and NO padding (hb_itemStrBuf; oracle hk299).
    movq %xmm0, %rax
    mov $0x7ff0000000000000, %rcx
    and %rcx, %rax          # exponent field only (NaN and inf both all-ones)
    cmp %rcx, %rax
    jne .Lf64_fin
    mov -40(%rbp), %r13
    mov %r13, %r15
    shr $16, %r15               # Harbour item length
    movzwl %r13w, %r13d         # dec
    test %r13d, %r13d
    jz .Lf64_st
    inc %r15
    add %r13, %r15
.Lf64_st:
    cmp $456, %r15              # bounded scratch (63zc frontier)
    jbe .Lf64_st3
    call hbc_f64range_error
.Lf64_st3:
    lea -544(%rbp), %r9
    mov %r15d, %ecx
.Lf64_st2:  movb $42, (%r9)
    inc %r9
    dec %ecx
    jnz .Lf64_st2
    lea -544(%rbp), %rax
    mov %r15, %rdx
    call hbc_print_str
    add $512, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    leave
    ret
.Lf64_fin:
    # sign / |x|
    xor %r10d, %r10d
    movq %xmm0, %rax
    test %rax, %rax
    jns .Lf64_10
    mov $1, %r10d
    mov $0x7fffffffffffffff, %rcx
    and %rcx, %rax
    movq %rax, %xmm0
.Lf64_10:
    # zero? (covers -0.0: sign dropped, oracle hk282)
    xorpd %xmm2, %xmm2
    ucomisd %xmm2, %xmm0
    jp .Lf64_11                      # unordered (NaN): treat as nonzero-defensive
    je .Lf64_20                      # zero
.Lf64_11:
    # normalize ax into [1,10), e in %r11
    xor %r11d, %r11d
    mov $0x4024000000000000, %rax
    movq %rax, %xmm1            # 10.0
.Lf64_1:  comisd %xmm1, %xmm0
    jb .Lf64_2
    divsd %xmm1, %xmm0
    inc %r11
    jmp .Lf64_1
.Lf64_2:  mov $0x3FF0000000000000, %rax
    movq %rax, %xmm2            # 1.0
.Lf64_3:  comisd %xmm2, %xmm0
    jae .Lf64_4
    mulsd %xmm1, %xmm0
    dec %r11
    jmp .Lf64_3
.Lf64_4:
    # N = (i64)(m * 1e15 + 0.5)
    mov $0x430C6BF526340000, %rax
    movq %rax, %xmm2
    mulsd %xmm2, %xmm0
    mov $0x3FE0000000000000, %rax
    movq %rax, %xmm2
    addsd %xmm2, %xmm0
    cvttsd2si %xmm0, %rax
    # carry: N == 1e16 -> N=1e15, e++
    mov $10000000000000000, %rcx
    cmp %rcx, %rax
    jne .Lf64_5
    mov $1000000000000000, %rax
    inc %r11
.Lf64_5:
    mov %rax, -48(%rbp)         # N
    mov %r11, -56(%rbp)         # e
    jmp .Lf64_30
.Lf64_20: # zero: N=0, e=0, sign=0
    xor %r10d, %r10d
    movq $0, -48(%rbp)
    movq $0, -56(%rbp)
.Lf64_30:
    # digit buffer: 16 digits of N at -48..-65(%rbp) (ASCII, most significant first)
    mov -48(%rbp), %rax
    lea -65(%rbp), %rsi
    mov $16, %ecx
.Lf64_6:  xor %edx, %edx
    mov $10, %r8
    div %r8
    add $48, %dl
    mov %dl, (%rsi)
    dec %rsi
    dec %ecx
    jnz .Lf64_6
    # hk301/hk301b: Harbour rounds the printed value HALF-UP (half-away
    # from zero - the sign is handled separately) at the dec boundary,
    # applied to the 16-significant-digit image: 0.125/1 -> 0.13,
    # 0.665/1 -> 0.67 (the double is 0.66499...; the image carries the
    # tie), 1.5/2.25 -> 0.67, 9.995/1 -> 10.00 with carry into the
    # integer part, 0.0999/1 -> 0.10 with carry through the leading
    # fraction zeros.
    movb $48, -160(%rbp)         # integer char when e<0 ("0"); -160/-161 are free frame bytes (saved regs occupy -8..-32)
    movb $0, -161(%rbp)          # leading-zero fraction position raised by a carry (0 = none)
    movzwl -40(%rbp), %r13d     # dec
    mov -56(%rbp), %r11         # e
    mov $1, %r12
    test %r11, %r11
    js .Lf64_50
    lea 1(%r11), %r12           # int_len = e+1
.Lf64_50:
    # round source = digit at position int_len+dec+1 of the sequence
    # (e>=0: N[i-1] or '0' past 16; e<0: '0' through the -e-1 leading
    # fraction zeros, then N[k+e]).
    lea 1(%r12,%r13), %rcx
    mov $48, %dl
    test %r11, %r11
    js .Lf64_51
    cmp $16, %rcx
    ja .Lf64_52
    mov -81(%rbp,%rcx), %dl
    jmp .Lf64_52
.Lf64_51:
    lea -1(%rcx), %rax          # fraction index k
    mov %r11, %r8
    neg %r8
    dec %r8                     # -e-1
    cmp %r8, %rax
    jle .Lf64_52                # inside the leading zeros: source is '0'
    lea (%rax,%r11), %r8        # N index = k+e
    cmp $16, %r8
    jae .Lf64_52
    mov -80(%rbp,%r8), %dl
.Lf64_52:
    cmp $53, %dl                # '5'
    jb .Lf64_60
    # increment at position int_len+dec and walk the carry left
    lea (%r12,%r13), %rcx
.Lf64_54:
    test %r11, %r11
    js .Lf64_55
    mov -81(%rbp,%rcx), %dl     # e>=0: position rcx maps to N[rcx-1]
    cmp $57, %dl
    je .Lf64_57
    inc %dl
    mov %dl, -81(%rbp,%rcx)
    jmp .Lf64_60
.Lf64_57:
    movb $48, -81(%rbp,%rcx)
    dec %rcx
    jnz .Lf64_54
    # full carry: the image becomes 1 followed by zeros - clear ALL 16
    # digits (the round source and everything past it are stale)
    lea -80(%rbp), %rsi
    mov $16, %ecx
.Lf64_62:  movb $48, (%rsi)
    inc %rsi
    dec %ecx
    jnz .Lf64_62
    movb $49, -80(%rbp)
    incq -56(%rbp)              # e grows: 9.995/1 -> 10.00 (hk301)
    jmp .Lf64_60
.Lf64_55:
    cmp $1, %rcx
    je .Lf64_58
    lea -1(%rcx), %rax          # fraction index k
    mov %r11, %r8
    neg %r8
    dec %r8                     # -e-1
    cmp %r8, %rax
    jle .Lf64_59                # leading-zero region: '0' -> '1'
    lea (%rax,%r11), %r8        # N index = k+e
    mov -80(%rbp,%r8), %dl
    cmp $57, %dl
    je .Lf64_61
    inc %dl
    mov %dl, -80(%rbp,%r8)
    jmp .Lf64_60
.Lf64_61:
    movb $48, -80(%rbp,%r8)
    dec %rcx
    jmp .Lf64_54
.Lf64_59:
    movb %al, -161(%rbp)         # raised leading-zero position
    jmp .Lf64_60
.Lf64_58:
    movb $49, -160(%rbp)         # the integer "0" becomes "1"
.Lf64_60:

    # compose output at -544(%rbp) forward; r9 = cursor
    lea -544(%rbp), %r9
    # total_len = sign + int_len + 1 + dec ; width = 11 + dec ; pad = max(width-total,0)
    mov -56(%rbp), %r11         # e
    mov $1, %r12                # int_len (e<0 -> "0")
    test %r11, %r11
    js .Lf64_7
    lea 1(%r11), %r12           # int_len = e+1
.Lf64_7:  mov -40(%rbp), %r13          # packed metadata: dec = low 16 bits, Harbour item length (10/20) above them
    mov %r13, %r15
    shr $16, %r15               # length: 10 for literals and small results, 20 for the asymmetric HB_DBL_LENGTH bounds (hb_itemPutND, oracles hk293/hk297)
    movzwl %r13w, %r13d         # dec
    lea (%r12,%r13), %r14       # int_len + dec
    test %r13d, %r13d
    jz .Lf64_7b
    inc %r14                    # + the dot (only when dec > 0: hb_itemStrBuf)
.Lf64_7b:
    test %r10d, %r10d
    jz .Lf64_8
    inc %r14
.Lf64_8:  test %r13d, %r13d
    jz .Lf64_8b
    inc %r15
    add %r13, %r15              # width = length + 1 + dec (dec > 0 only)
.Lf64_8b:
    sub %r14, %r15              # pad (may be negative)
    # bounded compose scratch: total + pad must fit 456 bytes (Harbour
    # grows its print buffer dynamically; 63zc registered frontier)
    mov %r14, %rax
    test %r15, %r15
    jle .Lf64_70
    add %r15, %rax
.Lf64_70:
    cmp $456, %rax
    jbe .Lf64_71
    call hbc_f64range_error
.Lf64_71:
    test %r15, %r15
    jle .Lf64_9
.Lf64_12: movb $32, (%r9)
    inc %r9
    dec %r15d
    jnz .Lf64_12
.Lf64_9:  test %r10d, %r10d
    jz .Lf64_13
    movb $45, (%r9)
    inc %r9
.Lf64_13:
    # integer part
    mov -56(%rbp), %r11
    test %r11, %r11
    js .Lf64_14
    # copy e+1 digits from digit buf (leading zeros within 16-digit N are real)
    lea -80(%rbp), %rsi
    mov %r12, %rcx
    # skip (16 - int_len - max(frac...)) hmm: N always has exactly 16 digits incl leading zeros; int part = FIRST int_len of the 16 only when N>=10^(16-int_len)... For zero N this is wrong; zero handled: digits are "0000000000000000", int="0".
    mov -48(%rbp), %rax
    test %rax, %rax
    jnz .Lf64_15
    movb $48, (%r9)
    inc %r9
    jmp .Lf64_16
.Lf64_15: # nonzero: first int_len digits are the integer part (N in [1e15,1e16) so no leading zeros within int_len when int_len=e+1)
    # N carries only 16 significant digits: an int_len past 16 (runtime
    # division results like 2^63, oracle hk293) reads trailing ZEROS, not
    # bytes past the digit buffer.
    mov %r12, %rcx
    cmp $16, %rcx
    jle .Lf64_17
    mov $16, %rcx
.Lf64_17: movsbq (%rsi), %rdx
    mov %dl, (%r9)
    inc %rsi
    inc %r9
    dec %ecx
    jnz .Lf64_17
    mov %r12, %rcx
    sub $16, %rcx
    jle .Lf64_16
.Lf64_41: movb $48, (%r9)
    inc %r9
    dec %ecx
    jnz .Lf64_41
    jmp .Lf64_16
.Lf64_14: movb -160(%rbp), %al        # e<0: integer char ("0"; a round carry may have raised it to "1", hk301b)
    mov %al, (%r9)
    inc %r9
.Lf64_16:
    movzwl -40(%rbp), %r13d     # dec remaining (low 16 bits of the packed metadata)
    test %r13, %r13
    jz .Lf64_40                 # dec 0: no dot, no fraction (hb_itemStrBuf)
    movb $46, (%r9)             # '.'
    inc %r9
    # fraction sequence: [(-e-1) zeros if e<0] + [16 digits of N after int part] + zeros; take dec chars
    mov -56(%rbp), %r11
    # leading zeros for e<0
    test %r11, %r11
    jns .Lf64_18
    mov %r11, %rcx
    neg %rcx
    dec %rcx                    # -e-1
.Lf64_19: test %r13, %r13
    jz .Lf64_40
    test %rcx, %rcx
    jz .Lf64_18
    # 1-based fraction position of this leading zero: (-e-1) - rcx + 1;
    # a round carry may have raised one of them to '1' (hk301b 0.0999/1).
    mov -56(%rbp), %rax
    neg %rax
    dec %rax
    sub %rcx, %rax
    inc %rax
    movb $48, %dl
    cmpb -161(%rbp), %al
    jne .Lf64_19b
    movb $49, %dl
.Lf64_19b:
    mov %dl, (%r9)
    inc %r9
    dec %r13
    dec %rcx
    jmp .Lf64_19
.Lf64_18:
    # digits of N after the integer part: rsi points into digit buf
    lea -80(%rbp), %rsi
    xor %r12d, %r12d            # e<0: fraction starts at digit 0 of N
    mov -56(%rbp), %r11
    test %r11, %r11
    js .Lf64_21
    lea 1(%r11), %r12           # e>=0: skip the e+1 integer digits
.Lf64_21: add %r12, %rsi              # first fraction digit
    lea -64(%rbp), %rdx         # end of 16 digits (exclusive)
.Lf64_22: test %r13, %r13
    jz .Lf64_40
    cmp %rdx, %rsi
    jae .Lf64_23
    movsbq (%rsi), %rcx
    mov %cl, (%r9)
    inc %r9
    inc %rsi
    dec %r13
    jmp .Lf64_22
.Lf64_23: movb $48, (%r9)             # zero pad
    inc %r9
    dec %r13
    jmp .Lf64_22
.Lf64_40:
    # write: start -112, len = r9 - start
    lea -544(%rbp), %rax
    mov %r9, %rdx
    sub %rax, %rdx
    call hbc_print_str
    add $512, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    leave
    ret

"#;

// Win64 runtime helpers (ours): same internal convention as the linux ones
// (print_str takes ptr/len in rax/rdx, print_i64 takes the value in rax)
// but I/O and exit go through kernel32. Win64 calling convention: args in
// rcx, rdx, r8, r9, 32 bytes of shadow space, 16-byte stack alignment at
// every call. Only VOLATILE registers (rax, rcx, rdx, r8-r11) are touched;
// no callee-saved register needs preserving. Return values of kernel32
// calls are not checked (no I/O error handling in this PoC).
const WIN_HELPERS: &str = r#"
# hbc_print_str: %rax = ptr, %rdx = len. Prints the bytes + newline.
hbc_print_str:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rdx, -8(%rbp)
    mov %rax, -16(%rbp)
    mov $-11, %ecx
    call GetStdHandle
    mov %rax, %rcx
    mov -16(%rbp), %rdx
    mov -8(%rbp), %r8d
    lea -24(%rbp), %r9
    movq $0, 32(%rsp)
    call WriteFile
    leave
    ret

# hbc_print_nl / hbc_print_sep: the `?` leading newline / item separator.
hbc_print_nl:
    lea .Lnl(%rip), %rax
    mov $1, %edx
    jmp hbc_print_str
hbc_print_sep:
    lea .Lpad20(%rip), %rax
    mov $1, %edx
    jmp hbc_print_str

# hbc_str_eq: %rax = lhs ptr, %rdx = lhs len, %rcx = rhs ptr, %r8 = rhs len.
# Returns %rax = 1 when equal, 0 otherwise. Harbour default (SET EXACT
# OFF) `=`: compare over the length of the RIGHT operand, left read
# NUL-padded - "abcd" = "abc" is true, "abc" = "abcd" false, anything
# = "" true (probe b23). Harbour's exact `==` is not in this grammar.
# Leaf routine: no calls, only volatile registers.
hbc_str_eq:
    xor %r9, %r9
91:
    cmp %r8, %r9
    jae 92f
    movzbl (%rcx,%r9), %r10d
    cmp %rdx, %r9
    jae 94f
    movzbl (%rax,%r9), %r11d
    jmp 93f
94:
    xor %r11d, %r11d
93:
    cmp %r11b, %r10b
    jne 90f
    inc %r9
    jmp 91b
92:
    mov $1, %eax
    ret
90:
    xor %eax, %eax
    ret

# hbc_str_xeq: same inputs as hbc_str_eq. Returns %rax = 1 only when the
# lengths match AND every byte matches - Harbour's exact `==` (hk124:
# "a"=="a" .T., "a"=="a " .F., "a "=="a" .F.). Leaf routine: no calls,
# only volatile registers.
hbc_str_xeq:
    cmp %r8, %rdx
    jne 90f
    xor %r9, %r9
91:
    cmp %r8, %r9
    jae 92f
    movzbl (%rax,%r9), %r10d
    movzbl (%rcx,%r9), %r11d
    cmp %r11b, %r10b
    jne 90f
    inc %r9
    jmp 91b
92:
    mov $1, %eax
    ret
90:
    xor %eax, %eax
    ret

# hbc_str_cmp: same inputs as hbc_str_eq. Returns %rax = -1, 0 or 1.
# Harbour default (SET EXACT OFF) ordering: compare over the length of
# the RIGHT operand only; the left operand is read NUL-padded past its
# end, so "abc" < "abcd" is true but "abcd" > "abc" is false and
# "abcd" <= "abc" is true (xBase asymmetric prefix rule, probe b22).
# No collation, no Unicode awareness. Leaf: no calls, volatile regs.
hbc_str_cmp:
    xor %r9d, %r9d
95:
    cmp %r8, %r9
    jae 96f
    movzbl (%rcx,%r9), %r10d
    cmp %rdx, %r9
    jae 94f
    movzbl (%rax,%r9), %r11d
    jmp 93f
94:
    xor %r11d, %r11d
93:
    cmp %r11b, %r10b
    jb 98f
    ja 97f
    inc %r9
    jmp 95b
96:
    xor %eax, %eax
    ret
98:
    mov $1, %eax
    ret
97:
    mov $-1, %rax
    ret

# hbc_print_i64: %rax = signed value. Prints decimal + newline.
# The digit loop touches only volatile registers and calls nothing, so the
# Win64 call at the end is the only ABI-sensitive point.
hbc_print_i64:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    xor %r9d, %r9d
    test %rax, %rax
    jns 1f
    mov $1, %r9d
    neg %rax
1:
    lea -1(%rbp), %r10
    mov $10, %r8
2:
    xor %edx, %edx
    div %r8
    add $48, %dl
    mov %dl, (%r10)
    dec %r10
    test %rax, %rax
    jnz 2b
    test %r9d, %r9d
    jz 3f
    movb $45, (%r10)
    dec %r10
3:
    # Harbour `?` integer field (probes q1/q5/q6): positives right-align in
    # max(10, digits+1); negatives in 10 when they fit, 20 otherwise.
    lea 1(%r10), %rax
    mov %rbp, %rdx
    sub %r10, %rdx
    dec %rdx
    cmpb $45, (%rax)
    je 5f
    lea 1(%rdx), %rcx
    mov $10, %r8
    cmp %r8, %rcx
    cmovae %rcx, %r8
    jmp 6f
5:
    mov $10, %r8
    cmp %r8, %rdx
    jbe 6f
    mov $20, %r8
6:
    sub %rdx, %r8
    jle 7f
    mov %rax, -32(%rbp)
    mov %rdx, -40(%rbp)
    lea .Lpad20(%rip), %rax
    mov %r8, %rdx
    call hbc_print_str
    mov -32(%rbp), %rax
    mov -40(%rbp), %rdx
7:
    call hbc_print_str
    leave
    ret

# hbc_print_i64c: computed (runtime) i64 field (hk327/hk328): 10 within
# -999999999..9999999999, else 20; one digit-count test for either sign.
hbc_print_i64c:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    xor %r9d, %r9d
    test %rax, %rax
    jns 1f
    mov $1, %r9d
    neg %rax
1:
    lea -1(%rbp), %r10
    mov $10, %r8
2:
    xor %edx, %edx
    div %r8
    add $48, %dl
    mov %dl, (%r10)
    dec %r10
    test %rax, %rax
    jnz 2b
    test %r9d, %r9d
    jz 3f
    movb $45, (%r10)
    dec %r10
3:
    lea 1(%r10), %rax
    mov %rbp, %rdx
    sub %r10, %rdx
    dec %rdx
    mov $10, %r8
    cmp %r8, %rdx
    jbe 6f
    mov $20, %r8
6:
    sub %rdx, %r8
    jle 7f
    mov %rax, -32(%rbp)
    mov %rdx, -40(%rbp)
    lea .Lpad20(%rip), %rax
    mov %r8, %rdx
    call hbc_print_str
    mov -32(%rbp), %rax
    mov -40(%rbp), %rdx
7:
    call hbc_print_str
    leave
    ret

# hbc_print_dyn: %rax = tag, %rdx = payload. Prints NIL (no field width,
# probe n1) for tag 1, the raw string bytes for tag 2 (payload points at
# the bytes, length header at payload-8 - same layout as a hash key
# copy); otherwise the numeric payload via hbc_print_i64.
hbc_print_dyn:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    test %rax, %rax
    jz 8f
    cmp $2, %rax
    je 10f
    cmp $4, %rax
    je 10f
    cmp $3, %rax
    je 11f
    lea .Lnilmsg(%rip), %rax
    mov $3, %edx
    call hbc_print_str
    jmp 9f
8:  mov %rdx, %rax
    call hbc_print_i64c
    jmp 9f
10: mov %rdx, %rax
    mov -8(%rax), %rdx
    call hbc_print_str
    jmp 9f
11: lea .Lfmsg(%rip), %rax
    test %rdx, %rdx
    jz 12f
    lea .Ltmsg(%rip), %rax
12: mov $3, %edx
    call hbc_print_str
    jmp 9f
9:  leave
    ret

# hbc_dyn_to_i64: %rax = tag, %rdx = payload -> %rax = payload. NIL here is
# a Harbour type error; see the linux copy for the failure-mode note.
hbc_dyn_to_i64:
    test %rax, %rax
    jnz hbc_type_error
    mov %rdx, %rax
    ret

# hbc_dyn_to_log: %rax = tag, %rdx = payload -> %rax = 0/1 (the logical
# payload). Only tag 3 is a valid condition: NIL (hk266), integers
# (hk267) and strings are Harbour's type error (clean named exit 1).
hbc_dyn_to_log:
    # Only a logical cell is a valid condition (hk266/hk267); see the
    # linux copy for the failure-mode note.
    cmp $3, %rax
    jne hbc_dynlog_error
    mov %rdx, %rax
    ret

# hbc_dynlog_error: reached via a JUMP, so force 16-byte alignment
# before calling out (noreturn).
hbc_dynlog_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Llogmsg(%rip), %rax
    mov $39, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_dyn_eq: %rax/%rdx = lhs tag/payload, %rcx/%r8 = rhs tag/payload ->
# %rax = 1/0. NIL = NIL is .T.; NIL against a payload is .F. (probes n1-n3;
# string casilla x NIL casilla .F. in both directions - hk147). Two string
# casillas compare by CONTENT with Harbour's prefix rule over the right
# operand's length (hbc_str_eq tail call - hk145; before this fix they
# answered .T. by tag alone, a divergence). A string casilla against an
# integer casilla is Harbour's BASE/1071 "Argument error: =" (hk146,
# dialog hangs headless) - clean named exit 1 via hbc_dyncmp_eq_error,
# registered failure mode, not exact equivalence. Leaf routine.
hbc_dyn_eq:
    # tag 4 (owned string) behaves exactly like tag 2 (borrowed string)
    cmp $4, %rax
    jne 80f
    mov $2, %eax
80: cmp $4, %rcx
    jne 81f
    mov $2, %ecx
81: cmp %rcx, %rax
    jne 7f
    cmp $2, %rax
    je 6f
    cmp %r8, %rdx
    jne 8f
9:  mov $1, %eax
    ret
8:  xor %eax, %eax
    ret
6:  mov -8(%rdx), %r10
    mov -8(%r8), %r9
    mov %rdx, %rax
    mov %r8, %rcx
    mov %r9, %r8
    mov %r10, %rdx
    jmp hbc_str_eq
7:  test %rax, %rax
    je 71f
    cmp $2, %rax
    je 72f
    jmp 8b
71: cmp $2, %rcx
    je hbc_dyncmp_eq_error
    jmp 8b
72: cmp $1, %rcx
    je 8b
    jmp hbc_dyncmp_eq_error

# hbc_dynxcmp: %rax/%rdx = lhs tag/payload, %rcx/%r8 = rhs tag/payload,
# %r9d = operator (1=<, 2=>, 3=<=, 4=>=) -> %rax = -1/0/1 (signed).
# Ordering between two Dyn casillas (hk148): int x int numerically;
# string x string byte-wise over the right operand's length (hbc_str_cmp
# tail call); string x integer is Harbour's BASE/1073/1075/1074/1076 per
# operator (hk149-hk152 - dialogs hang headless): clean named exit 1 via
# the hbc_dyncmp_*_error stubs, registered failure modes, not exact
# equivalence. A NIL casilla in an ordering comparison is a Harbour type
# error: hbc_type_error (registered failure mode). Leaf routine.
hbc_dynxcmp:
    # tag 4 (owned string) behaves exactly like tag 2 (borrowed string)
    cmp $4, %rax
    jne 80f
    mov $2, %eax
80: cmp $4, %rcx
    jne 81f
    mov $2, %ecx
81: cmp %rcx, %rax
    jne 70f
    test %rax, %rax
    jnz 71f
    xor %eax, %eax
    cmp %r8, %rdx
    je 79f
    jl 77f
    mov $1, %eax
    ret
77: mov $-1, %rax
79: ret
71: cmp $2, %rax
    je 72f
    jmp hbc_type_error
72: mov -8(%rdx), %r10
    mov -8(%r8), %r11
    mov %rdx, %rax
    mov %r8, %rcx
    mov %r11, %r8
    mov %r10, %rdx
    jmp hbc_str_cmp
70: cmp $1, %rax
    je hbc_type_error
    cmp $1, %rcx
    je hbc_type_error
    cmp $1, %r9d
    je hbc_dyncmp_lt_error
    cmp $2, %r9d
    je hbc_dyncmp_gt_error
    cmp $3, %r9d
    je hbc_dyncmp_le_error
    jmp hbc_dyncmp_ge_error

# hbc_dynxeq_dd: %rax/%rdx = lhs tag/payload, %rcx/%r8 = rhs tag/payload ->
# %rax = 1/0. Harbour's `==` between casillas (hk132/hk133/hk138/hk140):
# NIL x NIL .T., NIL x payload .F., number x number by value, string x
# string the EXACT byte compare (length header at payload-8). Mixed
# number x string raises Harbour's BASE/1070 (hk139/hk139b/hk139c -
# dialog hangs headless): a clean named exit 1, registered failure mode,
# not exact equivalence. Leaf routine: the error path is a noreturn stub.
hbc_dynxeq_dd:
    # tag 4 (owned string) behaves exactly like tag 2 (borrowed string)
    cmp $4, %rax
    jne 80f
    mov $2, %eax
80: cmp $4, %rcx
    jne 81f
    mov $2, %ecx
81: cmp %rcx, %rax
    jne 5f
    cmp $2, %rax
    je 2f
    cmp $1, %rax
    je 9f
    cmp %r8, %rdx
    jne 8f
9:  mov $1, %eax
    ret
2:  mov -8(%rdx), %r10
    cmp -8(%r8), %r10
    jne 8f
    xor %r9, %r9
3:  cmp %r10, %r9
    jae 9b
    movzbl (%rdx,%r9), %r11d
    movzbl (%r8,%r9), %eax
    cmp %eax, %r11d
    jne 8f
    inc %r9
    jmp 3b
5:  cmp $1, %rax
    je 8f
    cmp $1, %rcx
    je 8f
    jmp hbc_dynxeq_error
8:  xor %eax, %eax
    ret

# hbc_type_error: NIL used as a number at runtime. Reached via a JUMP from
# hbc_dyn_to_i64, so force 16-byte alignment before calling out (noreturn).
hbc_type_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ltypemsg(%rip), %rax
    mov $33, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_bound_error: array index outside 1..=n at runtime (noreturn). Same
# wording as the linux helper; exit code 1 via ExitProcess.
hbc_bound_error:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    lea .Lboundmsg(%rip), %rax
    mov $26, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_div0_error: division by zero at runtime (noreturn). Same wording as
# the linux helper; exit code 1 via ExitProcess.
hbc_div0_error:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    lea .Ldiv0msg(%rip), %rax
    mov $24, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_inc_overflow:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lincmsg(%rip), %rax
    mov $50, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_f64range_error: same wording as the linux helper; exit code 1.
hbc_f64range_error:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    lea .Lf64rangemsg(%rip), %rax
    mov $32, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_round: %xmm0 = n, %rdi = d (i64, sign kept) -> %xmm0 = rounded value,
# %rdi = PACKED metadata (dec low16 | length<<16). Exact hb_numRound
# transcription (src/common/hbstr.c; HB_NUM_PRECISION off;
# HB_DBLFL_PREC_FACTOR = 1.0000000000000002 active - hbdefs.h:665):
# c = n [* or /] dPow * 10; c +/- 5 by sign of n; c / 10; c * factor;
# trunc toward zero; back-scale by dPow. dec = max(d, 0); length = the
# asymmetric HB_DBL_LENGTH rule. Zero flows through uniformly.
hbc_round:
    mov %rdi, %r8
    test %rdi, %rdi
    js .Lround_neg
    cmp $15, %rdi
    jg hbc_round_range_error
    lea .Lround_pow10(%rip), %rax
    movsd (%rax,%rdi,8), %xmm1
    mulsd %xmm1, %xmm0
    jmp .Lround_common
.Lround_neg:
    cmp $-15, %rdi
    jl hbc_round_range_error
    neg %rdi
    lea .Lround_pow10(%rip), %rax
    movsd (%rax,%rdi,8), %xmm1
    divsd %xmm1, %xmm0
.Lround_common:
    movsd .Lround_ten(%rip), %xmm2
    mulsd %xmm2, %xmm0
    xorpd %xmm3, %xmm3
    ucomisd %xmm3, %xmm0
    jb .Lround_sub5
    addsd .Lround_five(%rip), %xmm0
    jmp .Lround_div
.Lround_sub5:
    subsd .Lround_five(%rip), %xmm0
.Lround_div:
    divsd %xmm2, %xmm0
    mulsd .Lround_factor(%rip), %xmm0
    roundsd $3, %xmm0, %xmm0
    test %r8, %r8
    js .Lround_mulback
    divsd %xmm1, %xmm0
    jmp .Lround_meta
.Lround_mulback:
    mulsd %xmm1, %xmm0
.Lround_meta:
    xor %edi, %edi
    test %r8, %r8
    js .Lround_len
    mov %r8, %rdi
.Lround_len:
    mov $10, %eax
    movsd .Lround_lenmax(%rip), %xmm2
    ucomisd %xmm2, %xmm0
    ja .Lround_l20
    xorpd %xmm2, %xmm2
    subsd %xmm0, %xmm2
    movsd .Lround_lenmin(%rip), %xmm3
    ucomisd %xmm3, %xmm2
    jbe .Lround_l10
.Lround_l20:
    mov $20, %eax
.Lround_l10:
    shl $16, %rax
    or %rax, %rdi
    ret

# hbc_round_range_error: same wording as the linux helper; exit code 1.
hbc_round_range_error:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    lea .Lroundmsg(%rip), %rax
    mov $30, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# Release only logically freed blocks, not live registry entries.
hbc_str_cache_flush:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    sub $48, %rsp
    xor %r12d, %r12d
    lea hbc_str_cache(%rip), %r13
.Lcache_flush_w_next:
    mov (%r13,%r12,8), %r8
    movq $0, (%r13,%r12,8)
    test %r8, %r8
    jz .Lcache_flush_w_skip
    mov %r8, -32(%rbp)
    call GetProcessHeap
    mov %rax, %rcx
    xor %edx, %edx
    mov -32(%rbp), %r8
    call HeapFree
    test %rax, %rax
    jz hbc_os_bad
.Lcache_flush_w_skip:
    inc %r12
    cmp $8, %r12
    jb .Lcache_flush_w_next
    add $48, %rsp
    pop %r13
    pop %r12
    pop %rbp
    ret

# ---- dynamic array heap (kernel32 Heap API) ----
# hbc_alloc: rdi = bytes -> rax = base. HeapAlloc failure returns NULL.
hbc_alloc:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    mov %rdi, %r8
    mov %rdi, 32(%rsp)
    call GetProcessHeap
    mov %rax, %rcx
    xor %edx, %edx
    call HeapAlloc
    test %rax, %rax
    jz hbc_oom
@REG_ALLOC_W@    incq hbc_mem_allocs(%rip)
    leave
    ret

# hbc_oom / hbc_asize_neg: print the message, exit 1 (noreturn)
# Entered via a conditional JUMP, not a call: the stack alignment at entry
# is the caller's, so force 16-byte alignment explicitly before calling out.
hbc_oom:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Loommsg(%rip), %rax
    mov $14, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_asize_neg:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lasizenegmsg(%rip), %rax
    mov $21, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_len_error: len() of a NIL slot (noreturn) - see the linux copy.
hbc_len_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Llenerrmsg(%rip), %rax
    mov $20, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_param_error: see the linux copy.
hbc_param_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lparamerrmsg(%rip), %rax
    mov $22, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_aadd_error / hbc_asize_error: see the linux copies.
hbc_snil_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lsnilmsg(%rip), %rax
    mov $47, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_eq_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpeqmsg(%rip), %rax
    mov $18, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_ne_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpnemsg(%rip), %rax
    mov $19, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_dynxeq_error: numeric casilla compared against a string under `==`
# (noreturn). Harbour raises BASE/1070 "Argument error: ==" (hk139/
# hk139b/hk139c, dialogs that hang headless) - clean named exit 1 here,
# registered failure mode, same error condition.
hbc_dynxeq_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldynxeqmsg(%rip), %rax
    mov $19, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_lt_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpltmsg(%rip), %rax
    mov $18, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_gt_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpgtmsg(%rip), %rax
    mov $18, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_le_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmplemsg(%rip), %rax
    mov $19, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_dyncmp_ge_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Ldyncmpgemsg(%rip), %rax
    mov $19, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_arracc_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Larraccmsg(%rip), %rax
    mov $29, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

hbc_aadd_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Laadderrmsg(%rip), %rax
    mov $21, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess
hbc_asize_error:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Lasizeerrmsg(%rip), %rax
    mov $22, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_free: rdi = data pointer (non-null), rsi = element size (unused:
# HeapFree needs the base pointer, not the length).
hbc_free:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
@REG_FREE_W@    sub $8, %rdi
    mov %rdi, %r8
    call GetProcessHeap
    mov %rax, %rcx
    xor %edx, %edx
    call HeapFree
    # HeapFree result: nonzero on success - a registry match alone does
    # not prove the OS released the block.
    test %rax, %rax
    jz hbc_os_bad
    incq hbc_mem_frees(%rip)
    leave
    ret

# hbc_freestr: rdi = string data pointer (non-null). String layout:
# capacity at -16(%rdi), length at -8(%rdi); HeapFree needs only the
# base (rdi-16), but the registry snippet validates 16 + cap.
hbc_freestr:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
@REG_SFREE_W@    cmpq $256, -16(%rdi)
    ja .Lstr_release_w
    mov -16(%rdi), %rcx
    and $7, %ecx
    lea hbc_str_cache(%rip), %r11
    cmpq $0, (%r11,%rcx,8)
    jne .Lstr_release_w
    lea -16(%rdi), %rax
    mov %rax, (%r11,%rcx,8)
    incq hbc_mem_frees(%rip)
    leave
    ret
.Lstr_release_w:
    sub $16, %rdi
    mov %rdi, %r8
    call GetProcessHeap
    mov %rax, %rcx
    xor %edx, %edx
    call HeapFree
    test %rax, %rax
    jz hbc_os_bad
    incq hbc_mem_frees(%rip)
    leave
    ret

# hbc_hfreeblock: rdi = hash block data pointer (non-null). Frees the
# whole block: 16-byte header [flags @0][capacity @8] + entries, so the
# block base is rdi-16 (HeapFree needs the base, not the length; the
# registry snippet computes and checks the recorded size).
hbc_hfreeblock:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
@REG_HFREE_W@    sub $16, %rdi
    mov %rdi, %r8
    call GetProcessHeap
    mov %rax, %rcx
    xor %edx, %edx
    call HeapFree
    test %rax, %rax
    jz hbc_os_bad
    incq hbc_mem_frees(%rip)
    leave
    ret

@REG_BAD_W@# hbc_os_bad: HeapFree reported failure (noreturn). Entered via JUMP.
hbc_os_bad:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $48, %rsp
    lea .Losbadmsg(%rip), %rax
    mov $31, %edx
    call hbc_print_str
    mov $1, %ecx
    call ExitProcess

# hbc_free2: rdi = outer data pointer (non-null), rsi = outer length.
hbc_free2:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $56, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    xor %r13, %r13
71: cmp %r12, %r13
    jge 72f
    mov %r13, %rax
    shl $4, %rax
    mov (%rbx,%rax), %rdi
    test %rdi, %rdi
    jz 73f
    mov $16, %esi
    call hbc_free
73: inc %r13
    jmp 71b
72: mov %rbx, %rdi
    mov $16, %esi
    call hbc_free
    add $56, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_rfree: rdi = block of (ptr,len) pairs, rsi = pair count, rdx =
# pair-levels (>= 2). Same generic recursive free as the SysV helper.
hbc_rfree:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    sub $48, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r14
    xor %r13, %r13
71: cmp %r12, %r13
    jge 72f
    mov %r13, %rax
    shl $4, %rax
    mov (%rbx,%rax), %rdi
    test %rdi, %rdi
    jz 73f
    mov 8(%rbx,%rax), %rsi
    cmp $2, %r14
    je 74f
    lea -1(%r14), %rdx
    call hbc_rfree
    jmp 73f
74: call hbc_free2
73: inc %r13
    jmp 71b
72: mov %rbx, %rdi
    mov $16, %esi
    call hbc_free
    add $48, %rsp
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_aadd: rdi = slot address (ptr,len), rsi = element size (8 or 16),
# rdx = pointer to the new element. A failed allocation leaves the old
# block and the slot untouched.
hbc_aadd:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    sub $48, %rsp
    mov %rdi, %rbx
    mov %rsi, %r14
    mov %rdx, %r12
    mov (%rbx), %r13
    xor %ecx, %ecx
    test %r13, %r13
    jz 51f
    mov -8(%r13), %rcx
51: cmp 8(%rbx), %rcx
    jg 54f
    mov $4, %eax
    test %rcx, %rcx
    jz 52f
    lea (%rcx,%rcx), %rax
52: mov $0x2000000000000000, %rdx
    cmp %rdx, %rax
    jae hbc_oom
    mov %rcx, -40(%rbp)
    mov %rax, -48(%rbp)
    mov %rax, %rdi
    imul %r14, %rdi
    jo hbc_oom
    add $8, %rdi
    jc hbc_oom
    call hbc_alloc
    mov -48(%rbp), %rdx
    mov %rdx, (%rax)
    test %r13, %r13
    jz 53f
    mov 8(%rbx), %r8
    xor %r9, %r9
55: cmp %r8, %r9
    jge 56f
    mov %r9, %r10
    imul %r14, %r10
    mov (%r13,%r10), %rcx
    mov %rcx, 8(%rax,%r10)
    cmp $16, %r14
    jne 57f
    mov 8(%r13,%r10), %rcx
    mov %rcx, 16(%rax,%r10)
57: inc %r9
    jmp 55b
56: mov %rax, -40(%rbp)
    mov %r13, %rdi
    mov %r14, %rsi
    call hbc_free
    mov -40(%rbp), %rax
53: add $8, %rax
    mov %rax, (%rbx)
    mov %rax, %r13
54: mov 8(%rbx), %rcx
    mov %rcx, %r10
    imul %r14, %r10
    mov (%r12), %rax
    mov %rax, (%r13,%r10)
    cmp $16, %r14
    jne 58f
    mov 8(%r12), %rax
    mov %rax, 8(%r13,%r10)
58: inc %rcx
    mov %rcx, 8(%rbx)
    add $48, %rsp
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# hbc_asize: rdi = slot address, rsi = new length, rdx = element size,
# rcx = deep flag (1: free removed children on shrink). Grown i64 slots
# read NIL (probe e1); a DArr2 grows with the empty (null, 0) child.
hbc_asize:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $56, %rsp
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r14
    mov %rcx, %r15
    test %r12, %r12
    js hbc_asize_neg
    mov 8(%rbx), %rcx
    cmp %rcx, %r12
    jle 59f
    mov (%rbx), %r13
    xor %edx, %edx
    test %r13, %r13
    jz 61f
    mov -8(%r13), %rdx
61: cmp %rdx, %r12
    jle 63f
    mov $4, %eax
    test %rdx, %rdx
    jz 62f
    lea (%rdx,%rdx), %rax
62: cmp %rax, %r12
    jle 64f
    mov %r12, %rax
64: mov $0x2000000000000000, %r8
    cmp %r8, %rax
    jae hbc_oom
    mov %rdx, -48(%rbp)
    mov %rax, -56(%rbp)
    mov %rax, %rdi
    imul %r14, %rdi
    jo hbc_oom
    add $8, %rdi
    jc hbc_oom
    call hbc_alloc
    mov -56(%rbp), %rdx
    mov %rdx, (%rax)
    mov 8(%rbx), %r8
    test %r13, %r13
    jz 65f
    xor %r9, %r9
66: cmp %r8, %r9
    jge 69f
    mov %r9, %r10
    imul %r14, %r10
    mov (%r13,%r10), %rcx
    mov %rcx, 8(%rax,%r10)
    cmp $16, %r14
    jne 60f
    mov 8(%r13,%r10), %rcx
    mov %rcx, 16(%rax,%r10)
60: inc %r9
    jmp 66b
69: mov %rax, -48(%rbp)
    mov %r13, %rdi
    mov %r14, %rsi
    call hbc_free
    mov -48(%rbp), %rax
65: add $8, %rax
    mov %rax, (%rbx)
    mov %rax, %r13
63: mov 8(%rbx), %rcx
67: cmp %r12, %rcx
    jge 68f
    mov %rcx, %r10
    shl $4, %r10
    cmp $1, %r15
    je 79f
    cmp $3, %r15
    je 79f
    # flat arrays and arrays of strings grow with NIL {1, 0} (probe e1;
    # hk13/hk14 for the string array: grown casillas read NIL)
    movq $1, (%r13,%r10)
    movq $0, 8(%r13,%r10)
    jmp 74f
79: # a DArr2 grows with the empty child (null, 0) - m-probes, unchanged
    movq $0, (%r13,%r10)
    movq $0, 8(%r13,%r10)
74: inc %rcx
    jmp 67b
68: mov %r12, 8(%rbx)
    jmp 75f
59: # shrink: kind 2 frees the removed string copies, kind 1 the children.
# The counter lives on the stack: kernel32 may clobber the volatile r9
# across the hbc_free call.
    cmp $2, %r15
    je 80f
    cmp $3, %r15
    je 83f
    test %r15, %r15
    jz 76f
    mov (%rbx), %r13
    mov %r12, -48(%rbp)
77: mov -48(%rbp), %r9
    cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    mov (%r13,%r10), %rdi
    test %rdi, %rdi
    jz 78f
    mov $16, %esi
    call hbc_free
78: incq -48(%rbp)
    jmp 77b
80: mov (%rbx), %r13
    mov %r12, -48(%rbp)
81: mov -48(%rbp), %r9
    cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    cmpq $2, (%r13,%r10)
    jne 82f
    mov 8(%r13,%r10), %rdi
    test %rdi, %rdi
    jz 82f
    call hbc_freestr
82: incq -48(%rbp)
    jmp 81b
    # kind 3: three levels - recursive free of removed children
    # (hbc_rfree depth 2); same stack-counter pattern as kind 1.
83: mov (%rbx), %r13
    mov %r12, -48(%rbp)
84: mov -48(%rbp), %r9
    cmp 8(%rbx), %r9
    jge 76f
    mov %r9, %r10
    shl $4, %r10
    mov (%r13,%r10), %rdi
    test %rdi, %rdi
    jz 85f
    mov 8(%r13,%r10), %rsi
    mov $2, %edx
    call hbc_rfree
85: incq -48(%rbp)
    jmp 84b
76: mov %r12, 8(%rbx)
75: add $56, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

    .data
    .align 8
hbc_mem_allocs: .quad 0
hbc_mem_frees:  .quad 0
hbc_str_cache: .zero 64
@REG_DATA@    .text
"#;

#[derive(Clone, Copy, PartialEq)]
enum Target { Linux, Windows }

#[path = "llvm_scalar.rs"]
mod llvm_scalar;
fn main() {
    let args: Vec<String> = env::args().collect();
    let mut pos: Vec<&String> = Vec::new();
    let mut target = Target::Linux;
    let mut incdirs: Vec<String> = Vec::new();
    let mut instrument = false;
    let mut llvm = false;
    let mut llvm_trace = true;
    let mut ai = 1;
    while ai < args.len() {
        let a = &args[ai];
        match a.as_str() {
            "--target=linux" => target = Target::Linux,
            "--target=windows" => target = Target::Windows,
            "--instrument" => instrument = true,
            "--experimental-llvm" => llvm = true,
            "--experimental-llvm-no-trace" => {llvm = true; llvm_trace = false;},
            "-I" => { ai += 1; incdirs.push(args.get(ai).expect("-I needs a directory").clone()); }
            _ if a.starts_with("-I") => incdirs.push(a[2..].to_string()),
            _ if a.starts_with("--") => { eprintln!("usage: hbc <input.hb> <output.s> [--target=linux|windows] [-I dir]..."); process::exit(2); }
            _ => pos.push(a),
        }
        ai += 1;
    }
    if pos.len() != 2 {
        eprintln!("usage: hbc <input.hb> <output.s> [--target=linux|windows] [-I dir]...");
        process::exit(2);
    }
    if llvm && instrument { eprintln!("error: LLVM scalar: --instrument is not supported; registry checks must not be silently omitted"); process::exit(1); }
    // Preprocessing runs automatically on every compile. Errors cite the
    // line in the ORIGINAL file for the main input; lines injected by an
    // #include report against that include file.
    let mut pre = pp::Pp::new(incdirs, matches!(target, Target::Windows));
    let mut src = String::new();
    if let Err(m) = pp::process(pos[0], &mut pre, &mut src, 0) {
        eprintln!("error: {}", m);
        process::exit(1);
    }

    TRACE_ORIGINS.with(|m| *m.borrow_mut() = pre.origins.clone());
    PROC_LINES.with(|m| *m.borrow_mut() = pre.end_lines.clone());
    let prog = match parse(&src) {
        Ok(p) => p,
        Err(msg) => { eprintln!("error: {}", msg); process::exit(1); }
    };
    if !prog.classes.is_empty() || !prog.methods.is_empty() {
        eprintln!("error: classes are not in this increment yet (the parser landed; the runtime representation is pending the user's decision)");
        process::exit(1);
    }
    let mut funcs = prog.funcs;

    // `@x` prescan (hk216 family), syntactic over the whole program: which
    // parameter positions each function receives by reference (call sites
    // come AFTER the callee under definition-before-use, so this must be
    // collected before the per-function check loop), which local names each
    // function passes by reference (they need owned-capable slots), and the
    // exact set of (callee, mask) variants codegen must emit.
    fn scan_byref_expr(e: &Expr, cur: &str, params: &mut std::collections::HashMap<String, Vec<usize>>, names: &mut std::collections::HashMap<String, std::collections::HashSet<String>>, variants: &mut std::collections::BTreeSet<(String, Vec<bool>)>) {
        if let Expr::Call(id, args) = e {
            let mask: Vec<bool> = args.iter().map(|a| matches!(a, Expr::ByRef(_))).collect();
            if mask.iter().any(|b| *b) && !id.starts_with("hb_") && !is_builtin(id, "len") && !is_builtin(id, "eval") {
                let pos: Vec<usize> = (0..args.len()).filter(|i| mask[*i]).collect();
                params.entry(id.clone()).or_default().extend(pos);
                for (i, a) in args.iter().enumerate() {
                    if mask[i] {
                        if let Expr::ByRef(vn) = a { names.entry(cur.to_string()).or_default().insert(vn.clone()); }
                    }
                }
                variants.insert((id.clone(), mask));
            }
        }
        match e {
            Expr::Seq(es) => { for x in es { scan_byref_expr(x, cur, params, names, variants); } }
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) | Expr::LAnd(a, b) | Expr::LOr(a, b) => { scan_byref_expr(a, cur, params, names, variants); scan_byref_expr(b, cur, params, names, variants); }
            Expr::LNot(a) => scan_byref_expr(a, cur, params, names, variants),
            Expr::Call(_, args) => { for a in args { if !matches!(a, Expr::ByRef(_)) { scan_byref_expr(a, cur, params, names, variants); } } }
            Expr::Index(_, a) => scan_byref_expr(a, cur, params, names, variants),
            Expr::Index2(_, a, b) => { scan_byref_expr(a, cur, params, names, variants); scan_byref_expr(b, cur, params, names, variants); }
            Expr::Index3(_, a, b, c) => { scan_byref_expr(a, cur, params, names, variants); scan_byref_expr(b, cur, params, names, variants); scan_byref_expr(c, cur, params, names, variants); }
            Expr::Index4(_, a, b, c, d) => { scan_byref_expr(a, cur, params, names, variants); scan_byref_expr(b, cur, params, names, variants); scan_byref_expr(c, cur, params, names, variants); scan_byref_expr(d, cur, params, names, variants); }
            Expr::ArrLit(es) => { for x in es { scan_byref_expr(x, cur, params, names, variants); } }
            Expr::HashLit(ps) => { for (k, v) in ps { scan_byref_expr(k, cur, params, names, variants); scan_byref_expr(v, cur, params, names, variants); } }
            Expr::BlockLit(_, _, body) => { for x in body { scan_byref_expr(x, cur, params, names, variants); } }
            Expr::Send(o, _, args) => { scan_byref_expr(o, cur, params, names, variants); for a in args { scan_byref_expr(a, cur, params, names, variants); } }
            _ => {}
        }
    }
    fn scan_byref_stmts(stmts: &[Stmt], cur: &str, params: &mut std::collections::HashMap<String, Vec<usize>>, names: &mut std::collections::HashMap<String, std::collections::HashSet<String>>, variants: &mut std::collections::BTreeSet<(String, Vec<bool>)>) {
        for st in stmts {
            match st {
                Stmt::Local(_, _, e) | Stmt::Assign(_, _, e) | Stmt::Ret(_, Some(e)) | Stmt::CallStmt(_, e) => scan_byref_expr(e, cur, params, names, variants),
                Stmt::Print(_, es, _) => { for e in es { scan_byref_expr(e, cur, params, names, variants); } }
                Stmt::If(_, c, t, el) => { scan_byref_expr(c, cur, params, names, variants); scan_byref_stmts(t, cur, params, names, variants); scan_byref_stmts(el, cur, params, names, variants); }
                Stmt::While(_, c, b) => { scan_byref_expr(c, cur, params, names, variants); scan_byref_stmts(b, cur, params, names, variants); }
                Stmt::For(_, _, a, b, _, body) => { scan_byref_expr(a, cur, params, names, variants); scan_byref_expr(b, cur, params, names, variants); scan_byref_stmts(body, cur, params, names, variants); }
                Stmt::ForEach(_, _, c, body) => { scan_byref_expr(c, cur, params, names, variants); scan_byref_stmts(body, cur, params, names, variants); }
                _ => {}
            }
        }
    }
    let mut byref_params: std::collections::HashMap<String, Vec<usize>> = std::collections::HashMap::new();
    let mut byref_locals: std::collections::HashMap<String, std::collections::HashSet<String>> = std::collections::HashMap::new();
    let mut byref_variants: std::collections::BTreeSet<(String, Vec<bool>)> = std::collections::BTreeSet::new();
    for f in &funcs {
        scan_byref_stmts(&f.stmts, &f.name, &mut byref_params, &mut byref_locals, &mut byref_variants);
    }

    // Pass 1: semantic analysis - types, ownership/move, signatures.
    // ORDER-INDEPENDENT inference (oracle hk253: Harbour resolves calls
    // to functions defined later in the file, including mutual and self
    // recursion): `view` always holds a COMPLETE signature table - every
    // function in the file, seeded with placeholder types (i64 params,
    // void return) before round 1. Each round re-infers every function
    // from the AST against `view`; a function's freshly computed entry
    // lands in `cur` and is only read by the NEXT round. Errors from a
    // round that is not yet converged may depend on placeholder types,
    // so they are collected and only emitted by the round that proves
    // convergence (its checks ran against the stable table).
    // Termination is justified by finite progress, not a guessed round
    // count: an entry only moves placeholder -> concrete and then UP the
    // finite pin-merge lattice (i64 < Dyn, DArr < DArr2 < DArr3 < DArr4,
    // ...), and the per-call-site borrowed/arr_moved flags only flip
    // false -> true, so every non-converged round strictly increases the
    // summed lattice height and the round count is bounded by `cap`
    // below. Reaching the cap means the monotonicity argument broke -
    // an explicit diagnostic, never a silent assumption.
    let cap = 2 + 4 * funcs.iter().map(|f| f.params.len() + 1).sum::<usize>();
    // A single inline-IF return can carry its own concrete base-case
    // anchor before recursive signatures exist (stock recursiv.prg).
    // This is ONLY a provisional scalar seed: every arm and every call
    // must pass ordinary type checking against the converged table before
    // codegen. Do not seed unknown calls/owned values or mixed return sites.
    fn inline_ret_seed(f: &Func) -> Option<Ty> {
        fn literal(e: &Expr) -> Option<Ty> {
            match e {
                Expr::Int(_) => Some(Ty::I64),
                Expr::Float(..) | Expr::FloatV(..) => Some(Ty::F64),
                Expr::Log(_) => Some(Ty::Bool),
                Expr::Str(_) => Some(Ty::Str),
                _ => None,
            }
        }
        let mut returns = Vec::new();
        fn collect<'a>(ss: &'a [Stmt], out: &mut Vec<Option<&'a Expr>>) {
            for s in ss {
                match s {
                    Stmt::Ret(_, e) => out.push(e.as_ref()),
                    Stmt::If(_, _, a, b) => { collect(a, out); collect(b, out); }
                    Stmt::While(_, _, b) | Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => collect(b, out),
                    _ => {}
                }
            }
        }
        collect(&f.stmts, &mut returns);
        if returns.len() != 1 { return None; }
        if let Some(Expr::Call(id, args)) = returns[0] {
            if is_builtin(id, "iif") && args.len() == 3 {
                return match (literal(&args[1]), literal(&args[2])) {
                    (Some(a), Some(b)) if a == b => Some(a),
                    (Some(a), None) | (None, Some(a)) => Some(a),
                    _ => None,
                };
            }
        }
        None
    }
    let mut view: Vec<Sig> = funcs.iter().map(|f| Sig {
        name: f.name.clone(),
        borrowed: vec![false; f.params.len()],
        arr_moved: vec![false; f.params.len()],
        params: vec![Ty::I64; f.params.len()],
        ret: if f.name == "main" { None } else { inline_ret_seed(f) },
        inferred: vec![false; f.params.len()],
        arg_ev: vec![None; f.params.len()],
        nil_ev: vec![false; f.params.len()],
    }).collect();
    let mut sigs: Vec<Sig>;
    let mut has_main = false;
    let mut round = 0usize;
    loop {
        round += 1;
        if round > cap {
            eprintln!("error: internal: type inference did not converge after {} rounds (monotone-refinement bound exceeded; please report this input)", cap);
            process::exit(1);
        }
        let mut cur: Vec<Sig> = Vec::with_capacity(funcs.len());
        let before = view.clone();
        // Argument evidence (arg_ev) is NOT reset between rounds: the
        // only recorded fact is "some call site passed a float", and
        // float-typedness is monotone across the fixpoint (literals and
        // float locals are stable; a callee's float return only flips
        // I64 -> F64 as its own parameter merges upward), so a sticky
        // recording cannot rest on a stale mid-convergence reading.
        let mut first_err: Option<String> = None;
        let mut first_pin_err: Option<String> = None;
        for (fi, f) in funcs.iter_mut().enumerate() {
            if f.name == "main" { has_main = true; }
            // Pin parameter types. On failure, keep the PREVIOUS view entry
            // (ains.prg diagnosis): resetting to i64 placeholders made the
            // table RETREAT down the lattice, so a stable pin conflict
            // (recursive array-parameter call, line-77 "array parameters
            // are not in this increment") oscillated I64 <-> DArr until the
            // round cap fired as an internal error. Carrying the view entry
            // forward keeps the table monotone: the conflict recurs every
            // round, the round converges, and the converged round reports
            // the pin error by name. (The body-first contract still holds:
            // the pin error is reported only when the body checks clean.)
            let (ptys, inferred, pin_err) = match pin_params(f, &view) {
                Ok((pin, e)) => {
                    let inf: Vec<bool> = pin.iter().map(|x| x.is_some()).collect();
                    (pin.into_iter().map(|x| x.unwrap_or(Ty::I64)).collect(), inf, e)
                }
                Err(m) => (view[fi].params.clone(), view[fi].inferred.clone(), Some(m)),
            };
            // Parameters enter the frame as owned locals: integer arguments copy,
            // string arguments move (callers hand over ownership). A parameter
            // some caller passes as `@p` is BORROWED from that caller instead
            // (hk216): the flag rejects moving it out (the caller keeps it).
            let brp: std::collections::HashSet<usize> = byref_params.get(&f.name).cloned().unwrap_or_default().into_iter().collect();
            let byref_names: std::collections::HashSet<String> = byref_locals.get(&f.name).cloned().unwrap_or_default();
            let dyn_names = prescan_dyn(f, &view, &ptys);
            // Direct self-recursion retry (fib piece). A recursive call
            // that precedes every RETURN of its own function deadlocks
            // the fixpoint on "`f` never returns a value" (fib.prg):
            // the body check aborts at the call, no return is reached,
            // the table converges with the error still pending. When the
            // unaided check fails with EXACTLY that error naming THIS
            // function, retry the body once with the function's own
            // table entry seeded by the return its checked prefix
            // already accumulated (early-return shapes keep their
            // precise inference) or Dyn when no return was reached (a
            // tagged return; the exact type is not provable without
            // running). A failed retry restores the entry and reports
            // the ORIGINAL error, so pinned rejections keep their
            // diagnostic (t1004/t1005); mutual recursion never names
            // itself here and keeps the limit (t1360). The fixpoint
            // re-verifies the seeded entry against the body's recomputed
            // return on the next round, so a wrong seed cannot
            // stabilize. Call-site flags accumulated in `view` by the
            // aborted pass are monotone and stay (same discipline as
            // mid-round errors elsewhere).
            let mut env: Vec<Local> = Vec::new();
            for (i, p) in f.params.iter().enumerate() {
                env.push(Local { name: p.clone(), ty: ptys[i], moved: false, ro: false, byref: brp.contains(&i) });
            }
            let mut ret = None;
            let mut top_exits: Vec<Vec<bool>> = Vec::new();
            CUR_FN.with(|c| *c.borrow_mut() = f.name.clone());
            let mut res = check_stmts(&f.stmts, &mut env, &mut view, &mut ret, None, &mut top_exits, &dyn_names, &byref_names);
            if let Err(m) = &res {
                let self_deadlock = m.contains("never returns a value")
                    && m.contains(&format!("`{}`", f.name));
                if self_deadlock {
                    let first = (m.clone(), ret);
                    let saved = view[fi].ret;
                    view[fi].ret = ret.or(Some(Ty::Dyn));
                    let mut env2: Vec<Local> = Vec::new();
                    for (i, p) in f.params.iter().enumerate() {
                        env2.push(Local { name: p.clone(), ty: ptys[i], moved: false, ro: false, byref: brp.contains(&i) });
                    }
                    let mut ret2 = None;
                    let mut top_exits2: Vec<Vec<bool>> = Vec::new();
                    let res2 = check_stmts(&f.stmts, &mut env2, &mut view, &mut ret2, None, &mut top_exits2, &dyn_names, &byref_names);
                    if res2.is_ok() {
                        res = res2;
                        ret = ret2;
                        top_exits = top_exits2;
                    } else {
                        view[fi].ret = saved;
                        res = Err(first.0);
                        ret = first.1;
                    }
                }
            }
            f.dyn_names = dyn_names;
            if let Err(m) = res {
                if first_err.is_none() { first_err = Some(m); }
            }
            if f.name == "main" {
                if has_value_return(&f.stmts) && first_err.is_none() {
                    first_err = Some("main must end with `return` or `return nil` in this PoC".to_string());
                }
                ret = None; // main's own `return nil` is NIL, never a usable value
            }
            if let Some(m) = pin_err {
                if std::env::var("HBC_INFER_TRACE").is_ok() {
                    eprintln!("infer round {}: {} pin_err: {}", round, f.name, m);
                }
                if first_pin_err.is_none() { first_pin_err = Some(m); }
            }
            cur.push(Sig { name: f.name.clone(), borrowed: vec![false; ptys.len()], arr_moved: vec![false; ptys.len()], params: ptys.clone(), ret, inferred, arg_ev: view[fi].arg_ev.clone(), nil_ev: view[fi].nil_ev.clone() });
            f.ret = ret;
        }
        // Types/returns converge by fresh re-inference (cur) against the
        // pre-round table (before); the call-site flags live ONLY in
        // `view`, where they accumulate across the whole round
        // (monotone false -> true), so a late caller in this round is
        // not lost by an early copy.
        let converged = cur.len() == before.len()
            && cur.iter().zip(before.iter()).all(|(c, b)| c.name == b.name && c.params == b.params && c.ret == b.ret && c.inferred == b.inferred)
            && view.iter().zip(before.iter()).all(|(v, b)| v.name == b.name && v.borrowed == b.borrowed && v.arr_moved == b.arr_moved
                // New float-argument evidence recorded THIS round feeds
                // only the NEXT round's pins: convergence must wait for
                // it (63zd; monotone None -> Some, so it stabilizes).
                && v.arg_ev == b.arg_ev && v.nil_ev == b.nil_ev);
        if std::env::var("HBC_INFER_TRACE").is_ok() {
            for (c, b) in cur.iter().zip(before.iter()) {
                if c.params != b.params || c.ret != b.ret || c.inferred != b.inferred {
                    eprintln!("infer round {}: {} params {:?} -> {:?} ret {:?} -> {:?} inferred {:?} -> {:?}", round, c.name, b.params, c.params, b.ret, c.ret, b.inferred, c.inferred);
                }
            }
            for (v, b) in view.iter().zip(before.iter()) {
                if v.borrowed != b.borrowed || v.arr_moved != b.arr_moved {
                    eprintln!("infer round {}: {} flags borrowed {:?} -> {:?} arr_moved {:?} -> {:?}", round, v.name, b.borrowed, v.borrowed, b.arr_moved, v.arr_moved);
                }
            }
        }
        if converged {
            // This round's checks already ran against the stable table:
            // its errors are final, not placeholder artifacts.
            // Body-first, the established contract (t66, t323): a body
            // error names the misuse more specifically than a pin
            // failure; the pin error is reported only when the body
            // checks clean. Placeholder artifacts cannot hide inside
            // body errors because call-site checks against uninferred
            // parameters are skipped, so a body error that survives to
            // the converged round never rests on a placeholder.
            if let Some(m) = first_err.or(first_pin_err) {
                eprintln!("error: {}", m);
                process::exit(1);
            }
            // Merge fresh types with the accumulated flags.
            for (c, v) in cur.iter_mut().zip(view.iter()) {
                c.borrowed = v.borrowed.clone();
                c.arr_moved = v.arr_moved.clone();
            }
            sigs = cur;
            break;
        }
        // Not converged: drop this round's errors (they may rest on
        // placeholder types) and refine the table for the next round:
        // types from this round, flags keep accumulating in place.
        for (v, c) in view.iter_mut().zip(cur.into_iter()) {
            v.params = c.params;
            v.ret = c.ret;
            v.inferred = c.inferred;
        }
    }
    // Borrowed-parameter escape post-pass (see borrow_stmts_ok).
    for f in &funcs {
        if let Some(s) = sigs.iter().find(|s| s.name == f.name) {
            for (i, p) in f.params.iter().enumerate() {
                if s.borrowed.get(i).copied().unwrap_or(false) {
                    if let Some(m) = borrow_stmts_ok(&f.stmts, p) {
                        eprintln!("error: line {}: parameter `{}` of `{}` is borrowed from its caller; it can be read, written and grown in place, but not returned, reassigned, iterated or passed on", m, p, f.name);
                        process::exit(1);
                    }
                }
            }
        }
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

    // Pass 2: generate x86-64 assembly from the validated AST only.
    if llvm {
        match llvm_scalar::emit(&funcs, &sigs, target, llvm_trace) {
            Ok(ir) => { fs::write(pos[1], ir).unwrap();
                let mut rt = emit_asm(&[], &[], target, false);
                rt = rt.replace("call hbc_fn_main", "call ll_main");
                rt.push_str("\n.globl hbc_trace_top\n");
                fs::write(format!("{}.runtime.s",pos[1]), rt).unwrap();
                return;
            },
            Err(e) => {eprintln!("error: {}",e);process::exit(1);}
        }
    }
    let out = emit_asm(&funcs, &sigs, target, instrument);

    fs::write(pos[1], out)
        .unwrap_or_else(|e| { eprintln!("cannot write {}: {}", args[2], e); process::exit(2); });
    println!("{} -> {} ({} functions)", args[1], args[2], funcs.len());
}

