from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--harbour-core',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();core=Path(a.harbour_core);repo=Path(__file__).resolve().parents[2];inv=json.loads((repo/'corpus/harbour-694428e1-inventory.json').read_text());pinned={x['path']:x['sha256'] for x in inv['files']};rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for n,args in [('bitclr','"AB",1'),('bitset','"AB",1'),('isbit','"AB",1'),('byteand','"A","B"'),('bytenot','"A"'),('byteor','"A","B"'),('bytexor','"A","B"')]:
 rel='contrib/hbnf/'+n+'.prg';original=core/rel;before=h(original);assert before==pinned[rel]
 w=out/n;w.mkdir();p=w/'p.prg';p.write_text('function Main()\nlocal x:=ft_'+n+'('+args+')\n? ValType(x),x\nreturn nil\n#include "'+n+'.prg"\n');rr={}
 for lab,cmd in [('base',[a.baseline,p,w/'base','--target=linux','-I',core/'contrib/hbnf']),('int',[a.compiler,p,w/'int','--target=linux','-I',core/'contrib/hbnf']),('ext',[a.compiler,p,w/'ext','--target=linux','--external-as','-I',core/'contrib/hbnf']),('oracle',[a.hbmk2,p,'-quiet','-gtstd','-w0','-i'+str(core/'contrib/hbnf'),'-o'+str(w/'oracle')])]:
  b=run(cmd,w,lab+'-build');rr[lab]=dict(build_rc=b.returncode)
  if b.returncode==0:
   q=run([w/lab],w,lab+'-run');rr[lab].update(run_rc=q.returncode,binary_sha256=h(w/lab));(w/lab).unlink()
 assert rr['base']['build_rc']==1
 assert all(rr[x]['build_rc']==rr[x]['run_rc']==0 for x in ['int','ext','oracle'])
 assert all((w/(m+'-run.'+e)).read_bytes()==(w/('oracle-run.'+e)).read_bytes() for m in ['int','ext'] for e in ['stdout','stderr','rc'])
 assert h(original)==before;rows.append(dict(name=n,driver_sha256=h(p),original_path=rel,original_sha256=before,unchanged=True,results=rr));print(n,'EXACT int/ext')
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='7 unchanged external original library PRGs via own include-only drivers,14 int/ext exact comparisons.Only listed valid typed callshapes;not all input validation or invalid-arg paths.Original bodies never copied into MIT tests.',rows=rows),indent=2))
