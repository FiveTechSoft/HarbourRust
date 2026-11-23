// Own MIT. Bounded scalar timestamp integration; tag16 remains shared arrays.
use super::*;

pub(super) fn family(id:&str)->bool { ["hb_stot","hb_ttos","hb_ttod","hb_dtot","hb_isdatetime","hb_istimestamp"].iter().any(|b|is_builtin(id,b)) }
pub(super) fn result(id:&str)->Option<Ty>{
 if is_builtin(id,"hb_stot")||is_builtin(id,"hb_dtot"){Some(Ty::Dyn)}
 else if is_builtin(id,"hb_ttos"){Some(Ty::StrOwn)}
 else if is_builtin(id,"hb_ttod"){Some(Ty::Date)}
 else if is_builtin(id,"hb_isdatetime")||is_builtin(id,"hb_istimestamp"){Some(Ty::Bool)}else{None}
}
pub(super) fn check(id:&str,args:&[Expr],env:&mut [Local],sigs:&mut Vec<Sig>,n:usize)->Result<Ty,String>{
 if args.len()!=1{return Err(format!("line {}: {} takes exactly one argument in timestamp phase 1",n,id));}
 if !DECIMAL_LOCAL_PROFILE.with(|v|v.get())||MACRO_CONTEXT.with(|v|v.get()){return Err(format!("line {}: timestamp phase 1 requires ordinary Linux without threads or macros",n));}
 let t=type_expr(&args[0],env,sigs,n)?;
 if (is_builtin(id,"hb_isdatetime")||is_builtin(id,"hb_istimestamp")) && !matches!(t,Ty::Dyn|Ty::Date|Ty::I64|Ty::Bool|Ty::Str|Ty::StrOwn|Ty::F64|Ty::NumLocal){return Err(format!("line {}: timestamp predicates accept scalar values in phase 1",n));}
 if is_builtin(id,"hb_stot") {if !matches!(t,Ty::Str|Ty::StrOwn){return Err(format!("line {}: hb_SToT expects a string",n));}}
 else if !is_builtin(id,"hb_isdatetime")&&!is_builtin(id,"hb_istimestamp")&&!matches!(t,Ty::Date|Ty::Dyn){return Err(format!("line {}: {} expects a date or timestamp",n,id));}
 Ok(result(id).unwrap())
}
pub(super) fn emit(id:&str,args:&[Expr],env:&[CgLocal],sigs:&[Sig],strs:&mut Vec<String>,out:&mut String,target:Target){
 let e=&args[0];let t=expr_ty(e,env,sigs);cg_value(e,env,sigs,strs,out,target);
 if is_builtin(id,"hb_isdatetime")||is_builtin(id,"hb_istimestamp"){
  let release=t==Ty::Dyn&&dyn_expr_owned(e);
  let release_str=t==Ty::StrOwn&&!matches!(e,Expr::Var(_));
  if release_str{out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n");}
  if release{out.push_str("    sub $32, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");}
  if t==Ty::Dyn {out.push_str(if is_builtin(id,"hb_isdatetime"){"    cmp $11, %rax\n    sete %cl\n    cmp $17, %rax\n    sete %al\n    or %cl, %al\n    movzbq %al, %rax\n"}else{"    cmp $17, %rax\n    sete %al\n    movzbq %al, %rax\n"});}
  else{out.push_str(if t==Ty::Date&&is_builtin(id,"hb_isdatetime"){"    mov $1, %eax\n"}else{"    xor %eax, %eax\n"});}
  if release_str{out.push_str("    mov %rax, 8(%rsp)\n    mov (%rsp), %rdi\n    call hbc_freestr\n    mov 8(%rsp), %rax\n    add $16, %rsp\n");}
  if release{out.push_str("    mov %rax, 16(%rsp)\n");cg_concat_drop(out,0);out.push_str("    mov 16(%rsp), %rax\n    add $32, %rsp\n");}
  return;
 }
 if is_builtin(id,"hb_stot") {
  let temp=t==Ty::StrOwn&&!matches!(e,Expr::Var(_));
  out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_ts_parse\n    mov %rax, 8(%rsp)\n");
  if temp{out.push_str("    mov (%rsp), %rdi\n    call hbc_freestr\n");}
  out.push_str("    mov 8(%rsp), %rdx\n    mov $17, %eax\n    add $16, %rsp\n");return;
 }
 if t==Ty::Date {out.push_str("    mov %rax, %rdi\n    call hbc_ts_from_date\n");}
 else{
  if dyn_expr_owned(e){
   let k=fresh_lbl();
   out.push_str(&format!("    cmp $11, %rax\n    je .Ltstype{k}\n    cmp $17, %rax\n    je .Ltstype{k}\n    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n"));
   cg_concat_drop(out,0);
   out.push_str(&format!("    add $16, %rsp\n    jmp hbc_type_error\n.Ltstype{k}:\n"));
  }
  let k=fresh_lbl();out.push_str(&format!("    cmp $11, %rax\n    jne .Ltstamp{k}\n    mov %rdx, %rdi\n    call hbc_ts_from_date\n    jmp .Ltsready{k}\n.Ltstamp{k}:\n    cmp $17, %rax\n    jne hbc_type_error\n    mov %rdx, %rax\n.Ltsready{k}:\n"));
 }
 out.push_str("    mov %rax, %rdi\n");
 if is_builtin(id,"hb_ttos"){out.push_str("    call hbc_ts_string\n");}
 else if is_builtin(id,"hb_ttod"){out.push_str("    call hbc_ts_to_date\n");}
 else{out.push_str("    call hbc_ts_midnight\n    mov %rax, %rdx\n    mov $17, %eax\n");}
}

thread_local!{static ACTIVE:std::cell::Cell<bool>=const{std::cell::Cell::new(false)};static NAMES:std::cell::RefCell<std::collections::HashSet<(String,String)>>=std::cell::RefCell::new(std::collections::HashSet::new());}
pub(super) fn known(e:&Expr)->bool{match e{Expr::Call(id,_)=>is_builtin(id,"hb_stot")||is_builtin(id,"hb_dtot"),Expr::Var(v)=>NAMES.with(|m|m.borrow().contains(&(CUR_FN.with(|f|f.borrow().clone()),v.clone()))),_=>false}}
pub(super) fn active()->bool{ACTIVE.with(|v|v.get())}
pub(super) fn init(fs:&[Func]){
 ACTIVE.with(|v|v.set(false));
 NAMES.with(|v|v.borrow_mut().clear());
 for f in fs{visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::Call(id,_) if family(id)){ACTIVE.with(|v|v.set(true));}});}
 for f in fs{let prev=CUR_FN.with(|c|c.replace(f.name.clone()));
 loop {
  let before=NAMES.with(|m|m.borrow().len());
  visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::Local(_,v,e)|Stmt::Assign(_,v,e)=s {if known(e){NAMES.with(|m|m.borrow_mut().insert((f.name.clone(),v.clone())));}}},&mut |_|{});
  if NAMES.with(|m|m.borrow().len())==before{break;}
 }
 CUR_FN.with(|c|c.replace(prev));}

}
pub(super) const PRINT_HELPER:&str=r#"
.text
hbc_ts_print:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    mov %esi, -4(%rbp)
    lea -40(%rbp), %rsi
    call hbc_ts_render
    mov %rax, %rdx
    lea -40(%rbp), %rax
    cmpl $2, -4(%rbp)
    je .Ltsprint_err
    cmpl $0, -4(%rbp)
    je .Ltsprint_raw
    call hbc_pstrt
    leave
    ret
.Ltsprint_raw:
    call hbc_print_str
    leave
    ret
.Ltsprint_err:
    call hbc_eprint_str
    leave
    ret
"#;
