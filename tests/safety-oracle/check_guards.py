#!/usr/bin/env python3
"""Test-only fault injection for the two upgraded safety rows, no compiler edits."""
from pathlib import Path
import argparse,hashlib,json,subprocess,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
proxy='''#!/usr/bin/env python3
import sys,subprocess,json
from pathlib import Path
cfg=json.loads(Path(__file__).with_suffix('.json').read_text());args=sys.argv[1:];source=Path(args[0]).read_text();binary=Path(args[1]);name=cfg['fault'];positive=source==cfg['original'];boundary=source==cfg['boundary']
if positive and name=='positive-build-reject':
 print('injected positive rejection',file=sys.stderr);sys.exit(1)
if boundary and name=='boundary-accept':
 binary.write_text('#!/bin/sh\\nexit 0\\n');binary.chmod(0o755);sys.exit(0)
r=subprocess.run([cfg['compiler'],*args])
if r.returncode==0 and positive and name=='positive-output':
 binary.write_text('#!/bin/sh\\nprintf wrong-positive-output\\n');binary.chmod(0o755)
sys.exit(r.returncode)
'''
for family,total,name,original,boundary in [
 ('inline-dyn',12,'date','function Main()\nlocal x:=StoD("20260101")\n? (x:=StoD("20260203"))\nreturn nil\n','function Main()\nlocal x\n? x,ValType(x),(x:=StoD("20260203"))\nreturn nil\n'),
 ('hash-strings',15,'numeric-key','function Main()\nlocal h:={=>}\nh[10]:="literal"\nreturn nil\n','function Main()\nlocal h:={=>},n:=10\nh[n]:="literal"\n? h[n]\nreturn nil\n')]:
 for fault in ['positive-build-reject','positive-output','boundary-accept']:
  w=out/(family+'-'+fault);w.mkdir();f=w/'proxy.py';f.write_text(proxy);f.chmod(0o755);f.with_suffix('.json').write_text(json.dumps(dict(compiler=str(Path(a.compiler).resolve()),fault=fault,original=original,boundary=boundary)));d=w/'gate';cmd=['python3',str(repo/'tests'/family/'safety.py'),'--compiler',str(f),'--hbmk2',a.hbmk2,'--output',str(d)];r=subprocess.run(cmd,cwd=repo,capture_output=True,timeout=90)
  for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/('gate.'+ext)).write_bytes(v)
  j=json.load(open(d/'results.json'));failed=[x['name'] for x in j['rows'] if not x['ok']];assert r.returncode==1 and len(j['rows'])==total and failed==[name],(family,fault,r.returncode,failed)
  row=dict(family=family,fault=fault,gate_rc=r.returncode,total_rows=len(j['rows']),failed_rows=failed,ok=True);rows.append(row);print(row,flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Six executable proxy faults, compiler product untouched. Positive build rejection, positive rc0 wrong output and unsupported-boundary acceptance must each fail exactly the upgraded row. Top-level row counts stay12/15.',rows=rows),indent=2))
