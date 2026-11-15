#!/usr/bin/env python3
"""Real callback through generated PRG and freestanding C, four thunk modes.
Legacy thunk controls replace only cap write to match the pre-migration
thunk's unflagged argc. They are not frozen historical PRG object evidence.
"""
import argparse,pathlib,subprocess,json,os,re
p=argparse.ArgumentParser()
for k in ['compiler','output','wine','wine-prefix','mingw-bin','mingw-lib']:p.add_argument('--'+k,required=True)
a=p.parse_args();root=pathlib.Path(__file__).resolve().parents[2];r=pathlib.Path(a.output);r.mkdir(parents=True,exist_ok=False);rows=[];env=dict(os.environ,WINEDEBUG='-all',WINEPREFIX=a.wine_prefix)
def run(c):
 q=subprocess.run(list(map(str,c)),capture_output=True,timeout=30);assert q.returncode==0,(c,q.returncode,q.stderr);return q
for target in ['linux','windows']:
 gcc='gcc' if target=='linux' else str(pathlib.Path(a.mingw_bin)/'x86_64-w64-mingw32-gcc-posix')
 ass='as' if target=='linux' else str(pathlib.Path(a.mingw_bin)/'x86_64-w64-mingw32-as')
 ld='ld' if target=='linux' else str(pathlib.Path(a.mingw_bin)/'x86_64-w64-mingw32-ld')
 for name,src in [('bridge',root/'extend/hbhbr.c'),('nested',root/'tests/dyn-heap/nested.c')]:run([gcc,'-O2','-c','-ffreestanding','-fno-stack-protector','-I'+str(root/'extend'),src,'-o',r/(name+'.o')])
 for inst in [False,True]:
  asm=r/'base.s';run([a.compiler,root/'tests/dyn-heap/nested.prg',asm,'--target='+target]+(['--instrument'] if inst else []));base=asm.read_text()
  for outer in [False,True]:
   for inner in [False,True]:
    code=base
    for name,cap in [('dyn_outer',outer),('dyn_inner',inner)]:
     if not cap:
      begin=code.index('hbc_fn_'+name+':');end=code.index('    ret',begin);frag=code[begin:end];assert '    or %r10, %rax' in frag;frag=frag.replace('    or %r10, %rax','    # legacy unflagged argc');code=code[:begin]+frag+code[end:]
    asm=r/'probe.s';asm.write_text(code);run([ass,asm,'-o',r/'probe.o']);exe=r/'probe.exe';run([ld,'-o',exe,r/'probe.o',r/'bridge.o',r/'nested.o']+(['-e','_start','--subsystem','console','-L'+a.mingw_lib,'-lkernel32'] if target=='windows' else []));q=run(([a.wine] if target=='windows' else [])+[exe]) if target=='linux' else subprocess.run([a.wine,str(exe)],capture_output=True,env=env,timeout=15)
    label=f'{target}-{inst}-{outer}-{inner}';(r/(label+'.stdout')).write_bytes(q.stdout);(r/(label+'.stderr')).write_bytes(q.stderr);assert(q.returncode,q.stdout,q.stderr)==(0,b'\n        19.50\n         0\n         0',b''),(label,q.returncode,q.stdout,q.stderr);rows.append(dict(target=target,instrument=inst,outer_heap_cap=outer,inner_heap_cap=inner,exact=True));exe.unlink()
(r/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(len(rows),'real callback configurations PASS')
