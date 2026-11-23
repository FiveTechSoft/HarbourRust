#!/usr/bin/env python3
"""Own concat unwind handler/value/trace controls."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=20)
 for ext,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return q
prefix='function Throw()\nBreak("expected")\nreturn "never"\n'
programs={
'catch-value':prefix+'function Main()\nlocal e\nTRY\nOutStd(Upper("a")+Throw())\nCATCH e\n? e\nEND\nreturn nil\n',
'finally-on-throw':prefix+'function Main()\nTRY\nOutStd(Upper("a")+Throw())\nCATCH\n? "caught"\nFINALLY\n? "finally"\nEND\nreturn nil\n',
'rethrow':prefix+'function Main()\nlocal e\nTRY\nTRY\nOutStd(Upper("a")+Throw())\nCATCH e\n? e\nBreak(e)\nEND\nCATCH\n? "outer"\nEND\nreturn nil\n',
'rhs-inner-catch':prefix+'function Recover()\nTRY\nThrow()\nCATCH\n? "inner"\nEND\nreturn Upper("b")\nfunction Main()\nTRY\n? Upper("a")+Recover()\nThrow()\nCATCH\n? "outer"\nEND\nreturn nil\n',
'rhs-inner-finally':prefix+'function Recover()\nTRY\nThrow()\nCATCH\n? "inner"\nFINALLY\n? "finally"\nEND\nreturn Upper("b")\nfunction Main()\nTRY\n? Upper("a")+Recover()\nThrow()\nCATCH\n? "outer"\nEND\nreturn nil\n',
'cross-frame':prefix+'function Join()\nlocal owner:=Replicate("X",64)\nreturn Upper("a")+Throw()\nfunction Main()\nTRY\nJoin()\nCATCH\n? "caught"\nEND\nreturn nil\n',
'uncaught':prefix+'function Join()\nreturn Upper("a")+Throw()\nfunction Main()\n? Join()\nreturn nil\n',
'uncaught-bound':'function Join()\nlocal text:={"x"}\nreturn Upper("a")+text[99]\nfunction Main()\n? Join()\nreturn nil\n',
}
for name,text in programs.items():
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
  w=out/(name+'-'+mode);w.mkdir();src=w/'p.prg';src.write_text(text);runs={};row=dict(name=name,mode=mode,source_sha256=h(src),ok=False)
  for label,cc in [('base',a.baseline),('candidate',a.compiler)]:
   e=w/label;b=run([cc,src,e,'--target=linux','--instrument',*flags],w,label+'-build');row[label+'_build_rc']=b.returncode
   if b.returncode==0:row[label+'_binary_sha256']=h(e);q=run([e],w,label+'-run');e.unlink();runs[label]=(q.returncode,q.stdout,q.stderr);row[label+'_run_rc']=q.returncode
  row['ok']=len(runs)==2 and runs['base']==runs['candidate'] and runs['candidate'][0]==(1 if name.startswith('uncaught') else 0) and not runs['candidate'][2]
  rows.append(row);print(name,mode,row['ok'],flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline),runner_sha256=h(__file__),scope='Exactbase/candidaterc/stdout/stderr,samesourcepath. Ownexceptionvalue,rethrow,finally,crossframeandtracecontrols;notHarbourerrordialogparity.',rows=rows),indent=2));assert all(x['ok'] for x in rows),[x for x in rows if not x['ok']]
