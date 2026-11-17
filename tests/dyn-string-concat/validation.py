#!/usr/bin/env python3
"""Production front-end guard order: invalid source stays rc1, never panic."""
from pathlib import Path
import argparse,subprocess,json,hashlib,sys
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--tree',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();compiler=str(Path(a.compiler).resolve());out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
cases={
'unknown':('Missing()+"!"','unknown function `missing`'),
'iif-zero':('IIF()+"!"','`iif` takes 3 arguments, got 0'),
'iif-short':('IIF(.t.)+"!"','`iif` takes 3 arguments, got 1'),
'min-zero':('Min()+"!"','`min` takes two arguments'),
'left-zero':('Left()+"!"','`left` takes two arguments'),
'eval-zero':('Eval()+"!"','`eval` needs a codeblock'),
'nested-unknown':('Upper(Missing()+"!")','unknown function `missing`'),
'left-dyn-invalid':('Left(d)+"!"','`left` takes two arguments'),
'iif-dyn-invalid':('IIF(.t.,d)+"!"','`iif` takes 3 arguments, got 2'),
'array-unknown-index':('xs[Missing()]+"!"','unknown function `missing`'),
}
def raw(src,w,label):
 r=subprocess.run([compiler,str(src),str(w/(label+'.out'))],capture_output=True,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
for name,(expr,diag) in cases.items():
 w=out/name;w.mkdir();results=[]
 for wrapped in [False,True]:
  label='wrapped' if wrapped else 'direct';src=w/(label+'.prg');src.write_text('EXTERNAL Take\nfunction main()\nlocal d,xs:={"cell",NIL}\nd:="owned"\n'+('Take('+expr+')' if wrapped else '? '+expr)+'\nreturn nil\n');r=raw(src,w,label);results.append(r)
 ok=all(r.returncode==1 and diag.encode() in r.stderr and b'panicked' not in r.stderr for r in results) and results[0].stderr==results[1].stderr
 rows.append(dict(test=name,pass_=ok,diagnostic=diag));print(rows[-1],flush=True)
# Validate all arguments before producer guards: a later malformed argument
# owns the diagnostic even if an earlier concat would be a named limit.
w=out/'later-invalid';w.mkdir();src=w/'probe.prg';src.write_text('EXTERNAL Take\nfunction main()\nlocal d\nd:="owned"\nTake(d+"!",IIF())\nreturn nil\n');r=raw(src,w,'build');rows.append(dict(test='later-invalid',pass_=r.returncode==1 and b'`iif` takes 3 arguments, got 0' in r.stderr))
# Forward return inference must settle before post-check producer inspection.
extra='function Later()\nlocal d\nd:="owned"\nreturn d\n'
for name,statement,diag in [('forward-limit','Take(Later()+"!")','Dyn/string concat temporary across C Extend is not in this increment'),('forward-static','Take(StaticLater()+"!")',None)]:
 w=out/name;w.mkdir();src=w/'probe.prg';src.write_text('EXTERNAL Take\nfunction main()\n'+statement+'\nreturn nil\n'+extra+'function StaticLater()\nreturn "string"\n');r=raw(src,w,'build')
 # A valid external is intentionally not linked in this probe. Emit asm
 # to prove validation reaches the boundary without needing a C object.
 if diag is None:
  r=subprocess.run([compiler,str(src),str(w/'valid.s')],capture_output=True,timeout=30)
  for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/('emit.'+ext)).write_bytes(v)
 ok=(r.returncode==1 and diag.encode() in r.stderr) if diag else r.returncode==0
 rows.append(dict(test=name,pass_=ok));print(rows[-1],flush=True)
r=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(Path(compiler).read_bytes()).hexdigest(),total=len(rows),passed=sum(x['pass_'] for x in rows),rows=rows);(out/'results.json').write_text(json.dumps(r,indent=2));sys.exit(0 if r['total']==r['passed'] else 1)
