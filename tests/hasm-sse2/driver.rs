#[path="../../src/hasm.rs"] mod hasm;
#[path="../../src/hpe.rs"] mod hpe;
#[path="../../src/hmacho.rs"] mod hmacho;
fn main(){
 let a:Vec<String>=std::env::args().collect();
 let src=std::fs::read_to_string(&a[2]).unwrap();
 let result=match a[1].as_str(){
  "elf"=>hasm::assemble(&src),
  "pe"=>hasm::assemble_pe(&src),
  "macho"=>hasm::assemble(&src).and_then(|v|hmacho::from_elf(&v)),
  _=>panic!("unknown target")
 };
 match result{Ok(v)=>std::fs::write(&a[3],v).unwrap(),Err(e)=>{eprintln!("{}",e);std::process::exit(1);}}
}
