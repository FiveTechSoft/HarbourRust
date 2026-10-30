#!/usr/bin/env python3
"""Replay pinned own logical-result probes; distinguish preexisting matcher gaps."""
import argparse,pathlib,subprocess,json,re
p=argparse.ArgumentParser();p.add_argument('--hpp',required=True);p.add_argument('--before',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).resolve().parent;rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\'[^\'\n]*\'|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)
for r in json.loads((root/'logical-result-gap-20261030/results.json').read_text())['rows']:
 f=out/f'p{r["case"]:03}.prg';text=f'#{r["directive"]} {r["pattern"]} => {r["result"]}\n{r["input"]}\n';f.write_text(text);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10)
 if r['reference_exit']==1:
  assert own.returncode==1 and 'unknown result marker'in own.stderr,(r['case'],own.stderr);comparison='definition rejection matches reference'
 elif 'OUT('not in r['reference_preprocessed']:
  # Two ordinary optional-identifier cases mismatch before this increment.
  plain=out/f'plain{r["case"]:03}.prg';plain.write_text(text.replace('<.m.>','<m>'));old=subprocess.run([a.before,str(plain)],capture_output=True,text=True,timeout=10)
  assert old.returncode==0 and 'OUT('in old.stdout and own.returncode==0 and '.T.'in own.stdout
  comparison='preexisting optional-identifier matcher divergence;not a matching pass'
 else:
  assert own.returncode==0 and tok(own.stdout)==tok(r['reference_preprocessed']),(r['case'],own.stdout,own.stderr,r['reference_preprocessed']);comparison='matched logical result token stream'
 rows.append({'case':r['case'],'comparison':comparison,'own_exit':own.returncode,'own_preprocessed':own.stdout,'reference_preprocessed':r['reference_preprocessed']})
j={'scope':'Replay90own logical-result characterization rows.88matched result/validation checks;2explicit preexisting matcher divergences are not passes. No arbitrary lexical reemission claim.','rows':rows};(out/'results.json').write_text(json.dumps(j,indent=2)+'\n');print('88 logical-result/validation checks PASS;2preexisting matching divergences preserved')
