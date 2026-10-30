#!/usr/bin/env python3
"""Own-source stringify observations;quoted bytes cannot be normalized away."""
import pathlib,subprocess,json,argparse
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args()
out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
for directive in ['command','xcommand','translate','xtranslate']:
 for value in ['alpha','a + 1','alpha(1, 2)','.T.','"hello"',"'hello'",'"a" + \'b\'','a:=1','alpha[1]','a  +   b']:
  for result in ['OUT( #<x> )','OUT( <"x"> )']:
   i=len(rows);text=f'#{directive} PROBE <x> => {result}\nPROBE {value}\n';p=out/f'p{i}.prg';p.write_text(text);r=subprocess.run([a.hbpp,str(p),'-q2'],capture_output=True,text=True,timeout=10);o=subprocess.run([a.hpp,str(p)],capture_output=True,text=True,timeout=10);rows.append({'case':i,'directive':directive,'value':value,'result':result,'source':text,'reference_exit':r.returncode,'reference_output':p.with_suffix('.ppo').read_text()if p.with_suffix('.ppo').exists()else'','reference_error':r.stdout+r.stderr,'own_exit':o.returncode,'own_output':o.stdout,'own_error':o.stderr})
(out/'results.json').write_text(json.dumps({'scope':'80own-source preprocessing stringify observations,no runtime.','rows':rows},indent=2)+'\n')
assert len(rows)==80 and all(r['reference_exit']==0 for r in rows)
print('80stringify observations;no production change')
