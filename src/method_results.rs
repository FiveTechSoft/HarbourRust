// Own MIT descriptor-selected method result ABI. No shared-array/object heap merge.
use super::*;
use std::collections::HashSet;
thread_local!{static PARAMS:std::cell::RefCell<HashSet<(String,String)>>=std::cell::RefCell::new(HashSet::new());}
pub fn parameter(f:&str,p:&str)->bool{PARAMS.with(|v|v.borrow().contains(&(f.to_string(),p.to_string())))}
thread_local!{static POS:std::cell::RefCell<HashSet<(String,usize)>>=std::cell::RefCell::new(HashSet::new());}
pub fn position(f:&str,i:usize)->bool{POS.with(|v|v.borrow().contains(&(f.to_string(),i)))}
pub fn active()->bool{PARAMS.with(|v|!v.borrow().is_empty())}
pub fn choices(name:&str)->Vec<(u32,String)>{let n=CLASSES.with(|v|v.borrow().len());(0..n as u32).filter_map(|ci|method_lookup(ci,&name.to_lowercase()).map(|(_,f)|(ci,f))).collect()}
pub fn init(ff:&[Func]){
 PARAMS.with(|v|v.borrow_mut().clear());POS.with(|v|v.borrow_mut().clear());
 if !DECIMAL_LOCAL_PROFILE.with(|v|v.get())||MACRO_CONTEXT.with(|v|v.get())||EXTERNS.with(|v|!v.borrow().is_empty())||module_static::has_objects(){return;}
 for f in ff {if METHOD_CLASS.with(|v|v.borrow().contains_key(&f.name)){continue;}
 visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::Send(o,n,_)=e{if let Expr::Var(p)=o.as_ref(){if f.params.contains(p)&&receiver_pin_class(n).is_err(){PARAMS.with(|v|{v.borrow_mut().insert((f.name.clone(),p.clone()));});POS.with(|v|{v.borrow_mut().insert((f.name.clone(),f.params.iter().position(|x|x==p).unwrap()));});}}}});}
}
pub fn send(e:&Expr)->bool{matches!(e,Expr::Send(o,_,_) if matches!(o.as_ref(),Expr::Var(p) if parameter(&CUR_FN.with(|v|v.borrow().clone()),p)))}
pub fn check(e:&Expr,env:&mut [Local],sigs:&mut Vec<Sig>,line:usize)->Result<Ty,String>{
 let Expr::Send(o,n,args)=e else{unreachable!()};let Expr::Var(p)=o.as_ref() else{unreachable!()};
 if !matches!(env.iter().find(|v|v.name==*p),Some(v) if v.ty==Ty::Dyn&&!v.moved){return Err(format!("line {}: dynamic method receiver is not live",line));}
 for a in args{if !plain_arg(a){return Err(format!("line {}: B1 dynamic message arguments must be plain variables or literals; compute expressions first",line));}let t=type_expr(a,env,sigs,line)?;if !matches!(t,Ty::I64|Ty::Bool|Ty::Date){return Err(format!("line {}: B1 dynamic message arguments require integer/logical/date values",line));}}
 let cc=choices(n);if cc.is_empty(){return Err(format!("line {}: dynamic message has no method",line));}
 for(ci,f)in cc{let mut local=env.to_vec();local.iter_mut().find(|v|v.name==*p).unwrap().ty=Ty::Obj(ci);let mut aa=vec![Expr::Var(p.clone())];aa.extend(args.iter().cloned());let t=type_expr(&Expr::Call(f,aa),&mut local,sigs,line)?;
 if !matches!(t,Ty::I64|Ty::Bool|Ty::Date|Ty::Str|Ty::StrOwn|Ty::F64|Ty::Dyn|Ty::Obj(_)){return Err(format!("line {}: B1 method result is outside scalar/object scope",line));}}
 Ok(Ty::Dyn)
}
pub fn emit(e:&Expr,env:&[CgLocal],sigs:&[Sig],strs:&mut Vec<String>,out:&mut String,target:Target){
 let Expr::Send(o,n,args)=e else{unreachable!()};let Expr::Var(p)=o.as_ref() else{unreachable!()};let root=env.iter().find(|v|v.name==*p).unwrap();let end=fresh_lbl();
 out.push_str(&format!("    cmpq $13, -{}(%rbp)\n    jne hbc_type_error\n    mov -{}(%rbp), %rax\n    test %rax, %rax\n    je hbc_type_error\n",root.off,root.off-8));
 for(ci,f)in choices(n){let next=fresh_lbl();out.push_str(&format!("    mov -{}(%rbp), %rax\n    lea hrobj_desc_{}(%rip), %rcx\n    cmp %rcx, (%rax)\n    jne .Lmrnext{next}\n",root.off-8,ci));
 let mut local=env.to_vec();let r=local.iter_mut().find(|v|v.name==*p).unwrap();r.ty=Ty::Obj(ci);r.off-=8;
 let mut aa=vec![Expr::Var(p.clone())];aa.extend(args.iter().cloned());let call=Expr::Call(f.clone(),aa);let t=sigs.iter().find(|s|s.name==f).and_then(|s|s.ret).unwrap();
 let saved=DISPATCH_SLOT.with(|v|v.replace(-1));
 if t==Ty::F64{cg_f64_load(&call,&local,sigs,strs,out,target);out.push_str("    mov %rdi, %rsi\n    movq %xmm0, %rdi\n    call hbc_float_new\n");}
 else{cg_value(&call,&local,sigs,strs,out,target);match t{
 Ty::I64=>cg_i64_tagged(out),Ty::Bool=>out.push_str("    mov %rax, %rdx\n    mov $3, %eax\n"),Ty::Date=>out.push_str("    mov %rax, %rdx\n    mov $11, %eax\n"),
 Ty::Str=>out.push_str("    mov %rax, %rdi\n    mov %rdx, %rsi\n    call hbc_strcpy\n    mov %rax, %rdx\n    mov $4, %eax\n"),Ty::StrOwn=>out.push_str("    mov %rax, %rdx\n    mov $4, %eax\n"),Ty::Obj(_)=>out.push_str("    mov %rax, %rdx\n    mov $13, %eax\n"),_=>{}}}
 DISPATCH_SLOT.with(|v|v.set(saved));out.push_str(&format!("    jmp .Lmrend{end}\n.Lmrnext{next}:\n"));}
 out.push_str(&format!("    call hbc_type_error\n.Lmrend{end}:\n"));
}

