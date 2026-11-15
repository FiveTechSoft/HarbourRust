#!/usr/bin/env python3
"""Upper/Lower empty owned-result regression against fresh Harbour.
PE/Wine is not native Windows; memory wrappers are native diagnostics.
"""
import argparse,hashlib,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for key in ['compiler','hbmk2','output']:p.add_argument('--'+key,type=Path,required=True)
p.add_argument('--wine',type=Path)
p.add_argument('--wine-prefix',type=Path)
a=p.parse_args()
for key in ['compiler','hbmk2','output']:setattr(a,key,getattr(a,key).resolve())
a.output.mkdir(parents=True,exist_ok=False)
root=Path(__file__).resolve().parent
env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=str(a.wine_prefix.resolve())
rows=[]
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,timeout=30,env=env)
def build(cmd,label):
    q=run(cmd);(a.output/(label+'.build.log')).write_bytes(q.stdout+q.stderr)
    assert q.returncode==0,(label,q.stderr)
def check(src,label,expected,target,instrument=False):
    exe=a.output/(label+'.program')
    build([a.compiler,src,exe,'--target='+target]+(['--instrument'] if instrument else []),label)
    q=run([a.wine,exe] if target=='windows' else [exe]);exe.unlink()
    (a.output/(label+'.stdout')).write_bytes(q.stdout);(a.output/(label+'.stderr')).write_bytes(q.stderr)
    assert(q.returncode,q.stdout,q.stderr)==(0,expected,b''),(label,q.returncode,q.stdout,expected,q.stderr)
    rows.append(dict(name=label,exit=0,exact=True))
for name in ['basic','loop']:
    src=root/(name+'.prg');exe=a.output/(name+'.harbour')
    build([a.hbmk2,src,'-quiet','-gtstd','-o'+str(exe)],name+'-hb')
    q=run([exe]);exe.unlink();assert(q.returncode,q.stderr)==(0,b''),(name,q.stderr)
    expected=q.stdout;(a.output/(name+'.oracle.stdout')).write_bytes(expected)
    wrapper=a.output/(name+'-memory.prg')
    wrapper.write_text(src.read_text().replace('Work()\nreturn','Work()\n? hb_memcheck()\nreturn',1))
    for target in ['linux','windows'] if a.wine else ['linux']:
        for instrument in [False,True]:
            label=name+'-'+target+str(instrument)
            check(src,label,expected,target,instrument)
            if True:check(wrapper,label+'-memory',expected+b'\n         0',target,instrument)
(a.output/'summary.json').write_text(json.dumps(dict(rows=rows,compiler_sha256=hashlib.sha256(a.compiler.read_bytes()).hexdigest()),indent=2)+'\n')
print('PASS',len(rows),'exact oracle/ownership executions')
