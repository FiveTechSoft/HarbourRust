#!/usr/bin/env python3
"""Raw terminal-headless gate, separate from legacy posx's empty-stderr rule."""
import argparse,subprocess,os,json,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--compiler',type=Path);p.add_argument('--adapter',type=Path);p.add_argument('--target',choices=['linux','windows'],required=True);p.add_argument('--wine',default='/tmp/hr-wine11/opt/wine-stable/bin/wine');p.add_argument('--wine-prefix',default='/tmp/hr-win11-prefix');p.add_argument('--output',type=Path,required=True);p.add_argument('--specs',type=Path,default=Path(__file__).with_name('specs.json'));a=p.parse_args()
assert bool(a.compiler)!=bool(a.adapter),'choose exactly one of --compiler or --adapter'
a.output.mkdir(parents=True,exist_ok=False);out=a.output.resolve();root=a.root.resolve();specs=json.loads(a.specs.read_text());specroot=a.specs.resolve().parent;env=os.environ.copy();env.update(WINEPREFIX=a.wine_prefix,WINEDEBUG='-all');rows=[]
for case in specs['cases']:
 name=Path(case['source']).stem;d=out/name;d.mkdir();binary=d/('program.exe' if a.target=='windows' else 'program')
 if a.compiler:
  q=subprocess.run([str(a.compiler.resolve()),case['source'],str(binary),'--target='+a.target,'-I','tests'],cwd=root,env=env,capture_output=True,timeout=60)
  (d/'compile.stdout').write_bytes(q.stdout);(d/'compile.stderr').write_bytes(q.stderr);(d/'compile.rc').write_text(str(q.returncode)+'\n')
  if q.returncode:rows.append(dict(case=name,pass_raw=False,stage='compile',rc=q.returncode));continue
  cmd=[str(binary)];h=hashlib.sha256(binary.read_bytes()).hexdigest()
 else:cmd=[str(a.adapter.resolve()),name];h=hashlib.sha256(a.adapter.read_bytes()).hexdigest()
 if a.target=='windows':cmd.insert(0,a.wine)
 try:
  q=subprocess.run(cmd,cwd=root,env=env,capture_output=True,stdin=subprocess.DEVNULL,timeout=10)
  (d/'run.stdout').write_bytes(q.stdout);(d/'run.stderr').write_bytes(q.stderr);(d/'run.rc').write_text(str(q.returncode)+'\n');sp=case['targets'][a.target]
  wantout=(specroot/sp['terminal_stdout']).read_bytes();wanterr=(specroot/sp['stderr']).read_bytes()
  (d/'expected.stdout').write_bytes(wantout);(d/'expected.stderr').write_bytes(wanterr)
  rows.append(dict(case=name,pass_raw=q.returncode==case['exit'] and q.stdout==wantout and q.stderr==wanterr,rc=q.returncode,binary_sha256=h,scope='adapter-only' if a.adapter else 'compiler-end-to-end'))
 except subprocess.TimeoutExpired:rows.append(dict(case=name,pass_raw=False,stage='timeout'))
 if a.compiler and binary.exists():binary.unlink()
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(rows,indent=2));raise SystemExit(0 if all(x['pass_raw'] for x in rows) else 1)
