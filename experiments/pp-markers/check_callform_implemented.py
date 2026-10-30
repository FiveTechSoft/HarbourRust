#!/usr/bin/env python3
"""Fresh own-source call-form translation oracle,not arbitrary grammar proof."""
import pathlib,json,subprocess,re,argparse
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).parent;rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\'[^\'\n]*\'|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)
probes=json.loads((root/'callform-gap-20261030/results.json').read_text())['rows']+json.loads((root/'callform-gap-20261030/extra.json').read_text())
for r in probes:
 f=out/(str(r['case'])+'.prg');f.write_text(r['source']);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';assert ref.returncode==r['reference_exit']and tok(expected)==tok(r['reference_output']),(r['case'],'reference drift');assert o.returncode==ref.returncode,(r['case'],o.stderr)
 if ref.returncode:assert 'unknown result marker'in o.stderr or 'translation expansion too deep'in o.stderr
 else:assert tok(o.stdout)==tok(expected),(r['case'],o.stdout,expected)
 rows.append({'case':r['case'],'own_exit':o.returncode,'own_output':o.stdout,'comparison':'definition/recursion rejection'if ref.returncode else'matched token stream'})
(out/'results.json').write_text(json.dumps({'scope':'108own-source call-form checks,including invalid-result and recursion boundaries;not runtime or arbitrary translation coverage.','rows':rows},indent=2)+'\n');print('108call-form boundaries PASS')
