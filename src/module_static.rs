//! Single-source fixed-type module storage and persistent string ownership.
use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use crate::{Expr, Func, Stmt, Ty};

thread_local! {
    // Function-local spelling -> canonical module slot; local shadows are absent.
    static ALIASES: RefCell<HashMap<(String, String), usize>> = RefCell::new(HashMap::new());
    static KINDS: RefCell<HashMap<(String, String), Ty>> = RefCell::new(HashMap::new());
    static EMITTED: RefCell<HashSet<String>> = RefCell::new(HashSet::new());
}

pub fn reset() {
    ALIASES.with(|v| v.borrow_mut().clear());
    KINDS.with(|v| v.borrow_mut().clear());
    EMITTED.with(|v| v.borrow_mut().clear());
}

pub fn storage(owner: &str, name: &str) -> String {
    ALIASES.with(|v| match v.borrow().get(&(owner.to_owned(), name.to_owned())) {
        Some(index) => format!("hbc_module_i64_{}", index),
        None => format!("hbc_static_{}_{}_{}", owner.len(), owner, name),
    })
}

pub fn kind(owner: &str, name: &str) -> Option<Ty> {
    KINDS.with(|v| v.borrow().get(&(owner.to_owned(), name.to_owned())).copied())
}
pub fn current(name: &str) -> Option<Ty> {
    crate::CUR_FN.with(|f| kind(&f.borrow(), name))
}
pub fn string_value(e: &Expr) -> bool {
    matches!(e, Expr::Var(v) if current(v) == Some(Ty::StrOwn))
}

pub fn first_emission(label: &str) -> bool {
    EMITTED.with(|v| v.borrow_mut().insert(label.to_owned()))
}

// Classify declarations before binding. An ordinary function-local declaration
// shadows the module slot throughout the function, as measured with Harbour.
// Branch-local shadows and explicit memvars are held until their scope has its
// own lowering; never silently bind them to the process slot.
fn declaration(ss: &[Stmt], name: &str, nested: bool) -> Result<bool, String> {
    let mut shadow = false;
    for s in ss {
        match s {
            Stmt::Local(line, id, _) | Stmt::Static(line, id, _) if id == name => {
                if nested { return Err(format!("line {}: module STATIC shadow inside control flow is not in this increment", line)); }
                shadow = true;
            }
            Stmt::MemvarDecl(line, _, id) | Stmt::MemvarSet(line, _, id, _) if id == name =>
                return Err(format!("line {}: module STATIC and explicit MEMVAR/PUBLIC/PRIVATE of the same name are not in this increment", line)),
            Stmt::CatchBind(line, id) if id == name =>
                return Err(format!("line {}: module STATIC catch binding shadow is not in this increment", line)),
            Stmt::If(_, _, a, b) => { shadow |= declaration(a, name, true)?; shadow |= declaration(b, name, true)?; }
            Stmt::While(_, _, b) | Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => shadow |= declaration(b, name, true)?,
            Stmt::Try(line, b, c, f) => {
                shadow |= declaration(b, name, true)?;
                if let Some((id, body)) = c {
                    if id.as_deref() == Some(name) { return Err(format!("line {}: module STATIC catch binding shadow is not in this increment", line)); }
                    shadow |= declaration(body, name, true)?;
                }
                if let Some(body) = f { shadow |= declaration(body, name, true)?; }
            }
            Stmt::Switch(_, _, arms, other) => {
                for (_, _, body) in arms { shadow |= declaration(body, name, true)?; }
                if let Some((_, body)) = other { shadow |= declaration(body, name, true)?; }
            }
            _ => {}
        }
    }
    Ok(shadow)
}

// The historical driver validates local STATIC counters on ordinary functions
// before methods join them. Guard module bindings here as well, so methods and
// nested exception bodies cannot bypass the same persistent-counter boundary.
fn check_counters(ss: &[Stmt], name: &str) -> Result<(), String> {
    for st in ss {
        match st {
            Stmt::For(line, id, ..) | Stmt::ForEach(line, id, ..) if id == name =>
                return Err(format!("line {}: STATIC loop counters require persistent counter lowering and are not in this increment", line)),
            Stmt::If(_, _, a, b) => { check_counters(a, name)?; check_counters(b, name)?; }
            Stmt::While(_, _, b) | Stmt::For(_, _, _, _, _, b) | Stmt::ForEach(_, _, _, b) => check_counters(b, name)?,
            Stmt::Try(_, b, c, f) => {
                check_counters(b, name)?;
                if let Some((_, body)) = c { check_counters(body, name)?; }
                if let Some(body) = f { check_counters(body, name)?; }
            }
            Stmt::Switch(_, _, arms, other) => {
                for (_, _, body) in arms { check_counters(body, name)?; }
                if let Some((_, body)) = other { check_counters(body, name)?; }
            }
            _ => {}
        }
    }
    Ok(())
}

