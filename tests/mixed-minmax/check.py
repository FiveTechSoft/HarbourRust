#!/usr/bin/env python3
"""Own MIT mixed static numeric Min/Max probes; external Harbour oracle only."""
from pathlib import Path
import subprocess,json,hashlib,argparse,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);p.add_argument('--external-p03');a=p.parse_args();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
pairs=[('basic','2','1.25'),('reverse','1.25','2'),('tie','2','2.00'),('tie-reverse','2.00','2'),('negative','-2','-1.25'),('negative-reverse','-1.25','-2'),('zero','0','0.00'),('zero-reverse','0.00','0'),('fraction','-0.25','0'),('large','9007199254740993','seed/1'),('large-reverse','seed/1','9007199254740993'),('large-negative','-9007199254740993','-seed/1'),('edge','9223372036854775807','top/1'),('edge-reverse','top/1','9223372036854775807')]
programs={name:'function Main()\nlocal seed:=9007199254740992,top:=9223372036854775807\nlocal a:='+x+',b:='+y+'\n? Min(a,b),Max(a,b)\nreturn nil\n' for name,x,y in pairs}
programs['once']='function LeftN()\n? "left"\nreturn 2\nfunction RightN()\n? "right"\nreturn 1.25\nfunction Main()\n? Min(LeftN(),RightN()),Max(LeftN(),RightN())\nreturn nil\n'
programs['stored']='function Main()\nlocal n:=Min(2,1.25),m:=Max(1.25,2)\n? n,m,ValType(n),ValType(m)\nreturn nil\n'
programs['nested']='function Main()\n? Min(Max(2,1.25),3.00),Max(Min(2,1.25),0)\nreturn nil\n'
programs['computed-int']='function Main()\nlocal i:=2,j:=1.25\n? Min(i+0,j),Max(i+0,j)\nreturn nil\n'
programs['existing-dyn-control']='function Keep(x)\nreturn x\nfunction Main()\nlocal dummy:=Keep(1),b:=Keep(1.25),a:=9007199254740993\n? Min(a,b),Max(a,b)\nreturn nil\n'
if a.external_p03:programs['external-p03-unmodified']=Path(a.external_p03).read_text()
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
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='20unchanged sources, int/ext exact rc/stdout/stderr against external Harbour, including optional P03. Tie metadata and large runtime doubles tested. Base build rejection separate.',rows=rows),indent=2))
