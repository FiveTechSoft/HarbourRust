#!/usr/bin/env python3
"""Same-source Space, five rotating-order whole-process samples.
Includes process start/shutdown. No CPU pinning; machine-local, not an
application speedup. C has no VM, cache or allocation registry.
"""
import argparse,json,statistics,subprocess,time,hashlib
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for k in ['compiler','hbmk2','output']:p.add_argument('--'+k,type=Path,required=True)
p.add_argument('--sizes',default='0,8,64,256,4096,65536,65537')
p.add_argument('--samples',type=int,default=5)
a_function='Space'
a=p.parse_args()
for k in ['compiler','hbmk2','output']:setattr(a,k,getattr(a,k).resolve())
a.output.mkdir(parents=True,exist_ok=False)
rows=[]
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,timeout=90)
for size in map(int,a.sizes.split(',')):
 iters=10000000 if size<=64 else 6000000 if size<=256 else 1000000 if size<=4096 else 300000 if size<=65537 else 10000
 src=a.output/f'space-{size}.prg'
 src.write_text(f'function Main()\nlocal s:=""\nlocal n:={size}\nlocal total:=0\nlocal i:=0\nfor i:=1 to {iters}\ns:=Space(n)\ntotal:=total+Len(s)+Asc(s)\nnext\n? total\nreturn nil\n')
 src.write_text(src.read_text().replace('local n:='+str(size)+'\n','local n:='+str(size)+'.9\n'))
 csrc=src.with_suffix('.c')
 csrc.write_text('''#include <stdlib.h>
#include <string.h>
#include <stdio.h>
__attribute__((noinline)) static char *space(size_t n){char *p=malloc(n?n:1);if(!p)exit(2);memset(p,32,n);return p;}
int main(void){size_t n=SIZE;long long total=0;char *s=NULL;
for(int i=0;i<ITERS;i++){char *p=space(n);free(s);s=p;total+=n+(n?(unsigned char)s[0]:0);}
printf("\\n%*lld",total>9999999999LL?20:10,total);free(s);return 0;}
'''.replace('SIZE',str(size)).replace('ITERS',str(iters)))
 impls=[('Harbour',a.hbmk2),('candidate',a.compiler),('candidate_I64_control',a.compiler),('C_malloc_memset','cc')]
 data={};expected=None
 for impl,compiler in impls:
  exe=a.output/(str(size)+'-'+impl)
  cmd=[compiler,src,'-quiet','-gtstd','-o'+str(exe)] if impl=='Harbour' else [compiler,'-O2',csrc,'-o',exe] if impl=='C_malloc_memset' else [compiler,src,exe]
  if impl=='candidate_I64_control':
   control=src.with_name(src.stem+'-i64.prg');control.write_text(src.read_text().replace('local n:='+str(size)+'.9','local n:='+str(size)));cmd=[compiler,control,exe]
  q=run(cmd);assert q.returncode==0,(impl,q.stderr)
  q=run([exe]);assert(q.returncode,q.stderr)==(0,b''),(impl,q.returncode,q.stderr)
  if expected is None:expected=q.stdout
  assert q.stdout==expected,(size,impl,q.stdout,expected)
  data[impl]=dict(bytes=size,iterations=iters,implementation=impl,seconds=[],stdout_hex=expected.hex())
 for rep in range(a.samples):
  order=impls[rep%4:]+impls[:rep%4]
  for impl,_ in order:
   exe=a.output/(str(size)+'-'+impl)
   start=time.perf_counter_ns();q=run([exe]);elapsed=(time.perf_counter_ns()-start)/1e9
   assert(q.returncode,q.stdout,q.stderr)==(0,expected,b''),(impl,q.returncode,q.stderr)
   data[impl]['seconds'].append(elapsed)
 for impl,_ in impls:
  d=data[impl];d['median_ns_per_call']=statistics.median(d['seconds'])*1e9/iters;rows.append(d)
  print(size,impl,round(d['median_ns_per_call'],2),flush=True)
  (a.output/(str(size)+'-'+impl)).unlink()
 (a.output/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
(a.output/'compiler-sha256.txt').write_text(hashlib.sha256(a.compiler.read_bytes()).hexdigest()+'\n')