// New owned storage must not enter old move/container/inline-write routes.
// Simple expression borrows, explicit ownership copies, and @string calls have
// measured lowering. Dynamic containers and compound call effects remain held.
fn check_payload_uses(f: &Func, name: &str, ty: Ty) -> Result<(), String> {
    fn may_mutate(e: &Expr) -> bool {
        match e {
            Expr::Call(id,es) => !["len","asc","left","right","substr","upper","lower","trim","ltrim","rtrim","alltrim","valtype","hb_isnumeric","hb_isstring","hb_isarray","chr","space","replicate"].iter().any(|b|crate::is_builtin(id,b)) || es.iter().any(may_mutate),
            Expr::Set(..)|Expr::Inc(..)|Expr::Send(..)=>true,
            Expr::Bin(_,a,b)|Expr::Cmp(_,a,b)|Expr::LAnd(a,b)|Expr::LOr(a,b)=>may_mutate(a)||may_mutate(b),
            Expr::Seq(es)|Expr::ArrLit(es)|Expr::BlockLit(_,_,es)=>es.iter().any(may_mutate),
            Expr::LNot(e)|Expr::Index(_,e)=>may_mutate(e),
            _=>false,
        }
    }
    fn expr(e: &Expr, name: &str, ty: Ty) -> bool {
        match e {
            Expr::ByRef(v) if v == name => ty != Ty::Bool,
            Expr::Set(v, _) | Expr::Inc(v, ..) if v == name => false,
            Expr::ArrLit(es) => !es.iter().any(|e| crate::expr_mentions(e,name)),
            Expr::HashLit(es) => !es.iter().any(|(k,v)| crate::expr_mentions(k,name)||crate::expr_mentions(v,name)),
            Expr::Bin(_,a,b) | Expr::Cmp(_,a,b) | Expr::LAnd(a,b) | Expr::LOr(a,b) => {
                if ty == Ty::StrOwn && crate::expr_mentions(e,name) && crate::expr_has_call(e) {return false;}
                expr(a,name,ty) && expr(b,name,ty)
            }
            Expr::Seq(es) => !(ty == Ty::StrOwn && es.iter().any(|e|crate::expr_mentions(e,name))) && es.iter().all(|e|expr(e,name,ty)),
            Expr::Call(id,es) => {
                if ty == Ty::StrOwn && ["iif","eval"].iter().any(|b|crate::is_builtin(id,b)) && es.iter().any(|e|crate::expr_mentions(e,name)) {return false;}
                if ty == Ty::StrOwn && es.iter().any(|e|crate::expr_mentions(e,name)) && es.iter().any(may_mutate) {return false;}
                es.iter().all(|e|expr(e,name,ty))
            }
            Expr::BlockLit(_,_,es) => es.iter().all(|e|expr(e,name,ty)),
            Expr::Set(_,e) | Expr::LNot(e) | Expr::Index(_,e) => expr(e,name,ty),
            Expr::Send(o,_,es) => !(ty == Ty::StrOwn && crate::expr_mentions(e,name)) && expr(o,name,ty)&&es.iter().all(|e|expr(e,name,ty)),
            Expr::Var(_) | Expr::ByRef(_) => true,
            _ => !crate::expr_mentions(e,name),
        }
    }
    fn walk(ss: &[Stmt], name:&str,ty:Ty)->bool {
        ss.iter().all(|s|match s {
            Stmt::Local(_,_,e)|Stmt::Assign(_,_,e)|Stmt::Ret(_,Some(e))|Stmt::CallStmt(_,e)|Stmt::SendStmt(_,e)=>expr(e,name,ty),
            Stmt::Print(_,es,_)=>!(ty == Ty::StrOwn && es.iter().any(|e|crate::expr_mentions(e,name)) && es.iter().any(may_mutate)) && es.iter().all(|e|expr(e,name,ty)),
            Stmt::If(_,e,a,b)=>expr(e,name,ty)&&walk(a,name,ty)&&walk(b,name,ty),
            Stmt::While(_,e,b)=>expr(e,name,ty)&&walk(b,name,ty),
            Stmt::Try(_,b,c,f)=>walk(b,name,ty)&&c.as_ref().map_or(true,|(_,b)|walk(b,name,ty))&&f.as_ref().map_or(true,|b|walk(b,name,ty)),
            Stmt::For(_,_,a,b,_,body)=>expr(a,name,ty)&&expr(b,name,ty)&&walk(body,name,ty),
            Stmt::ForEach(_,_,e,body)=>expr(e,name,ty)&&walk(body,name,ty),
            Stmt::Switch(_,e,arms,other)=>expr(e,name,ty)&&arms.iter().all(|(_,_,b)|walk(b,name,ty))&&other.as_ref().map_or(true,|(_,b)|walk(b,name,ty)),
            Stmt::Static(..)|Stmt::Ret(_,None)|Stmt::Exit(_)|Stmt::Loop(_)=>true,
            _ => !crate::stmt_mentions(s,name),
        })
    }
    if !walk(&f.stmts,name,ty) {return Err(format!("module STATIC `{}`: owned/container/inline-effect or logical by-reference use is outside this increment",name));}
    Ok(())
}

