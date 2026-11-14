#!/usr/bin/env python3
"""Exact channel controls; Windows compares the Linux oracle contract, not a native Harbour oracle."""
from pathlib import Path
import subprocess,json,hashlib,os,argparse,tempfile
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);ap.add_argument('--wine');ap.add_argument('--wine-prefix');ap.add_argument('--console-only',action='store_true');a=ap.parse_args()
r=Path(a.output).resolve();r.mkdir(parents=True,exist_ok=True);repo=Path(__file__).resolve().parents[1];compiler=Path(a.compiler).resolve();rows=[]
for src in sorted((repo/'tests/procmeta').rglob('*.prg')):
 if a.console_only and src.parent.name!='newline-oracle':continue
 for target in (['linux','windows']if a.wine else['linux']):
  for inst in [False,True]:
   exe=r/('smoke.exe'if target=='windows'else'smoke');p=subprocess.run([str(compiler),str(src),str(exe),'--target='+target]+(['--instrument']if inst else[]),capture_output=True,cwd=repo);row=dict(source=str(src.relative_to(repo)),target=target,instrument=inst,compile_rc=p.returncode)
   if src.stem.startswith('reject_'):row['pass']=p.returncode==1 and b'I64'in p.stderr
   else:
    assert not p.returncode,p.stderr;p=subprocess.run(([a.wine]if target=='windows'else[])+[str(exe)],cwd=repo,capture_output=True,timeout=8,env=dict(os.environ,WINEPREFIX=a.wine_prefix or os.environ.get('WINEPREFIX',str(Path.home()/'.wine')),WINEDEBUG='-all'));row.update(rc=p.returncode,stdout=p.stdout.hex(),stderr=p.stderr.hex());row['pass']=(p.stdout,p.stderr,p.returncode)==(src.with_suffix('.stdout').read_bytes(),b'',0);exe.unlink()
   rows.append(row)
   if not row['pass']:print('SMOKE FAIL',row)
(r/'final-smoke.json').write_text(json.dumps({'compiler_sha256':hashlib.sha256(compiler.read_bytes()).hexdigest(),'rows':rows},indent=2)+'\n');print('PASS',sum(x['pass']for x in rows),'/',len(rows));raise SystemExit(0 if all(x['pass']for x in rows)else 1)
