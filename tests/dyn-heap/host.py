#!/usr/bin/env python3
"""Host mock allocator/API controls, not freestanding ABI evidence."""
import argparse,pathlib,subprocess
p=argparse.ArgumentParser();p.add_argument('--output',required=True);a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(exist_ok=False);root=pathlib.Path(__file__).resolve().parents[2]
s=(root/'extend/hbhbr.c').read_text().replace('extern HB_LONG hbc_blk_launch( HB_LONG codeptr, const HB_ULONG * vals, HB_LONG count );','extern HB_LONG test_blk_launch( HB_LONG codeptr, const HB_ULONG * vals, HB_LONG count );').replace('ret = hbc_blk_launch( codeptr, vals, n );','ret = test_blk_launch( codeptr, vals, n );');(r/'bridge.c').write_text(s)
for n,c in [('build',['gcc','-O2','-I'+str(root/'extend'),str(r/'bridge.c'),str(root/'tests/dyn-heap/bridge.c'),'-o',str(r/'probe')]),('run',[str(r/'probe')])]:
 q=subprocess.run(c,capture_output=True);(r/(n+'.stdout')).write_bytes(q.stdout);(r/(n+'.stderr')).write_bytes(q.stderr);(r/(n+'.rc')).write_text(str(q.returncode)+'\n');assert q.returncode==0,q.stderr
print('8 host bridge combinations PASS incl invalid stornd indices/no byref with no allocation')
