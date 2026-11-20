#!/usr/bin/env python3
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for name,text in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(text);results={}
 for label,cmd in [('base',[a.baseline,src,w/'base','--target=linux']),('int',[a.compiler,src,w/'int','--target=linux']),('ext',[a.compiler,src,w/'ext','--target=linux','--external-as']),('oracle',[a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')])]:
  b=run(cmd,w,label+'-build');v=dict(build_rc=b.returncode)
  if not b.returncode:
   q=run([w/label],w,label+'-run');v.update(run_rc=q.returncode,binary_sha256=h(w/label));(w/label).unlink()
  results[label]=v
 assert results['base']['build_rc']==1,(name,'baseline must reject')
 assert all(results[n]['build_rc']==0 and results[n]['run_rc']==0 for n in ['int','ext','oracle']),(name,results)
 assert all((w/(n+'-run.'+e)).read_bytes()==(w/('oracle-run.'+e)).read_bytes() for n in ['int','ext'] for e in ['stdout','stderr','rc']),name
 rows.append(dict(name=name,source_sha256=h(src),results=results));print(name,'EXACT int/ext',flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='34 own unchanged sources, scalar default setters,68 exact int/ext rc/stdout/stderr comparisons against fresh external Harbour executable; baseline rejection separate.',rows=rows),indent=2))
