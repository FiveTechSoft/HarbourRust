#!/usr/bin/env python3
"""Own MIT: re-run bounded frontier gates together on one compiler identity."""
from pathlib import Path
import argparse,json,subprocess,hashlib,sys
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','llvm-lib','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();r=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir();rows=[];cc=Path(a.compiler).resolve();sha=hashlib.sha256(cc.read_bytes()).hexdigest()
names=['cli-defines','pp-sign-boundary','pp-param-sign','pp-if-hex','pp-if-expand','pp-defined-form','pp-if-logical','pp-if-assoc','pp-if-bitwise','pp-if-shift','pp-if-ne','pp-if-chain','llvm-borrowed-len','llvm-borrowed-empty','llvm-borrowed-asc','llvm-borrowed-at','llvm-borrowed-rat','llvm-int','llvm-inline-set','llvm-set-followup','llvm-idxcompound','llvm-dynamic-step','llvm-for-live-bound','llvm-char-predicates','llvm-exact-string','llvm-borrowed-contains','llvm-console-profile','llvm-constant-print','llvm-constant-init']
for name in names:
 d=out/name;cmd=[sys.executable,str(r/'tests'/name/'check.py'),'--compiler',str(cc),'--hbmk2',str(Path(a.hbmk2).resolve()),'--output',str(d)]
 if name.startswith('llvm-'):cmd+=['--llvm-lib',str(Path(a.llvm_lib).resolve())]
 z=subprocess.run(cmd,cwd=r,capture_output=True,timeout=120,stdin=subprocess.DEVNULL)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(out/(name+'.'+k)).write_bytes(b)
 (out/(name+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(r)),indent=2)+'\n');assert z.returncode==0,(name,z.stdout,z.stderr)
 j=json.loads((d/'results.json').read_text());assert j['compiler_sha256']==sha;rows.append(dict(gate=name,count=len(j['rows']),compiler_sha256=sha));print(name,'PASS',len(j['rows']),flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=sha,hbmk2_sha256=hashlib.sha256(Path(a.hbmk2).read_bytes()).hexdigest(),llvm_lib_sha256=hashlib.sha256(Path(a.llvm_lib).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows),'gates',sum(x['count']for x in rows),'rows')
