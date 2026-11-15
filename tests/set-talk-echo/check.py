#!/usr/bin/env python3
"""Exact console oracle; rejected syntax/DBF combinations never execute."""
import argparse,json,subprocess,pathlib,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--wine');p.add_argument('--wine-prefix');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);r=pathlib.Path(__file__).resolve().parent
rows=[]
env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=a.wine_prefix
def run(cmd):return subprocess.run(list(map(str,cmd)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,env=env,timeout=30)
def keep(label,q):
 (a.output/(label+'.stdout')).write_bytes(q.stdout);(a.output/(label+'.stderr')).write_bytes(q.stderr)
 return q
for name in ['basic','order']:
 src=r/(name+'.prg');hb=a.output/(name+'-hb');q=keep(name+'-hb-build',run([a.hbmk2,src,'-quiet','-gtstd','-o'+str(hb)]));assert q.returncode==0,q.stderr
 oracle=keep(name+'-hb',run([hb]));hb.unlink();assert oracle.returncode==0 and not oracle.stderr
 for target in ['linux']+(['windows'] if a.wine else []):
  # Existing hbc QOut writes LF on both targets. No Windows Harbour oracle claimed.
  expected=oracle.stdout
  for inst in [False,True]:
   label=name+'-'+target+'-'+str(int(inst));exe=a.output/label;flags=['--target='+target]+(['--instrument'] if inst else [])
   q=keep(label+'-build',run([a.compiler,src,exe]+flags));assert q.returncode==0,(label,q.stderr)
   q=keep(label,run([a.wine,exe] if target=='windows' else [exe]));exe.unlink();assert (q.returncode,q.stdout,q.stderr)==(0,expected,b''),(label,q.returncode,q.stdout,expected,q.stderr)
   rows.append(dict(case=label,status='PASS',sha256=hashlib.sha256(q.stdout).hexdigest()))
for src in sorted(r.glob('*-neg.prg')):
 label=src.stem;exe=a.output/label;q=keep(label,run([a.compiler,src,exe]));
 expect=(b'SET TALK/ECHO with DBF operations' if '-dbf-' in label else b'SET commands are not in this increment' if label=='other-neg' else b'SET TALK/ECHO require exactly ON or OFF')
 assert q.returncode!=0 and expect in q.stderr,(label,q.returncode,q.stderr)
 assert not exe.exists(),label
 rows.append(dict(case=label,status='PASS',diagnostic=expect.decode()))
(a.output/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(str(len(rows))+' PASS')
