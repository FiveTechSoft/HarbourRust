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
fn integer_value(e:&Expr,p:&str,value:i64)->Option<i64> {
 fn eval(e:&Expr,p:&str,value:i64)->Option<(i64,bool)>{match e{
  Expr::Int(v)=>Some((v.parse::<i64>().ok()?,false)),
  Expr::Var(v) if v==p=>Some((value,false)),
  Expr::Bin(op @ ('+'|'-'|'*'),a,b)=>{
   let (a,af)=eval(a,p,value)?;let (b,bf)=eval(b,p,value)?;
   let fp=af||bf||*op=='*';
   if fp&&(a.unsigned_abs()>9_007_199_254_740_992||b.unsigned_abs()>9_007_199_254_740_992){return None;}
   let n=match op {'+'=>a.checked_add(b),'-'=>a.checked_sub(b),'*'=>a.checked_mul(b),_=>None}?;
   if fp&&n.unsigned_abs()>9_007_199_254_740_992{return None;}
   Some((n,fp))
  },_=>None,
 }}
 eval(e,p,value).map(|v|v.0)
}
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

#[cfg(test)]
mod tests {
 use super::*;
 fn n(v:i64)->Expr{Expr::Int(v.to_string())}
 fn x()->Expr{Expr::Var("x".into())}
 fn op(o:char,a:Expr,b:Expr)->Expr{Expr::Bin(o,Box::new(a),Box::new(b))}
 #[test] fn exact_i64_add_sub_edges(){
  assert_eq!(integer_value(&op('+',x(),n(1)),"x",i64::MAX-1),Some(i64::MAX));
  assert_eq!(integer_value(&op('-',x(),n(1)),"x",i64::MIN+1),Some(i64::MIN));
  assert_eq!(integer_value(&op('*',x(),x()),"x",3037000499),None);
 }
 #[test] fn overflow_at_any_intermediate_stops_reduction(){
  assert_eq!(integer_value(&op('+',x(),n(1)),"x",i64::MAX),None);
  assert_eq!(integer_value(&op('-',x(),n(1)),"x",i64::MIN),None);
  assert_eq!(integer_value(&op('*',x(),x()),"x",3037000500),None);
  // Final mathematics fits, but the first intermediate does not.
  assert_eq!(integer_value(&op('-',op('+',x(),n(1)),n(1)),"x",i64::MAX),None);
  assert_eq!(integer_value(&op('+',op('-',x(),n(1)),n(1)),"x",i64::MIN),None);
 }
 #[test] fn refused_intermediates_leave_call_unreduced(){
  let direct=Func{init:false,name:"modify".into(),params:vec!["x".into(),"b".into()],ret:None,dyn_names:HashSet::new(),stmts:vec![
   Stmt::If(1,Expr::Cmp(CmpOp::EqEq,Box::new(Expr::Call("valtype".into(),vec![Expr::Var("b".into())])),Box::new(Expr::Str("B".into()))),vec![Stmt::Ret(2,Some(Expr::Call("eval".into(),vec![Expr::Var("b".into()),x()])))],vec![]),Stmt::Ret(3,Some(x()))]};
  for (value,body) in [(i64::MAX,op('-',op('+',x(),n(1)),n(1))),(3037000499,op('*',x(),x()))] {
   let call=Expr::Call("modify".into(),vec![n(value),Expr::BlockLit(9,vec!["x".into()],vec![body])]);
   let debug=format!("{:?}",call);
   let mut funcs=vec![Func{init:false,name:direct.name.clone(),params:direct.params.clone(),ret:None,dyn_names:HashSet::new(),stmts:vec![]},Func{init:false,name:"main".into(),params:vec![],ret:None,dyn_names:HashSet::new(),stmts:vec![Stmt::Ret(4,Some(call))]}];
   // Reconstruct the small template, without needing Clone for arbitrary statements.
   funcs[0].stmts=vec![Stmt::If(1,Expr::Cmp(CmpOp::EqEq,Box::new(Expr::Call("valtype".into(),vec![Expr::Var("b".into())])),Box::new(Expr::Str("B".into()))),vec![Stmt::Ret(2,Some(Expr::Call("eval".into(),vec![Expr::Var("b".into()),x()])))],vec![]),Stmt::Ret(3,Some(x()))];
   crate::DECIMAL_LOCAL_PROFILE.with(|v|v.set(true));
   assert!(!lower(&mut funcs));assert_eq!(funcs.len(),2);
   if let Stmt::Ret(_,Some(after))=&funcs[1].stmts[0]{assert_eq!(format!("{:?}",after),debug);}else{panic!("return lost")}
  }
 }
 #[test] fn multiplication_provenance_bounds_all_later_intermediates(){
  let edge=9_007_199_254_740_992;
  assert_eq!(integer_value(&op('-',op('*',x(),n(1)),n(9_007_199_254_740_993)),"x",1),None);
  for sign in [-1,1]{
   let product=op('*',x(),n(1));
   let beyond=op('+',product.clone(),n(sign));
   assert_eq!(integer_value(&beyond,"x",sign*edge),None);
   assert_eq!(integer_value(&op('-',product,n(-sign)),"x",sign*edge),None);
   assert_eq!(integer_value(&op('-',beyond,x()),"x",sign*edge),None);
   assert_eq!(integer_value(&op('+',op('*',x(),n(1)),n(-sign)),"x",sign*edge),Some(sign*(edge-1)));
  }
 }
 #[test] fn successful_cancellation_stays_exact(){
  assert_eq!(integer_value(&op('*',op('-',x(),x()),n(2)),"x",i64::MAX),Some(0));
 }
}
