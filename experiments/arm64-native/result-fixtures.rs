#[path="arm64-code.rs"] mod code;
#[path="arm64-runtime.rs"] mod runtime;
#[path="arm64-trace.rs"] mod trace;
#[path="arm64-writer.rs"] mod writer;
#[path="numeric-result.rs"] mod result;
#[path="pair-print.rs"] mod pair_print;
#[path="numeric/decimal-mixed.rs"] mod mixedformat;
#[path="numeric/decimal-compose.rs"] mod compose;
#[path="numeric/decimal-image.rs"] mod decimal;
#[path="numeric/numeric-values.rs"] mod values;
#[path="numeric/numeric-kernel.rs"] mod numeric;
#[path="numeric/numeric-metadata.rs"] mod metadata;
use code::Code;
fn main(){
 let args:Vec<String>=std::env::args().collect();let root=std::path::Path::new(&args[1]);
 for line in std::fs::read_to_string(root.join("cases.tsv")).unwrap().lines(){
  let p:Vec<&str>=line.split('\t').collect();let name=p[0];let op=p[1].chars().next().unwrap();
  let nums:Vec<u64>=p[2..].iter().map(|x|x.parse().unwrap()).collect();
  let mut c=Code::default();c.prologue(96).unwrap();
  c.ldst(19,31,0,false).unwrap();c.mov(19,0).unwrap();
  c.fp_env(9,false,false).unwrap();c.fp_env(10,true,false).unwrap();
  c.ldst(9,31,8,false).unwrap();c.ldst(10,31,16,false).unwrap();
  c.mov(9,0).unwrap();c.fp_env(9,false,true).unwrap();c.fp_env(9,true,true).unwrap();c.isb();
  trace::link(&mut c,24).unwrap();
  trace::location(&mut c,"result_origin",&format!("  at main ({}:{})\n",root.join(format!("{name}.prg")).display(),if nums[5]==1{8}else{4})).unwrap();
  for (reg,v)in nums[..4].iter().enumerate(){c.mov(reg as u8,*v).unwrap();}
  if op!='r'{c.b("arithmetic",true);}else{c.mov(2,nums[4]).unwrap();}
  c.mov(3,nums[5]).unwrap();c.b("result_validate",true);
  for (reg,off)in[(0,32),(1,40),(2,48),(3,56)]{c.ldst(reg,31,off,false).unwrap();}
  c.data("newline",b"\n").unwrap();c.adr(0,"newline").unwrap();c.mov(1,1).unwrap();c.b("rt_write",true);
  for (reg,off)in[(0,32),(1,40),(2,48),(3,56)]{c.ldst(reg,31,off,true).unwrap();}
  c.b("result_print",true);trace::unlink(&mut c).unwrap();c.ldst(19,31,0,true).unwrap();
  c.ldst(9,31,8,true).unwrap();c.ldst(10,31,16,true).unwrap();c.fp_env(9,false,true).unwrap();c.fp_env(10,true,true).unwrap();c.isb();
  c.mov(0,0).unwrap();c.epilogue().unwrap();
  runtime::emit(&mut c).unwrap();trace::emit(&mut c).unwrap();result::emit(&mut c).unwrap();pair_print::emit(&mut c).unwrap();
  if op!='r'{c.label("arithmetic").unwrap();values::emit(&mut c,op).unwrap();}
  let(b,d)=c.finish().unwrap();let image=writer::from_code(&b,&d,0,"arm64-result-contract").unwrap();std::fs::write(root.join(format!("{name}.arm")),image).unwrap();
 }
}
