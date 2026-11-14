#!/usr/bin/env python3
"""Before/after retained-source fixtures against fresh real Harbour.

Wine is not native Windows. Diagnostic wrappers add HR-only hb_memcheck
AFTER Work returns. CToD is a control, not a claimed defect or code fix.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
p=argparse.ArgumentParser(description=__doc__)
for arg in ['compiler','baseline','hbmk2','output']:
    p.add_argument('--'+arg,type=Path,required=True)
p.add_argument('--wine',type=Path)
p.add_argument('--wine-prefix',type=Path)
a=p.parse_args()
for arg in ['compiler','baseline','hbmk2','output']:
    setattr(a,arg,getattr(a,arg).resolve())
a.output.mkdir(parents=True,exist_ok=False)
root=Path(__file__).resolve().parent
env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=str(a.wine_prefix.resolve())
rows=[]
def run(cmd):
    return subprocess.run(list(map(str,cmd)),capture_output=True,timeout=30,env=env)
def build(cmd,label):
    q=run(cmd)
    (a.output/(label+'.build.log')).write_bytes(q.stdout+q.stderr)
    assert q.returncode==0,(label,q.stderr)
def execute(compiler,src,label,target,instrument):
    exe=a.output/(label+'.program')
    build([compiler,src,exe,'--target='+target]+(['--instrument'] if instrument else []),label)
    q=run([a.wine,exe] if target=='windows' else [exe])
    (a.output/(label+'.stdout')).write_bytes(q.stdout)
    (a.output/(label+'.stderr')).write_bytes(q.stderr)
    exe.unlink()
    return q
for src in sorted(root.glob('*.prg')):
    name=src.stem
    exe=a.output/(name+'.harbour')
    build([a.hbmk2,src,'-quiet','-gtstd','-o'+str(exe)],name+'-hb')
    q=run([exe]);exe.unlink()
    assert (q.returncode,q.stderr)==(0,b''),(name,q.stderr)
    expected=q.stdout
    (a.output/(name+'.oracle.stdout')).write_bytes(expected)
    wrapper=a.output/(name+'-memory.prg')
    wrapper.write_text(src.read_text().replace('Work()\nreturn','Work()\n? hb_memcheck()\nreturn',1))
    assert wrapper.read_text()!=src.read_text()
    for target in ['linux','windows'] if a.wine else ['linux']:
        for instrument in [False,True]:
            label=name+'-'+target+str(instrument)
            before=execute(a.baseline,src,label+'-before',target,instrument)
            correct=(before.returncode,before.stdout,before.stderr)==(0,expected,b'')
            if name in ['padr-mutate','replicate-mutate','large-mutate']:
                # Freed cached/heap bytes can remain readable on one target.
                # Require the Linux reproducer; record masking elsewhere.
                if target=='linux':
                    assert not correct,('baseline did not reproduce',label)
            else:assert correct,('control failed before',label,before.stderr)
            after=execute(a.compiler,src,label+'-after',target,instrument)
            assert (after.returncode,after.stdout,after.stderr)==(0,expected,b''),(label,after.returncode,after.stdout,expected,after.stderr)
            mem=execute(a.compiler,wrapper,label+'-memory',target,instrument)
            assert (mem.returncode,mem.stdout,mem.stderr)==(0,expected+b'\n         0',b''),(label,mem.returncode,mem.stdout,mem.stderr)
            rows.append(dict(name=name,target=target,instrument=instrument,before_exact=correct,
                             before_rc=before.returncode,after_exact=True,final_memcheck0=True))
# Known exception-path owned cleanup gap: record separately, never as a
# successful ownership test. These HR diagnostic programs are not oracles.
known_limits=[]
for src in sorted((root/'limits').glob('*.prg')):
    for target in ['linux','windows'] if a.wine else ['linux']:
        label='known-owned-error-'+src.stem+'-'+target
        q=execute(a.compiler,src,label,target,True)
        assert (q.returncode,q.stderr)==(0,b''),(label,q.stderr)
        balance=int(q.stdout.rsplit(b'\n',1)[1].strip())
        assert balance==1,(label,'known limit changed; review evidence',balance)
        known_limits.append(dict(name=label,final_memcheck=balance,owned_error_leak=True))
summary=dict(base='e22689202927313db6db1c0f7f1a027b9a4f4988',
             baseline_sha256=hashlib.sha256(a.baseline.read_bytes()).hexdigest(),
             compiler_sha256=hashlib.sha256(a.compiler.read_bytes()).hexdigest(),rows=rows,known_limits=known_limits)
(a.output/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print('PASS',len(rows),'before/after pairs and',len(rows),'final memcheck0 wrappers')
