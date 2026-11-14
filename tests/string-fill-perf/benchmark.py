#!/usr/bin/env python3
"""Same-source growth/repetition benchmarks, separate from regression manifest.

Three whole-process samples, exact output checked. C reference implements
these byte transforms, not the VM/registry or argument-retention semantics.
"""
import argparse,json,statistics,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for key in ['compiler','baseline','hbmk2','output']:
    p.add_argument('--'+key,type=Path,required=True)
p.add_argument('--cc',default='cc')
a=p.parse_args()
for key in ['compiler','baseline','hbmk2','output']:
    setattr(a,key,getattr(a,key).resolve())
a.output.mkdir(parents=True,exist_ok=False)
rows=[]
def run(cmd):
    return subprocess.run(list(map(str,cmd)),capture_output=True,timeout=90)
cases=[]
for size,iters in [(8,500000),(256,200000),(4096,20000),(65536,2000)]:
    cases.append(('PadR',max(1,size//4),size,iters))
    cases.append(('Replicate',1,size,iters))
    cases.append(('Replicate',max(1,size//8),8,iters))
# Non-power-of-two source sizes and incomplete final copy-doubling block.
cases.extend([('Replicate',3,5,200000),('Replicate',257,17,20000),('PadR',257,4095,20000)])
cases=list(dict.fromkeys(cases))
for index,(fn,n,count,iters) in enumerate(cases):
    size=count if fn=='PadR' else n*count
    name=str(index)+'-'+fn+'-'+str(n)+'-'+str(count)
    src=a.output/(name+'.prg')
    src.write_text('function Main()\nlocal source:=Replicate("A",'+str(n)+')\nlocal value:=""\nlocal total:=0\nlocal i:=0\nfor i:=1 to '+str(iters)+'\nvalue:='+fn+'(source,'+str(count)+')\ntotal:=total+Len(value)+Asc(value)\nnext\n? total\nreturn nil\n')
    csrc=src.with_suffix('.c')
    csrc.write_text('''#include <stdlib.h>
#include <string.h>
#include <stdio.h>
__attribute__((noinline)) static char *transform(const char *s,size_t n,size_t m) {
 char *p=malloc(m);if(!p)exit(2);
 BODY
 return p;
}
int main(void) {
 size_t n=SOURCE_BYTES,m=RESULT_BYTES; char *s=malloc(n),*v=NULL;long long total=0;
 if(!s)return 2;memset(s,'A',n);
 for(int i=0;i<ITERS;i++){char *p=transform(s,n,m);free(v);v=p;total+=m+(unsigned char)v[0];}
 printf("\\n%10lld",total);free(v);free(s);return 0;
}
'''.replace('BODY','memcpy(p,s,n);memset(p+n,32,m-n);' if fn=='PadR' else 'memcpy(p,s,n);for(size_t filled=n;filled<m;){size_t k=filled<m-filled?filled:m-filled;memcpy(p+filled,p,k);filled+=k;}').replace('ITERS',str(iters)).replace('SOURCE_BYTES',str(n)).replace('RESULT_BYTES',str(size)))
    expected=None
    for impl,compiler in [('Harbour',a.hbmk2),('baseline',a.baseline),('candidate',a.compiler),('C_transform',a.cc)]:
        exe=a.output/(name+'-'+impl)
        cmd=[compiler,src,'-quiet','-gtstd','-o'+str(exe)] if impl=='Harbour' else [compiler,'-O2',csrc,'-o',exe] if impl=='C_transform' else [compiler,src,exe]
        q=run(cmd);assert q.returncode==0,(name,impl,q.stderr)
        samples=[]
        for _ in range(3):
            start=time.perf_counter_ns();q=run([exe]);samples.append((time.perf_counter_ns()-start)/1e9)
            assert (q.returncode,q.stderr)==(0,b''),(name,impl,q.returncode,q.stderr)
            if expected is None:expected=q.stdout
            assert q.stdout==expected,(name,impl,q.stdout,expected)
        exe.unlink()
        row=dict(function=fn,source_bytes=n,argument=count,result_bytes=size,iterations=iters,
                 implementation=impl,seconds=samples,median_ns_per_call=statistics.median(samples)*1e9/iters,
                 stdout_hex=expected.hex())
        rows.append(row);print(name,impl,round(row['median_ns_per_call'],2),flush=True)
    (a.output/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
