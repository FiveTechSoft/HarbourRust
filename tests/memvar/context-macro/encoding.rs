#[path="../../../src/hpe.rs"] mod hpe;
#[path="../../../src/hasm.rs"] mod hasm;
fn main(){let src=".text\n.globl _start\n_start:\nmov $0xffff, %eax\nmovswl %ax, %edi\nadd $1, %edi\nmov $60, %eax\nsyscall\n";let bytes=hasm::assemble(src).unwrap();assert!(bytes.windows(3).any(|w|w==[0x0f,0xbf,0xf8]));std::fs::write(std::env::args().nth(1).unwrap(),bytes).unwrap();}
