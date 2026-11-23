#!/usr/bin/env python3
"""Base/final error contract and final zero-pending caught transitions."""
from pathlib import Path
import argparse,json
from common import *
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
cases={
'caught-before-return':('function Get()\nBreak("expected")\nreturn Make()\n','c:=Get()'),
'caller-throws':('function Get()\nreturn Make()\n','c:=Get()\nBreak("expected")'),
'finally-return':('function Get()\nlocal a:=Uno():New()\nTRY\na:=Make()\nFINALLY\na:Same()\nEND\nreturn Make()\n','c:=Get()\nBreak("expected")'),
'rethrow':('function Get()\nTRY\nBreak("expected")\nCATCH err\nBreak(err)\nEND\nreturn Make()\n','c:=Get()'),
'inner-catch':('function Get()\nTRY\nBreak("expected")\nCATCH\nreturn Make()\nEND\nreturn Make()\n','c:=Get()\nBreak("expected")'),
}
for name,(defs,body) in cases.items():
 for mode,flags in MODES[:4]:
  w=out/(name+'-'+mode);w.mkdir();src=w/'p.prg';base=CLASSES+DEFS+defs+'function Work(n)\nlocal c:=Uno():New(),i,k:=0\nfor i:=1 to n\nTRY\n'+body+'\nCATCH err\nk++\nif err!="expected"\n? "BAD-ERROR"\nendif\nEND\nif c:value!=17 .or. c:text!="retained"\n? "BAD-OWNER"\nendif\nnext\nreturn k\n'
  if name=='rethrow':base=base.replace('Break("expected")','Break(17)').replace('err!="expected"','err!=17')
  src.write_text(base+'function Main()\n? Work(3)\nreturn nil\n');rr={};row=dict(name=name,mode=mode,source_sha256=h(src),ok=False)
  for tag,cc in [('base',a.baseline),('candidate',a.compiler)]:
   e=w/tag;b=run([cc,src,e,'--target=linux',*flags],w,tag+'-build');row[tag+'_build_rc']=b[0]
   if b[0]==0 and not b[3]:row[tag+'_binary_sha256']=h(e);q=run([e],w,tag+'-run');rr[tag]=q;row[tag+'_run_rc']=q[0];e.unlink()
  row['ok']=len(rr)==2 and rr['base'][:3]==rr['candidate'][:3] and all(not q[3] for q in rr.values());rows.append(row)
  ms=w/'memory.prg';ms.write_text(base+'function Main()\nlocal b,n\nWork(3)\nb:=hb_memcheck()\nn:=Work(1503)\n? n,hb_memcheck()-b\nreturn nil\n');e=w/'memory';b=run([a.compiler,ms,e,'--target=linux','--instrument',*flags],w,'memory-build');row=dict(name=name,mode=mode,kind='caught-transition-memory',source_sha256=h(ms),build_rc=b[0],ok=False)
  if b[0]==0 and not b[3]:row['binary_sha256']=h(e);q=run([e],w,'memory-run');row.update(run_rc=q[0],ok=q[0]==0 and not q[2] and not q[3] and q[1].split()==[b'1503',b'0']);e.unlink()
  rows.append(row);print(name,mode,rows[-2]['ok'],row['ok'],flush=True)
  (out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline),runner_sha256=h(__file__),scope='Base/final exact caught error/return/finally behavior,not Harbour dialogue parity. Final1503caught transitions afterwarmup3 must have zero pending blocks and valid owner/error markers.',rows=rows),indent=2))
assert all(x['ok'] for x in rows)
