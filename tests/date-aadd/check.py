#!/usr/bin/env python3
"""D: exact local date-array checks, no independent Harbour claim except t09."""
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
wants={'t09':(here/'t09.out').read_bytes(),
 'paths':b'\nD 11/23/26 D   /  /\nD 11/23/26\n23/11/2026 23/11/2026   /  /\n23.11.26\nN L U',
 'memory':b'\nD 11/23/26 D   /  /   D 11/23/26',
 'catch':b'\nD 11/23/26',
 'copy':b'\nD 11/23/26 D 11/23/26',
 'streams':b'[ 23/11/2026 ]','streams_static':b'[ 23/11/2026 ]'}
for name,want in wants.items():
 for mode,flags in [('native',['--instrument']),('external',['--external-as','--instrument']),('flat',['--no-vas-arrays','--instrument'])]:
  label=name+'-'+mode;exe=out/label
  r=run([cc,here/(name+'.prg'),exe,'--target=linux',*flags],label+'-build');assert r.returncode==0,r.stderr
  r=run([exe],label+'-run');err=want if name.startswith('streams') else b''
  assert (r.returncode,r.stdout,r.stderr)==(0,want,err),(label,r.returncode,r.stdout,r.stderr)
  rows.append(dict(name=label,kind='exact-execution'))
 if not name.startswith('streams'):
  d=out/(name+'-delta');d.mkdir();row=emit_delta(cc,os.environ,here/(name+'.prg'),d,want)
  assert row['state_ok'] and row['delta']==0,(name,row)
  rows.append(dict(name=name,kind='final-balance',**row))
 for target in ['windows','macho','macho-arm64']:
  r=run([cc,here/(name+'.prg'),out/(name+'-'+target+'.s'),'--target='+target,'--instrument'],name+'-'+target)
  assert r.returncode==0,(name,target,r.stderr)
  rows.append(dict(name=name+'-'+target,kind='assembly-emission-only'))
r=run([cc,here/'empty_limit.prg',out/'empty_limit'],'empty_limit')
assert r.returncode==1 and b'`Empty` on generic Dyn values is not in this increment' in r.stderr,r.stderr
rows.append(dict(name='empty_limit',kind='named-rejection'))
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
print('PASS date-aadd: 21 exact Linux executions, 5 final delta=0, 21 cross-target emissions, 1 named limit')
