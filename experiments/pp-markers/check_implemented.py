#!/usr/bin/env python3
"""Own-source oracle of scoped identifier/wildcard markers; no runtime needed."""
import argparse,pathlib,subprocess,re,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
values=['Alpha','A_2','1','12abc','a + b','(a)','"abc"','','a,b','a:b','a.b','alpha beta','a[1]','é','_x']
cases=[]
for directive in ['command','xcommand','translate','xtranslate']:
 for marker,suffix in [('<!x!>',' STOP'),('<*x*>',' STOP'),('<*x*>','')]:
  for val in values:cases.append((directive,'PROBE '+marker+suffix,'OUT( <x> )','PROBE '+val+suffix))
for pattern,source in [('PROBE [<!x!>]','PROBE'),('PROBE [<!x!>]','PROBE alpha beta'),('PROBE [<!x!>] STOP','PROBE alpha STOP'),('PROBE [<!x!>] <!y!>','PROBE alpha beta'),('PROBE [WORD <!x!>]','PROBE WORD alpha WORD beta'),('PROBE [<*x*>]','PROBE'),('PROBE [<*x*>]','PROBE a + b'),('PROBE <*x*> [STOP]','PROBE alpha STOP'),('PROBE <!x!> <!y!>','PROBE alpha beta'),('PROBE <!x!> <!y!>','PROBE alpha 1')]:cases.append(('xcommand',pattern,'OUT( [<x>] )',source))
def tokens(s):
 # Compare token streams, retaining exact quoted strings; the engines format
 # token whitespace differently. No source/runtime output normalization claim.
 return re.findall(r'"[^"\n]*"|\'[^\'\n]*\'|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)
for i,(directive,pattern,result,source) in enumerate(cases):
 f=out/f'probe{i:03}.prg';text=f'#{directive} {pattern} => {result}\nPROCEDURE Main()\n{source}\nRETURN\n';f.write_text(text);ref=subprocess.run([str(pathlib.Path(a.hbpp).resolve()),str(f),'-q2'],capture_output=True,text=True,timeout=10);assert ref.returncode==0,(i,ref.stderr);expected=f.with_suffix('.ppo').read_text();own=subprocess.run([str(pathlib.Path(a.hpp).resolve()),str(f)],capture_output=True,text=True,timeout=10);matched='OUT(' in expected
 if matched:assert own.returncode==0 and tokens(own.stdout)==tokens(expected),(i,text,expected,own.stderr,own.stdout)
 else:assert own.returncode==1 and 'incomplete statement' in own.stderr,(i,text,own.stderr,own.stdout)
 rows.append({'case':i,'directive':directive,'pattern':pattern,'input':source,'source_sha256':hashlib.sha256(text.encode()).hexdigest(),'reference_rule_matched':matched,'own_preprocess_exit':own.returncode,'comparison':'matched token stream including quoted bytes'if matched else'nonmatch;own stricter incomplete-command diagnostic,reference leaves source unchanged'})
j={'scope':'190 own-source preprocessor-only probes. No runtime program execution. Matched token streams,not whitespace-identical ppo. Nonmatches retain existing diagnostic difference. Not full marker grammar or class/driver support.','rows':rows};(out/'results.json').write_text(json.dumps(j,indent=2)+'\n');print(f'{len(rows)} own/reference marker boundaries PASS')
