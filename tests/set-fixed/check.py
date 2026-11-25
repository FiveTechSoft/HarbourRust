#!/usr/bin/env python3
"""Original MIT. SET FIXED display state, not Str() metadata mutation."""
from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','spec-root','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();out=Path(a.output).resolve();out.mkdir();rows=[]
def run(cmd,w,t,data=b''):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=w,input=data,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(w),stdin_hex=data.hex())));return z
body='''PROCEDURE Main()
LOCAL i:=10,f:=15.1004,n:=-15.1004
? i,10,f,n,Str(f),Str(f,15),Str(f,20,5)
SET FIXED ON
? i,10,f,n,Str(f),Str(f,15),Str(f,20,5)
QQOut(i,10,f,n)
OutStd(i,10,f,n)
OutErr(i,10,f,n)
SET DECIMALS TO 4
? i,10,f,n,Str(f)
SET FIXED OFF
? f,n,Str(f)
? Set(_SET_FIXED),Set(_SET_FIXED,.T.),Set(_SET_FIXED)
? f,n,Str(f)
? Set(_SET_FIXED,NIL),Set(_SET_FIXED,.F.),Set(_SET_FIXED)
RETURN
'''
mixed='''PROCEDURE Main()
LOCAL x:=1,a:={10,20},d:=0d20261125
SET FIXED ON
? x,a[1],a[2],Year(d),Month(d),Day(d)
x:=15.1004
? x
SET FIXED OFF
? x,a[1]
RETURN
'''
sources={'mixed':mixed,'own':body,'dec0':body.replace('TO 4','TO 0'),'dec6':body.replace('TO 4','TO 6'),'numeric-selector':body.replace('_SET_FIXED','2')}
for name,src in sources.items():
 w=out/name;w.mkdir();s=w/'input.prg';s.write_text(src);b=run([a.hbmk2,s,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert b.returncode==0,b.stderr;want=run([w/'oracle'],w,'oracle-run',b'A');(w/'oracle').unlink()
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  b=run([a.compiler,s,w/mode,'--instrument',*flags],w,mode+'-build');got=run([w/mode],w,mode+'-run',b'A')if b.returncode==0 else None;ok=bool(got and (got.returncode,got.stdout,got.stderr)==(want.returncode,want.stdout,want.stderr));rows.append(dict(case=name,mode=mode,exact=ok,build_rc=b.returncode));(w/mode).unlink(missing_ok=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),rows=rows),indent=2));print(sum(r['exact']for r in rows),'/',len(rows));print([r for r in rows if not r['exact']]);raise SystemExit(not all(r['exact']for r in rows))
