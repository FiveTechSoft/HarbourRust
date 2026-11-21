#!/usr/bin/env python3
"""Own MIT lifetime counters and fail-closed scope probes, not Harbour memory equivalence."""
from pathlib import Path
import argparse,hashlib,json,os,signal,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 p=subprocess.Popen(list(map(str,cmd)),cwd=w,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=p.communicate(timeout=20);timed=False
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate();timed=True
 for k,v in [('stdout',so),('stderr',se),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p.returncode,so,se,timed
pick='function Pick(a)\nlocal b:=IIf(a==nil,{},a)\nreturn Len(b)\n'
def main(body,defs=pick):return defs+'function Main()\n'+body+'\nreturn nil\n'
reject={
'index':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','return b[1]')),
'mutate':main('local a:={}\nAAdd(a,1)\n? Pick(a)',pick.replace('return Len(b)','AAdd(b,7)\nreturn Len(b)')),
'escape':main('local a:={1,2}\nlocal c:=Pick(a)\n? Len(c)',pick.replace('return Len(b)','return b')),
'alias':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','local c:=b\nreturn Len(c)')),
'capture':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','local c:={|| Len(b)}\nreturn Eval(c)')),
'assign-param':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','a:=nil\nreturn Len(b)')),
'assign-result':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','b:={}\nreturn Len(b)')),
'forward-array':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','return Count(b)')+'function Count(c)\nreturn Len(c)\n'),
'forward-param':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','return Count(a)')+'function Count(c)\nreturn Len(c)\n'),
'print-result':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','? b\nreturn Len(b)')),
'byref-result':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','return Other(@b)')+'function Other(c)\nreturn 1\n'),
'loop-result':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','for b:=1 to 2\n? b\nnext\nreturn 1')),
'byref-argument':main('local a:={1,2}\n? Pick(@a)'),
'view-sibling-alias':main('local a:={1,2}\n? Pick(a,Len(a))',pick.replace('Pick(a)','Pick(a,n)').replace('return Len(b)','return Len(b)+n')),
'integer-argument':main('? Pick(7)'),
'string-argument':main('? Pick("not-array")'),
'logical-argument':main('? Pick(.T.)'),
'array-temporary':main('? Pick({})'),
'array-call-temporary':main('? Pick(NewA())','function NewA()\nreturn {}\n'+pick),
'dyn-source':main('local a\na:={1,"x"}\n? Pick(a)'),
'persistent-fixed':'STATIC shared:={1,2}\n'+main('? Pick(shared)'),
'persistent-mixed':'STATIC shared:={1,"x"}\n'+main('? Pick(shared)'),
'nonempty-fallback':main('local a:={1,2}\n? Pick(a)',pick.replace('{},a','{1},a')),
'wrong-selection':main('local a:={1,2}\n? Pick(a)',pick.replace('a==nil','a!=nil')),
'wrong-condition':main('local a:={1,2}\n? Pick(a)',pick.replace('a==nil','.T.')),
'nonoptional-array-union':main('local a:={},b:={}\nlocal c:=IIf(.T.,a,b)\n? Len(c)',''),
'unknown-function':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','return Unknown(Len(b))')),
'unknown-name':main('local a:={1,2}\n? Pick(a)',pick.replace('return Len(b)','return Len(b)+missing')),
'malformed-iif':main('? Pick()',pick.replace('IIf(a==nil,{},a)','IIf(a==nil,{})')),
'function-reference':main('? Other(@Pick())','function Other(c)\nreturn 1\n'+pick),
'method': 'class TProbe\nmethod Count(a)\nendclass\nmethod Count(a) class TProbe\nlocal b:=IIf(a==nil,{},a)\nreturn Len(b)\nfunction Main()\nlocal o:=TProbe()\n? o:Count()\nreturn nil\n',
}
for name,s in reject.items():
 w=out/('reject-'+name);w.mkdir();src=w/'p.prg';src.write_text(s);e=w/'p';b=run([a.compiler,src,e,'--target=linux'],w,'build');rows.append(dict(name=name,kind='build-rejection',source_sha256=h(src),build_rc=b[0],diagnostic=b[2].decode(errors='replace').strip(),ok=b[0]==1 and not b[3] and not e.exists()));print(name,rows[-1]['ok'],flush=True)
for name,flags,prefix in [('windows',['--target=windows'],''),('macho',['--target=macho'],''),('arm64',['--target=macho-arm64'],''),('llvm',['--target=linux','--experimental-llvm'],''),('llvm-notrace',['--target=linux','--experimental-llvm-no-trace'],''),('threads',['--target=linux'],'function Worker()\nreturn 1\n'),('memvar',['--target=linux'],'')]:
 w=out/('profile-'+name);w.mkdir();src=w/'p.prg';src.write_text(main(('local t:=hb_threadStart(@Worker())\n' if name=='threads' else 'private hidden:=1\n' if name=='memvar' else '')+'? Pick()',prefix+pick));e=w/'p';b=run([a.compiler,src,e,*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b[0],diagnostic=b[2].decode(errors='replace').strip(),ok=b[0]==1 and not b[3] and not e.exists()));print(name,rows[-1]['ok'],flush=True)
for count in [1,17,503]:
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
  w=out/('memory-'+str(count)+'-'+mode);w.mkdir();src=w/'p.prg';src.write_text(pick+'function Work(n)\nlocal a:={},i,sum:=0\nAAdd(a,Upper("first"))\nAAdd(a,Upper("second"))\nfor i:=1 to n\nsum+=Pick(a)+Pick()+Pick(nil)+Len(a)\nnext\nreturn sum\nfunction Main()\nlocal b,n\nWork(3)\nb:=hb_memcheck()\nn:=Work('+str(count)+')\n? n,hb_memcheck()-b\nreturn nil\n');e=w/'p';b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,'build');row=dict(name=str(count)+'-'+mode,kind='instrumented-lifetime',source_sha256=h(src),build_rc=b[0],ok=False)
  if b[0]==0 and not b[3]:
   row['binary_sha256']=h(e);q=run([e],w,'run');row.update(run_rc=q[0],ok=q[0]==0 and not q[2] and not q[3] and list(map(int,q[1].split()))==[4*count,0]);e.unlink()
  rows.append(row);print(row['name'],row['ok'],flush=True)
report=dict(compiler_sha256=h(a.compiler),runner_sha256=h(__file__),scope='Rejections verify rc1 and no executable, not Harbour runtime divergence. Lifetime runs: own instrumentation, three warmup iterations followed by 1/17/503 calls per Work, three optional selections per iteration, caller retains two owned-string elements; expected sum4*n and zero pending allocations. No claim about exception cost or Harbour allocation equivalence.',passed=sum(r['ok'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));assert all(r['ok'] for r in rows),[r for r in rows if not r['ok']];print('PASS',len(rows))
