#!/usr/bin/env python3
"""Own repeated-result grouping probes. No matcher implementation copied."""
import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
for directive in ['command','xcommand','translate','xtranslate']:
 for pattern,inputs in [('PROBE [<!x!>]',['','alpha','alpha beta','alpha beta gamma']),('PROBE <!x!> [,<!y!>]',['alpha','alpha,beta','alpha,beta,gamma']),('PROBE [KEY <!x!> VALUE <y>]',['','KEY alpha VALUE 1','KEY alpha VALUE 1 KEY beta VALUE 2']),('PROBE [<x:alpha,beta>]',['','alpha','alpha beta','alpha beta alpha'])]:
  for result in ['OUT(<(x)>)','OUT([<(x)>])','OUT([<(x)>,])','OUT(<x>)','OUT([<x>])']:
   for value in inputs:
    text=f'#{directive} {pattern} => {result}\n{value if value.startswith("PROBE") else "PROBE "+value}\n';f=out/f'case{len(rows)}.prg';f.write_text(text);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);rows.append(dict(source=text,directive=directive,pattern=pattern,result=result,input=value,reference_exit=ref.returncode,reference_output=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'',reference_error=ref.stderr,own_exit=own.returncode,own_output=own.stdout,own_error=own.stderr))
(out/'results.json').write_text(json.dumps({'scope':'280own characterization observations;not compatibilitypasses','rows':rows},indent=2)+'\n');print(len(rows),'observations')
for r in rows[:40]:print(r['source'].replace('\n',' / '),'=>',repr(r['reference_output']),';own',repr(r['own_output']),repr(r['own_error']))
