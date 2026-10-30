#!/usr/bin/env python3
"""Own black-box observations of <-m->; no production mutation."""
import argparse,pathlib,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
cases=[]
for directive in ['command','xcommand','translate','xtranslate']:
 for pattern,inputs in [('PROBE [<m: META>]',['PROBE','PROBE META']),('PROBE <m>',['PROBE alpha','PROBE .F.','PROBE 0','PROBE ""']),('PROBE [META <!m!>] <!n!>',['PROBE alpha','PROBE META beta alpha'])]:
  for result in ['OUT( <-m-> yes )','OUT( [<-m-> yes] )']:
   for src in inputs:cases.append((directive,pattern,result,src))
 for result in ['OUT( [<-m-> yes] [<m>] )','OUT( <-m-> <.m.> )','OUT( <-M-> yes )','OUT( <-missing-> yes )']:
  cases.append((directive,'PROBE [<m: META>]',result,'PROBE META'))
for i,(directive,pat,result,src)in enumerate(cases):
 f=out/f'p{i:03}.prg';text=f'#{directive} {pat} => {result}\n{src}\n';f.write_text(text);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);ppo=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10)
 assert own.returncode==1 and 'unknown result marker'in own.stderr,(i,own.stderr)
 bad='<-M->'in result or '<-missing->'in result
 assert ref.returncode==(1 if bad else 0),(i,ref.stdout,ref.stderr)
 if not bad:assert 'OUT('in ppo and '<-'not in ppo,(i,ppo)
 rows.append({'case':i,'directive':directive,'pattern':pat,'result':result,'input':src,'source_sha256':hashlib.sha256(text.encode()).hexdigest(),'reference_exit':ref.returncode,'reference_preprocessed':ppo,'reference_diagnostic':(ref.stdout+ref.stderr).strip(),'own_exit':own.returncode,'own_diagnostic':own.stderr.strip()})
j={'reference':'694428e1c12f726675b19324d62167fa77d68185','own':'e9c7c0613452b4ccb312f1011ad05b32e9a5fa97','scope':'80own-source preprocessing observations of null result marker <-m->. No production change,program execution or whole-language claim.','rows':rows};(out/'results.json').write_text(json.dumps(j,indent=2)+'\n');print(len(rows),'null-result observations;own rejection unchanged')
