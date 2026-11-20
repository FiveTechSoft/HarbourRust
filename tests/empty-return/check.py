#!/usr/bin/env python3
"""Own MIT empty-array return probes. Harbour is an external executable oracle only."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--baseline');ap.add_argument('--hbmk2',required=True);ap.add_argument('--output',required=True);ap.add_argument('--contributed-p09');a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def source(body,defs=''):return defs+'\nfunction Main()\n'+body+'\nreturn nil\n'
empty='function EmptyA()\nlocal a:={}\nreturn a\n'
programs={
'len-local-return':source('? Len(EmptyA())',empty),
'len-direct-return':source('? Len(Direct())','function Direct()\nreturn {}\n'),
'len-literal':source('? Len({})'),
'caller-store':source('local a:=EmptyA()\n? Len(a)',empty),
'caller-copy':source('local a:=EmptyA(),b:={}\nb:=a\n? Len(b)',empty),
'callee-copy':source('? Len(CopyA())','function CopyA()\nlocal a:={},b:={}\nb:=a\nreturn b\n'),
'caller-pin-int':source('local a:=EmptyA()\nAAdd(a,42)\n? Len(a),a[1]',empty),
'caller-pin-string':source('local a:=EmptyA()\nAAdd(a,"owned")\n? Len(a),a[1]',empty),
'caller-pin-logical':source('local a:=EmptyA()\nAAdd(a,.T.)\n? Len(a),a[1]',empty),
'caller-pin-child':source('local a:=EmptyA(),b:=Array(2)\nAAdd(a,b)\n? Len(a),Len(a[1])',empty),
'independent':source('local a:=EmptyA(),b:=EmptyA()\nAAdd(a,8)\n? Len(a),Len(b)',empty),
'chained-return':source('? Len(Wrap())',empty+'function Wrap()\nreturn EmptyA()\n'),
'branch-both-empty':source('? Len(Choose(0)),Len(Choose(1))','function Choose(n)\nlocal a:={}\nif n==0\nreturn a\nendif\nreturn {}\n'),
'effects-once':source('? Len(Effect())','function Effect()\nlocal a:={}\nOutStd("effect",Chr(10))\nreturn a\n'),
'argument-consumption':source('local s:=Upper("input")\n? Len(Consume(s))','function Consume(s)\nOutStd(s,Chr(10))\nreturn {}\n'),
'sibling-consumption':source('local s:=Upper("input")\n? Len(Consume(s)),Len({})','function Consume(s)\nOutStd(s,Chr(10))\nreturn {}\n'),
}
if a.contributed_p09:programs['external-p09-unmodified']=Path(a.contributed_p09).read_text()
def run(cmd,w,label):
 p=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=20)
 for k,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return p
for n,s in programs.items():
 w=out/n;w.mkdir();src=w/'p.prg';src.write_text(s);oracle=w/'oracle';ob=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(oracle)],w,'oracle-build');assert ob.returncode==0,(n,ob.stderr);o=run([oracle],w,'oracle-run');osh=h(oracle);oracle.unlink()
 for mode,flags in [('int',[]),('ext',['--external-as']),('int-no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays'])]:
  e=w/mode;b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,mode+'-build');row=dict(name=n,mode=mode,source_sha256=h(src),oracle_binary_sha256=osh,build_rc=b.returncode)
  if b.returncode==0:
   row['binary_sha256']=h(e);p=run([e],w,mode+'-run');row.update(run_rc=p.returncode,exact=(p.returncode,p.stdout,p.stderr)==(o.returncode,o.stdout,o.stderr));e.unlink()
  else:row['exact']=False
  rows.append(row);print(n,mode,row['exact'],flush=True)
 if a.baseline:
  b=run([a.baseline,src,w/'baseline','--target=linux'],w,'baseline-build');(w/'baseline').unlink(missing_ok=True);rows.append(dict(name=n,mode='baseline-compile',source_sha256=h(src),build_rc=b.returncode,baseline_reject=b.returncode!=0))
report=dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Unmodified sources compared against external Harbour, rc/stdout/stderr exact, no normalization; baseline compile is not runtime comparison',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));assert all(x.get('exact',True) for x in rows);print('PASS',sum('exact'in x for x in rows))
