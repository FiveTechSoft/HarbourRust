#!/usr/bin/env python3
import pathlib,json,subprocess,re,argparse
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).parent/'list-stringify-gap-20261031';rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s)
for group in ['results','extra']:
 j=json.loads((root/(group+'.json')).read_text());j=j['rows']if isinstance(j,dict)else j
 for r in j:
  f=out/f'{group}{r["case"]}.prg';f.write_text(r['source']);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';assert(ref.returncode,expected)==(r['reference_exit'],r['reference_output']);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True)
  supported=('['not in r['input']and'e"'not in r['input'])if group=='results'else r['case']%10 not in [5,8,9]
  if supported:assert own.returncode==0 and tok(own.stdout)==tok(expected),(group,r,own.stdout,own.stderr,expected);kind='supported exact quoted contents'
  else:kind='outside slice observation'
  rows.append({'group':group,'case':r['case'],'kind':kind,'own_exit':own.returncode,'own_output':own.stdout,'own_error':own.stderr})
(out/'results.json').write_text(json.dumps({'scope':'list captures only,no general pp proof','rows':rows},indent=2)+'\n');print({k:sum(r['kind']==k for r in rows)for k in sorted(set(r['kind']for r in rows))})
