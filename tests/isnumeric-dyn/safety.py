from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
text='''function Work()
local i,x:=hb_defaultValue(nil,1.25),s:=hb_defaultValue(nil,Replicate("a",32)),n:=hb_defaultValue(nil,17),u:=hb_defaultValue(nil,nil),l:=hb_defaultValue(nil,.t.)
for i:=1 to 100
if !hb_isnumeric(x) .or. !hb_isnumeric(n) .or. hb_isnumeric(s) .or. hb_isnumeric(u) .or. hb_isnumeric(l)
? "bad tag"
endif
if ValType(x)!="N" .or. ValType(s)!="C"
? "bad retained"
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
shapes={'zero':'? hb_isnumeric()','extra':'? hb_isnumeric(1,2)','call':'? hb_isnumeric(hb_defaultValue(nil,1))','binary':'local n:=1\n? hb_isnumeric(n+2)','date-call':'? hb_isnumeric(SToD("20240229"))','hash-var':'local x:={=>}\n? hb_isnumeric(x)','block-var':'local x:={||1}\n? hb_isnumeric(x)','ref':'local x\n? hb_isnumeric(@x)','byref-parameter':'? Test(hb_defaultValue(nil,1))\nreturn nil\nfunction Test(@x)\n? hb_isnumeric(x)','bad-index':'local a:={1}\n? hb_isnumeric(a["x"])'}
for name,body in shapes.items():
 w=out/name;w.mkdir();p=w/'p.prg';p.write_text('function Main()\n'+body+'\nreturn nil\nfunction Take(x)\n? x\nreturn nil\n');b=run([cc,p,w/'ours','--target=linux'],w,'build');rows.append(dict(name=name,kind='shape-limit',source_sha256=h(p),build_rc=b.returncode,ok=b.returncode==1 and b'panicked' not in b.stderr and not (w/'ours').exists()))
for mode in ['--experimental-llvm','--experimental-llvm-no-trace']:
 w=out/mode;w.mkdir();p=w/'p.prg';p.write_text('function Main()\nlocal x:=hb_defaultValue(nil,1.25)\n? hb_isnumeric(x)\nreturn nil\n');b=run([cc,p,w/'ours','--target=linux',mode],w,'build');rows.append(dict(name=mode,kind='profile-limit',source_sha256=h(p),build_rc=b.returncode,ok=b.returncode==1 and b'panicked' not in b.stderr))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='3 instrumented lifetime modes,10 unsupported forms,2 LLVM profile limits. Dyn variable borrowing only; indexed-cell behavior unchanged.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==15 and all(x['ok'] for x in rows)
