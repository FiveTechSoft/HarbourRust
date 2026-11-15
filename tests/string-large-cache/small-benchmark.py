#!/usr/bin/env python3
"""Interleaved baseline/candidate samples for below-boundary cache overhead."""
import argparse,subprocess,time,statistics,json
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for k in ['compiler','baseline','output']:p.add_argument('--'+k,required=True,type=Path)
a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False);a.compiler=a.compiler.resolve();a.baseline=a.baseline.resolve()
rows=[]
for size,iters in [(8,500000),(64,500000),(4096,100000),(65536,10000)]:
 src=a.output/(str(size)+'.prg');src.write_text('function Main()\nlocal s:=Replicate("A",'+str(size)+')\nlocal r:=Replicate("B",'+str(size)+')\nlocal i:=0\nlocal t:=0\nfor i:=1 to '+str(iters)+'\nr:=SubStr(s,1,'+str(size)+')\nt:=t+Len(r)+Asc(r)\nnext\n? t\nreturn nil\n')
 exes={};samples={'baseline':[],'candidate':[]};expected=None
 for key,cc in [('baseline',a.baseline),('candidate',a.compiler)]:
  exe=a.output/(str(size)+'-'+key);q=subprocess.run([str(cc),str(src),str(exe)],capture_output=True);assert q.returncode==0,q.stderr;exes[key]=exe
 for rep in range(9):
  for key in (['baseline','candidate'] if rep%2==0 else ['candidate','baseline']):
   start=time.perf_counter_ns();q=subprocess.run([str(exes[key])],capture_output=True,timeout=60);ns=(time.perf_counter_ns()-start)/iters
   assert(q.returncode,q.stderr)==(0,b''),q.stderr
   if expected is None:expected=q.stdout
   assert q.stdout==expected,(key,q.stdout,expected)
   samples[key].append(ns)
 for exe in exes.values():exe.unlink()
 row=dict(bytes=size,iterations=iters,samples_ns=samples,medians_ns={k:statistics.median(v) for k,v in samples.items()});rows.append(row);print(row,flush=True)
(a.output/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
