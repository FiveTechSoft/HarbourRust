// Own MIT bounded object-method ValType observer. No generic Dyn dispatch.
use super::*;
thread_local! {
    static SELF_RET: std::cell::RefCell<std::collections::HashSet<String>> = std::cell::RefCell::new(std::collections::HashSet::new());
    static OBS: std::cell::RefCell<std::collections::HashMap<String,(String,String)>> = std::cell::RefCell::new(std::collections::HashMap::new());
}
pub fn parameter(f:&str,i:usize)->bool {i==0 && OBS.with(|s|s.borrow().contains_key(f))}
fn shape(e:&Expr)->Option<(&str,&str)> {
    let Expr::Call(id,aa)=e else{return None};
    if !is_builtin(id,"valtype") || aa.len()!=1{return None;}
    let Expr::Send(o,name,args)=&aa[0] else{return None};
    let Expr::Var(p)=o.as_ref() else{return None};
    if !args.is_empty(){return None;}
    Some((p,name))
}
pub fn analyze(ff:&[Func]) {
    OBS.with(|s|s.borrow_mut().clear());SELF_RET.with(|s|s.borrow_mut().clear());
    for f in ff {let mut seen=false;let mut safe=true;visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::Ret(_,e)=s {seen=true;safe &= matches!(e,Some(Expr::SelfObj));}},&mut |_|{});if seen&&safe {SELF_RET.with(|s|s.borrow_mut().insert(f.name.clone()));}}
    if !DECIMAL_LOCAL_PROFILE.with(|v|v.get()) || MACRO_CONTEXT.with(|v|v.get()) || EXTERNS.with(|v|!v.borrow().is_empty()) || module_static::has_objects(){return;}
    let mut indirect=std::collections::HashSet::new();
    for f in ff {visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::FuncRef(id)=e {indirect.insert(id.clone());}});}
    for f in ff {
        if f.init || f.params.len()!=1 || METHOD_CLASS.with(|m|m.borrow().contains_key(&f.name)) || indirect.contains(&f.name) || root_param(&f.name,&f.params[0]) {continue;}
        let [Stmt::Ret(_,Some(e))]=f.stmts.as_slice() else{continue};
        if let Some((p,name))=shape(e) {if p==f.params[0] {OBS.with(|s|s.borrow_mut().insert(f.name.clone(),(p.to_string(),name.to_string())));}}
    }
}
pub fn active(f:&str,e:&Expr)->bool {
    let Some((p,n))=shape(e) else{return false};
    OBS.with(|s|s.borrow().get(f).map(|v|v.0==p && v.1==n).unwrap_or(false))
}
fn choices(name:&str)->Vec<(u32,String)> {
    let count=CLASSES.with(|c|c.borrow().len());
    (0..count as u32).filter_map(|ci|method_lookup(ci,&name.to_lowercase()).map(|(_,f)|(ci,f))).collect()
}
pub fn check(e:&Expr,env:&mut [Local],sigs:&mut Vec<Sig>,n:usize)->Result<Ty,String> {
    let (p,name)=shape(e).expect("active");
    if !matches!(env.iter().rev().find(|v|v.name==p),Some(v) if v.ty==Ty::Dyn&&!v.moved){return Err(format!("line {}: method ValType observer needs its object parameter",n));}
    let cc=choices(name);
    if cc.is_empty(){return Err(format!("line {}: method ValType observer has no measured method `{}`",n,name));}
    for (ci,f) in cc {
        if sigs.iter().find(|s|s.name==f).map(|s|s.params.len())!=Some(1){return Err(format!("line {}: method ValType observer requires a method without explicit parameters",n));}
        let mut local=env.to_vec();local.iter_mut().rev().find(|v|v.name==p).unwrap().ty=Ty::Obj(ci);
        let ty=type_expr(&Expr::Call(f.clone(),vec![Expr::Var(p.to_string())]),&mut local,sigs,n)?;
        if ty!=Ty::Bool && !(matches!(ty,Ty::Obj(_)) && SELF_RET.with(|s|s.borrow().contains(&f))){return Err(format!("line {}: method ValType observer supports logical or RETURN Self method results only, `{}` returns {}",n,f,ty_name(ty)));}
    }
    Ok(Ty::Str)
}
pub fn argument(id:&str,e:&Expr,t:Ty,n:usize)->Result<(),String> {
    let source_ok=match e {
        Expr::Var(_)=>true,
        Expr::Call(c,aa)=>aa.is_empty()&&class_find(c).is_some(),
        Expr::Send(o,m,aa) if aa.is_empty()=>match o.as_ref() {Expr::Call(c,ca) if ca.is_empty()=>class_find(c).and_then(|ci|method_lookup(ci,&m.to_lowercase())).map(|(_,f)|SELF_RET.with(|s|s.borrow().contains(&f))).unwrap_or(false),_=>false},
        _=>false,
    };
    let name=OBS.with(|s|s.borrow().get(id).unwrap().1.clone());
    if source_ok && matches!(t,Ty::Obj(ci) if method_lookup(ci,&name.to_lowercase()).is_some()){Ok(())}else{Err(format!("line {}: method ValType observer `{}` requires a typed object variable or measured direct instance owning method `{}`",n,id,name))}
}
pub fn emit(e:&Expr,env:&[CgLocal],sigs:&[Sig],strs:&mut Vec<String>,out:&mut String,target:Target) {
    let (p,name)=shape(e).expect("active");let root=env.iter().rev().find(|v|v.name==p).expect("checked");let end=fresh_lbl();
    out.push_str(&format!("    @HBC_TAG_KIND@cmpq $13, -{}(%rbp)@HBC_TAG_END@\n    jne hbc_type_error\n    mov -{}(%rbp), %rax\n    test %rax, %rax\n    je hbc_type_error\n",root.off,root.off-8));
    for (ci,f) in choices(name) {
        let next=fresh_lbl();out.push_str(&format!("    mov -{}(%rbp), %rax\n    lea hrobj_desc_{}(%rip), %rcx\n    cmp %rcx, (%rax)\n    jne .Lvtmethodnext{}\n",root.off-8,ci,next));
        let mut local=env.to_vec();let v=local.iter_mut().rev().find(|v|v.name==p).unwrap();v.ty=Ty::Obj(ci);v.off-=8;
        // Descriptor equality selected the actual implementation, including
        // inherited methods. Do not reuse another active virtual-call slot.
        let saved=DISPATCH_SLOT.with(|s|s.replace(-1));
        cg_expr_inner(&Expr::Call(f.clone(),vec![Expr::Var(p.to_string())]),&local,sigs,strs,out,target);
        DISPATCH_SLOT.with(|s|s.set(saved));
        let ty=sigs.iter().find(|s|s.name==f).and_then(|s|s.ret).expect("checked return");
        let ch=if ty==Ty::Bool {"L"} else {out.push_str("    mov %rax, %rdi\n    call hrobj_release\n");"O"};
        let si=strs.len();strs.push(ch.to_string());out.push_str(&format!("    lea .Lstr{}(%rip), %rax\n    mov $1, %edx\n    jmp .Lvtmethodend{}\n.Lvtmethodnext{}:\n",si,end,next));
    }
    out.push_str(&format!("    call hbc_type_error\n.Lvtmethodend{}:\n",end));
}
