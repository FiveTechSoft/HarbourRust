#!/usr/bin/env python3
"""Own-source end-to-end probes for older token emission gaps,no fixes."""
import argparse,pathlib,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--hbmk2',required=True);p.add_argument('--before',required=True);p.add_argument('--current',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
cases=[('logical','#xcommand PROBE <x> => ? <x>\nprocedure main()\nPROBE .T.\nreturn\n','unterminated dotted word'),('stringify','#xcommand PROBE <x> => ? #<x>\nprocedure main()\nPROBE alpha + 1\nreturn\n','')]
for name,text,diag in cases:
 d=out/name;d.mkdir(exist_ok=True);src=d/'probe.prg';src.write_text(text);exe=d/'reference';r=subprocess.run([str(pathlib.Path(a.hbmk2).resolve()),str(src),'-q','-gtstd','-o'+str(exe)],cwd=d,capture_output=True,text=True,timeout=30);assert r.returncode==0,(name,r.stderr,r.stdout);r=subprocess.run([str(exe)],capture_output=True,timeout=5);assert r.returncode==0 and r.stderr==b'';results={}
 for label,compiler in [('before',a.before),('current',a.current)]:
  for backend in ['default','llvm']:
   r2=subprocess.run([str(pathlib.Path(compiler).resolve()),str(src),str(d/(label+backend+'.out'))]+(['--experimental-llvm']if backend=='llvm'else[]),capture_output=True,text=True,timeout=10);assert r2.returncode==1,(name,label,backend,r2.stderr);assert not diag or diag in r2.stderr;results[label+'-'+backend]={'compile_exit':r2.returncode,'diagnostic':r2.stderr.strip().splitlines()[:1]}
 rows.append({'case':name,'source_sha256':hashlib.sha256(text.encode()).hexdigest(),'reference_exit':r.returncode,'reference_stdout_hex':r.stdout.hex(),'own_results':results})
j={'before':'89f3ead production77f972a','current':'e71b0ed','scope':'Two own-source end-to-end reference programs. Reference run safe console only. Both own backends reject before and after marker increment;preexisting gaps,not fixed. Exact stdout bytes retained as hex;token-stream-only comparison is insufficient for lexical adjacency. No original reference sources executed.','rows':rows};(out/'results.json').write_text(json.dumps(j,indent=2)+'\n');print('PASS2reference runs;8expected preexisting compile rejections')
