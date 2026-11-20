from pathlib import Path
import struct,sys,json,hashlib
from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM,UC_HOOK_INTR,UC_PROT_ALL
from unicorn.arm64_const import *
p=Path(sys.argv[1]);b=p.read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);ncmd=struct.unpack_from('<I',b,16)[0];pos=32;segments=[];entry=None
for j in range(ncmd):
 cmd,size=struct.unpack_from('<II',b,pos)
 if cmd==0x19:
  name,addr,mem,off,sz=struct.unpack_from('<16sQQQQ',b,pos+8)
  if mem and name.rstrip(b'\0')!=b'__PAGEZERO':
   u.mem_map(addr,(mem+4095)&~4095);u.mem_write(addr,b[off:off+sz]);segments.append((name.decode().rstrip('\0'),addr,off))
 if cmd==0x80000028:entry=struct.unpack_from('<Q',b,pos+8)[0]
 pos+=size
base=next(a-o for n,a,o in segments if n=='__TEXT');start=base+entry;stack=0x700000000;u.mem_map(stack,0x100000);u.reg_write(UC_ARM64_REG_SP,stack+0x80000);out=bytearray();err=bytearray();code=None;writes=0

def hook(uc,no,data):
 global code,writes
 assert no==2,no
 call=uc.reg_read(UC_ARM64_REG_X16)
 if call==4:
  fd,ptr,count=[uc.reg_read(r) for r in [UC_ARM64_REG_X0,UC_ARM64_REG_X1,UC_ARM64_REG_X2]]
  assert count<2**24,count
  writes+=1
  if '--eintr-once' in sys.argv and writes==1:
   uc.reg_write(UC_ARM64_REG_X0,4);uc.reg_write(UC_ARM64_REG_NZCV,uc.reg_read(UC_ARM64_REG_NZCV)|(1<<29));return
  if '--short-writes' in sys.argv:count=min(count,2)
  (out if fd==1 else err).extend(uc.mem_read(ptr,count));uc.reg_write(UC_ARM64_REG_X0,count);uc.reg_write(UC_ARM64_REG_NZCV,uc.reg_read(UC_ARM64_REG_NZCV)&~(1<<29))
 elif call==1:code=uc.reg_read(UC_ARM64_REG_X0);uc.emu_stop()
 else:raise RuntimeError(('unsupported syscall',call))
u.hook_add(UC_HOOK_INTR,hook);u.emu_start(start,0,count=10000000);assert code is not None,'instruction limit without exit'
p.with_suffix('.stdout').write_bytes(out);p.with_suffix('.stderr').write_bytes(err);p.with_suffix('.rc').write_text(str(code));print(dict(rc=code,stdout=bytes(out),stderr=bytes(err)))
