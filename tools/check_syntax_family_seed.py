#!/usr/bin/env python3
"""Verify the seed evidence matrix. It is not complete grammar coverage."""
import argparse,hashlib,json,pathlib,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--matrix',default='corpus/syntax-family-seed-b105ae0.json');a=p.parse_args();root=pathlib.Path(__file__).resolve().parents[1];d=json.loads((root/a.matrix).read_text());count=0
with tempfile.TemporaryDirectory(prefix='family-matrix-')as tmp:
 for family in d['families']:
  for case in family['cases']:
   path=root/case['file'];assert hashlib.sha256(path.read_bytes()).hexdigest()==case['sha256'],case['file']
   for profile,expected in case['profiles'].items():
    target,mode=profile.split('-');cmd=[str(pathlib.Path(a.compiler).resolve()),str(path),str(pathlib.Path(tmp)/('out.s'if mode=='default'else'out.ll')),'--target='+target,'-I',str(root/'tests')]+(['--experimental-llvm']if mode=='llvm'else[]);r=subprocess.run(cmd,capture_output=True,text=True,timeout=10);actual={'accepted':r.returncode==0,'exit':r.returncode,'diagnostic':r.stderr.strip().splitlines()[:1]};assert actual==expected,(case['file'],profile,actual,expected);count+=1
print(f'PASS {len(d["families"])} seed families, {count} compile-profile checks; no runtime/grammar-completeness claim')
