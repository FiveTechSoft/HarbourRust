#!/usr/bin/env python3
"""Original MIT. Linux integration with unchanged source and external Harbour oracle."""
from pathlib import Path
import argparse,hashlib,hmac,json,subprocess
ap=argparse.ArgumentParser()
for n in ['compiler','hbmk2','harbour-core','output']:ap.add_argument('--'+n,required=True)
a=ap.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();rows=[];hashes={};commands=[]
def run(cmd,w,tag):
 commands.append(dict(argv=list(map(str,cmd)),cwd=str(w),tag=tag))
 try:p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,timeout=30)
 except subprocess.TimeoutExpired as e:p=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for e,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(tag+'.'+e)).write_bytes(b)
 return p

def cleanup(w):
 for name in ['oracle','int','ext']:
  p=w/name
  if p.exists():hashes[str(p.relative_to(out))]=hashlib.sha256(p.read_bytes()).hexdigest();p.unlink()

def case(name,source,expected=None):
 w=out/name;w.mkdir();s=w/'p.prg';s.write_text(source);ob=run([a.hbmk2,s,'-quiet','-gtstd','-w0','-ooracle'],w,'oracle-build');o=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  b=run([cc,s,w/mode,'--target=linux','--instrument',*flags],w,mode+'-build');r=run([w/mode],w,mode+'-run') if b.returncode==0 else None
  ok=bool(o and r and o.returncode==r.returncode==0 and o.stdout==r.stdout and o.stderr==r.stderr==b'' and (expected is None or r.stdout==expected));rows.append(dict(name=name+'-'+mode,ok=ok,kind='oracle-exact',source_sha256=hashlib.sha256(s.read_bytes()).hexdigest(),build_rc=b.returncode,oracle_build_rc=ob.returncode,run_rc=r.returncode if r else None))
  if not ok:print('FAIL',name,mode,'build-rejected' if b.returncode else 'runtime-diff',flush=True)
 cleanup(w)
