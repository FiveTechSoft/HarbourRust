#!/usr/bin/env python3
"""Run on a real Intel Mac. Does not edit the workflow or its sample."""
from pathlib import Path
import argparse,subprocess,platform,json,hashlib,sys
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();assert sys.platform=='darwin' and platform.machine()=='x86_64','native Intel Mac required';repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(exist_ok=False);cc=Path(a.compiler).resolve();wf=(repo/'.github/workflows/macos.yml').read_text();sample=wf.split("<<'PRG'\n")[1].split('\n          PRG')[0];src=out/'macos.prg';src.write_text('\n'.join(x[10:] for x in sample.splitlines())+'\n');rows=[]
def run(cmd,label):
 r=subprocess.run(list(map(str,cmd)),cwd=out,capture_output=True,timeout=60)
 for ext,b in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(out/(label+'.'+ext)).write_bytes(b)
 rows.append(dict(step=label,rc=r.returncode));assert r.returncode==0,(label,r.stdout,r.stderr)
 return r
run([cc,'macos.prg','program.ll','--target=linux','--experimental-llvm'],'emit')
run(['clang','-target','x86_64-apple-macos14','-c','program.ll','-o','program.o'],'assemble')
run(['clang','-target','x86_64-apple-macos14','program.o','program.ll.runtime.s','-o','smoke'],'link')
r=run(['./smoke'],'execute');assert r.stdout==b'\nhello\nsoma         15\nfatorial    3628800' and not r.stderr
report=dict(scope='Native macOS Intel, unchanged feasibility sample, with clang architecture x86_64 instead of arm64 (workflow remains unchanged). Not a general LLVM/Harbour parity claim.',compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),workflow_sha256=hashlib.sha256(wf.encode()).hexdigest(),source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),platform=platform.platform(),rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));print('NATIVE Intel smoke exact')
