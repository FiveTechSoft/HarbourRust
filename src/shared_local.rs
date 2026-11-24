// Own MIT local shared-array discovery. This stage activates only when a
// an empty local array reaches a mutator or receives a direct alias. Other
// legacy programs keep their existing representation, including fixed copies.
use super::*;
use std::collections::{HashMap,HashSet};
thread_local! {
 static NAMES: std::cell::RefCell<HashMap<String,HashSet<String>>> = std::cell::RefCell::new(HashMap::new());
 static PARAMS: std::cell::RefCell<HashSet<(String,usize)>> = std::cell::RefCell::new(HashSet::new());
 static ACTIVE: std::cell::Cell<bool> = const {std::cell::Cell::new(false)};
}
pub fn active()->bool{ACTIVE.with(|v|v.get())}
pub fn named(f:&str,n:&str)->bool{NAMES.with(|v|v.borrow().get(f).map_or(false,|s|s.contains(n)))}
pub fn current(n:&str)->bool{CUR_FN.with(|f|named(&f.borrow(),n))}
pub fn parameter(f:&str,i:usize)->bool{PARAMS.with(|v|v.borrow().contains(&(f.to_string(),i)))}
pub fn value_parameter(f:&str,i:usize)->bool {VALUES.with(|v|v.borrow().contains(&(f.to_string(),i)))}
thread_local! {static VALUES: std::cell::RefCell<HashSet<(String,usize)>> = std::cell::RefCell::new(HashSet::new());}
thread_local! {static TRACE_HELPERS: std::cell::RefCell<HashSet<String>>=std::cell::RefCell::new(HashSet::new());}
thread_local! {static PURE_HELPERS: std::cell::RefCell<HashSet<String>>=std::cell::RefCell::new(HashSet::new());}
thread_local! {static THROW_HELPERS: std::cell::RefCell<HashSet<String>>=std::cell::RefCell::new(HashSet::new());}
pub fn throw_helper(id:&str)->bool{THROW_HELPERS.with(|v|v.borrow().contains(id))}
pub fn pure_helper(id:&str)->bool{PURE_HELPERS.with(|v|v.borrow().contains(id))}
pub fn trace_helper(id:&str)->bool{TRACE_HELPERS.with(|v|v.borrow().contains(id))}
pub fn init(ff:&[Func]) {
 THROW_HELPERS.with(|v|v.borrow_mut().clear());
 for f in ff {
  let body:Vec<_>=f.stmts.iter().filter(|s|!matches!(s,Stmt::Static(..))).collect();
  if f.params.len()==3 {if let [Stmt::Assign(_,slot,Expr::Bin('+',inc,one)),Stmt::If(_,Expr::Cmp(_,a,b),yes,no),Stmt::Ret(_,Some(Expr::Cmp(_,x,y)))]=body.as_slice(){
   if matches!(inc.as_ref(),Expr::Var(v)if v==slot)&&matches!(one.as_ref(),Expr::Int(t)if t=="1")&&module_static::kind(&f.name,slot)==Some(Ty::I64)&&matches!(a.as_ref(),Expr::Var(v)if v==slot)&&matches!(b.as_ref(),Expr::Var(v)if v==&f.params[2])&&no.is_empty()&&matches!(yes.as_slice(),[Stmt::Break(_,Expr::Str(_))])&&matches!(x.as_ref(),Expr::Var(v)if v==&f.params[0])&&matches!(y.as_ref(),Expr::Var(v)if v==&f.params[1]){THROW_HELPERS.with(|v|v.borrow_mut().insert(f.name.clone()));}
  }}
 }
 PURE_HELPERS.with(|v|v.borrow_mut().clear());
 for f in ff {
  fn pure(e:&Expr,ps:&[String])->bool{match e{
   Expr::Var(v)=>ps.contains(v),Expr::Int(_)|Expr::Log(_)|Expr::Str(_)|Expr::Nil=>true,
   Expr::Cmp(_,a,b)=>pure(a,ps)&&pure(b,ps),
   Expr::Index(v,i)=>ps.contains(v)&&pure(i,ps),
   Expr::Call(id,aa)if is_builtin(id,"iif")=>aa.len()==3&&aa.iter().all(|a|pure(a,ps)),_=>false}}
  if matches!(f.stmts.as_slice(),[Stmt::Ret(_,Some(e))]if pure(e,&f.params)){PURE_HELPERS.with(|v|v.borrow_mut().insert(f.name.clone()));}
 }
 TRACE_HELPERS.with(|v|v.borrow_mut().clear());
 for f in ff {
  fn text(e:&Expr,ps:&[String],slot:&str)->bool{match e{
   Expr::Str(_)=>true,Expr::Var(v)=>v==slot,
   Expr::Bin(op,a,b)if *op=='+'=>text(a,ps,slot)&&text(b,ps,slot),
   Expr::Call(id,aa)if is_builtin(id,"hb_ntos")=>matches!(aa.as_slice(),[Expr::Var(v)]if ps.contains(v)),_=>false}}
  let body:Vec<_>=f.stmts.iter().filter(|s|!matches!(s,Stmt::Static(..))).collect();
  if f.params.len()==2 {if let [Stmt::Assign(_,slot,e),Stmt::Ret(_,Some(Expr::Cmp(_,a,b)))]=body.as_slice(){
   if module_static::kind(&f.name,slot)==Some(Ty::StrOwn)&&text(e,&f.params,slot)&&matches!(a.as_ref(),Expr::Var(v)if f.params.contains(v))&&matches!(b.as_ref(),Expr::Var(v)if f.params.contains(v)) {TRACE_HELPERS.with(|v|v.borrow_mut().insert(f.name.clone()));}
  }}
 }

 VALUES.with(|v|v.borrow_mut().clear());
 NAMES.with(|v|v.borrow_mut().clear());PARAMS.with(|v|v.borrow_mut().clear());ACTIVE.with(|v|v.set(false));
 let mut names=HashMap::<String,HashSet<String>>::new();let mut need=false;
 for f in ff {
  let mut arrays=HashSet::new();
  visit_stmts_ref(&f.stmts,&mut |s|{match s {
   Stmt::Local(_,n,Expr::DArrNew)|Stmt::Assign(_,n,Expr::DArrNew)=>{arrays.insert(n.clone());},

   _=>{}
  }},&mut |_|{});
  loop {let old=arrays.clone();visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::Local(_,n,Expr::Var(p))|Stmt::Assign(_,n,Expr::Var(p))=s{if old.contains(p){need=true;arrays.insert(n.clone());}}},&mut |_|{});if arrays==old{break}}
  // A constant local array stored into its own cell needs identity, not
  // the legacy fixed-cell copy. Enter the existing shared heap only for
  // this explicit cycle-producing shape; ordinary literals keep their ABI.
  let mut constants=HashSet::new();
  visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::Local(_,n,e)=s{if literal(e){constants.insert(n.clone());}}},&mut |_|{});
  visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::ArrSet(_,n,_,Expr::Var(v))=s{if n==v&&constants.contains(n){need=true;}}},&mut |_|{});
  // A constant nested array with a noninteger leaf and an explicit
  // nested store uses tagged shared cells, not integer-only DArr2 cells.
  fn tagged_nested(e:&Expr)->bool{
   match e{Expr::ArrLit(es)=>es.iter().any(|e|matches!(e,Expr::ArrLit(_)))&&es.iter().any(has_tagged_leaf),_=>false}
  }
  fn has_tagged_leaf(e:&Expr)->bool{match e{Expr::Str(_)|Expr::Nil|Expr::Log(_)=>true,Expr::ArrLit(es)=>es.iter().any(has_tagged_leaf),_=>false}}
  let mut nested=HashSet::new();
  visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::Local(_,n,e)=s{if literal(e)&&tagged_nested(e){nested.insert(n.clone());}}},&mut |_|{});
  visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::ArrSet2(_,n,..)=s{if nested.contains(n){need=true;}}},&mut |_|{});
  // ASort on a constant local flat literal requires an addressable array
  // identity. Direct callbacks are checked separately; computed literals stay closed.
  let mut sortable=HashSet::new();
  visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::Local(_,n,Expr::ArrLit(es))|Stmt::Assign(_,n,Expr::ArrLit(es))=s{
   if !es.iter().all(|e|matches!(e,Expr::Str(_)))&&literal(&Expr::ArrLit(es.clone())){sortable.insert(n.clone());}
  }},&mut |_|{});
  visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::Call(id,args)=e{
   if is_builtin(id,"asort")&&args.len()<=4&&matches!(args.first(),Some(Expr::Var(n)) if sortable.contains(n)){need=true;}
  }});
  // A literal handed to a function that stores a dynamic parameter in
  // one of its cells needs shared identity at the call boundary.
  let mut literals=HashSet::new();
  visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::Local(_,n,e)=s{if literal(e){literals.insert(n.clone());}}},&mut |_|{});
  visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::Call(id,args)=e{
   if let Some(to)=ff.iter().find(|f|f.name==*id){for (i,a)in args.iter().enumerate().take(to.params.len()){
    if matches!(a,Expr::Var(n)if literals.contains(n))&&to.stmts.iter().any(|s|matches!(s,Stmt::ArrSet(_,n,_,Expr::Var(v)) if n==&to.params[i]&&v!=n&&(to.params.contains(v)||to.stmts.iter().any(|s|matches!(s,Stmt::Local(_,local,Expr::Call(_,aa))if local==v&&aa.iter().any(|e|matches!(e,Expr::Index(root,_)if root==n))))))){need=true;}
   }}
  }});
  visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::Call(id,args)=e{
   if let Some(to)=ff.iter().find(|f|f.name==*id){for (i,a)in args.iter().enumerate().take(to.params.len()){
    if matches!(a,Expr::Var(n)if literals.contains(n)){
     visit_stmts_ref(&to.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::Call(id,aa)if is_builtin(id,"asort")&&aa.len()<=4&&matches!(aa.first(),Some(Expr::Var(n))if n==&to.params[i])){need=true;}});
    }
   }}
  }});
  names.insert(f.name.clone(),arrays);
 }
 for f in ff {let own=names.get(&f.name).unwrap();visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::Call(id,aa)=e {if let Some(to)=ff.iter().find(|x|x.name==*id){for(i,a)in aa.iter().enumerate().take(to.params.len()){if matches!(a,Expr::Var(n) if own.contains(n)) && to.stmts.iter().any(|s|matches!(s,Stmt::AAdd(_,p,_) if p==&to.params[i])) {need=true;}}}}});}
 if method_arrays::active()||timestamp::containers(){need=true;}
 if !need{return;}
 // Initially keep unsupported profiles closed, rather than changing existing
 // native/PE/Mach-O contracts with an untested collector.
 if !DECIMAL_LOCAL_PROFILE.with(|v|v.get())||MACRO_CONTEXT.with(|v|v.get())||EXTERNS.with(|v|!v.borrow().is_empty())||(!method_arrays::active()&&CLASSES.with(|v|!v.borrow().is_empty())){return;}
 for f in ff {visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::Local(_,n,e)|Stmt::Assign(_,n,e)=s{if literal(e){names.entry(f.name.clone()).or_default().insert(n.clone());}}},&mut |_|{});}
 let mut params=HashSet::new();
 for f in ff {if pure_helper(&f.name){if let [Stmt::Ret(_,Some(Expr::Index(n,_)))]=f.stmts.as_slice(){if let Some(i)=f.params.iter().position(|p|p==n){names.entry(f.name.clone()).or_default().insert(n.clone());params.insert((f.name.clone(),i));}}}}
 let mut returns=HashSet::<String>::new();
 loop {
  let old=names.clone();let np=params.len();let nr=returns.len();
  for f in ff {
   let own=old.get(&f.name).cloned().unwrap_or_default();
   let oldret=returns.clone();
   visit_stmts_ref(&f.stmts,&mut |s|{
    match s {
     Stmt::Local(_,n,Expr::Var(p))|Stmt::Assign(_,n,Expr::Var(p)) if own.contains(p)=>{names.entry(f.name.clone()).or_default().insert(n.clone());},
     Stmt::Local(_,n,e) if optional_empty::selected(e).map_or(false,|p|own.contains(p))=>{names.entry(f.name.clone()).or_default().insert(n.clone());},
     Stmt::Local(_,n,Expr::Call(id,_))|Stmt::Assign(_,n,Expr::Call(id,_)) if oldret.contains(id)=>{names.entry(f.name.clone()).or_default().insert(n.clone());},
     Stmt::Local(_,n,e)|Stmt::Assign(_,n,e) if method_arrays::active() && method_arrays::expr(e,&own,&oldret)=>{names.entry(f.name.clone()).or_default().insert(n.clone());},
     Stmt::CatchBind(_,n)=>{names.entry(f.name.clone()).or_default().insert(n.clone());},
     Stmt::Try(_,_,Some((Some(n),_)),_)=>{names.entry(f.name.clone()).or_default().insert(n.clone());},
     Stmt::Ret(_,Some(Expr::SelfGet(_))) if method_arrays::active()=>{returns.insert(f.name.clone());},
     Stmt::Ret(_,Some(e)) if method_arrays::active() && method_arrays::expr(e,&own,&oldret)=>{returns.insert(f.name.clone());},
     Stmt::Ret(_,Some(Expr::Var(n))) if own.contains(n)=>{returns.insert(f.name.clone());},
     _=>{}
    }
   },&mut |_|{});
   visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{
    if method_arrays::active(){if let Expr::Send(_,n,aa)=e{for(_,id)in method_results::choices(n){if let Some(to)=ff.iter().find(|f|f.name==id){for(i,a)in aa.iter().enumerate(){if i+1<to.params.len() && method_arrays::expr(a,&own,&oldret){params.insert((id.clone(),i+1));names.entry(id.clone()).or_default().insert(to.params[i+1].clone());}}}}}}
    if let Expr::Call(id,aa)=e {if let Some(to)=ff.iter().find(|x|x.name==*id){for(i,a)in aa.iter().enumerate().take(to.params.len()){
     if matches!(a,Expr::Var(n)|Expr::Index(n,_) if own.contains(n)) || matches!(a,Expr::Call(id,_) if oldret.contains(id)) || (method_arrays::active() && method_arrays::expr(a,&own,&oldret)) {params.insert((id.clone(),i));names.entry(id.clone()).or_default().insert(to.params[i].clone());}
    }}}
   });
  }
  if old==names&&np==params.len()&&nr==returns.len(){break}
 }
 for f in ff {visit_stmts_ref(&f.stmts,&mut |s|{if let Stmt::AAdd(_,n,Expr::Var(p))=s {if names.get(&f.name).map_or(false,|ns|ns.contains(n)){if let Some(i)=f.params.iter().position(|x|x==p){VALUES.with(|v|{v.borrow_mut().insert((f.name.clone(),i));});}}}},&mut |_|{});}
 NAMES.with(|v|*v.borrow_mut()=names);PARAMS.with(|v|*v.borrow_mut()=params);ACTIVE.with(|v|v.set(true));
}
pub fn literal(e:&Expr)->bool {
 fn leaf(e:&Expr)->bool{match e{Expr::Float(..)|Expr::FloatV(..)|Expr::DArrNew=>true,Expr::Call(id,aa) if (is_builtin(id,"stod")||is_builtin(id,"hb_stod"))&&matches!(aa.as_slice(),[Expr::Str(_)])=>true,Expr::ArrLit(es)=>es.iter().all(leaf),_=>const_array_init(e)}}
 matches!(e,Expr::DArrNew)||(matches!(e,Expr::ArrLit(_))&&leaf(e))
}
pub fn optional(e:&Expr)->Option<&str>{let p=optional_empty::selected(e)?;if current(p){Some(p)}else{None}}
pub fn emit_literal(e:&Expr,strs:&mut Vec<String>,out:&mut String){let d=emit_sarr_desc(out,strs,e);out.push_str(&format!("    lea {d}(%rip), %rdi\n    call hbc_sarr_build\n    mov %rax, %rdx\n    mov $16, %eax\n"));}

