#!/usr/bin/env python3
"""Own MIT mandatory current-compiler replay of five intact-original gates."""
from pathlib import Path
import argparse,subprocess,json,hashlib,sys
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','spec-root','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[];cc=str(Path(a.compiler).resolve())
for name in ['original-array-control','original-scalar-control','original-calls-control','original-input-control','original-filesystem-control']:
 d=out/name;cmd=[sys.executable,str(root/'tests'/name/'check.py'),'--compiler',cc,'--hbmk2',str(Path(a.hbmk2).resolve()),'--spec-root',str(Path(a.spec_root).resolve()),'--output',str(d)];z=subprocess.run(cmd,cwd=root,capture_output=True,timeout=120,stdin=subprocess.DEVNULL)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(out/(name+'.'+k)).write_bytes(b)
 (out/(name+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(root)),indent=2)+'\n');assert z.returncode==0,(name,z.stdout,z.stderr);j=json.loads((d/'results.json').read_text());assert j['compiler_sha256']==hashlib.sha256(Path(cc).read_bytes()).hexdigest();rows.append(dict(name=name,checks=len(j['rows']),compiler_sha256=j['compiler_sha256']));print(name,'PASS',len(j['rows']),flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),hbmk2_sha256=hashlib.sha256(Path(a.hbmk2).read_bytes()).hexdigest(),oracle_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=a.spec_root,text=True).strip(),rows=rows),indent=2)+'\n');print('PASS',sum(x['checks']for x in rows))
