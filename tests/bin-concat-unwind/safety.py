#!/usr/bin/env python3
"""Own MIT concat RHS unwind lifetime gate, not Harbour memory parity."""
from pathlib import Path
import argparse,hashlib,json,os,signal,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--baseline');ap.add_argument('--output',required=True);a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 p=subprocess.Popen(list(map(str,cmd)),cwd=w,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=p.communicate(timeout=15);timed=False
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate();timed=True
 for k,v in [('stdout',so),('stderr',se),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p.returncode,so,se,timed
cases={
'fresh-replicate':('Replicate("A",64)+Throw()',1,1),
'fresh-upper':('Upper("a")+Throw()',1,1),
'fresh-concat':('(Upper("a")+Upper("b"))+Throw()',1,1),
'nested-right':('Upper("a")+(Upper("b")+Throw())',1,2),
'nested-three':('(Upper("a")+Upper("b"))+(Upper("c")+Throw())',1,2),
'literal-control':('"A"+Throw()',1,0),
'borrow-control':('owner+Throw()',1,0),
'left-throws-control':('Throw()+Upper("b")',1,0),
'bound-rhs':('Replicate("A",64)+text[99]',1,1),
'dyn-key-control':('Replicate("A",64)+h[Throw()]',1,0),
'wrapped-rhs':('Upper("a")+Upper(Throw())',1,1),
'sequence-lhs':('(Upper("x"),Upper("a"))+Throw()',1,1),
'sequence-rhs':('Upper("a")+(Upper("x"),Throw())',1,1),
'normal':('Upper("a")+Upper("b")',0,0),
'normal-literal':('Upper("a")+"B"',0,0),
}
for name,(expr,throws,prior_per_call) in cases.items():
 for count in [1,503]:
  text='function Throw()\nBreak("expected")\nreturn "never"\nfunction Work(n)\nlocal i,k:=0,owner:=Upper("owned"),text:={"only"},h:={"k"=>"v"},trash\nfor i:=1 to n\nTRY\nif Len('+expr+')!=2\n? "BAD-VALUE"\nendif\nCATCH\nk++\nEND\ntrash:=Replicate("BAD-VALUE",32)\nif owner!="OWNED" .or. text[1]!="only"\n? "BAD-OWNER"\nendif\nnext\nreturn k\nfunction Main()\nlocal b,n\nWork(3)\nb:=hb_memcheck()\nn:=Work('+str(count)+')\n? n,hb_memcheck()-b\nreturn nil\n'
  # Materialize concat at an unambiguous scalar consumer. Len(string expression)
  # uses its existing path, no new observer or result ABI is introduced.
  for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
   w=out/(name+'-'+str(count)+'-'+mode);w.mkdir();src=w/'p.prg';src.write_text(text);e=w/'p';b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,'build');row=dict(name=name,count=count,mode=mode,source_sha256=h(src),build_rc=b[0],ok=False)
   if b[0]==0 and not b[3]:
    row['binary_sha256']=h(e);q=run([e],w,'run');row.update(run_rc=q[0],ok=q[0]==0 and not q[2] and not q[3] and q[1].split()==[str(count*throws).encode(),b'0']);e.unlink()
   rows.append(row);print(w.name,row['ok'],flush=True)
  if a.baseline:
   w=out/(name+'-'+str(count)+'-baseline');w.mkdir();src=w/'p.prg';src.write_text(text);e=w/'p';b=run([a.baseline,src,e,'--target=linux','--instrument'],w,'build');row=dict(name=name,count=count,mode='baseline-attribution',source_sha256=h(src),build_rc=b[0],expected_pending=count*prior_per_call,ok=False)
   if b[0]==0 and not b[3]:
    row['binary_sha256']=h(e);q=run([e],w,'run');row.update(run_rc=q[0],ok=q[0]==0 and not q[2] and not q[3] and q[1].split()==[str(count*throws).encode(),str(count*prior_per_call).encode()]);e.unlink()
   rows.append(row);print(w.name,row['ok'],flush=True)
  (out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline) if a.baseline else None,runner_sha256=h(__file__),scope='Own instrumented lifetime after warmup3,1/503iterations,fivemodes,cacheoverwrite ownerguards. Base inheritedpending recorded separately. No Harbour memory parity.',rows=rows),indent=2))
assert all(r['ok'] for r in rows),[r for r in rows if not r['ok']]
print('PASS',len(rows))
