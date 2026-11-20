#!/usr/bin/env python3
"""Own MIT memory/unwind and named-boundary checks, no oracle claim."""
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
 row=dict(name=mode,kind='lifetime',source_sha256=h(src),build_rc=b.returncode,ok=bool(r and r.returncode==0 and r.stdout==b'      2000          0 \n' and not r.stderr))
 if r:row['binary_sha256']=h(w/'p');(w/'p').unlink()
 rows.append(row)
program='function Keep(x)\nreturn x\nfunction Main()\nlocal x\n? (x:=Keep(nil))\nreturn nil\n'
for name,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('threads',['--target=linux'])]:
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if name=='threads' else '')+program.replace('function Main()\n','function Main()\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else '')));b=run([cc,src,w/'p',*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and b'inline `:=`' in b.stderr and not (w/'p').exists()))
negative={
'date':'function Main()\nlocal x:=StoD("20260101")\n? (x:=StoD("20260203"))\nreturn nil\n',
'float-static':'function Main()\nlocal x\n? (x:=1.25)\nreturn nil\n',
'string-static':'function Main()\nlocal x\n? (x:=Upper("hello"))\nreturn nil\n',
'byref':'function Keep(x)\nreturn x\nfunction Put(x)\n? (x:=Keep(nil))\nreturn nil\nfunction Main()\nlocal x\nPut(@x)\nreturn nil\n',
}
for name,text in negative.items():
 expected=b'inline `:=`'
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(text);b=run([cc,src,w/'p','--target=linux'],w,'build');rows.append(dict(name=name,kind='shape-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and expected in b.stderr and not (w/'p').exists()))
report=dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Three lifetime modes with1000 string/F64 autocopy/nested/discard loops plus2000 catches, warmup then allocation delta0. Five excluded profiles and four static limits. Not Harbour parity.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));print([x for x in rows if not x['ok']]);assert all(x['ok'] for x in rows)
