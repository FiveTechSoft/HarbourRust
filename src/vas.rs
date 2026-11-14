// I3 flat-array family admission. This module is ours (MIT), not VM code.
use super::*;
thread_local! {
    static COLLECT: std::cell::Cell<bool> = const { std::cell::Cell::new(false) };
    static TYPES: std::cell::RefCell<Vec<Ty>> = const { std::cell::RefCell::new(Vec::new()) };
    static ACTIVE: std::cell::Cell<bool> = const { std::cell::Cell::new(false) };
}
pub(super) fn observe(env: &[Local]) {
    if COLLECT.with(|c| c.get()) {
        TYPES.with(|t| { let mut t=t.borrow_mut(); for v in env { if !t.contains(&v.ty) { t.push(v.ty); } } });
    }
}
fn persistent(ss: &[Stmt]) -> bool {
    ss.iter().any(|s| match s {
        Stmt::Static(..) => true,
        Stmt::If(_,_,a,b) => persistent(a)||persistent(b),
        Stmt::While(_,_,b)|Stmt::For(_,_,_,_,_,b)|Stmt::ForEach(_,_,_,b) => persistent(b),
        Stmt::Switch(_,_,arms,other) => arms.iter().any(|(_,_,b)|persistent(b)) || other.as_ref().map_or(false,|(_,b)|persistent(b)),
        _ => false,
    })
}
pub(super) fn classify(fs: &[Func], sigs: &[Sig], bp: &std::collections::HashMap<String,Vec<usize>>, bl: &std::collections::HashMap<String,std::collections::HashSet<String>>, enabled: bool, extern_decl: bool) {
    TYPES.with(|t| t.borrow_mut().clear());
    COLLECT.with(|c| c.set(true));
    let reports=escape_analysis(fs,sigs,bp,bl);
    COLLECT.with(|c| c.set(false));
    let mut types=TYPES.with(|t| t.borrow().clone());
    for s in sigs {
        types.extend(s.params.iter().copied());
        if let Some(t)=s.ret { if t!=Ty::Dyn || !s.nil_ret_only { types.push(t); } }
    }
    let flat=types.iter().any(|t|matches!(t,Ty::DArr|Ty::DArrU|Ty::DArrRef));
    let mut reasons=Vec::new();
    if !enabled { reasons.push("disabled"); }
    if !flat { reasons.push("no-flat-array"); }
    if extern_decl { reasons.push("extend"); }
    if DBF_USED.with(|v|v.get()) { reasons.push("dbf"); }
    if THREADS.with(|v|v.get()) || MUTEX.with(|v|v.get()) { reasons.push("threads"); }
    if CLASSES.with(|v|!v.borrow().is_empty()) { reasons.push("classes"); }
    if fs.iter().any(|f|persistent(&f.stmts)) { reasons.push("persistent"); }
    if reports.iter().any(|r|!r.recheck_ok) { reasons.push("unproven-recheck"); }
    for t in types {
        let reason=match t {
            Ty::DArr|Ty::DArrU|Ty::DArrRef|Ty::Arr(_)|Ty::I64|Ty::F64|Ty::NumLocal|Ty::Str|Ty::StrOwn|Ty::Bool|Ty::Date|Ty::Block(..)=>None,
            Ty::DArr2|Ty::DArr3|Ty::DArr4|Ty::DArrRef2=>Some("nested"),
            Ty::DArrS=>Some("string-array"), Ty::DArrDyn=>Some("mixed-array"),
            Ty::Hash=>Some("hash"),Ty::AView=>Some("aview"),
            Ty::Dyn|Ty::RefDyn=>Some("unproven-dyn"),
            Ty::Obj(_)=>Some("object"), Ty::RefI64|Ty::RefStrOwn=>Some("unproven-reference"),
        };
        if let Some(r)=reason { if !reasons.contains(&r) { reasons.push(r); } }
    }
    ACTIVE.with(|v|v.set(reasons.is_empty()));
    if std::env::var_os("HBC_VAS_DUMP").is_some() { eprintln!("VAS eligible={} reasons={}",reasons.is_empty(),reasons.join(",")); }
}
pub(super) fn active() -> bool { ACTIVE.with(|v|v.get()) }

