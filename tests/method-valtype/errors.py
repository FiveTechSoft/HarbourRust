#!/usr/bin/env python3
"""Own nested-method unwind and diagnostic probes, no Harbour error-dialog claim."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=20)
 for ext,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return q
classes='#include "hbclass.ch"\nclass Uno\nmethod Cierra()\nendclass\nmethod Cierra() class Uno\nlocal a:={},n:=2\nAAdd(a,1)\nreturn a[n]==1\nclass Dos\nmethod Cierra()\nendclass\nmethod Cierra() class Dos\nreturn Self\nfunction Usa(o)\nreturn ValType(o:Cierra())\n'
for fresh in [False,True]:
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
  for catch in [False,True]:
   w=out/(('fresh' if fresh else 'owner')+'-'+mode+('-catch' if catch else '-trace'));w.mkdir();src=w/'p.prg';arg='Uno():New()' if fresh else 'a'
   body=('function Work(n)\nlocal a:=Uno():New(),i,k:=0\nfor i:=1 to n\nTRY\nUsa('+arg+')\nCATCH\nk++\nEND\nnext\nreturn k\nfunction Main()\nlocal b,n\nWork(3)\nb:=hb_memcheck()\nn:=Work(113)\n? n,hb_memcheck()-b\nreturn nil\n') if catch else ('function Main()\nlocal a:=Uno():New()\n? Usa('+arg+')\nreturn nil\n')
   src.write_text(classes+body);e=w/'p';b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,'build');row=dict(fresh_receiver=fresh,mode=mode,catch=catch,source_sha256=h(src),build_rc=b.returncode,ok=False)
   if b.returncode==0:
    row['binary_sha256']=h(e);q=run([e],w,'run');e.unlink();row['run_rc']=q.returncode;row['ok']=(q.returncode==0 and not q.stderr and list(map(int,q.stdout.split()))==[113,0]) if catch else (q.returncode==1 and not q.stderr and b'Bound error' in q.stdout and b'at usa' in q.stdout and b'cierra' in q.stdout)
   rows.append(row);print(w.name,row['ok'],flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),runner_sha256=h(__file__),scope='Own registered bounds errors inside a dispatched method.113catches after warmup3 and zero pending counters, fresh/retained receivers,4modes; trace requires method and observer frames. Not Harbour error compatibility.',rows=rows),indent=2));assert all(x['ok'] for x in rows)
