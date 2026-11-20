#!/usr/bin/env python3
"""Original MIT: binary tokens, runtime macro syntax, bare Linux GTSTD WAIT."""
import argparse,pathlib,subprocess,json,hashlib
P=pathlib.Path;ap=argparse.ArgumentParser()
for x in ['compiler','hbmk2','harbour-core','output']:ap.add_argument('--'+x,required=True)
a=ap.parse_args();cc=P(a.compiler).resolve();core=P(a.harbour_core).resolve();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);gate=P(__file__).resolve().parent;rows=[]
def run(cmd,w,label,inp=b'Z',timeout=10):
 try:r=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,input=inp,timeout=timeout)
 except subprocess.TimeoutExpired as e:r=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return r
def add(n,ok,**kw):rows.append(dict(name=n,ok=bool(ok),**kw));print(n,'PASS' if ok else 'FAIL',flush=True)
src=core/'tests/base2.prg';inv=json.loads((gate.parents[1]/'corpus/harbour-694428e1-inventory.json').read_text());assert hashlib.sha256(src.read_bytes()).hexdigest()==next(x['sha256'] for x in inv['files'] if x['path']=='tests/base2.prg')
for src in sorted((gate/'programs').glob('*.prg'))+[src]:
 w=out/src.stem;w.mkdir();ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),src],w,'oracle-build');inputs={'ascii':b'Z'} if src.stem!='wait' else {'ascii':b'Z','lf':b'\n','esc':b'\x1b','nul':b'\x00Z','del':b'\x7f','ff':b'\xff',**{'ctrl'+str(i):bytes([i]) for i in range(1,32)}}
 for name,flags in [('int',[]),('ext',['--external-as'])]:
  b=run([cc,src,w/name,'--target=linux',*flags,'-I',core/'include'],w,'build-'+name)
  for key,inp in inputs.items():
   rr=run([w/'oracle'],w,'oracle-'+key,inp) if ob.returncode==0 else None;r=run([w/name],w,name+'-'+key,inp) if b.returncode==0 else None;add(src.stem+'-'+name+'-'+key,r and rr and rr.returncode==r.returncode==0 and rr.stdout==r.stdout and rr.stderr==r.stderr==b'',source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),build_rc=b.returncode,run_rc=r.returncode if r else None,external_original=src==core/'tests/base2.prg')
w=out/'reject';w.mkdir()
for i,text in enumerate(['0b','0B','0b2','0b102','0b1foo','0b1.5','0b1e2']):
 (w/'p.prg').write_text('function main()\n? '+text+'\nreturn nil\n');o=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'p.prg'],w,'oracle-'+str(i));b=run([cc,w/'p.prg',w/'ours','--target=linux'],w,'build-'+str(i));add('invalid-'+text,o.returncode!=0 and b.returncode==1 and b'binary literal' in b.stderr,build_rc=b.returncode)
for name,body,flags in [('windows','WAIT',['--target=windows']),('macho','WAIT',['--target=macho']),('llvm','WAIT',['--experimental-llvm']),('wait-prompt','WAIT "x"',[]),('thread-after','WAIT\n? hb_threadself()',[]),('thread-before','? hb_threadself()\nWAIT',[])]:
 (w/'p.prg').write_text('function main()\n'+body+'\nreturn nil\n');b=run([cc,w/'p.prg',w/name,*flags],w,'build-'+name);add('limit-'+name,b.returncode==1 and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
# A negated wrapped minimum becomes a double in the oracle; not an admitted
# integer literal in this compiler increment. Fail closed, never wrap silently.
(w/'p.prg').write_text('function main()\n? -0b1'+'0'*63+'\nreturn nil\n')
b=run([cc,w/'p.prg',w/'neg-overflow','--target=linux'],w,'neg-overflow')
add('limit-negated-min',b.returncode==1 and b'negated integer literal out of range' in b.stderr,build_rc=b.returncode)
# No input and EOF both leave WAIT blocked after its prompt. With delayed
# input it must not print the following statement before that byte arrives.
for exe,label in [(out/'wait/oracle','oracle'),(out/'wait/int','int'),(out/'wait/ext','ext')]:
 if not exe.exists():
  for suffix in ['-eof','-delayed']:add('wait-'+label+suffix,False,build_rejected=True)
  continue
 import time,select
 prompt=b'\nbefore\nPress any key to continue...'
 for eof in [False,True]:
  q=subprocess.Popen([str(exe)],cwd=w,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
  if eof:q.stdin.close()
  data=b'';until=time.monotonic()+0.15
  while time.monotonic()<until:
   if select.select([q.stdout],[],[],0.02)[0]:data+=__import__('os').read(q.stdout.fileno(),4096)
  blocked=q.poll() is None
  if eof:q.kill();q.wait();err=q.stderr.read()
  else:
   q.stdin.write(b'Z');q.stdin.close();q.wait(timeout=2);data+=q.stdout.read();err=q.stderr.read()
  (w/(label+('-eof' if eof else '-delayed')+'.stdout')).write_bytes(data)
  add('wait-'+label+('-eof' if eof else '-delayed'),blocked and not err and data==(prompt if eof else prompt+b'Z\nafter'))
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),passed=sum(x['ok'] for x in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(x['ok'] for x in rows))
