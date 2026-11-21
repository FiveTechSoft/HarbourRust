from pathlib import Path
import subprocess,json,hashlib,os,argparse

def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def setup(base=False):
 p=argparse.ArgumentParser()
 for n in ['compiler','hbmk2','output']+(['baseline'] if base else []):p.add_argument('--'+n,type=Path,required=True)
 a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False);return a

def fixture():
 # No inherited environment is queried by test programs. Each lookup uses a
 # named fixture key; a large unrelated fixture checks no 64KiB slurp cap.
 e=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],HR_GETENV_A='alpha',HR_GETENV_EMPTY='',HR_GETENV_LONG='q'*8192,HR_GETENV_UTF8='café',HR_GETENV_DECOY='decoy',HR_GETENV_BIG='x'*70000)
 e.pop('HR_GETENV_MISSING',None);return e

def run(cmd,w,label,timeout=25):
 try:q=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=fixture(),timeout=timeout)
 except subprocess.TimeoutExpired as e:q=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for n,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+n)).write_bytes(v)
 return q

def exact(a,w,source,reject=True):
 p=w/'p.prg';p.write_text(source);rr={}
 if hasattr(a,'baseline'):
  b=run([a.baseline,p,w/'base','--target=linux'],w,'base-build');rr['base']=dict(build_rc=b.returncode)
  if reject:assert b.returncode==1 and not(w/'base').exists(),(w,b)
 oracle=w/'oracle.prg';oracle.write_text(source.replace('hb_memcheck()','0').replace('TRY\n','BEGIN SEQUENCE WITH {|o| Break(o)}\n').replace('CATCH e\n','RECOVER USING e\n').replace('END\n','END SEQUENCE\n'))
 b=run([a.hbmk2,oracle,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert b.returncode==0,(w,b)
 z=run([w/'oracle'],w,'oracle-run');assert z.returncode==0 and not z.stderr,(w,z);rr['oracle']=dict(build_rc=0,run_rc=0,binary_sha256=h(w/'oracle'));(w/'oracle').unlink()
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  b=run([a.compiler,p,w/mode,'--target=linux','--instrument',*flags],w,mode+'-build');assert b.returncode==0,(w,mode,b)
  q=run([w/mode],w,mode+'-run');rr[mode]=dict(build_rc=0,run_rc=q.returncode,binary_sha256=h(w/mode));(w/mode).unlink();assert (q.returncode,q.stdout,q.stderr)==(z.returncode,z.stdout,z.stderr),(w,mode,q,z)
 return dict(source_sha256=h(p),exact=True,results=rr)
def finish(a,rows,scope):
 j=dict(compiler_sha256=h(a.compiler),runner_sha256=h(Path(__import__('__main__').__file__)),scope=scope,rows=rows)
 if hasattr(a,'baseline'):j['baseline_sha256']=h(a.baseline)
 (a.output/'results.json').write_text(json.dumps(j,indent=2));print('PASS',len(rows))
