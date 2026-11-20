#!/usr/bin/env python3
"""Own MIT empty-array return lifetime/profile checks."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();cc=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[];hashes={};env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 p=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=20)
 for k,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return p
for mode,flags in [('int',[]),('ext',['--external-as']),('int-no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
 w=out/('memory-'+mode);w.mkdir();src=w/'p.prg';src.write_bytes(Path(__file__).with_name('memory.prg').read_bytes());b=run([cc,src,w/'p','--target=linux','--instrument',*flags],w,'build');p=run([w/'p'],w,'run') if not b.returncode else None
 if p:hashes[str(w/'p')]=h(w/'p');(w/'p').unlink()
 rows.append(dict(name='memory-'+mode,kind='instrumentation',source_sha256=h(src),build_rc=b.returncode,ok=bool(p and p.returncode==0 and p.stdout==b'      1000          0 \n' and not p.stderr)))
for mode,flags in [('flat-vas',[]),('flat-no-vas',['--no-vas-arrays'])]:
 w=out/mode;w.mkdir();src=w/'p.prg';src.write_text('function E()\nlocal a:={}\nreturn a\nfunction W()\nlocal i,x:=0\nfor i:=1 to 1000\nx:=Len(E())+Len({})\nnext\nreturn x\nfunction Main()\nlocal b\nW()\nb:=hb_memcheck()\nOutStd(W(),hb_memcheck()-b,Chr(10))\nreturn nil\n');b=run([cc,src,w/'p','--target=linux','--instrument',*flags],w,'build');p=run([w/'p'],w,'run') if not b.returncode else None
 if p:hashes[str(w/'p')]=h(w/'p');(w/'p').unlink()
 rows.append(dict(name=mode,kind='instrumentation-flat',source_sha256=h(src),build_rc=b.returncode,ok=bool(p and p.returncode==0 and p.stdout==b'         0          0 \n' and not p.stderr)))
reject={
'moved-after-return':'local a:=EmptyA()\nAAdd(a,7)\nTake(a)\n? Len(a)',
'nonempty-literal-return':'? Len(Nonempty())',
'nonempty-local-temporary':'? Len(Pinned())',
'mixed-empty-int-return':'? Len(Mixed(0))',
'print-temporary':'? EmptyA()',
'empty-discard-call':'EmptyA()',
'generic-unpinned-param':'local a:=EmptyA()\n? Borrow(a)',
'empty-asize-unpinned':'local a:=EmptyA()\nASize(a,3)',
'empty-element-read':'local a:=EmptyA()\n? a[1]',
}
helpers={
'moved-after-return':'function Take(a)\nAAdd(a,7)\nreturn nil\n',
'nonempty-literal-return':'function Nonempty()\nreturn {1,2}\n',
'nonempty-local-temporary':'function Pinned()\nlocal a:={}\nAAdd(a,1)\nreturn a\n',
'mixed-empty-int-return':'function Mixed(n)\nlocal a:={}\nif n==0\nreturn a\nendif\nreturn 1\n',
'generic-unpinned-param':'function Borrow(a)\nreturn Len(a)\n',
}
empty='function EmptyA()\nlocal a:={}\nreturn a\n'
for name,body in reject.items():
 w=out/('reject-'+name);w.mkdir();src=w/'p.prg';src.write_text(empty+helpers.get(name,'')+'function Main()\n'+body+'\nreturn nil\n');b=run([cc,src,w/'p','--target=linux'],w,'build');rows.append(dict(name='reject-'+name,kind='rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and not (w/'p').exists()))
for name,flags in [('PE',['--target=windows']),('Darwin',['--target=macho']),('ARM64',['--target=macho-arm64']),('LLVM',['--target=linux','--experimental-llvm']),('LLVM-no-trace',['--target=linux','--experimental-llvm-no-trace']),('threads',['--target=linux'])]:
 w=out/('profile-'+name);w.mkdir();src=w/'p.prg';src.write_text('function EmptyA()\nlocal a:={}\nreturn a\n'+('function Work()\nreturn 1\n' if name=='threads' else '')+'function Main()\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else '')+'OutStd(Len(EmptyA()))\nreturn nil\n');b=run([cc,src,w/'p',*flags],w,'build');rows.append(dict(name='profile-'+name,kind='profile',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and not (w/'p').exists()))
report=dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Instrumentation is not a Harbour oracle comparison. Each memory run has1000loopiterations,1000catches,warmup,andzero outstanding allocation delta. Rejections are compile checks only.',passed=sum(x['ok'] for x in rows),total=len(rows),rows=rows,binary_hashes=hashes);(out/'results.json').write_text(json.dumps(report,indent=2));print(report['passed'],'/',report['total']);print([x for x in rows if not x['ok']]);assert all(x['ok'] for x in rows)
