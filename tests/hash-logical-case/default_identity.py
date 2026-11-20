#!/usr/bin/env python3
"""Default dialect byte-for-byte emission against the previous compiler."""
from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--output',required=True);a=p.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for n in ['t556_casematch_toggle','t560_casematch_clone','t563_casematch_emptyclone','t584_hclear']:
 for tg in ['linux','windows','macho','macho-arm64']:
  w=out/(n+'-'+tg);w.mkdir();row=dict(source='tests/'+n+'.prg',target=tg,source_sha256=h(repo/'tests'/(n+'.prg')),results={})
  for suffix in ['.s','.bin']:
   for label,cc in [('base',a.baseline),('candidate',a.compiler)]:
    f=w/(label+suffix);r=subprocess.run([cc,repo/'tests'/(n+'.prg'),f,'--target='+tg],capture_output=True,timeout=30)
    for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+suffix+'.build.'+ext)).write_bytes(v)
    assert r.returncode==0,(n,tg,label,r.stderr);row['results'][label+suffix]=h(f)
   assert (w/('base'+suffix)).read_bytes()==(w/('candidate'+suffix)).read_bytes(),(n,tg,suffix)
  row['exact']=True;rows.append(row);print(n,tg,'ASM+binary byte-identical',flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='No opt-in flag. Four unchanged root sources, four targets, full assembly and binary bytes identical to P08. Cross emission, not native execution outside Linux.',rows=rows),indent=2))
