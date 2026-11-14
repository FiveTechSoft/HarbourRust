"""ARM64 decimal-image normalization, not formatted language output."""
import sys,struct,random,json,math
from pathlib import Path

from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM
from unicorn.arm64_const import *
r=Path(__file__).resolve().parent;rng=random.Random(53643)
code=(r/'decimal-image.bin').read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(0x10000,0x1000);u.mem_write(0x10000,code);u.mem_map(0x20000,0x1000);u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
def bits(x):return struct.unpack('<Q',struct.pack('<d',x))[0]
values=[0,2**63,0x7ff0000000000000,0xfff0000000000000,0x7ff0000000000001,0x7ff8000000000000,1,2**63+1,0x0010000000000000,0x7fefffffffffffff]
for e in range(-323,309):
 x=10.0**e
 for sign in [1.,-1.]:
  for v in [math.nextafter(x,0.),x,math.nextafter(x,math.inf)]:values.append(bits(sign*v))
values.extend(rng.getrandbits(64)for _ in range(4000))
for payload in values:
 v=struct.unpack('<d',struct.pack('<Q',payload))[0];a=abs(v);exponent=0;sign=payload>>63
 if not math.isfinite(v):want=(0,0,sign,1)
 elif a==0:want=(0,0,0,0)
 else:
  while a>=10.:a/=10.;exponent+=1
  while a<1.:a*=10.;exponent-=1
  n=int(a*1e15+0.5)
  if n==10**16:n=10**15;exponent+=1
  want=(n,exponent&((1<<64)-1),sign,0)
 u.reg_write(UC_ARM64_REG_X0,payload);u.reg_write(UC_ARM64_REG_LR,0x20000);u.reg_write(UC_ARM64_REG_FPCR,0)
 u.emu_start(0x10000,0x20000,count=10000)
 assert u.reg_read(UC_ARM64_REG_PC)==0x20000
 got=tuple(u.reg_read(UC_ARM64_REG_X0+i)for i in range(4));assert got==want,(hex(payload),v,got,want)
(r/'decimal-image-results.json').write_text(json.dumps({'cases':len(values),'exact':True,'scope':'own emitted ARM64 normalized digit-image kernel versus explicit host model, not completed formatter or Harbour oracle'},indent=2)+'\n')
print(len(values),'ARM64 normalized image controls exact')
