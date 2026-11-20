#!/usr/bin/env python3
"""Own MIT lifetime, profile and shape boundaries, no oracle parity claim."""
from pathlib import Path
import argparse,hashlib,json,subprocess,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
for mode,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
 w=out/mode;w.mkdir();src=w/'p.prg';src.write_bytes(Path(__file__).with_name('memory.prg').read_bytes());b=run([cc,src,w/'p','--target=linux','--instrument',*flags],w,'build');r=run([w/'p'],w,'run') if not b.returncode else None
 row=dict(name=mode,kind='lifetime',source_sha256=h(src),build_rc=b.returncode,ok=bool(r and r.returncode==0 and r.stdout==b'      3000          0 \n' and not r.stderr))
 if r:row['binary_sha256']=h(w/'p');(w/'p').unlink()
 rows.append(row)
program='function Main()\n? hb_defaultValue(nil,7)\nreturn nil\n'
for name,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('threads',['--target=linux']),('macro',['--target=linux'])]:
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if name=='threads' else '')+program.replace('function Main()\n','function Main()\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else 'local c:="1+2"\n? &(c)\n' if name=='macro' else '')));b=run([cc,src,w/'p',*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and b'hb_defaultValue' in b.stderr and not (w/'p').exists()))
negative={
'zero':'? hb_defaultValue()',
'one':'? hb_defaultValue(1)',
'extra':'? hb_defaultValue(1,2,3)',
'date':'? hb_defaultValue(SToD("20260203"),1)',
'array':'? hb_defaultValue({1},1)',
'hash':'? hb_defaultValue({=>},1)',
'block':'? hb_defaultValue({||1},1)',
'byref':'local x:=1\n? hb_defaultValue(@x,1)',
'num-local':'local x:=1\nx:=1.25\n? hb_defaultValue(x,2)',
'dyn-call':'local x,dummy:=Keep(nil)\n? hb_defaultValue(Keep(x),2)',
'dyn-inline':'local x\n? hb_defaultValue((x:=x),2)',
}
for name,body in negative.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Keep(x)\nreturn x\n' if name=='dyn-call' else '')+'function Main()\n'+body+'\nreturn nil\n');b=run([cc,src,w/'p','--target=linux'],w,'build');rows.append(dict(name=name,kind='shape-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and not (w/'p').exists()))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Three instrumented 1000-loop modes: string reuse, selected/fallback snapshots, F64, self-copy, nesting/discard and1000 caught nested RHS failures, warmupdelta0; six profiles and eleven shape limits. Not oracle parity.',rows=rows),indent=2));print([x for x in rows if not x['ok']]);assert all(x['ok'] for x in rows)