// Called only at the nine audited flat alloc/free emitter sites, plus
// Array(n), scalar AAdd and ASize. Never rewrites an entire function or
// generic runtime text. Excluded programs emit the original exact snippet.
pub(super) fn emit_flat(out: &mut String, code: &str) {
    if !active() { out.push_str(code); return; }
    out.push_str(&code.replace("call hbc_alloc\n", "call hbc_valloc\n")
        .replace("call hbc_free\n", "call hbc_vfree\n")
        .replace("call hbc_aadd\n", "call hbc_vaadd\n")
        .replace("call hbc_asize\n", "call hbc_vasize\n"));
}
pub(super) fn finish(mut code: String, target: Target, instrument: bool) -> String {
    if !active() { return code; }
    match target {
        Target::Linux => {
            // Stash original initial stack before I2 may use rdi/rsp.
            code=code.replacen("_start:\n", "_start:\n    mov %rsp, %rdi\n    call hbc_vinit\n",1);
            code.push_str(include_str!("vas-linux.s"));
        }
        Target::Windows => {
            code=code.replacen("    and $-16, %rsp\n    sub $48, %rsp\n", "    and $-16, %rsp\n    sub $48, %rsp\n    call hbc_vinit\n",1);
            code.push_str(include_str!("vas-windows.s"));
        }
    }
    code.push_str(include_str!("vas-common.s"));
    if instrument {
        code=code.replace("@VREG_DATA@", VREG_DATA).replace("@VREG_ADD@", VREG_ADD)
            .replace("@VREG_CHECK@",VREG_CHECK).replace("@VREG_REMOVE@",VREG_REMOVE)
            .replace("@VREG_HELPERS@", VREG_HELPERS).replace("@VREG_GROW@", "    mov %rcx, %rdi\n    call hbc_vreg_grow\n")
            .replace("@VREG_ENSURE@", "    mov %rax, %rdi\n    call hbc_vreg_validate\n    mov -24(%rbp), %rax\n    mov -8(%rbp), %rdi\n")
            .replace("@VFAIL_RESERVE@", "    cmpq $1, hbc_vfault(%rip)\n    je .Lvnew_heap\n")
            .replace("@VFAIL_INITIAL@", "    cmpq $2, hbc_vfault(%rip)\n    je .Lvnew_unreserve\n")
            .replace("@VFAIL_COMMIT@", "    cmpq $3, hbc_vfault(%rip)\n    je .Lvensure_move\n")
            .replace("@VFAIL_HEAP@", "    cmpq $4, hbc_vfault(%rip)\n    je hbc_oom\n")
            .replace("@VFAIL_FREE@", "    cmpq $5, hbc_vfault(%rip)\n    je hbc_os_bad\n");
    } else {
        for k in ["@VREG_HELPERS@","@VREG_GROW@","@VREG_ENSURE@","@VREG_DATA@","@VREG_ADD@","@VREG_CHECK@","@VREG_REMOVE@","@VFAIL_RESERVE@","@VFAIL_INITIAL@","@VFAIL_COMMIT@","@VFAIL_HEAP@","@VFAIL_FREE@"] { code=code.replace(k, ""); }
    }
    code
}
const VREG_DATA: &str = r#"
hbc_vfault: .quad 0
hbc_vreg_n: .quad 0
hbc_vreg_base: .zero 131072
hbc_vreg_size: .zero 131072
hbc_vreg_kind: .zero 131072
hbc_vreg_cap: .zero 131072
hbc_vreg_commit: .zero 131072
"#;
// These snippets execute inside framed common routines, not OS wrappers.
const VREG_ADD: &str = r#"
    mov hbc_vreg_n(%rip), %rcx
    cmp $16384, %rcx
    jae hbc_reg_bad
    lea hbc_vreg_base(%rip), %r8
    mov %rax, (%r8,%rcx,8)
    lea hbc_vreg_size(%rip), %r8
    mov -16(%rax), %rdx
    mov -24(%rax), %r9
    test %r9, %r9
    cmovnz %r9, %rdx
    mov %rdx, (%r8,%rcx,8)
    lea hbc_vreg_kind(%rip), %r8
    mov %r9, (%r8,%rcx,8)
    lea hbc_vreg_cap(%rip), %r8
    mov -8(%rax), %rdx
    mov %rdx, (%r8,%rcx,8)
    lea hbc_vreg_commit(%rip), %r8
    mov -16(%rax), %rdx
    mov %rdx, (%r8,%rcx,8)
    incq hbc_vreg_n(%rip)
