// Experimental scalar-only LLVM IR lowering. Shares the existing checked AST.
use super::*;
#[derive(Clone)]
struct Ir { out: String, n: usize, label: usize, vars: std::collections::BTreeMap<String,String>, arrays: std::collections::BTreeMap<String,String>, asz: std::collections::BTreeMap<String,usize>, globals: Vec<String>, allocas: Vec<String>, sig_names: std::collections::BTreeSet<String>, bools: std::collections::BTreeSet<String>, traced: bool, frame: String, fname: String, current_line: usize, loops: Vec<(String,String)> }
impl Ir {
 fn tmp(&mut self)->String { self.n+=1; format!("%v{}",self.n) }
 fn line(&mut self,s:String){self.out.push_str(&format!("  {}\n",s));}
 fn lab(&mut self)->String {self.label+=1; format!("bb{}",self.label)}
 fn block(&mut self,l:&str){self.out.push_str(&format!("{}:\n",l));}
 fn ptr(&mut self,n:&str)->Result<String,String>{self.vars.get(n).cloned().ok_or(format!("LLVM scalar: unknown local {}",n))}
 fn trace_at(&mut self,line:usize) {
  self.current_line=line;
  if !self.traced{return}
  let (path,original)=TRACE_ORIGINS.with(|m|m.borrow().get(line.saturating_sub(1)).cloned()).unwrap_or_else(||("<unknown>".into(),line));
  let text=format!("  at {} ({}:{})\n",self.fname,path,original);
  let k=self.globals.len();self.globals.push(format!("@str{} = private constant [{} x i8] c\"{}\"",k,text.len(),text.as_bytes().iter().map(|b|format!("\\{:02X}",b)).collect::<String>()));
  let p=self.tmp();self.line(format!("{} = getelementptr [3 x i64], ptr {}, i64 0, i64 1",p,self.frame));self.line(format!("store volatile ptr @str{}, ptr {}",k,p));
  let q=self.tmp();self.line(format!("{} = getelementptr [3 x i64], ptr {}, i64 0, i64 2",q,self.frame));self.line(format!("store volatile i64 {}, ptr {}",text.len(),q));
 }
 fn unlink(&mut self){if self.traced {let p=self.tmp();self.line(format!("{} = load ptr, ptr {}",p,self.frame));self.line(format!("store volatile ptr {}, ptr @hbc_trace_top",p));}}
 fn slot(&mut self,n:&str,idx:&str)->Result<String,String>{
  let base=self.arrays.get(n).cloned().ok_or(format!("LLVM scalar: indexed access `{}` is not a fixed I64 array",n))?;
  let k=self.asz[n];
  let lo=self.tmp();self.line(format!("{} = icmp slt i64 {}, 1",lo,idx));
  let hi=self.tmp();self.line(format!("{} = icmp sgt i64 {}, {}",hi,idx,k));
  let bad=self.tmp();self.line(format!("{} = or i1 {}, {}",bad,lo,hi));
  let b=self.lab();let g=self.lab();self.line(format!("br i1 {}, label %{}, label %{}",bad,b,g));
  self.block(&b);self.line("call void @rt_bound_error()".into());self.line("unreachable".into());self.block(&g);
  let m=self.tmp();self.line(format!("{} = sub i64 {}, 1",m,idx));
  let p=self.tmp();self.line(format!("{} = getelementptr [{} x i64], ptr {}, i64 0, i64 {}",p,k,base,m));
  Ok(p)
 }
 fn expr(&mut self,e:&Expr)->Result<String,String>{
  Ok(match e {
   Expr::Seq(es)=>{
    let mut value=None;
    for item in es {value=Some(self.expr(item)?);}
    value.ok_or("LLVM scalar: empty sequence")?
   },
   Expr::Int(v)=>v.clone(), Expr::Log(v)=>if *v {"1".into()}else{"0".into()},
   Expr::Var(n)=>{if self.arrays.contains_key(n){return Err(format!("LLVM scalar: whole-array value `{}` unsupported",n))}let p=self.ptr(n)?;let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));v},
   Expr::Index(n,ie)=>{let ie=self.expr(ie)?;let p=self.slot(n,&ie)?;let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));v},
   Expr::Bin(op,a,b) if matches!(op,'+'|'-'|'*')=>{let a=self.expr(a)?;let b=self.expr(b)?;let v=self.tmp();self.line(format!("{} = {} i64 {}, {}",v,match op {'+'=>"add",'-'=>"sub",_=>"mul"},a,b));v},
   Expr::LNot(a)=>{
    let c=self.cond(a)?;
    let neg=self.tmp();self.line(format!("{} = xor i1 {}, true",neg,c));
    let r=self.tmp();self.line(format!("{} = zext i1 {} to i64",r,neg));r
   },
   Expr::LAnd(a,b)|Expr::LOr(a,b)=>{
    // Branch before lowering the RHS: calls, increments and errors must
    // occur only when the existing backend would evaluate that operand.
    let c=self.cond(a)?;
    let rhs=self.lab();let short=self.lab();let end=self.lab();
    let slot=self.tmp();self.allocas.push(format!("  {} = alloca i64\n",slot));
    let is_and=matches!(e,Expr::LAnd(..));
    self.line(format!("br i1 {}, label %{}, label %{}",c,if is_and{&rhs}else{&short},if is_and{&short}else{&rhs}));
    self.block(&short);self.line(format!("store i64 {}, ptr {}",if is_and{0}else{1},slot));self.line(format!("br label %{}",end));
    self.block(&rhs);let c=self.cond(b)?;let v=self.tmp();self.line(format!("{} = zext i1 {} to i64",v,c));self.line(format!("store i64 {}, ptr {}",v,slot));self.line(format!("br label %{}",end));
    self.block(&end);let r=self.tmp();self.line(format!("{} = load i64, ptr {}",r,slot));r
   },
   Expr::Cmp(op,a,b)=>{let a=self.expr(a)?;let b=self.expr(b)?;let v=self.tmp();self.line(format!("{} = icmp {} i64 {}, {}",v,match op{CmpOp::Eq|CmpOp::EqEq=>"eq",CmpOp::Ne=>"ne",CmpOp::Lt=>"slt",CmpOp::Le=>"sle",CmpOp::Gt=>"sgt",CmpOp::Ge=>"sge",_=>return Err("LLVM scalar: comparison unsupported".into())},a,b));let r=self.tmp();self.line(format!("{} = zext i1 {} to i64",r,v));r},
   Expr::Call(n,args) if (is_builtin(n,"min")||is_builtin(n,"max")) && args.len()==2=>{
    if args.iter().any(|a|self.isbool(a)){return Err("LLVM scalar: Min/Max only supports I64 operands".into())}
    let a=self.expr(&args[0])?;let b=self.expr(&args[1])?;
    let c=self.tmp();self.line(format!("{} = icmp {} i64 {}, {}",c,if is_builtin(n,"min"){"sle"}else{"sge"},a,b));
    let r=self.tmp();self.line(format!("{} = select i1 {}, i64 {}, i64 {}",r,c,a,b));r
   },
   Expr::Call(n,args) if is_builtin(n,"len") && args.len()==1=>{match &args[0] {Expr::Var(v) if self.asz.contains_key(v)=>self.asz[v].to_string(),_=>return Err("LLVM scalar: len() only on fixed I64 arrays".into())}},
   Expr::Call(n,args) if is_builtin(n,"procline") && (args.is_empty() || matches!(&args[..], [Expr::Int(v)] if v=="0"))=>PROC_LINES.with(|m|m.borrow().get(self.current_line.saturating_sub(1)).copied()).unwrap_or(self.current_line).to_string(),
   Expr::Inc(n,delta,prefix)=>{let ptr=self.ptr(n)?;let old=self.tmp();self.line(format!("{} = load i64, ptr {}",old,ptr));let pair=self.tmp();self.line(format!("{} = call {{i64,i1}} @llvm.sadd.with.overflow.i64(i64 {}, i64 {})",pair,old,delta));let next=self.tmp();let ov=self.tmp();self.line(format!("{} = extractvalue {{i64,i1}} {}, 0",next,pair));self.line(format!("{} = extractvalue {{i64,i1}} {}, 1",ov,pair));let bad=self.lab();let good=self.lab();self.line(format!("br i1 {}, label %{}, label %{}",ov,bad,good));self.block(&bad);self.line("call void @rt_inc_error()".into());self.line("unreachable".into());self.block(&good);self.line(format!("store i64 {}, ptr {}",next,ptr));if *prefix {next}else{old}},
   Expr::Call(n,args) if is_builtin(n,"iif") && args.len()==3=>{let c=self.cond(&args[0])?;let t=self.lab();let f=self.lab();let end=self.lab();let slot=self.tmp();self.allocas.push(format!("  {} = alloca i64\n",slot));self.line(format!("br i1 {}, label %{}, label %{}",c,t,f));self.block(&t);let a=self.expr(&args[1])?;self.line(format!("store i64 {}, ptr {}",a,slot));self.line(format!("br label %{}",end));self.block(&f);let b=self.expr(&args[2])?;self.line(format!("store i64 {}, ptr {}",b,slot));self.line(format!("br label %{}",end));self.block(&end);let r=self.tmp();self.line(format!("{} = load i64, ptr {}",r,slot));r},
   Expr::Call(n,args) if self.sig_names.contains(n)=>{let mut aa=Vec::new();for a in args {aa.push(format!("i64 {}",self.expr(a)?));}let r=self.tmp();self.line(format!("{} = call i64 @ll_{}({})",r,n,aa.join(", ")));r},
   _=>return Err(format!("LLVM scalar: expression unsupported: {:?}",e))
  })
 }
 fn isbool(&self,e:&Expr)->bool {match e {Expr::Seq(es)=>es.last().map(|e|self.isbool(e)).unwrap_or(false),Expr::Log(_)|Expr::Cmp(..)|Expr::LNot(_)|Expr::LAnd(..)|Expr::LOr(..)=>true,Expr::Var(n)=>self.bools.contains(n),Expr::Call(n,a) if is_builtin(n,"iif") && a.len()==3=>self.isbool(&a[1]),_=>false}}
 fn cond(&mut self,e:&Expr)->Result<String,String>{let v=self.expr(e)?;let c=self.tmp();self.line(format!("{} = icmp ne i64 {}, 0",c,v));Ok(c)}
 fn check_dead(&self,ss:&[Stmt])->Result<(),String>{
  // Reuse the exact lowering checks with the same locals and enclosing
  // loop destinations, but discard all generated unreachable IR.
  if !ss.is_empty(){let mut probe=self.clone();probe.stmts(ss)?;}
  Ok(())
 }
 fn stmts(&mut self,ss:&[Stmt])->Result<bool,String>{for (si,s) in ss.iter().enumerate(){self.trace_at(stmt_line(s));match s {
  Stmt::Local(_,n,Expr::ArrLit(items))|Stmt::Assign(_,n,Expr::ArrLit(items)) if self.arrays.contains_key(n)=>{
   // A literal containing logicals is Ty::DArr in the checked frontend,
   // with tagged cells, not a stack I64 array. Do not erase its tags.
   if items.iter().any(|e|matches!(e,Expr::Log(_))){
    return Err("LLVM scalar: tagged logical/mixed array literals unsupported".into())
   }
   let k=self.asz[n];
   if items.len()!=k {return Err(format!("LLVM scalar: array `{}` literal size {} does not match its declaration {}",n,items.len(),k))}
   let base=self.arrays[n].clone();
   for (i,item) in items.iter().enumerate() {
    let v=self.expr(item)?;
    let p=self.tmp();self.line(format!("{} = getelementptr [{} x i64], ptr {}, i64 0, i64 {}",p,k,base,i));
    self.line(format!("store i64 {}, ptr {}",v,p));
   }
  },
  Stmt::Local(_,n,e)|Stmt::Assign(_,n,e)=>{if self.arrays.contains_key(n){return Err(format!("LLVM scalar: whole-array assignment `{}` unsupported",n))}if self.isbool(e){self.bools.insert(n.clone());}let v=self.expr(e)?;let p=self.ptr(n)?;self.line(format!("store i64 {}, ptr {}",v,p));},
  Stmt::Ret(_,e)=>{let v=if let Some(e)=e{self.expr(e)?}else{"0".into()};self.unlink();self.line(format!("ret i64 {}",v));self.check_dead(&ss[si+1..])?;return Ok(true)},
  Stmt::Print(_,es,inline)=>{let mut vals=Vec::new();for (ei,e) in es.iter().enumerate() {if self.isbool(e){return Err("LLVM scalar: logical output not implemented".into())}match e {Expr::Str(s)=>{let k=self.globals.len();let text=if ei+1==es.len(){s.trim_end_matches(' ')}else{s.as_str()};let bytes=text.as_bytes();self.globals.push(format!("@str{} = private constant [{} x i8] c\"{}\"",k,bytes.len(),bytes.iter().map(|b|format!("\\{:02X}",b)).collect::<String>()));vals.push((format!("@str{}",k),Some(bytes.len()),false));},_=>{let v=self.expr(e)?;vals.push((v,None,(fold_int(e).is_some() || matches!(e,Expr::Call(n,_) if is_builtin(n,"procline")))));}}}if !inline{self.line("call void @rt_nl()".into());}for(i,(v,len,lit))in vals.iter().enumerate(){if i>0{self.line("call void @rt_sep()".into());}if let Some(n)=len{self.line(format!("call void @rt_str(ptr {}, i64 {})",v,n));}else{self.line(format!("call void @rt_{}(i64 {})",if *lit{"int"}else{"computed"},v));}}},
  Stmt::If(_,c,a,b)=>{let c=self.cond(c)?;let t=self.lab();let f=self.lab();let end=self.lab();self.line(format!("br i1 {}, label %{}, label %{}",c,t,f));self.block(&t);let ta=self.stmts(a)?;if !ta{self.line(format!("br label %{}",end));}self.block(&f);let tb=self.stmts(b)?;if !tb{self.line(format!("br label %{}",end));}if ta&&tb{self.check_dead(&ss[si+1..])?;return Ok(true)}self.block(&end);},
  Stmt::While(_,c,b)=>{let h=self.lab();let body=self.lab();let end=self.lab();self.line(format!("br label %{}",h));self.block(&h);self.trace_at(stmt_line(s));let c=self.cond(c)?;self.line(format!("br i1 {}, label %{}, label %{}",c,body,end));self.block(&body);self.loops.push((h.clone(),end.clone()));let done=self.stmts(b)?;self.loops.pop();if !done{self.line(format!("br label %{}",h));}self.block(&end);},
  Stmt::For(_,n,a,b,step,ss)=>{let a=self.expr(a)?;let p=self.ptr(n)?;self.line(format!("store i64 {}, ptr {}",a,p));let b=self.expr(b)?;let h=self.lab();let body=self.lab();let inc=self.lab();let store=self.lab();let end=self.lab();self.line(format!("br label %{}",h));self.block(&h);let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));let c=self.tmp();self.line(format!("{} = icmp {} i64 {}, {}",c,if *step>0{"sle"}else{"sge"},v,b));self.line(format!("br i1 {}, label %{}, label %{}",c,body,end));self.block(&body);self.loops.push((inc.clone(),end.clone()));let done=self.stmts(ss)?;self.loops.pop();if !done{self.line(format!("br label %{}",inc));}self.block(&inc);let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));let pair=self.tmp();self.line(format!("{} = call {{i64,i1}} @llvm.sadd.with.overflow.i64(i64 {}, i64 {})",pair,v,step));let next=self.tmp();let ov=self.tmp();self.line(format!("{} = extractvalue {{i64,i1}} {}, 0",next,pair));self.line(format!("{} = extractvalue {{i64,i1}} {}, 1",ov,pair));self.line(format!("br i1 {}, label %{}, label %{}",ov,end,store));self.block(&store);self.line(format!("store i64 {}, ptr {}",next,p));self.line(format!("br label %{}",h));self.block(&end);},
  Stmt::ArrSet(_,n,ie,e)=>{
   if !self.arrays.contains_key(n){return Err(format!("LLVM scalar: array write `{}` outside fixed I64 arrays unsupported",n))}
   let v=self.expr(e)?;
   let idx=self.expr(ie)?;
   let p=self.slot(n,&idx)?;
   self.line(format!("store i64 {}, ptr {}",v,p));
  },
  Stmt::Exit(_)|Stmt::Loop(_)=>{
   let (cont,end)=self.loops.last().cloned().ok_or("LLVM scalar: EXIT/LOOP outside loop")?;
   self.line(format!("br label %{}",if matches!(s,Stmt::Exit(_)){end}else{cont}));
   // This block is terminated, not a function return: surrounding IF/loop
   // lowering still emits any reachable merge or exit block.
   self.check_dead(&ss[si+1..])?;return Ok(true)
  },
  Stmt::CallStmt(_,e)=>{self.expr(e)?;},
  _=>return Err(format!("LLVM scalar: statement unsupported: {:?}",s))
 }}Ok(false)}
}
fn locals(ss:&[Stmt],out:&mut std::collections::BTreeSet<String>,arrays:&mut std::collections::BTreeMap<String,usize>){for s in ss{match s{Stmt::Local(_,n,e)=>{match e {Expr::ArrLit(items) if !items.iter().any(|x|matches!(x,Expr::ArrLit(_)|Expr::DArrNew))=>{arrays.insert(n.clone(),items.len());},_=>{out.insert(n.clone());}}},Stmt::If(_,_,a,b)=>{locals(a,out,arrays);locals(b,out,arrays)},Stmt::For(_,n,_,_,_,b)=>{out.insert(n.clone());locals(b,out,arrays)},Stmt::While(_,_,b)=>locals(b,out,arrays),_=>{}}}}
pub fn emit(funcs:&[Func],sigs:&[Sig],_target:Target,traced:bool)->Result<String,String>{
 for s in sigs{if !s.params.iter().all(|t|matches!(t,Ty::I64)) || !matches!(s.ret,None|Some(Ty::I64)){return Err("LLVM scalar: only I64 signatures supported".into())}}
 let mut ir=Ir{out:String::new(),n:0,label:0,vars:Default::default(),arrays:Default::default(),asz:Default::default(),globals:Vec::new(),allocas:Vec::new(),sig_names:funcs.iter().map(|f|f.name.clone()).collect(),bools:Default::default(),traced,frame:String::new(),fname:String::new(),current_line:0,loops:Vec::new()};
 for f in funcs{ir.vars.clear();ir.arrays.clear();ir.asz.clear();ir.bools.clear();ir.allocas.clear();ir.fname=f.name.clone();let begin=ir.out.len();ir.out.push_str(&format!("define i64 @ll_{}({}) {{\nentry:\n",f.name,f.params.iter().enumerate().map(|(i,_)|format!("i64 %arg{}",i)).collect::<Vec<_>>().join(", ")));if traced {ir.frame=ir.tmp();ir.line(format!("{} = alloca [3 x i64]",ir.frame));let old=ir.tmp();ir.line(format!("{} = load ptr, ptr @hbc_trace_top",old));ir.line(format!("store ptr {}, ptr {}",old,ir.frame));let text=ir.tmp();let len=ir.tmp();ir.line(format!("{} = getelementptr [3 x i64], ptr {}, i64 0, i64 1",text,ir.frame));ir.line(format!("{} = getelementptr [3 x i64], ptr {}, i64 0, i64 2",len,ir.frame));ir.line(format!("store ptr null, ptr {}",text));ir.line(format!("store i64 0, ptr {}",len));ir.line(format!("store volatile ptr {}, ptr @hbc_trace_top",ir.frame));}ir.trace_at(f.stmts.first().map(stmt_line).unwrap_or(0));let mut ns=std::collections::BTreeSet::new();let mut am=std::collections::BTreeMap::new();locals(&f.stmts,&mut ns,&mut am);for (n,k) in am {let p=ir.tmp();ir.line(format!("{} = alloca [{} x i64]",p,k));ir.arrays.insert(n.clone(),p);ir.asz.insert(n,k);}ns.extend(f.params.iter().cloned());for n in ns{let p=ir.tmp();ir.line(format!("{} = alloca i64",p));ir.vars.insert(n,p);}for(i,p)in f.params.iter().enumerate(){let ptr=ir.ptr(p)?;ir.line(format!("store i64 %arg{}, ptr {}",i,ptr));}if !ir.stmts(&f.stmts)?{ir.unlink();ir.line("ret i64 0".into());}let idx=begin+ir.out[begin..].find("entry:\n").unwrap()+7;ir.out.insert_str(idx,&ir.allocas.concat());ir.out.push_str("}\n");}
 Ok(format!("{}\n{}\n@hbc_trace_top = external global ptr\ndeclare void @rt_inc_error() noreturn\ndeclare void @rt_bound_error() noreturn\ndeclare void @rt_nl()\ndeclare void @rt_sep()\ndeclare void @rt_str(ptr, i64)\ndeclare void @rt_int(i64)\ndeclare void @rt_computed(i64)\ndeclare {{i64,i1}} @llvm.sadd.with.overflow.i64(i64,i64)\n",ir.globals.join("\n"),ir.out))
}
