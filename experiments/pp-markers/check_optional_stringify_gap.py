#!/usr/bin/env python3
"""Own optional/stringify behavioral probes;no reference implementation copied."""
import argparse,pathlib,subprocess,json,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
for directive in ['command','xcommand','translate','xtranslate']:
 for pattern in ['PROBE [WORD <x>]','PROBE <x> [TAIL <y>]','PROBE [WORD <x:alpha,beta>]']:
  for result in ['OUT( #<x> )','OUT( [#<x>] )','OUT( <x> )','OUT( [<x>] )']:
   for source in ['PROBE','PROBE WORD alpha','PROBE WORD alpha WORD beta','PROBE alpha TAIL beta']:
    n=len(rows);text=f'#{directive} {pattern} => {result}\n{source}\n';f=out/f'case{n}.prg';f.write_text(text);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else''
    def tokens(s):return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s)
    rows.append({'case':n,'source':text,'reference_exit':ref.returncode,'reference_output':expected,'reference_error':ref.stderr,'own_exit':own.returncode,'own_output':own.stdout,'own_error':own.stderr,'exact_tokens':ref.returncode==own.returncode==0 and tokens(expected)==tokens(own.stdout)})
(out/'results.json').write_text(json.dumps({'scope':'192characterization observations;not192compatibility passes','rows':rows},indent=2)+'\n');print(len(rows),'observations',sum(r['exact_tokens']for r in rows),'token matches',sum(r['own_exit']!=0 for r in rows),'explicit rejections')
