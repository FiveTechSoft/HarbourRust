// Own MIT bounded LEN-only observer for an element of a received array.
// No scalar ownership transfer and no general view-to-user-call conversion.
use super::*;
thread_local! {
    static LEAVES: std::cell::RefCell<std::collections::HashSet<String>> = std::cell::RefCell::new(std::collections::HashSet::new());
}
pub fn parameter(id:&str,i:usize)->bool {i==0 && LEAVES.with(|s|s.borrow().contains(id))}
pub fn analyze(ff:&[Func]) {
    LEAVES.with(|s|s.borrow_mut().clear());
    if !DECIMAL_LOCAL_PROFILE.with(|v|v.get()) || MACRO_CONTEXT.with(|v|v.get()) || EXTERNS.with(|v|!v.borrow().is_empty()){return;}
    let mut indirect=std::collections::HashSet::new();
    for f in ff {visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::FuncRef(id)=e {indirect.insert(id.clone());}});}
    let mut leaves=std::collections::HashSet::new();
    for f in ff {
        if f.init || f.params.len()!=1 || METHOD_CLASS.with(|m|m.borrow().contains_key(&f.name)) || indirect.contains(&f.name) || root_param(&f.name,&f.params[0]) {continue;}
        if matches!(f.stmts.as_slice(),[Stmt::Ret(_,Some(Expr::Call(id,aa)))] if is_builtin(id,"len") && matches!(aa.as_slice(),[Expr::Var(p)] if p==&f.params[0])) {leaves.insert(f.name.clone());}
    }
    let mut used=std::collections::HashSet::new();
    for f in ff {
        if METHOD_CLASS.with(|m|m.borrow().contains_key(&f.name)) {continue;}
        visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{
            if let Expr::Call(id,aa)=e {
                if leaves.contains(id) && matches!(aa.as_slice(),[Expr::Index(p,i)] if f.params.contains(p) && !root_param(&f.name,p) && !aview_mentions(i,p)) {used.insert(id.clone());}
            }
        });
    }
    LEAVES.with(|s|*s.borrow_mut()=used);
}
pub fn evidence(id:&str,aa:&[Expr],p:&str)->bool {
    parameter(id,0) && matches!(aa,[Expr::Index(v,i)] if v==p && !aview_mentions(i,p))
}
pub fn emit_cell(out:&mut String) {
    let k=fresh_lbl();let slot=aview_scratch();
    // Existing subarray descriptors already carry their child view header.
    // Strings get a frame-only length header. Kind 6 is private to this
    // exact RETURN Len(parameter) proof, never input to hbc_aview_get.
    // The real callee frame/call/trace remains present; nothing is inlined.
    out.push_str(&format!("    @HBC_TAG_KIND@cmp $6, %rax@HBC_TAG_END@\n    je .Lcelllenready{k}\n    @HBC_TAG_KIND@cmp $2, %rax@HBC_TAG_END@\n    je .Lcelllenstr{k}\n    @HBC_TAG_KIND@cmp $4, %rax@HBC_TAG_END@\n    jne .Lcelllenbad{k}\n.Lcelllenstr{k}:\n    test %rdx, %rdx\n    je .Lcelllenbad{k}\n    movq $6, -{slot}(%rbp)\n    mov %rdx, -{}(%rbp)\n    mov -8(%rdx), %rax\n    mov %rax, -{}(%rbp)\n    lea -{slot}(%rbp), %rdx\n    jmp .Lcelllenready{k}\n.Lcelllenbad{k}:\n    movq $7, -{slot}(%rbp)\n    lea -{slot}(%rbp), %rdx\n.Lcelllenready{k}:\n    mov %rdx, %rax\n",slot-8,slot-16));
}
