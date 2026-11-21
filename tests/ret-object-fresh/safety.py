#!/usr/bin/env python3
"""Own zero-pending pool reuse tests. Base attribution is separate, not an oracle."""
from pathlib import Path
import argparse,json
from common import *
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline');p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
for name,(_,inc,_) in CASES.items():
 for count in [1,503,1503]:
  for mode,flags in MODES+([('baseline-attribution',[])] if a.baseline else []):
   w=out/(name+'-'+str(count)+'-'+mode);w.mkdir();s=w/'p.prg';s.write_text(source(name,count,True));e=w/'p';cc=a.baseline if mode=='baseline-attribution' else a.compiler;b=run([cc,s,e,'--target=linux','--instrument',*flags],w,'build');row=dict(name=name,count=count,mode=mode,source_sha256=h(s),build_rc=b[0],ok=False)
   if b[0]==0 and not b[3]:
    row['binary_sha256']=h(e);q=run([e],w,'run');parts=q[1].split();valid=q[0]==0 and not q[2] and not q[3] and len(parts)==2 and parts[0]==str(count*(1+inc)).encode() and parts[1].isdigit();pending=int(parts[1]) if valid else None
    row.update(run_rc=q[0],pending_blocks=pending,ok=valid and (pending==0 if mode!='baseline-attribution' else True));e.unlink()
   rows.append(row);print(w.name,row['ok'],flush=True)
  (out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline) if a.baseline else None,runner_sha256=h(__file__),fixtures_sha256=h(Path(__file__).with_name('common.py')),scope='Own allocation counter afterwarmup3,1/503/1503iterations,5modes. Pools retain reusable chunks; zero delta is required but not a per-object count. Value and caller-owner identity checks after new allocation force pool reuse. Base attribution reports actual pending separately,never memory parity.',rows=rows),indent=2))
assert all(x['ok'] for x in rows)
assert all(x['pending_blocks']==0 for x in rows if x['mode']!='baseline-attribution')
if a.baseline:assert any(x['pending_blocks']>0 for x in rows if x['mode']=='baseline-attribution' and x['count']==1503)
