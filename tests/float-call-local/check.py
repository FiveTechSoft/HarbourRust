#!/usr/bin/env python3
"""Own MIT statically integer LOCAL receiving proven F64 call probes; external Harbour oracle only."""
from pathlib import Path
import subprocess,json,hashlib,argparse,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
defs='function Half()\nreturn 1.25\nfunction Main()\n'
programs={
'call-store':defs+'local n:=0\nn:=Half()\n? n\nreturn nil\n',
'call-return':'function Half()\nreturn 1.25\nfunction Pick(flag)\nlocal n:=0\nif flag\nn:=Half()\nendif\nreturn n\nfunction Main()\n? Pick(.T.),Pick(.F.)\nreturn nil\n',
'call-replace':defs+'local n:=0\nn:=Half()\n? n\nn:=7\n? n\nreturn nil\n',
'call-branch-false':defs+'local n:=0\nif .F.\nn:=Half()\nendif\n? n\nreturn nil\n',
'call-metadata':defs+'local n:=9007199254740993\n? n\nn:=Half()\n? n\nreturn nil\n',
'call-arg':defs+'local n:=0\nn:=Half()\n? Min(n,2),Max(n,2)\nreturn nil\n',
'call-once':'function Half()\n? "once"\nreturn 1.25\nfunction Main()\nlocal n:=0\nn:=Half()\n? n\nreturn nil\n',
'call-forward':'function Main()\nlocal n:=0\nn:=Half()\n? n\nreturn nil\nfunction Half()\nreturn 1.25\n',
'no-int-origin':defs+'local n:=Half()\n? n,Min(n,1.25)\nreturn nil\n',
'seconds-shape':'function Main()\nlocal n:=0\nn:=Seconds()\n? ValType(n),n>=0,n<86400\nreturn nil\n',
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
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='10own sources, int/ext exact rc/stdout/stderr against external Harbour. Seconds emits type/range predicates, not nondeterministic value. Baseline build rejections separate.',rows=rows),indent=2))
