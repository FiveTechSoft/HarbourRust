"""Isolated MEMVAR API gate: C-client vs PRG oracle, raw exact per target.
This does not claim same-source compilation or PRG frontend integration.
The PE client is a developer C harness using CRT, not the emitted product.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import subprocess

p=argparse.ArgumentParser()
for k in ['root','output','cc','mingw-cc','hbmk2','mingw-bin','wine','wine-prefix']:
    p.add_argument('--'+k,required=True)
p.add_argument('--sanitizer',action='store_true')
a=p.parse_args()
root=Path(a.root).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
commands=[];rows=[]
env={**os.environ,'WINEPREFIX':a.wine_prefix,'WINEDEBUG':'-all'}

def call(cmd,d,label,cross=False,extra=None):
    e=env.copy()
    for key in ['HB_CCPATH','HB_CCPREFIX','HB_CCSUFFIX']:e.pop(key,None)
    if cross:e.update(PATH=a.mingw_bin+':'+e['PATH'],HB_CCPATH=a.mingw_bin+'/',HB_CCPREFIX='x86_64-w64-mingw32-',HB_CCSUFFIX='-posix')
    if extra:e.update(extra)
    q=subprocess.run(cmd,cwd=d,env=e,capture_output=True,timeout=60)
    commands.append(dict(argv=[str(x) for x in cmd],directory=str(d.relative_to(out)),label=label,cross=cross,extra_env=extra or {}))
    for ext,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(d/(label+'.'+ext)).write_bytes(b)
    (out/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
    assert q.returncode==0 and not q.stderr,(label,q.returncode,q.stderr)
    return q

for target in ['linux','windows']:
    d=out/target;d.mkdir()
    cc=a.cc if target=='linux' else a.mingw_cc
    exe=d/('client.exe' if target=='windows' else 'client')
    flags=['-std=c11','-O2','-Wall','-Wextra','-Werror']
    call([cc,*flags,str(root/'runtime/hrmemvar.c'),str(root/'tests/memvar/storage-client.c'),'-o',str(exe)],d,'client-build')
    obj=d/'freestanding.o'
    call([cc,*flags,'-ffreestanding','-fno-builtin','-fno-stack-protector','-c',str(root/'runtime/hrmemvar.c'),'-o',str(obj)],d,'freestanding-build')
    nm='nm' if target=='linux' else str(Path(a.mingw_bin)/'x86_64-w64-mingw32-nm')
    undefined=call([nm,'-u',str(obj)],d,'undefined')
    assert not undefined.stdout
    (d/'probe.prg').write_bytes((root/'tests/memvar/storage-oracle.prg').read_bytes())
    call([a.hbmk2,'probe.prg','-gtstd','-oofficial']+(['-plat=win','-comp=mingw64'] if target=='windows' else []),d,'oracle-build',target=='windows')
    execute=[a.wine] if target=='windows' else []
    oracle=call(execute+[str(d/('official.exe' if target=='windows' else 'official'))],d,'oracle-run')
    client=call(execute+[str(exe)],d,'client-run')
    assert oracle.stdout==client.stdout,(target,oracle.stdout,client.stdout)
    faults=call(execute+[str(exe),'faults'],d,'faults')
    assert b'faults=PASS\nlive_bytes=0\n' in faults.stdout
    values=dict(line.split('=',1) for line in faults.stdout.decode().splitlines())
    assert values['allocations']==values['frees']
    rows.append(dict(target=target,raw_stdout_stderr_exit_exact=True,semantic_lines=len(oracle.stdout.splitlines()),allocation_count=int(values['allocations']),free_count=int(values['frees']),live_bytes=0,freestanding_undefined_symbols=0,frontend_integrated=False))
    (d/'artifact-shas.json').write_text(json.dumps({x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in d.iterdir() if x.name in ['client','client.exe','official','official.exe','freestanding.o']},indent=2)+'\n')
if a.sanitizer:
    d=out/'sanitizer';d.mkdir();exe=d/'client'
    call([a.cc,'-std=c11','-O1','-g0','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-fno-omit-frame-pointer',str(root/'runtime/hrmemvar.c'),str(root/'tests/memvar/storage-client.c'),'-o',str(exe)],d,'build')
    call([str(exe)],d,'semantic',extra={'ASAN_OPTIONS':'detect_leaks=1'})
    call([str(exe),'faults'],d,'faults',extra={'ASAN_OPTIONS':'detect_leaks=1'})
    rows.append(dict(target='linux-sanitizer',ASAN_UBSAN_leak_check_pass=True))
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
print(json.dumps(rows,indent=2))
