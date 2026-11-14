from pathlib import Path
import sys,struct,json,os,subprocess
from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM
from unicorn.arm64_const import *
r=Path(__file__).resolve().parent
u=Uc(UC_ARCH_ARM64,UC_MODE_ARM);u.mem_map(0x10000,0x1000);u.mem_write(0x10000,(r/'fp-env-probe.bin').read_bytes());u.mem_map(0x20000,0x1000);u.mem_map(0x30000,0x1000);u.reg_write(UC_ARM64_REG_CPACR_EL1,3<<20)
records=[]
# Rounding mode, flush-to-zero, default-NaN and alternative-half state.
for rounding in range(4):
 for flags in [0,1<<24,1<<25,(1<<24)|(1<<25),1<<26]:
  for fpsr in [0,1,2,4,8,16,128,0x0800009f]:
   fpcr=rounding<<22|flags
   u.reg_write(UC_ARM64_REG_FPCR,fpcr);u.reg_write(UC_ARM64_REG_FPSR,fpsr)
   actualc=u.reg_read(UC_ARM64_REG_FPCR);actuals=u.reg_read(UC_ARM64_REG_FPSR)
   u.reg_write(UC_ARM64_REG_SP,0x31000-16);u.reg_write(UC_ARM64_REG_FP,0x7777);u.reg_write(UC_ARM64_REG_LR,0x20000)
   u.emu_start(0x10000,0x20000,count=100)
   assert u.reg_read(UC_ARM64_REG_PC)==0x20000
   assert u.reg_read(UC_ARM64_REG_X0)==u.reg_read(UC_ARM64_REG_X1)==0
   assert u.reg_read(UC_ARM64_REG_FPCR)==actualc and u.reg_read(UC_ARM64_REG_FPSR)==actuals
   assert u.reg_read(UC_ARM64_REG_SP)==0x31000-16 and u.reg_read(UC_ARM64_REG_FP)==0x7777
   records.append([actualc,actuals])
# Fixed words plus optional independently generated LLVM Mach-O text.
ours=(r/'fp-env-words.bin').read_bytes()
assert ours==bytes.fromhex('09443bd509441bd52a443bd52a441bd5df3f03d5')
llvm=False
if os.environ.get('LLVM_SHARED_LIBRARY'):
 subprocess.run([sys.executable,str(r.parent/'make_reference.py'),str(r/'fp-env-reference.ll'),str(r/'fp-env-reference')],check=True)
 b=(r/'fp-env-reference.o').read_bytes();o=32;ref=None
 for _ in range(struct.unpack_from('<I',b,16)[0]):
  cmd,n=struct.unpack_from('<II',b,o)
  if cmd==25:
   for i in range(struct.unpack_from('<I',b,o+64)[0]):
    p=o+72+i*80
    if b[p:p+16].split(b'\0')[0]==b'__text':
     size,off=struct.unpack_from('<QI',b,p+40);ref=b[off:off+size]
  o+=n
 assert ref==ours
 llvm=True
(r/'fp-env-results.json').write_text(json.dumps({'cases':len(records),'llvm_words':5 if llvm else 0,'normalized_then_exactly_restored':True,'scope':'instruction-emulated reversible FPCR/FPSR boundary only, no production entry or actual macOS ABI validation'},indent=2)+'\n')
print(len(records),'FPCR/FPSR boundary controls exact; LLVM words:',5 if llvm else 'not requested')
