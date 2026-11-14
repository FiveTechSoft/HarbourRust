"""LLVM is a development oracle only, never part of output generation."""
from pathlib import Path
import subprocess,sys,struct,os
r=Path(__file__).resolve().parent
subprocess.run([sys.executable,str(r.parent/'make_reference.py'),str(r/'numeric-reference.ll'),str(r/'numeric-ref')],check=True)
b=(r/'numeric-ref.o').read_bytes();o=32;ref=None
for _ in range(struct.unpack_from('<I',b,16)[0]):
 cmd,n=struct.unpack_from('<II',b,o)
 if cmd==25:
  for i in range(struct.unpack_from('<I',b,o+64)[0]):
   p=o+72+80*i
   if b[p:p+16].split(b'\0')[0]==b'__text':
    size,off=struct.unpack_from('<QI',b,p+40);ref=b[off:off+size]
 o+=n
ours=(r/'numeric-encodings.bin').read_bytes();assert ref==ours
print(len(ours)//4,'numeric encoding words LLVM byte-exact')
