from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--harbour-core',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();core=Path(a.harbour_core);repo=Path(__file__).resolve().parents[2];inv=json.loads((repo/'corpus/harbour-694428e1-inventory.json').read_text());pinned={x['path']:x['sha256'] for x in inv['files']};rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for n,args in [('occurs','"ab","abABabab"')]:
 rel='contrib/hbfoxpro/'+n+'.prg';original=core/rel;before=h(original);assert before==pinned[rel]
 w=out/n;w.mkdir();p=w/'p.prg';p.write_text('function Main()\nlocal x:='+n+'('+args+')\n? ValType(x),x\n? fox_At("ab","abABabab",1),fox_At("ab","abABabab",2),fox_At("ab","abABabab",3)\nreturn nil\n#include "'+n+'.prg"\n');rr={}
 for lab,cmd in [('base',[a.baseline,p,w/'base','--target=linux','-I',core/'contrib/hbfoxpro']),('int',[a.compiler,p,w/'int','--target=linux','-I',core/'contrib/hbfoxpro']),('ext',[a.compiler,p,w/'ext','--target=linux','--external-as','-I',core/'contrib/hbfoxpro']),('oracle',[a.hbmk2,p,'-quiet','-gtstd','-w0','-i'+str(core/'contrib/hbfoxpro'),'-o'+str(w/'oracle')])]:
  b=run(cmd,w,lab+'-build');rr[lab]=dict(build_rc=b.returncode)
  if b.returncode==0:
   q=run([w/lab],w,lab+'-run');rr[lab].update(run_rc=q.returncode,binary_sha256=h(w/lab));(w/lab).unlink()
 assert rr['base']['build_rc']==1
 assert all(rr[x]['build_rc']==rr[x]['run_rc']==0 for x in ['int','ext','oracle'])
 assert all((w/(m+'-run.'+e)).read_bytes()==(w/('oracle-run.'+e)).read_bytes() for m in ['int','ext'] for e in ['stdout','stderr','rc'])
 assert h(original)==before;rows.append(dict(name=n,driver_sha256=h(p),original_path=rel,original_sha256=before,unchanged=True,results=rr));print(n,'EXACT int/ext')
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='One unchanged pinned external occurs.prg via own include-only driver,2 int/ext exact pairs,including fox_At1/2/3 and Occurs count;not all invalid inputs.',rows=rows),indent=2))
