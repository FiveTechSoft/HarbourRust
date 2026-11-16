#!/usr/bin/env python3
"""Named F5 limits and inherited platform guards; not Harbour equivalence claims."""
from pathlib import Path
import argparse,subprocess,json,sys
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args()
hbc=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
root=Path(__file__).resolve().parent;results=[]
def run(cmd,stem):
 r=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=30)
 (out/(stem+'.cmd.json')).write_text(json.dumps(list(map(str,cmd))))
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(out/(stem+'.'+k)).write_bytes(v)
 return r
for name,expected in json.loads((root/'negative/expected.json').read_text()).items():
 r=run([hbc,root/'negative'/(name+'.prg'),out/(name+'.s')],name)
 ok=r.returncode==1 and expected.encode() in r.stderr and b'panicked' not in r.stderr
 results.append({'name':name,'ok':ok});print(name,ok)
for label,flags,match in [('windows',['--target=windows'],'threads are Linux-only'),('instrument',['--instrument'],'--instrument is not supported with threads')]:
 r=run([hbc,root/'programs/lailton.prg',out/(label+'.s')]+flags,label)
 ok=r.returncode==1 and match.encode() in r.stderr
 results.append({'name':label,'ok':ok});print(label,ok)
# Runtime miss must run the already-evaluated arguments, then fail closed,
# not silently use NIL or dispatch another function. No recovery ABI claimed.
src=out/'unknown-runtime.prg';src.write_text('''procedure Main()
local t,name:="absent"
t:=hb_threadStart(name,side())
return
function side()
? "arg-ran"
return 1
''')
r=run([hbc,src,out/'unknown-runtime'],'unknown-build')
if r.returncode==0:
 r=run([out/'unknown-runtime'],'unknown-run')
 ok=r.returncode==1 and r.stdout.startswith(b'\narg-ran') and b'unknown or unsupported function name' in r.stderr
else:ok=False
results.append({'name':'runtime_unknown','ok':ok});print('runtime_unknown',ok)
literal=out/'unknown-literal.prg';literal.write_text('procedure Main()\nlocal t\nt:=hb_threadStart("absent")\nreturn\n')
r=run([hbc,literal,out/'unknown-literal'],'literal-build')
if r.returncode==0:
 r=run([out/'unknown-literal'],'literal-run')
 ok=r.returncode==1 and b'unknown or unsupported function name' in r.stderr
else:ok=False
results.append({'name':'literal_unknown_runtime_failure','ok':ok});print('literal_unknown_runtime_failure',ok)
(out/'results.json').write_text(json.dumps(results,indent=2));sys.exit(0 if all(v['ok'] for v in results) else 1)
