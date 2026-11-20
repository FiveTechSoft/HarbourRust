from pathlib import Path
import subprocess,json,hashlib,argparse,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir(exist_ok=False);rows=[];cc=Path(a.compiler);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
programs={'array':'function Main()\nlocal x,y\nx:={1,"canary"}\ny:=IIf(.T.,x,nil)\n? y\nreturn nil\n','array-try':'function Main()\nlocal x,y\nx:={1,"canary"}\nTRY\ny:=IIf(.T.,x,nil)\n? y\nCATCH e\n? "caught"\nEND\nreturn nil\n'}
for name,text in programs.items():
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  w=out/(name+'-'+mode);w.mkdir();src=w/'p.prg';src.write_text(text);b=subprocess.run([str(cc),str(src),str(w/'p'),'--target=linux',*flags],capture_output=True,env=env);(w/'build.stderr').write_bytes(b.stderr);assert b.returncode==0,b.stderr;q=subprocess.run([w/'p'],capture_output=True)
  for k,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/('run.'+k)).write_bytes(v)
  rows.append(dict(name=name,mode=mode,build_rc=b.returncode,run_rc=q.returncode,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),binary_sha256=hashlib.sha256((w/'p').read_bytes()).hexdigest(),ok=q.returncode==1 and b'Limit: Dyn IIF arms support scalar values only in this increment\n' in q.stdout and b'caught' not in q.stdout and b'NIL used as a number' not in q.stdout and not q.stderr));(w/'p').unlink();print(name,mode,rows[-1]['ok'],repr(q.stdout))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),scope='Runtime container limit, explicit fatal diagnostic int/ext, outside/inside TRY. Not Harbour error parity.',rows=rows),indent=2));assert all(x['ok'] for x in rows)
