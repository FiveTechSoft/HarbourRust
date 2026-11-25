#!/usr/bin/env python3
"""Original MIT. Counted literal WAIT prompt, unchanged oracle source and bytes."""
from pathlib import Path
import argparse, subprocess, json, hashlib, os
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();out=Path(a.output).resolve();out.mkdir();rows=[];commands=[];bins={}
def run(cmd,w,t,data=b''):
 cmd=list(map(str,cmd));commands.append(dict(argv=cmd,cwd=str(w),stdin_hex=data.hex(),tag=t))
 try:z=subprocess.run(cmd,cwd=w,input=data,capture_output=True,timeout=5,env=dict(os.environ,TZ='UTC'))
 except subprocess.TimeoutExpired as e:z=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 return z
prompts=[r'"custom:"','""','" "','"Press any key to continue..."',r'e"abc\rZ"',r'e"abc\bZ"',r'e"a\nb"',r'e"a\tb"',r'e"a\fb"',r'e"a\ab"','"áéñ"','"'+('x'*90)+'"']
# Escape strings stay single literal tokens; expressions remain named limits.
for i,prompt in enumerate(prompts):
 w=out/str(i);w.mkdir();src=w/'input.prg';src.write_text('PROCEDURE Main()\n? "before"\nWAIT '+prompt+'\n?? Chr(8)+"X"\n? "after"\nRETURN\n');want={}
 for mode,flags in [('oracle',None),('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  exe=w/mode;cmd=[a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(exe)] if flags is None else [a.compiler,src,exe,'--target=linux','--instrument',*flags]
  b=run(cmd,w,mode+'-build')
  for key in [b' ',b'A',b'Z',b'~']:
   got=run([exe],w,mode+'-'+key.hex(),key) if b.returncode==0 else None
   if mode=='oracle':want[key]=got
   else:
    ref=want[key];ok=bool(b.returncode==0 and got and ref and (got.returncode,got.stdout,got.stderr)==(ref.returncode,ref.stdout,ref.stderr) and got.returncode==0 and not got.stderr);rows.append(dict(case=i,prompt=prompt,mode=mode,key=key.hex(),exact=ok,build_rc=b.returncode))
  if exe.exists():bins[str(exe.relative_to(out))]=hashlib.sha256(exe.read_bytes()).hexdigest();exe.unlink()
(out/'commands.json').write_text(json.dumps(commands,indent=2));(out/'binary-shas.json').write_text(json.dumps(bins,indent=2));(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),rows=rows),indent=2));print('PASS',sum(r['exact']for r in rows),'/',len(rows));print([r for r in rows if not r['exact']][:8]);raise SystemExit(not all(r['exact']for r in rows))
