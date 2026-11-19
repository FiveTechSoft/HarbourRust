#!/usr/bin/env python3
"""Original MIT: Linux library filenames, string ownership and profile limits."""
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
src=core/'tests/libname.prg';inv=json.loads((gate.parents[1]/'corpus/harbour-694428e1-inventory.json').read_text());assert hashlib.sha256(src.read_bytes()).hexdigest()==next(x['sha256'] for x in inv['files'] if x['path']=='tests/libname.prg')
for src in sorted((gate/'programs').glob('*.prg'))+[src]:
 w=out/src.stem;w.mkdir();external=src.parent==core/'tests'
 ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),src],w,'oracle-build');rr=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None
 for variant,flags in [('elf-int',[]),('elf-ext',['--external-as'])]:
  b=run([cc,src,w/variant,'--target=linux',*flags,'-I',str(core/'include')],w,'build-'+variant);r=run([w/variant],w,'run-'+variant) if b.returncode==0 else None
  add(src.stem+'-'+variant,rr and r and (rr.returncode,r.returncode,rr.stderr,r.stderr)==(0,0,b'',b'') and rr.stdout==r.stdout,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),external_source=external,build_rc=b.returncode,run_rc=r.returncode if r else None)
# Allocation growth, after warming caches. Candidate instrumentation, not oracle.
w=out/'memory';w.mkdir();s=(gate/'programs/ownership.prg').read_text().replace(' Work()\nRETURN NIL',' LOCAL n\n Work()\n n:=hb_memcheck()\n Work()\n ? hb_memcheck()-n\nRETURN NIL');(w/'p.prg').write_text(s);expected=(out/'ownership/oracle-run.stdout').read_bytes()*2+b'\n         0'
for variant,flags in [('elf-int',[]),('elf-ext',['--external-as'])]:
 b=run([cc,w/'p.prg',w/variant,'--target=linux','--instrument',*flags],w,'build-'+variant);r=run([w/variant],w,'run-'+variant) if b.returncode==0 else None
 add('memory-'+variant,r and r.returncode==0 and not r.stderr and r.stdout==expected,build_rc=b.returncode,run_rc=r.returncode if r else None)
# Named limits: Linux filenames only; no platform naming guessed for PE.
w=out/'limits';w.mkdir();(w/'p.prg').write_text('function main()\n? hb_libName("x")\nreturn nil\n')
for name,flags in [('windows',['--target=windows']),('darwin',['--target=macho']),('arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('llvm-no-trace',['--target=linux','--experimental-llvm-no-trace'])]:
 b=run([cc,w/'p.prg',w/name,*flags],w,'build-'+name);add('limit-'+name,b.returncode==1 and b'library filenames are measured only on ordinary Linux' in b.stderr and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
(w/'args.prg').write_text('function main()\n? hb_libName()\nreturn nil\n');b=run([cc,w/'args.prg',w/'args','--target=linux'],w,'build-args');add('limit-args',b.returncode==1 and b'hb_libName takes one or two' in b.stderr,build_rc=b.returncode)
for src in sorted((gate/'reject').glob('*.prg')):
 w=out/('reject-'+src.stem);w.mkdir()
 b=run([cc,src,w/'p','--target=linux'],w,'build')
 add('reject-'+src.stem,b.returncode==1 and b'use of moved value' in b.stderr and b'panicked' not in b.stderr and not (w/'p').exists(),build_rc=b.returncode)
# Same lifetime path as snapshot, checked for growth after cache warm-up.
w=out/'snapshot-memory';w.mkdir();s=(gate/'programs/snapshot.prg').read_text().replace(' Work()\nRETURN NIL',' LOCAL n\n Work()\n n:=hb_memcheck()\n Work()\n ? hb_memcheck()-n\nRETURN NIL');(w/'p.prg').write_text(s);want=(out/'snapshot/oracle-run.stdout').read_bytes()*2+b'\n         0'
for variant,flags in [('elf-int',[]),('elf-ext',['--external-as'])]:
 b=run([cc,w/'p.prg',w/variant,'--target=linux','--instrument',*flags],w,'build-'+variant);r=run([w/variant],w,'run-'+variant) if b.returncode==0 else None
 add('snapshot-memory-'+variant,r and r.returncode==0 and not r.stderr and r.stdout==want,build_rc=b.returncode,run_rc=r.returncode if r else None)
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),passed=sum(r['ok'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(r['ok'] for r in rows))
