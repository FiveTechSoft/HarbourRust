#!/usr/bin/env python3
"""Original MIT: actual Linux filesystem links and FError state. External oracle only."""
import argparse,pathlib,subprocess,json,hashlib,os,stat,re
P=pathlib.Path;ap=argparse.ArgumentParser()
for x in ['compiler','hbmk2','harbour-core','output']:ap.add_argument('--'+x,required=True)
a=ap.parse_args();cc=P(a.compiler).resolve();core=P(a.harbour_core).resolve();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);gate=P(__file__).resolve().parent;rows=[]
def run(cmd,w,label):
 try:r=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,timeout=15)
 except subprocess.TimeoutExpired as e:r=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return r
def add(n,ok,**kw):rows.append(dict(name=n,ok=bool(ok),**kw));print(n,'PASS' if ok else 'FAIL',flush=True)
def prepare(p):
 p.mkdir();(p/'origin').write_bytes(b'abc');(p/'subdir').mkdir();(p/'blocked').mkdir();(p/'blocked/inside').write_bytes(b'x');(p/'blocked').chmod(0);(p/'loop').symlink_to('loop')
def snap(p):
 d={}
 for f in p.iterdir():
  if f.name.startswith('run.'):continue
  m=f.lstat()
  if stat.S_ISLNK(m.st_mode):d[f.name]=dict(link=os.readlink(f))
  elif stat.S_ISREG(m.st_mode):d[f.name]=dict(bytes=hashlib.sha256(f.read_bytes()).hexdigest(),size=m.st_size,mode=m.st_mode&0o777,links=m.st_nlink)
  elif stat.S_ISDIR(m.st_mode):d[f.name]=dict(directory=True,mode=m.st_mode&0o777)
 return d
orig=core/'tests/flink.prg';inv=json.loads((gate.parents[1]/'corpus/harbour-694428e1-inventory.json').read_text());assert hashlib.sha256(orig.read_bytes()).hexdigest()==next(x['sha256'] for x in inv['files'] if x['path']=='tests/flink.prg')
for src in sorted((gate/'programs').glob('*.prg'))+[orig]:
 w=out/src.stem;w.mkdir();oracle_src=src
 if src.stem.startswith('unwind'):
  text=src.read_text();text=re.sub(r'(?im)^(\s*)try\s*$',r'\1begin sequence',text);text=re.sub(r'(?im)^(\s*)catch(?:\s+(\w+))?\s*$',lambda m:m[1]+'recover'+(' using '+m[2] if m[2] else ''),text);text=re.sub(r'(?im)^(\s*)end\s*$',r'\1end sequence',text);text=text.replace('FUNCTION Main()','FUNCTION Main()\n ErrorBlock({|e|Break(e)})');oracle_src=w/'oracle-source.prg';oracle_src.write_text(text)
 ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),oracle_src],w,'oracle-build')
 for name,flags in [('int',[]),('ext',['--external-as'])]:
  ow=w/(name+'-oracle');cw=w/(name+'-candidate');prepare(ow);prepare(cw);rr=run([w/'oracle'],ow,'run') if ob.returncode==0 else None;b=run([cc,src,w/name,'--target=linux',*flags,'-I',core/'include'],w,'build-'+name);r=run([w/name],cw,'run') if b.returncode==0 else None
  ofs=snap(ow);cfs=snap(cw);add(src.stem+'-'+name,rr and r and rr.returncode==r.returncode==0 and rr.stdout==r.stdout and rr.stderr==r.stderr==b'' and ofs==cfs,build_rc=b.returncode,run_rc=r.returncode if r else None,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),candidate_files=cfs,oracle_files=ofs,external_original=src==orig)
  (ow/'blocked').chmod(0o700);(cw/'blocked').chmod(0o700)
w=out/'memory';w.mkdir();source=(gate/'programs/ownership.prg').read_text().replace(' Work()\nRETURN NIL',' LOCAL n\n Work()\n n:=hb_memcheck()\n Work()\n ? hb_memcheck()-n\nRETURN NIL');(w/'p.prg').write_text(source)
expected=(out/'ownership/int-oracle/run.stdout').read_bytes()*2+b'\n         0'
for name,flags in [('int',[]),('ext',['--external-as'])]:
 cw=w/('cwd-'+name);prepare(cw);b=run([cc,w/'p.prg',w/name,'--target=linux','--instrument',*flags],w,'build-'+name);r=run([w/name],cw,'run') if b.returncode==0 else None;add('memory-'+name,r and r.returncode==0 and r.stdout==expected and not r.stderr,build_rc=b.returncode,run_rc=r.returncode if r else None);(cw/'blocked').chmod(0o700)
w=out/'unwind-memory';w.mkdir();source=(gate/'programs/unwind.prg').read_text().replace(' Work()\nRETURN NIL',' LOCAL n\n Work()\n n:=hb_memcheck()\n Work()\n ? hb_memcheck()-n\nRETURN NIL');(w/'p.prg').write_text(source)
expected=(out/'unwind/int-oracle/run.stdout').read_bytes()*2+b'\n         0'
for name,flags in [('int',[]),('ext',['--external-as'])]:
 cw=w/('cwd-'+name);prepare(cw);b=run([cc,w/'p.prg',w/name,'--target=linux','--instrument',*flags],w,'build-'+name);r=run([w/name],cw,'run') if b.returncode==0 else None;add('unwind-memory-'+name,r and r.returncode==0 and r.stdout==expected and not r.stderr,build_rc=b.returncode,run_rc=r.returncode if r else None);(cw/'blocked').chmod(0o700)
w=out/'limits';w.mkdir()
for name,body,flags in [('thread-after','? FError()\n ? hb_threadself()',[]),('thread-before','? hb_threadself()\n ? FError()',[]),('windows','? FError()',['--target=windows']),('darwin','? FError()',['--target=macho']),('llvm','? FError()',['--experimental-llvm']),('ferror-set','? FError(1)',[]),('num','? hb_FLink(1,2)',[]),('one','? hb_FLink("a")',[]),('dir-extra','? hb_DirCreate("a","b")',[]),('memo-extra','? hb_MemoWrit("a","b",.T.)',[])]:
 (w/'p.prg').write_text('function main()\n'+body+'\nreturn nil\n');r=run([cc,w/'p.prg',w/name,*flags],w,'build-'+name);add('limit-'+name,r.returncode==1 and (b'filesystem link' in r.stderr or b'Linux filesystem' in r.stderr) and b'panicked' not in r.stderr and not (w/name).exists(),build_rc=r.returncode)
w=out/'nested-consumption';w.mkdir();(w/'p.prg').write_text((gate/'programs/snapshot.prg').read_text().replace('hb_FLink(a,Consume(a)),FError()','hb_FLink(a,Consume(a)),FError()\n ? Len(a)'));b=run([cc,w/'p.prg',w/'p','--target=linux'],w,'build');add('nested-consumption',b.returncode==1 and b'use of moved value' in b.stderr and not (w/'p').exists(),build_rc=b.returncode)
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),passed=sum(x['ok'] for x in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(x['ok'] for x in rows))
