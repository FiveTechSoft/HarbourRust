from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();cc=Path(a.compiler);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
text='''function Work()
local i,bit,n:=0
for i:=1 to 100
bit:=i
n:=hb_bitSet(0,bit)
if !hb_bitTest(n,bit)
? "bad set"
endif
if hb_bitReset(n,bit)!=0
? "bad reset"
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
for api in ['hb_bitTest','hb_bitSet','hb_bitReset']:
 for name,decl,arg in [('float','local bit:=1.25','bit'),('bool','local bit:=.t.','bit'),('str','local bit:="1"','bit'),('date','local bit:=SToD("20260102")','bit'),('call','', 'Int(1.25)'),('binary','local bit:=1','bit+1'),('out-ofrange-literal','','64'),('negative-literal','','-1'),('memvar','PRIVATE bit:=1','bit'),('dyn-call','','hb_defaultValue(nil,1)')]:
  w=out/(api+'-'+name);w.mkdir();p=w/'p.prg';p.write_text('function Main()\n'+decl+'\n? '+api+'(0,'+arg+')\nreturn nil\n');b=run([cc,p,w/'ours','--target=linux'],w,'build');rows.append(dict(name=w.name,kind='shape-limit',source_sha256=h(p),build_rc=b.returncode,ok=b.returncode==1 and b'panicked' not in b.stderr and not (w/'ours').exists()))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='3instrumented100warmup+10000loops Dyn modes;30named shape limits.17index values cover modulo64 in positive matrix,not rejected magnitudes. Literal paths outside0..63 retain prior rejection.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==33 and all(x['ok'] for x in rows)