pub fn bind(f: &mut Func, slots: &[(usize, String, Expr)]) -> Result<(), String> {
    let mut prefix = Vec::new();
    for (index, (line, name, init)) in slots.iter().enumerate() {
        if f.params.contains(name) || declaration(&f.stmts, name, false)? { continue; }
        if !crate::stmts_mention(&f.stmts, name) { continue; }
        check_counters(&f.stmts, name)?;
        ALIASES.with(|v| v.borrow_mut().insert((f.name.clone(), name.clone()), index));
        let ty = match init { Expr::Log(_) => Ty::Bool, Expr::Str(_) => Ty::StrOwn, _ => Ty::I64 };
        if matches!(ty,Ty::Bool|Ty::StrOwn) {check_payload_uses(f,name,ty)?;}
        KINDS.with(|v| v.borrow_mut().insert((f.name.clone(), name.clone()), ty));
        prefix.push(Stmt::Static(*line, name.clone(), init.clone()));
    }
    prefix.append(&mut f.stmts);
    f.stmts = prefix;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn shared_canonical_label_and_single_emission() {
        crate::parse("STATIC n := 1\nFUNCTION Main()\n? n\nRETURN NIL\nFUNCTION ReadN()\nRETURN n\n").unwrap_or_else(|e| panic!("{}", e));
        let a = storage("main", "n");
        assert_eq!(a, storage("readn", "n"));
        assert!(a.starts_with("hbc_module_i64_"));
        assert!(first_emission(&a));
        assert!(!first_emission(&a));
    }
    #[test]
    fn local_static_keeps_independent_identity() {
        crate::parse("STATIC n := 1\nFUNCTION Main()\n? n\nRETURN NIL\nFUNCTION PrivateN()\nSTATIC n := 7\nRETURN n\n").unwrap_or_else(|e| panic!("{}", e));
        assert_ne!(storage("main", "n"), storage("privaten", "n"));
        assert_eq!(storage("privaten", "n"), "hbc_static_8_privaten_n");
    }
    #[test]
    fn parse_resets_binding_and_emission_state() {
        crate::parse("STATIC n := 1\nFUNCTION Main()\n? n\nRETURN NIL\n").unwrap_or_else(|e| panic!("{}", e));
        let old = storage("main", "n");
        assert!(first_emission(&old));
        crate::parse("FUNCTION Main()\nSTATIC n := 2\n? n\nRETURN NIL\n").unwrap_or_else(|e| panic!("{}", e));
        assert_ne!(old, storage("main", "n"));
        assert!(first_emission(&old));
    }
}

#[cfg(test)]
mod owned_tests {
    use super::*;
    #[test]
    fn distinct_fixed_payloads_and_reset() {
        crate::parse("STATIC flag := .T., text := \"seed\"\nFUNCTION Main()\n? flag,text\nRETURN NIL\n").unwrap_or_else(|e|panic!("{}",e));
        assert_eq!(kind("main","flag"),Some(Ty::Bool));
        assert_eq!(kind("main","text"),Some(Ty::StrOwn));
        crate::parse("FUNCTION Main()\nRETURN NIL\n").unwrap_or_else(|e|panic!("{}",e));
        assert_eq!(kind("main","text"),None);
    }
    #[test]
    fn guard_nested_counter_and_catch_without_losing_i64() {
        assert!(crate::parse("STATIC n := 0\nFUNCTION Main()\nTRY\nFOR n := 1 TO 3\n? n\nNEXT\nCATCH\n? 1\nEND\nRETURN NIL\n").err().unwrap().contains("STATIC loop counters"));
        assert!(crate::parse("STATIC s := \"x\"\nFUNCTION Main()\nTRY\nBreak(1)\nCATCH s\n? s\nEND\nRETURN NIL\n").err().unwrap().contains("catch binding shadow"));
    }
}
