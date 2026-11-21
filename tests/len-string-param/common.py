from pathlib import Path
import argparse,subprocess,hashlib,json,os

def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def setup(baseline=False):
 p=argparse.ArgumentParser();p.add_argument('--compiler',type=Path,required=True);p.add_argument('--hbmk2',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
 if baseline:p.add_argument('--baseline',type=Path,required=True)
 p.add_argument('--harbour-core',type=Path);a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False);a.compiler=a.compiler.resolve();a.hbmk2=a.hbmk2.resolve();return a

def run(cmd,w,label,timeout=20):
 q=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,timeout=timeout,env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']))
 for k,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return q

def exact(a,w,source,base_reject=True,extra=None):
 p=w/'p.prg';p.write_text(source);rows={};extra=extra or []
 for mode,cmd in [('base',[a.baseline,p,w/'base','--target=linux',*extra])] if hasattr(a,'baseline') else []:
  b=run(cmd,w,mode+'-build');rows[mode]=dict(build_rc=b.returncode)
  if base_reject:assert b.returncode==1,(w,b)
 ob=run([a.hbmk2,p,'-quiet','-gtstd','-w0',*['-i'+str(x) for x in getattr(a,'oracle_include',[])],'-o'+str(w/'oracle')],w,'oracle-build');assert ob.returncode==0,(w,ob)
 z=run([w/'oracle'],w,'oracle-run');assert z.returncode==0 and not z.stderr,(w,z);rows['oracle']=dict(build_rc=0,run_rc=z.returncode,binary_sha256=h(w/'oracle'));(w/'oracle').unlink()
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  b=run([a.compiler,p,w/mode,'--target=linux','--instrument',*extra,*flags],w,mode+'-build');assert b.returncode==0,(w,mode,b)
  q=run([w/mode],w,mode+'-run');rows[mode]=dict(build_rc=0,run_rc=q.returncode,binary_sha256=h(w/mode));(w/mode).unlink();assert (q.returncode,q.stdout,q.stderr)==(z.returncode,z.stdout,z.stderr),(w,mode,q,z)
 return dict(source_sha256=h(p),results=rows,exact=True)
def finish(a,rows,scope):
 j=dict(compiler_sha256=h(a.compiler),runner_sha256=h(Path(__import__('__main__').__file__)),scope=scope,rows=rows)
 if hasattr(a,'baseline'):j['baseline_sha256']=h(a.baseline)
 (a.output/'results.json').write_text(json.dumps(j,indent=2));print('PASS',len(rows))