fn plain_arg(e:&Expr)->bool{matches!(e,Expr::Int(_)|Expr::Log(_)|Expr::Nil|Expr::Str(_)|Expr::Var(_))}
pub fn validate(ff:&[Func])->Result<(),String>{
 if !active(){return Ok(());}
 let mut bad=false;
 for f in ff {visit_stmts_ref(&f.stmts,&mut |st|{if matches!(st,Stmt::ForEach(..)|Stmt::MemvarDecl(..)|Stmt::MemvarSet(..)|Stmt::Switch(..)){bad=true;}},&mut |_|{});
 visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::HashLit(_)|Expr::ArrLit(_)|Expr::DArrNew|Expr::BlockLit(..)|Expr::ByRef(_)|Expr::FuncRef(_)|Expr::Seq(_)|Expr::Set(..)){bad=true;}});}
 for f in ff {visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::Call(id,_) if is_builtin(id,"empty")){bad=true;}});}
 for f in ff {visit_stmts_ref(&f.stmts,&mut |st|{if matches!(st,Stmt::Static(..)){bad=true;}},&mut |_|{});visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::Call(id,aa)=e{if ff.iter().any(|f|f.name==*id) && aa.iter().skip(1).any(|a|!plain_arg(a)){bad=true;}}});}
 if bad{Err("B1 mixed-method programs do not yet combine with containers, blocks, indirect calls, @, MEMVAR, SWITCH, FOR EACH, inline assignments/sequences, Empty, STATIC or effectful later arguments to ordinary functions".into())}else{Ok(())}
}

// B1 uses individual object allocations so final counters measure live
// references rather than process-lifetime slabs. Scalar DATA templates are
// still shared per descriptor and explicitly released at process exit.
pub fn runtime()->String{
 let mut s=HROBJ_BLOB.to_string();
 let a=s.find(".Lhrobj_8:").unwrap();let b=s.find(".Lhrobj_29:").unwrap();
 s.replace_range(a..b,".Lhrobj_8:\n    add $1, %eax\n    shl $4, %eax\n    mov %rax, %rdi\n    call hbc_alloc\n    mov %rax, %r14\n    movl 20(%r12), %eax\n    jmp .Lhrobj_9\n");
 let a=s.find(".Lhrobj_39:").unwrap();let b=s.find(".Lhrobj_35:").unwrap();
 s.replace_range(a..b,".Lhrobj_39:\n    mov 0(%rbp), %rax\n    movl 20(%rax), %esi\n    add $1, %esi\n    shl $4, %esi\n    mov %rbp, %rdi\n@REG_FREE_L@    incq hbc_mem_frees(%rip)\n    call hbc_release\n");s
}
pub fn cleanup(out:&mut String){
 if !active(){return;}
 for ci in 0..CLASSES.with(|c|c.borrow().len()){
 let k=fresh_lbl();out.push_str(&format!("    lea hrobj_desc_{ci}(%rip), %rax\n    mov 48(%rax), %rdi\n    test %rdi, %rdi\n    je .Lmrtemplate{k}\n    movq $0, 48(%rax)\n    mov %rdi, -8(%rbp)\n    movl 20(%rax), %eax\n    mov %rax, -16(%rbp)\n    movq $0, -24(%rbp)\n.Lmrtemplloop{k}:\n    mov -24(%rbp), %rcx\n    cmp -16(%rbp), %rcx\n    jge .Lmrtemplfree{k}\n    shl $4, %rcx\n    add -8(%rbp), %rcx\n    mov (%rcx), %rax\n    mov 8(%rcx), %rdx\n    sub $16, %rsp\n    mov %rax, (%rsp)\n    mov %rdx, 8(%rsp)\n"));
 cg_dyn_stack_release(out,0,false);
 out.push_str(&format!("    add $16, %rsp\n    incq -24(%rbp)\n    jmp .Lmrtemplloop{k}\n.Lmrtemplfree{k}:\n    mov -16(%rbp), %rsi\n    shl $4, %rsi\n    test %rsi, %rsi\n    jne .Lmrtemplsize{k}\n    mov $16, %esi\n.Lmrtemplsize{k}:\n    mov -8(%rbp), %rdi\n@REG_FREE_L@    incq hbc_mem_frees(%rip)\n    call hbc_release\n.Lmrtemplate{k}:\n"));
 }
}
