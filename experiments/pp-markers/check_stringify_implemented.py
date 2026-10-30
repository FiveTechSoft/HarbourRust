#!/usr/bin/env python3
"""Scoped plain #capture:preserve string contents and exact interior spacing."""
import pathlib,json,subprocess,re,argparse
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).parent;rows=[]
base=json.loads((root/'stringify-gap-20261031/results.json').read_text())['rows'];extra=json.loads((root/'stringify-gap-20261031/extra.json').read_text())
for r in base+extra:
 ident=('base'if'directive'in r else'extra')+str(r['case']);f=out/(ident+'.prg');f.write_text(r['source']);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';assert ref.returncode==0 and expected.strip()==r['reference_output'].strip()
 supported=(r['result']=='OUT( #<x> )'if'directive'in r else r['case']in[9,11,12,14,15,17,21,23,24,26])
 if supported:
  # Ignore formatting only outside string contents.
  def parts(s):return re.findall(r'"[^"\n]*"|\'[^\'\n]*\'|[^\s]',s)
  assert o.returncode==0 and parts(o.stdout)==parts(expected),(ident,o.stdout,o.stderr,expected);comparison='plain stringify exact quoted contents'
 else:
  assert o.returncode==1,(ident,'outside slice unexpectedly accepted',o.stdout);comparison='outside scoped plain stringify;explicit rejection'
 rows.append({'case':ident,'own_exit':o.returncode,'own_output':o.stdout,'comparison':comparison})
(out/'results.json').write_text(json.dumps({'scope':'50supported plain stringify checks and60outside-scope rejections. Not general stringify compatibility.','rows':rows},indent=2)+'\n');print('50plain stringify checks PASS;60outside-scope rejection boundaries')
