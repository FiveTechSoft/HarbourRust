#!/usr/bin/env python3
"""Own MIT comma-list string probes. Harbour is an external executable oracle only."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--baseline');ap.add_argument('--hbmk2',required=True);ap.add_argument('--output',required=True);ap.add_argument('--contributed-p04');a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def source(body,defs=''):return defs+'\nfunction Main()\n'+body+'\nreturn nil\n'
programs={
'accumulator':source('local c:="seed",n:=0\nc:=(n:=n+1,c+"next")\nOutStd(c,"|",Str(n),Chr(10))'),
'prefix':source('local c:="left"\nOutStd((Upper("discard"),c),"|",c,Chr(10))'),
'final-temporary':source('local c:=""\nc:=(Upper("one"),Lower("TWO"))\nOutStd(c,Chr(10))'),
'local-copy':source('local c:=Upper("keep"),d:=""\nd:=(1,c)\nOutStd(c,"|",d,Chr(10))'),
'borrowed-consumers':source('local c:=Upper("stay")\nOutStd(Str(Len((1,c))),Empty((1,c)),"|",c,Chr(10))'),
'print-copy':source('local c:=Upper("print")\n? (1,c),c\n? c'),
'return-copy':source('OutStd(F(),Chr(10))','function F()\nlocal c:=Upper("return")\nreturn (1,c)\n'),
'owned-call':source('local c:=Upper("call")\nOutStd(Take((Upper("prefix"),c)),"|",c,Chr(10))','function Take(s)\nreturn s+"!"\n'),
'nested':source('local c:=""\nc:=(Upper("one"),(Upper("two"),Upper("three")))\nOutStd(c,Chr(10))'),
'float-last':source('OutStd(Str((Upper("prefix"),1.25)),Chr(10))'),
'float-last-nested':source('OutStd(Str((Upper("prefix"),(Lower("PREFIX"),2.5))),Chr(10))'),
'prefix-var':source('local c:=Upper("preserve")\nOutStd((c,Upper("value")),"|",c,Chr(10))'),
'empty':source('OutStd((Upper(""),Lower("")),"done",Chr(10))'),
'binary':source('local c:=""\nc:=(Lower("Discard"),Upper(Chr(0)+Chr(255)+"z"))\nOutStd(c,Chr(10))'),
'branch':source('local c:="",n:=1\nif n==1\nc:=(Upper("discard"),c+"yes")\nelse\nc:=(Lower("discard"),c+"no")\nendif\nOutStd(c,Chr(10))'),
'loop':source('local c:="initial",i:=0\nfor i:=1 to 9\nc:=(Upper("discard"),c+"x")\nnext\nOutStd(c,Chr(10))'),
'final-borrow-param':source('local c:=Upper("owner")\nOutStd(F(c),Chr(10))','function F(c)\nreturn (Upper("prefix"),c)\n'),
}
if a.contributed_p04:programs['external-p04-unmodified']=Path(a.contributed_p04).read_text()
def run(cmd,w,label):
 p=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=20)
 for k,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return p
for n,s in programs.items():
 w=out/n;w.mkdir();src=w/'p.prg';src.write_text(s);oracle=w/'oracle';ob=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(oracle)],w,'oracle-build');assert ob.returncode==0,(n,ob.stderr);o=run([oracle],w,'oracle-run');osh=h(oracle);oracle.unlink()
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  e=w/mode;b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,mode+'-build');row=dict(name=n,mode=mode,source_sha256=h(src),oracle_binary_sha256=osh,build_rc=b.returncode)
  if b.returncode==0:
   row['binary_sha256']=h(e);p=run([e],w,mode+'-run');row.update(run_rc=p.returncode,exact=(p.returncode,p.stdout,p.stderr)==(o.returncode,o.stdout,o.stderr));e.unlink()
  else:row['exact']=False
  rows.append(row);print(n,mode,row['exact'],flush=True)
 if a.baseline:
  b=run([a.baseline,src,w/'baseline','--target=linux'],w,'baseline-build');(w/'baseline').unlink(missing_ok=True);rows.append(dict(name=n,mode='baseline-compile',source_sha256=h(src),build_rc=b.returncode,baseline_reject=b.returncode!=0))
report=dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Unmodified sources compared against external Harbour, rc/stdout/stderr exact, no normalization; baseline compile is not runtime comparison',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));assert all(x.get('exact',True) for x in rows);print('PASS',sum('exact'in x for x in rows))
