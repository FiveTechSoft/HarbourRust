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
for storage in ['PRIVATE','PUBLIC']:
 for typ,v in [('integer','7'),('float','1.25'),('string','"A"'),('bool','.t.')]:cases[storage+'-'+typ]='function Main()\n'+storage+' x:='+v+'\n? x++\nreturn nil\n'
cases['local-in-memvar']='function Main()\nlocal x\nPRIVATE other:=7\nx:=7\n? x++\nreturn nil\n';cases['local-in-macro']='function Main()\nlocal x,s:="1+2"\nx:=7\n? &(s),x++\nreturn nil\n';cases['static']='function Main()\nstatic x\nx:=7\n? x++\nreturn nil\n'
for n,s in cases.items():
 w=out/n;w.mkdir();p=w/'p.prg';p.write_text(s);op=w/'oracle.prg';op.write_text(s.replace('? x++','TRY\n? x++\nCATCH e\n? "caught"\nEND').replace('TRY\n','BEGIN SEQUENCE WITH {|o| Break(o)}\n').replace('CATCH e\n','RECOVER\n').replace('END\n','END SEQUENCE\n'));b=run([a.compiler,p,w/'ours','--target=linux'],w,'build');ob=run([a.hbmk2,op,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');q=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None;ok=b.returncode==1 and (b'Dyn expression ++/-- requires ordinary Linux non-macro local storage' in b.stderr or (n=='static' and b'persistent tagged STATIC cannot escape' in b.stderr)) and not(w/'ours').exists() and bool(q and q.returncode==0 and not q.stderr);row=dict(name=n,source_sha256=h(p),build_rc=b.returncode,oracle_build_rc=ob.returncode,oracle_run_rc=q.returncode if q else None,ok=ok)
 if q:row['oracle_binary_sha256']=h(w/'oracle');(w/'oracle').unlink()
 rows.append(row)
for tg in ['windows','macho','macho-arm64','linux-thread']:
 w=out/tg;w.mkdir();p=w/'p.prg';s='function Main()\nlocal x\nx:=7\n? x++\nreturn nil\n';s+=('function Unused()\nreturn hb_threadSelf()\n' if tg=='linux-thread' else '');p.write_text(s);b=run([a.compiler,p,w/'ours.s','--target='+('linux' if tg=='linux-thread' else tg)],w,'build');rows.append(dict(name=tg,source_sha256=h(p),build_rc=b.returncode,ok=b.returncode==1 and b'Dyn expression ++/-- requires ordinary Linux non-macro local storage' in b.stderr and not(w/'ours.s').exists()))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='11storage/context compile limits with fresh oracle controls,4profile limits;none of rejected binaries executed.Oracle TRY adapter only for expected bad-kind errors.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert all(x['ok'] for x in rows)
