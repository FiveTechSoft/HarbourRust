"""Isolated value-format ABI glue, without AST admission or language exceptions."""
import sys,struct,random,json,math
from pathlib import Path

from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM
from unicorn.arm64_const import *
r=Path(__file__).resolve().parent;rng=random.Random(343374)
mask=(1<<64)-1
def bits(v):return struct.unpack('<Q',struct.pack('<d',v))[0]
def dbl(b):return struct.unpack('<d',struct.pack('<Q',b))[0]
values=[(n&mask,f)for n in [-2**63,-2**53-1,-1,0,1,2**53+1,2**63-1]for f in [0,1]]
values.extend((bits(n),(w<<16)|d)for n in [-1e100,-0.,0.,1.5,1e100]for w in [10,20]for d in [0,2,17,435])
values.extend([(bits(1.),3),(bits(1.),10<<16|436),(bits(1.),1<<63),(bits(1.),11<<16)])
cases=[(rng.choice(values),rng.choice(values))for _ in range(3000)]
cases.extend((a,b)for a in values[:14]for b in values[:14])
def valid(f):return f<=1 or ((f>>16)in [10,20] and (f&65535)<=435)
def val(p,f):return (p-(1<<64)if p>>63 else p)if f<=1 else dbl(p)
records=[]
for op,name in [('+','add'),('-','sub'),('*','mul'),('/','div')]:
 code=(r/('values-'+name+'.bin')).read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(0x10000,0x4000);u.mem_write(0x10000,code);u.mem_map(0x20000,0x1000);u.mem_map(0x30000,0x1000);u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
 counts=[0]*4
 for (pa,fa),(pb,fb)in cases:
  if not valid(fa)or not valid(fb):want=(0,0,2)
  else:
   a=val(pa,fa);b=val(pb,fb)
   if op=='/'and b==0:want=(0,0,1)
   else:
    exact={'+':lambda:a+b,'-':lambda:a-b,'*':lambda:a*b,'/':lambda:None}[op]()
    if fa<=1 and fb<=1 and exact is not None and -2**63<=exact<2**63:want=(exact&mask,0,0)
    else:
     da=0 if fa<=1 else fa&65535;db=0 if fb<=1 else fb&65535
     dec=max(da,db)if op in '+-'else da+db if op=='*'else 2
     if dec>435:want=(0,0,3)
     else:
      x=float(a);y=float(b);z={'+':lambda:x+y,'-':lambda:x-y,'*':lambda:x*y,'/':lambda:x/y}[op]()
      width=20 if z>9999999999. or z< -999999999. else 10;want=(bits(z),width<<16|dec,0)
  for reg,v in [(UC_ARM64_REG_X0,pa),(UC_ARM64_REG_X1,fa),(UC_ARM64_REG_X2,pb),(UC_ARM64_REG_X3,fb),(UC_ARM64_REG_SP,0x31000-16),(UC_ARM64_REG_FP,0x123456),(UC_ARM64_REG_LR,0x20000),(UC_ARM64_REG_X18,0xdeadbeef),(UC_ARM64_REG_FPCR,0)]:u.reg_write(reg,v)
  for i in range(19,29):u.reg_write(globals()['UC_ARM64_REG_X'+str(i)],0x777000+i)
  u.emu_start(0x10000,0x20000,count=1000)
  assert u.reg_read(UC_ARM64_REG_PC)==0x20000
  got=tuple(u.reg_read(UC_ARM64_REG_X0+i)for i in range(3));assert got==want,(op,pa,fa,pb,fb,got,want)
  assert u.reg_read(UC_ARM64_REG_SP)==0x31000-16 and u.reg_read(UC_ARM64_REG_FP)==0x123456 and u.reg_read(UC_ARM64_REG_X18)==0xdeadbeef
  assert all(u.reg_read(globals()['UC_ARM64_REG_X'+str(i)])==0x777000+i for i in range(19,29))
  counts[got[2]]+=1
 records.append({'op':op,'cases':len(cases),'status_counts':counts})
(r/'value-format-results.json').write_text(json.dumps({'total':len(cases)*4,'scope':'isolated ABI glue, raw error status only; no AST or throw/trace integration','cases':records},indent=2)+'\n')
print(len(cases)*4,'value-format ABI controls exact')