// Keep registry cells within the payload families its release walker owns.
// Reject old unique-array/object/handle payloads before installing them.
pub fn screen_value(out:&mut String) {
 let k=fresh_lbl();
 if active(){out.push_str(&format!("    cmp $5, %al\n    je .Lsvok{k}\n    cmp $11, %rax\n    je .Lsvok{k}\n    cmp $17, %rax\n    je .Lsvok{k}\n"));}
 out.push_str(&format!("    cmp $0, %rax\n    je .Lsvok{k}\n    cmp $1, %rax\n    je .Lsvok{k}\n    cmp $3, %rax\n    je .Lsvok{k}\n    cmp $4, %rax\n    je .Lsvok{k}\n    cmp $9, %rax\n    je .Lsvok{k}\n    cmp $16, %rax\n    je .Lsvok{k}\n    jmp hbc_type_error\n.Lsvok{k}:\n"));
}

pub fn validate(ff:&[Func])->Result<(),String> {
 if !active(){return Ok(());}
 let mut allowed=HashSet::new();
 for f in ff {visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if let Expr::Call(id,aa)=e{if is_builtin(id,"asort"){if let Some(Expr::BlockLit(id,_,_))=aa.get(3){allowed.insert(*id);}}}});}
 let mut bad=false;
 for f in ff {visit_stmts_ref(&f.stmts,&mut |s|{if matches!(s,Stmt::MemvarDecl(..)|Stmt::MemvarSet(..)|Stmt::ForEach(..)){bad=true;}},&mut |_|{});
 visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::HashLit(_)|Expr::FuncRef(_)|Expr::ByRef(_)){bad=true;}
 if matches!(e,Expr::BlockLit(id,..) if !allowed.contains(id)){bad=true;}
 if matches!(e,Expr::Call(id,_) if is_builtin(id,"array")||is_builtin(id,"hb_hkeys")||is_builtin(id,"hb_hvalues")){bad=true;}
 if matches!(e,Expr::ArrLit(_) if !literal(e)){bad=true;}});}
 if bad{return Err("local shared arrays with hashes, non-ASort blocks, indirect calls, by-reference storage, MEMVAR, FOR EACH or unique/computed array constructors are outside A2".to_string());}Ok(())
}
