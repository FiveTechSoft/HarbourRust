#!/usr/bin/env python3
"""Bounded self-VAL parameter gate. Linux execution, other targets rejection.
Raw logs and a post-cleanup alloc/free DELTA guard are mandatory.
"""
import argparse, json, os, subprocess, sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2]; here=Path(__file__).resolve().parent
cc=str(Path(a.compiler).resolve());out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
sys.path.insert(0,str(root/'tests/trycatch-linux'))
from memdelta_guard import emit_delta
rows=[]
def run(cmd,label):
 r=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=60)
 for ext,data in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:
  (out/(label+'.'+ext)).write_bytes(data)
 return r
for name,want in [('param_dyn',b'\n      2025\n         8\n        25.0\n        25\n      2024\nbalanced'),('direct_return',b'\n      2025'),('bad_value',b'\nrecovered'),('date_direct',b'\n 2024'),('early_string',b'\nabc!\n         8')]:
 src=here/(name+'.prg');exe=out/name
 r=run([cc,src,exe,'--target=linux','--instrument'],name+'-build');assert r.returncode==0,r.stderr
 r=run([exe],name+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,want,b''),(name,r.returncode,r.stdout,r.stderr)
 d=out/(name+'-delta');d.mkdir();row=emit_delta(cc,os.environ,src,d,want)
 assert row['state_ok'] and row['delta']==0,(name,row)
 rows.append(dict(name=name,kind='execution-and-final-balance',**row))
for name,needle in [('static_integer_limit',b'retyped VAL parameter to a static integer'),('byref_limit',b'retyped VAL parameters cannot be passed by reference')]:
 r=run([cc,here/(name+'.prg'),out/name,'--target=linux'],name)
 assert r.returncode==1 and needle in r.stderr,(name,r.stderr)
 rows.append(dict(name=name,kind='named-rejection',rc=r.returncode))
for name in ['thread_limit','macro_limit']:
 r=run([cc,here/(name+'.prg'),out/name,'--target=linux'],name)
 assert r.returncode==1 and b'retyped VAL parameters require ordinary Linux' in r.stderr,(name,r.stderr)
 rows.append(dict(name=name,kind='named-profile-rejection',rc=r.returncode))
# VAL remains an assembler-reserved definition in the current front end.
# Pin that existing source-level limit on every target, with no false gate.
for target in ['linux','macho','macho-arm64','windows']:
 r=run([cc,here/'user_val_reserved.prg',out/'reserved','--target='+target],'user-val-'+target)
 assert r.returncode==1 and b'`val` is reserved by the code generator' in r.stderr,(target,r.stderr)
 assert b'retyped VAL' not in r.stderr
 rows.append(dict(name='user-val-'+target,kind='existing-reserved-name-limit',rc=r.returncode))
for target in ['macho','macho-arm64','windows']:
 r=run([cc,here/'param_dyn.prg',out/'rejected','--target='+target],'target-'+target)
 assert r.returncode==1 and b'retyped VAL parameters require ordinary Linux' in r.stderr,(target,r.stderr)
 rows.append(dict(name=target,kind='named-profile-rejection',rc=r.returncode))
# A numeric value followed by concatenation must raise, not reinterpret a pointer.
r=run([cc,here/'neg_str_arith.prg',out/'badconcat','--instrument'],'badconcat-build');assert r.returncode==0,r.stderr
r=run([out/'badconcat'],'badconcat-run');assert r.returncode==1 and b'Argument error: +' in r.stdout+r.stderr,(r.returncode,r.stdout,r.stderr)
rows.append(dict(name='numeric-concat',kind='runtime-error',rc=r.returncode))
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
print('PASS param-dyn: 5 executions with final delta=0, 2 named limits, 5 profile rejections, 4 existing VAL reserved-name checks, 1 runtime error')
