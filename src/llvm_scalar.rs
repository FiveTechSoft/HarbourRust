// Experimental scalar-only LLVM IR lowering. Shares the existing checked AST.
use super::*;
struct Ir { out: String, n: usize, label: usize, vars: std::collections::BTreeMap<String,String>, globals: Vec<String>, allocas: Vec<String>, sig_names: std::collections::BTreeSet<String>, bools: std::collections::BTreeSet<String> }
impl Ir {
 fn tmp(&mut self)->String { self.n+=1; format!("%v{}",self.n) }
 fn line(&mut self,s:String){self.out.push_str(&format!("  {}\n",s));}
 fn lab(&mut self)->String {self.label+=1; format!("bb{}",self.label)}
 fn block(&mut self,l:&str){self.out.push_str(&format!("{}:\n",l));}
 fn ptr(&mut self,n:&str)->Result<String,String>{self.vars.get(n).cloned().ok_or(format!("LLVM scalar: unknown local {}",n))}
 fn expr(&mut self,e:&Expr)->Result<String,String>{
  Ok(match e {
   Expr::Int(v)=>v.clone(), Expr::Log(v)=>if *v {"1".into()}else{"0".into()},
   Expr::Var(n)=>{let p=self.ptr(n)?;let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));v},
   Expr::Bin(op,a,b) if matches!(op,'+'|'-'|'*')=>{let a=self.expr(a)?;let b=self.expr(b)?;let v=self.tmp();self.line(format!("{} = {} i64 {}, {}",v,match op {'+'=>"add",'-'=>"sub",_=>"mul"},a,b));v},
   Expr::Cmp(op,a,b)=>{let a=self.expr(a)?;let b=self.expr(b)?;let v=self.tmp();self.line(format!("{} = icmp {} i64 {}, {}",v,match op{CmpOp::Eq|CmpOp::EqEq=>"eq",CmpOp::Ne=>"ne",CmpOp::Lt=>"slt",CmpOp::Le=>"sle",CmpOp::Gt=>"sgt",CmpOp::Ge=>"sge",_=>return Err("LLVM scalar: comparison unsupported".into())},a,b));let r=self.tmp();self.line(format!("{} = zext i1 {} to i64",r,v));r},
   Expr::Call(n,args) if is_builtin(n,"procline") && args.is_empty()=>return Err("LLVM scalar: ProcLine deferred pending origin mapping".into()),
   Expr::Call(n,args) if is_builtin(n,"iif") && args.len()==3=>{let c=self.cond(&args[0])?;let t=self.lab();let f=self.lab();let end=self.lab();let slot=self.tmp();self.allocas.push(format!("  {} = alloca i64\n",slot));self.line(format!("br i1 {}, label %{}, label %{}",c,t,f));self.block(&t);let a=self.expr(&args[1])?;self.line(format!("store i64 {}, ptr {}",a,slot));self.line(format!("br label %{}",end));self.block(&f);let b=self.expr(&args[2])?;self.line(format!("store i64 {}, ptr {}",b,slot));self.line(format!("br label %{}",end));self.block(&end);let r=self.tmp();self.line(format!("{} = load i64, ptr {}",r,slot));r},
   Expr::Call(n,args) if self.sig_names.contains(n)=>{let mut aa=Vec::new();for a in args {aa.push(format!("i64 {}",self.expr(a)?));}let r=self.tmp();self.line(format!("{} = call i64 @ll_{}({})",r,n,aa.join(", ")));r},
   _=>return Err(format!("LLVM scalar: expression unsupported: {:?}",e))
  })
 }
 fn isbool(&self,e:&Expr)->bool {match e {Expr::Log(_)|Expr::Cmp(..)|Expr::LNot(_)|Expr::LAnd(..)|Expr::LOr(..)=>true,Expr::Var(n)=>self.bools.contains(n),Expr::Call(n,a) if is_builtin(n,"iif") && a.len()==3=>self.isbool(&a[1]),_=>false}}
 fn cond(&mut self,e:&Expr)->Result<String,String>{let v=self.expr(e)?;let c=self.tmp();self.line(format!("{} = icmp ne i64 {}, 0",c,v));Ok(c)}
 fn stmts(&mut self,ss:&[Stmt])->Result<bool,String>{for s in ss {match s {
  Stmt::Local(_,n,e)|Stmt::Assign(_,n,e)=>{if self.isbool(e){self.bools.insert(n.clone());}let v=self.expr(e)?;let p=self.ptr(n)?;self.line(format!("store i64 {}, ptr {}",v,p));},
  Stmt::Ret(_,e)=>{let v=if let Some(e)=e{self.expr(e)?}else{"0".into()};self.line(format!("ret i64 {}",v));return Ok(true)},
  Stmt::Print(_,es,inline)=>{let mut vals=Vec::new();for e in es {if self.isbool(e){return Err("LLVM scalar: logical output not implemented".into())}match e {Expr::Str(s)=>{let k=self.globals.len();let bytes=s.as_bytes();self.globals.push(format!("@str{} = private constant [{} x i8] c\"{}\"",k,bytes.len(),bytes.iter().map(|b|format!("\\{:02X}",b)).collect::<String>()));vals.push((format!("@str{}",k),Some(bytes.len()),false));},_=>{let v=self.expr(e)?;vals.push((v,None,fold_int(e).is_some()));}}}if !inline{self.line("call void @rt_nl()".into());}for(i,(v,len,lit))in vals.iter().enumerate(){if i>0{self.line("call void @rt_sep()".into());}if let Some(n)=len{self.line(format!("call void @rt_str(ptr {}, i64 {})",v,n));}else{self.line(format!("call void @rt_{}(i64 {})",if *lit{"int"}else{"computed"},v));}}},
  Stmt::If(_,c,a,b)=>{let c=self.cond(c)?;let t=self.lab();let f=self.lab();let end=self.lab();self.line(format!("br i1 {}, label %{}, label %{}",c,t,f));self.block(&t);let ta=self.stmts(a)?;if !ta{self.line(format!("br label %{}",end));}self.block(&f);let tb=self.stmts(b)?;if !tb{self.line(format!("br label %{}",end));}if ta&&tb{return Ok(true)}self.block(&end);},
  Stmt::While(_,c,b)=>{let h=self.lab();let body=self.lab();let end=self.lab();self.line(format!("br label %{}",h));self.block(&h);let c=self.cond(c)?;self.line(format!("br i1 {}, label %{}, label %{}",c,body,end));self.block(&body);if !self.stmts(b)?{self.line(format!("br label %{}",h));}self.block(&end);},
  Stmt::For(_,n,a,b,step,ss)=>{let a=self.expr(a)?;let b=self.expr(b)?;let p=self.ptr(n)?;self.line(format!("store i64 {}, ptr {}",a,p));let h=self.lab();let body=self.lab();let inc=self.lab();let store=self.lab();let end=self.lab();self.line(format!("br label %{}",h));self.block(&h);let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));let c=self.tmp();self.line(format!("{} = icmp {} i64 {}, {}",c,if *step>0{"sle"}else{"sge"},v,b));self.line(format!("br i1 {}, label %{}, label %{}",c,body,end));self.block(&body);if !self.stmts(ss)?{self.line(format!("br label %{}",inc));}self.block(&inc);let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));let pair=self.tmp();self.line(format!("{} = call {{i64,i1}} @llvm.sadd.with.overflow.i64(i64 {}, i64 {})",pair,v,step));let next=self.tmp();let ov=self.tmp();self.line(format!("{} = extractvalue {{i64,i1}} {}, 0",next,pair));self.line(format!("{} = extractvalue {{i64,i1}} {}, 1",ov,pair));self.line(format!("br i1 {}, label %{}, label %{}",ov,end,store));self.block(&store);self.line(format!("store i64 {}, ptr {}",next,p));self.line(format!("br label %{}",h));self.block(&end);},
  Stmt::CallStmt(_,e)=>{self.expr(e)?;},
  _=>return Err(format!("LLVM scalar: statement unsupported: {:?}",s))
 }}Ok(false)}
}
fn locals(ss:&[Stmt],out:&mut std::collections::BTreeSet<String>){for s in ss{match s{Stmt::Local(_,n,_)=>{out.insert(n.clone());},Stmt::If(_,_,a,b)=>{locals(a,out);locals(b,out)},Stmt::For(_,_,_,_,_,b)|Stmt::While(_,_,b)=>locals(b,out),_=>{}}}}
pub fn emit(funcs:&[Func],sigs:&[Sig],_target:Target)->Result<String,String>{
 for s in sigs{if !s.params.iter().all(|t|matches!(t,Ty::I64)) || !matches!(s.ret,None|Some(Ty::I64)){return Err("LLVM scalar: only I64/Bool signatures supported".into())}}
 let mut ir=Ir{out:String::new(),n:0,label:0,vars:Default::default(),globals:Vec::new(),allocas:Vec::new(),sig_names:funcs.iter().map(|f|f.name.clone()).collect(),bools:Default::default()};
 for f in funcs{ir.vars.clear();ir.bools.clear();ir.allocas.clear();let begin=ir.out.len();ir.out.push_str(&format!("define i64 @ll_{}({}) {{\nentry:\n",f.name,f.params.iter().enumerate().map(|(i,_)|format!("i64 %arg{}",i)).collect::<Vec<_>>().join(", ")));let mut ns=std::collections::BTreeSet::new();locals(&f.stmts,&mut ns);ns.extend(f.params.iter().cloned());for n in ns{let p=ir.tmp();ir.line(format!("{} = alloca i64",p));ir.vars.insert(n,p);}for(i,p)in f.params.iter().enumerate(){let ptr=ir.ptr(p)?;ir.line(format!("store i64 %arg{}, ptr {}",i,ptr));}if !ir.stmts(&f.stmts)?{ir.line("ret i64 0".into());}let idx=begin+ir.out[begin..].find("entry:\n").unwrap()+7;ir.out.insert_str(idx,&ir.allocas.concat());ir.out.push_str("}\n");}
 Ok(format!("{}\n{}\ndeclare void @rt_nl()\ndeclare void @rt_sep()\ndeclare void @rt_str(ptr, i64)\ndeclare void @rt_int(i64)\ndeclare void @rt_computed(i64)\ndeclare {{i64,i1}} @llvm.sadd.with.overflow.i64(i64,i64)\n",ir.globals.join("\n"),ir.out))
}
