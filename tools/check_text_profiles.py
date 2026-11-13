#!/usr/bin/env python3
"""Check TEXT LLVM/target profiles; Windows generation is not execution."""
import argparse, pathlib, subprocess, json, os
p=argparse.ArgumentParser()
p.add_argument('--compiler',required=True)
p.add_argument('--core',required=True)
p.add_argument('--oracle-results',required=True)
p.add_argument('--output',required=True)
a=p.parse_args()
repo=pathlib.Path(__file__).resolve().parents[1]
compiler=str(pathlib.Path(a.compiler).resolve()); core=pathlib.Path(a.core).resolve()
out=pathlib.Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
oracles=pathlib.Path(a.oracle_results).resolve();base=repo/'experiments/llvm-scalar'
rows=[]
def run(cmd):return subprocess.run(list(map(str,cmd)),cwd=repo,capture_output=True,timeout=30)
def build(cmd):
 r=run(cmd);assert r.returncode==0,(cmd,r.stderr);return r
sources=[core/'tests/vec1.prg']+sorted((repo/'tests').glob('t15[6789][0-9]_text_*.prg'))
sources=[s for s in sources if '_neg_' not in s.name]
for source in sources:
 for target in ['linux','windows']:
  stem=out/(source.stem+'-'+target)
  ll=str(stem)+'.ll'
  r=run([compiler,source,ll,'--target='+target,'--experimental-llvm','-I',repo/'tests'])
  row={'file':source.name,'target':target,'admitted':r.returncode==0};rows.append(row)
  (out/(source.stem+'-'+target+'.stderr')).write_bytes(r.stderr)
  if source.name != 't1573_text_inactive.prg':
   assert r.returncode != 0 and b'bare TEXT literal streams require exact terminal presentation' in r.stderr,row
   row['diagnostic']=r.stderr.decode(errors='replace');continue
  assert r.returncode==0,(row,r.stderr)
  obj=str(stem)+'.o'
  cmd=['python3',base/'llvm_aot.py',ll,obj]
  if target=='windows':cmd.append('windows')
  build(cmd);row['llvm_verified_object']=True
  if target=='linux':
   runtime=ll+'.runtime.s';build(['python3',base/'link_runtime.py',runtime])
   build(['as',runtime,'-o',str(stem)+'.runtime.o'])
   build(['ld',obj,str(stem)+'.runtime.o','-o',stem])
   r=build([stem]);expected=oracles/source.stem
   assert (r.stdout,r.stderr,r.returncode)==((expected/'oracle.stdout').read_bytes(),(expected/'oracle.stderr').read_bytes(),int((expected/'oracle.rc').read_text())),row
   row['exact_linux_execution']=True
negatives=[]
for line in (repo/'tests/manifest.txt').read_text().splitlines():
 if not line.startswith('neg tests/t15') or '_text_neg_' not in line:continue
 _,source,expected=line.split(' ',2)
 for target in ['linux','windows']:
  for llvm in [False,True]:
   cmd=[compiler,repo/source,out/'reject.s','--target='+target,'-I',repo/'tests']
   if llvm:cmd.append('--experimental-llvm')
   r=run(cmd);ok=r.returncode!=0 and expected in r.stderr.decode(errors='replace')
   negatives.append({'file':source,'target':target,'llvm':llvm,'expected_rejection':ok})
   assert ok,(cmd,r.stderr)
no_trace=[]
for source in sources:
 if source.name=='t1573_text_inactive.prg':continue
 for target in ['linux','windows']:
  r=run([compiler,source,out/'no-trace.ll','--target='+target,'--experimental-llvm-no-trace','-I',repo/'tests'])
  ok=r.returncode!=0 and b'bare TEXT literal streams require exact terminal presentation' in r.stderr
  no_trace.append({'file':source.name,'target':target,'expected_rejection':ok});assert ok
(out/'results.json').write_text(json.dumps({'positives':rows,'negatives':negatives,'no_trace':no_trace},indent=2)+'\n')
print('PASS',sum(x.get('exact_linux_execution',False) for x in rows),'LLVM Linux exact;',sum(x.get('llvm_verified_object',False) and x['target']=='windows' for x in rows),'Windows LLVM objects;',sum(not x['admitted'] for x in rows),'named LLVM rejections;',len(negatives),'negative profile checks;',len(no_trace),'no-trace rejections')
