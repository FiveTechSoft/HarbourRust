// Own MIT repair for a typed concat's fresh left temporary during RHS unwind.
use super::*;
pub fn selected(a:&Expr,b:&Expr,env:&[CgLocal],sigs:&[Sig])->bool {
    DECIMAL_LOCAL_PROFILE.with(|v|v.get()) && !MACRO_CONTEXT.with(|v|v.get())
        && !DBF_USED.with(|v|v.get()) && EXTERNS.with(|v|v.borrow().is_empty())
        && expr_ty(a,env,sigs)==Ty::StrOwn && !matches!(a,Expr::Var(_))
        && matches!(expr_ty(b,env,sigs),Ty::Str|Ty::StrOwn)
        && expr_may_raise_or_call(b,env,sigs)
}
pub fn emit(a:&Expr,b:&Expr,env:&[CgLocal],sigs:&[Sig],strs:&mut Vec<String>,out:&mut String,target:Target){
    let arena_root=CG_ARENA_ROOT.with(|c|c.replace(false));
    let b_tmp=expr_ty(b,env,sigs)==Ty::StrOwn && !matches!(b,Expr::Var(_));
    // LHS is fresh and exclusively owned. No snapshot or ownership expansion.
    // If it throws, its own inner emitter is responsible. Only a completed
    // LHS is put under this expression-local pad before RHS evaluation.
    cg_value(a,env,sigs,strs,out,target);
    let k=fresh_lbl();
    out.push_str(&format!("    sub $64, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n    movq $0, 48(%rsp)\n    cmpq $0, hbc_seq_depth(%rip)\n    je .Lbinrhs{k}\n    lea .Lbincatch{k}(%rip), %rdi\n    call hbc_seq_push\n    movq $1, 48(%rsp)\n.Lbinrhs{k}:\n"));
    cg_value(b,env,sigs,strs,out,target);
    // hbc_seq_pop clobbers no value registers. Drop the pad immediately once
    // RHS completes: concat and frees below cannot throw a catchable error.
    out.push_str(&format!("    mov %rax, 16(%rsp)\n    cmpq $0, 48(%rsp)\n    je .Lbinjoin{k}\n    call hbc_seq_pop\n.Lbinjoin{k}:\n    mov %rdx, %rcx\n    mov %rax, %rdx\n    mov (%rsp), %rdi\n    mov 8(%rsp), %rsi\n"));
    if arena_root{out.push_str("    movb $1, hbc_arena_ok(%rip)\n");}
    out.push_str("    call hbc_strcat\n");
    if arena_root{out.push_str("    movb $0, hbc_arena_ok(%rip)\n");}
    out.push_str("    mov %rax, 24(%rsp)\n    mov %rdx, 32(%rsp)\n");
    if b_tmp{out.push_str("    mov 16(%rsp), %rdi\n    call hbc_freestr\n");}
    out.push_str(&format!("    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 24(%rsp), %rax\n    mov 32(%rsp), %rdx\n    add $64, %rsp\n    jmp .Lbinend{k}\n.Lbincatch{k}:\n    mov (%rsp), %rdi\n    call hbc_freestr\n    add $64, %rsp\n    jmp hbc_seq_unwind\n.Lbinend{k}:\n"));
}
