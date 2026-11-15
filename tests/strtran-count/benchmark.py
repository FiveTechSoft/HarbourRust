#!/usr/bin/env python3
"""Same-source StrTran versus Harbour and malloc/memcmp/memcpy C.

Three whole-process samples; exact output each time. C has no VM/cache or
argument-retention semantics. Timings are not application-wide claims.
"""
import argparse,json,statistics,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for key in ['compiler','hbmk2','output']:p.add_argument('--'+key,type=Path,required=True)
p.add_argument('--cc',default='cc');a=p.parse_args()
for key in ['compiler','hbmk2','output']:setattr(a,key,getattr(a,key).resolve())
a.output.mkdir(parents=True,exist_ok=False)
rows=[]
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,timeout=90)
cases=[]
for size,iters in [(64,100000),(4096,5000),(65536,300)]:
 for kind in ['replace','expand','delete','multi','miss','prefix-miss','unlimited-replace','unlimited-expand','unlimited-delete']:
  cases.append((size,iters*4,kind))
for size,iters,kind in cases:
 seek=('aa' if kind.startswith('multi') else 'a'*31+'b' if kind=='prefix-miss' else 'Z' if kind=='miss' else 'a')
 repl=('bbb' if kind=='multi-expand' else 'B' if kind=='multi' else 'XY' if kind in ['expand','unlimited-expand'] else '' if kind in ['delete','unlimited-delete'] else 'X')
 start_occ=2;count=3 if kind in ['replace','expand','delete'] else -2
 name=str(size)+'-'+kind;src=a.output/(name+'.prg')
 src.write_text('function Main()\nlocal c:=Replicate("a",'+str(size)+')\nlocal r:=""\nlocal i:=0\nlocal total:=0\nfor i:=1 to '+str(iters)+'\nr:=StrTran(c,"'+seek+'","'+repl+'",'+str(start_occ)+','+str(count)+')\ntotal:=total+Len(r)+Asc(r)\nnext\n? total\nreturn nil\n')
 csrc=src.with_suffix('.c');csrc.write_text('''#include <stdlib.h>
#include <string.h>
#include <stdio.h>
__attribute__((noinline)) static char *trans(const char *s,size_t n,const char *q,size_t k,const char *v,size_t m,size_t *out){
 size_t matches=0,found=0,i=0;while(i+k<=n){if(!memcmp(s+i,q,k)){found++;if(found>=START && (LIMIT<0 || matches<(size_t)LIMIT))matches++;i+=k;}else i++;}
 size_t len=n+matches*m-matches*k;char *p=malloc(len?len:1);if(!p)exit(2);size_t j=0,used=0;i=0;found=0;
 while(i+k<=n){if(!memcmp(s+i,q,k)){found++;if(found>=START && (LIMIT<0 || used<(size_t)LIMIT)){memcpy(p+j,v,m);j+=m;used++;}else {memcpy(p+j,s+i,k);j+=k;}i+=k;}else p[j++]=s[i++];}
 memcpy(p+j,s+i,n-i);*out=len;return p;}
int main(void){size_t n=SIZE;char *s=malloc(n),*v=NULL;long long total=0;if(!s)return 2;memset(s,'a',n);
 for(int i=0;i<ITERS;i++){size_t len;char *p=trans(s,n,"SEEK",KLEN,"REPL",RLEN,&len);free(v);v=p;total+=len+(len?(unsigned char)v[0]:0);}
 printf("\\n%10lld",total);free(v);free(s);return 0;}
'''.replace('START',str(start_occ)).replace('LIMIT',str(count)).replace('SIZE',str(size)).replace('ITERS',str(iters)).replace('SEEK',seek).replace('REPL',repl).replace('RLEN',str(len(repl))).replace('KLEN',str(len(seek))))
 expected=None
 for impl,compiler in [('Harbour',a.hbmk2),('candidate',a.compiler),('C_transform',a.cc)]:
  exe=a.output/(name+'-'+impl)
  cmd=[compiler,src,'-quiet','-gtstd','-o'+str(exe)] if impl=='Harbour' else [compiler,'-O2',csrc,'-o',exe] if impl=='C_transform' else [compiler,src,exe]
  q=run(cmd);assert q.returncode==0,(name,impl,q.stderr)
  samples=[]
  for _ in range(3):
   before=time.perf_counter_ns();q=run([exe]);samples.append((time.perf_counter_ns()-before)/1e9)
   assert(q.returncode,q.stderr)==(0,b''),(name,impl,q.stderr)
   if expected is None:expected=q.stdout
   assert q.stdout==expected,(name,impl,q.stdout,expected)
  exe.unlink();row=dict(start=start_occ,count=count,bytes=size,kind=kind,iterations=iters,implementation=impl,seconds=samples,median_ns_per_call=statistics.median(samples)*1e9/iters,stdout_hex=expected.hex())
  rows.append(row);print(name,impl,round(row['median_ns_per_call'],2),flush=True)
 (a.output/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
