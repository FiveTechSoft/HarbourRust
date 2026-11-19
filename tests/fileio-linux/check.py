#!/usr/bin/env python3
"""Original MIT: typed Linux file I/O with independent filesystem oracles."""
import argparse,hashlib,json,os,pathlib,subprocess
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['compiler','hbmk2','harbour-core','output']:ap.add_argument('--'+k,required=True)
a=ap.parse_args();cc=P(a.compiler).resolve();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);gate=P(__file__).resolve().parent;core=P(a.harbour_core).resolve();rows=[]
def run(cmd,w,label,fd=False):
 held=os.open('/dev/null',os.O_RDONLY) if fd else None
 try:
  try:r=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,timeout=60,pass_fds=(held,) if fd else ())
  except subprocess.TimeoutExpired as e:r=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 finally:
  if held is not None:os.close(held)
 for k,d in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(d)
 return r

def add(name,ok,**kw):rows.append(dict(name=name,ok=bool(ok),**kw));print(name,'PASS' if ok else 'FAIL',flush=True)
def cwd(w,name):
 p=w/name;p.mkdir();(p/'limité.dat').write_bytes(b'UTF8');return p
def files(w):
 return {f.name:dict(sha256=hashlib.sha256(f.read_bytes()).hexdigest(),size=f.stat().st_size,mode=f.stat().st_mode&0o777) for f in w.iterdir() if f.is_file() and f.name not in ['run.stdout','run.stderr','run.rc']}
src=core/'tests/fileio2.prg';inv=json.loads((gate.parents[1]/'corpus/harbour-694428e1-inventory.json').read_text());assert hashlib.sha256(src.read_bytes()).hexdigest()==next(x['sha256'] for x in inv['files'] if x['path']=='tests/fileio2.prg')
for src in sorted((gate/'programs').glob('*.prg'))+[src]:
 w=out/src.stem;w.mkdir();ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),src],w,'oracle-build');external=src.parent==core/'tests'
 for variant,flags,extra in [('elf-int',[],False),('elf-ext',['--external-as'],False),('extra-fd',[],True)]:
  ow=cwd(w,variant+'-oracle');cw=cwd(w,variant+'-candidate');rr=run([w/'oracle'],ow,'run',extra) if ob.returncode==0 else None
  b=run([cc,src,w/variant,'--target=linux',*flags,'-I',str(core/'include')],w,'build-'+variant);r=run([w/variant],cw,'run',extra) if b.returncode==0 else None
  fs=files(cw);ofs=files(ow)
  add(src.stem+'-'+variant,rr and r and (rr.returncode,r.returncode,rr.stderr,r.stderr)==(0,0,b'',b'') and rr.stdout==r.stdout and fs==ofs,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),external_source=external,build_rc=b.returncode,run_rc=r.returncode if r else None,candidate_files=fs,oracle_files=ofs)
w=out/'memory';w.mkdir();s=(gate/'programs/ownership.prg').read_text().replace(' Work()\nRETURN NIL',' LOCAL n\n Work()\n n:=hb_memcheck()\n Work()\n ? hb_memcheck()-n\nRETURN NIL');(w/'p.prg').write_text(s);expected=(out/'ownership/elf-int-oracle/run.stdout').read_bytes()*2+b'\n         0'
for variant,flags in [('elf-int',[]),('elf-ext',['--external-as'])]:
 cw=cwd(w,variant+'-candidate');b=run([cc,w/'p.prg',w/variant,'--target=linux','--instrument',*flags],w,'build-'+variant);r=run([w/variant],cw,'run') if b.returncode==0 else None
 add('memory-'+variant,r and r.returncode==0 and not r.stderr and r.stdout==expected,build_rc=b.returncode,run_rc=r.returncode if r else None)
w=out/'limits';w.mkdir();(w/'p.prg').write_text('function main()\n? FCreate("x")\nreturn nil\n')
for name,flags in [('windows',['--target=windows']),('darwin',['--target=macho']),('arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('llvm-no-trace',['--target=linux','--experimental-llvm-no-trace'])]:
 b=run([cc,w/'p.prg',w/name,*flags],w,'build-'+name);add('limit-'+name,b.returncode==1 and b'typed file I/O is measured only on ordinary Linux' in b.stderr and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
for name,expr,diagnostic in [('zero','FReadStr(-1,0)','count must be a literal'),('negative','FReadStr(-1,-1)','count must be a literal'),('dynamic','FReadStr(-1,n)','count must be a literal'),('large','FReadStr(-1,1048577)','count must be a literal'),('open-mode','FOpen("x",2)','supports 1 argument'),('write-count','FWrite(-1,"x",1)','supports 2 argument'),('create-attr','FCreate("x",0)','supports 1 argument'),('path-type','FOpen(1)','requires typed strings'),('close-args','FClose()','supports 1 argument')]:
 (w/'args.prg').write_text('function main()\nlocal n:=1\n? '+expr+'\nreturn nil\n');b=run([cc,w/'args.prg',w/name,'--target=linux'],w,'build-'+name);add('limit-'+name,b.returncode==1 and diagnostic.encode() in b.stderr and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
for src in sorted((gate/'reject').glob('*.prg')):
 w=out/('reject-'+src.stem);w.mkdir();b=run([cc,src,w/'p','--target=linux'],w,'build');add('reject-'+src.stem,b.returncode==1 and b'use of moved value' in b.stderr and b'panicked' not in b.stderr and not (w/'p').exists(),build_rc=b.returncode)
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),passed=sum(r['ok'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(r['ok'] for r in rows))
