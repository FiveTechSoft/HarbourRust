//! Single-source fixed-type module storage and persistent string ownership.
use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use crate::{Expr, Func, Stmt, Ty};

thread_local! {
    // Function-local spelling -> canonical module slot; local shadows are absent.
    static ALIASES: RefCell<HashMap<(String, String), usize>> = RefCell::new(HashMap::new());
    static KINDS: RefCell<HashMap<(String, String), Ty>> = RefCell::new(HashMap::new());
    static OBJECTS: RefCell<HashMap<usize, u32>> = RefCell::new(HashMap::new());
    static EMITTED: RefCell<HashSet<String>> = RefCell::new(HashSet::new());
}

pub fn reset() {
    OBJECTS.with(|v| v.borrow_mut().clear());
    ALIASES.with(|v| v.borrow_mut().clear());
    KINDS.with(|v| v.borrow_mut().clear());
    EMITTED.with(|v| v.borrow_mut().clear());
}

// Object slots are explicitly NIL-initialized. Infer one fixed class from
// direct constructor assignments, never from a member-name guess. Scalar
// initializers keep their prior type and named retag rejection.
pub fn discover_objects(funcs: &[Func], methods: &[crate::MethodDef], classes: &[crate::ClassDecl], slots: &[(usize,String,Expr)]) -> Result<(),String> {
    fn ctor(e:&Expr, classes:&[crate::ClassDecl])->Option<u32> {
        match e {
            Expr::Call(n,_)=>classes.iter().position(|c|c.name.eq_ignore_ascii_case(n)).map(|i|i as u32),
            Expr::Send(o,n,_) if n.eq_ignore_ascii_case("new")=>ctor(o,classes),
            _=>None,
        }
    }
    fn scan(ss:&[Stmt],name:&str,classes:&[crate::ClassDecl],found:&mut Option<u32>)->Result<(),String> {
        for st in ss {match st {
            Stmt::Assign(line,id,e) if id==name=>if let Some(ci)=ctor(e,classes) {
                if found.is_some() && *found!=Some(ci) {return Err(format!("line {}: module STATIC object `{}` has multiple constructor classes; fixed-class storage only in this increment",line,name));}
                *found=Some(ci);
            },
            Stmt::If(_,_,a,b)=>{scan(a,name,classes,found)?;scan(b,name,classes,found)?;},
            Stmt::While(_,_,b)|Stmt::For(_,_,_,_,_,b)|Stmt::ForEach(_,_,_,b)=>scan(b,name,classes,found)?,
            Stmt::Try(_,b,c,f)=>{scan(b,name,classes,found)?;if let Some((_,b))=c{scan(b,name,classes,found)?;}if let Some(b)=f{scan(b,name,classes,found)?;}},
            Stmt::Switch(_,_,arms,other)=>{for(_,_,b)in arms{scan(b,name,classes,found)?;}if let Some((_,b))=other{scan(b,name,classes,found)?;}},
            _=>{}
        }}Ok(())
    }
    for (index,(_,name,init)) in slots.iter().enumerate() {
        if !matches!(init,Expr::Nil){continue;}
        let mut found=None;
        for f in funcs.iter().chain(methods.iter().map(|m|&m.f)) {
            if f.params.contains(name)||declaration(&f.stmts,name,false)?{continue;}
            scan(&f.stmts,name,classes,&mut found)?;
        }
        if let Some(ci)=found{OBJECTS.with(|v|v.borrow_mut().insert(index,ci));}
        else{return Err(format!("line {}: module STATIC requires a folded i64, logical or string scalar or a constant array initializer (i64/logical/string/NIL cells, nested and empty arrays admitted); NIL, Date, float and hash initializers are not in this increment",slots[index].0));}
    }
    Ok(())
}
pub fn has_objects()->bool{OBJECTS.with(|v|!v.borrow().is_empty())}
pub fn object(name:&str)->Option<u32>{match current(name){Some(Ty::Obj(ci))=>Some(ci),_=>None}}

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

