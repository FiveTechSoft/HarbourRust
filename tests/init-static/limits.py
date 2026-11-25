from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();rows=[]
sources={
'value-return':('PROCEDURE Main()\nRETURN\nINIT FUNCTION Hook()\nSTATIC n:=1\nRETURN 42\n','INIT procedures require bare/NIL returns'),
'windows':('PROCEDURE Main()\nRETURN\nINIT PROCEDURE Hook()\nSTATIC n:=1\n? n\nRETURN\n','INIT STATIC platform guard'),
'float':('PROCEDURE Main()\nRETURN\nINIT PROCEDURE Hook()\nSTATIC n:=1.5\n? n\nRETURN\n',None),
'threads':('PROCEDURE Main()\nLOCAL th,r\nth:=hb_threadStart({|n|n+1},1)\nhb_threadJoin(th,@r)\nRETURN\nINIT PROCEDURE Hook()\nSTATIC n:=1\n? n\nRETURN\n','INIT STATIC thread guard'),
'macro':('PROCEDURE Main()\nLOCAL c:="1"\n? &c\nRETURN\nINIT PROCEDURE Hook()\nSTATIC n:=1\n? n\nRETURN\n','INIT STATIC platform guard'),
'params':('PROCEDURE Main()\nRETURN\nINIT PROCEDURE Hook(n)\n? n\nRETURN\n','INIT procedures with parameters')}
for name,(src,diag)in sources.items():
 w=out/name;w.mkdir();s=w/'input.prg';s.write_text(src);cmd=[a.compiler,str(s),str(w/'out'),'--target=windows'if name=='windows'else'--target=linux'];z=subprocess.run(cmd,capture_output=True)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/('build.'+k)).write_bytes(b)
 (w/'build.command.json').write_text(json.dumps(dict(argv=cmd,cwd=str(Path.cwd()))));ok=z.returncode==1 and diag is not None and diag.encode()in z.stderr
 if name=='float':ok=z.returncode==1 and b'float/hash initializers remain outside this increment'in z.stderr
 rows.append(dict(case=name,ok=ok,rc=z.returncode,diagnostic=z.stderr.decode(errors='replace')))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),rows=rows),indent=2));print(rows);raise SystemExit(not all(r['ok']for r in rows))
