"""Own MIT Intel instruction harness, not native macOS execution."""
from pathlib import Path
import struct,sys
from unicorn import Uc,UC_ARCH_X86,UC_MODE_64,UC_HOOK_INSN
from unicorn.x86_const import *
p=Path(sys.argv[1]);b=p.read_bytes();u=Uc(UC_ARCH_X86,UC_MODE_64);ncmd=struct.unpack_from('<I',b,16)[0];pos=32;segments=[];entry=None
for j in range(ncmd):
 cmd,size=struct.unpack_from('<II',b,pos)
 if cmd==0x19:
  name,addr,mem,off,sz=struct.unpack_from('<16sQQQQ',b,pos+8)
  if mem and name.rstrip(b'\0')!=b'__PAGEZERO':
   u.mem_map(addr,(mem+4095)&~4095);u.mem_write(addr,b[off:off+sz]);segments.append((name.decode().rstrip('\0'),addr,off))
 if cmd==0x80000028:entry=struct.unpack_from('<Q',b,pos+8)[0]
 pos+=size
base=next(a-o for n,a,o in segments if n=='__TEXT');start=base+entry;stack=0x700000000;u.mem_map(stack,0x100000);u.reg_write(UC_X86_REG_RSP,stack+0x80008);out=bytearray();err=bytearray();code=None;writes=0

def hook(uc,data):
 global code,writes
 call=uc.reg_read(UC_X86_REG_RAX)
 if call==0x2000004:
  fd,ptr,count=[uc.reg_read(r) for r in [UC_X86_REG_RDI,UC_X86_REG_RSI,UC_X86_REG_RDX]]
  assert count<2**24,count
  writes+=1
  if '--eintr-once' in sys.argv and writes==1:
   uc.reg_write(UC_X86_REG_RAX,4);uc.reg_write(UC_X86_REG_EFLAGS,uc.reg_read(UC_X86_REG_EFLAGS)|1);return
  if '--short-writes' in sys.argv:count=min(count,2)
  (out if fd==1 else err).extend(uc.mem_read(ptr,count));uc.reg_write(UC_X86_REG_RAX,count);uc.reg_write(UC_X86_REG_EFLAGS,uc.reg_read(UC_X86_REG_EFLAGS)&~1)
 elif call==0x2000001:code=uc.reg_read(UC_X86_REG_RDI);uc.emu_stop()
 else:raise RuntimeError(('unsupported syscall',call))
 # Hardware SYSCALL destroys rcx/r11. Deterministic poison catches reliance.
 uc.reg_write(UC_X86_REG_RCX,0xBADCA11);uc.reg_write(UC_X86_REG_R11,0xBADCA12)
u.hook_add(UC_HOOK_INSN,hook,None,1,0,UC_X86_INS_SYSCALL);u.emu_start(start,0,count=10000000);assert code is not None,'instruction limit without exit'
p.with_suffix('.stdout').write_bytes(out);p.with_suffix('.stderr').write_bytes(err);p.with_suffix('.rc').write_text(str(code));print(dict(rc=code,stdout=bytes(out),stderr=bytes(err)))
