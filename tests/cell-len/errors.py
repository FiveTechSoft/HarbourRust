#!/usr/bin/env python3
"""Own error-path checks. No claim about headless Harbour error dialogs."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=20)
 for ext,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return q
leaf='function Count(c)\nreturn Len(c)\nfunction Observe(a)\nreturn Count(a[INDEX])\n'
for name,cell,index,error,frame in [('integer','7','1',b'Argument error: LEN',b'at count'),('nil','nil','1',b'Argument error: LEN',b'at count'),('logical','.T.','1',b'Argument error: LEN',b'at count'),('low','"x"','0',b'Bound error',b'at observe'),('high','"x"','2',b'Bound error',b'at observe')]:
 for catch in [False,True]:
  for mode,flags in [('int',[]),('ext',['--external-as'])]:
   w=out/(name+('-catch' if catch else '-trace')+'-'+mode);w.mkdir();src=w/'p.prg';defs=leaf.replace('INDEX',index)
   body='function Work(n)\nlocal a:={},i,k:=0\nAAdd(a,'+cell+')\nfor i:=1 to n\nTRY\nObserve(a)\nCATCH\nk++\nEND\nnext\nreturn k\nfunction Main()\nlocal b,k\nWork(3)\nb:=hb_memcheck()\nk:=Work(113)\n? k,hb_memcheck()-b\nreturn nil\n' if catch else 'function Main()\nlocal a:={}\nAAdd(a,'+cell+')\n? Observe(a)\nreturn nil\n'
   src.write_text(defs+body);e=w/'p';b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,'build');assert b.returncode==0,(name,b.stderr);bh=h(e);q=run([e],w,'run');e.unlink()
   ok=(q.returncode==0 and not q.stderr and list(map(int,q.stdout.split()))==[113,0]) if catch and name in ['low','high'] else (q.returncode==1 and not q.stderr and error in q.stdout and frame in q.stdout)
   row=dict(name=name,catch=catch,mode=mode,source_sha256=h(src),binary_sha256=bh,build_rc=b.returncode,run_rc=q.returncode,ok=ok);rows.append(row);print(row,flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),runner_sha256=h(__file__),scope='Own registered LEN/bounds error diagnostics and callee-frame presence; bounds catch113 with warmup3 and zero pending instrumentation counters; LEN remains registered fatal rc1 even under TRY, diagnostic channel stdout. External Harbour error dialogs not run.',rows=rows),indent=2));assert all(r['ok'] for r in rows)
