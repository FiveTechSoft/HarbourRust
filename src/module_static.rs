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
// Absolute .data base label when `name` binds to the persistent module array
// in the function under codegen; None for every other local. Cell reads and
// writes route through this label instead of a frame slot, so every function
// sharing the binding aliases the same storage, as Harbour does.
pub fn array_base(name: &str) -> Option<String> {
    crate::CUR_FN.with(|f| {
        let owner = f.borrow().clone();
        match kind(&owner, name) {
            Some(Ty::Arr(_)) => Some(storage(&owner, name)),
            _ => None,
        }
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

// New owned storage must not enter old move/container/inline-write routes.
// Simple expression borrows, explicit ownership copies, and @string calls have
// measured lowering. Dynamic containers and compound call effects remain held.
fn check_payload_uses(f: &Func, name: &str, ty: Ty) -> Result<(), String> {
    // Conservative effect scan. Every expression form is classified on its
    // own arm and there is deliberately no wildcard: a future form fails the
    // build until it is classified here. Anything that can run user code or
    // write state counts as a possible mutation of the persistent slot;
    // multi-level indexes and hash literals carry arbitrary index/key/value
    // expressions, so they must recurse like every other composite form.
    fn may_mutate(e: &Expr) -> bool {
        match e {
            Expr::Call(id,es) => !["len","asc","left","right","substr","upper","lower","trim","ltrim","rtrim","alltrim","valtype","hb_isnumeric","hb_isstring","hb_isarray","chr","space","replicate"].iter().any(|b|crate::is_builtin(id,b)) || es.iter().any(may_mutate),
            Expr::Set(..)|Expr::Inc(..)|Expr::Send(..)|Expr::IdxCompound(..)=>true,
            Expr::Bin(_,a,b)|Expr::Cmp(_,a,b)|Expr::LAnd(a,b)|Expr::LOr(a,b)=>may_mutate(a)||may_mutate(b),
            Expr::Seq(es)|Expr::ArrLit(es)|Expr::BlockLit(_,_,es)=>es.iter().any(may_mutate),
            Expr::HashLit(ps)=>ps.iter().any(|(k,v)|may_mutate(k)||may_mutate(v)),
            Expr::LNot(e)|Expr::Index(_,e)=>may_mutate(e),
            Expr::Index2(_,a,b)=>may_mutate(a)||may_mutate(b),
            Expr::Index3(_,a,b,c)=>may_mutate(a)||may_mutate(b)||may_mutate(c),
            Expr::Index4(_,a,b,c,d)=>may_mutate(a)||may_mutate(b)||may_mutate(c)||may_mutate(d),
            // Leaves and borrows: no sub-expression, no effect of their own.
            Expr::FloatV(..)|Expr::Float(..)|Expr::Int(_)|Expr::Str(_)|Expr::Var(_)|Expr::ByRef(_)|Expr::FuncRef(_)|Expr::DArrNew|Expr::SelfObj|Expr::SelfGet(_)|Expr::Nil|Expr::Log(_)=>false,
        }
    }
    // Admission check for one expression. Also exhaustive without a wildcard,
    // for the same reason: an unclassified form must stop the build, never
    // fall through to a permissive default.
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
            Expr::Inc(..) => true, // ++/-- on another variable holds no borrow of this slot
            Expr::Send(o,_,es) => !(ty == Ty::StrOwn && crate::expr_mentions(e,name)) && expr(o,name,ty)&&es.iter().all(|e|expr(e,name,ty)),
            Expr::Var(_) | Expr::ByRef(_) => true,
            // Compound/multi-level forms with no lexical mention of the slot
            // are admitted; a mutating call hidden in their index or right
            // side is caught by the may_mutate scan at statement level.
            Expr::IdxCompound(..) | Expr::Index2(..) | Expr::Index3(..) | Expr::Index4(..) => !crate::expr_mentions(e,name),
            // Leaf forms carry no variable: nothing to mention, nothing held.
            Expr::FloatV(..)|Expr::Float(..)|Expr::Int(_)|Expr::Str(_)|Expr::Nil|Expr::Log(_)|Expr::DArrNew|Expr::SelfObj|Expr::SelfGet(_)|Expr::FuncRef(_) => true,
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

// Persistent fixed arrays admit cell reads, cell writes, len() and
// cell-by-value call arguments only. Every whole-array route (assignment
// copies, containers, calls, blocks, sends, @ borrows, structural AAdd/
// AIns/ADel/ASize/AFill ops, multi-level indexes, compound cell ops) would
// either copy where Harbour aliases or escape the fixed i64 storage model,
// so the guard rejects it by name. The expression classifier is exhaustive
// over expression forms without a wildcard, mirroring may_mutate/expr
// above: a future form stops the build until it is classified. Statements
// keep the shared mention-fallback accepted for the owned-string guard.
fn check_array_uses(f: &Func, name: &str) -> Result<(), String> {
    fn expr(e: &Expr, name: &str) -> bool {
        match e {
            // Cell read: the index may itself read other cells; recursion
            // keeps a mutating call or a nested whole-array use rejected.
            Expr::Index(_, i) => expr(i, name),
            // Multi-level indexing on the module array is out of this
            // increment; on any other array only the sub-expressions count.
            Expr::Index2(id, a, b) => id != name && expr(a, name) && expr(b, name),
            Expr::Index3(id, a, b, c) => id != name && expr(a, name) && expr(b, name) && expr(c, name),
            Expr::Index4(id, a, b, c, d) => id != name && expr(a, name) && expr(b, name) && expr(c, name) && expr(d, name),
            // No whole-array value (Harbour aliases, hbc would copy) and
            // no @ borrow of the module array, on any route.
            Expr::Var(v) | Expr::ByRef(v) => v != name,
            Expr::Set(v, e) => v != name && expr(e, name),
            Expr::Inc(v, ..) => v != name,
            Expr::IdxCompound(v, i, _, r) => v != name && expr(i, name) && expr(r, name),
            Expr::Call(id, es) => {
                // len(a) is the single whole-array call form admitted: it
                // lowers to the fixed arity constant without a value read.
                if crate::is_builtin(id, "len") && es.len() == 1 {
                    return matches!(&es[0], Expr::Var(v) if v == name) || !crate::expr_mentions(&es[0], name);
                }
                es.iter().all(|e| expr(e, name))
            }
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) | Expr::LAnd(a, b) | Expr::LOr(a, b) => expr(a, name) && expr(b, name),
            Expr::LNot(e) => expr(e, name),
            Expr::Seq(es) => es.iter().all(|e| expr(e, name)),
            Expr::ArrLit(es) => !es.iter().any(|e| crate::expr_mentions(e, name)),
            Expr::HashLit(ps) => !ps.iter().any(|(k, v)| crate::expr_mentions(k, name) || crate::expr_mentions(v, name)),
            Expr::BlockLit(..) | Expr::Send(..) => !crate::expr_mentions(e, name),
            Expr::FloatV(..) | Expr::Float(..) | Expr::Int(_) | Expr::Str(_) | Expr::Nil | Expr::Log(_) | Expr::DArrNew | Expr::SelfObj | Expr::SelfGet(_) | Expr::FuncRef(_) => true,
        }
    }
    fn walk(ss: &[Stmt], name: &str) -> bool {
        ss.iter().all(|s| match s {
            Stmt::Local(_, _, e) | Stmt::Ret(_, Some(e)) | Stmt::CallStmt(_, e) | Stmt::SendStmt(_, e) => expr(e, name),
            // Whole-array assignment is the copy/alias divergence itself.
            Stmt::Assign(_, v, e) => v != name && expr(e, name),
            Stmt::Print(_, es, _) => es.iter().all(|e| expr(e, name)),
            // Cell write on any array: value first, then index, each
            // classified; a[i] := a[j] stays a pure i64 copy.
            Stmt::ArrSet(_, _, ie, e) => expr(ie, name) && expr(e, name),
            Stmt::If(_, e, a, b) => expr(e, name) && walk(a, name) && walk(b, name),
            Stmt::While(_, e, b) => expr(e, name) && walk(b, name),
            Stmt::Try(_, b, c, f) => walk(b, name) && c.as_ref().map_or(true, |(_, b)| walk(b, name)) && f.as_ref().map_or(true, |b| walk(b, name)),
            Stmt::For(_, _, a, b, _, body) => expr(a, name) && expr(b, name) && walk(body, name),
            Stmt::ForEach(_, _, e, body) => expr(e, name) && walk(body, name),
            Stmt::Switch(_, e, arms, other) => expr(e, name) && arms.iter().all(|(_, _, b)| walk(b, name)) && other.as_ref().map_or(true, |(_, b)| walk(b, name)),
            Stmt::Static(..) | Stmt::Ret(_, None) | Stmt::Exit(_) | Stmt::Loop(_) => true,
            _ => !crate::stmt_mentions(s, name),
        })
    }
    if !walk(&f.stmts, name) {
        return Err(format!("module STATIC `{}`: whole-array, structural, multi-level, compound-cell or by-reference use is outside this increment", name));
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
        let ty = match init { Expr::Log(_) => Ty::Bool, Expr::Str(_) => Ty::StrOwn, Expr::ArrLit(es) => Ty::Arr(es.len()), _ => Ty::I64 };
        if matches!(ty,Ty::Bool|Ty::StrOwn) {check_payload_uses(f,name,ty)?;}
        if matches!(ty,Ty::Arr(_)) {check_array_uses(f,name)?;}
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
    fn guard_rejects_hidden_mutation_in_multilevel_index_hash_method_and_block() {
        // Every form below is valid Harbour, but borrows the persistent
        // string in a statement whose hidden call can release its owner.
        // The original wildcard may_mutate classified Index2/3/4 and HashLit
        // as pure and let the first of these through (use-after-free).
        let cases = [
            // The reported repro: one-level Index was covered, Index2 was not.
            "STATIC text := \"old\"\nPROCEDURE Main()\nLOCAL a := {{1}}\n? text, a[Change(),1]\nRETURN\nFUNCTION Change()\ntext := \"new\"\nRETURN 1\n",
            "STATIC text := \"old\"\nPROCEDURE Main()\nLOCAL a := {{{1}}}\n? text, a[Change(),1,1]\nRETURN\nFUNCTION Change()\ntext := \"new\"\nRETURN 1\n",
            "STATIC text := \"old\"\nPROCEDURE Main()\nLOCAL a := {{{{1}}}}\n? text, a[Change(),1,1,1]\nRETURN\nFUNCTION Change()\ntext := \"new\"\nRETURN 1\n",
            // Hash literal value hiding the call.
            "STATIC text := \"old\"\nPROCEDURE Main()\n? text, {\"k\"=>Change()}\nRETURN\nFUNCTION Change()\ntext := \"new\"\nRETURN 1\n",
            // Index nested inside an index.
            "STATIC text := \"old\"\nPROCEDURE Main()\nLOCAL a := {{1}}\n? text, a[a[Change(),1],1]\nRETURN\nFUNCTION Change()\ntext := \"new\"\nRETURN 1\n",
            // Method send mixing the borrow with a mutating receiver chain.
            "STATIC text := \"old\"\nCLASS Holder\nMETHOD Change()\nENDCLASS\nMETHOD Change() CLASS Holder\ntext := \"new\"\nRETURN 1\nPROCEDURE Main()\nLOCAL o := Holder():New()\n? text, o:Change()\nRETURN\n",
            // Code block body hiding the call.
            "STATIC text := \"old\"\nPROCEDURE Main()\n? text, {|| Change()}\nRETURN\nFUNCTION Change()\ntext := \"new\"\nRETURN 1\n",
            // Call argument mixing the borrow with a mutating index.
            "STATIC text := \"old\"\nPROCEDURE Main()\nLOCAL a := {{1}}\n? Show(text,a[Change(),1])\nRETURN\nFUNCTION Show(t,x)\nRETURN t\nFUNCTION Change()\ntext := \"new\"\nRETURN 1\n",
        ];
        for src in cases {
            let err = crate::parse(src).err().unwrap_or_else(|| panic!("accepted an unsafe form: {}", src));
            assert!(err.contains("inline-effect"), "{}: {}", src, err);
        }
    }
    #[test]
    fn guard_admits_sequenced_forms_and_pure_indexes() {
        // Splitting the effect into its own statement is the documented
        // workaround: the borrow starts after the mutation completed.
        for src in [
            "STATIC text := \"old\"\nPROCEDURE Main()\nLOCAL a := {{1}}\nLOCAL i\ni := Change()\n? text, a[i,1]\nRETURN\nFUNCTION Change()\ntext := \"new\"\nRETURN 1\n",
            "STATIC text := \"old\"\nPROCEDURE Main()\nLOCAL a := {{1}}\n? a[1,1]\n? text\nRETURN\nFUNCTION Unused()\nRETURN 1\n",
        ] {
            crate::parse(src).unwrap_or_else(|e| panic!("{}: {}", src, e));
        }
    }
    #[test]
    fn guard_nested_counter_and_catch_without_losing_i64() {
        assert!(crate::parse("STATIC n := 0\nFUNCTION Main()\nTRY\nFOR n := 1 TO 3\n? n\nNEXT\nCATCH\n? 1\nEND\nRETURN NIL\n").err().unwrap().contains("STATIC loop counters"));
        assert!(crate::parse("STATIC s := \"x\"\nFUNCTION Main()\nTRY\nBreak(1)\nCATCH s\n? s\nEND\nRETURN NIL\n").err().unwrap().contains("catch binding shadow"));
    }
}

#[cfg(test)]
mod array_tests {
    use super::*;
    #[test]
    fn fixed_array_binds_with_shared_label_and_arity() {
        crate::parse("STATIC a := {1,2,3}\nFUNCTION Main()\n? a[1]\nRETURN NIL\nFUNCTION ReadA()\nRETURN a[2]\n").unwrap_or_else(|e| panic!("{}", e));
        assert_eq!(kind("main","a"), Some(Ty::Arr(3)));
        let label = storage("main","a");
        assert_eq!(label, storage("reada","a"));
        crate::CUR_FN.with(|f| *f.borrow_mut() = "main".to_string());
        assert_eq!(array_base("a"), Some(label.clone()));
        crate::CUR_FN.with(|f| *f.borrow_mut() = "other".to_string());
        assert_eq!(array_base("a"), None);
    }
    #[test]
    fn guard_admits_cell_reads_writes_len_and_call_args() {
        for src in [
            "STATIC a := {1,2,3}\nPROCEDURE Main()\na[1] := a[2] + 10\n? a[1], len(a)\nRETURN\n",
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nLOCAL b := {0,0}\nb[1] := a[2]\n? Show(a[1])\nRETURN\nFUNCTION Show(x)\nRETURN x\n",
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nLOCAL i := 2\nLOCAL c := {10,20}\n? c[a[i]], a[c[1] - 9]\nRETURN\n",
        ] {
            crate::parse(src).unwrap_or_else(|e| panic!("{}: {}", src, e));
        }
    }
    #[test]
    fn guard_rejects_whole_array_structural_multilevel_and_ref_forms() {
        let cases = [
            // Whole-array assignment would copy where Harbour aliases.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nLOCAL b := a\n? b[1]\nRETURN\n",
            "STATIC a := {1,2,3}\nPROCEDURE Main()\n? a\nRETURN\n",
            // Passing the whole array to a call.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\n? Show(a)\nRETURN\nFUNCTION Show(x)\nRETURN x\n",
            // @ borrow of the module array.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nLOCAL x := 0\nMut(@a)\nRETURN\nFUNCTION Mut(p)\nRETURN p\n",
            // Multi-level index on the module array.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\n? a[1,1]\nRETURN\n",
            // Structural ops.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nAAdd(a, 4)\n? a[1]\nRETURN\n",
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nAFill(a, 0)\n? a[1]\nRETURN\n",
            // Compound cell op.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\na[1] += 5\n? a[1]\nRETURN\n",
            // Whole array inside a container or send.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nLOCAL c := {a}\n? c[1]\nRETURN\n",
            // Assign to the array name itself.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\na := {9,9,9}\n? a[1]\nRETURN\n",
        ];
        for src in cases {
            let err = crate::parse(src).err().unwrap_or_else(|| panic!("accepted an unsafe form: {}", src));
            assert!(err.contains("whole-array"), "{}: {}", src, err);
        }
    }
    #[test]
    fn nested_or_mixed_array_initializers_stay_rejected() {
        let nested = crate::parse("STATIC a := {{1,2},3}\nPROCEDURE Main()\n? a[1]\nRETURN\n").err().unwrap();
        assert!(nested.contains("folded"), "{}", nested);
        let mixed = crate::parse("STATIC a := {1,\"x\",3}\nPROCEDURE Main()\n? a[1]\nRETURN\n").err().unwrap();
        assert!(mixed.contains("folded"), "{}", mixed);
        let empty = crate::parse("STATIC a := {}\nPROCEDURE Main()\n? a[1]\nRETURN\n").err().unwrap();
        assert!(empty.contains("folded"), "{}", empty);
    }
}
