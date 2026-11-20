#!/usr/bin/env python3
"""Own MIT mixed static numeric Min/Max probes; external Harbour oracle only."""
from pathlib import Path
import subprocess,json,hashlib,argparse,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);p.add_argument('--external-p06');a=p.parse_args();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
programs={
'call-dyn':'function Keep(x)\nreturn x\nfunction Main()\nlocal x\n? (x:=Keep(nil)),ValType(x)\nreturn nil\n',
'call-string-dyn':'function Keep(x)\nreturn x\nfunction Main()\nlocal x,dummy:=Keep(nil)\n? (x:=Keep(Upper("hello"))),x\nreturn nil\n',
'self-copy':'function Main()\nlocal x\nx:=Upper("hello")\n? (x:=x),x\nreturn nil\n',
'nested':'function Main()\nlocal x,y\nx:=Upper("hello")\n? (y:=(x:=x)),x,y\nreturn nil\n',
'prefix-effects':'function Main()\nlocal x\nx:=Upper("hello")\n? (x:=x),(x:=nil),x\nreturn nil\n',
'float-dyn':'function Main()\nlocal x,y\nx:=1.25\n? (y:=x),x,y\nreturn nil\n',
'discard':'function Main()\nlocal x\nx:=Upper("hello")\n(x:=x)\n? x\nreturn nil\n',
}
programs.update({
'comparison-effects':'function Main()\nlocal x,y\nx:=Upper("hello")\ny:=Upper("other")\n? (x:=x)==(y:=y),x,y\n? (x:=x)==(x:=nil),x\nreturn nil\n',
'concat':'function Keep(x)\nreturn x\nfunction Main()\nlocal x\n? (x:=Keep(Upper("hello")))+(x:=Keep(Upper("world"))),x\nreturn nil\n',
'caller-return':'function Keep(x)\nreturn x\nfunction Pick()\nlocal x\nreturn (x:=Keep(Upper("hello")))\nfunction Main()\nlocal y:=Pick()\n? y\nreturn nil\n',
'argument':'function Keep(x)\nreturn x\nfunction Main()\nlocal x\n? Keep((x:=Keep(Upper("hello")))),x\nreturn nil\n',
})
if a.external_p06:programs['external-p06-unmodified']=Path(a.external_p06).read_text()
for name,text in programs.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(text);row=dict(name=name,source_sha256=h(src),results={})
 for label,cmd in [('base',[a.baseline,src,w/'base','--target=linux']),('int',[a.compiler,src,w/'int','--target=linux']),('ext',[a.compiler,src,w/'ext','--target=linux','--external-as']),('oracle',[a.hbmk2,src,'-quiet','-w0','-gtstd','-o'+str(w/'oracle')])]:
  b=run(cmd,w,label+'-build');rr=dict(build_rc=b.returncode)
  if not b.returncode:
   q=run([w/label],w,label+'-run');rr.update(run_rc=q.returncode,binary_sha256=h(w/label));(w/label).unlink()
  row['results'][label]=rr
 for label in ['oracle','int','ext']:assert row['results'][label]['build_rc']==0,(name,label)
 for label in ['int','ext']:assert all((w/(label+'-run.'+ext)).read_bytes()==(w/('oracle-run.'+ext)).read_bytes() for ext in ['rc','stdout','stderr']),(name,label)
 rows.append(row);print(name,'EXACT int/ext',flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='Own scalar Dyn inline assignment sources plus optional external P06 unchanged, int/ext exact rc/stdout/stderr against external Harbour. Baseline build rejections separate.',rows=rows),indent=2))
