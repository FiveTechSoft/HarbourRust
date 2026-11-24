// Own MIT bounded NIL/empty-array selection. Mutable extension borrows the
// caller slot or owns a frame-scoped empty fallback, with no escaping alias.
use super::*;
thread_local! {
    static MUTABLE: std::cell::RefCell<std::collections::HashSet<(String,String)>> = std::cell::RefCell::new(std::collections::HashSet::new());
    static NAMES: std::cell::RefCell<std::collections::HashSet<(String,String)>> = std::cell::RefCell::new(std::collections::HashSet::new());
    static PARAMS: std::cell::RefCell<std::collections::HashSet<(String,usize)>> = std::cell::RefCell::new(std::collections::HashSet::new());
}
pub fn parameter(f: &str, i: usize) -> bool { PARAMS.with(|s|s.borrow().contains(&(f.to_string(),i))) }
pub fn current(p:&str)->bool { NAMES.with(|s|s.borrow().contains(&(CUR_FN.with(|c|c.borrow().clone()),p.to_string()))) }
pub fn selected(e: &Expr) -> Option<&str> {
    let Expr::Call(id,aa)=e else{return None};
    if !is_builtin(id,"iif") || aa.len()!=3{return None;}
    let Expr::Cmp(op,a,b)=&aa[0] else{return None};
    let p=match (&**a,&**b) {(Expr::Var(p),Expr::Nil)|(Expr::Nil,Expr::Var(p))=>p,_=>return None};
    let (empty,value)=match op {CmpOp::Eq|CmpOp::EqEq=>(&aa[1],&aa[2]),CmpOp::Ne=>(&aa[2],&aa[1]),_=>return None};
    if matches!(empty,Expr::DArrNew) && matches!(value,Expr::Var(v) if v==p){Some(p)}else{None}
}
fn safe_expr(e:&Expr,p:&str,locals:&[String])->bool {
    if !aview_mentions(e,p) && !locals.iter().any(|q|aview_mentions(e,q)){return true;}
    match e {
        Expr::Call(id,aa) if is_builtin(id,"len") && aa.len()==1 && matches!(&aa[0],Expr::Var(q) if locals.contains(q))=>true,
        Expr::Call(_,aa)|Expr::Seq(aa)|Expr::ArrLit(aa)=>aa.iter().all(|e|safe_expr(e,p,locals)),
        Expr::Bin(_,a,b)|Expr::Cmp(_,a,b)|Expr::LAnd(a,b)|Expr::LOr(a,b)=>safe_expr(a,p,locals)&&safe_expr(b,p,locals),
        Expr::LNot(a)=>safe_expr(a,p,locals),
        _=>false,
    }
}
fn safe_stmts(ss:&[Stmt],p:&str,locals:&[String],top:bool)->bool {
    ss.iter().all(|s|match s {
        Stmt::AAdd(_,q,e) if locals.contains(q)=>!aview_mentions(e,p)&&!locals.iter().any(|x|aview_mentions(e,x))&&matches!(e,Expr::Int(_)|Expr::Log(_)|Expr::Nil),
        Stmt::Local(_,q,e) if top && locals.contains(q)=>selected(e)==Some(p),
        Stmt::Local(_,q,e)|Stmt::Assign(_,q,e)=>q!=p&&!locals.contains(q)&&safe_expr(e,p,locals),
        Stmt::Print(_,aa,_)=>aa.iter().all(|e|safe_expr(e,p,locals)),
        Stmt::Ret(_,Some(e))|Stmt::CallStmt(_,e)|Stmt::Break(_,e)=>safe_expr(e,p,locals),
        Stmt::Ret(_,None)|Stmt::Exit(_)|Stmt::Loop(_)=>true,
        Stmt::If(_,e,a,b)=>safe_expr(e,p,locals)&&safe_stmts(a,p,locals,false)&&safe_stmts(b,p,locals,false),
        Stmt::While(_,e,ss)=>safe_expr(e,p,locals)&&safe_stmts(ss,p,locals,false),
        Stmt::For(_,q,a,b,_,ss)=>q!=p&&!locals.contains(q)&&safe_expr(a,p,locals)&&safe_expr(b,p,locals)&&safe_stmts(ss,p,locals,false),
        _=>false,
    })
}
pub fn analyze(ff:&[Func]) {
    MUTABLE.with(|s|s.borrow_mut().clear());
    PARAMS.with(|s|s.borrow_mut().clear());NAMES.with(|s|s.borrow_mut().clear());
    if !DECIMAL_LOCAL_PROFILE.with(|v|v.get())||MACRO_CONTEXT.with(|v|v.get())||EXTERNS.with(|v|!v.borrow().is_empty()){return;}
    let mut indirect=std::collections::HashSet::new();
    for caller in ff {visit_stmts_ref(&caller.stmts,&mut |_|{},&mut |e|{if let Expr::FuncRef(id)=e {indirect.insert(id.clone());}});}
    for f in ff {
        if METHOD_CLASS.with(|m|m.borrow().contains_key(&f.name)) || indirect.contains(&f.name){continue;}
        for(i,p)in f.params.iter().enumerate(){
            if root_param(&f.name,p){continue;}
            let locals:Vec<String>=f.stmts.iter().filter_map(|s|match s {Stmt::Local(_,q,e) if q!=p&&selected(e)==Some(p)=>Some(q.clone()),_=>None}).collect();
            if !locals.is_empty() && !f.params.iter().any(|p|locals.contains(p)) && safe_stmts(&f.stmts,p,&locals,true) {
                let mut mutation=false;visit_stmts_ref(&f.stmts,&mut |st|{if matches!(st,Stmt::AAdd(_,q,_) if locals.contains(q)){mutation=true;}},&mut |_|{});
                if mutation{MUTABLE.with(|s|s.borrow_mut().insert((f.name.clone(),p.clone())));}
                NAMES.with(|s|s.borrow_mut().insert((f.name.clone(),p.clone())));
                PARAMS.with(|s|s.borrow_mut().insert((f.name.clone(),i)));
            }
        }
    }
}
pub fn active(e:&Expr,env:&[CgLocal])->Option<usize>{
    let p=selected(e)?;
    if !current(p){return None;}
    env.iter().rev().find(|v|v.name==p&&v.ty==Ty::AView).map(|v|v.off)
}
pub fn emit_select(off:usize,out:&mut String){
    if mutable_current(){emit_mut_select(off,out);return;}
    let k=fresh_lbl();let slot=aview_scratch();
    // Kind 5 is the private NIL sentinel, never an array accessor input.
    out.push_str(&format!("    mov -{off}(%rbp), %rax\n    cmpq $5, (%rax)\n    jne .Loptview{k}\n    movq $1, -{slot}(%rbp)\n    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n    lea -{slot}(%rbp), %rax\n.Loptview{k}:\n",slot-8,slot-16));
}
pub fn emit_nil(out:&mut String){
    let slot=aview_scratch();
    out.push_str(&format!("    movq $5, -{slot}(%rbp)\n    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n    lea -{slot}(%rbp), %rax\n    sub $16, %rsp\n    mov %rax, (%rsp)\n    movq $0, 8(%rsp)\n",slot-8,slot-16));
}

