from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
text='''function Work()
local i,s:=hb_BChar(65),z:=Upper("zzzzzzzz")
for i:=1 to 100
s:=hb_BChar(i)
if hb_BCode(s)!=i
? "bad retained byte"
endif
if hb_BCode(hb_BChar(i+256))!=i
? "bad temporary byte"
endif
if hb_BCode(Upper("abcdefgh"))!=65
? "bad temporary string"
endif
if hb_BCode("")!=0
? "bad empty"
endif
next
return nil
function Main()
local i
Work()
? hb_memcheck()
for i:=1 to 100
Work()
next
? hb_memcheck()
return nil
'''
for name,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
 w=out/name;w.mkdir();p=w/'p.prg';p.write_text(text);b=run([cc,p,w/'ours','--target=linux','--instrument',*flags],w,'build');q=run([w/'ours'],w,'run') if not b.returncode else None;row=dict(name=name,kind='lifetime',source_sha256=h(p),build_rc=b.returncode,ok=bool(q and q.returncode==0 and q.stdout==b'\n         0\n         0' and not q.stderr));rows.append(row)
 if q:row['binary_sha256']=h(w/'ours');(w/'ours').unlink()
for api in ['hb_BChar','hb_BCode']:
 shapes={'zero':'? '+api+'()','extra':'? '+api+'(1,2)','date':'? '+api+'(SToD("20240229"))','array':'? '+api+'({1})','hash':'? '+api+'({=>})','block':'? '+api+'({||1})','byref':'local x\n? '+api+'(@x)','nil':'? '+api+'(nil)','bool':'? '+api+'(.T.)','float':'? '+api+'(65.9)','dyn-int':'local x\nx:=65\n? '+api+'(x)','dyn-string':'local x\nx:="abc"\n? '+api+'(x)','dyn-default':'? '+api+'(hb_defaultValue(nil,65))','opposite-static':'? '+api+'('+('"65"' if api=='hb_BChar' else '65')+')','override':'function '+api+'(x)\nreturn x\nfunction Main()\nreturn nil\n'}
 for name,body in shapes.items():
  w=out/(api+'-'+name);w.mkdir();p=w/'p.prg';p.write_text(body if name=='override' else 'function Main()\n'+body+'\nreturn nil\n');b=run([cc,p,w/'ours','--target=linux'],w,'build');rows.append(dict(name=api+'-'+name,kind='shape-limit',source_sha256=h(p),build_rc=b.returncode,ok=b.returncode==1 and b'panicked' not in b.stderr and not (w/'ours').exists()))
for api,arg in [('hb_BChar','65'),('hb_BCode','"abc"')]:
 for mode in ['--experimental-llvm','--experimental-llvm-no-trace']:
  w=out/(api+mode);w.mkdir();p=w/'p.prg';p.write_text('function Main()\n? '+api+'('+arg+')\nreturn nil\n');b=run([cc,p,w/'ours','--target=linux',mode],w,'build');rows.append(dict(name=api+mode,kind='existing-llvm-limit',source_sha256=h(p),build_rc=b.returncode,ok=b.returncode==1 and b'LLVM scalar: expression unsupported:' in b.stderr and b'panicked' not in b.stderr))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='3 instrumented100warmup+10000loop lifetime modes;30 typed-shape/name rejections and4 existing LLVM-expression limits. No F64/Dyn/default coercion promised. No runtime-invalid-type equality claim.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==37 and all(x['ok'] for x in rows)
