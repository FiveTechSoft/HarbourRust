#!/usr/bin/env python3
import argparse,pathlib,json,subprocess
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).parent/'escape-literals-20261031';rows=[]
for n,r in enumerate(json.loads((root/'stringify.json').read_text())):
 f=out/f'case{n}.prg';f.write_text(r['source']);p=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True);expected=f.with_suffix('.ppo').read_text();o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True);assert p.returncode==o.returncode==0 and o.stdout.strip()==expected.strip(),(n,expected,o.stdout,o.stderr);rows.append({'case':n,'exact_pp':True,'output':o.stdout})
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('12stringify literal-boundary outputs exact Harbour')
