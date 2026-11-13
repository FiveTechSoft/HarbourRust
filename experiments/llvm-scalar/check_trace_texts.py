#!/usr/bin/env python3
"""Compare diagnostic bytes and volatile store sequence across LLVM emitters."""
import argparse,pathlib,subprocess,re,json
p=argparse.ArgumentParser();p.add_argument('--before',required=True);p.add_argument('--after',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();base=pathlib.Path(__file__).resolve().parent;out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
for file in ['perfextra.prg','corpus.prg','arraywork.prg','error-after-call.prg','error-bitops.prg','error-boolcalls.prg']:
 observations=[]
 for label,compiler in [('before',a.before),('after',a.after)]:
  f=out/(file+'-'+label+'.ll');subprocess.run([str(pathlib.Path(compiler).resolve()),file,str(f),'--experimental-llvm'],cwd=base,check=True,timeout=10);s=f.read_text();defs=dict(re.findall(r'(@str\d+) = private constant \[\d+ x i8\] c"([^"]*)"',s));seq=[]
  for line in s.splitlines():
   m=re.search(r'store volatile ptr (@str\d+),',line)
   if m:seq.append(('ptr',defs[m[1]]))
   m=re.search(r'store volatile i64 (-?\d+),',line)
   if m:seq.append(('len',m[1]))
  observations.append({'defs':defs,'sequence':seq,'s':s});
 old,new=observations;assert old['sequence']==new['sequence'],file
 assert new['s'].count('store volatile ptr')==old['s'].count('store volatile ptr'),file
 assert new['s'].count('load ptr, ptr @hbc_trace_top')==old['s'].count('load ptr, ptr @hbc_trace_top'),file
 assert len(new['defs'])<=len(old['defs']),file
 rows.append({'file':file,'before_constants':len(old['defs']),'after_constants':len(new['defs']),'volatile_text_and_length_stores':len(new['sequence']),'byte_sequence_exact':True});print(file,rows[-1])
(out/'results.json').write_text(json.dumps({'scope':'IR diagnostic text bytes and volatile update sequence; runtime/error tests separately required. Not pointer-identity ABI or performance proof.','rows':rows},indent=2)+'\n')
