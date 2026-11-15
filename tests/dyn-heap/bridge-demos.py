#!/usr/bin/env python3
"""Checkpoint old PRG object + new bridge, baseline output parity on ELF/PE.
Fresh Harbour and new-heap gates are required for final delivery separately.
"""
import argparse,pathlib,subprocess,json,os
p=argparse.ArgumentParser()
for k in ['compiler','baseline','output']:p.add_argument('--'+k,required=True)
p.add_argument('--windows',action='store_true');p.add_argument('--mingw-bin');p.add_argument('--mingw-lib');p.add_argument('--wine');p.add_argument('--wine-prefix');a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(parents=True,exist_ok=False);root=pathlib.Path(__file__).resolve().parents[2];rows=[]
gcc=str(pathlib.Path(a.mingw_bin)/'x86_64-w64-mingw32-gcc-posix') if a.windows else 'gcc';ass=str(pathlib.Path(a.mingw_bin)/'x86_64-w64-mingw32-as') if a.windows else 'as';ld=str(pathlib.Path(a.mingw_bin)/'x86_64-w64-mingw32-ld') if a.windows else 'ld';env=dict(os.environ,WINEDEBUG='-all',WINEPREFIX=a.wine_prefix or '')
def run(c):
 q=subprocess.run(list(map(str,c)),capture_output=True,timeout=45);assert q.returncode==0,(c,q.returncode,q.stderr);return q
run([gcc,'-c','-O2','-ffreestanding','-fno-stack-protector','-I'+str(root/'extend'),root/'extend/hbhbr.c','-o',r/'newbridge.o'])
# Recover frozen legacy bridge from BASE, not the working copy.
q=run(['git','-C',root,'show','e67e67ba:extend/hbhbr.c']);(r/'oldbridge.c').write_bytes(q.stdout)
run([gcc,'-c','-O2','-ffreestanding','-fno-stack-protector','-I'+str(root/'extend'),r/'oldbridge.c','-o',r/'oldbridge.o'])
for name in ['apif64','apiecho','apiref','apistorref','apiitem','apiarr','apieval']:
 src=root/'extend/demo'/(name+'.prg');c=root/'extend/demo'/(name+'.c');run([gcc,'-c','-O2','-ffreestanding','-fno-stack-protector','-I'+str(root/'extend'),c,'-o',r/(name+'.o')]);want=None
 for impl,cc in [('old',a.baseline),('reader',a.compiler)]:
  for inst in [False,True]:
   label=name+impl+str(inst);asm=r/(label+'.s');obj=r/(label+'.o');run([cc,src,asm,'--target='+('windows' if a.windows else 'linux')]+(['--instrument'] if inst else []));run([ass,asm,'-o',obj]);asm.unlink()
   for bridge in (['oldbridge','newbridge'] if impl=='old' else ['newbridge']):
    exe=r/label;run([ld,'-o',exe,obj,r/(name+'.o'),r/(bridge+'.o')]+([r/'apif64.o'] if name in ['apiref','apiitem','apistorref','apiarr','apieval'] else [])+(['-e','_start','--subsystem','console','-L'+a.mingw_lib,'-lkernel32'] if a.windows else []));q=subprocess.run(([a.wine] if a.windows else [])+[str(exe)],capture_output=True,timeout=45,env=env if a.windows else None);exe.unlink()
    if want is None:want=(q.returncode,q.stdout,q.stderr)
    assert(q.returncode,q.stdout,q.stderr)==want,(label,bridge,q.stdout,want);(r/(label+bridge+'.stdout')).write_bytes(q.stdout);rows.append(dict(case=label,bridge=bridge,status='exact baseline'))
   obj.unlink()
(r/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(len(rows),('PE' if a.windows else 'ELF'),'compatibility demo cases PASS')
