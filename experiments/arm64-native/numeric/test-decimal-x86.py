"""Direct emitted ARM bytes vs existing x86 helper: not a Harbour/Mac run."""
import sys,runpy,struct,json
from pathlib import Path

from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM
from unicorn.arm64_const import *
r=Path(__file__).resolve().parent
d=runpy.run_path(str(r/'test-decimal-model.py'))
code=(r/'decimal-mixed.bin').read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(0x10000,0x4000);u.mem_write(0x10000,code);u.mem_map(0x20000,0x4000);u.mem_map(0x30000,0x4000);u.mem_map(0x40000,0x4000);u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
for case,want in zip(d['cases'],d['reference']):
 v,l,dec,m=case
 for reg,val in [(UC_ARM64_REG_X0,struct.unpack('<Q',struct.pack('<d',v))[0]),(UC_ARM64_REG_X1,l),(UC_ARM64_REG_X2,dec),(UC_ARM64_REG_X3,0x30000),(UC_ARM64_REG_X4,m),(UC_ARM64_REG_LR,0x20000),(UC_ARM64_REG_SP,0x44000-16),(UC_ARM64_REG_FP,0x123456),(UC_ARM64_REG_FPCR,0)]:u.reg_write(reg,val)
 u.reg_write(UC_ARM64_REG_X18,0x11123456789)
 for i in range(19,29):u.reg_write(globals()['UC_ARM64_REG_X'+str(i)],0x777000+i)
 u.mem_write(0x30000,b'\xa5'*512);u.emu_start(0x10000,0x20000,count=50000)
 assert u.reg_read(UC_ARM64_REG_PC)==0x20000 and u.reg_read(UC_ARM64_REG_X1)==0
 got=bytes(u.mem_read(0x30000,u.reg_read(UC_ARM64_REG_X0)));assert got==want,(case,got,want)
 assert u.reg_read(UC_ARM64_REG_X18)==0x11123456789
 assert all(u.reg_read(globals()['UC_ARM64_REG_X'+str(i)])==0x777000+i for i in range(19,29))
 assert u.reg_read(UC_ARM64_REG_FP)==0x123456 and u.reg_read(UC_ARM64_REG_SP)==0x44000-16
 assert bytes(u.mem_read(0x30000+len(got),512-len(got)))==b'\xa5'*(512-len(got))
(r/'decimal-x86-results.json').write_text(json.dumps({'cases':len(d['cases']),'exact':True,'scope':'ARM64 emitted ordinary/mixed formatter on independent emulator vs current x86 formatter executed natively. No new Harbour oracle or actual Mac/AST admission'},indent=2)+'\n')
print(len(d['cases']),'direct emitted ARM64 vs x86 formatter outputs exact')
