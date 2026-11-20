#!/usr/bin/env python3
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for name,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
 w=out/name;w.mkdir();p=w/'p.prg';p.write_bytes(Path(__file__).with_name('memory.prg').read_bytes());b=run([cc,p,w/'ours','--target=linux','--instrument',*flags],w,'build');q=run([w/'ours'],w,'run') if not b.returncode else None;row=dict(name=name,kind='lifetime',source_sha256=h(p),build_rc=b.returncode,ok=bool(q and q.returncode==0 and q.stdout==b'\n         0\n         0' and not q.stderr))
 if q:row['binary_sha256']=h(w/'ours');(w/'ours').unlink()
 rows.append(row)
for api in ['Lower','Upper','AllTrim']:
 prog='function Main()\nlocal x\nx:="aBc"\n? '+api+'(x)\nreturn nil\n'
 for name,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('threads',['--target=linux']),('macro',['--target=linux'])]:
  w=out/(api+'-'+name);w.mkdir();p=w/'p.prg';p.write_text(('function Work()\nreturn 1\n' if name=='threads' else '')+prog.replace('local x\n','local x\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else 'local c:="1+2"\n? &(c)\n' if name=='macro' else '')));b=run([cc,p,w/'ours',*flags],w,'build');rows.append(dict(name=api+'-'+name,kind='profile-limit',source_sha256=h(p),build_rc=b.returncode,ok=b.returncode==1 and b'Dyn string consumers' in b.stderr and not (w/'ours').exists()))
 shapes={'zero':'? '+api+'()','extra':'? '+api+'("x",1)','date':'? '+api+'(SToD("20240229"))','array':'? '+api+'({1})','hash':'? '+api+'({=>})','block':'? '+api+'({||1})','byref':'local x\n? '+api+'(@x)','num-local':'local x:=1\nx:=1.25\n? '+api+'(x)','other-dyn-call':'? '+api+'(Pick())','inline-dyn':'local x\n? '+api+'((x:=hb_defaultValue(nil,"x")))','sequence-dyn':'? '+api+'((1,hb_defaultValue(nil,"x")))'}
 for name,body in shapes.items():
  w=out/(api+'-'+name);w.mkdir();p=w/'p.prg';p.write_text(('function Pick()\nlocal x\n? x\nreturn x\n' if name=='other-dyn-call' else '')+'function Main()\n'+body+'\nreturn nil\n');b=run([cc,p,w/'ours','--target=linux'],w,'build');rows.append(dict(name=api+'-'+name,kind='shape-limit',source_sha256=h(p),build_rc=b.returncode,ok=b.returncode==1 and b'panicked' not in b.stderr and not (w/'ours').exists()))
 print(api,'checked',flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Three instrumented10000loop modes with10000 caught nested RHS failures after warmup,18 profile and33 shape limits. Not oracle equality.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==54 and all(x['ok'] for x in rows)
