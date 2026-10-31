#!/usr/bin/env python3
"""Own narrow probes: identifier/restricted/wildcard stringify, not parenthesis."""
import argparse,pathlib,subprocess,json,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
def tokens(s):return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s)
def probe(text,kind):
 f=out/f'case{len(rows)}.prg';f.write_text(text);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else''
 assert ref.returncode==0,(text,ref.stderr)
 assert own.returncode==0 and tokens(own.stdout)==tokens(expected),(text,own.stdout,own.stderr,expected)
 rows.append(dict(source=text,kind=kind,reference_output=expected,own_output=own.stdout))
for directive in ['command','xcommand','translate','xtranslate']:
 for pattern,inputs in [('<!x!>',['alpha','alpha_2','123']),('<x:alpha,beta>',['alpha','BETA','gamma']),('<*x*>',['alpha + beta','"a  b"',''])]:
  for result in ['#<x>','<"x">']:
   for value in inputs:probe(f'#{directive} PROBE {pattern} => OUT({result})\nPROBE {value}\n','matched or preserved nonmatch')
 for pattern,value in [('<!x!>','alpha'),('<x:alpha,beta>','BETA'),('<*x*>','alpha+beta')]:
  for result in ['#<x>','<"x">']:
   for source in ['PROBE','PROBE '+value]:probe(f'#{directive} PROBE [{pattern}] => OUT({result})\n{source}\n','optional capture present or absent')
 for value in ['alpha  +  beta','a[1,2] + b','f(1,2), "a  b"','a[1,2], b','a,,b',',a,']:
  for result in ['#<x>','<"x">']:probe(f'#{directive} PROBE <*x*> => OUT({result})\nPROBE {value}\n','wildcard exact interior spacing')
(out/'results.json').write_text(json.dumps({'scope':'existing identifier/restricted/wildcard stringify;no parenthesis or repeated/disjoint claim','rows':rows},indent=2)+'\n');print(len(rows),'scoped token/content checks PASS')
