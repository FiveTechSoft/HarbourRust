"""Development emulator only: models SVC write, not macOS loader/security/kernel."""
import sys,struct,json
from pathlib import Path
# Optional development packages are imported normally from PYTHONPATH/venv.
from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM,UC_HOOK_INTR,UC_HOOK_CODE
from unicorn.arm64_const import *
def execute(path,short=None,interrupt=False,failure=False,fault=None,observer=None,fp_state=(0,0)):

 b=Path(path).read_bytes();u=Uc(UC_ARCH_ARM64,UC_MODE_ARM)
 base=0x100000000;page=0x4000;u.mem_map(base,(len(b)+page-1)&-page);u.mem_write(base,b)
 stack=0x200000000;u.mem_map(stack,0x100000);initialsp=stack+0x100000-16;u.reg_write(UC_ARM64_REG_SP,initialsp)
 initialfp=0x1234567812340000;u.reg_write(UC_ARM64_REG_FP,initialfp)
 end=0x300000000;u.mem_map(end,0x4000);u.reg_write(UC_ARM64_REG_LR,end)
 o=32;entry=None
 for _ in range(struct.unpack_from('<I',b,16)[0]):
  cmd,n=struct.unpack_from('<II',b,o)
  if cmd==0x80000028:entry=base+struct.unpack_from('<Q',b,o+8)[0]
  o+=n
 assert entry is not None
 output=bytearray();calls=[];count=0;alignment_errors=[];reserved=[];state={'interrupted':False,'rc':None}
 u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
 u.reg_write(UC_ARM64_REG_FPCR,fp_state[0]);u.reg_write(UC_ARM64_REG_FPSR,fp_state[1])
 u.reg_write(UC_ARM64_REG_X18,0x7654321000011111)
 saved={}
 for i in range(19,29):
  saved[i]=0xa0000000+i;u.reg_write(UC_ARM64_REG_X0+i,saved[i])
 def trace(uc,address,size,_):
  nonlocal count
  count+=1
  if uc.reg_read(UC_ARM64_REG_SP)%16:alignment_errors.append(hex(address));uc.emu_stop()
  if uc.reg_read(UC_ARM64_REG_X18)!=0x7654321000011111:reserved.append(hex(address));uc.emu_stop()
 def svc(uc,no,_):
  assert no==2,('unexpected interrupt',no)
  pc=uc.reg_read(UC_ARM64_REG_PC);assert bytes(uc.mem_read(pc-4,4))==bytes.fromhex('011000d4')
  n=uc.reg_read(UC_ARM64_REG_X16);args=[uc.reg_read(UC_ARM64_REG_X0+i)for i in range(3)];calls.append([n,*args])
  assert uc.reg_read(UC_ARM64_REG_SP)%16==0
  if observer is not None: observer(uc,n,args)
  nzcv=uc.reg_read(UC_ARM64_REG_NZCV)&~(1<<29)
  if n==4:
   fd,ptr,length=args;assert fd==1
   if failure:uc.reg_write(UC_ARM64_REG_X0,9);nzcv|=1<<29
   elif fault=='zero':uc.reg_write(UC_ARM64_REG_X0,0)
   elif fault=='oversize':uc.reg_write(UC_ARM64_REG_X0,length+1)
   elif interrupt and not state['interrupted']:
    state['interrupted']=True;uc.reg_write(UC_ARM64_REG_X0,4);nzcv|=1<<29
   else:
    length=min(length,short) if short else length
    output.extend(uc.mem_read(ptr,length));uc.reg_write(UC_ARM64_REG_X0,length)
   # XNU's syscall return can overwrite both x0 and x1.
   uc.reg_write(UC_ARM64_REG_X1,0xdeadbeef)
   uc.reg_write(UC_ARM64_REG_NZCV,nzcv)
  elif n==1:state['rc']=args[0];uc.emu_stop()
  else:raise AssertionError(('unsupported syscall model',n))
 u.hook_add(UC_HOOK_INTR,svc);u.hook_add(UC_HOOK_CODE,trace)
 u.emu_start(entry,end,count=2000000)
 assert not alignment_errors,alignment_errors
 assert not reserved,reserved
 assert u.reg_read(UC_ARM64_REG_PC)==end or state['rc']is not None,('not terminated',hex(u.reg_read(UC_ARM64_REG_PC)))
 if state['rc']is None:
  assert u.reg_read(UC_ARM64_REG_SP)==initialsp
  assert u.reg_read(UC_ARM64_REG_FP)==initialfp
  assert all(u.reg_read(UC_ARM64_REG_X0+i)==v for i,v in saved.items())
  assert u.reg_read(UC_ARM64_REG_FPCR)==fp_state[0] and u.reg_read(UC_ARM64_REG_FPSR)==fp_state[1]
  state['rc']=u.reg_read(UC_ARM64_REG_X0)
 return {'stdout_hex':output.hex(),'rc':state['rc'],'instructions':count,'syscalls':len(calls),'sp_aligned':True,'x18_preserved':True,'mode':'Unicorn + own syscall model, not macOS execution'}
if __name__=='__main__':
 print(json.dumps(execute(sys.argv[1]),indent=2))
