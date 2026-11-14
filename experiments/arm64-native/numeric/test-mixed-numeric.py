"""Mixed finite numeric payload kernels; no formatting or AST admission."""
import sys,struct,random,json,math,hashlib
from pathlib import Path

from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM
from unicorn.arm64_const import *
r=Path(__file__).resolve().parent;rng=random.Random(574339)
def bits(f):return struct.unpack('<Q',struct.pack('<d',f))[0]
def f64(b):return struct.unpack('<d',struct.pack('<Q',b))[0]
ints=[-2**63,-2**53-1,-1,0,1,2**53+1,2**63-1]
floats=[-0.,0.,1.,-1.,1.5,-1.5,2**-1074,-2**-1074,2**-1022,-2**-1022,1.7976931348623157e308,-1.7976931348623157e308,float(2**53),float(2**63)]
values=[(i&((1<<64)-1),0)for i in ints]+[(bits(f),1)for f in floats]
cases=[(a,b)for a in values for b in values]
for _ in range(5000):
 pair=[]
 for _ in range(2):
  tag=rng.randrange(2)
  if tag:
   while True:
    n=rng.getrandbits(64)
    if math.isfinite(f64(n)):break
  else:n=rng.getrandbits(64)
  pair.append((n,tag))
 cases.append(tuple(pair))
def val(n,k):return f64(n)if k else n-(1<<64)if n>>63 else n
records=[]
for op,name in [('+','add'),('-','sub'),('*','mul'),('/','div')]:
 code=(r/('mixed-'+name+'.bin')).read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(0x10000,0x1000);u.mem_write(0x10000,code);u.mem_map(0x20000,0x1000);u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
 counts=[0,0,0,0]
 for (pa,ka),(pb,kb) in cases:
  a=val(pa,ka);b=val(pb,kb)
  u.reg_write(UC_ARM64_REG_X0,pa);u.reg_write(UC_ARM64_REG_X1,pb);u.reg_write(UC_ARM64_REG_X2,ka);u.reg_write(UC_ARM64_REG_X3,kb);u.reg_write(UC_ARM64_REG_LR,0x20000)
  u.reg_write(UC_ARM64_REG_FPCR,0);u.reg_write(UC_ARM64_REG_FPSR,0)
  u.emu_start(0x10000,0x20000,count=100)
  assert u.reg_read(UC_ARM64_REG_PC)==0x20000
  if op=='/'and b==0:expected=(0,2)
  else:
   exact={'+':lambda:a+b,'-':lambda:a-b,'*':lambda:a*b,'/':lambda:None}[op]()
   if ka==kb==0 and exact is not None and -2**63<=exact<2**63:expected=(exact&((1<<64)-1),0)
   else:
    x=float(a);y=float(b);f={'+':lambda:x+y,'-':lambda:x-y,'*':lambda:x*y,'/':lambda:x/y}[op]()
    expected=(bits(f),1)
  got=(u.reg_read(UC_ARM64_REG_X0),u.reg_read(UC_ARM64_REG_X1));assert got==expected,(op,a,b,ka,kb,got,expected)
  counts[got[1]]+=1
 for ka,kb in [(2,0),(0,2),(3,3),(2**64-1,1),(1,2**64-1)]:
  u.reg_write(UC_ARM64_REG_X2,ka);u.reg_write(UC_ARM64_REG_X3,kb);u.reg_write(UC_ARM64_REG_LR,0x20000);u.emu_start(0x10000,0x20000,count=100)
  assert u.reg_read(UC_ARM64_REG_X1)==3
 records.append({'operation':op,'vectors':len(cases),'kinds':counts,'invalid_kind_controls':5,'sha256':hashlib.sha256(code).hexdigest()})
(r/'mixed-numeric-results.json').write_text(json.dumps({'total':len(cases)*4,'scope':'finite input values, binary64 overflow and subnormal/signed-zero controls; FPCR=0. No NaN payload semantics, no formatted-language ABI or AST admission','cases':records},indent=2)+'\n')
print(len(cases)*4,'mixed finite numeric kernels bit-exact, plus20 invalid-tag controls')
