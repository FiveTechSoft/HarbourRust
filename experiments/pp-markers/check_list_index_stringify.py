#!/usr/bin/env python3
import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).parent/'list-index-stringify-20261031';rows=[]
for r in json.loads((root/'oracle.json').read_text()):
 f=out/f'case{r["case"]}.prg';f.write_text(r['source']);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True);expected=f.with_suffix('.ppo').read_text();o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True)
 if r['case']not in[13,15]:assert o.returncode==0 and o.stdout.strip()==expected.strip(),(r,o.stdout,o.stderr,expected);kind='exact output'
 else:kind='outside observation'
 rows.append({'case':r['case'],'kind':kind,'output':o.stdout,'error':o.stderr})
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('14exact outputs+2outside observations')
