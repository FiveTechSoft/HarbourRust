#!/usr/bin/env python3
"""Check existing own optional-identifier observations against hbpp."""
import json,pathlib,subprocess,re,argparse
p=argparse.ArgumentParser();p.add_argument("--hpp",required=True);p.add_argument("--hbpp",required=True);p.add_argument("--output-dir",required=True);a=p.parse_args()
b=pathlib.Path(a.output_dir).resolve();b.mkdir(parents=True,exist_ok=True);rows=json.load(open('experiments/pp-markers/repeated-smart-gap-20261031/results.json'))['rows'];rows=[dict(r)for r in rows if r['pattern']=='PROBE [<!x!>]'];good=0
for i,r in enumerate(rows):
 p=b/f'case{i}.prg';p.write_text(r['source']);h=subprocess.run([a.hbpp,str(p),'-q2'],capture_output=True,text=True);assert h.returncode==r['reference_exit'] and p.with_suffix('.ppo').read_text()==r['reference_output'];o=subprocess.run([a.hpp,str(p)],capture_output=True,text=True);tok=lambda s:re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s);r.update(own_exit=o.returncode,own_output=o.stdout,own_error=o.stderr,token_match=o.returncode==r['reference_exit']==0 and tok(o.stdout)==tok(r['reference_output']));good+=r['token_match']
 if not r['token_match']:print(r['source'].replace('\n',' / '),repr(r['reference_output']),repr(o.stdout),repr(o.stderr))
(b/'results.json').write_text(json.dumps({'scope':'80own optional identifier group cases,candidate only','rows':rows},indent=2)+'\n');print(good,'/',len(rows));assert good==len(rows)
