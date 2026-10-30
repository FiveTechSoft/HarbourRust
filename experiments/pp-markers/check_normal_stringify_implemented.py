#!/usr/bin/env python3
"""Scoped plain normal stringify;oracle gaps remain separately classified."""
import pathlib,json,subprocess,re,argparse
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).parent/'normal-stringify-gap-20261031';rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s)
for group in ['results','extra']:
 j=json.loads((root/(group+'.json')).read_text());j=j['rows']if isinstance(j,dict)else j
 for r in j:
  f=out/f'{group}{r["case"]}.prg';f.write_text(r['source']);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';assert(ref.returncode,expected)==(r['reference_exit'],r['reference_output']);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True)
  supported=(group=='results'and',...'not in r['pattern']and r['input']!='PROBE alpha, beta')or(group=='extra'and r['case']%10 in[0,1,2,3,4,6])
  if supported:
   assert own.returncode==ref.returncode,(r,own.stderr)
   if not ref.returncode:assert tok(own.stdout)==tok(expected),(r,own.stdout,expected)
   kind='scoped normal exact quoted contents or invalid marker identity'
  else:kind='outside slice observation'
  rows.append({'group':group,'case':r['case'],'kind':kind,'own_exit':own.returncode,'own_output':own.stdout,'own_error':own.stderr})
(out/'results.json').write_text(json.dumps({'scope':'plain normal stringify only;outside observations not passes','rows':rows},indent=2)+'\n');print({k:sum(r['kind']==k for r in rows)for k in sorted(set(r['kind']for r in rows))})
