#!/usr/bin/env python3
"""Routine canary for interned text, retained dynamic trace stores and origins."""
import pathlib,subprocess,re,hashlib,json
base=pathlib.Path(__file__).resolve().parent
manifest=json.loads((base/'trace-interning-canary.json').read_text())
for case in manifest['cases']:
 source=base/case['file'];assert hashlib.sha256(source.read_bytes()).hexdigest()==case['source_sha256'],source
 for target in ['linux','windows']:
  output=base/'run'/('trace-canary-'+source.stem+'-'+target+'.ll')
  subprocess.run([str(base/'run/hbc'),source.name,str(output),'--experimental-llvm','--target='+target],cwd=base,check=True,timeout=10)
  s=output.read_text();defs=dict(re.findall(r'(@str\d+) = private constant \[\d+ x i8\] c"([^"]*)"',s));refs=re.findall(r'store volatile ptr (@str\d+),',s);texts=[defs[r]for r in refs];lengths=re.findall(r'store volatile i64 (-?\d+),',s)
  assert len(texts)==len(lengths)==case['text_updates'],(source,target)
  assert len(set(refs))==len(set(texts))==case['unique_texts'],(source,target)
  for text,length in zip(texts,lengths):assert len(re.findall(r'\\[0-9A-Fa-f]{2}',text))==int(length),(source,text,length)
  digest=hashlib.sha256(json.dumps(list(zip(texts,lengths)),separators=(',',':')).encode()).hexdigest();assert digest==case['update_sequence_sha256'],(source,target,digest)
  assert s.count('store volatile ptr')==case['volatile_pointer_stores'],(source,target)
  print('PASS interned trace text bytes/update sequence',source.name,target)
