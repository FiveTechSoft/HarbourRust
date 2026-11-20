from pathlib import Path
import argparse,subprocess,json,hashlib,os
ap=argparse.ArgumentParser()
for k in ['compiler','baseline','hbmk2','output']:ap.add_argument('--'+k,required=True)
a=ap.parse_args();out=Path(a.output);out.mkdir();rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,n):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(n+'.'+e)).write_bytes(b)
 return q
cases={}
for typ,v in [('i64','42'),('f64','1.25')]:
 for marker in ['', '__br10']:
  for n in [0,1,2]:
   name='Pick'+marker;cases['byref-'+typ+marker+'-'+str(n)]=('exact','function Main()\nlocal s:=Replicate("A",64),a:='+name+'(@s,'+str(n)+')\n? ValType(a),a\nreturn nil\nfunction '+name+'(s,n)\nif n==0\nreturn nil\nendif\nif n==1\nreturn '+v+'\nendif\nreturn Upper(s)\n')
for typ,v,other,kind in [('i64','42','0','prior'),('f64','1.25','0.5','prior'),('str','Replicate("A",64)','nil','limit'),('bool','.t.','nil','limit')]:
 for flag in ['.t.','.f.']:
  cases['finally-'+typ+flag]=(kind,'function Main()\n? Pick('+flag+')\nreturn nil\nfunction Pick(flag)\nTRY\nBreak("x")\nCATCH e\nif flag\nreturn '+v+'\nendif\nreturn '+other+'\nFINALLY\n? "finally-marker"\nEND\nreturn '+other+'\n')
# String return outside CATCH and numeric/NIL inside still requires pending FINALLY.
for outside in ['before','after']:
 s='function Main()\n? Pick(.f.)\nreturn nil\nfunction Pick(flag)\n'
 typed='if flag\nreturn "typed-outside"\nendif\n'
 if outside=='before':s+=typed
 s+='TRY\nBreak("x")\nCATCH e\nreturn nil\nFINALLY\n? "finally-marker"\nEND\n'
 if outside=='after':s+=typed
 s+='return nil\n';cases['finally-outside-'+outside]=('limit',s)
for name,(kind,s) in cases.items():
 w=out/name;w.mkdir();p=w/'p.prg';p.write_text(s);op=w/'oracle.prg';op.write_text(s.replace('TRY\n','BEGIN SEQUENCE WITH {|o| Break(o)}\n').replace('CATCH e\n','RECOVER\n').replace('FINALLY\n','ALWAYS\n').replace('END\n','END SEQUENCE\n'));rr={}
 for lab,cmd in [('base',[a.baseline,p,w/'base','--target=linux']),('int',[a.compiler,p,w/'int','--target=linux']),('ext',[a.compiler,p,w/'ext','--target=linux','--external-as']),('oracle',[a.hbmk2,op,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')])]:
  b=run(cmd,w,lab+'-build');rr[lab]=dict(build_rc=b.returncode)
  if b.returncode==0:
   q=run([w/lab],w,lab+'-run');rr[lab].update(run_rc=q.returncode,binary_sha256=h(w/lab));(w/lab).unlink()
 assert rr['oracle']['build_rc']==rr['oracle']['run_rc']==0
 if kind=='exact':
  assert rr['base']['build_rc']==1
  assert all(rr[m]['build_rc']==rr[m]['run_rc']==0 and all((w/(m+'-run.'+e)).read_bytes()==(w/('oracle-run.'+e)).read_bytes() for e in ['stdout','stderr','rc']) for m in ['int','ext'])
 elif kind=='limit':
  assert rr['base']['build_rc']==1
  assert all(rr[m]['build_rc']==1 and b'mixed string/logical Dyn return from CATCH with FINALLY' in (w/(m+'-build.stderr')).read_bytes() and not(w/m).exists() for m in ['int','ext'])
 else:
  assert all(rr[m]['build_rc']==rr[m]['run_rc']==0 and all((w/(m+'-run.'+e)).read_bytes()==(w/('base-run.'+e)).read_bytes() for e in ['stdout','stderr','rc']) for m in ['int','ext'])
  assert (w/'base-run.stdout').read_bytes()!=(w/'oracle-run.stdout').read_bytes() and b'finally-marker' in (w/'oracle-run.stdout').read_bytes()
 rows.append(dict(name=name,kind=kind,source_sha256=h(p),results=rr,ok=True));print(name,kind,'PASS',flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='12byref numeric/NIL/string sources24exact oracle pairs;6new mixed FINALLY limits12rejections with oracle;4prior numeric FINALLY omissions8base-identical runtime controls,known oracle difference explicitly retained.Oracle driver maps TRY/CATCH/FINALLY/END only.',rows=rows),indent=2))
