#!/usr/bin/env python3
"""Check scoped iteration controls and deliberate historical fallbacks."""
import argparse,pathlib,subprocess,json,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
tok=lambda s:re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s)
base=pathlib.Path(__file__).parent/'identifier-iterations-20261031'
for name in ['family-guard12.json','removal-nested4.json']:
 for r in json.loads((base/name).read_text()):
  f=out/f'case{len(rows)}.prg';f.write_text(r['source']);h=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True);ref=f.with_suffix('.ppo').read_text();assert ref==r['reference_output'],(r['source'],ref,r['reference_output']);o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True)
  if r['historical_identical']:
   assert (o.returncode,o.stdout,o.stderr)==(r['own_exit'],r['own_output'],r['own_error']),(r['source'],o)
  else:
   assert h.returncode==o.returncode==0 and tok(o.stdout)==tok(ref),(r['source'],ref,o.stdout,o.stderr)
  rows.append(dict(source=r['source'],historical_fallback=r['historical_identical'],reference_output=ref,own_exit=o.returncode,own_output=o.stdout,own_error=o.stderr))
(out/'results.json').write_text(json.dumps({'scope':'16family/removal/nested/literal controls;fallback is not Harbour compatibility','rows':rows},indent=2)+'\n');print(len(rows),'family guard controls PASS')
