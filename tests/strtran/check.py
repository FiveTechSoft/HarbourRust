#!/usr/bin/env python3
"""StrTran typed 2/3-argument gate against fresh Harbour, with explicit limits.

PE/Wine is not native Windows. Memory wrappers are HR diagnostics. No
claim of start/count, Dyn/coercion or unrestricted Harbour arity.
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
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,timeout=60,env=env)
def build(cmd,label):
    q=run(cmd);(a.output/(label+'.build.log')).write_bytes(q.stdout+q.stderr)
    assert q.returncode==0,(label,q.stderr)
def check(src,label,expected,target,instrument=False):
    exe=a.output/(label+'.program')
    build([a.compiler,src,exe,'--target='+target]+(['--instrument'] if instrument else []),label)
    q=run([a.wine,exe] if target=='windows' else [exe]);exe.unlink()
    (a.output/(label+'.stdout')).write_bytes(q.stdout);(a.output/(label+'.stderr')).write_bytes(q.stderr)
    assert(q.returncode,q.stdout,q.stderr)==(0,expected,b''),(label,q.returncode,'byte mismatch',len(q.stdout),len(expected),q.stderr)
    rows.append(dict(name=label,exit=0,exact=True))
for name in ['basic','bytes','order','random']:
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
            check(wrapper,label+'-memory',expected+b'\n         0',target,instrument)
# Byte-exact repeated calls in two workers, normal mode only.
src=root/'thread.prg';exe=a.output/'thread.harbour'
build([a.hbmk2,src,'-quiet','-gtstd','-mt','-o'+str(exe)],'thread-hb')
q=run([exe]);exe.unlink();assert(q.returncode,q.stderr)==(0,b''),q.stderr
for n in range(5):check(src,'thread-'+str(n),q.stdout,'linux')
for src in sorted(root.glob('*-neg.prg')):
    expected=(b'`StrTran` admits 2 or 3 arguments' if src.stem.startswith('arity') else b'`StrTran` expects typed strings')
    for target in ['linux','windows'] if a.wine else ['linux']:
        dest=a.output/(src.stem+'-'+target+'.program')
        q=run([a.compiler,src,dest,'--target='+target])
        assert q.returncode!=0 and expected in q.stderr and not dest.exists(),(src,target,q.returncode,q.stderr)
        (a.output/(src.stem+'-'+target+'.stderr')).write_bytes(q.stderr)
        rows.append(dict(name=src.stem,target=target,rejected=True,diagnostic=expected.decode()))
known_limits=[]
for src in sorted((root/'limits').glob('*.prg')):
    for target in ['linux','windows'] if a.wine else ['linux']:
        label='known-owned-'+src.stem+'-'+target
        exe=a.output/(label+'.program')
        build([a.compiler,src,exe,'--target='+target,'--instrument'],label)
        q=run([a.wine,exe] if target=='windows' else [exe]);exe.unlink()
        assert(q.returncode,q.stderr)==(0,b''),(label,q.stderr)
        balance=int(q.stdout.rsplit(b'\n',1)[1].strip());assert balance>0,(label,balance)
        (a.output/(label+'.stdout')).write_bytes(q.stdout)
        known_limits.append(dict(name=label,final_memcheck=balance,owned_error_leak=True))
summary=dict(compiler_sha256=hashlib.sha256(a.compiler.read_bytes()).hexdigest(),rows=rows,known_limits=known_limits,
             limits='Typed strings, arity2/3 only; no start/count or Dyn/coercion; Wine is not native Windows')
(a.output/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print('PASS',sum(r.get('exact',False) for r in rows),'exact executions;',sum(r.get('rejected',False) for r in rows),'named rejections')
