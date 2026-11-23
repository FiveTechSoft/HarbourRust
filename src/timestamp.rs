// Own MIT. Bounded scalar timestamp integration; tag16 remains shared arrays.
use super::*;

pub(super) fn family(id:&str)->bool { ["hb_stot","hb_ttos","hb_ttod","hb_dtot","hb_isdatetime","hb_istimestamp","hb_ttoc","hb_dtoc"].iter().any(|b|is_builtin(id,b)) }
pub(super) fn result(id:&str)->Option<Ty>{
 if is_builtin(id,"hb_stot")||is_builtin(id,"hb_dtot"){Some(Ty::Dyn)}
 else if is_builtin(id,"hb_ttos")||is_builtin(id,"hb_ttoc")||is_builtin(id,"hb_dtoc"){Some(Ty::StrOwn)}
 else if is_builtin(id,"hb_ttod"){Some(Ty::Date)}
 else if is_builtin(id,"hb_isdatetime")||is_builtin(id,"hb_istimestamp"){Some(Ty::Bool)}else{None}
}
pub(super) fn check(id:&str,args:&[Expr],env:&mut [Local],sigs:&mut Vec<Sig>,n:usize)->Result<Ty,String>{
 if format_builtin(id){return check_format(id,args,env,sigs,n);}
 if args.len()!=1{return Err(format!("line {}: {} takes exactly one argument in timestamp phase 1",n,id));}
 if !DECIMAL_LOCAL_PROFILE.with(|v|v.get())||MACRO_CONTEXT.with(|v|v.get()){return Err(format!("line {}: timestamp phase 1 requires ordinary Linux without threads or macros",n));}
 let t=type_expr(&args[0],env,sigs,n)?;
 if (is_builtin(id,"hb_isdatetime")||is_builtin(id,"hb_istimestamp")) && !matches!(t,Ty::Dyn|Ty::Date|Ty::I64|Ty::Bool|Ty::Str|Ty::StrOwn|Ty::F64|Ty::NumLocal){return Err(format!("line {}: timestamp predicates accept scalar values in phase 1",n));}
 if is_builtin(id,"hb_stot") {if !matches!(t,Ty::Str|Ty::StrOwn){return Err(format!("line {}: hb_SToT expects a string",n));}}
 else if !is_builtin(id,"hb_isdatetime")&&!is_builtin(id,"hb_istimestamp")&&!matches!(t,Ty::Date|Ty::Dyn){return Err(format!("line {}: {} expects a date or timestamp",n,id));}
 Ok(result(id).unwrap())
}
pub(super) fn emit(id:&str,args:&[Expr],env:&[CgLocal],sigs:&[Sig],strs:&mut Vec<String>,out:&mut String,target:Target){
 if format_builtin(id){emit_format(id,args,env,sigs,strs,out,target);return;}
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
 let mut fmt=false;let mut arr=false;for f in fs{visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::Call(id,_) if is_builtin(id,"hb_stot")||is_builtin(id,"hb_dtot")){fmt=true;}if matches!(e,Expr::DArrNew){arr=true;}});}
 CONTAINERS.with(|v|v.set(fmt&&arr&&CLASSES.with(|c|c.borrow().is_empty())&&DECIMAL_LOCAL_PROFILE.with(|v|v.get())&&!MACRO_CONTEXT.with(|v|v.get())));
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

