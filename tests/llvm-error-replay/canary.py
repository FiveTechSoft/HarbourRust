#!/usr/bin/env python3
"""Own MIT: fixed existing trace intern/update canary, emission-only both targets."""
from pathlib import Path
import subprocess,re,hashlib,json,argparse
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();r=Path(__file__).resolve().parents[2];base=r/'experiments/llvm-scalar';d=Path(a.output).resolve();d.mkdir();cc=str(Path(a.compiler).resolve());rows=[];manifest=json.loads((base/'trace-interning-canary.json').read_text());(d/'canary.json').write_text(json.dumps(manifest,indent=2)+'\n')
for case in manifest['cases']:
 src=base/case['file'];assert hashlib.sha256(src.read_bytes()).hexdigest()==case['source_sha256']
 for target in ['linux','windows']:
  w=d/(src.stem+'-'+target);w.mkdir();(w/'input.prg').write_bytes(src.read_bytes());ll=w/'emit.ll';cmd=[cc,src.name,str(ll),'--experimental-llvm','--target='+target];z=subprocess.run(cmd,cwd=base,capture_output=True,timeout=30)
  for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/('emit.'+k)).write_bytes(b)
  (w/'command.json').write_text(json.dumps(dict(argv=cmd,cwd=str(base)),indent=2)+'\n');assert z.returncode==0,z.stderr
  s=ll.read_text();defs=dict(re.findall(r'(@str\d+) = private constant \[\d+ x i8\] c"([^"]*)"',s));refs=re.findall(r'store volatile ptr (@str\d+),',s);texts=[defs[x]for x in refs];lengths=re.findall(r'store volatile i64 (-?\d+),',s)
  assert len(texts)==len(lengths)==case['text_updates'];assert len(set(refs))==len(set(texts))==case['unique_texts']
  for text,length in zip(texts,lengths):assert len(re.findall(r'\\[0-9A-Fa-f]{2}',text))==int(length)
  digest=hashlib.sha256(json.dumps(list(zip(texts,lengths)),separators=(',',':')).encode()).hexdigest();assert digest==case['update_sequence_sha256'];assert s.count('store volatile ptr')==case['volatile_pointer_stores']
  # Retain the actual emitted IR: this is the object under inspection,not disposable assembly.
  rows.append(dict(source=src.name,target=target,source_sha256=case['source_sha256'],update_digest=digest,text_updates=len(texts),unique_texts=len(set(texts)),pass_=True))
(d/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS canary',len(rows))
