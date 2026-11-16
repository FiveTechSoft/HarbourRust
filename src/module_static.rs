//! Single-source module storage. No owned payload or runtime initializer here.
use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use crate::{Expr, Func, Stmt};

thread_local! {
    // Function-local spelling -> canonical module slot; local shadows are absent.
    static ALIASES: RefCell<HashMap<(String, String), usize>> = RefCell::new(HashMap::new());
    static EMITTED: RefCell<HashSet<String>> = RefCell::new(HashSet::new());
}

pub fn reset() {
    ALIASES.with(|v| v.borrow_mut().clear());
    EMITTED.with(|v| v.borrow_mut().clear());
}

pub fn storage(owner: &str, name: &str) -> String {
    ALIASES.with(|v| match v.borrow().get(&(owner.to_owned(), name.to_owned())) {
        Some(index) => format!("hbc_module_i64_{}", index),
        None => format!("hbc_static_{}_{}_{}", owner.len(), owner, name),
    })
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

pub fn bind(f: &mut Func, slots: &[(usize, String, Expr)]) -> Result<(), String> {
    let mut prefix = Vec::new();
    for (index, (line, name, init)) in slots.iter().enumerate() {
        if f.params.contains(name) || declaration(&f.stmts, name, false)? { continue; }
        if !crate::stmts_mention(&f.stmts, name) { continue; }
        check_counters(&f.stmts, name)?;
        ALIASES.with(|v| v.borrow_mut().insert((f.name.clone(), name.clone()), index));
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
