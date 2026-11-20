#!/usr/bin/env python3
"""Own MIT Date storage boundaries and instrumented repeated unwinding."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();cc=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),env=env,capture_output=True,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
for mode,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
 w=out/mode;w.mkdir();src=w/'p.prg';src.write_bytes(Path(__file__).with_name('memory.prg').read_bytes());b=run([cc,src,w/'p','--target=linux','--instrument',*flags],w,'build');r=run([w/'p'],w,'run') if not b.returncode else None
 row=dict(name=mode,kind='lifetime',source_sha256=h(src),build_rc=b.returncode,ok=bool(r and r.returncode==0 and r.stdout==b'      1000          0 \n' and not r.stderr))
 if r:row['binary_sha256']=h(w/'p');(w/'p').unlink()
 rows.append(row)
program='function Main()\nlocal d\n? (d:=StoD("20260203")),d\nreturn nil\n'
for name,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('threads',['--target=linux'])]:
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if name=='threads' else '')+program.replace('function Main()\n','function Main()\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else '')));b=run([cc,src,w/'p',*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and not (w/'p').exists()))
negative={
'early-read':'local d\n? d,ValType(d)\nd:=StoD("20260203")\n? d',
'conditional':'local d\nif .F.\nd:=StoD("20260203")\nendif\n? d,ValType(d)',
'loop-first':'local d,i\nfor i:=1 to 0\nd:=StoD("20260203")\nnext\n? d,ValType(d)',
'early-inline-read':'local d\n? d,(d:=StoD("20260203"))',
'early-block':'local d,b:={||d}\nd:=StoD("20260203")\n? Eval(b)',
'early-hash':'local d,h:={"x"=>d}\nd:=StoD("20260203")\n? h["x"]',
'early-index':'local d,a:={1}\n? a[Len(d)]\nd:=StoD("20260203")',
'early-return':'local d\nif .T.\nreturn d\nendif\nd:=StoD("20260203")\n? d',
'self-rhs':'local d\nd:=CToD(d)\n? d',
'later-nil':'local d\nd:=StoD("20260203")\nd:=nil\n? d',
'later-number':'local d\nd:=StoD("20260203")\nd:=2\n? d',
'discard':'local d:=StoD("")\n(d:=StoD("20260203"))\n? d',
'comma':'local d:=StoD("")\n? ((d:=StoD("20260203")),d)',
'branch-inline-first':'local d\n? IIf(.F.,(d:=StoD("20260203")),d)',
'macro-excluded':'local d,c:="1+2"\n? &(c)\nd:=StoD("20260203")\n? d',
'byref-local-excluded':'local d\nd:=StoD("20260203")\nTouch(@d)\n? d',
}
for name,body in negative.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Touch(d)\nreturn d\n' if name=='byref-local-excluded' else '')+'function Main()\n'+body+'\nreturn nil\n');b=run([cc,src,w/'p','--target=linux'],w,'build');rows.append(dict(name=name,kind='shape-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and not (w/'p').exists()))
report=dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Three instrumented modes,1000 immutable Date overwrites and1000 failed RHS catches, old Date unchanged, warmup delta0. Five excluded profiles and16 bounded-shape exclusions. Not Harbour parity.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));print([x for x in rows if not x['ok']]);assert all(x['ok'] for x in rows)