def expr(b):return '+'.join('Chr('+str(x)+')' for x in b) if b else '""'
# Each program produces both representations, counted raw then hex. OutStd
# deliberately isolates the algorithm from presentation; the unchanged original
# separately checks both raw digests through QOut/GTSTD.
for n in [0,1,2,20,55,56,57,63,64,65,127,128,129,255,256,1000]:
 m=bytes((i*37+11)%256 for i in range(n));data='Left(Replicate('+expr(bytes((i*37+11)%256 for i in range(256)))+','+str((n+255)//256)+'),'+str(n)+')'
 case('sha-'+str(n),'function Main()\nlocal s:='+data+'\nOutStd(hb_SHA1(s,.T.),hb_SHA1(s,.F.),hb_SHA1(s))\nreturn nil\n',hashlib.sha1(m).digest()+b' '+hashlib.sha1(m).hexdigest().encode()+b' '+hashlib.sha1(m).hexdigest().encode())
 for kn in [0,1,20,63,64,65,100,1000]:
  k=bytes((i*17+3)%256 for i in range(kn));key='Left(Replicate('+expr(bytes((i*17+3)%256 for i in range(256)))+','+str((kn+255)//256)+'),'+str(kn)+')';digest=hmac.digest(k,m,'sha1')
  case('hmac-'+str(n)+'-'+str(kn),'function Main()\nlocal s:='+data+',k:='+key+'\nOutStd(hb_HMAC_SHA1(s,k,.T.),hb_HMAC_SHA1(s,k,.F.),hb_HMAC_SHA1(s,k))\nreturn nil\n',digest+b' '+digest.hex().encode()+b' '+digest.hex().encode())
original=Path(a.harbour_core)/'tests/sha1.prg';inventory=json.loads((repo/'corpus/harbour-694428e1-inventory.json').read_text());assert hashlib.sha256(original.read_bytes()).hexdigest()==next(x['sha256'] for x in inventory['files'] if x['path']=='tests/sha1.prg');case('original',original.read_text())
case('snapshot',(Path(__file__).parent/'snapshot.prg').read_text(),hmac.digest(b'HELLO',b'HELLO','sha1').hex().encode())
case('bool-variable','function Main()\nlocal raw:=.T.\nOutStd(hb_SHA1("abc",raw))\nraw:=.F.\nOutStd(hb_SHA1("abc",raw))\nreturn nil\n',hashlib.sha1(b'abc').digest()+hashlib.sha1(b'abc').hexdigest().encode())
case('result-ownership','function Main()\nlocal a:=hb_SHA1("abc"),b:=hb_HMAC_SHA1("abc","k"),c:=""\nc:=Upper(a)+Upper(b)\nOutStd(c)\nreturn nil\n',(hashlib.sha1(b'abc').hexdigest()+hmac.digest(b'k',b'abc','sha1').hex()).upper().encode())
# Instrumentation-only unwind/memory fixture. TRY syntax belongs to this
# compiler, so it is not presented as an unchanged Harbour source pair.
w=out/'unwind';w.mkdir();src=Path(__file__).parent/'unwind.prg'
for mode,flags in [('int',[]),('ext',['--external-as'])]:
 b=run([cc,src,w/mode,'--target=linux','--instrument',*flags],w,mode+'-build');r=run([w/mode],w,mode+'-run') if not b.returncode else None;rows.append(dict(name='unwind-'+mode,kind='instrumentation',ok=bool(r and r.returncode==0 and r.stdout==b'\n      2000          0' and not r.stderr),build_rc=b.returncode));cleanup(w)
reject={'sha-noargs':'hb_SHA1()','sha-many':'hb_SHA1("x",.T.,.F.)','sha-number':'hb_SHA1(1)','sha-nil':'hb_SHA1(NIL)','sha-bool':'hb_SHA1(.T.)','sha-array':'hb_SHA1({"x"})','sha-flag':'hb_SHA1("x",1)','hmac-noargs':'hb_HMAC_SHA1()','hmac-one':'hb_HMAC_SHA1("x")','hmac-many':'hb_HMAC_SHA1("x","k",.T.,.F.)','hmac-key':'hb_HMAC_SHA1("x",1)','hmac-data':'hb_HMAC_SHA1(1,"k")','hmac-flag':'hb_HMAC_SHA1("x","k",NIL)','use-after':'hb_HMAC_SHA1(a,Consume(a))+a'}
for name,e in reject.items():
 w=out/('reject-'+name);w.mkdir();src=w/'p.prg';src.write_text('function Consume(a)\nreturn Upper(a)\nfunction Main()\nlocal a:=Upper("x")\nOutStd('+e+')\nreturn nil\n');b=run([cc,src,w/'int','--target=linux'],w,'build');rows.append(dict(name='reject-'+name,kind='rejection',ok=b.returncode==1 and not (w/'int').exists(),build_rc=b.returncode))
for profile,flags in [('PE',['--target=windows']),('Darwin',['--target=macho']),('ARM64',['--target=macho-arm64']),('LLVM',['--target=linux','--experimental-llvm']),('LLVM-no-trace',['--target=linux','--experimental-llvm-no-trace']),('threads',['--target=linux'])]:
 w=out/('profile-'+profile);w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if profile=='threads' else '')+'function Main()\n'+('local t:=hb_threadStart(@Work())\n' if profile=='threads' else '')+'OutStd(hb_SHA1("x"))\nreturn nil\n');b=run([cc,src,w/'int',*flags],w,'build');rows.append(dict(name='profile-'+profile,kind='profile-rejection',ok=b.returncode==1 and b'SHA1/HMAC is measured only' in b.stderr and not (w/'int').exists(),build_rc=b.returncode))
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),scope='ordinary Linux SHA1/HMAC typed strings, optional typed logical raw flag. Unchanged original plus own fixtures; external Harbour oracle only, no normalization',passed=sum(r['ok'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));(out/'binary-shas.json').write_text(json.dumps(hashes,indent=2));(out/'commands.json').write_text(json.dumps(commands,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(r['ok'] for r in rows))
