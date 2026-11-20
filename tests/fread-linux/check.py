#!/usr/bin/env python3
"""Original MIT: typed Linux FRead with independent filesystem oracles."""
import argparse,hashlib,json,os,pathlib,subprocess,time
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
src=core/'tests/fileio.prg';inv=json.loads((gate.parents[1]/'corpus/harbour-694428e1-inventory.json').read_text());assert hashlib.sha256(src.read_bytes()).hexdigest()==next(x['sha256'] for x in inv['files'] if x['path']=='tests/fileio.prg')
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
w=out/'limits';w.mkdir();(w/'p.prg').write_text('function main()\nlocal s:="xx"\n? FRead(-1,@s,1)\nreturn nil\n')
for name,flags in [('windows',['--target=windows']),('darwin',['--target=macho']),('arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('llvm-no-trace',['--target=linux','--experimental-llvm-no-trace'])]:
 b=run([cc,w/'p.prg',w/name,*flags],w,'build-'+name);add('limit-'+name,b.returncode==1 and b'typed FRead is measured only on ordinary Linux' in b.stderr and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
for name,expr,diagnostic in [('negative','FRead(-1,@s,-1)','count must be a literal'),('dynamic','FRead(-1,@s,n)','count must be a literal'),('large','FRead(-1,@s,1048577)','count must be a literal'),('missing','FRead(-1,@s)','needs handle'),('notbyref','FRead(-1,s,1)','buffer must be'),('badbuf','FRead(-1,@n,1)','buffer must be'),('alias','FRead(Len(s),@s,1)','cannot alias'),('badhandle','FRead("x",@s,1)','handle requires')]:
 (w/'args.prg').write_text('function main()\nlocal n:=1,s:="keep"\n? '+expr+'\nreturn nil\n');b=run([cc,w/'args.prg',w/name,'--target=linux'],w,'build-'+name);add('limit-'+name,b.returncode==1 and diagnostic.encode() in b.stderr and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
for src in sorted((gate/'reject').glob('*.prg')):
 w=out/('reject-'+src.stem);w.mkdir();b=run([cc,src,w/'p','--target=linux'],w,'build');add('reject-'+src.stem,b.returncode==1 and b'use of moved value' in b.stderr and b'panicked' not in b.stderr and not (w/'p').exists(),build_rc=b.returncode)
# A single short pipe read must not wait to collect the length+1 request.
w=out/'boundary-pipe';w.mkdir();(w/'p.prg').write_text('function main()\nlocal s:=Upper("xxx"),h:=FOpen("fifo")\n? FRead(h,@s,4),Len(s),s\nreturn nil\n')
for name,cmd in [('oracle',[a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'p.prg']),('ours-int',[cc,w/'p.prg',w/'ours-int','--target=linux']),('ours-ext',[cc,w/'p.prg',w/'ours-ext','--target=linux','--external-as'])]:
 b=run(cmd,w,'build-'+name)
 if b.returncode: add('boundary-pipe-'+name,False,build_rc=b.returncode);continue
 os.mkfifo(w/'fifo');p=subprocess.Popen([str(w/name)],cwd=w,stdin=subprocess.DEVNULL,stdout=subprocess.PIPE,stderr=subprocess.PIPE);fd=os.open(w/'fifo',os.O_WRONLY);os.write(fd,b'AB');time.sleep(.1);finished=p.poll() is not None;os.close(fd);(w/'fifo').unlink()
 if not finished:p.kill()
 so,se=p.communicate();(w/(name+'.stdout')).write_bytes(so);(w/(name+'.stderr')).write_bytes(se);(w/(name+'.rc')).write_text(str(p.returncode));add('boundary-pipe-'+name,finished and p.returncode==0 and not se and so==b'\n         2          3 ABX',build_rc=b.returncode,run_rc=p.returncode)
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),passed=sum(r['ok'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(r['ok'] for r in rows))
