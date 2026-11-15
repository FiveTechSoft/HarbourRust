#!/usr/bin/env python3
"""Build B1 isolated gates from repository sources and a supplied hbc binary."""
from pathlib import Path
import os,subprocess,shutil,hashlib,argparse
p=argparse.ArgumentParser();g=p.add_mutually_exclusive_group(required=True);g.add_argument('--compiler',type=Path);g.add_argument('--emitted-dir',type=Path);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
a.output.mkdir(parents=True,exist_ok=False);out=a.output.resolve();(out/'runtime').mkdir();(out/'tests').mkdir();(out/'real').mkdir()
for name in ['hrmemvar.c','hrmemvar.h','hrmembridge.c','hrmembridge.h','hrvalue.h','hrdbf.h','hrdyn.h']:shutil.copyfile(ROOT/'runtime'/name,out/'runtime'/name)
shutil.copyfile(HERE/'bridge-client.c',out/'tests/bridge-client.c');shutil.copyfile(ROOT/'tests/memvar/storage-client.c',out/'tests/storage-regression.c')
s=(out/'tests/storage-regression.c').read_text().replace('../../runtime/hrmemvar.h','../runtime/hrmemvar.h').replace('i==4||i==9','i==4||i==5||i==9');(out/'tests/storage-regression.c').write_text(s)
for name in ['client.c','make-runtime.py','make-abi.py','template.prg']:shutil.copyfile(HERE/'real'/name,out/'real'/name)
for target in ['linux','windows']:
 if a.emitted_dir:
  shutil.copyfile(a.emitted_dir/(target+'.s'),out/'real'/(target+'.s'));continue
 q=subprocess.run([str(a.compiler.resolve()),str(out/'real/template.prg'),str(out/'real'/(target+'.s')),'--target='+target],capture_output=True);(out/'real'/(target+'-emit.stdout')).write_bytes(q.stdout);(out/'real'/(target+'-emit.stderr')).write_bytes(q.stderr);assert q.returncode==0
shutil.copytree(HERE/'oracle',out/'oracle');shutil.copyfile(HERE/'reproduce.sh',out/'reproduce.sh')
if a.compiler:(out/'compiler.sha256').write_text(hashlib.sha256(a.compiler.read_bytes()).hexdigest()+'\n')
else:(out/'EMISSION_SOURCE.txt').write_text('Reused supplied emitted assembly, no compiler re-emission.\n')
subprocess.run(['bash',str(out/'reproduce.sh')],check=True,cwd=out)
