// Experimental scalar-only LLVM IR lowering. Shares the existing checked AST.
use super::*;
// Pure ASCII constant trees only. Chr's existing helper emits n & 255;
// restricting inputs to 0..127 avoids inventing a byte/Unicode convention.
fn borrowed_constant(e:&Expr)->Option<String>{match e {
 Expr::Str(s)=>Some(s.clone()),
 Expr::Bin('+',a,b)=>Some(borrowed_constant(a)?+&borrowed_constant(b)?),
 Expr::Call(n,args) if is_builtin(n,"chr")&&args.len()==1=>{
  if let Expr::Int(v)=&args[0]{let n=v.parse::<u8>().ok()?;if n<128{return Some((n as char).to_string())}}
  None
 },
 _=>None
}}
// Conservative structural proof, including unreachable statements. Unknown
// statement forms are never evidence for a NIL-only function.
fn nil_only_body(ss:&[Stmt])->Option<bool>{
 let mut terminates=false;
 for s in ss {let ends=match s {
  Stmt::Ret(_,None)=>true,
  Stmt::Ret(_,Some(_))=>return None,
  Stmt::If(_,_,a,b)=>{let a=nil_only_body(a)?;let b=nil_only_body(b)?;a&&b},
  Stmt::While(_,_,b)|Stmt::For(_,_,_,_,_,b)=>{nil_only_body(b)?;false},
  Stmt::Local(..)|Stmt::Assign(..)|Stmt::Print(..)|Stmt::CallStmt(..)|Stmt::ArrSet(..)|Stmt::Exit(_)|Stmt::Loop(_)=>false,
  _=>return None
 };terminates|=ends;}
 Some(terminates)
}
// Check every expression, including dead arms and post-return code. Discard
// context propagates only through sequence prefixes and lazy IIF arms.
fn effect_uses(e:&Expr,discard:bool,voids:&std::collections::BTreeSet<String>)->Result<(),String>{
 match e {
  Expr::Call(n,args)=>{
   if voids.contains(n)&&!discard{return Err(format!("LLVM scalar: NIL-only effect call `{}` cannot be used as a value",n))}
   for(i,a)in args.iter().enumerate(){effect_uses(a,discard&&is_builtin(n,"iif")&&i>0,voids)?;}
  },
  Expr::Seq(es)=>for(i,a)in es.iter().enumerate(){effect_uses(a,discard||i+1<es.len(),voids)?;},
  Expr::Bin(_,a,b)|Expr::Cmp(_,a,b)|Expr::LAnd(a,b)|Expr::LOr(a,b)=>{effect_uses(a,false,voids)?;effect_uses(b,false,voids)?;},
  Expr::LNot(a)|Expr::Index(_,a)=>effect_uses(a,false,voids)?,
  Expr::IdxCompound(_,a,_,b)=>{effect_uses(a,false,voids)?;effect_uses(b,false,voids)?;},
  Expr::ArrLit(es)|Expr::BlockLit(_,_,es)=>for a in es{effect_uses(a,false,voids)?;},
  Expr::Index2(_,a,b)=>{effect_uses(a,false,voids)?;effect_uses(b,false,voids)?;},
  Expr::Index3(_,a,b,c)=>for e in [a,b,c]{effect_uses(e,false,voids)?;},
  Expr::Index4(_,a,b,c,d)=>for e in [a,b,c,d]{effect_uses(e,false,voids)?;},
  Expr::HashLit(es)=>for(a,b)in es{effect_uses(a,false,voids)?;effect_uses(b,false,voids)?;},
  Expr::Send(a,_,args)=>{effect_uses(a,false,voids)?;for e in args{effect_uses(e,false,voids)?;}},
  Expr::FloatV(..)|Expr::Float(..)|Expr::Int(_)|Expr::Str(_)|Expr::Var(_)|Expr::Inc(..)|Expr::ByRef(_)|Expr::DArrNew|Expr::SelfObj|Expr::SelfGet(_)|Expr::Nil|Expr::Log(_)=>{}
 }Ok(())
}
fn check_effect_uses(ss:&[Stmt],voids:&std::collections::BTreeSet<String>)->Result<(),String>{
 for s in ss {match s {
  Stmt::CallStmt(_,e)=>effect_uses(e,true,voids)?,
  Stmt::Local(_,_,e)|Stmt::Assign(_,_,e)|Stmt::Ret(_,Some(e))=>effect_uses(e,false,voids)?,
  Stmt::Print(_,es,_)=>for e in es{effect_uses(e,false,voids)?;},
  Stmt::If(_,e,a,b)=>{effect_uses(e,false,voids)?;check_effect_uses(a,voids)?;check_effect_uses(b,voids)?;},
  Stmt::While(_,e,b)=>{effect_uses(e,false,voids)?;check_effect_uses(b,voids)?;},
  Stmt::For(_,_,a,b,_,body)=>{effect_uses(a,false,voids)?;effect_uses(b,false,voids)?;check_effect_uses(body,voids)?;},
  Stmt::ArrSet(_,_,a,b)=>{effect_uses(a,false,voids)?;effect_uses(b,false,voids)?;},
  Stmt::Ret(_,None)|Stmt::Exit(_)|Stmt::Loop(_)=>{},
  _=>return Err("LLVM scalar: statement outside effect-use proof".into())
 }}Ok(())
}
#[derive(Clone)]
struct Ir { trace_texts: std::collections::BTreeMap<String,usize>, strings: std::collections::BTreeMap<String,String>, windows: bool, voids: std::collections::BTreeSet<String>, void_return: bool, out: String, n: usize, label: usize, vars: std::collections::BTreeMap<String,String>, arrays: std::collections::BTreeMap<String,String>, asz: std::collections::BTreeMap<String,usize>, globals: Vec<String>, allocas: Vec<String>, sig_names: std::collections::BTreeSet<String>, bool_returns: std::collections::BTreeSet<String>, bools: std::collections::BTreeSet<String>, traced: bool, frame: String, fname: String, current_line: usize, loops: Vec<(String,String)> }
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
  // Text identity is not part of the diagnostic contract. Reuse identical
  // immutable bytes, while preserving EVERY volatile pointer/length update.
  let k=if let Some(&k)=self.trace_texts.get(&text){k}else{
   let k=self.globals.len();self.globals.push(format!("@str{} = private constant [{} x i8] c\"{}\"",k,text.len(),text.as_bytes().iter().map(|b|format!("\\{:02X}",b)).collect::<String>()));
   self.trace_texts.insert(text.clone(),k);k
  };
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
    for (i,item) in es.iter().enumerate() {if i+1<es.len(){self.effect(item)?;}else{value=Some(self.expr(item)?);}}
    value.ok_or("LLVM scalar: empty sequence")?
   },
   Expr::Int(v)=>v.clone(), Expr::Log(v)=>if *v {"1".into()}else{"0".into()},
   Expr::Var(n)=>{if self.strings.contains_key(n){return Err("LLVM scalar: borrowed constant string only allowed as a direct print item".into())}if self.arrays.contains_key(n){return Err(format!("LLVM scalar: whole-array value `{}` unsupported",n))}let p=self.ptr(n)?;let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));v},
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
   Expr::Cmp(op,a,b) if matches!(op,CmpOp::Eq|CmpOp::Ne|CmpOp::EqEq) && (matches!(&**a,Expr::Nil)^matches!(&**b,Expr::Nil))=>{
    // The checked other operand must lower as an existing I64/logical scalar.
    // Evaluate it even though the different-type equality result is constant.
    // NIL itself has no LLVM value or storage representation.
    let other=if matches!(&**a,Expr::Nil){b}else{a};self.expr(other)?;
    if matches!(op,CmpOp::Ne){"1".into()}else{"0".into()}
   },
   Expr::Cmp(op,a,b)=>{let a=self.expr(a)?;let b=self.expr(b)?;let v=self.tmp();self.line(format!("{} = icmp {} i64 {}, {}",v,match op{CmpOp::Eq|CmpOp::EqEq=>"eq",CmpOp::Ne=>"ne",CmpOp::Lt=>"slt",CmpOp::Le=>"sle",CmpOp::Gt=>"sgt",CmpOp::Ge=>"sge",_=>return Err("LLVM scalar: comparison unsupported".into())},a,b));let r=self.tmp();self.line(format!("{} = zext i1 {} to i64",r,v));r},
   Expr::Call(n,args) if is_builtin(n,"empty") && args.len()==1=>{
    if let Expr::Var(v)=&args[0]{if let Some(k)=self.asz.get(v){return Ok(if *k==0{"1".into()}else{"0".into()})}}
    let v=self.expr(&args[0])?;let c=self.tmp();self.line(format!("{} = icmp eq i64 {}, 0",c,v));let r=self.tmp();self.line(format!("{} = zext i1 {} to i64",r,c));r
   },
   Expr::Call(n,args) if is_bitop(n)=>{
    let mut v=self.expr(&args[0])?;
    if is_builtin(n,"hb_bitnot") {let r=self.tmp();self.line(format!("{} = xor i64 {}, -1",r,v));r}
    else {
     for arg in &args[1..] {let b=self.expr(arg)?;let r=self.tmp();self.line(format!("{} = {} i64 {}, {}",r,if is_builtin(n,"hb_bitand"){"and"}else if is_builtin(n,"hb_bitor"){"or"}else{"xor"},v,b));v=r;}
     v
    }
   },
   Expr::Call(n,args) if is_bitindex(n)=>{
    let v=self.expr(&args[0])?;
    let bit=match &args[1]{Expr::Int(s)=>s.parse::<u32>().map_err(|_|"LLVM scalar: invalid bit index")?,_=>return Err("LLVM scalar: nonliteral bit index".into())};
    if bit>=64{return Err("LLVM scalar: invalid bit index".into())}
    let mask=1u64<<bit;
    if is_builtin(n,"hb_bittest"){
     let a=self.tmp();self.line(format!("{} = and i64 {}, {}",a,v,mask));let b=self.tmp();self.line(format!("{} = icmp ne i64 {}, 0",b,a));let r=self.tmp();self.line(format!("{} = zext i1 {} to i64",r,b));r
    } else {let r=self.tmp();self.line(format!("{} = {} i64 {}, {}",r,if is_builtin(n,"hb_bitset"){"or"}else{"and"},v,if is_builtin(n,"hb_bitset"){mask}else{!mask}));r}
   },
   Expr::Call(n,args) if (is_builtin(n,"min")||is_builtin(n,"max")) && args.len()==2=>{
    let a=self.expr(&args[0])?;let b=self.expr(&args[1])?;
    let c=self.tmp();self.line(format!("{} = icmp {} i64 {}, {}",c,if is_builtin(n,"min"){"sle"}else{"sge"},a,b));
    let r=self.tmp();self.line(format!("{} = select i1 {}, i64 {}, i64 {}",r,c,a,b));r
   },
   Expr::Call(n,args) if is_builtin(n,"len") && args.len()==1=>{match &args[0] {Expr::Var(v) if self.asz.contains_key(v)=>self.asz[v].to_string(),_=>return Err("LLVM scalar: len() only on fixed I64 arrays".into())}},
   Expr::Call(n,args) if is_builtin(n,"procline") && (args.is_empty() || matches!(&args[..], [Expr::Int(v)] if v=="0"))=>PROC_LINES.with(|m|m.borrow().get(self.current_line.saturating_sub(1)).copied()).unwrap_or(self.current_line).to_string(),
   Expr::Inc(n,delta,prefix)=>{let ptr=self.ptr(n)?;let old=self.tmp();self.line(format!("{} = load i64, ptr {}",old,ptr));let pair=self.tmp();self.line(format!("{} = call {{i64,i1}} @llvm.sadd.with.overflow.i64(i64 {}, i64 {})",pair,old,delta));let next=self.tmp();let ov=self.tmp();self.line(format!("{} = extractvalue {{i64,i1}} {}, 0",next,pair));self.line(format!("{} = extractvalue {{i64,i1}} {}, 1",ov,pair));let bad=self.lab();let good=self.lab();self.line(format!("br i1 {}, label %{}, label %{}",ov,bad,good));self.block(&bad);self.line("call void @rt_inc_error()".into());self.line("unreachable".into());self.block(&good);self.line(format!("store i64 {}, ptr {}",next,ptr));if *prefix {next}else{old}},
   Expr::Call(n,args) if is_builtin(n,"iif") && args.len()==3=>{let c=self.cond(&args[0])?;let t=self.lab();let f=self.lab();let end=self.lab();let slot=self.tmp();self.allocas.push(format!("  {} = alloca i64\n",slot));self.line(format!("br i1 {}, label %{}, label %{}",c,t,f));self.block(&t);let a=self.expr(&args[1])?;self.line(format!("store i64 {}, ptr {}",a,slot));self.line(format!("br label %{}",end));self.block(&f);let b=self.expr(&args[2])?;self.line(format!("store i64 {}, ptr {}",b,slot));self.line(format!("br label %{}",end));self.block(&end);let r=self.tmp();self.line(format!("{} = load i64, ptr {}",r,slot));r},
   Expr::Call(n,_) if self.voids.contains(n)=>return Err(format!("LLVM scalar: NIL-only effect call `{}` cannot be used as a value",n)),
   Expr::Call(n,args) if self.sig_names.contains(n)=>{let mut aa=Vec::new();for a in args {aa.push(format!("i64 {}",self.expr(a)?));}let r=self.tmp();self.line(format!("{} = call i64 @ll_{}({})",r,n,aa.join(", ")));r},
   Expr::IdxCompound(..)=>return Err("LLVM scalar: indexed compound assignment `a[i] op= e` is not in this subset (default-backend feature added with the arrayidx piece; the LLVM subset never accepted this form, so nothing previously supported is lost)".into()),
   _=>return Err(format!("LLVM scalar: expression unsupported: {:?}",e))
  })
 }
 // A discarded NIL effect has no scalar value or storage representation.
 fn effect(&mut self,e:&Expr)->Result<(),String>{
  match e {
   Expr::Nil=>Ok(()),
   Expr::Call(n,args) if self.voids.contains(n)=>{
    let mut aa=Vec::new();for a in args{aa.push(format!("i64 {}",self.expr(a)?));}
    self.line(format!("call void @ll_{}({})",n,aa.join(", ")));Ok(())
   },
   Expr::Seq(es)=>{for e in es{self.effect(e)?;}Ok(())},
   Expr::Call(n,args) if (is_builtin(n,"qout") || is_builtin(n,"qqout") || is_builtin(n,"outstd"))=>self.print_items(args,!is_builtin(n,"qout"),is_builtin(n,"outstd")),
   Expr::Call(n,args) if is_builtin(n,"iif") && args.len()==3=>{
    let c=self.cond(&args[0])?;let t=self.lab();let f=self.lab();let end=self.lab();
    self.line(format!("br i1 {}, label %{}, label %{}",c,t,f));
    self.block(&t);self.effect(&args[1])?;self.line(format!("br label %{}",end));
    self.block(&f);self.effect(&args[2])?;self.line(format!("br label %{}",end));self.block(&end);Ok(())
   },
   _=>{self.expr(e)?;Ok(())}
  }
 }
 fn isbool(&self,e:&Expr)->bool {match e {Expr::Seq(es)=>es.last().map(|e|self.isbool(e)).unwrap_or(false),Expr::Log(_)|Expr::Cmp(..)|Expr::LNot(_)|Expr::LAnd(..)|Expr::LOr(..)=>true,Expr::Var(n)=>self.bools.contains(n),Expr::Call(n,_) if self.bool_returns.contains(n)=>true,Expr::Call(n,_) if is_builtin(n,"hb_bittest")||is_builtin(n,"empty")=>true,Expr::Call(n,a) if is_builtin(n,"iif") && a.len()==3=>self.isbool(&a[1]),Expr::Call(n,a) if (is_builtin(n,"min")||is_builtin(n,"max")) && a.len()==2=>self.isbool(&a[0]),_=>false}}
 fn cond(&mut self,e:&Expr)->Result<String,String>{let v=self.expr(e)?;let c=self.tmp();self.line(format!("{} = icmp ne i64 {}, 0",c,v));Ok(c)}
 fn print_items(&mut self,es:&[Expr],inline:bool,raw:bool)->Result<(),String>{
  // Evaluate every item before emitting the outer newline or separator.
  let mut vals=Vec::new();
  for (ei,e) in es.iter().enumerate() {
   let borrowed=match e {
    Expr::Var(n)=>self.strings.get(n).cloned().map(Expr::Str),
    Expr::Call(n,args) if is_builtin(n,"hb_eol")&&args.is_empty()=>Some(Expr::Str(if self.windows{"\r\n"}else{"\n"}.into())),
    _=>None
   };
   let e=borrowed.as_ref().unwrap_or(e);
   // Print-only selection between static literals: no string value ABI,
   // local storage, owned result or general expression support is introduced.
   if let Expr::Call(n,args)=e {if is_builtin(n,"iif") && args.len()==3 {
    if let (Expr::Str(a),Expr::Str(b))=(&args[1],&args[2]) {
     let c=self.cond(&args[0])?;let k=self.globals.len();let mut lens=Vec::new();
     for text in [a,b] {
      let text=if !raw&&ei+1==es.len(){text.trim_end_matches(' ')}else{text.as_str()};
      let bytes=text.as_bytes();lens.push(bytes.len());
      self.globals.push(format!("@str{} = private constant [{} x i8] c\"{}\"",self.globals.len(),bytes.len(),bytes.iter().map(|b|format!("\\{:02X}",b)).collect::<String>()));
     }
     let p=self.tmp();self.line(format!("{} = select i1 {}, ptr @str{}, ptr @str{}",p,c,k,k+1));
     let len=self.tmp();self.line(format!("{} = select i1 {}, i64 {}, i64 {}",len,c,lens[0],lens[1]));
     vals.push((p,Some(len),false));continue
    }
   }}
   if self.isbool(e){
    let c=self.cond(e)?;let k=self.globals.len();
    self.globals.push(format!("@str{} = private constant [3 x i8] c\".T.\"",k));
    self.globals.push(format!("@str{} = private constant [3 x i8] c\".F.\"",k+1));
    let p=self.tmp();self.line(format!("{} = select i1 {}, ptr @str{}, ptr @str{}",p,c,k,k+1));
    vals.push((p,Some("3".to_string()),false));continue
   }
   match e {
    Expr::Str(s)=>{
     let k=self.globals.len();
     let text=if !raw&&ei+1==es.len(){s.trim_end_matches(' ')}else{s.as_str()};
     let bytes=text.as_bytes();
     self.globals.push(format!("@str{} = private constant [{} x i8] c\"{}\"",k,bytes.len(),bytes.iter().map(|b|format!("\\{:02X}",b)).collect::<String>()));
     vals.push((format!("@str{}",k),Some(bytes.len().to_string()),false));
    },
    _=>{
     let v=self.expr(e)?;
     let literal=fold_int(e).is_some() || matches!(e,Expr::Call(n,_) if is_builtin(n,"procline"));
     vals.push((v,None,literal));
    }
   }
  }
  if !inline{self.line("call void @rt_nl()".into());}
  for(i,(v,len,lit))in vals.iter().enumerate(){
   if i>0{self.line("call void @rt_sep()".into());}
   if let Some(n)=len{self.line(format!("call void @rt_str(ptr {}, i64 {})",v,n));}
   else{self.line(format!("call void @rt_{}(i64 {})",if *lit{"int"}else{"computed"},v));}
  }
  Ok(())
 }
 fn check_dead(&self,ss:&[Stmt])->Result<(),String>{
  // Reuse the exact lowering checks with the same locals and enclosing
  // loop destinations, but discard all generated unreachable IR.
  if !ss.is_empty(){let mut probe=self.clone();probe.stmts(ss)?;}
  Ok(())
 }
 fn stmts(&mut self,ss:&[Stmt])->Result<bool,String>{
  // Block-local names may be reused with another type in disjoint arms.
  // Outer variables retain their frontend-checked type; local classifications
  // must not leak into the sibling arm or enclosing block.
  let bindings=(self.vars.clone(),self.arrays.clone(),self.asz.clone(),self.bools.clone(),self.strings.clone());
  let result=self.stmts_inner(ss);
  (self.vars,self.arrays,self.asz,self.bools,self.strings)=bindings;
  result
 }
 fn stmts_inner(&mut self,ss:&[Stmt])->Result<bool,String>{for (si,s) in ss.iter().enumerate(){self.trace_at(stmt_line(s));match s {
  Stmt::Local(_,n,e) if borrowed_constant(e).is_some()=>{
   // Pure constant tree only, borrowed from immutable global bytes.
   // No address, alias, reassignment, return or argument use is admitted.
   self.strings.insert(n.clone(),borrowed_constant(e).unwrap());
  },
  Stmt::Local(_,n,e)=>{
   // Physical slots are unique per declaration and live in the entry block;
   // only initialization executes here (including inside repeated loops).
   let p=self.tmp();
   // Same frontend-only counter exception as the default backend, not NIL coercion.
   if matches!(e,Expr::Nil) && bare_local_is_for_counter(ss,si,n){
    self.allocas.push(format!("  {} = alloca i64\n",p));
    self.line(format!("store i64 0, ptr {}",p));self.vars.insert(n.clone(),p);
    continue
   }
   if let Expr::ArrLit(items)=e {
    if items.iter().any(|e|matches!(e,Expr::Log(_)|Expr::ArrLit(_)|Expr::DArrNew)){
     return Err("LLVM scalar: tagged logical/mixed or nested array literals unsupported".into())
    }
    let k=items.len();self.allocas.push(format!("  {} = alloca [{} x i64]\n",p,k));
    // Initializers cannot refer to their own undeclared binding (frontend).
    for (i,item) in items.iter().enumerate(){
     let v=self.expr(item)?;let q=self.tmp();
     self.line(format!("{} = getelementptr [{} x i64], ptr {}, i64 0, i64 {}",q,k,p,i));
     self.line(format!("store i64 {}, ptr {}",v,q));
    }
    self.arrays.insert(n.clone(),p);self.asz.insert(n.clone(),k);
   } else {
    let logical=self.isbool(e);let v=self.expr(e)?;
    self.allocas.push(format!("  {} = alloca i64\n",p));
    self.line(format!("store i64 {}, ptr {}",v,p));self.vars.insert(n.clone(),p);
    if logical{self.bools.insert(n.clone());}
   }
  },
  Stmt::Assign(_,n,Expr::ArrLit(items)) if self.arrays.contains_key(n)=>{
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
  Stmt::Assign(_,n,e)=>{if self.strings.contains_key(n){return Err("LLVM scalar: borrowed constant string reassignment unsupported".into())}if self.arrays.contains_key(n){return Err(format!("LLVM scalar: whole-array assignment `{}` unsupported",n))}if self.isbool(e){self.bools.insert(n.clone());}let v=self.expr(e)?;let p=self.ptr(n)?;self.line(format!("store i64 {}, ptr {}",v,p));},
  Stmt::Ret(_,e)=>{if self.void_return{if e.is_some(){return Err("LLVM scalar: value return in NIL-only effect function".into())}self.unlink();self.line("ret void".into());}else{let v=if let Some(e)=e{self.expr(e)?}else{"0".into()};self.unlink();self.line(format!("ret i64 {}",v));}self.check_dead(&ss[si+1..])?;return Ok(true)},
  Stmt::Print(_,es,inline)=>{self.print_items(es,*inline,false)?;},
  Stmt::If(_,c,a,b)=>{let c=self.cond(c)?;let t=self.lab();let f=self.lab();let end=self.lab();self.line(format!("br i1 {}, label %{}, label %{}",c,t,f));self.block(&t);let ta=self.stmts(a)?;if !ta{self.line(format!("br label %{}",end));}self.block(&f);let tb=self.stmts(b)?;if !tb{self.line(format!("br label %{}",end));}if ta&&tb{self.check_dead(&ss[si+1..])?;return Ok(true)}self.block(&end);},
  Stmt::While(_,c,b)=>{let h=self.lab();let body=self.lab();let end=self.lab();self.line(format!("br label %{}",h));self.block(&h);self.trace_at(stmt_line(s));let c=self.cond(c)?;self.line(format!("br i1 {}, label %{}, label %{}",c,body,end));self.block(&body);self.loops.push((h.clone(),end.clone()));let done=self.stmts(b)?;self.loops.pop();if !done{self.line(format!("br label %{}",h));}self.block(&end);},
  Stmt::For(_,n,a,b,step,ss)=>{let outer_vars=self.vars.clone();let a=self.expr(a)?;let p=if let Some(p)=self.vars.get(n){p.clone()}else{let p=self.tmp();self.allocas.push(format!("  {} = alloca i64\n",p));self.vars.insert(n.clone(),p.clone());p};self.line(format!("store i64 {}, ptr {}",a,p));let b=self.expr(b)?;let h=self.lab();let body=self.lab();let inc=self.lab();let store=self.lab();let end=self.lab();self.line(format!("br label %{}",h));self.block(&h);let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));let c=self.tmp();self.line(format!("{} = icmp {} i64 {}, {}",c,if *step>0{"sle"}else{"sge"},v,b));self.line(format!("br i1 {}, label %{}, label %{}",c,body,end));self.block(&body);self.loops.push((inc.clone(),end.clone()));let done=self.stmts(ss)?;self.loops.pop();if !done{self.line(format!("br label %{}",inc));}self.block(&inc);let v=self.tmp();self.line(format!("{} = load i64, ptr {}",v,p));let pair=self.tmp();self.line(format!("{} = call {{i64,i1}} @llvm.sadd.with.overflow.i64(i64 {}, i64 {})",pair,v,step));let next=self.tmp();let ov=self.tmp();self.line(format!("{} = extractvalue {{i64,i1}} {}, 0",next,pair));self.line(format!("{} = extractvalue {{i64,i1}} {}, 1",ov,pair));self.line(format!("br i1 {}, label %{}, label %{}",ov,end,store));self.block(&store);self.line(format!("store i64 {}, ptr {}",next,p));self.line(format!("br label %{}",h));self.block(&end);self.vars=outer_vars;},
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
  Stmt::CallStmt(_,e)=>{self.effect(e)?;},
  _=>return Err(format!("LLVM scalar: statement unsupported: {:?}",s))
 }}Ok(false)}
}
pub fn emit(funcs:&[Func],sigs:&[Sig],target:Target,traced:bool)->Result<String,String>{
 let voids:std::collections::BTreeSet<String>=funcs.iter().filter(|f|f.name!="main"&&sigs.iter().any(|s|s.name==f.name&&s.ret==Some(Ty::Dyn))&&nil_only_body(&f.stmts)==Some(true)).map(|f|f.name.clone()).collect();
 for f in funcs{check_effect_uses(&f.stmts,&voids)?;}
 for s in sigs{if !s.params.iter().all(|t|matches!(t,Ty::I64|Ty::Bool)) || (!matches!(s.ret,None|Some(Ty::I64)|Some(Ty::Bool))&&!voids.contains(&s.name)){return Err("LLVM scalar: only I64/logical scalar signatures supported".into())}}
 let mut ir=Ir{trace_texts:Default::default(),strings:Default::default(),windows:matches!(target,Target::Windows),voids,void_return:false,out:String::new(),n:0,label:0,vars:Default::default(),arrays:Default::default(),asz:Default::default(),globals:Vec::new(),allocas:Vec::new(),sig_names:funcs.iter().map(|f|f.name.clone()).collect(),bool_returns:sigs.iter().filter(|s|matches!(s.ret,Some(Ty::Bool))).map(|s|s.name.clone()).collect(),bools:Default::default(),traced,frame:String::new(),fname:String::new(),current_line:0,loops:Vec::new()};
 for f in funcs{ir.strings.clear();ir.vars.clear();ir.arrays.clear();ir.asz.clear();ir.bools.clear();ir.allocas.clear();ir.fname=f.name.clone();ir.void_return=ir.voids.contains(&f.name);let begin=ir.out.len();ir.out.push_str(&format!("define {} @ll_{}({}) {{\nentry:\n",if ir.void_return{"void"}else{"i64"},f.name,f.params.iter().enumerate().map(|(i,_)|format!("i64 %arg{}",i)).collect::<Vec<_>>().join(", ")));if traced {ir.frame=ir.tmp();ir.line(format!("{} = alloca [3 x i64]",ir.frame));let old=ir.tmp();ir.line(format!("{} = load ptr, ptr @hbc_trace_top",old));ir.line(format!("store ptr {}, ptr {}",old,ir.frame));let text=ir.tmp();let len=ir.tmp();ir.line(format!("{} = getelementptr [3 x i64], ptr {}, i64 0, i64 1",text,ir.frame));ir.line(format!("{} = getelementptr [3 x i64], ptr {}, i64 0, i64 2",len,ir.frame));ir.line(format!("store ptr null, ptr {}",text));ir.line(format!("store i64 0, ptr {}",len));ir.line(format!("store volatile ptr {}, ptr @hbc_trace_top",ir.frame));}ir.trace_at(f.stmts.first().map(stmt_line).unwrap_or(0));for n in &f.params{let p=ir.tmp();ir.line(format!("{} = alloca i64",p));ir.vars.insert(n.clone(),p);}for(i,p)in f.params.iter().enumerate(){if matches!(sigs.iter().find(|s|s.name==f.name).unwrap().params[i],Ty::Bool){ir.bools.insert(p.clone());}let ptr=ir.ptr(p)?;ir.line(format!("store i64 %arg{}, ptr {}",i,ptr));}if !ir.stmts(&f.stmts)?{ir.unlink();ir.line(if ir.void_return{"ret void".into()}else{"ret i64 0".into()});}let idx=begin+ir.out[begin..].find("entry:\n").unwrap()+7;ir.out.insert_str(idx,&ir.allocas.concat());ir.out.push_str("}\n");}
 // The experimental AOT linker includes the trace global in this executable; no DSO runtime.
 Ok(format!("{}\n{}\n@hbc_trace_top = external dso_local global ptr\ndeclare void @rt_inc_error() noreturn\ndeclare void @rt_bound_error() noreturn\ndeclare void @rt_nl()\ndeclare void @rt_sep()\ndeclare void @rt_str(ptr, i64)\ndeclare void @rt_int(i64)\ndeclare void @rt_computed(i64)\ndeclare {{i64,i1}} @llvm.sadd.with.overflow.i64(i64,i64)\n",ir.globals.join("\n"),ir.out))
}
