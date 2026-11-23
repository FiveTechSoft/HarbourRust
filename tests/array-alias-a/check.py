#!/usr/bin/env python3
"""A1 exact measured Julio oracles and own scoped-alias ownership checks."""
import argparse,json,os,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2];here=Path(__file__).resolve().parent
cc=str(Path(a.compiler).resolve());out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import emit_delta
rows=[]
def run(cmd,label):
 r=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=60)
 for ext,data in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(out/(label+'.'+ext)).write_bytes(data)
 return r
wants={n:(here/(n+'.out')).read_bytes() for n in ['p05','p10','v05','v10']}
wants.update(memory=b'\n       101        100       6350          9',exception=b'\n       200        101          9')
for name,want in wants.items():
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays'])]:
  label=name+'-'+mode;exe=out/label
  r=run([cc,here/(name+'.prg'),exe,'--instrument',*flags],label+'-build');assert r.returncode==0,(name,r.stderr)
  r=run([exe],label+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,want,b''),(label,r.returncode,r.stdout,r.stderr)
  rows.append(dict(name=label,kind='exact-execution'))
 d=out/(name+'-delta');d.mkdir();row=emit_delta(cc,os.environ,here/(name+'.prg'),d,want)
 assert row['state_ok'] and row['delta']==0,(name,row)
 rows.append(dict(name=name,kind='final-balance',**row))
for name in ['limits','thread_limit']:
 r=run([cc,here/(name+'.prg'),out/name],name);assert r.returncode==1 and r.stderr.startswith(b'error:'),(name,r.stderr)
 rows.append(dict(name=name,kind='named-rejection',diagnostic=r.stderr.decode()))
for target in ['windows','macho','macho-arm64']:
 for name in ['v05','v10']:
  r=run([cc,here/(name+'.prg'),out/(name+'-'+target+'.s'),'--target='+target],name+'-'+target)
  assert r.returncode==1 and r.stderr.startswith(b'error:'),(target,name,r.stderr)
  rows.append(dict(name=name+'-'+target,kind='profile-rejection',diagnostic=r.stderr.decode()))
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
print('PASS A1:18 exact executions;6 final delta=0;2 limits;6 profile rejections')
