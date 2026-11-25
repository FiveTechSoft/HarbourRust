from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();rows=[]
sources={
'local':('PROCEDURE Main()\nLOCAL n:=1,b:={|x|++n,x+n}\n? Eval(b,1)\nRETURN\n','persistent integer Eval capture guard'),
'mixed':('PROCEDURE Main()\nSTATIC n:=1\nLOCAL k:=2,b:={|x|++n,x+n+k}\n? Eval(b,1)\nRETURN\n','persistent integer Eval capture guard'),
'returned':('PROCEDURE Main()\nLOCAL b:=Make()\n? Eval(b,1)\nRETURN\nFUNCTION Make()\nSTATIC n:=1\nRETURN {|x|++n,x+n}\n','codeblocks cannot be returned'),
'windows':('PROCEDURE Main()\nSTATIC n:=1\nLOCAL b:={|x|++n,x+n}\n? Eval(b,1)\nRETURN\n','codeblock captures'),
'nested':('STATIC n:=10\nPROCEDURE Main()\nLOCAL b:={|x|Eval({|y|++n,n+y},x)}\n? Eval(b,1)\nRETURN\n','persistent integer Eval capture guard'),
'float':('PROCEDURE Main()\nSTATIC n:=1.5\nLOCAL b:={|x|n+x}\n? Eval(b,1)\nRETURN\n',None)}
for name,(src,diag)in sources.items():
 w=out/name;w.mkdir();s=w/'input.prg';s.write_text(src);cmd=[a.compiler,str(s),str(w/'out'),'--target=windows'if name=='windows'else'--target=linux'];z=subprocess.run(cmd,capture_output=True)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/('build.'+k)).write_bytes(b)
 (w/'build.command.json').write_text(json.dumps(dict(argv=cmd,cwd=str(Path.cwd()))));ok=z.returncode==1 and diag is not None and diag.encode()in z.stderr
 if name=='float':ok=z.returncode==1 and b'float/hash initializers remain outside this increment'in z.stderr
 rows.append(dict(case=name,ok=ok,rc=z.returncode,diagnostic=z.stderr.decode(errors='replace')))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),rows=rows),indent=2));print(rows);raise SystemExit(not all(r['ok']for r in rows))
