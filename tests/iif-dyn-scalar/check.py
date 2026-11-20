#!/usr/bin/env python3
"""Own MIT mixed static numeric Min/Max probes; external Harbour oracle only."""
from pathlib import Path
import subprocess,json,hashlib,argparse,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
programs={
'prompt-string-dyn':'function Prompt(x)\n? IIf(x==nil,"default",x)\nreturn nil\nfunction Main()\nPrompt()\nPrompt("hello")\nreturn nil\n',
'prompt-other-dyn':'function Prompt(x)\n? IIf(x==nil,"default",x)\nreturn nil\nfunction Main()\nPrompt()\nPrompt(2)\nPrompt(1.25)\nreturn nil\n',
'stored-string-dyn':'function Keep(x)\nreturn x\nfunction Main()\nlocal x,y,dummy:=Keep(nil)\nx:=Keep(Upper("hello"))\ny:=IIf(.T.,x,"other")\nx:=nil\n? y\nreturn nil\n',
'dyn-dyn':'function Keep(x)\nreturn x\nfunction Main()\nlocal x,y,z,dummy:=Keep(nil)\nx:=Keep(Upper("hello"))\ny:=Keep(1.25)\nz:=IIf(.T.,x,y)\nx:=nil\n? z\nreturn nil\n',
}
programs.update({
'reverse':'function Prompt(x)\n? IIf(x!=nil,x,"default")\nreturn nil\nfunction Main()\nPrompt()\nPrompt(Upper("hello"))\nreturn nil\n',
 'lazy-call':'function Keep(x)\nreturn x\nfunction Loud()\n? "called"\nreturn Upper("hello")\nfunction Main()\nlocal x:=Keep(1.25),dummy:=Keep(nil),y\ny:=IIf(.F.,Loud(),x)\n? y\ny:=IIf(.T.,Loud(),x)\n? y\nreturn nil\n',
'owned-static-branch':'function Keep(x)\nreturn x\nfunction Main()\nlocal x:=Keep(nil),y,z:=Upper("hello")\ny:=IIf(.T.,z,x)\n? y\nreturn nil\n',
'return':'function Prompt(x)\nreturn IIf(x==nil,"default",x)\nfunction Main()\n? Prompt(),Prompt(Upper("hello")),Prompt(1.25)\nreturn nil\n',
'float-static-dyn':'function Keep(x)\nreturn x\nfunction Main()\nlocal x:=Keep(2),dummy:=Keep(nil),y\ny:=IIf(.T.,1.25,x)\n? y\ny:=IIf(.F.,1.25,x)\n? y\nreturn nil\n',
'overwrite-prefix':'function Keep(x)\nreturn x\nfunction Main()\nlocal x:=Keep(Upper("hello")),dummy:=Keep(nil),y\ny:=IIf(.T.,x,"other")\nx:=Keep(Upper("world"))\n? y,x\nreturn nil\n',
'last-output':'function Keep(x)\nreturn x\nfunction Main()\nlocal x:=Keep(Upper("hello")),dummy:=Keep(nil)\n? "prefix",IIf(.T.,x,"other")\nreturn nil\n',
})
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
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='11own scalar Dyn IIF sources, int/ext exact rc/stdout/stderr against external Harbour. Baseline build rejection separate.',rows=rows),indent=2))
