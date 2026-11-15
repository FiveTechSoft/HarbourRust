#!/usr/bin/env python3
"""Actual frozen pre-direct-thunk compiler; Linux section dispatch compatibility."""
import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(exist_ok=False);root=pathlib.Path(__file__).resolve().parents[2];rows=[]
def run(c):
 q=subprocess.run(list(map(str,c)),cwd=root,capture_output=True,timeout=30);assert q.returncode==0,(c,q.stderr);return q
run(['gcc','-O2','-c','-ffreestanding','-fno-stack-protector',root/'extend/hbhbr.c','-o',r/'newbridge.o'])
for n in ['hbhbr.c','hbhbr.h']:(r/n).write_bytes(run(['git','show','d86724bb:extend/'+n]).stdout)
run(['gcc','-O2','-c','-ffreestanding','-fno-stack-protector',r/'hbhbr.c','-o',r/'oldbridge.o'])
# Historical API supports scalar f64. Items/byref/arrays came with the
# direct-thunk transition and cannot be claimed as old section APIs.
for n in ['apif64']:
 run(['gcc','-O2','-c','-ffreestanding','-fno-stack-protector','-Iextend',root/('extend/demo/'+n+'.c'),'-o',r/(n+'.o')])
 for inst in [False,True]:
  s=r/(n+'.s');run([a.compiler,root/('extend/demo/'+n+'.prg'),s,'--target=linux']+(['--instrument'] if inst else []));assert 'hbc_ext_dispatch:' in s.read_text() and 'call HBHBR_FN_' not in s.read_text();o=r/'program.o';run(['as',s,'-o',o]);vals=[]
  for bridge in ['oldbridge','newbridge']:
   exe=r/'program';run(['ld','-o',exe,o,r/(bridge+'.o'),r/(n+'.o')]);q=subprocess.run([exe],capture_output=True,timeout=15);(r/(n+'-'+str(inst)+'-'+bridge+'.stdout')).write_bytes(q.stdout);(r/(n+'-'+str(inst)+'-'+bridge+'.stderr')).write_bytes(q.stderr);vals.append((q.returncode,q.stdout,q.stderr));exe.unlink()
  assert vals[0]==vals[1],(n,vals);rows.append(dict(case=n,instrument=inst,compiler_commit='d86724bb831ebc6d4697f3b652ec1c0c05cd2e7b',dispatch='actual historical section walker',old_new_bridge_exact=True))
(r/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(len(rows),'real historical section dispatcher comparisons PASS')
