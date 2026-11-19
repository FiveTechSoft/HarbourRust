#!/usr/bin/env python3
"""Original MIT: Linux uname-backed OS, owned strings and profile limits."""
import argparse,hashlib,json,os,pathlib,subprocess
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['compiler','hbmk2','harbour-core','output']:ap.add_argument('--'+k,required=True)
a=ap.parse_args();cc=P(a.compiler).resolve();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);gate=P(__file__).resolve().parent;core=P(a.harbour_core).resolve();rows=[]
def run(cmd,w,label):
 try:r=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,timeout=60)
 except subprocess.TimeoutExpired as e:r=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for k,d in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(d)
 return r
def add(name,ok,**kw):rows.append(dict(name=name,ok=bool(ok),**kw));print(name,'PASS' if ok else 'FAIL',flush=True)
src=core/'tests/os.prg';inv=json.loads((gate.parents[1]/'corpus/harbour-694428e1-inventory.json').read_text());assert hashlib.sha256(src.read_bytes()).hexdigest()==next(x['sha256'] for x in inv['files'] if x['path']=='tests/os.prg')
for src in sorted((gate/'programs').glob('*.prg'))+[src]:
 w=out/src.stem;w.mkdir();external=src.parent==core/'tests'
 ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),src],w,'oracle-build');rr=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None
 for variant,flags in [('elf-int',[]),('elf-ext',['--external-as'])]:
  b=run([cc,src,w/variant,'--target=linux',*flags],w,'build-'+variant);r=run([w/variant],w,'run-'+variant) if b.returncode==0 else None
  add(src.stem+'-'+variant,rr and r and (rr.returncode,r.returncode,rr.stderr,r.stderr)==(0,0,b'',b'') and rr.stdout==r.stdout,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),external_source=external,build_rc=b.returncode,run_rc=r.returncode if r else None)
# Allocation growth, after warming caches. Candidate instrumentation, not oracle.
w=out/'memory';w.mkdir();s=(gate/'programs/ownership.prg').read_text().replace(' Work()\nRETURN NIL',' LOCAL n\n Work()\n n:=hb_memcheck()\n Work()\n ? hb_memcheck()-n\nRETURN NIL');(w/'p.prg').write_text(s);expected=(out/'ownership/oracle-run.stdout').read_bytes()*2+b'\n         0'
for variant,flags in [('elf-int',[]),('elf-ext',['--external-as'])]:
 b=run([cc,w/'p.prg',w/variant,'--target=linux','--instrument',*flags],w,'build-'+variant);r=run([w/variant],w,'run-'+variant) if b.returncode==0 else None
 add('memory-'+variant,r and r.returncode==0 and not r.stderr and r.stdout==expected,build_rc=b.returncode,run_rc=r.returncode if r else None)
# Named limits: OS is Linux ordinary backend only. No host-derived PE output.
w=out/'limits';w.mkdir();(w/'p.prg').write_text('function main()\n? OS()\nreturn nil\n')
for name,flags in [('windows',['--target=windows']),('darwin',['--target=macho']),('arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('llvm-no-trace',['--target=linux','--experimental-llvm-no-trace'])]:
 b=run([cc,w/'p.prg',w/name,*flags],w,'build-'+name);add('limit-'+name,b.returncode==1 and b'OS is measured only on the ordinary Linux' in b.stderr and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
(w/'args.prg').write_text('function main()\n? OS(1)\nreturn nil\n');b=run([cc,w/'args.prg',w/'args','--target=linux'],w,'build-args');add('limit-args',b.returncode==1 and b'OS takes no arguments' in b.stderr,build_rc=b.returncode)
# Deterministic syscall-boundary diagnostics using generated ELF assembly.
# These are own synthetic kernel records, not Harbour/platform executions.
w=out/'kernel-records';w.mkdir();(w/'p.prg').write_text('function main()\n? ">"+OS()+"<"\nreturn nil\n')
b=run([cc,w/'p.prg',w/'original.s','--target=linux'],w,'emit')
if b.returncode==0:
 text=(w/'original.s').read_text();start=text.index('hbc_os_uname_linux:');end=text.index('.section .rodata',start);helper=text[start:end];assert helper.count('    syscall')==1
 for name,fields,fail,unterminated in [('different-host',['OtherOS','9.8-test','newarch'],False,False),('max-fields',['s'*64,'r'*64,'m'*64],False,False),('empty-fields',['','',''],False,False),('syscall-failure',[],True,False),('unterminated',['x'*65,'r','m'],False,True)]:
  stub=['.text','os_test_uname:']
  if fail:stub+=['    mov $-1, %rax','    ret']
  else:
   stub+=['    push %rdi','    xor %eax, %eax','    mov $390, %ecx','    rep stosb','    pop %rdi']
   for off,field in zip([0,130,260],fields):
    for j,ch in enumerate(field.encode()):stub.append('    movb $%d, %d(%%rdi)'%(ch,off+j))
   stub+=['    xor %eax, %eax','    ret']
  asm=text[:start]+helper.replace('    syscall','    call os_test_uname')+text[end:]+'\n'+'\n'.join(stub)+'\n';(w/(name+'.s')).write_text(asm)
  ab=run(['as','-o',w/(name+'.o'),w/(name+'.s')],w,name+'-as');lb=run(['ld','-o',w/name,w/(name+'.o')],w,name+'-ld') if ab.returncode==0 else None
  r=run([w/name],w,name+'-run') if lb and lb.returncode==0 else None
  expected=('\n>'+' '.join(fields)+'<').encode()
  ok=bool(r and ((r.returncode==1 and (r.stdout or r.stderr)) if fail or unterminated else (r.returncode==0 and not r.stderr and r.stdout==expected)))
  add('kernel-record-'+name,ok,run_rc=r.returncode if r else None)
else:add('kernel-record-emission',False,build_rc=b.returncode)
w=out/'noncontamination';w.mkdir();(w/'p.prg').write_text('function main()\n? 1\nreturn nil\n');b=run([cc,w/'p.prg',w/'p.s','--target=linux'],w,'emit');add('no-os-no-helper',b.returncode==0 and 'hbc_os_uname_linux' not in (w/'p.s').read_text())
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),passed=sum(r['ok'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(r['ok'] for r in rows))
