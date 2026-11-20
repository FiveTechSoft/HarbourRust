from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
cases={}
for kind in ['PRIVATE','PUBLIC']:
 for n,v in [('int','7'),('float','1.25'),('bool','.t.'),('str','"abc"')]:cases[kind+'-'+n]='function Main()\nPick(.t.)\nreturn nil\nfunction Pick(flag)\n'+kind+' x:='+v+'\nif flag\nreturn x\nendif\nreturn "abc"\n'
cases['local-memvar-context']='function Main()\nPRIVATE other:=7\n? Pick(.t.)\nreturn nil\nfunction Pick(flag)\nif flag\nreturn "abc"\nendif\nreturn nil\n'
cases['local-macro-context']=cases['local-memvar-context'].replace('PRIVATE other:=7','local expr:="1+2"\n? &(expr)')
for name,text in cases.items():
 w=out/name;w.mkdir();p=w/'p.prg';p.write_text(text);b=run([a.compiler,p,w/'ours','--target=linux'],w,'build');ob=run([a.hbmk2,p,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');q=run([w/'oracle'],w,'oracle-run') if not ob.returncode else None;ok=b.returncode==1 and b'mixed string/logical Dyn returns require ordinary Linux' in b.stderr and b'panicked' not in b.stderr and not(w/'ours').exists() and bool(q and q.returncode==0 and not q.stderr);row=dict(name=name,source_sha256=h(p),build_rc=b.returncode,oracle_build_rc=ob.returncode,oracle_run_rc=q.returncode if q else None,ok=ok)
 if q:row['oracle_binary_sha256']=h(w/'oracle');(w/'oracle').unlink()
 rows.append(row)
for target,flags in [('windows',[]),('linux',[]),('macho',[]),('macho-arm64',[])]:
 name=target;w=out/name;w.mkdir();p=w/'p.prg';p.write_text(cases['local-memvar-context'].replace('PRIVATE other:=7\n','')+('function Unused()\nreturn hb_threadSelf()\n' if target=='linux' else ''));b=run([a.compiler,p,w/'ours.s','--target='+target,*flags],w,'build');ok=b.returncode==1 and b'mixed string/logical Dyn returns require ordinary Linux' in b.stderr and not(w/'ours.s').exists();rows.append(dict(name=name,source_sha256=h(p),build_rc=b.returncode,ok=ok))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='10memvar/macro limits with fresh executable oracle,4profile limits;all rejected at build,none executed.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==14 and all(x['ok'] for x in rows)
