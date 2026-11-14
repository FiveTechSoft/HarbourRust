#!/usr/bin/env python3
"""Same-source Space versus real Harbour and malloc/memset C reference.

Three whole-process samples. Includes startup/shutdown; short cases noisy.
C has no VM, registry or cache. This is not an application-wide speedup.
"""
import argparse,json,statistics,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for key in ['compiler','hbmk2','output']:p.add_argument('--'+key,type=Path,required=True)
p.add_argument('--cc',default='cc')
a=p.parse_args()
for key in ['compiler','hbmk2','output']:setattr(a,key,getattr(a,key).resolve())
a.output.mkdir(parents=True,exist_ok=False)
rows=[]
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,timeout=90)
for size,iters in [(0,500000),(8,500000),(64,500000),(256,200000),(4096,20000),(65536,2000),(65537,2000)]:
    src=a.output/('space-'+str(size)+'.prg')
    src.write_text('function Main()\nlocal s:=""\nlocal n:='+str(size)+'\nlocal total:=0\nlocal i:=0\nfor i:=1 to '+str(iters)+'\ns:=Space(n)\ntotal:=total+Len(s)+Asc(s)\nnext\n? total\nreturn nil\n')
    csrc=src.with_suffix('.c');csrc.write_text('''#include <stdlib.h>
#include <string.h>
#include <stdio.h>
__attribute__((noinline)) static char *space(size_t n){
 char *p=malloc(n?n:1);if(!p)exit(2);memset(p,32,n);return p;
}
int main(void){size_t n=SIZE;long long total=0;char *s=NULL;
 for(int i=0;i<ITERS;i++){char *p=space(n);free(s);s=p;total+=n+(n?(unsigned char)s[0]:0);}
 printf("\\n%10lld",total);free(s);return 0;}
'''.replace('SIZE',str(size)).replace('ITERS',str(iters)))
    expected=None
    for impl,compiler in [('Harbour',a.hbmk2),('candidate',a.compiler),('C_malloc_memset',a.cc)]:
        exe=a.output/(str(size)+'-'+impl)
        cmd=([compiler,src,'-quiet','-gtstd','-o'+str(exe)] if impl=='Harbour' else
             [compiler,'-O2',csrc,'-o',exe] if impl=='C_malloc_memset' else [compiler,src,exe])
        q=run(cmd);assert q.returncode==0,(impl,q.stderr)
        samples=[]
        for _ in range(3):
            start=time.perf_counter_ns();q=run([exe]);samples.append((time.perf_counter_ns()-start)/1e9)
            assert(q.returncode,q.stderr)==(0,b''),(impl,q.returncode,q.stderr)
            if expected is None:expected=q.stdout
            assert q.stdout==expected,(size,impl,q.stdout,expected)
        exe.unlink();row=dict(bytes=size,iterations=iters,implementation=impl,seconds=samples,
                             median_ns_per_call=statistics.median(samples)*1e9/iters,stdout_hex=expected.hex())
        rows.append(row);print(size,impl,round(row['median_ns_per_call'],2),flush=True)
    (a.output/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
