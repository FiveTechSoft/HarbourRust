#!/usr/bin/env python3
"""Own MIT memory/unwind and named-boundary checks, no oracle claim."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();cc=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
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
program='function Prompt(x)\n? IIf(x==nil,"default",x)\nreturn nil\nfunction Main()\nPrompt()\nPrompt("hello")\nreturn nil\n'
for name,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('threads',['--target=linux'])]:
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if name=='threads' else '')+program.replace('function Main()\n','function Main()\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else '')));b=run([cc,src,w/'p',*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and b'`iif` branches' in b.stderr and not (w/'p').exists()))
negative={
'array-typed':'function Main()\nlocal a:={},b:={},x\nAAdd(a,1)\nAAdd(b,2)\nx:=IIf(.T.,a,b)\n? Len(x)\nreturn nil\n',
'empty-array-dyn':'function Pick(a)\nlocal x:=IIf(a==nil,{},a)\nreturn Len(x)\nfunction Main()\n? Pick()\nreturn nil\n',
'nested':'function Keep(x)\nreturn x\nfunction Main()\nlocal x:=Keep(nil),y\ny:=IIf(.T.,IIf(.F.,x,nil),x)\n? y\nreturn nil\n',
'argument':'function Keep(x)\nreturn x\nfunction Main()\nlocal x:=Keep(nil)\n? Keep(IIf(.T.,x,"other"))\nreturn nil\n',
}
for name,text in negative.items():
 expected=b'`iif` branches' if name in ['array-typed','empty-array-dyn'] else b'only supported directly'
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(text);b=run([cc,src,w/'p','--target=linux'],w,'build')
 if name=='empty-array-dyn':
  # Superseded rejection: the bounded optional read-only view now admits this exact form.
  ob=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');r=run([w/'p'],w,'run') if b.returncode==0 else None;o=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None
  row=dict(name=name,kind='superseded-rejection-oracle-acceptance',source_sha256=h(src),build_rc=b.returncode,oracle_build_rc=ob.returncode,ok=bool(r and o and r.returncode==o.returncode==0 and r.stdout==o.stdout and r.stderr==o.stderr))
  for label in ['p','oracle']:
   e=w/label
   if e.exists():row[label+'_binary_sha256']=h(e);e.unlink()
  rows.append(row)
 else:rows.append(dict(name=name,kind='shape-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and expected in b.stderr and not (w/'p').exists()))
report=dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Three lifetime modes with1000 string/F64 borrow/own/overwrite loops plus2000 catches, warmup then allocation delta0. Five excluded profiles, three static scope/shape limits, and one visibly superseded rejection now compared exactly to external Harbour. Lifetime counters are not Harbour parity.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));print([x for x in rows if not x['ok']]);assert all(x['ok'] for x in rows)
