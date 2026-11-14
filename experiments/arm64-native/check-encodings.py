"""Independent LLVM reference for each new encoder operation; dev-only."""
from pathlib import Path
import subprocess,struct,json
r=Path(__file__).resolve().parent
cases=[('c.mov(0,0xffff123456789abc)', ['movz x0,#0x9abc','movk x0,#0x5678,lsl #16','movk x0,#0x1234,lsl #32','movk x0,#0xffff,lsl #48']),('c.copy(0,2)',['mov x0,x2']),('c.imm(31,0,4,true,true)',['cmp x0,#4']),('c.addsub(31,9,0,true,true)',['cmp x9,x0']),('c.addsub(9,31,9,true,false)',['neg x9,x9']),('c.byte(14,11,0,false)',['strb w14,[x11]']),('c.byte(14,11,3,true)',['ldrb w14,[x11,#3]']),('c.udiv(13,9,12)',['udiv x13,x9,x12']),('c.msub(14,13,12,9)',['msub x14,x13,x12,x9']),('c.cset(0,11)',['cset x0,lt']),('c.cset(0,1)',['cset x0,ne']),('c.prologue(96)',['stp x29,x30,[sp,#-16]!','mov x29,sp','sub sp,sp,#96']),('c.epilogue()',['mov sp,x29','ldp x29,x30,[sp],#16','ret'])]
rs='#[path="arm64-code.rs"]mod code;fn main(){let mut c=code::Code::default();'
for expr,_ in cases:rs+=expr+'.unwrap();'
rs+='let(b,_)=c.finish().unwrap();std::fs::write("new-encodings.bin",b).unwrap();}'
(r/'new-encodings.rs').write_text(rs)
asm=[ins for _,insns in cases for ins in insns]
ll='target triple = "arm64-apple-macosx11.0.0"\nmodule asm ".section __TEXT,__text,regular,pure_instructions"\n'+''.join('module asm "'+i+'"\n'for i in asm)
(r/'new-encodings.ll').write_text(ll)
subprocess.run([__import__('os').environ.get('RUSTC','rustc'),'--edition=2021','-O','-C','strip=symbols','new-encodings.rs','-o','new-encodings'],cwd=r,check=True,capture_output=True)
subprocess.run([str(r/'new-encodings')],cwd=r,check=True)
subprocess.run(['python3',str(r/'make_reference.py'),str(r/'new-encodings.ll'),'new-encodings-ref'],check=True)
b=(r/'new-encodings-ref.o').read_bytes();o=32;ref=None
for _ in range(struct.unpack_from('<I',b,16)[0]):
 cmd,n=struct.unpack_from('<II',b,o)
 if cmd==25:
  ns=struct.unpack_from('<I',b,o+64)[0]
  for i in range(ns):
   p=o+72+80*i
   if b[p:p+16].split(b'\0')[0]==b'__text':
    size,off=struct.unpack_from('<QI',b,p+40);ref=b[off:off+size]
 o+=n
assert ref is not None
ours=(r/'new-encodings.bin').read_bytes();assert ours==ref
(r/'new-encodings-results.json').write_text(json.dumps({'instructions':len(asm),'llvm_byte_exact':True,'mnemonics':asm},indent=2)+'\n')
print(len(asm),'new encoder instructions LLVM byte-exact')

subprocess.run(['python3',str(r/'make_reference.py'),str(r/'encoder-reference.ll'),'original-encodings-ref'],check=True)
b=(r/'original-encodings-ref.o').read_bytes();o=32;ref=None
for _ in range(struct.unpack_from('<I',b,16)[0]):
 cmd,n=struct.unpack_from('<II',b,o)
 if cmd==25:
  for i in range(struct.unpack_from('<I',b,o+64)[0]):
   p=o+72+80*i
   if b[p:p+16].split(b'\0')[0]==b'__text':
    size,off=struct.unpack_from('<QI',b,p+40);ref=b[off:off+size]
 o+=n
assert ref==(r/'own-instructions.bin').read_bytes()
print(18,'original encoder instructions LLVM byte-exact')
