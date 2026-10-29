#!/usr/bin/env python3
import argparse,pathlib,json,hashlib,subprocess
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();root=pathlib.Path(__file__).resolve().parents[1];j=json.loads((root/'corpus/syntax-supplementary-regressions-e71b0ed.json').read_text());out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);compiler=str(pathlib.Path(a.compiler).resolve());manifest=(root/'tests/manifest.txt').read_text().splitlines()
for row in j['cases']:
 f=root/row['file'];assert hashlib.sha256(f.read_bytes()).hexdigest()==row['sha256'];assert any(x.startswith(row['manifest_kind']+' '+row['file']+' ')for x in manifest)
 lines=f.read_text().splitlines()
 for w in row['witnesses']:assert w['lines']==[i+1for i,line in enumerate(lines)if w['symbol_or_construct']in line]
 for profile,want in row['compile_profiles'].items():
  target,mode=profile.split('-');r=subprocess.run([compiler,str(f),str(out/'trial'),'--target='+target]+(['--experimental-llvm']if mode=='llvm'else[]),capture_output=True,text=True,timeout=10);assert {'accepted':r.returncode==0,'exit':r.returncode,'diagnostic':r.stderr.strip().splitlines()[:1]}==want,(f,profile,r.stderr)
print('PASS supplementary7sources/28compileprofiles;no runtime execution')