pub fn any_mutable()->bool{MUTABLE.with(|s|!s.borrow().is_empty())}
pub fn mutable_current()->bool{CUR_FN.with(|f|MUTABLE.with(|s|s.borrow().iter().any(|(n,_)|n==&*f.borrow())))}
pub fn mutable_parameter(f:&str,i:usize)->bool{parameter(f,i)&&MUTABLE.with(|s|s.borrow().iter().any(|(n,_)|n==f))}
pub fn selected_local(f:&str,v:&str,ss:&[Stmt])->bool{MUTABLE.with(|s|s.borrow().iter().any(|(n,p)|n==f&&ss.iter().any(|st|matches!(st,Stmt::Local(_,q,e) if q==v&&selected(e)==Some(p.as_str())))))}
fn emit_mut_select(off:usize,out:&mut String){
 let k=fresh_lbl();let pair=aview_scratch();let hdr=aview_scratch();
 out.push_str(&format!("    mov -{off}(%rbp), %rax\n    cmpq $5, (%rax)\n    jne .Lmutopt{k}\n    movq $0, -{pair}(%rbp)\n    movq $0, -{}(%rbp)\n    movq $8, -{hdr}(%rbp)\n    lea -{pair}(%rbp), %r11\n    mov %r11, -{}(%rbp)\n    movq $0, -{}(%rbp)\n    movq $1, -{}(%rbp)\n    lea -{hdr}(%rbp), %rax\n.Lmutopt{k}:\n",pair-8,hdr-8,hdr-16,hdr-24));
}
pub fn emit_mut_argument(root:&CgLocal,out:&mut String){
 let hdr=aview_scratch();
 out.push_str(&format!("    movq $8, -{hdr}(%rbp)\n    lea -{}(%rbp), %rax\n    mov %rax, -{}(%rbp)\n    movq $0, -{}(%rbp)\n    movq $0, -{}(%rbp)\n    lea -{hdr}(%rbp), %rax\n",root.off,hdr-8,hdr-16,hdr-24));
}
