// Isolated AST-to-ARM64 experiment. NOT integrated or advertised by hbc.
// Finite F64 literal/copy/call/compare only; numeric arithmetic still rejects.
// Compiled only by make-compiler-probe.py against a copy of the checked frontend.
// Keeps a named, deliberately narrow boundary; all functions and dead code
// are visited. The real --target=macho-arm64 continues to reject unchanged.
use super::*;
#[path = "arm64-code.rs"]
mod code;
#[path = "numeric/decimal-compose.rs"]
mod compose;
#[path = "numeric/decimal-image.rs"]
mod decimal;
#[path = "numeric/decimal-mixed.rs"]
mod mixedformat;
#[path = "pair-print.rs"]
mod pair_print;
#[path = "arm64-runtime.rs"]
mod runtime;
#[path = "arm64-trace.rs"]
mod trace;
#[path = "arm64-writer.rs"]
mod writer;
use code::Code;
#[derive(Clone, Copy, PartialEq)]
enum K {
    Int,
    Float,
    Mixed,
    Bool,
    Text,
    Void,
}
struct V {
    name: String,
    k: K,
    off: u16,
}
struct E<'a> {
    c: Code,
    sigs: &'a [Sig],
    env: Vec<V>,
    slot: u16,
    seq: usize,
    loops: Vec<(String, String)>,
    fname: String,
    mixed: std::collections::HashSet<String>,
}
fn kind(t: Ty) -> Result<K, String> {
    match t {
        Ty::I64 => Ok(K::Int),
        Ty::F64 => Ok(K::Float),
        Ty::Bool => Ok(K::Bool),
        _ => Err(format!(
            "ARM64 scalar experiment: type {t:?} is outside this boundary"
        )),
    }
}
impl E<'_> {
    fn label(&mut self) -> String {
        let s = format!("L{}", self.seq);
        self.seq += 1;
        s
    }
    fn find(&self, n: &str) -> Result<(K, u16), String> {
        self.env
            .iter()
            .rev()
            .find(|v| v.name == n)
            .map(|v| (v.k, v.off))
            .ok_or_else(|| format!("ARM64 scalar experiment: local {n} unavailable"))
    }
    fn load(&mut self, off: u16) -> Result<(), String> {
        self.c.imm(17, 29, off, true, false)?;
        self.c.ldst(1, 17, 8, true)?;
        self.c.ldst(0, 17, 0, true)
    }
    fn store(&mut self, off: u16) -> Result<(), String> {
        self.c.imm(17, 29, off, true, false)?;
        self.c.ldst(1, 17, 8, false)?;
        self.c.ldst(0, 17, 0, false)
    }
    fn push(&mut self) -> Result<(), String> {
        self.c.imm(31, 31, 16, true, false)?;
        self.c.ldst(0, 31, 0, false)?;
        self.c.ldst(1, 31, 8, false)
    }
    fn pop9(&mut self) -> Result<(), String> {
        self.c.ldst(9, 31, 0, true)?;
        self.c.imm(31, 31, 16, false, false)
    }
    fn cond(&mut self, e: &Expr) -> Result<(), String> {
        if self.expr(e)? != K::Bool {
            return Err("ARM64 scalar experiment: condition must be logical".into());
        }
        self.c.imm(31, 0, 0, true, true)
    }
    fn expr(&mut self, e: &Expr) -> Result<K, String> {
        match e {
            Expr::Int(n) => {
                self.c.mov(
                    0,
                    n.parse::<i64>().map_err(|_| "ARM64 integer range")? as u64,
                )?;
                self.c.mov(1, 1)?;
                Ok(K::Int)
            }
            Expr::Float(txt, dec) => {
                if *dec > 16 {
                    return Err("pair-AST literal decimal count above16".into());
                }
                let v = harbour_parse_f64(txt).ok_or("pair-AST literal parse")?;
                if !v.is_finite() {
                    return Err("pair-AST nonfinite literal".into());
                }
                self.c.mov(0, v.to_bits())?;
                self.c.mov(1, (10u64 << 16) | (*dec as u64))?;
                Ok(K::Float)
            }
            Expr::FloatV(bits, dec) => {
                if *dec > 16 {
                    return Err("pair-AST folded decimal count above16".into());
                }
                let v = f64::from_bits(*bits);
                if !v.is_finite() {
                    return Err("pair-AST nonfinite folded literal".into());
                }
                self.c.mov(0, *bits)?;
                self.c.mov(
                    1,
                    ((if v > 9999999999.0 || v < -999999999.0 {
                        20u64
                    } else {
                        10
                    }) << 16)
                        | (*dec as u64),
                )?;
                Ok(K::Float)
            }
            Expr::Log(v) => {
                self.c.mov(0, *v as u64)?;
                Ok(K::Bool)
            }
            Expr::Str(s) => {
                if s.is_empty() || s.ends_with(' ') || s.contains('\n') || s.contains('\r') {
                    return Err("ARM64 scalar experiment: empty, trailing-space and multiline console strings need the pending-console runtime".into());
                }
                let label = self.label();
                self.c.data(&label, s.as_bytes())?;
                self.c.adr(0, &label)?;
                self.c.mov(1, s.len() as u64)?;
                Ok(K::Text)
            }
            Expr::Var(n) => {
                let (k, o) = self.find(n)?;
                self.load(o)?;
                Ok(k)
            }
            Expr::Set(n, e) => {
                let (k, o) = self.find(n)?;
                if k == K::Mixed {
                    return Err("mixed-AST inline assignment expression unavailable".into());
                }
                if self.expr(e)? != k {
                    return Err("ARM64 scalar experiment: assignment kind mismatch".into());
                }
                self.store(o)?;
                Ok(k)
            }
            Expr::Seq(es) => {
                let mut k = K::Void;
                for e in es {
                    k = self.expr(e)?
                }
                Ok(k)
            }
            Expr::Cmp(op, a, b) => {
                let left = self.expr(a)?;
                if !matches!(left, K::Int | K::Float) {
                    return Err("pair-AST comparison kind".into());
                }
                self.push()?;
                let right = self.expr(b)?;
                if right != left {
                    return Err("pair-AST mixed comparison rejected".into());
                }
                self.pop9()?;
                let cond = match op {
                    CmpOp::Eq | CmpOp::EqEq => 0,
                    CmpOp::Ne => 1,
                    CmpOp::Lt => 11,
                    CmpOp::Le => 13,
                    CmpOp::Gt => 12,
                    CmpOp::Ge => 10,
                    _ => return Err("ARM64 scalar experiment: comparison unavailable".into()),
                };
                if left == K::Float {
                    self.c.fp_bits(9, 0, false)?;
                    self.c.fp_bits(0, 1, false)?;
                    self.c.fcmp(0, 1)?;
                    let fcond = match op {
                        CmpOp::Eq | CmpOp::EqEq => 0,
                        CmpOp::Ne => 1,
                        CmpOp::Lt => 4,
                        CmpOp::Le => 9,
                        CmpOp::Gt => 12,
                        CmpOp::Ge => 10,
                        _ => unreachable!(),
                    };
                    self.c.cset(0, fcond)?;
                } else {
                    self.c.addsub(31, 9, 0, true, true)?;
                    self.c.cset(0, cond)?;
                }
                Ok(K::Bool)
            }
            Expr::LNot(e) => {
                self.cond(e)?;
                self.c.cset(0, 0)?;
                Ok(K::Bool)
            }
            Expr::LAnd(a, b) | Expr::LOr(a, b) => {
                let end = self.label();
                let or = matches!(e, Expr::LOr(..));
                self.cond(a)?;
                self.c.bc(&end, if or { 1 } else { 0 })?;
                self.cond(b)?;
                self.c.cset(0, 1)?;
                self.c.label(&end)?;
                Ok(K::Bool)
            }
            Expr::Call(n, args) => {
                let sig = self.sigs.iter().find(|s| s.name == *n).ok_or_else(|| {
                    format!("ARM64 scalar experiment: builtin or external {n} unavailable")
                })?;
                if args.len() != sig.params.len() || args.len() > 8 {
                    return Err(
                        "ARM64 scalar experiment: supports at most eight scalar arguments".into(),
                    );
                }
                let expected: Vec<K> = sig
                    .params
                    .iter()
                    .map(|t| kind(*t))
                    .collect::<Result<_, _>>()?;
                let ret = if sig.nil_ret_only {
                    K::Void
                } else {
                    match sig.ret {
                        Some(t) => kind(t)?,
                        None => K::Void,
                    }
                };
                let words: usize = expected
                    .iter()
                    .map(|k| if *k == K::Float { 2 } else { 1 })
                    .sum();
                if words > 8 {
                    return Err("pair-AST call exceeds eight register words".into());
                }
                for (e, k) in args.iter().zip(&expected) {
                    if self.expr(e)? != *k {
                        return Err("pair-AST call kind".into());
                    }
                    self.push()?;
                }
                let mut reg = 0;
                for (i, k) in expected.iter().enumerate() {
                    let off = (16 * (args.len() - 1 - i)) as u16;
                    self.c.ldst(reg, 31, off, true)?;
                    reg += 1;
                    if *k == K::Float {
                        self.c.ldst(reg, 31, off + 8, true)?;
                        reg += 1;
                    }
                }
                // Keep evaluated pairs alive for the private callee metadata view.
                // x0..x7 still carry the same scalar/F64 register words.
                self.c.imm(8, 31, 0, false, false)?;
                self.c.b(&format!("fn_{n}"), true);
                if !args.is_empty() {
                    self.c.imm(31, 31, (16 * args.len()) as u16, false, false)?;
                }
                Ok(ret)
            }
            _ => Err(format!(
                "ARM64 scalar experiment: expression family is not implemented: {e:?}"
            )),
        }
    }
    fn location(&mut self, s: &Stmt) -> Result<(), String> {
        let line = stmt_line(s);
        let (path, original) = TRACE_ORIGINS
            .with(|m| m.borrow().get(line.saturating_sub(1)).cloned())
            .unwrap_or_else(|| ("<unknown>".to_string(), line));
        let text = format!("  at {} ({}:{})\n", self.fname, path, original);
        let label = self.label();
        trace::location(&mut self.c, &label, &text)
    }
    fn block(&mut self, ss: &[Stmt]) -> Result<(), String> {
        let old = self.env.len();
        for s in ss {
            self.location(s)?;
            match s {
                Stmt::Local(_, n, e) => {
                    let mut k = self.expr(e)?;
                    if self.mixed.contains(n) {
                        if !matches!(k, K::Int | K::Float | K::Mixed) {
                            return Err("mixed-AST local nonnumeric seed".into());
                        }
                        k = K::Mixed;
                    }
                    if !matches!(k, K::Int | K::Bool | K::Float | K::Mixed) {
                        return Err(
                            "ARM64 scalar experiment: locals must be integer, logical or finite F64".into()
                        );
                    }
                    self.slot = self.slot.checked_add(16).ok_or("ARM64 frame overflow")?;
                    if self.slot > 4080 {
                        return Err("ARM64 scalar experiment: frame exceeds 4080 bytes".into());
                    }
                    self.store(self.slot)?;
                    self.env.push(V {
                        name: n.clone(),
                        k,
                        off: self.slot,
                    });
                }
                Stmt::Assign(_, n, e) => {
                    let (k, o) = self.find(n)?;
                    let rhs = self.expr(e)?;
                    if rhs != k && !(k == K::Mixed && matches!(rhs, K::Int | K::Float | K::Mixed)) {
                        return Err("ARM64 scalar experiment: assignment kind".into());
                    }
                    self.store(o)?;
                }
                Stmt::Print(_, es, inline) => {
                    if es.len() > 128 {
                        return Err("ARM64 scalar experiment: console item limit 128".into());
                    }
                    let mut ks = Vec::new();
                    for e in es {
                        let k = self.expr(e)?;
                        if k == K::Void {
                            return Err(
                                "ARM64 scalar experiment: cannot print a void return".into()
                            );
                        }
                        ks.push(k);
                        self.push()?;
                    }
                    if !inline {
                        self.c.adr(0, "rt_nl")?;
                        self.c.mov(1, 1)?;
                        self.c.b("rt_write", true);
                    }
                    for (i, k) in ks.iter().enumerate() {
                        if i > 0 {
                            self.c.adr(0, "rt_sep")?;
                            self.c.mov(1, 1)?;
                            self.c.b("rt_write", true);
                        }
                        let o = (16 * (es.len() - 1 - i)) as u16;
                        self.c.ldst(0, 31, o, true)?;
                        self.c.ldst(1, 31, o + 8, true)?;
                        self.c.b(
                            match k {
                                K::Int => "rt_i64",
                                K::Float => "pair_print_f64",
                                K::Mixed => "pair_print_mixed",
                                K::Bool => "rt_bool",
                                K::Text => "rt_write",
                                K::Void => unreachable!(),
                            },
                            true,
                        );
                    }
                    if !es.is_empty() {
                        self.c.imm(31, 31, (16 * es.len()) as u16, false, false)?;
                    }
                }
                Stmt::If(_, e, a, b) => {
                    let els = self.label();
                    let end = self.label();
                    self.cond(e)?;
                    self.c.bc(&els, 0)?;
                    self.block(a)?;
                    self.c.b(&end, false);
                    self.c.label(&els)?;
                    self.block(b)?;
                    self.c.label(&end)?;
                }
                Stmt::While(_, e, b) => {
                    let start = self.label();
                    let end = self.label();
                    self.c.label(&start)?;
                    self.location(s)?;
                    self.cond(e)?;
                    self.c.bc(&end, 0)?;
                    self.loops.push((start.clone(), end.clone()));
                    self.block(b)?;
                    self.loops.pop();
                    self.c.b(&start, false);
                    self.c.label(&end)?;
                }
                Stmt::Loop(_) | Stmt::Exit(_) => {
                    let (start, end) =
                        self.loops.last().ok_or("ARM64 loop control outside loop")?;
                    self.c.b(
                        if matches!(s, Stmt::Loop(_)) {
                            start
                        } else {
                            end
                        },
                        false,
                    );
                }
                Stmt::Ret(_, e) => {
                    match e {
                        None | Some(Expr::Nil) => {
                            self.c.mov(0, 0)?;
                        }
                        Some(e) => {
                            if !matches!(self.expr(e)?, K::Int | K::Bool | K::Float) {
                                return Err("ARM64 scalar experiment: return kind".into());
                            }
                        }
                    }
                    trace::unlink(&mut self.c)?;
                    self.c.epilogue()?;
                }
                Stmt::CallStmt(_, e) => {
                    self.expr(e)?;
                }
                _ => {
                    return Err(format!(
                        "ARM64 scalar experiment: statement family is not implemented: {s:?}"
                    ))
                }
            }
        }
        self.env.truncate(old);
        Ok(())
    }
}
pub fn emit(funcs: &[Func], sigs: &[Sig]) -> Result<Vec<u8>, String> {
    let mut e = E {
        c: Code::default(),
        sigs,
        env: vec![],
        slot: 0,
        seq: 0,
        loops: vec![],
        fname: String::new(),
        mixed: std::collections::HashSet::new(),
    };
    if !funcs.iter().any(|f| f.name == "main") {
        return Err("ARM64 experiment: main missing".into());
    }
    e.c.prologue(32)?;
    e.c.ldst(19, 31, 0, false)?;
    e.c.mov(19, 0)?;
    e.c.fp_env(9, false, false)?;
    e.c.ldst(9, 31, 8, false)?;
    e.c.fp_env(9, true, false)?;
    e.c.ldst(9, 31, 16, false)?;
    e.c.mov(9, 0)?;
    e.c.fp_env(9, false, true)?;
    e.c.fp_env(9, true, true)?;
    e.c.isb();
    e.c.b("fn_main", true);
    e.c.mov(0, 0)?;
    e.c.ldst(9, 31, 8, true)?;
    e.c.fp_env(9, false, true)?;
    e.c.ldst(9, 31, 16, true)?;
    e.c.fp_env(9, true, true)?;
    e.c.isb();
    e.c.ldst(19, 31, 0, true)?;
    e.c.epilogue()?;
    for f in funcs {
        if f.init || !f.dyn_names.is_empty() {
            return Err("ARM64 scalar experiment: INIT and Dyn locals unavailable".into());
        }
        let sig = sigs
            .iter()
            .find(|s| s.name == f.name)
            .ok_or("ARM64 function signature missing")?;
        if sig.params.len() > 8
            || sig.borrowed.iter().any(|v| *v)
            || sig.aview.iter().any(|v| *v)
            || sig.arr_moved.iter().any(|v| *v)
        {
            return Err("ARM64 scalar experiment: call ownership/argument boundary".into());
        }
        if !sig.nil_ret_only {
            if let Some(t) = sig.ret {
                kind(t)?;
            }
        }
        if f.name == "main" && !f.params.is_empty() {
            return Err("ARM64 scalar experiment: main parameters unavailable".into());
        }
        e.c.label(&format!("fn_{}", f.name))?;
        // Reserve a conservative fixed 4080-byte frame; no dynamic local storage.
        e.c.prologue(4080)?;
        e.env.clear();
        e.slot = 0;
        e.fname = f.name.clone();
        e.mixed = prescan_numeric(f);
        // Separate 48-byte trace storage preserves the existing 4080-byte local limit.
        e.c.imm(31, 31, 48, true, false)?;
        trace::link_at_sp(&mut e.c)?;
        let kinds = sig
            .params
            .iter()
            .map(|t| kind(*t))
            .collect::<Result<Vec<_>, _>>()?;
        let words: usize = kinds
            .iter()
            .map(|k| if *k == K::Float { 2 } else { 1 })
            .sum();
        if words > 8 {
            return Err("pair-AST signature exceeds eight register words".into());
        }
        // Incoming x8 borrows caller argument-pair temporaries until return.
        // Capture it before any parameter register or stack work can overwrite it.
        e.c.copy(15, 8)?;
        e.c.imm(31, 31, 64, true, false)?;
        for reg in 0..8 {
            e.c.ldst(reg, 31, (reg as u16) * 8, false)?;
        }
        let mut reg = 0;
        for (index, (n, k)) in f.params.iter().zip(kinds).enumerate() {
            e.slot += 16;
            e.c.ldst(0, 31, reg * 8, true)?;
            reg += 1;
            if k == K::Float {
                e.c.ldst(1, 31, reg * 8, true)?;
                reg += 1;
            } else if k == K::Int {
                // Caller pushes arguments left-to-right, so the first is highest.
                let off = (16 * (f.params.len() - 1 - index) + 8) as u16;
                e.c.ldst(1, 15, off, true)?;
            } else {
                e.c.mov(1, 1)?;
            }
            e.store(e.slot)?;
            e.env.push(V {
                name: n.clone(),
                k,
                off: e.slot,
            });
        }
        e.c.imm(31, 31, 64, false, false)?;
        e.block(&f.stmts)?;
        e.c.mov(0, 0)?;
        trace::unlink(&mut e.c)?;
        e.c.epilogue()?;
    }
    pair_print::emit(&mut e.c)?;
    runtime::emit(&mut e.c)?;
    trace::emit(&mut e.c)?;
    let (code, data) = e.c.finish()?;
    writer::from_code(&code, &data, 0, "hbc-arm64-scalar-experiment")
}