// True when `name` in the current function binds the module-level
// static itself (as opposed to a local alias from note_alias): the
// canonical casilla is the shared .data label, so every frame sees a
// rebind (probe p17).
pub fn is_module_binding(name: &str) -> bool {
    crate::CUR_FN.with(|f| {
        let owner = f.borrow().clone();
        ALIASES.with(|v| v.borrow().contains_key(&(owner, name.to_owned())))
    })
}

// A local Dyn copy of a shared module array aliases the same object.
// Record the local under its own name so the shared-array checker arms
// admit it (the runtime tag-16 guards stay the real array checks: a
// later non-array assignment to the local fails there, as Harbour).
pub fn note_alias(name: &str) {
    crate::CUR_FN.with(|f| {
        let owner = f.borrow().clone();
        KINDS.with(|v| v.borrow_mut().insert((owner, name.to_owned()), Ty::Dyn));
    });
}
pub fn string_value(e: &Expr) -> bool {
    matches!(e, Expr::Var(v) if current(v) == Some(Ty::StrOwn))
}
// A dynamic shared-reference module array binds as a Dyn local carrying
// {tag 16, object pointer}; cell reads/writes route through the object.
pub fn is_shared_array(owner: &str, name: &str) -> bool {
    kind(owner, name) == Some(Ty::Dyn)
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
    // Pure integer formatting in a persistent-string concat cannot call
    // user code or mutate its borrowed left operand. Keep the whitelist
    // structural and closed; no computed arguments or arbitrary helpers.
    fn format_concat(e:&Expr,name:&str)->bool {
        match e {
            Expr::Var(_)|Expr::Str(_)|Expr::Int(_)=>true,
            Expr::Bin(op,a,b) if *op=='+' => format_concat(a,name)&&format_concat(b,name),
            Expr::Call(id,aa) if crate::is_builtin(id,"hb_ntos") => matches!(aa.as_slice(),[Expr::Var(v)]if v!=name)||matches!(aa.as_slice(),[Expr::Int(_)]),
            _=>false,
        }
    }
    // Admission check for one expression. Also exhaustive without a wildcard,
    // for the same reason: an unclassified form must stop the build, never
    // fall through to a permissive default.
    fn expr(e: &Expr, name: &str, ty: Ty) -> bool {
        match e {
            Expr::ByRef(v) if v == name => ty != Ty::Bool && !matches!(ty,Ty::Obj(_)),
            Expr::Set(v, _) | Expr::Inc(v, ..) if v == name => false,
            Expr::ArrLit(es) => !es.iter().any(|e| crate::expr_mentions(e,name)),
            Expr::HashLit(es) => !es.iter().any(|(k,v)| crate::expr_mentions(k,name)||crate::expr_mentions(v,name)),
            Expr::Bin(_,a,b) | Expr::Cmp(_,a,b) | Expr::LAnd(a,b) | Expr::LOr(a,b) => {
                if matches!(ty,Ty::StrOwn|Ty::Obj(_)) && crate::expr_mentions(e,name) && crate::expr_has_call(e) && !(ty==Ty::StrOwn&&format_concat(e,name)) {return false;}
                expr(a,name,ty) && expr(b,name,ty)
            }
            Expr::Seq(es) => !(ty == Ty::StrOwn && es.iter().any(|e|crate::expr_mentions(e,name))) && es.iter().all(|e|expr(e,name,ty)),
            Expr::Call(id,es) => {
                if ty == Ty::StrOwn && ["iif","eval"].iter().any(|b|crate::is_builtin(id,b)) && es.iter().any(|e|crate::expr_mentions(e,name)) {return false;}
                if matches!(ty,Ty::StrOwn|Ty::Obj(_)) && es.iter().any(|e|crate::expr_mentions(e,name)) && es.iter().any(may_mutate) {return false;}
                es.iter().all(|e|expr(e,name,ty))
            }
            Expr::BlockLit(_,_,es) => !(matches!(ty,Ty::Obj(_)) && es.iter().any(|e|crate::expr_mentions(e,name))) && es.iter().all(|e|expr(e,name,ty)),
            Expr::Set(_,e) | Expr::LNot(e) | Expr::Index(_,e) => expr(e,name,ty),
            Expr::Inc(..) => true, // ++/-- on another variable holds no borrow of this slot
            Expr::Send(o,_,es) => !(matches!(ty,Ty::Obj(_)) && crate::expr_mentions(o,name) && es.iter().any(may_mutate)) && !(ty == Ty::StrOwn && crate::expr_mentions(e,name)) && expr(o,name,ty)&&es.iter().all(|e|expr(e,name,ty)),
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
            Stmt::For(_,_,a,b,c,body)=>expr(a,name,ty)&&expr(b,name,ty)&&expr(c,name,ty)&&walk(body,name,ty),
            Stmt::ForEach(_,_,e,body)=>expr(e,name,ty)&&walk(body,name,ty),
            Stmt::Switch(_,e,arms,other)=>expr(e,name,ty)&&arms.iter().all(|(_,_,b)|walk(b,name,ty))&&other.as_ref().map_or(true,|(_,b)|walk(b,name,ty)),
            Stmt::SendSet(_,o,_,e) if matches!(ty,Ty::Obj(_)) => expr(o,name,ty) && expr(e,name,ty) && !(crate::expr_mentions(o,name) && may_mutate(e)),
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
            Stmt::For(_, _, a, b, c, body) => expr(a, name) && expr(b, name) && expr(c,name) && walk(body, name),
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

// Dynamic shared-reference module arrays (tag-16 Dyn). The name binds as
// an ordinary Dyn local, so locals, parameters, returns and 16-byte copies
// alias by construction; the guard only keeps out the routes that would
// break the shared-heap model or are unmeasured in this increment: @
// borrows, inline assign/inc on the name, compound cell ops (deferred
// increment), AIns/ADel/AFill (deferred), literals as AAdd values
// (descriptor materialization deferred), container/hash/block/send
// captures, and structural whole-array builtins. Multi-level reads and
// writes are admitted: nested arrays are the point of the increment.
// The expression classifier is exhaustive over expression forms without a
// wildcard, same rule as the owned-string and fixed-array guards.
fn check_shared_array_uses(f: &Func, name: &str) -> Result<(), String> {
    fn expr(e: &Expr, name: &str) -> bool {
        match e {
            Expr::Index(_, i) => expr(i, name),
            Expr::Index2(_, a, b) => expr(a, name) && expr(b, name),
            Expr::Index3(_, a, b, c) => expr(a, name) && expr(b, name) && expr(c, name),
            Expr::Index4(_, a, b, c, d) => expr(a, name) && expr(b, name) && expr(c, name) && expr(d, name),
            // A Dyn copy of the name aliases, which is the Harbour
            // semantics this increment implements: Var is safe as a
            // value (call args, alias copies, prints). A DIRECT Var as
            // an operand of compare/arithmetic/logic or as an IF/WHILE/
            // FOR EACH condition is a whole-array value use, unmeasured
            // against Harbour here: rejected at the composite arms.
            Expr::Var(_) => true,
            Expr::ByRef(v) => v != name,
            Expr::Set(v, e) => v != name && expr(e, name),
            Expr::Inc(v, ..) => v != name,
            Expr::IdxCompound(v, i, _, r) => v != name && expr(i, name) && expr(r, name),
            Expr::Call(id, es) => {
                if ["acopy","aeval","ascan","asort","aclone","adel","ains","afill"].iter().any(|b| crate::is_builtin(id, b)) && es.iter().any(|e| crate::expr_mentions(e, name)) {
                    return false;
                }
                es.iter().all(|e| expr(e, name))
            }
            // A DIRECT Var(name) operand is a whole-array value use
            // (compare, arithmetic, logic): unmeasured against Harbour
            // in this increment, so it is rejected. Nested mentions
            // (call args, indexes) still alias safely.
            Expr::Bin(_, a, b) | Expr::Cmp(_, a, b) | Expr::LAnd(a, b) | Expr::LOr(a, b) =>
                !matches!(&**a, Expr::Var(v) if v == name) && !matches!(&**b, Expr::Var(v) if v == name) && expr(a, name) && expr(b, name),
            Expr::LNot(e) => !matches!(&**e, Expr::Var(v) if v == name) && expr(e, name),
            Expr::Seq(es) => es.iter().all(|e| expr(e, name)),
            Expr::ArrLit(..) | Expr::HashLit(..) | Expr::BlockLit(..) | Expr::Send(..) => !crate::expr_mentions(e, name),
            Expr::FloatV(..) | Expr::Float(..) | Expr::Int(_) | Expr::Str(_) | Expr::Nil | Expr::Log(_) | Expr::DArrNew | Expr::SelfObj | Expr::SelfGet(_) | Expr::FuncRef(_) => true,
        }
    }
    fn walk(ss: &[Stmt], name: &str) -> bool {
        ss.iter().all(|s| match s {
            Stmt::Local(_, _, e) | Stmt::Ret(_, Some(e)) | Stmt::CallStmt(_, e) | Stmt::SendStmt(_, e) => expr(e, name),
            // Reassignment of the module name replaces the canonical
            // reference; only literal rebuilds are admitted (a descriptor
            // materializes the new object).
            Stmt::Assign(_, v, e) => (v != name || matches!(e, Expr::ArrLit(..) | Expr::DArrNew)) && expr(e, name),
            Stmt::Print(_, es, _) => es.iter().all(|e| expr(e, name)),
            Stmt::ArrSet(_, v, ie, e) => (v != name || (expr(ie, name) && expr(e, name))) && (v == name || !crate::stmt_mentions(s, name) || matches!(e, Expr::Index(v2, _) | Expr::Index2(v2, ..) | Expr::Index3(v2, ..) | Expr::Index4(v2, ..) if v2 == name)),
            Stmt::ArrSet2(_, v, a, b, e) => v != name && !crate::expr_mentions(a, name) && !crate::expr_mentions(b, name) && !crate::expr_mentions(e, name) || v == name && expr(a, name) && expr(b, name) && expr(e, name),
            Stmt::ArrSet3(_, v, a, b, c, e) => v != name && !crate::expr_mentions(a, name) && !crate::expr_mentions(b, name) && !crate::expr_mentions(c, name) && !crate::expr_mentions(e, name) || v == name && expr(a, name) && expr(b, name) && expr(c, name) && expr(e, name),
            Stmt::ArrSet4(_, v, a, b, c, d, e) => v != name && !crate::expr_mentions(a, name) && !crate::expr_mentions(b, name) && !crate::expr_mentions(c, name) && !crate::expr_mentions(d, name) && !crate::expr_mentions(e, name) || v == name && expr(a, name) && expr(b, name) && expr(c, name) && expr(d, name) && expr(e, name),
            Stmt::AAdd(_, v, e) => v != name && !crate::expr_mentions(e, name) || v == name && expr(e, name) && !matches!(e, Expr::ArrLit(..) | Expr::DArrNew),
            Stmt::ASize(_, v, e) => v != name && !crate::expr_mentions(e, name) || v == name && expr(e, name),
            Stmt::AIns(_, v, _) | Stmt::ADel(_, v, _) | Stmt::AFill(_, v, ..) => v != name && !crate::stmt_mentions(s, name),
            Stmt::If(_, e, a, b) => !matches!(e, Expr::Var(v) if v == name) && expr(e, name) && walk(a, name) && walk(b, name),
            Stmt::While(_, e, b) => !matches!(e, Expr::Var(v) if v == name) && expr(e, name) && walk(b, name),
            Stmt::Try(_, b, c, f) => walk(b, name) && c.as_ref().map_or(true, |(_, b)| walk(b, name)) && f.as_ref().map_or(true, |b| walk(b, name)),
            Stmt::For(_, _, a, b, c, body) => expr(a, name) && expr(b, name) && expr(c,name) && walk(body, name),
            Stmt::ForEach(_, _, e, body) => !matches!(e, Expr::Var(v) if v == name) && expr(e, name) && walk(body, name),
            Stmt::Switch(_, e, arms, other) => expr(e, name) && arms.iter().all(|(_, _, b)| walk(b, name)) && other.as_ref().map_or(true, |(_, b)| walk(b, name)),
            Stmt::Static(..) | Stmt::Ret(_, None) | Stmt::Exit(_) | Stmt::Loop(_) => true,
            _ => !crate::stmt_mentions(s, name),
        })
    }
    if !walk(&f.stmts, name) {
        return Err(format!("module STATIC `{}`: this shared-array use is outside the dynamic increment (@ borrows, compound cell ops, AIns/ADel/AFill, literal AAdd values, container captures and whole-array builtins are deferred or rejected)", name));
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
        let ty = if let Some(ci)=OBJECTS.with(|v|v.borrow().get(&index).copied()) {Ty::Obj(ci)} else {match init {
            Expr::Log(_) => Ty::Bool,
            Expr::Str(_) => Ty::StrOwn,
            // S4 unify (doc: "every module STATIC array literal becomes a
            // dynamic shared-reference array"; flat literals included):
            // nested, mixed, flat or empty - all bind as Dyn {tag 16,
            // object pointer}. The S3 fixed .data route is retired.
            Expr::ArrLit(_) | Expr::DArrNew => Ty::Dyn,
            _ => Ty::I64,
        }};
        if matches!(init,Expr::Nil) && !matches!(ty,Ty::Obj(_)) {return Err(format!("line {}: module STATIC requires a folded i64, logical or string scalar or a constant array initializer (i64/logical/string/NIL cells, nested and empty arrays admitted); NIL, Date, float and hash initializers are not in this increment",line));}
        if matches!(ty,Ty::Bool|Ty::StrOwn|Ty::Obj(_)) {check_payload_uses(f,name,ty)?;}
        if matches!(ty,Ty::Arr(_)) {check_array_uses(f,name)?;}
        if ty == Ty::Dyn && matches!(init, Expr::ArrLit(_) | Expr::DArrNew) {check_shared_array_uses(f,name)?;}
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
    fn flat_array_binds_dyn_after_the_unify_flip() {
        // Post-flip: even the flat all-i64 literal binds as Dyn (tag-16
        // shared reference); the fixed .data route is retired, so
        // array_base never applies to a module literal array.
        crate::parse("STATIC a := {1,2,3}\nFUNCTION Main()\n? a[1]\nRETURN NIL\nFUNCTION ReadA()\nRETURN a[2]\n").unwrap_or_else(|e| panic!("{}", e));
        assert_eq!(kind("main","a"), Some(Ty::Dyn));
        assert_eq!(kind("reada","a"), Some(Ty::Dyn));
        crate::CUR_FN.with(|f| *f.borrow_mut() = "main".to_string());
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
    fn guard_admits_aliased_and_structural_forms_after_unify() {
        // Post-flip admissions (doc "S4 SUBSUMES S3"): alias local, whole
        // print (empty line), whole-array call argument, multi-level
        // index. AAdd/ASize and literal rebuilds join once their codegen
        // arms land (they still error today, named in the docs).
        for src in [
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nLOCAL b := a\n? b[1]\nRETURN\n",
            "STATIC a := {1,2,3}\nPROCEDURE Main()\n? a\nRETURN\n",
            "STATIC a := {1,2,3}\nPROCEDURE Main()\n? Show(a)\nRETURN\nFUNCTION Show(x)\nRETURN x\n",
            "STATIC a := {{1,2},{3,4}}\nPROCEDURE Main()\n? a[1,1]\nRETURN\n",
        ] {
            crate::parse(src).unwrap_or_else(|e| panic!("{}: {}", src, e));
        }
    }
    #[test]
    fn guard_rejects_deferred_and_ref_forms_after_unify() {
        let cases = [
            // @ borrow of the module array.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nLOCAL x := 0\nMut(@a)\nRETURN\nFUNCTION Mut(p)\nRETURN p\n",
            // Deferred structural ops.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nAFill(a, 0)\n? a[1]\nRETURN\n",
            // Compound cell op (deferred increment).
            "STATIC a := {1,2,3}\nPROCEDURE Main()\na[1] += 5\n? a[1]\nRETURN\n",
            // Whole array inside a container or send.
            "STATIC a := {1,2,3}\nPROCEDURE Main()\nLOCAL c := {a}\n? c[1]\nRETURN\n",
        ];
        for src in cases {
            let err = crate::parse(src).err().unwrap_or_else(|| panic!("accepted an unsafe form: {}", src));
            assert!(err.contains("outside the dynamic increment") || err.contains("outside this increment"), "{}: {}", src, err);
        }
    }
    #[test]
    fn all_module_array_literals_bind_dyn_after_unify() {
        // The S4 dynamic route, post-flip: nested, mixed, empty AND flat
        // all-i64 literals bind as Dyn (shared reference).
        crate::parse("STATIC a := {{1,2},\"x\"}
STATIC b := {}
STATIC f := {1,2,3}
PROCEDURE Main()
? a[1][1], len(b), f[1]
RETURN
").unwrap_or_else(|e| panic!("{}", e));
        assert_eq!(kind("main","a"), Some(Ty::Dyn));
        assert_eq!(kind("main","b"), Some(Ty::Dyn));
        assert_eq!(kind("main","f"), Some(Ty::Dyn));
        // Float cells stay rejected on every route.
        let float = crate::parse("STATIC a := {1.5}
PROCEDURE Main()
? a[1]
RETURN
").err().unwrap();
        assert!(float.contains("folded"), "{}", float);
    }
    #[test]
    fn shared_array_guard_rejects_deferred_and_unsafe_routes() {
        let cases = [
            "STATIC a := {1,\"x\"}
PROCEDURE Main()
Mut(@a)
RETURN
FUNCTION Mut(p)
RETURN p
",
            "STATIC a := {1,\"x\"}
PROCEDURE Main()
AIns(a, 1)
RETURN
",
            "STATIC a := {1,\"x\"}
PROCEDURE Main()
ADel(a, 1)
RETURN
",
            "STATIC a := {1,\"x\"}
PROCEDURE Main()
AFill(a, 0)
RETURN
",
            "STATIC a := {}
PROCEDURE Main()
AAdd(a, {1})
RETURN
",
            "STATIC a := {1,\"x\"}
PROCEDURE Main()
LOCAL c := {a}
RETURN
",
            "STATIC a := {1,\"x\"}
PROCEDURE Main()
? AScan(a, 1)
RETURN
",
            "STATIC a := {1,\"x\"}
PROCEDURE Main()
LOCAL b := a
a := b
RETURN
",
        ];
        for src in cases {
            let err = crate::parse(src).err().unwrap_or_else(|| panic!("accepted an unsafe form: {}", src));
            assert!(err.contains("shared-array use"), "{}: {}", src, err);
        }
    }
}

#[cfg(test)]
mod object_tests {
    use super::*;
    #[test]
    fn nil_object_inference_and_canonical_class() {
        crate::parse("STATIC o := NIL\nCLASS T\nENDCLASS\nFUNCTION Main()\no := T()\nRETURN NIL\nFUNCTION ReadO()\nRETURN o:n\n").unwrap();
        assert_eq!(kind("main","o"),Some(Ty::Obj(0)));
        assert_eq!(kind("reado","o"),Some(Ty::Obj(0)));
        assert_eq!(storage("main","o"),storage("reado","o"));
        assert!(has_objects());
        crate::parse("FUNCTION Main()\nRETURN NIL\n").unwrap();
        assert!(!has_objects());
    }
    #[test]
    fn object_inference_respects_local_shadow_and_rejects_two_classes() {
        let src="STATIC o := NIL\nCLASS T\nENDCLASS\nCLASS U\nENDCLASS\nFUNCTION Main()\no := T()\nRETURN NIL\nFUNCTION PrivateO()\nLOCAL o\no := U()\nRETURN NIL\n";
        crate::parse(src).unwrap();
        assert_eq!(kind("main","o"),Some(Ty::Obj(0)));
        assert_eq!(kind("privateo","o"),None);
        let bad=src.replace("LOCAL o\n","");
        assert!(crate::parse(&bad).err().unwrap().contains("multiple constructor classes"));
    }
}
