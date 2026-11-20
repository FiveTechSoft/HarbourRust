#!/usr/bin/env python3
"""Original MIT: Linux GTSTD cursor state and actual blocking stdin bytes."""
import argparse,hashlib,json,pathlib,subprocess,os,time,pty,select
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['compiler','hbmk2','harbour-core','output']:ap.add_argument('--'+k,required=True)
a=ap.parse_args();cc=P(a.compiler).resolve();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);gate=P(__file__).resolve().parent;core=P(a.harbour_core).resolve();rows=[]
def run(cmd,w,label,inp=b''):
 try:r=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,input=inp,timeout=20)
 except subprocess.TimeoutExpired as e:r=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for k,d in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(d)
 return r
def add(name,ok,**kw):rows.append(dict(name=name,ok=bool(ok),**kw));print(name,'PASS' if ok else 'FAIL',flush=True)
src=core/'tests/cursor.prg';inv=json.loads((gate.parents[1]/'corpus/harbour-694428e1-inventory.json').read_text());assert hashlib.sha256(src.read_bytes()).hexdigest()==next(x['sha256'] for x in inv['files'] if x['path']=='tests/cursor.prg')
for src in sorted((gate/'programs').glob('*.prg'))+[src]:
 w=out/src.stem;w.mkdir();ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),src],w,'oracle-build')
 inputs={'none':b''} if src.stem in ['modes','order'] else ({'five':b'12345'} if src.stem=='cursor' else {'abc':b'ABCD','nul-esc':b'\x00\x1b[A\xff','control':b'\x03\x08\x09\x0d','utf8':'éü'.encode()})
 for variant,flags in [('elf-int',[]),('elf-ext',['--external-as'])]:
  b=run([cc,src,w/variant,'--target=linux',*flags,'-I',str(core/'include')],w,'build-'+variant)
  for name,inp in inputs.items():
   (w/(name+'.stdin')).write_bytes(inp);rr=run([w/'oracle'],w,'oracle-'+name,inp) if ob.returncode==0 else None;r=run([w/variant],w,variant+'-'+name,inp) if b.returncode==0 else None
   add(src.stem+'-'+variant+'-'+name,rr and r and (rr.returncode,r.returncode,rr.stderr,r.stderr)==(0,0,b'',b'') and rr.stdout==r.stdout,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),external_source=src.parent==core/'tests',build_rc=b.returncode,run_rc=r.returncode if r else None)
# Delayed pipe proves blocking, then EOF/zero-input cannot synthesize a key.
w=out/'blocking';w.mkdir();(w/'p.prg').write_text('function main()\n? Inkey(0)\nreturn nil\n');builds={}
for who,cmd in [('ours',[cc,w/'p.prg',w/'ours','--target=linux']),('oracle',[a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'p.prg'])]:builds[who]=run(cmd,w,who+'-build')
for who in ['ours','oracle']:
 if builds[who].returncode: add(who+'-delayed',False,build_rc=builds[who].returncode);continue
 p=subprocess.Popen([str(w/who)],cwd=w,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE);time.sleep(.15);waiting=p.poll() is None;p.stdin.write(b'\x00Q');p.stdin.flush();so,se=p.communicate(timeout=3);(w/(who+'-delayed.stdout')).write_bytes(so);(w/(who+'-delayed.stderr')).write_bytes(se);add(who+'-delayed',waiting and p.returncode==0 and so==b'\n        81' and not se,build_rc=builds[who].returncode,run_rc=p.returncode)
 for name,inp in [('eof',b''),('nul',b'\x00')]:
  p=subprocess.Popen([str(w/who)],cwd=w,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE);p.stdin.write(inp);p.stdin.close();p.stdin=None
  try:so,se=p.communicate(timeout=.2);held=False
  except subprocess.TimeoutExpired:p.kill();so,se=p.communicate();held=True
  (w/(who+'-'+name+'.stdout')).write_bytes(so);(w/(who+'-'+name+'.stderr')).write_bytes(se);add(who+'-'+name,held and not so and not se,killed_after_timeout=held,build_rc=builds[who].returncode,run_rc=p.returncode)
# Cooked PTY only: newline releases input; raw terminal mode is not promised.
for who in ['ours','oracle']:
 if builds[who].returncode:continue
 m,s=pty.openpty();p=subprocess.Popen([str(w/who)],cwd=w,stdin=s,stdout=s,stderr=s,close_fds=True);time.sleep(.1);os.write(m,b'q\n');p.wait(timeout=3);buf=b''
 while select.select([m],[],[],.05)[0]:
  try:buf+=os.read(m,4096)
  except OSError:break
 os.close(m);os.close(s);(w/(who+'.pty')).write_bytes(buf);add(who+'-cooked-pty',p.returncode==0 and b'113' in buf)
w=out/'limits';w.mkdir()
for name,source,flags,msg in [
 ('set-string','? SetCursor("x")',[],b'typed integer'),('set-nil','? SetCursor(NIL)',[],b'typed integer'),('set-two','? SetCursor(1,2)',[],b'zero or one'),
 ('set-windows','? SetCursor()', ['--target=windows'],b'SetCursor is measured only'),('set-llvm','? SetCursor()',['--experimental-llvm'],b'SetCursor is measured only'),
 ('zero-windows','? Inkey(0)',['--target=windows'],b'INKEY supports zero arguments'),('zero-darwin','? Inkey(0)',['--target=macho'],b'INKEY supports ordinary'),('zero-llvm','? Inkey(0)',['--experimental-llvm'],b'INKEY supports ordinary')]:
  (w/'p.prg').write_text('function main()\n'+source+'\nreturn nil\n');b=run([cc,w/'p.prg',w/name,*flags],w,'build-'+name);add('limit-'+name,b.returncode==1 and msg in b.stderr and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
w=out/'nested-consumption';w.mkdir();(w/'p.prg').write_text((gate/'programs/order.prg').read_text().replace('? SetCursor(),SetCursor(Mode(p)),SetCursor()','? SetCursor(Mode(p))\n ? Len(p)'));b=run([cc,w/'p.prg',w/'p','--target=linux'],w,'build');add('nested-consumption',b.returncode==1 and b'use of moved value' in b.stderr and not (w/'p').exists(),build_rc=b.returncode)
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),passed=sum(r['ok'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(r['ok'] for r in rows))
