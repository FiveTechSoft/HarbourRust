from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,n):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=25)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(n+'.'+e)).write_bytes(b)
 return q
for typ,v in [('string','Replicate("A",64)'),('float','1.25'),('integer','7')]:
 work='function Work()\nlocal x,y,i,e\nfor i:=1 to 100\nx:='+v+'\nTRY\ny:=x++\nCATCH e\nEND\nnext\nreturn nil\n';s='function Main()\nlocal i\nWork()\n? hb_memcheck()\nfor i:=1 to 100\nWork()\nnext\n? hb_memcheck()\nreturn nil\n'+work
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
  w=out/(typ+'-'+mode);w.mkdir();p=w/'p.prg';p.write_text(s);b=run([a.compiler,p,w/'ours','--target=linux','--instrument',*flags],w,'build');q=run([w/'ours'],w,'run') if b.returncode==0 else None;ok=bool(q and q.returncode==0 and q.stdout==b'\n         0\n         0' and not q.stderr);row=dict(name=typ,mode=mode,source_sha256=h(p),build_rc=b.returncode,run_rc=q.returncode if q else None,ok=ok)
  if q:row['binary_sha256']=h(w/'ours');(w/'ours').unlink()
  rows.append(row)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='9instrumented modes100warmup+10000measured attempts,integer writes and string/float reject preserve ownership.CATCH e declared.No oracle parity claim for hb_memcheck.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert all(x['ok'] for x in rows)
