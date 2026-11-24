#!/usr/bin/env python3
"""Own MIT paired process benchmark of mandatory unedited Harbour originals."""
from pathlib import Path
import argparse, subprocess, hashlib, json, os, time, statistics, platform, sys
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','spec-root','output']:p.add_argument('--'+n,required=True)
p.add_argument('--pairs',type=int,default=101);a=p.parse_args()
if not 11<=a.pairs<=1001:p.error('--pairs must be 11..1001')
root=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
cc=str(Path(a.compiler).resolve());hb=str(Path(a.hbmk2).resolve())
sources=[Path(a.spec_root).resolve()/'tests'/n for n in ['fib.prg','recursiv.prg','longstr2.prg']]
for s in sources:
 if not s.is_file():p.error('required upstream original missing: '+str(s))
parent_affinity=sorted(os.sched_getaffinity(0));cpu=parent_affinity[0];os.sched_setaffinity(0,{cpu})
rows=[]
def build(cmd,w,label):
 r=subprocess.run(cmd,capture_output=True,stdin=subprocess.DEVNULL,timeout=60,cwd=root)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 assert r.returncode==0,(label,r.stderr)
def execute(exe):
 t=time.perf_counter_ns();r=subprocess.run([str(exe)],capture_output=True,stdin=subprocess.DEVNULL,timeout=30,cwd=root)
 return r,time.perf_counter_ns()-t
for src in sources:
 w=out/src.stem;w.mkdir();(w/src.name).write_bytes(src.read_bytes())
 build([hb,str(src),'-quiet','-gtstd','-w0','-o'+str(w/'harbour')],w,'harbour-build')
 build([cc,str(src),str(w/'harbourrust')],w,'harbourrust-build')
 expected=None
 for i in range(5):
  for kind in ['harbour','harbourrust']:
   r,ns=execute(w/kind)
   if expected is None:expected=(r.returncode,r.stdout,r.stderr)
   assert expected==(0,r.stdout,r.stderr) and r.returncode==0 and (r.returncode,r.stdout,r.stderr)==expected,(src,kind,i,r.returncode)
   if i==0:
    for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(kind+'-warm.'+ext)).write_bytes(v)
 pairs=[]
 for i in range(a.pairs):
  pair={'pair':i,'order':['harbour','harbourrust'] if i%2==0 else ['harbourrust','harbour']}
  for kind in pair['order']:
   r,ns=execute(w/kind)
   assert (r.returncode,r.stdout,r.stderr)==expected,(src,kind,i,r.returncode)
   pair[kind+'_ns']=ns
  pair['harbour_over_harbourrust']=pair['harbour_ns']/pair['harbourrust_ns'];pairs.append(pair)
 med={k:statistics.median(x[k+'_ns'] for x in pairs) for k in ['harbour','harbourrust']}
 result=dict(source=src.name,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),pairs=pairs,median_ns=med,ratio_of_medians=med['harbour']/med['harbourrust'],median_paired_ratio=statistics.median(x['harbour_over_harbourrust'] for x in pairs),range_ns={k:[min(x[k+'_ns']for x in pairs),max(x[k+'_ns']for x in pairs)]for k in med},stdout_bytes=len(expected[1]),stderr_bytes=len(expected[2]))
 (w/'measurements.json').write_text(json.dumps(result,indent=2)+'\n');rows.append(result)
 for kind in ['harbour','harbourrust']:(w/kind).unlink()
 print(src.name,med,'Harbour/HarbourRust',round(result['ratio_of_medians'],3),flush=True)
summary=dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),hbmk2_sha256=hashlib.sha256(Path(hb).read_bytes()).hexdigest(),platform=platform.platform(),python=sys.version,clock=time.get_clock_info('perf_counter')._asdict() if hasattr(time.get_clock_info('perf_counter'),'_asdict')else str(time.get_clock_info('perf_counter')),original_affinity=parent_affinity,measurement_cpu=cpu,warmups_per_engine=5,pairs_per_source=a.pairs,scope='Unedited original end-to-end process times including startup, captured stdout/stderr, shutdown. No algorithm-only or cross-platform claim. All warm and measured output triples checked.',rows=rows)
(out/'results.json').write_text(json.dumps(summary,indent=2)+'\n')
