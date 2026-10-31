#!/usr/bin/env python3
import pathlib,json,subprocess,argparse,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).parent/'macro-arguments-20261031';rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s)
for group in ['results','param']:
 j=json.loads((root/(group+'.json')).read_text());j=j['rows']if isinstance(j,dict)else j
 for r in j:
  f=out/f'{group}{r["case"]}.prg';f.write_text(r['source']);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';assert(ref.returncode,expected)==(r['reference_exit'],r['reference_output']);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True)
  supported=r['case']in[0,1,2,3,4,8,10,11,12,13,17,18]if group=='results'else r['case']in[0,1,2,4]
  if supported:assert own.returncode==0 and tok(own.stdout)==tok(expected),(r,own.stdout,own.stderr);kind='supported exact tokens'
  else:kind='outside-slice observation:empty/wrong arity/bracket literal/malformed'
  rows.append({'group':group,'case':r['case'],'kind':kind,'own_exit':own.returncode,'own_output':own.stdout,'own_error':own.stderr})
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('16supported exact checks,9outside observations')
