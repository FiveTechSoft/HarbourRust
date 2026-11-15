#!/usr/bin/env python3
"""Fresh same-source paired native Linux, 7 rotating-order process samples.
Includes startup/allocation/loop; no claim of isolated helper throughput.
"""
import argparse,pathlib,subprocess,statistics,time,json,hashlib
p=argparse.ArgumentParser()
for x in ['compiler','baseline','hbmk2','output']:p.add_argument('--'+x,required=True)
p.add_argument('--size',required=True,type=int);p.add_argument('--function',required=True,choices=['Upper','Lower']);a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(parents=True,exist_ok=False)
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,timeout=60)
n=a.size;iters=2000000 if n<=64 else 131072 if n<=4096 else 8192
src=r/'bench.prg';src.write_text(f'''function Main()
local source:=Replicate("aAzZ019!",{n//8})
local s:=""
local total:=0
local i:=0
for i:=1 to {iters}
s:={a.function}(source)
total:=total+Len(s)+Asc(s)
next
? total
return nil
''');names=['candidate','baseline','Harbour'];rows={};want=None
for name,cc in [('Harbour',a.hbmk2),('candidate',a.compiler),('baseline',a.baseline)]:
 exe=r/name;q=run([cc,src,'-quiet','-gtstd','-o'+str(exe)] if name=='Harbour' else [cc,src,exe]);assert q.returncode==0,(name,q.stderr);q=run([exe]);assert(q.returncode,q.stderr)==(0,b'');want=q.stdout if want is None else want;assert q.stdout==want,(name,q.stdout,want);rows[name]=dict(implementation=name,seconds=[],binary_sha256=hashlib.sha256(exe.read_bytes()).hexdigest())
for rep in range(7):
 for name in names[rep%3:]+names[:rep%3]:
  start=time.perf_counter_ns();q=run([r/name]);secs=(time.perf_counter_ns()-start)/1e9;assert(q.returncode,q.stdout,q.stderr)==(0,want,b'');rows[name]['seconds'].append(secs)
for name in names:
 rows[name]['median_ns_per_call']=statistics.median(rows[name]['seconds'])*1e9/iters;(r/name).unlink()
result=dict(function=a.function,bytes=n,iterations=iters,samples=7,platform='native Linux x86_64; same host; rotating order; no CPU affinity',stdout_hex=want.hex(),results=list(rows.values()));(r/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(a.function,n,[(name,round(rows[name]['median_ns_per_call'],2)) for name in names],flush=True)
