// Own MIT structurally checked LEN-only borrow of a received array cell.
// Scalar locals, control flow and returns may use its length, never its owner.
use super::*;
thread_local! {
    static LEAVES: std::cell::RefCell<std::collections::HashSet<(String,usize)>> = std::cell::RefCell::new(std::collections::HashSet::new());
}
pub fn parameter(id:&str,i:usize)->bool {LEAVES.with(|s|s.borrow().contains(&(id.to_string(),i)))}
pub fn analyze(ff:&[Func]) {
    PARAM_NAMES.with(|m|{let mut m=m.borrow_mut();m.clear();for f in ff{for(i,p)in f.params.iter().enumerate(){m.insert((f.name.clone(),i),p.clone());}}});
    LEAVES.with(|s|s.borrow_mut().clear());
    if !DECIMAL_LOCAL_PROFILE.with(|v|v.get()) || MACRO_CONTEXT.with(|v|v.get()) || EXTERNS.with(|v|!v.borrow().is_empty()){return;}
    let mut indirect=std::collections::HashSet::new();
    for f in ff {visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::FuncRef(id)=e {indirect.insert(id.clone());}});}
    // A cell is borrowed only through LEN. Other scalar locals, control
    // flow, additional parameters and return arithmetic do not change that.
    fn ex(e:&Expr,p:&str)->bool {
        if !aview_mentions(e,p){return true;}
        match e {
            Expr::Call(id,aa) if is_builtin(id,"len")=>matches!(aa.as_slice(),[Expr::Var(v)] if v==p),
            Expr::Call(_,aa)|Expr::Seq(aa)=>aa.iter().all(|x|ex(x,p)),
            Expr::Bin(_,a,b)|Expr::Cmp(_,a,b)|Expr::LAnd(a,b)|Expr::LOr(a,b)=>ex(a,p)&&ex(b,p),
            Expr::LNot(a)=>ex(a,p),_=>false,
        }
    }
    fn safe(ss:&[Stmt],p:&str)->bool {ss.iter().all(|s|match s{
        Stmt::Local(_,v,e)|Stmt::Assign(_,v,e)=>v!=p&&ex(e,p),
        Stmt::Ret(_,Some(e))|Stmt::CallStmt(_,e)|Stmt::Break(_,e)=>ex(e,p),
        Stmt::Print(_,aa,_)=>aa.iter().all(|e|ex(e,p)),
        Stmt::If(_,c,a,b)=>ex(c,p)&&safe(a,p)&&safe(b,p),
        Stmt::While(_,c,b)=>ex(c,p)&&safe(b,p),
        Stmt::For(_,v,a,b,_,ss)=>v!=p&&ex(a,p)&&ex(b,p)&&safe(ss,p),
        Stmt::Try(_,b,c,f)=>safe(b,p)&&c.as_ref().map_or(true,|(id,b)|id.as_deref()!=Some(p)&&safe(b,p))&&f.as_ref().map_or(true,|b|safe(b,p)),
        Stmt::Ret(_,None)|Stmt::Exit(_)|Stmt::Loop(_)=>true,_=>false,
    })}
    let mut leaves=std::collections::HashSet::new();
    for f in ff {
        if f.init || METHOD_CLASS.with(|m|m.borrow().contains_key(&f.name)) || indirect.contains(&f.name){continue;}
        for (i,p) in f.params.iter().enumerate(){
            let mut len=false;visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::Call(id,aa) if is_builtin(id,"len")&&matches!(aa.as_slice(),[Expr::Var(v)] if v==p)){len=true;}});
            if len&&!root_param(&f.name,p)&&safe(&f.stmts,p){leaves.insert((f.name.clone(),i));}
        }
    }
    let mut used=std::collections::HashSet::new();
    for f in ff {if METHOD_CLASS.with(|m|m.borrow().contains_key(&f.name)){continue;}
        visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::Call(id,aa)=e {
            for(i,a)in aa.iter().enumerate(){if leaves.contains(&(id.clone(),i))&&matches!(a,Expr::Index(p,idx) if f.params.contains(p)&&!root_param(&f.name,p)&&!aview_mentions(idx,p)){used.insert((id.clone(),i));}}
        }});
    }
    LEAVES.with(|s|*s.borrow_mut()=used);
}
pub fn evidence(id:&str,aa:&[Expr],p:&str)->bool {
    aa.iter().enumerate().any(|(n,a)|parameter(id,n)&&matches!(a,Expr::Index(v,i) if v==p&&!aview_mentions(i,p)))
}
pub fn emit_cell(out:&mut String) {
    let k=fresh_lbl();let slot=aview_scratch();
    // Existing subarray descriptors already carry their child view header.
    // Strings get a frame-only length header. Kind 6 is private to this
    // exact RETURN Len(parameter) proof, never input to hbc_aview_get.
    // The real callee frame/call/trace remains present; nothing is inlined.
    out.push_str(&format!("    @HBC_TAG_KIND@cmp $6, %rax@HBC_TAG_END@\n    je .Lcelllenready{k}\n    @HBC_TAG_KIND@cmp $2, %rax@HBC_TAG_END@\n    je .Lcelllenstr{k}\n    @HBC_TAG_KIND@cmp $4, %rax@HBC_TAG_END@\n    jne .Lcelllenbad{k}\n.Lcelllenstr{k}:\n    test %rdx, %rdx\n    je .Lcelllenbad{k}\n    movq $6, -{slot}(%rbp)\n    mov %rdx, -{}(%rbp)\n    mov -8(%rdx), %rax\n    mov %rax, -{}(%rbp)\n    lea -{slot}(%rbp), %rdx\n    jmp .Lcelllenready{k}\n.Lcelllenbad{k}:\n    movq $7, -{slot}(%rbp)\n    lea -{slot}(%rbp), %rdx\n.Lcelllenready{k}:\n    mov %rdx, %rax\n",slot-8,slot-16));
}

pub fn current(p:&str)->bool{CUR_FN.with(|c|{let f=c.borrow();LEAVES.with(|s|s.borrow().iter().any(|(n,i)|n==&*f && PARAM_NAMES.with(|m|m.borrow().get(&(n.clone(),*i)).map_or(false,|v|v==p))))})}
thread_local!{static PARAM_NAMES:std::cell::RefCell<std::collections::HashMap<(String,usize),String>>=std::cell::RefCell::new(std::collections::HashMap::new());}
