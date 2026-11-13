#!/usr/bin/env python3
"""INIT target/rejection boundaries. Windows assembly is not execution."""
import argparse,pathlib,subprocess,json,re
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--core',required=True);p.add_argument('--output',required=True);a=p.parse_args()
repo=pathlib.Path(__file__).resolve().parents[1];compiler=str(pathlib.Path(a.compiler).resolve());out=pathlib.Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
sources=[pathlib.Path(a.core).resolve()/'tests/initproc.prg',repo/'tests/t681_init_proc_neg.prg']+sorted((repo/'tests').glob('t*_startup_*.prg'));sources=[s for s in sources if '_neg_' not in s.name or s.name=='t681_init_proc_neg.prg']
rows=[];negative=[]
def run(cmd):return subprocess.run(list(map(str,cmd)),cwd=repo,capture_output=True,timeout=30)
for source in sources:
 calls=None
 for target in ['linux','windows']:
  asm=out/(source.stem+'-'+target+'.s')
  r=run([compiler,source,asm,'--target='+target,'-I',repo/'tests']);assert r.returncode==0,(source,r.stderr)
  startup=asm.read_text().split('call hbc_fn_main',1)[0]
  found=re.findall(r'call hbc_fn_([^\s]+)',startup);assert found and all(s.endswith('$') for s in found)
  if calls is None:calls=found
  else:assert calls==found,(source,calls,found)
  for flag in ['--experimental-llvm','--experimental-llvm-no-trace']:
   r=run([compiler,source,out/'reject.ll','--target='+target,flag,'-I',repo/'tests'])
   assert r.returncode!=0 and (b'INIT startup procedures are not in this increment' in r.stderr or b'bare TEXT literal streams require exact terminal presentation' in r.stderr),(source,target,flag,r.stderr)
   rows.append({'source':source.name,'target':target,'llvm_mode':flag,'startup_calls':found,'llvm_rejected':True})
for line in (repo/'tests/manifest.txt').read_text().splitlines():
 if not line.startswith('neg ') or '_startup_neg_' not in line:continue
 _,source,expected=line.split(' ',2)
 for target in ['linux','windows']:
  for mode in ['ordinary','--experimental-llvm','--experimental-llvm-no-trace']:
   cmd=[compiler,repo/source,out/'negative.s','--target='+target,'-I',repo/'tests']
   if mode!='ordinary':cmd.append(mode)
   r=run(cmd)
   # Some semantic negatives hit the earlier INIT LLVM boundary instead.
   ok=r.returncode!=0 and (expected.encode() in r.stderr or (mode!='ordinary' and b'INIT startup procedures are not in this increment' in r.stderr))
   assert ok,(source,target,mode,r.stderr)
   negative.append({'source':source,'target':target,'mode':mode,'rejected':True,'diagnostic':r.stderr.decode()})
(out/'results.json').write_text(json.dumps({'positives':rows,'negatives':negative},indent=2)+'\n');print('PASS',len(rows),'positive LLVM rejections with ordinary target startup ordering;',len(negative),'negative profile checks; no Windows execution')
