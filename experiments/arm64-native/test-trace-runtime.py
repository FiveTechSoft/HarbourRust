"""Native diagnostic traversal and real current x86 zero-error output oracle."""
from pathlib import Path
import subprocess,importlib.util,json
r=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
out=r/'trace-fixtures-out';records=[]
# Current real x86 compiler, not a hand-written expected message.
f=out/'zero.prg';f.write_text('FUNCTION Main()\nLOCAL n:=8\nLOCAL d:=0\nLOCAL v:=n/d\n? v\nRETURN\n')
b=out/'zero.linux';subprocess.run([str(r/'hbc-baseline'),str(f),str(b),'--target=linux'],check=True,capture_output=True)
ref=subprocess.run([str(b)],capture_output=True);assert ref.returncode==1 and ref.stderr==b''
assert ref.stdout==b'Error: division by zero\nCallstack:\n'+f'  at main ({f}:4)\n'.encode()
for depth in [0,1,4,5,17,65,257]:
 trace=(b'Callstack:\n'+b''.join(f'  at proc{i} (fixture.ch:{i+10})\n'.encode()for i in reversed(range(depth))if i!=2))if depth else b''
 for action in ['trace','panic','zero']:
  want=(b'Error: division by zero\n'+trace) if action=='zero'else trace;rc=0 if action=='trace'else 1
  if action=='zero' and depth==1:want=ref.stdout
  f=out/f'{action}-{depth}.arm'
  for short,intr in [(None,False),(1,False),(3,True),(11,True)]:
   got=m.execute(f,short,intr);assert got['rc']==rc and bytes.fromhex(got.pop('stdout_hex'))==want,(depth,action,short,got)
   records.append({'depth':depth,'action':action,'short':short,'eintr':intr,**got})
  # Empty trace emits nothing, so I/O fault injection cannot change its return.
  if want:
   for fault in ['zero','oversize','failure']:
    got=m.execute(f,failure=fault=='failure',fault=None if fault=='failure'else fault)
    assert got['rc']==74 and got.pop('stdout_hex')=='',(depth,action,fault,got)
    records.append({'depth':depth,'action':action,'fault':fault,**got})
(out/'results.json').write_text(json.dumps({'controls':len(records),'max_native_depth':257,'zero_oracle':'current hbc native Linux stdout/stderr/exit','scope':'own linked diagnostic runtime under emulator and syscall model, no source numeric admission, no language TRY/unwinding, no Mac hardware','cases':records},indent=2)+'\n')
print(len(records),'native trace/error + short-write/EINTR/I/O failure controls pass, depth257; zero matches live x86 baseline')
