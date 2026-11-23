#!/usr/bin/env python3
"""Timestamp phase1 scalar checks. t01/02/04/07 and parse use supplied oracles."""
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
wants={n:(here/(n+'.out')).read_bytes() for n in ['t01','t02','t04','t07','parse']}
wants.update(runtime_compare_limit=b'\ncomparison rejected',extremes=b'\n00000101000000000\n99991231235959999\n20000229010203004\n00000000010203004\n00000229000000000\n19700101000000000',forward=b'\n20261123000000000 20261123000000000 .F. .F. .F.',memory=b'\nT 20261123101530999 20261123101530999\n20261123101530999',errors=b'\ndone',predicates=b'\n.F. .F. .F.',valtype=b'\nT T D C',user_override=b'\n         5')
for name,want in wants.items():
 for mode,flags in [('native',['--instrument']),('external',['--external-as','--instrument']),('flat',['--no-vas-arrays','--instrument'])]:
  label=name+'-'+mode;exe=out/label
  r=run([cc,here/(name+'.prg'),exe,'--target=linux',*flags],label+'-build');assert r.returncode==0,(name,r.stderr)
  r=run([exe],label+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,want,b''),(label,r.returncode,r.stdout,r.stderr)
  rows.append(dict(name=label,kind='exact-execution'))
 d=out/(name+'-delta');d.mkdir();row=emit_delta(cc,os.environ,here/(name+'.prg'),d,want)
 assert row['state_ok'] and row['delta']==0,(name,row)
 rows.append(dict(name=name,kind='final-balance',**row))
state=b'\n11/23/26 10:15:30.999\n23/11/2026 10:15:30.999 23/11/2026   /  /     00:00:00.000\n26.11.23 10:15:30.999[ 26.11.23 10:15:30.999 ]'
for mode,flags in [('native',[]),('external',['--external-as'])]:
 exe=out/('state-'+mode);r=run([cc,here/'state.prg',exe,*flags],'state-'+mode+'-build');assert r.returncode==0,r.stderr
 r=run([exe],'state-'+mode+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,state,b'[ 26.11.23 10:15:30.999 ]'),r
 rows.append(dict(name='state-'+mode,kind='exact-streams-execution'))
for name,needle in [('arithmetic_limit',b'timestamp arithmetic and comparison'),('comparison_limit',b'timestamp arithmetic and comparison'),('macro_limit',b'timestamp phase 1 requires ordinary Linux'),('thread_limit',b'timestamp phase 1 requires ordinary Linux'),('aggregate_limit',b'timestamp predicates accept scalar values')]:
 r=run([cc,here/(name+'.prg'),out/name],name);assert r.returncode==1 and needle in r.stderr,(name,r.stderr)
 rows.append(dict(name=name,kind='named-rejection'))
for target in ['windows','macho','macho-arm64']:
 r=run([cc,here/'t01.prg',out/('limit-'+target+'.s'),'--target='+target],'limit-'+target)
 assert r.returncode==1 and b'timestamp phase 1 requires ordinary Linux' in r.stderr,(target,r.stderr)
 r=run([cc,here/'user_override.prg',out/('override-'+target+'.s'),'--target='+target],'override-'+target);assert r.returncode==0,r.stderr
 rows.append(dict(name=target,kind='profile-rejection-and-user-override-emission'))
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
print('PASS timestamp phase1: 39 exact executions + 2 streams; 13 delta=0; 5 named limits; 3 profile rejections + user override emissions')
