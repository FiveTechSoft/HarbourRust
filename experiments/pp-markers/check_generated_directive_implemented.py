#!/usr/bin/env python3
"""Own generated-command probes: fresh reference versus implemented slice."""
import pathlib,json,subprocess,re,argparse
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[2];out=pathlib.Path(a.output_dir).resolve();out.mkdir(exist_ok=True);j=json.load(open(root/'experiments/pp-markers/generated-directive-gap-20261030/results.json'));rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\'[^\'\n]*\'|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)
for r in j['rows']+j['timing']:
 f=out/(str(r['case'])+'.prg');f.write_text(r['source']);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else''
 assert ref.returncode==r['reference_exit']and tok(expected)==tok(r['reference_preprocessed']),(r['case'],'reference drift')
 if ref.returncode:ok=own.returncode==1 and 'unknown result marker'in own.stderr
 else:ok=own.returncode==0 and tok(own.stdout)==tok(expected)
 if not ok:print('FAIL',r['case'],r.get('form'),repr(own.stdout),repr(own.stderr),repr(expected))
 rows.append({'case':r['case'],'pass':ok,'own_exit':own.returncode,'own_preprocessed':own.stdout,'own_diagnostic':own.stderr})
print(sum(r['pass']for r in rows),'generated-directive boundaries verified;success output tokens match reference;invalid definitions reject');(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n')

assert all(r["pass"]for r in rows)
