#!/usr/bin/env python3
"""Own MIT owned-string comma-list lifetime/profile checks."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();cc=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[];hashes={};env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 p=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=20)
 for k,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return p
for mode,flags in [('int',[]),('ext',['--external-as'])]:
 w=out/('memory-'+mode);w.mkdir();src=w/'p.prg';src.write_bytes(Path(__file__).with_name('memory.prg').read_bytes());b=run([cc,src,w/'p','--target=linux','--instrument',*flags],w,'build');p=run([w/'p'],w,'run') if not b.returncode else None
 if p:hashes[str(w/'p')]=h(w/'p');(w/'p').unlink()
 rows.append(dict(name='memory-'+mode,kind='instrumentation',source_sha256=h(src),build_rc=b.returncode,ok=bool(p and p.returncode==0 and p.stdout==b'      2000          0 \n' and not p.stderr)))
reject={
'consumed-final-var':'local c:=Upper("x"),d:=""\nd:=(Take(c),c)\nOutStd(d)',
'consumed-nested':'local c:=Upper("x"),d:=""\nd:=(Take(c),(1,c))\nOutStd(d)',
'consumed-in-final-call':'local c:=Upper("x"),d:=""\nd:=(1,Take(c))\nOutStd(c,d)',
'array-prefix':'OutStd(({1,2},Upper("x")))',
'array-final':'local d\nd:=(Upper("x"),{1,2})',
'block-prefix':'OutStd(({||1},Upper("x")))',
'block-final':'local d\nd:=(Upper("x"),{||1})',
'dyn-temporary-prefix':'OutStd((DynRet(),Upper("x")))',
'valtype-seq-limit':'OutStd(ValType((1,Upper("x"))))',
'nonempty-slot-call-limit':'local c:="x"\nc:=(1,Upper(c))',
'nonempty-slot-nested-call-limit':'local c:="x"\nc:=(1,(2,Upper(c)))',
}
for name,body in reject.items():
 w=out/('reject-'+name);w.mkdir();src=w/'p.prg';src.write_text('function Take(c)\nreturn c+"!"\nfunction DynRet()\nlocal d\nreturn d\nfunction Main()\n'+body+'\nreturn nil\n');b=run([cc,src,w/'p','--target=linux'],w,'build');rows.append(dict(name='reject-'+name,kind='rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and not (w/'p').exists()))
for name,flags in [('PE',['--target=windows']),('Darwin',['--target=macho']),('ARM64',['--target=macho-arm64']),('LLVM',['--target=linux','--experimental-llvm']),('LLVM-no-trace',['--target=linux','--experimental-llvm-no-trace']),('threads',['--target=linux'])]:
 w=out/('profile-'+name);w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if name=='threads' else '')+'function Main()\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else '')+'OutStd((1,Upper("x")))\nreturn nil\n');b=run([cc,src,w/'p',*flags],w,'build');rows.append(dict(name='profile-'+name,kind='profile',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and not (w/'p').exists()))
report=dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Instrumentation is not a Harbour oracle comparison. Each memory run has1000loopiterations,2000catches,warmup,andzero outstanding allocation delta. Rejections are compile checks only.',passed=sum(x['ok'] for x in rows),total=len(rows),rows=rows,binary_hashes=hashes);(out/'results.json').write_text(json.dumps(report,indent=2));print(report['passed'],'/',report['total']);print([x for x in rows if not x['ok']]);assert all(x['ok'] for x in rows)
