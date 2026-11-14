import random,subprocess,importlib.util,json
from pathlib import Path
r=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
rng=random.Random(34364)
values=[0,1,-1,9223372036854775807,-9223372036854775808]
for n in range(1,19):
 for off in [-1,0,1]:
  values.extend([10**n+off,-10**n+off])
values.extend(rng.randrange(-2**63,2**63)for _ in range(150))
values=[v for v in values if -2**63<=v<2**63]
subprocess.run([str(r/'runtime-fixtures'),str(r/'runtime-probe'),*map(str,values)],check=True)
def fmt(v):
 t=str(v);width=(max(10,len(t)+1)if v>=0 else (10 if len(t)<=10 else 20))
 return t.rjust(width)
want=('\n'.join(map(fmt,values))+'\n.T..F.').encode()
# Runtime harness prints false first, then true.
want=('\n'.join(map(fmt,values))+'\n.F..T.').encode()
results=[]
for short,eintr in [(None,False),(1,False),(3,True),(7,True)]:
 v=m.execute(r/'runtime-probe',short,eintr);assert v['rc']==0;assert bytes.fromhex(v['stdout_hex'])==want,(short,eintr,bytes.fromhex(v['stdout_hex'])[:500],want[:500]);v.pop('stdout_hex');results.append(v|{'short':short,'eintr':eintr})
for fault in ['zero','oversize']:
 v=m.execute(r/'runtime-probe',fault=fault);assert v['rc']==74 and v['stdout_hex']=='';v.pop('stdout_hex');results.append(v|{'fault':fault})
v=m.execute(r/'runtime-probe',failure=True);assert v['rc']==74 and v['stdout_hex']=='';v.pop('stdout_hex');results.append(v|{'write_failure':True})
(r/'runtime-emulator-results.json').write_text(json.dumps({'integer_values':len(values),'cases':results,'limits':'own syscall model and emulator; not Darwin execution or Harbour runtime proof'},indent=2)+'\n')
print(len(values),'integer formatting vectors, full/partial/EINTR/failure models pass')
