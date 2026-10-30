#!/usr/bin/env python3
"""Replay own-source keyword overlap/nonmatch observations with fresh oracle."""
import argparse,pathlib,json,subprocess,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);j=json.loads((pathlib.Path(__file__).parent/'nonmatch-20261030/observations.json').read_text());rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\'[^\'\n]*\'|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)
for r in j['rows']:
 f=out/f'p{r["case"]}.prg';f.write_text(r['source']);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);expected=f.with_suffix('.ppo').read_text();assert ref.returncode==0 and tok(expected)==tok(r['reference_output']);assert o.returncode==0
 if r['case']in [23,31]:assert tok(o.stdout)==tok('CHOOSE FROM extra');comparison='preexisting translate-prefix divergence,not fixed/not pass'
 else:assert tok(o.stdout)==tok(expected),(r['case'],o.stdout,expected);comparison='reference token stream matched'
 rows.append({'case':r['case'],'comparison':comparison,'own_output':o.stdout})
(out/'results.json').write_text(json.dumps({'scope':'30matched checks plus2preexisting translate-prefix divergences,not32passes.','rows':rows},indent=2)+'\n');print('30nonmatch/match token checks PASS;2preexisting prefix divergences preserved')
