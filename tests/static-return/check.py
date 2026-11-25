#!/usr/bin/env python3
"""Original MIT. Function-local STATIC string persistence and identity."""
from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','spec-root','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();out=Path(a.output).resolve();out.mkdir();rows=[]
def run(cmd,w,t,data=b''):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=w,input=data,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(w),stdin_hex=data.hex())));return z
sources={
'detached':'PROCEDURE Main()\nLOCAL b:=Make(),c:=Make()\n? Eval(b,1)\n? Eval(c,2)\n? Eval(b,3)\nRETURN\nFUNCTION Make()\nSTATIC n:=100\nRETURN {|x|++n,x+n}\n',
'module':'STATIC n:=20\nPROCEDURE Main()\nLOCAL b:=Make()\n? Eval(b,1)\nn:=50\n? Eval(b,2)\nRETURN\nFUNCTION Make()\nRETURN {|x|++n,x+n}\n',
'passed':'PROCEDURE Main()\nLOCAL b:=Make()\n? ApplyBlock(b,1)\n? ApplyBlock(b,2)\nRETURN\nFUNCTION Make()\nSTATIC n:=100\nRETURN {|x|++n,x+n}\nFUNCTION ApplyBlock(b,x)\nRETURN Eval(b,x)\n'}
for name,src in sources.items():
 w=out/name;w.mkdir();s=w/'input.prg';s.write_text(src);b=run([a.hbmk2,s,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert b.returncode==0,b.stderr;want=run([w/'oracle'],w,'oracle-run',b'A');(w/'oracle').unlink()
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  b=run([a.compiler,s,w/mode,'--instrument',*flags],w,mode+'-build');got=run([w/mode],w,mode+'-run',b'A')if b.returncode==0 else None;ok=bool(got and (got.returncode,got.stdout,got.stderr)==(want.returncode,want.stdout,want.stderr));rows.append(dict(case=name,mode=mode,exact=ok,build_rc=b.returncode));(w/mode).unlink(missing_ok=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),rows=rows),indent=2));print(sum(r['exact']for r in rows),'/',len(rows));print([r for r in rows if not r['exact']]);raise SystemExit(not all(r['exact']for r in rows))
