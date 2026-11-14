"""Own kernels on an independent ARM64 emulator, not a language/Mac run."""
import sys,struct,random,json,hashlib
from pathlib import Path

from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM,UC_HOOK_CODE
from unicorn.arm64_const import *
from capstone import Cs,CS_ARCH_ARM64,CS_MODE_ARM
r=Path(__file__).resolve().parent;rng=random.Random(6532634)
edge=[-2**63,-2**63+1,-2**63+2,-2**62,-2**53-1,-2**53,-2**32,-1,0,1,2,2**31-1,2**32,2**53-1,2**53,2**53+1,2**62,2**63-2,2**63-1]
pairs=[(a,b)for a in edge for b in edge]
pairs.extend((rng.randrange(-2**63,2**63),rng.randrange(-2**63,2**63))for _ in range(5000))
# Distinguish conversion-before-op from converting exact big-int result.
for _ in range(1000):
 a=rng.randrange(2**62,2**63);pairs.extend([(a,a),(-a,a),(a,-a),(-a,-a),(a,1),(a,2),(a,-2)])
mask=2**64-1;end=0x20000;start=0x10000
cs=Cs(CS_ARCH_ARM64,CS_MODE_ARM);records=[]
for op,name in [('+','add'),('-','sub'),('*','mul'),('/','div')]:
 code=(r/('kernel-'+name+'.bin')).read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(start,0x1000);u.mem_write(start,code);u.mem_map(end,0x1000)
 u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
 decoded=list(cs.disasm(code,start));assert len(decoded)*4==len(code)
 assert all('x18'not in i.op_str and 'w18'not in i.op_str for i in decoded)
 counts={'integer':0,'double':0,'zero_divisor':0}
 for a,b in pairs:
  u.reg_write(UC_ARM64_REG_X0,a&mask);u.reg_write(UC_ARM64_REG_X1,b&mask);u.reg_write(UC_ARM64_REG_LR,end);u.reg_write(UC_ARM64_REG_X18,0x123456789abc)
  for n in range(19,30):u.reg_write(globals()['UC_ARM64_REG_X'+str(n)],0x5000+n)
  # Numerical ABI requires round-to-nearest, no flush-to-zero or exceptions.
  u.reg_write(UC_ARM64_REG_FPCR,0);u.reg_write(UC_ARM64_REG_FPSR,0)
  u.emu_start(start,end,count=100)
  assert u.reg_read(UC_ARM64_REG_PC)==end
  got=u.reg_read(UC_ARM64_REG_X0);tag=u.reg_read(UC_ARM64_REG_X1)
  assert u.reg_read(UC_ARM64_REG_X18)==0x123456789abc
  assert all(u.reg_read(globals()['UC_ARM64_REG_X'+str(n)])==0x5000+n for n in range(19,30))
  if op=='/'and b==0:want=0;kind=2
  else:
   exact={'+':lambda:a+b,'-':lambda:a-b,'*':lambda:a*b,'/':lambda:None}[op]()
   if exact is not None and -2**63<=exact<2**63:want=exact&mask;kind=0
   else:
    x=float(a);y=float(b)
    f={'+':lambda:x+y,'-':lambda:x-y,'*':lambda:x*y,'/':lambda:x/y}[op]()
    want=struct.unpack('<Q',struct.pack('<d',f))[0];kind=1
  assert (got,tag)==(want,kind),(op,a,b,hex(got),tag,hex(want),kind)
  counts[['integer','double','zero_divisor'][kind]]+=1
 records.append({'operation':op,'vectors':len(pairs),'results':counts,'sha256':hashlib.sha256(code).hexdigest(),'decoded':[i.mnemonic+' '+i.op_str for i in decoded]})
(r/'numeric-results.json').write_text(json.dumps({'scope':'isolated i64-input kernels under Unicorn, no AST admission or formatting/error language runtime','pairs_per_operation':len(pairs),'total':len(pairs)*4,'integer_semantics':'Python exact integer; overflowing inputs converted independently to float before operation, not exact-result conversion','cases':records},indent=2)+'\n')
print(len(pairs)*4,'numeric kernel vectors bit-exact under independent instruction emulation')
