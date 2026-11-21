#!/usr/bin/env python3
"""Exact Harbour output comparison, independent of allocation counters."""
from pathlib import Path
import argparse,json
from common import *
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--baseline');p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
for name in CASES:
 w=out/name;w.mkdir();s=w/'p.prg';s.write_text(source(name));oracle=w/'oracle';b=run([a.hbmk2,s,'-quiet','-gtstd','-o'+str(oracle)],w,'oracle-build');assert b[0]==0 and not b[3],(name,b);q=run([oracle],w,'oracle-run');assert q[0]==0 and not q[2] and not q[3];oh=h(oracle);oracle.unlink()
 for mode,flags in MODES+([('baseline',[])] if a.baseline else []):
  cc=a.baseline if mode=='baseline' else a.compiler;e=w/mode;b=run([cc,s,e,'--target=linux',*flags],w,mode+'-build');row=dict(name=name,mode=mode,source_sha256=h(s),oracle_binary_sha256=oh,build_rc=b[0],exact=False)
  if b[0]==0 and not b[3]:
   row['binary_sha256']=h(e);z=run([e],w,mode+'-run');row.update(run_rc=z[0],exact=z[:3]==q[:3] and not z[3]);e.unlink()
  rows.append(row);print(name,mode,row['exact'],flush=True)
 (out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline) if a.baseline else None,runner_sha256=h(__file__),fixtures_sha256=h(Path(__file__).with_name('common.py')),scope='Same own sources compiled by external Harbour and base/final. Exact rc/stdout/stderr,5modes. No output normalization or memory-parity claim.',rows=rows),indent=2))
assert all(x['exact'] for x in rows)
