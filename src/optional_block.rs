// Own MIT bounded static dispatch for pure optional-block wrappers.
// No runtime union, cloning of functions, or changes to Eval's ABI.
use crate::{Expr,Stmt,Func,CmpOp,visit_stmts_ref,visit_stmts_mut};
use std::collections::HashSet;
fn var(e:&Expr,p:&str)->bool {matches!(e,Expr::Var(v) if v==p)}
fn direct(f:&Func,user:&HashSet<String>)->bool {
 if f.init||f.name=="main"||f.params.len()!=2||user.contains("valtype")||user.contains("eval"){return false;}
 let (x,b)=(&f.params[0],&f.params[1]);
 let [Stmt::If(_,Expr::Cmp(CmpOp::EqEq,a,z),yes,no),Stmt::Ret(_,Some(tail))]=f.stmts.as_slice() else{return false};
 if !no.is_empty()||!var(tail,x)||!matches!(z.as_ref(),Expr::Str(s) if s=="B"){return false;}
 if !matches!(a.as_ref(),Expr::Call(id,aa) if id=="valtype" && aa.len()==1 && var(&aa[0],b)){return false;}
 matches!(yes.as_slice(),[Stmt::Ret(_,Some(Expr::Call(id,aa)))] if id=="eval"&&aa.len()==2&&var(&aa[0],b)&&var(&aa[1],x))
}
fn leaf(e:&Expr)->bool {matches!(e,Expr::Int(_)|Expr::Str(_)|Expr::Log(_)|Expr::Nil)}
// Reject reduction if any intermediate leaves Harbour's exact i64 range.
// Such calls remain on the pre-existing typed Eval route.
fn integer_value(e:&Expr,p:&str,value:i64)->Option<i64> {match e {
 Expr::Int(v)=>v.parse::<i64>().ok(),Expr::Var(v) if v==p=>Some(value),
 Expr::Bin(op @ ('+'|'-'|'*'),a,b)=>{
  let a=integer_value(a,p,value)?;let b=integer_value(b,p,value)?;
  match op {'+'=>a.checked_add(b),'-'=>a.checked_sub(b),'*'=>a.checked_mul(b),_=>None}
 },_=>None,
}}
fn substitute(e:&mut Expr,p:&str,value:&Expr){match e{
 Expr::Var(v) if v==p=>*e=value.clone(),
 Expr::Bin(_,a,b)=>{substitute(a,p,value);substitute(b,p,value);},_=>{},
}}
pub fn lower(funcs:&mut Vec<Func>)->bool {
 if !crate::DECIMAL_LOCAL_PROFILE.with(|v|v.get()) || crate::MACRO_CONTEXT.with(|v|v.get()){return false;}
 let user:HashSet<_>=funcs.iter().map(|f|f.name.clone()).collect();
 if user.len()!=funcs.len(){return false;}
 let mut templates:HashSet<_>=funcs.iter().filter(|f|direct(f,&user)).map(|f|f.name.clone()).collect();
 if templates.is_empty(){return false;}
 loop {
  let n=templates.len();
  for f in funcs.iter(){
   if f.init||f.name=="main"||f.params.len()!=2{continue;}
   if matches!(f.stmts.as_slice(),[Stmt::Ret(_,Some(Expr::Call(id,aa)))] if templates.contains(id)&&aa.len()==2&&var(&aa[0],&f.params[0])&&var(&aa[1],&f.params[1])){templates.insert(f.name.clone());}
  }
  if templates.len()==n{break;}
 }
 let mut changed=false;
 for f in funcs.iter_mut(){
  if templates.contains(&f.name){continue;}
  visit_stmts_mut(&mut f.stmts,&mut |e,_|{
   let Expr::Call(id,args)=e else{return};
   if !templates.contains(id)||args.is_empty()||args.len()>2||!leaf(&args[0]){return;}
   let replacement=if args.len()==1||leaf(&args[1]){Some(args[0].clone())}
    else if let Expr::BlockLit(_,pp,body)=&args[1]{
     if pp.len()==1&&body.len()==1&&matches!(&args[0],Expr::Int(v) if v.parse::<i64>().is_ok())&&matches!(&args[0],Expr::Int(v) if v.parse::<i64>().ok().and_then(|n|integer_value(&body[0],&pp[0],n)).is_some()){
      let mut v=body[0].clone();substitute(&mut v,&pp[0],&args[0]);Some(v)
     }else{None}
    }else{None};
   if let Some(v)=replacement{*e=v;changed=true;}
  });
 }
 // Remove the proven pure templates only when every external reference
 // was discharged. Incomplete coverage keeps the old checker rejection.
 let mut referenced=false;
 for f in funcs.iter().filter(|f|!templates.contains(&f.name)){
  visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|{if matches!(e,Expr::Call(id,_)|Expr::FuncRef(id)|Expr::Str(id) if templates.contains(&id.to_ascii_lowercase())){referenced=true;}});
 }
 if changed && !referenced{funcs.retain(|f|!templates.contains(&f.name));}
 changed
}
