"""Isolated pair call/local/status/snapshot test, no source/runtime exception ABI."""
from pathlib import Path
import sys,struct,random,json,math
from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM,UC_HOOK_CODE
from unicorn.arm64_const import *
r=Path(__file__).resolve().parent;rng=random.Random(674653);mask=(1<<64)-1
def bits(v):return struct.unpack('<Q',struct.pack('<d',v))[0]
def number(p,f):return (p-(1<<64)if p>>63 else p)if f<=1 else struct.unpack('<d',struct.pack('<Q',p))[0]
def valid(f):return f<=1 or(f>>16 in[10,20]and(f&65535)<=435)
def calc(a,b,op):
 pa,fa=a;pb,fb=b
 if not valid(fa)or not valid(fb):return (0,0,2)
 x=number(*a);y=number(*b)
 if op=='/'and y==0:return(0,0,1)
 exact={'+':lambda:x+y,'-':lambda:x-y,'*':lambda:x*y,'/':lambda:None}[op]()
 if fa<=1 and fb<=1 and exact is not None and -2**63<=exact<2**63:return(exact&mask,0,0)
 da=0 if fa<=1 else fa&65535;db=0 if fb<=1 else fb&65535;dec=max(da,db)if op in'+-'else da+db if op=='*'else 2
 if dec>435:return(0,0,3)
 x=float(x);y=float(y);z={'+':lambda:x+y,'-':lambda:x-y,'*':lambda:x*y,'/':lambda:x/y}[op]()
 width=20 if z>9999999999. or z< -999999999. else 10
 return(bits(z),width<<16|dec,0)
vals=[(n&mask,f)for n in [-2**63,-2**53-1,-1,0,1,2,2**53+1,2**63-1]for f in [0,1]]
vals.extend((bits(v),(w<<16)|d)for v in[-1e100,-0.,0.,0.125,2.25,1e100]for w in[10,20]for d in[0,2,17,435])
vals.extend([(bits(1.),3),(bits(1.),10<<16|436)])
cases=[tuple(rng.choice(vals)for _ in range(3))for _ in range(1500)]
records=[]
for op,name in[('+','add'),('-','sub'),('*','mul'),('/','div')]:
 code=(r/('pair-'+name+'.bin')).read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(0x10000,0x4000);u.mem_write(0x10000,code);u.mem_map(0x20000,0x1000);u.mem_map(0x30000,0x4000);u.mem_map(0x40000,0x1000);u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
 def trace(uc,addr,size,_):
  if uc.reg_read(UC_ARM64_REG_SP)%16:raise AssertionError('unaligned stack')
  if uc.reg_read(UC_ARM64_REG_X18)!=0x1234456:raise AssertionError('x18 touched')
 u.hook_add(UC_HOOK_CODE,trace)
 statuses=[0]*4;first=second=0
 for args in cases:
  left=calc(args[0],args[1],op);want=left if left[2]else calc(left[:2],args[2],op)
  for i,(p,f)in enumerate(args):u.reg_write(UC_ARM64_REG_X0+i*2,p);u.reg_write(UC_ARM64_REG_X0+i*2+1,f)
  external=bool(len(statuses) and statuses[0]%2)
  # A two-frame incoming caller chain exercises bounded snapshot truncation.
  top=0x40200 if external else 0
  namep=0x40300
  u.mem_write(namep,b'caller')
  u.mem_write(0x40200,struct.pack('<4Q',0x40220,namep,6,90)+struct.pack('<4Q',0,namep,6,91))
  u.mem_write(0x40000,struct.pack('<4Q',top,99,99,99)+b'\0'*96+b'\xa5'*128)
  for reg,v in[(UC_ARM64_REG_X8,0x40000),(UC_ARM64_REG_SP,0x34000-16),(UC_ARM64_REG_FP,0x5678),(UC_ARM64_REG_LR,0x20000),(UC_ARM64_REG_X18,0x1234456),(UC_ARM64_REG_FPCR,3<<22|1<<24),(UC_ARM64_REG_FPSR,0x0800009f)]:u.reg_write(reg,v)
  for i in range(19,29):u.reg_write(globals()['UC_ARM64_REG_X'+str(i)],0x88800+i)
  u.emu_start(0x10000,0x20000,count=2000)
  assert u.reg_read(UC_ARM64_REG_PC)==0x20000
  got=tuple(u.reg_read(UC_ARM64_REG_X0+i)for i in range(3));assert got==want,(op,args,got,want)
  assert u.reg_read(UC_ARM64_REG_FPCR)==3<<22|1<<24 and u.reg_read(UC_ARM64_REG_FPSR)==0x0800009f
  assert u.reg_read(UC_ARM64_REG_FP)==0x5678 and u.reg_read(UC_ARM64_REG_SP)==0x34000-16
  assert all(u.reg_read(globals()['UC_ARM64_REG_X'+str(i)])==0x88800+i for i in range(19,29))
  ctx=bytes(u.mem_read(0x40000,256));top,error,count,truncated=struct.unpack_from('<4Q',ctx)
  assert top==(0x40200 if external else 0) and truncated==int(external and bool(want[2]))
  if want[2]:
   assert error==want[2] and count==(4 if external else 3)
   for i,(n,line)in enumerate([('leaf',30),('middle',20),('outer',10)]):
    p,length,ln=struct.unpack_from('<3Q',ctx,32+i*24);assert bytes(u.mem_read(p,length))==n.encode()and ln==line
   if left[2]:first+=1
   else:second+=1
   if external:
    p,length,ln=struct.unpack_from('<3Q',ctx,104);assert bytes(u.mem_read(p,length))==b'caller' and ln==90
  else:assert error==count==0
  assert ctx[128:]==b'\xa5'*128
  statuses[want[2]]+=1
 records.append({'op':op,'cases':len(cases),'status_counts':statuses,'first_leaf_error':first,'second_leaf_error':second})
# Pure-copy calls preserve integer provenance, negative zero and NaN payloads.
copyvals=vals+[(bits(float('inf')),10<<16),(bits(float('-inf')),20<<16),(0x7ff8000000001234,10<<16),(0xfff8000000005678,20<<16)]
u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(0x10000,0x1000);u.mem_write(0x10000,(r/'pair-copy.bin').read_bytes());u.mem_map(0x20000,0x1000);u.mem_map(0x30000,0x1000)
for p,f in copyvals:
 u.reg_write(UC_ARM64_REG_X0,p);u.reg_write(UC_ARM64_REG_X1,f);u.reg_write(UC_ARM64_REG_SP,0x30ff0);u.reg_write(UC_ARM64_REG_FP,0x5678);u.reg_write(UC_ARM64_REG_LR,0x20000)
 u.emu_start(0x10000,0x20000,count=200)
 assert u.reg_read(UC_ARM64_REG_PC)==0x20000 and u.reg_read(UC_ARM64_REG_X0)==p and u.reg_read(UC_ARM64_REG_X1)==f
 assert u.reg_read(UC_ARM64_REG_SP)==0x30ff0 and u.reg_read(UC_ARM64_REG_FP)==0x5678
print(len(copyvals),'copy pair controls bit-exact')
(r/'pair-abi-results.json').write_text(json.dumps({'total':len(cases)*4,'copy_controls':len(copyvals),'incoming_chain_and_truncation':True,'scope':'own emitted pair-ABI/local spill/native chain/status snapshot under emulator, no source AST or true language errors/TRY unwinding','cases':records},indent=2)+'\n')
print(len(cases)*4,'pair ABI+locals+status/trace snapshot controls exact')
