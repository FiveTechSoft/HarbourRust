#!/usr/bin/env python3
"""Strict repeated th11b timeout control. External Harbour oracle uses -mt."""
from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser(description=__doc__)
for n in ['compiler','hbmk2','output']:p.add_argument('--'+n,type=Path,required=True)
p.add_argument('--repeats',type=int,default=30)
a=p.parse_args();assert a.repeats>=10
a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
a.compiler=a.compiler.resolve();a.hbmk2=a.hbmk2.resolve()
src=Path(__file__).with_name('programs')/'th11b_wait_to.prg'
expected=b'\ntimeout          0\nafter-join'
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,label,timeout=30):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=timeout,stdin=subprocess.DEVNULL)
 for k,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(a.output/(label+'.'+k)).write_bytes(v)
 return q
rows=[]
for mode,cmd in [('oracle',[a.hbmk2,src,'-quiet','-mt','-gtstd','-w0','-o'+str(a.output/'oracle')]),('int',[a.compiler,src,a.output/'int','--target=linux']),('ext',[a.compiler,src,a.output/'ext','--target=linux','--external-as'])]:
 q=run(cmd,mode+'-build');assert q.returncode==0,(mode,q)
 binary=a.output/mode;binary_sha=h(binary)
 for i in range(a.repeats):
  q=run([binary],mode+'-'+str(i));assert (q.returncode,q.stdout,q.stderr)==(0,expected,b''),(mode,i,q)
  rows.append(dict(mode=mode,iteration=i,rc=q.returncode,stdout_sha256=hashlib.sha256(q.stdout).hexdigest(),stderr_empty=True,binary_sha256=binary_sha))
 binary.unlink()
 print(mode,a.repeats,'strict passes',flush=True)
(a.output/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),oracle_sha256=h(a.hbmk2),source_sha256=h(src),runner_sha256=h(Path(__file__)),scope='Strict rc0/fullstdout/emptystderr repeated external Harbour-mt and Linux internal/external assembler. No timing thresholds widened;mutex ownership keeps worker pending during timed wait. Not native Mac execution.',rows=rows),indent=2))
