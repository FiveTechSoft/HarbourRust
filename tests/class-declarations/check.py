#!/usr/bin/env python3
"""Original MIT: class declaration ordering, lists, and dynamic ClassName.
Harbour is an external oracle only; source programs and harness are original.
"""
import argparse,hashlib,json,os,pathlib,re,subprocess
P=pathlib.Path
ap=argparse.ArgumentParser()
for k in ('compiler','hbmk2','output'): ap.add_argument('--'+k,required=True)
ap.add_argument("--harbour-core",type=P)
a=ap.parse_args(); out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
cc=P(a.compiler).resolve(); env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all')
rows=[]
def run(cmd,w,name):
 try: p=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=120)
 except subprocess.TimeoutExpired as e: p=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for ext,data in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]: (w/(name+'.'+ext)).write_bytes(data)
 return p
sources=sorted(P(__file__).resolve().parent.joinpath('programs').glob('*.prg'))
if a.harbour_core:
 src=a.harbour_core.resolve()/'tests/classch.prg'
 inv=json.loads((P(__file__).resolve().parents[2]/'corpus/harbour-694428e1-inventory.json').read_text())
 expected=next(x['sha256'] for x in inv['files'] if x['path']=='tests/classch.prg')
 assert hashlib.sha256(src.read_bytes()).hexdigest()==expected
 sources.append(src)
for src in sources:
 w=out/src.stem;w.mkdir();external=src.stem=='classch'
 if not external:
  (w/'p.prg').write_bytes(src.read_bytes());(w/'o.prg').write_bytes(src.read_bytes())
 candidate=src if external else w/'p.prg'
 oracle=src if external else w/'o.prg'
 ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),oracle],w,'oracle-build')
 rr=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None
 for variant,flags in [('elf-int',['--target=linux']),('elf-ext',['--target=linux','--external-as']),('pe',['--target=windows'])]:
  binary=w/('x.exe' if variant=='pe' else 'x-'+variant)
  b=run([cc,candidate,binary,*flags,*(['-I',str(a.harbour_core.resolve()/'include')] if external else [])],w,'build-'+variant)
  r=run(['wine',binary] if variant=='pe' else [binary],w,'run-'+variant) if b.returncode==0 else None
  want=rr.stdout.replace(b'\n',b'\r\n') if rr and variant=='pe' else (rr.stdout if rr else None)
  ok=bool(rr and rr.returncode==0 and not rr.stderr and r and r.returncode==0 and not r.stderr and r.stdout==want)
  rows.append(dict(source=src.name,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),external_source=external,variant=variant,ok=ok,oracle_build_rc=ob.returncode,oracle_run_rc=rr.returncode if rr else None,build_rc=b.returncode,run_rc=r.returncode if r else None))
  print(src.stem,variant,'PASS' if ok else 'FAIL',flush=True)
# Candidate-only allocation-growth check after warming class caches.
# hb_memcheck is an instrumentation extension, never an oracle claim.
stress=P(__file__).resolve().parent/'programs/stress.prg'
w=out/'allocation-growth';w.mkdir()
text=stress.read_text().replace(' Work()\nRETURN NIL',' LOCAL n\n Work()\n n := hb_memcheck()\n Work()\n ? hb_memcheck()-n\nRETURN NIL')
(w/'p.prg').write_text(text)
expected=(out/'stress/oracle-run.stdout').read_bytes()*2+b'\n         0'
for variant,flags in [('elf-int',['--target=linux']),('elf-ext',['--target=linux','--external-as']),('pe',['--target=windows'])]:
 binary=w/('x-'+variant+('.exe' if variant=='pe' else ''))
 b=run([cc,w/'p.prg',binary,*flags,'--instrument'],w,'build-'+variant)
 r=run(['wine',binary] if variant=='pe' else [binary],w,'run-'+variant) if b.returncode==0 else None
 want=expected.replace(b'\n',b'\r\n') if variant=='pe' else expected
 ok=bool(r and r.returncode==0 and not r.stderr and r.stdout==want)
 rows.append(dict(source='allocation-growth',variant=variant,ok=ok,build_rc=b.returncode,run_rc=r.returncode if r else None))
 print('allocation-growth',variant,'PASS' if ok else 'FAIL',flush=True)
for src in sorted(P(__file__).resolve().parent.joinpath('reject').glob('*.prg')):
 w=out/('reject-'+src.stem);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes())
 limit_ok=True
 if src.stem=='name-args':
  ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'p.prg'],w,'oracle-build')
  rr=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None
  limit_ok=bool(rr and rr.returncode==0 and not rr.stderr and rr.stdout==b'\nA')
 for variant,flags in [('elf-int',['--target=linux']),('elf-ext',['--target=linux','--external-as']),('pe',['--target=windows'])]:
  binary=w/('x-'+variant)
  b=run([cc,w/'p.prg',binary,*flags],w,'build-'+variant)
  expected={'cycle':b'inheritance cycle','missing-parent':b'unknown class','trailing-list':b'trailing comma','name-args':b'ClassName expects no arguments','duplicate-list':b'duplicate DATA name'}[src.stem]
  ok=limit_ok and b.returncode==1 and expected in b.stderr and b'panicked' not in b.stderr and not binary.exists()
  rows.append(dict(source=src.name,variant=variant,ok=ok,build_rc=b.returncode))
  print('reject-'+src.stem,variant,'PASS' if ok else 'FAIL',flush=True)
result=dict(runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),rows=rows,passed=sum(x['ok'] for x in rows),total=len(rows))
(out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
print(result['passed'], '/',result['total']);raise SystemExit(0 if all(x['ok'] for x in rows) else 1)
