from pathlib import Path
import sys,struct,random,json,math,subprocess

from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM
from unicorn.arm64_const import *
r=Path(__file__).resolve().parent;rng=random.Random(36446)
base=[0.,-0.,0.125,0.665,9.995,0.0999,1.5,2.25,1e-17,1e-18,1e19,1e20,9007199254740992.,9007199254740994.,float(-2**63),float(2**63),float('inf'),float('-inf'),float('nan'),5e-324,-5e-324,1.7976931348623157e308]
cases=[(v,l,d,0)for v in base for l in [10,20]for d in [0,1,2,6,17,255,435]]
for _ in range(5000):cases.append((rng.uniform(-1.,1.)*10**rng.randrange(-17,21),rng.choice([10,20]),rng.choice([0,1,2,3,9,17,35]),0))
cases=[c for c in cases if not(math.isfinite(c[0])and abs(c[0])>=1e19 and c[2]==435)and not(math.isfinite(c[0])and abs(c[0])>=1e200 and c[2]>=255)]
p=subprocess.run([str(r/'decimal-model')],input=b''.join(struct.pack('<dIIB',*c)for c in cases),capture_output=True);assert p.returncode==0,p.stderr
ref=p.stdout;off=0
code=(r/'decimal-compose.bin').read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(0x10000,0x4000);u.mem_write(0x10000,code);u.mem_map(0x20000,0x4000);u.mem_map(0x30000,0x4000);u.mem_map(0x40000,0x4000);u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
for i,(v,l,d,_) in enumerate(cases):
 n=struct.unpack_from('<I',ref,off)[0];off+=4;want=ref[off:off+n];off+=n
 payload=struct.unpack('<Q',struct.pack('<d',v))[0]
 for reg,val in [(UC_ARM64_REG_X0,payload),(UC_ARM64_REG_X1,l),(UC_ARM64_REG_X2,d),(UC_ARM64_REG_X3,0x30000),(UC_ARM64_REG_LR,0x20000),(UC_ARM64_REG_SP,0x44000-16),(UC_ARM64_REG_FP,0x123456),(UC_ARM64_REG_FPCR,0)]:u.reg_write(reg,val)
 u.mem_write(0x30000,b'\xa5'*512);u.emu_start(0x10000,0x20000,count=50000)
 assert u.reg_read(UC_ARM64_REG_PC)==0x20000,(i,'loop')
 assert u.reg_read(UC_ARM64_REG_X1)==0,(i,v,l,d,'status')
 got=bytes(u.mem_read(0x30000,u.reg_read(UC_ARM64_REG_X0)))
 assert got==want,(i,v,l,d,got,want)
 assert u.reg_read(UC_ARM64_REG_FP)==0x123456 and u.reg_read(UC_ARM64_REG_SP)==0x44000-16
 assert bytes(u.mem_read(0x30000+len(got),512-len(got)))==b'\xa5'*(512-len(got))
# Named rejection controls, not part of the positive count.
negative=[(1.,11,2),(1.,10,436),(1.,20,2**64-1),(1e308,20,435),(-1e308,20,435)]
for v,l,d in negative:
 for reg,val in [(UC_ARM64_REG_X0,struct.unpack('<Q',struct.pack('<d',v))[0]),(UC_ARM64_REG_X1,l),(UC_ARM64_REG_X2,d),(UC_ARM64_REG_X3,0x30000),(UC_ARM64_REG_LR,0x20000),(UC_ARM64_REG_SP,0x44000-16)]:u.reg_write(reg,val)
 u.mem_write(0x30000,b'\xa5'*512);u.emu_start(0x10000,0x20000,count=50000)
 assert u.reg_read(UC_ARM64_REG_X0)==0 and u.reg_read(UC_ARM64_REG_X1)==1
 assert bytes(u.mem_read(0x30000,512))==b'\xa5'*512
(r/'decimal-compose-results.json').write_text(json.dumps({'cases':len(cases),'exact':True,'negative_no_output':len(negative),'scope':'ARM64 ASCII composer vs own host model; no mixed-integral fast path, no AST admission or actual Mac execution'},indent=2)+'\n')
print(len(cases),'ARM64 ASCII compose controls exact')
