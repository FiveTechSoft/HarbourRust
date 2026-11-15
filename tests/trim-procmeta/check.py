#!/usr/bin/env python3
"""Trim metadata elision plus fail-closed recursive-argument controls."""
import argparse,subprocess,json,os,difflib
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for k in ['compiler','baseline','hbmk2','output']:p.add_argument('--'+k,type=Path,required=True)
p.add_argument('--wine',type=Path);p.add_argument('--wine-prefix',type=Path)
a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
root=Path(__file__).resolve().parent;env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=str(a.wine_prefix.resolve())
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
rows=[]
for name in ['pure','direct','calls']:
 src=root/(name+'.prg');hb=a.output/'oracle'
 q=run([a.hbmk2,src,'-quiet','-gtstd','-o'+str(hb)]);assert q.returncode==0,q.stderr
 q=run([hb]);hb.unlink();assert(q.returncode,q.stderr)==(0,b''),q.stderr
 expected=q.stdout;(a.output/(name+'.oracle.stdout')).write_bytes(expected)
 for target in ['linux','windows'] if a.wine else ['linux']:
  for inst in [False,True]:
   label=name+'-'+target+'-'+str(inst);asm=[]
   for impl,c in [('base',a.baseline),('new',a.compiler)]:
    out=a.output/(label+'-'+impl+'.s');exe=a.output/(label+'-'+impl)
    flags=['--target='+target]+(['--instrument'] if inst else [])
    q=run([c,src,out]+flags);assert q.returncode==0,q.stderr;asm.append(out.read_text());out.unlink()
    q=run([c,src,exe]+flags);assert q.returncode==0,q.stderr
    q=run([a.wine,exe] if target=='windows' else [exe]);exe.unlink()
    (a.output/(label+'-'+impl+'.stdout')).write_bytes(q.stdout)
    assert(q.returncode,q.stdout,q.stderr)==(0,expected,b''),(label,impl,q.returncode,q.stdout,expected,q.stderr)
   if name=='pure':
    assert asm[0]!=asm[1],label
    # Pure fixture changes ONLY by deleting nonzero source-line stores.
    diff=''.join(difflib.unified_diff(asm[0].splitlines(True),asm[1].splitlines(True)))
    (a.output/(label+'.diff')).write_text(diff)
    import re
    before=asm[0].splitlines();after=asm[1].splitlines();removed=0
    for tag,i,j,k,l in difflib.SequenceMatcher(a=before,b=after,autojunk=False).get_opcodes():
     if tag=='equal':continue
     assert tag=='delete',(label,tag,before[i:j],after[k:l])
     assert all(re.fullmatch(r'    movq \$[1-9][0-9]*, -[0-9]+\(%rbp\)',line) for line in before[i:j]),(label,before[i:j])
     removed+=j-i
    assert removed==5,(label,removed)
   else:assert asm[0]==asm[1],(label,'introspection metadata changed')
   rows.append(dict(name=name,target=target,instrument=inst,exact_oracle=True,pure_elided=name=='pure',introspection_asm_unchanged=name!='pure'))
(a.output/'summary.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',len(rows),'metadata/oracle cases x2 compilers')
