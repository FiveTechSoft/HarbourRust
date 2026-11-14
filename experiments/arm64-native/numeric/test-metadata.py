"""Metadata contract controls, not formatted output or language ABI proof."""
import sys,struct,random,json,math
from pathlib import Path

from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM
from unicorn.arm64_const import *
r=Path(__file__).resolve().parent;rng=random.Random(33273)
def bits(f):return struct.unpack('<Q',struct.pack('<d',f))[0]
thresholds=[9999999999.,-999999999.]
vs=[0.,-0.,1.,-1.,float('inf'),-float('inf'),float('nan'),5e-324,-5e-324,1e308,-1e308]
for f in thresholds:vs.extend([math.nextafter(f,-math.inf),f,math.nextafter(f,math.inf)])
raw=[bits(f)for f in vs]+[0x7ff0000000000001,0xfff0000000000001]
raw.extend(rng.getrandbits(64)for _ in range(1000))
decs=[0,1,2,17,255,434,435,436,65535,2**64-1]
records=[]
for op,name in [('+','add'),('-','sub'),('*','mul'),('/','div')]:
 code=(r/('metadata-'+name+'.bin')).read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(0x10000,0x1000);u.mem_write(0x10000,code);u.mem_map(0x20000,0x1000);u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
 n=0
 for payload in raw:
  f=struct.unpack('<d',struct.pack('<Q',payload))[0]
  for a,b in [(rng.choice(decs),rng.choice(decs))for _ in range(10)]+[(0,0),(435,0),(435,1),(1,435),(17,17)]:
   u.reg_write(UC_ARM64_REG_X0,payload);u.reg_write(UC_ARM64_REG_X1,a);u.reg_write(UC_ARM64_REG_X2,b);u.reg_write(UC_ARM64_REG_LR,0x20000);u.reg_write(UC_ARM64_REG_FPCR,0)
   u.emu_start(0x10000,0x20000,count=100)
   dec=max(a,b)if op in '+-'else a+b if op=='*'else 2
   bad=a>435 or b>435 or dec>435
   length=20 if f>9999999999. or f< -999999999. else 10
   expected=(payload,0,1)if bad else (payload,(length<<16)|dec,0)
   got=(u.reg_read(UC_ARM64_REG_X0),u.reg_read(UC_ARM64_REG_X1),u.reg_read(UC_ARM64_REG_X2));assert got==expected,(op,hex(payload),a,b,got,expected)
   n+=1
 records.append({'operation':op,'vectors':n})
(r/'metadata-results.json').write_text(json.dumps({'scope':'format word only, no rendered number/error path/AST admission. NaN payload preserved, width10; no full NaN arithmetic claim','total':sum(c['vectors']for c in records),'cases':records},indent=2)+'\n')
print(sum(c['vectors']for c in records),'metadata field controls exact under independent ARM64 emulation')
