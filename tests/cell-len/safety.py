#!/usr/bin/env python3
"""Own MIT fail-closed and lifetime probes, not oracle memory equivalence."""
from pathlib import Path
import argparse,hashlib,json,os,signal,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 p=subprocess.Popen(list(map(str,cmd)),cwd=w,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=p.communicate(timeout=15);timed=False
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate();timed=True
 for k,v in [('stdout',so),('stderr',se),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p.returncode,so,se,timed
leaf='function Count(c)\nreturn Len(c)\n'
loop='function Sum(a)\nreturn Count(a[1])\n'
def main(body='local a:={}\nAAdd(a,"one")\n? Sum(a)',defs=leaf+loop):return defs+'function Main()\n'+body+'\nreturn nil\n'
reject={
'callee-effect':main(defs=leaf.replace('return Len(c)','OutStd("effect")\nreturn Len(c)')+loop),
'callee-local':main(defs=leaf.replace('return Len(c)','local n:=Len(c)\nreturn n')+loop),
'callee-expression':main(defs=leaf.replace('return Len(c)','return Len(c)+1')+loop),
'callee-extra-param':main(defs=leaf.replace('Count(c)','Count(c,n)')+loop),
'callee-escape':main(defs=leaf.replace('return Len(c)','return c')+loop),
'callee-forward':main(defs='function Relay(c)\nreturn Len(c)\n'+leaf.replace('return Len(c)','return Relay(c)')+loop),
'callee-capture':main(defs=leaf.replace('return Len(c)','local b:={|| Len(c)}\nreturn Eval(b)')+loop),
'callee-branch':main(defs=leaf.replace('return Len(c)','if .T.\nreturn Len(c)\nendif\nreturn 0')+loop),
'callee-print':main(defs=leaf.replace('return Len(c)','? c\nreturn Len(c)')+loop),
'callee-unknown':main(defs=leaf.replace('return Len(c)','return Unknown(c)')+loop),
'array-mutate':main(defs=leaf+loop.replace('return Count(a[1])','AAdd(a,"two")\nreturn Count(a[1])')),
'array-escape':main('local a:={"one"}\nlocal b:=Sum(a)\n? Len(b)',leaf+loop.replace('return Count(a[1])','? Count(a[1])\nreturn a')),
'array-capture':main(defs=leaf+loop.replace('return Count(a[1])','local b:={|| Len(a)}\nreturn Count(a[1])+Eval(b)')),
'array-reassign':main(defs=leaf+loop.replace('return Count(a[1])','a:={}\nreturn Count(a[1])')),
'array-store':main(defs=leaf+loop.replace('return Count(a[1])','local b:=a\nreturn Count(a[1])+Len(b)')),
'array-byref':main('local a:={"one"}\n? Sum(@a)'),
'self-index':main(defs=leaf+loop.replace('a[1]','a[Len(a)]')),
'index-consume':main(defs=leaf+loop.replace('a[1]','a[Take(a)]')+'function Take(a)\nreturn 1\n'),
'callee-reference':main('local a:={"one"},b:=@Count()\n? Sum(a)'),
'whole-string-other-call':main('local a:={"one"}\n? Sum(a),Count("abc")'),
'whole-integer-other-call':main('local a:={"one"}\n? Sum(a),Count(4)'),
'byref-other-call':main('local a:={"one"}\n? Sum(a),Count(@a)'),
'threads':main('local a:={"one"},t:=hb_threadStart(@Worker())\n? Sum(a)',leaf+loop+'function Worker()\nreturn 1\n'),
'method': 'class TProbe\nmethod Count(c)\nendclass\nmethod Count(c) class TProbe\nreturn Len(c)\nfunction Observe(a)\nlocal o:=TProbe()\nreturn o:Count(a[1])\nfunction Main()\nlocal a:={"one"}\n? Observe(a)\nreturn nil\n',
'unknown-root':main(defs=leaf+loop.replace('a[1]','missing[1]')),
}
for name,s in reject.items():
 w=out/('reject-'+name);w.mkdir();src=w/'p.prg';src.write_text(s);e=w/'p';b=run([a.compiler,src,e,'--target=linux'],w,'build');rows.append(dict(name=name,kind='build-rejection',source_sha256=h(src),build_rc=b[0],diagnostic=b[2].decode(errors='replace').strip(),ok=b[0]==1 and not b[3] and not e.exists()));print(name,rows[-1]['ok'],flush=True)
 if e.exists():e.unlink()
for name,flags,body in [('windows',['--target=windows'],'? Sum(a)'),('macho',['--target=macho'],'? Sum(a)'),('arm64',['--target=macho-arm64'],'? Sum(a)'),('llvm',['--target=linux','--experimental-llvm'],'? Sum(a)'),('llvm-notrace',['--target=linux','--experimental-llvm-no-trace'],'? Sum(a)'),('memvar',['--target=linux'],'private hidden:=1\n? Sum(a)')]:
 w=out/('profile-'+name);w.mkdir();src=w/'p.prg';src.write_text(main('local a:={"one"}\n'+body));e=w/'p';b=run([a.compiler,src,e,*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b[0],diagnostic=b[2].decode(errors='replace').strip(),ok=b[0]==1 and not b[3] and not e.exists()));print(name,rows[-1]['ok'],flush=True)
 if e.exists():e.unlink()
for count in [1,17,503]:
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
  w=out/('memory-'+str(count)+'-'+mode);w.mkdir();src=w/'p.prg';src.write_text(leaf+'function Work(n)\nlocal a:={},i,sum:=0\nAAdd(a,Upper("first"))\nAAdd(a,Upper("second"))\nfor i:=1 to n\nsum+=Observe(a)\nnext\nreturn sum\n'+loop.replace('Sum','Observe').replace('return Count(a[1])','return Count(a[1])+Count(a[2])')+'function Main()\nlocal b,n\nWork(3)\nb:=hb_memcheck()\nn:=Work('+str(count)+')\n? n,hb_memcheck()-b\nreturn nil\n');e=w/'p';b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,'build');row=dict(name=str(count)+'-'+mode,kind='instrumented-lifetime',source_sha256=h(src),build_rc=b[0],ok=False)
  if b[0]==0 and not b[3]:
   row['binary_sha256']=h(e);q=run([e],w,'run');row.update(run_rc=q[0],ok=q[0]==0 and not q[2] and not q[3] and list(map(int,q[1].split()))==[11*count,0]);e.unlink()
  rows.append(row);print(row['name'],row['ok'],flush=True)
report=dict(compiler_sha256=h(a.compiler),runner_sha256=h(__file__),scope='Build rejections require rc1 and no executable; not runtime wrongness. Memory: own instrumented counters, warmup3, 1/17/503 iterations, two element observers per loop on owned strings; expected 11*n and zero pending allocations. Not Harbour memory equivalence.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));assert all(r['ok'] for r in rows),[r for r in rows if not r['ok']];print('PASS',len(rows))
