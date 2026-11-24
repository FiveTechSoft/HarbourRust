// Own MIT B2 array DATA roots. Objects cannot occur inside shared arrays.
use super::*;
thread_local!{static ACTIVE:std::cell::Cell<bool>=const{std::cell::Cell::new(false)};}
pub fn active()->bool{ACTIVE.with(|v|v.get())}
pub fn init(ff:&[Func]){
 let mut yes=false;
 for f in ff {if METHOD_CLASS.with(|m|m.borrow().contains_key(&f.name)){visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::DArrNew){yes=true;}});}}
 ACTIVE.with(|v|v.set(yes&&DECIMAL_LOCAL_PROFILE.with(|v|v.get())&&!MACRO_CONTEXT.with(|v|v.get())&&!EXTERNS.with(|v|!v.borrow().is_empty())&&!module_static::has_objects()));
}
pub fn expr(e:&Expr,own:&std::collections::HashSet<String>,ret:&std::collections::HashSet<String>)->bool{
 match e{Expr::Var(n)=>own.contains(n),Expr::DArrNew=>true,Expr::Call(id,_)=>ret.contains(id),Expr::Send(_,n,_)=>method_results::choices(n).iter().any(|(_,f)|ret.contains(f)),_=>false}
}

pub fn runtime(s:String)->String{
 if !active(){return s;}
 let mut s=s;
 s=s.replace("    add $1, %eax\n    shl $4, %eax\n    mov %rax, %rdi\n    call hbc_alloc\n    mov %rax, %r14", "    add $2, %eax\n    shl $4, %eax\n    mov %rax, %rdi\n    call hbc_alloc\n    mov hbc_b2_objects(%rip), %rcx\n    mov %rcx, (%rax)\n    lea 16(%rax), %r14\n    mov %r14, hbc_b2_objects(%rip)");
 s=s.replace(".Lhrobj_39:\n    mov 0(%rbp), %rax", ".Lhrobj_39:\n    lea hbc_b2_objects(%rip), %rdi\n.Lb2unlink:\n    mov (%rdi), %rax\n    cmp %rbp, %rax\n    je .Lb2found\n    lea -16(%rax), %rdi\n    jmp .Lb2unlink\n.Lb2found:\n    mov -16(%rbp), %rax\n    mov %rax, (%rdi)\n    mov 0(%rbp), %rax");
 s=s.replace("    add $1, %esi\n    shl $4, %esi\n    mov %rbp, %rdi", "    add $2, %esi\n    shl $4, %esi\n    lea -16(%rbp), %rdi");
 s.push_str("\n.bss\n.align 8\nhbc_b2_objects: .quad 0\n.text\n");s
}
pub fn roots(out:&mut String){
 if !active(){return;}
 out.push_str("    mov hbc_b2_objects(%rip), %r8\n.Lb2rootobj:\n    test %r8, %r8\n    je .Lb2rootdone\n    mov (%r8), %rax\n    movl 20(%rax), %ecx\n    lea 16(%r8), %r9\n.Lb2rootcell:\n    test %rcx, %rcx\n    je .Lb2rootnext\n    cmpq $16, (%r9)\n    jne .Lb2rootcellnext\n    mov 8(%r9), %rax\n    movq $1, 32(%rax)\n.Lb2rootcellnext:\n    add $16, %r9\n    dec %rcx\n    jmp .Lb2rootcell\n.Lb2rootnext:\n    mov -16(%r8), %r8\n    jmp .Lb2rootobj\n.Lb2rootdone:\n");
}

pub fn validate(ff:&[Func])->Result<(),String>{
 if !active(){return Ok(());}
 let mut bad=false;
 for f in ff{
 visit_stmts_ref(&f.stmts,&mut |st|{if matches!(st,Stmt::Static(..)|Stmt::Switch(..)|Stmt::ForEach(..)|Stmt::MemvarDecl(..)|Stmt::MemvarSet(..)){bad=true;}},&mut |_|{});
 visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::Seq(_)|Expr::Set(..)|Expr::HashLit(_)|Expr::BlockLit(..)|Expr::ByRef(_)|Expr::FuncRef(_)){bad=true;}});
 }
 if bad{Err("B2 excludes STATIC, SWITCH, FOR EACH, MEMVAR, inline sequences/assignments, hashes, blocks, indirect calls and @".into())}else{Ok(())}
}
pub fn screen_data(out:&mut String){
 let k=fresh_lbl();out.push_str(&format!("    cmp $13, %rax\n    jne .Lb2dataok{k}\n    mov %rdx, %rdi\n    call hrobj_release\n    jmp hbc_type_error\n.Lb2dataok{k}:\n"));shared_local::screen_value(out);
}

pub fn integer(e:&Expr,out:&mut String){
 if !dyn_expr_owned(e){out.push_str("    call hbc_dyn_to_i64\n");return;}
 let k=fresh_lbl();out.push_str(&format!("    sub $32, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n    cmp $0, %rax\n    je .Lb2intok{k}\n    cmp $9, %rax\n    je .Lb2intok{k}\n"));
 cg_dyn_stack_release(out,0,false);
 out.push_str(&format!("    add $32, %rsp\n    jmp hbc_type_error\n.Lb2intok{k}:\n    mov %rdx, %rax\n    add $32, %rsp\n"));
}
