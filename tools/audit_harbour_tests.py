#!/usr/bin/env python3
"""Compile-only audit. Never links or executes original Harbour programs."""
import argparse,hashlib,json,pathlib,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--core',required=True);p.add_argument('--compiler',required=True);p.add_argument('--compiler-sha',required=True);p.add_argument('--reference',required=True);p.add_argument('--output',required=True);a=p.parse_args();root=pathlib.Path(a.core).resolve();compiler=str(pathlib.Path(a.compiler).resolve());rows=[]
with tempfile.TemporaryDirectory(prefix='harbour-audit-')as tmp:
 for path in sorted((root/'tests').rglob('*.prg')):
  row={'file':path.relative_to(root).as_posix(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
  for target in ['linux','windows']:
   for mode in ['current','llvm']:
    key=mode+('_windows'if target=='windows'else'');out=pathlib.Path(tmp)/(key+('.s'if mode=='current'else'.ll'));cmd=[compiler,str(path),str(out),'--target='+target,'-I',str(root/'include')]+(['--experimental-llvm']if mode=='llvm'else[])
    try:
     r=subprocess.run(cmd,capture_output=True,text=True,timeout=10);row[key]={'compiled':r.returncode==0,'exit':r.returncode,'diagnostic':r.stderr.strip().splitlines()[:1]}
    except subprocess.TimeoutExpired:row[key]={'compiled':False,'exit':'timeout','diagnostic':['compiler timeout10s']}
  rows.append(row)
result={'reference':a.reference,'compiler':a.compiler_sha,'scope':'all .prg recursively under tests; Linux and Windows target profiles','execution':'compilation only; no linking, execution or runtime validation','include_policy':'reference include/; no full std.ch auto-import or adaptations','platform_caveats':{'tests/dynwin.prg':'Linux excludes Windows-only dynamic DLL/GUI body. Acceptance is not dynamic DLL support.'},'rows':rows};pathlib.Path(a.output).write_text(json.dumps(result,indent=2)+'\n')
for target,keys in [('linux',['current','llvm']),('windows',['current_windows','llvm_windows'])]:print(target,len(rows),{k:sum(r[k]['compiled']for r in rows)for k in keys})
