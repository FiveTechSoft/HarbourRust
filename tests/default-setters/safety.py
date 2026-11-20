#!/usr/bin/env python3
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for name,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
 w=out/name;w.mkdir();src=w/'p.prg';src.write_bytes(Path(__file__).with_name('memory.prg').read_bytes());b=run([cc,src,w/'ours','--target=linux','--instrument',*flags],w,'build');q=run([w/'ours'],w,'run') if b.returncode==0 else None
 row=dict(name=name,kind='lifetime',source_sha256=h(src),build_rc=b.returncode,ok=bool(q and q.returncode==0 and q.stdout==b'\n         0\n         0' and not q.stderr))
 if q:row['binary_sha256']=h(w/'ours');(w/'ours').unlink()
 rows.append(row)
for api in ['__defaultNIL','hb_default']:
 prog='function Main()\nlocal x\n'+api+'(@x,7)\nreturn nil\n'
 for profile,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('threads',['--target=linux']),('macro',['--target=linux'])]:
  name=api+'-'+profile;w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if profile=='threads' else '')+prog.replace('local x\n','local x\n'+('local t:=hb_threadStart(@Work())\n' if profile=='threads' else 'local c:="1+2"\n? &(c)\n' if profile=='macro' else '')));b=run([cc,src,w/'ours',*flags],w,'build');rows.append(dict(name=name,kind='profile-limit',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and b'scalar default setters' in b.stderr and not (w/'ours').exists()))
 bodies={'zero':api+'()','one':'local x\n'+api+'(@x)','extra':'local x\n'+api+'(@x,7,8)','no-ref':'local x\n'+api+'(x,7)','typed':'local x:=2\n'+api+'(@x,7)','date':'local x\n'+api+'(@x,SToD("20240229"))','array':'local x\n'+api+'(@x,{1})','hash':'local x\n'+api+'(@x,{=>})','block':'local x\n'+api+'(@x,{||1})','fallback-byref':'local x,y:=1\n'+api+'(@x,@y)','num-local':'local x,y:=1\ny:=1.25\n'+api+'(@x,y)','other-dyn-call':'local x\n'+api+'(@x,Pick())','static':'static x\n'+api+'(@x,7)'}
 for name,body in bodies.items():
  w=out/(api+'-'+name);w.mkdir();src=w/'p.prg';src.write_text(('function Pick()\nlocal v\n? v\nreturn v\n' if name=='other-dyn-call' else '')+'function Main()\n'+body+'\nreturn nil\n');b=run([cc,src,w/'ours','--target=linux'],w,'build');rows.append(dict(name=api+'-'+name,kind='shape-limit',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and b'panicked' not in b.stderr and not (w/'ours').exists()))
 print(api,'checked',flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Three instrumented lifetime modes,10000 iterations and10000 caught nested RHS failures after warmup;12 profile and26 shape limits, not oracle parity.',rows=rows),indent=2))
print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==41 and all(x['ok'] for x in rows)
