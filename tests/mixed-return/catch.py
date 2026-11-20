from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
cases={
'catch-return':'function Main()\n? Pick(.t.),Pick(.f.)\nreturn nil\nfunction Pick(flag)\nTRY\nBreak("x")\nCATCH e\nif flag\nreturn Replicate("A",64)\nendif\nreturn nil\nEND\nreturn nil\n',
'caller-catch':'function Main()\nlocal a:=Pick(.t.)\nTRY\nBreak("x")\nCATCH e\n? a\nEND\n? a\nreturn nil\nfunction Pick(flag)\nif flag\nreturn Replicate("A",64)\nendif\nreturn nil\n',
'later-arg-throw':'function Main()\nTRY\nShow(Pick(.t.),Fail())\nCATCH e\n? "caught"\nEND\n? "after"\nreturn nil\nfunction Pick(flag)\nif flag\nreturn Replicate("A",64)\nendif\nreturn nil\nfunction Show(a,b)\n? a,b\nreturn nil\nfunction Fail()\nBreak("x")\nreturn 0\n',
'callee-throw':'function Main()\nTRY\n? Pick(.t.)\nCATCH e\n? "caught"\nEND\n? "after"\nreturn nil\nfunction Pick(flag)\nlocal s:=Replicate("A",64)\nif flag\nBreak("x")\nendif\nif flag\nreturn s\nendif\nreturn nil\n'}
for n,s in cases.items():
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  w=out/(n+'-'+mode);w.mkdir();p=w/'p.prg';p.write_text(s);oracle=w/'oracle.prg';oracle.write_text(s.replace('TRY\n','BEGIN SEQUENCE WITH {|o| Break(o)}\n').replace('CATCH e\n','RECOVER\n').replace('END\n','END SEQUENCE\n'));b=run([a.compiler,p,w/'ours','--target=linux',*flags],w,'build');ob=run([a.hbmk2,oracle,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert b.returncode==ob.returncode==0,(n,b.stderr,ob.stderr);q=run([w/'ours'],w,'run');oq=run([w/'oracle'],w,'oracle-run');row=dict(name=n,mode=mode,source_sha256=h(p),oracle_source_sha256=h(oracle),oracle_adapter=True,build_rc=b.returncode,run_rc=q.returncode,oracle_run_rc=oq.returncode,binary_sha256=h(w/'ours'),oracle_binary_sha256=h(w/'oracle'),exact=q.returncode==oq.returncode==0 and (q.stdout,q.stderr)==(oq.stdout,oq.stderr));rows.append(row);(w/'ours').unlink();(w/'oracle').unlink()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='4catch/ownership shapes x2modes exact rc/stdout/stderr,own TRY adapted to Harbour SEQUENCE only.',rows=rows),indent=2));print('PASS',sum(x['exact'] for x in rows),'/',len(rows));assert len(rows)==8 and all(x['exact'] for x in rows)
