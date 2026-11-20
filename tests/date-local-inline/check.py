#!/usr/bin/env python3
"""Own MIT monomorphic Date LOCAL and inline probes; external Harbour oracle only."""
from pathlib import Path
import subprocess,json,hashlib,argparse,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
programs={
'bare-inline':'function Main()\nlocal d\n? "date",(d:=StoD("20260203")),d,ValType(d),Day(d)\nreturn nil\n',
'bare-store':'function Main()\nlocal d\nd:=StoD("20260203")\n? d,ValType(d),Day(d)\nreturn nil\n',
'bare-ctod':'function Main()\nlocal d\n? (d:=CToD("02/03/2026")),d,ValType(d)\nreturn nil\n',
'bare-empty-date':'function Main()\nlocal d\n? (d:=StoD("")),d,ValType(d)\nreturn nil\n',
'bare-date-now':'function Main()\nlocal d\nd:=Date()\n? d==Date(),ValType(d)\nreturn nil\n',
'typed-inline':'function Main()\nlocal d:=StoD("20260101")\n? (d:=StoD("20260203")),d,Day(d)\nreturn nil\n',
'copy':'function Main()\nlocal d,e\nd:=StoD("20260203")\ne:=StoD("20260506")\n? (d:=e),d,e\n? (e:=d),d,e\nreturn nil\n',
'nested':'function Main()\nlocal d:=StoD(""),e:=StoD("")\n? (d:=(e:=StoD("20260203"))),d,e\nreturn nil\n',
'prefix-snapshot':'function Main()\nlocal d:=StoD("20260101")\n? d,(d:=StoD("20260203")),d,(d:=StoD("")),d\nreturn nil\n',
'argument':'function Show(d)\n? d,ValType(d),Day(d)\nreturn nil\nfunction Main()\nlocal d:=StoD("")\nShow((d:=StoD("20260203")))\n? d\nreturn nil\n',
'return':'function Pick()\nlocal d:=StoD("")\nreturn (d:=StoD("20260203"))\nfunction Main()\n? Pick()\nreturn nil\n',
'loop':'function Main()\nlocal d,i\nd:=StoD("20260101")\nfor i:=1 to 3\n? (d:=d+1),d\nnext\nreturn nil\n',
'parameter-copy':'function Update(d)\n? Day(d)\n? (d:=StoD("20260203")),d\nreturn nil\nfunction Main()\nlocal d:=StoD("20260101")\nUpdate(d)\n? d\nreturn nil\n',
}
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
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='Own monomorphic Date LOCAL and inline assignment sources, int/ext exact rc/stdout/stderr against external Harbour. Baseline build rejections separate.',rows=rows),indent=2))
