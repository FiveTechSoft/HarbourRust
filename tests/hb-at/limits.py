from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser()
for k in ['compiler','hbmk2','output']:p.add_argument('--'+k,required=True)
a=p.parse_args();out=Path(a.output);out.mkdir();rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,n):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(n+'.'+e)).write_bytes(b)
 return q
cases={}
for kind in ['PRIVATE','PUBLIC']:
 for typ,v in [('i64','2'),('f64','2.5'),('bool','.t.'),('str','"2"')]:cases[kind+'-'+typ]=('profile','function Main()\n'+kind+' x:='+v+'\n? hb_At("a","aba",x)\nreturn nil\n')
for typ,v in [('f64','2.5'),('bool','.t.'),('str','"2"')]:cases['bound-'+typ]=('bound','function Main()\n? hb_At("a","aba",'+v+')\nreturn nil\n')
cases['dyn-bound']=('bound','function Main()\nlocal x\nx:=2\n? hb_At("a","aba",x)\nreturn nil\n')
cases['macro-context']=('profile','function Main()\nlocal expr:="1+2"\n? &(expr)\n? hb_At("a","aba",2)\nreturn nil\n')
cases['memvar-context']=('profile','function Main()\nPRIVATE other:=2\n? hb_At("a","aba",2)\nreturn nil\n')
for n,(kind,s) in cases.items():
 w=out/n;w.mkdir();p=w/'p.prg';p.write_text(s);b=run([a.compiler,p,w/'ours','--target=linux'],w,'build');ob=run([a.hbmk2,p,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');q=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None;expected=b'hb_At requires ordinary Linux' if kind=='profile' else b'hb_At bounds require I64 or literal NIL';ok=b.returncode==1 and expected in b.stderr and not(w/'ours').exists() and bool(q and q.returncode==0 and not q.stderr);row=dict(name=n,source_sha256=h(p),build_rc=b.returncode,oracle_build_rc=ob.returncode,oracle_run_rc=q.returncode if q else None,ok=ok)
 if q:row['oracle_binary_sha256']=h(w/'oracle');(w/'oracle').unlink()
 rows.append(row)
for tg in ['windows','macho','macho-arm64']:
 w=out/tg;w.mkdir();p=w/'p.prg';p.write_text('function Main()\n? hb_At("a","aba",2)\nreturn nil\n');b=run([a.compiler,p,w/'ours.s','--target='+tg],w,'build');rows.append(dict(name=tg,source_sha256=h(p),build_rc=b.returncode,ok=b.returncode==1 and b'hb_At requires ordinary Linux' in b.stderr and not(w/'ours.s').exists()))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='14compile limits with fresh external executable oracle,3profile assembly limits;not runtime parity of rejected programs,no rejected program executes.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert all(x['ok'] for x in rows)
