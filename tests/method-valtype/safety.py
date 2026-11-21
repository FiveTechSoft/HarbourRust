#!/usr/bin/env python3
"""Own MIT closed-scope and lifetime tests, not Harbour memory equivalence."""
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
classes='#include "hbclass.ch"\nclass Uno\nmethod Cierra()\nendclass\nmethod Cierra() class Uno\nreturn .T.\nclass Dos\nmethod Cierra()\nendclass\nmethod Cierra() class Dos\nreturn Self\n'
observe='function Usa(o)\nreturn ValType(o:Cierra())\n'
def main(body='? Usa(Uno():New()),Usa(Dos():New())',defs=classes+observe):return defs+'function Main()\n'+body+'\nreturn nil\n'
reject={
'factory-argument':main('? Usa(BuildDos())',classes+observe+'function BuildDos()\nreturn Dos():New()\n'),
'nested-method-argument':main('local a:=Dos():New()\n? Usa(a:Cierra())'),
'method-explicit-param':main(defs=(classes+observe).replace('method Cierra()','method Cierra(n)')),
'string-result':main(defs=(classes+observe).replace('return .T.','return Upper("abc")')),
'integer-result':main(defs=(classes+observe).replace('return .T.','return 7')),
'float-result':main(defs=(classes+observe).replace('return .T.','return 1.5')),
'fresh-object-result':main(defs=(classes+observe).replace('return Self','return Uno():New()')),
'call-object-result':main(defs=(classes+observe).replace('return Self','return Make()')+'function Make()\nreturn Uno():New()\n'),
'nil-result':main(defs=(classes+observe).replace('return .T.','return nil')),
'array-result':main(defs=(classes+observe).replace('return .T.','return {}')),
'mixed-within-method':main(defs=(classes+observe).replace('return .T.','if .T.\nreturn .T.\nendif\nreturn Self')),
'data-not-method':main(defs=(classes+observe).replace('class Uno\nmethod Cierra()\nendclass\nmethod Cierra() class Uno\nreturn .T.','class Uno\ndata Cierra\nendclass')),
'wrong-method':main(defs=(classes+observe).replace('o:Cierra()','o:Missing()')),
'arg-in-method-call':main(defs=(classes+observe).replace('o:Cierra()','o:Cierra(1)')),
'observer-local':main(defs=(classes+observe).replace('return ValType(o:Cierra())','local x:=o:Cierra()\nreturn ValType(x)')),
'observer-effect':main(defs=(classes+observe).replace('return ValType(o:Cierra())','? "effect"\nreturn ValType(o:Cierra())')),
'observer-expression':main(defs=(classes+observe).replace('return ValType(o:Cierra())','return ValType(o:Cierra())+"x"')),
'observer-extra-param':main(defs=(classes+observe).replace('Usa(o)','Usa(o,n)')),
'observer-no-valtype':main(defs=(classes+observe).replace('ValType(o:Cierra())','o:Cierra()')),
'observer-capture':main(defs=(classes+observe).replace('return ValType(o:Cierra())','local b:={|| ValType(o:Cierra())}\nreturn Eval(b)')),
'observer-funcref':main('local b:=@Usa()\n? Usa(Uno():New())'),
'byref':main('local a:=Uno():New()\n? Usa(@a)'),
'omitted':main('? Usa()'),
'nil':main('? Usa(nil)'),
'integer':main('? Usa(7)'),
'string':main('? Usa("x")'),
'array':main('local a:={1,2}\n? Usa(a)'),
'unknown-class':main('? Usa(Tres():New())',classes+'class Tres\nendclass\n'+observe),
'forward-unknown':main('? Relay(Uno():New())',classes+observe+'function Relay(o)\nreturn Usa(o)\n'),
'direct-bool':main('local a:=Uno():New()\n? ValType(a:Cierra())',classes),
'direct-self':main('local a:=Dos():New()\n? ValType(a:Cierra())',classes),
'classname':main(defs=(classes+observe).replace('o:Cierra()','o:ClassName()')),
'module-static':'STATIC shared:=Uno():New()\n'+main('? Usa(shared)'),
}
for name,s in reject.items():
 w=out/('reject-'+name);w.mkdir();src=w/'p.prg';src.write_text(s);e=w/'p';b=run([a.compiler,src,e,'--target=linux'],w,'build');rows.append(dict(name=name,kind='build-rejection',source_sha256=h(src),build_rc=b[0],diagnostic=b[2].decode(errors='replace').strip(),ok=b[0]==1 and not b[3] and not e.exists()));print(name,rows[-1]['ok'],flush=True)
 if e.exists():e.unlink()
for name,flags,prefix,body in [('windows',['--target=windows'],'',''),('macho',['--target=macho'],'',''),('arm64',['--target=macho-arm64'],'',''),('llvm',['--target=linux','--experimental-llvm'],'',''),('llvm-notrace',['--target=linux','--experimental-llvm-no-trace'],'',''),('memvar',['--target=linux'],'','private hidden:=1\n'),('threads',['--target=linux'],'function Worker()\nreturn 1\n','local t:=hb_threadStart(@Worker())\n')]:
 w=out/('profile-'+name);w.mkdir();src=w/'p.prg';src.write_text(main(body+'? Usa(Uno():New()),Usa(Dos():New())',classes+observe+prefix));e=w/'p';b=run([a.compiler,src,e,*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b[0],diagnostic=b[2].decode(errors='replace').strip(),ok=b[0]==1 and not b[3] and not e.exists()));print(name,rows[-1]['ok'],flush=True)
 if e.exists():e.unlink()
for count in [1,17,503]:
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
  for fresh_result in [False]:
   w=out/('memory-'+str(count)+'-'+mode+('-fresh' if fresh_result else '-self'));w.mkdir();src=w/'p.prg';defs=classes+observe
   if fresh_result:defs=defs.replace('return Self','return Uno():New()')
   src.write_text(main('local b,n\nWork(3)\nb:=hb_memcheck()\nn:=Work('+str(count)+')\n? n,hb_memcheck()-b',defs+'function Work(n)\nlocal a:=Uno():New(),b:=Dos():New(),i,k:=0\nfor i:=1 to n\nUsa(a)\nUsa(b)\nUsa(Uno():New())\nUsa(Dos():New())\nk++\nnext\nreturn k\n'));e=w/'p';b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,'build');row=dict(name=str(count)+'-'+mode,kind='instrumented-lifetime',fresh_result=fresh_result,source_sha256=h(src),build_rc=b[0],ok=False)
   if b[0]==0 and not b[3]:
    row['binary_sha256']=h(e);q=run([e],w,'run');row.update(run_rc=q[0],ok=q[0]==0 and not q[2] and not q[3] and list(map(int,q[1].split()))==[count,0]);e.unlink()
   rows.append(row);print(w.name,row['ok'],flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),runner_sha256=h(__file__),scope='Rejects require rc1 and no executable. Own warmup3 and 1/17/503 loop lifetime counters, four observer calls per loop, retained input owners/fresh receivers, RETURN Self result; zero pending required. Not Harbour memory equivalence.',rows=rows),indent=2));assert all(r['ok'] for r in rows),[r for r in rows if not r['ok']];print('PASS',len(rows))
