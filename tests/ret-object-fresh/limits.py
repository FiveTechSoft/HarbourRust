#!/usr/bin/env python3
"""Existing rejections and target/profile emission remain unchanged in admission."""
from pathlib import Path
import argparse,json
from common import *
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
rejected={
'object-seq-fresh':CLASSES+'function Make()\nreturn (1,Uno():New())\nfunction Main()\nlocal a:=Make()\n? a:value\nreturn nil\n',
'object-seq-borrow':CLASSES+'function Make()\nlocal a:=Uno():New()\nreturn (1,a)\nfunction Main()\nlocal a:=Make()\n? a:value\nreturn nil\n',
'return-in-try':CLASSES+'function Make()\nTRY\nreturn Uno():New()\nCATCH\nEND\nreturn Uno():New()\nfunction Main()\nlocal a:=Make()\n? a:value\nreturn nil\n',
'new-observer-not-admitted':'#include "hbclass.ch"\nclass Uno\nmethod Cierra()\nendclass\nmethod Cierra() class Uno\nreturn .T.\nclass Dos\nmethod Cierra()\nendclass\nmethod Cierra() class Dos\nreturn Uno():New()\nfunction Usa(o)\nreturn ValType(o:Cierra())\nfunction Main()\n? Usa(Uno():New()),Usa(Dos():New())\nreturn nil\n',
}
for name,text in rejected.items():
 w=out/name;w.mkdir();s=w/'p.prg';s.write_text(text);rr={};row=dict(name=name,kind='unchanged-rejection',source_sha256=h(s),ok=False)
 for tag,cc in [('base',a.baseline),('candidate',a.compiler)]:
  e=w/tag;q=run([cc,s,e,'--target=linux'],w,tag+'-build');rr[tag]=q;row[tag+'_build_rc']=q[0];assert not e.exists()
 row['ok']=rr['base'][0]==rr['candidate'][0]==1 and rr['base'][1:3]==rr['candidate'][1:3] and all(not q[3] for q in rr.values());rows.append(row)
for target in ['linux','windows','macho','macho-arm64']:
 w=out/target;w.mkdir();s=w/'p.prg';s.write_text(source('factory'));row=dict(name=target,kind='target-assembly',source_sha256=h(s),ok=True)
 for tag,cc in [('base',a.baseline),('candidate',a.compiler)]:
  asm=w/(tag+'.s');q=run([cc,s,asm,'--target='+target],w,tag+'-build');row[tag+'_build_rc']=q[0];row['ok'] &= q[0]==0 and not q[3] and asm.exists()
  if asm.exists():row[tag+'_assembly_sha256']=h(asm)
 rows.append(row)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline),runner_sha256=h(__file__),scope='Four unchanged rejections require rc1,no output,and exactdiagnostic. Fourtargets assembly build0,not native execution or assembly identity.',rows=rows),indent=2));print('LIMITS',rows);assert all(x['ok'] for x in rows)