fn format_builtin(id:&str)->bool{is_builtin(id,"hb_ttoc")||is_builtin(id,"hb_dtoc")}
fn valid_mask(s:&str,time:bool)->bool{
 if s.len()>128||(!time&&s.len()>10)||!s.is_ascii(){return false;}
 let b=s.as_bytes();let mut i=0;let mut seen=std::collections::HashSet::new();
 while i<b.len(){let c=b[i].to_ascii_uppercase();let mut j=i+1;while j<b.len()&&b[j].to_ascii_uppercase()==c{j+=1;}let n=j-i;
 let ok=if time{match c{b'H'|b'M'|b'S'=>n==2,b'F'=>n==3,b'A'..=b'Z'=>false,_=>true}}else{match c{b'Y'=>n==2||n==4,b'M'|b'D'=>n==2,b'A'..=b'Z'=>false,_=>true}};
 if !ok{return false;}if c.is_ascii_alphabetic()&&!seen.insert(c){return false;}i=j;}true
}
fn check_format(id:&str,args:&[Expr],env:&mut [Local],sigs:&mut Vec<Sig>,n:usize)->Result<Ty,String>{
 let max=if is_builtin(id,"hb_dtoc"){2}else{3};
 if args.is_empty()||args.len()>max{return Err(format!("line {}: {} takes 1..{} arguments",n,id,max));}
 if !DECIMAL_LOCAL_PROFILE.with(|v|v.get())||MACRO_CONTEXT.with(|v|v.get()){return Err(format!("line {}: timestamp formats require ordinary Linux",n));}
 let t=type_expr(&args[0],env,sigs,n)?;
 if !matches!(t,Ty::Date|Ty::Dyn){return Err(format!("line {}: {} expects date/timestamp",n,id));}
 for(i,a)in args.iter().enumerate().skip(1){if !matches!(a,Expr::Str(s) if valid_mask(s,i==2)){return Err(format!("line {}: timestamp format subset requires literal ASCII masks <=128 bytes; date YYYY/YY MM DD, time HH MM SS fff, punctuation only",n));}}
 Ok(Ty::StrOwn)
}
fn emit_format(id:&str,args:&[Expr],env:&[CgLocal],sigs:&[Sig],strs:&mut Vec<String>,out:&mut String,target:Target){
 let e=&args[0];let t=expr_ty(e,env,sigs);cg_value(e,env,sigs,strs,out,target);
 if t==Ty::Date{out.push_str("    mov %rax, %rdi\n    call hbc_ts_from_date\n");}
 else{let k=fresh_lbl();out.push_str(&format!("    cmp $11, %rax\n    jne .Ltsfmtstamp{k}\n    mov %rdx, %rdi\n    call hbc_ts_from_date\n    jmp .Ltsfmtready{k}\n.Ltsfmtstamp{k}:\n    cmp $17, %rax\n    je .Ltsfmtvalid{k}\n"));
 if dyn_expr_owned(e){out.push_str("    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n");cg_concat_drop(out,0);out.push_str("    add $16, %rsp\n");}
 out.push_str(&format!("    jmp hbc_type_error\n.Ltsfmtvalid{k}:\n    mov %rdx, %rax\n.Ltsfmtready{k}:\n"));}
 out.push_str("    sub $48, %rsp\n    mov %rax, (%rsp)\n");
 let mut flags=0;
 if let Some(df)=args.get(1){cg_value(df,env,sigs,strs,out,target);out.push_str("    mov %rax, 8(%rsp)\n    mov %rdx, 16(%rsp)\n");}else{flags|=1;out.push_str("    movq $0, 8(%rsp)\n    movq $0, 16(%rsp)\n");}
 if let Some(tf)=args.get(2){cg_value(tf,env,sigs,strs,out,target);out.push_str("    mov %rax, 24(%rsp)\n    mov %rdx, 32(%rsp)\n");}else{flags|=2;out.push_str("    movq $0, 24(%rsp)\n    movq $0, 32(%rsp)\n");}
 if is_builtin(id,"hb_dtoc"){flags|=4;}
 out.push_str(&format!("    mov (%rsp), %rdi\n    mov 8(%rsp), %rsi\n    mov 16(%rsp), %rdx\n    mov 24(%rsp), %rcx\n    mov 32(%rsp), %r8\n    mov ${flags}, %r9d\n    call hbc_ts_format\n    add $48, %rsp\n"));
}

// Phase3 array bridge is independently bounded to timestamp programs without classes.
thread_local!{static CONTAINERS:std::cell::Cell<bool>=const{std::cell::Cell::new(false)};}
pub(super) fn containers()->bool{CONTAINERS.with(|v|v.get())}

// Compare only two timestamps. Mixed Date/timestamp has different Harbour
// coercions per operator and is a named runtime limit, not payload ordering.
pub(super) fn comparison_helpers(out:&mut String){
 for (h,ordering) in [("hbc_dyn_eq",false),("hbc_dynxeq_dd",false),("hbc_dynxcmp",true)]{
  let k=fresh_lbl();let mut s=format!("{h}:\n    cmp $17, %rax\n    je .Ltscmp{k}\n    cmp $17, %rcx\n    jne .Ltscmpold{k}\n.Ltscmp{k}:\n");
  if !ordering{s.push_str(&format!("    cmp $1, %rax\n    je .Ltscmpfalse{k}\n    cmp $1, %rcx\n    je .Ltscmpfalse{k}\n"));}
  s.push_str(&format!("    cmp $17, %rax\n    jne hbc_type_error\n    cmp $17, %rcx\n    jne hbc_type_error\n    cmp %r8, %rdx\n"));
  if ordering{s.push_str(&format!("    je .Ltscmpzero{k}\n    jb .Ltscmpless{k}\n    mov $1, %eax\n    ret\n.Ltscmpless{k}:\n    mov $-1, %rax\n    ret\n.Ltscmpzero{k}:\n    xor %eax, %eax\n    ret\n"));}
  else{s.push_str(&format!("    sete %al\n    movzbq %al, %rax\n    ret\n.Ltscmpfalse{k}:\n    xor %eax, %eax\n    ret\n"));}
  s.push_str(&format!(".Ltscmpold{k}:\n"));*out=out.replace(&format!("{h}:\n"),&s);
 }
}
