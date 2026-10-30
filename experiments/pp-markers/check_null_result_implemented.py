#!/usr/bin/env python3
"""Replay own-source null-result observations, no original programs executed."""
import argparse,pathlib,json,subprocess,re
p=argparse.ArgumentParser();p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).resolve().parent;rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\'[^\'\n]*\'|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)
for r in json.loads((root/'null-result-gap-20261030/results.json').read_text())['rows']:
 f=out/f'p{r["case"]:03}.prg';f.write_text(f'#{r["directive"]} {r["pattern"]} => {r["result"]}\n{r["input"]}\n');o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10)
 if r['reference_exit']:assert o.returncode==1 and 'unknown result marker'in o.stderr
 else:assert o.returncode==0 and tok(o.stdout)==tok(r['reference_preprocessed']),(r['case'],o.stdout,r['reference_preprocessed'],o.stderr)
 rows.append({'case':r['case'],'own_exit':o.returncode,'own_preprocessed':o.stdout,'comparison':'definition rejection'if r['reference_exit']else'matched token stream'})
(out/'results.json').write_text(json.dumps({'scope':'80own-source null-result oracle checks;token equality not arbitrary reemission proof.','rows':rows},indent=2)+'\n');print('80null-result checks PASS')
