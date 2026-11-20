from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
text='function Main()\nlocal i\nWork()\n? hb_memcheck()\nfor i:=1 to 100\nWork()\nnext\n? hb_memcheck()\nreturn nil\nfunction Pick(flag)\nlocal s:=Replicate("A",64)\nif flag\nreturn s\nendif\nreturn nil\nfunction Lit(flag)\nif flag\nreturn "ABCD"\nendif\nreturn nil\nfunction Work()\nlocal i,a,b,c,d,s,z\nfor i:=1 to 100\na:=Pick(.t.)\nb:=Replicate("Z",64)\nif a!=Replicate("A",64)\n? "bad-owner"\nendif\nc:=Lit(.t.)\nd:=Pick(.f.)\nWorkRef()\nnext\nreturn nil\nfunction RefPick(s,flag)\nif flag\nreturn Upper(s)\nendif\nreturn nil\nfunction WorkRef()\nlocal s:=Replicate("B",64),z:=RefPick(@s,.t.)\ns:=Replicate("Z",64)\nif z!=Replicate("B",64)\n? "bad-ref-owner"\nendif\nreturn nil\n'
for name,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
 w=out/name;w.mkdir();p=w/'p.prg';p.write_text(text);b=run([cc,p,w/'ours','--target=linux','--instrument',*flags],w,'build');q=run([w/'ours'],w,'run') if not b.returncode else None;row=dict(name=name,kind='lifetime',source_sha256=h(p),build_rc=b.returncode,ok=bool(q and q.returncode==0 and q.stdout==b'\n         0\n         0' and not q.stderr));rows.append(row)
 if q:row['binary_sha256']=h(w/'ours');(w/'ours').unlink()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='3instrumented100warmup+10000loops mixed-return lifetime modes,cache reuse and BAD-owner guard;not oracle runtime parity of hb_memcheck.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==3 and all(x['ok'] for x in rows)
