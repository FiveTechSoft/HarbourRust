from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser()
for k in ['compiler','hbmk2','output']:p.add_argument('--'+k,required=True)
a=p.parse_args();out=Path(a.output);out.mkdir();rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,n):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(n+'.'+e)).write_bytes(b)
 return q
for op in ['++x','x++','--x','x--']:
 for typ,value in [('nil','nil'),('bool','.t.'),('string','Replicate("A",64)'),('f64','1.25')]:
  name=op.replace('+','p').replace('-','m')+'-'+typ;w=out/name;w.mkdir();p=w/'p.prg';s='function Main()\nlocal x,y,e\nx:='+value+'\nTRY\ny:='+op+'\n? "value",y,x\nCATCH e\n? "caught",ValType(x),x\nEND\nreturn nil\n';p.write_text(s);oracle=w/'oracle.prg';oracle.write_text(s.replace('TRY\n','BEGIN SEQUENCE WITH {|o| Break(o)}\n').replace('CATCH e\n','RECOVER USING e\n').replace('END\n','END SEQUENCE\n'));rr={}
  for lab,cmd in [('int',[a.compiler,p,w/'int','--target=linux']),('ext',[a.compiler,p,w/'ext','--target=linux','--external-as']),('oracle',[a.hbmk2,oracle,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')])]:
   b=run(cmd,w,lab+'-build');assert b.returncode==0,(name,lab,b.stderr);q=run([w/lab],w,lab+'-run');assert q.returncode==0 and not q.stderr;rr[lab]=dict(build_rc=b.returncode,run_rc=q.returncode,binary_sha256=h(w/lab));(w/lab).unlink()
  exact=all((w/(m+'-run.'+e)).read_bytes()==(w/('oracle-run.'+e)).read_bytes() for m in ['int','ext'] for e in ['stdout','stderr','rc'])
  if typ=='f64':assert not exact and all(b'caught' in (w/(m+'-run.stdout')).read_bytes() and b'1.25' in (w/(m+'-run.stdout')).read_bytes() for m in ['int','ext'])
  else:assert exact
  rows.append(dict(name=name,source_sha256=h(p),kind='named-runtime-limit' if typ=='f64' else 'oracle-exact',exact=exact,results=rr,ok=True));print(name,rows[-1]['kind'])
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='12badkind sources24int/ext exact catch+unchangedslot oracle pairs;4F64 sources8named runtime rejection controls,oracle increments F64 and differs deliberately.Only TRY/CATCH/END adapted for oracle.',rows=rows),indent=2))