"#;
// Validate pointer before reading its prefix, including wrong-family free.
const VREG_CHECK: &str = "    call hbc_vreg_validate\n    mov %rax, -32(%rbp)\n    mov -8(%rbp), %rdi\n";
const VREG_REMOVE: &str = r#"
    mov hbc_vreg_n(%rip), %rdx
    dec %rdx
    mov -32(%rbp), %rcx
    lea hbc_vreg_base(%rip), %r8
    mov (%r8,%rdx,8), %r9
    mov %r9, (%r8,%rcx,8)
    lea hbc_vreg_size(%rip), %r8
    mov (%r8,%rdx,8), %r9
    mov %r9, (%r8,%rcx,8)
    lea hbc_vreg_kind(%rip), %r8
    mov (%r8,%rdx,8), %r9
    mov %r9, (%r8,%rcx,8)
    lea hbc_vreg_cap(%rip), %r8
    mov (%r8,%rdx,8), %r9
    mov %r9, (%r8,%rcx,8)
    lea hbc_vreg_commit(%rip), %r8
    mov (%r8,%rdx,8), %r9
    mov %r9, (%r8,%rcx,8)
    mov %rdx, hbc_vreg_n(%rip)
"#;

const VREG_HELPERS: &str = r#"
# Pointer membership is checked BEFORE reading any header.
hbc_vreg_find:
    mov hbc_vreg_n(%rip), %rax
    lea hbc_vreg_base(%rip), %r8
.Lvreg_find:
    test %rax, %rax
    je hbc_reg_bad
    dec %rax
    cmp %rdi, (%r8,%rax,8)
    jne .Lvreg_find
    ret
hbc_vreg_validate:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hbc_vreg_find
    lea hbc_vreg_size(%rip), %r8
    mov -16(%rdi), %rdx
    mov -24(%rdi), %r9
    test %r9, %r9
    cmovnz %r9, %rdx
    cmp %rdx, (%r8,%rax,8)
    jne hbc_reg_bad
    lea hbc_vreg_kind(%rip), %r8
    cmp %r9, (%r8,%rax,8)
    jne hbc_reg_bad
    lea hbc_vreg_cap(%rip), %r8
    mov -8(%rdi), %rdx
    cmp %rdx, (%r8,%rax,8)
    jne hbc_reg_bad
    lea hbc_vreg_commit(%rip), %r8
    mov -16(%rdi), %rdx
    cmp %rdx, (%r8,%rax,8)
    jne hbc_reg_bad
    leave
    ret
hbc_vreg_grow:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hbc_vreg_find
    lea hbc_vreg_cap(%rip), %r8
    mov -8(%rdi), %rdx
    mov %rdx, (%r8,%rax,8)
    lea hbc_vreg_commit(%rip), %r8
    mov -16(%rdi), %rdx
    mov %rdx, (%r8,%rax,8)
    leave
    ret
"#;
