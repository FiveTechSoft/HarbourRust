#!/usr/bin/env python3
"""Fresh Harbour differential + tracked heap lifetime, native ELF/PE runtime.
MachO checked separately as emission only. Classes remain Linux-only.
"""
import argparse,pathlib,subprocess,json,os,hashlib
p=argparse.ArgumentParser()
for k in ['compiler','hbmk2','output','wine','wine-prefix','multiarg']:p.add_argument('--'+k,required=True)
a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(parents=True,exist_ok=False);root=pathlib.Path(__file__).resolve().parents[2];rows=[];env=dict(os.environ,WINEDEBUG='-all',WINEPREFIX=a.wine_prefix)
sources=[pathlib.Path(a.multiarg)]+list((root/'tests/dyn-heap/programs').glob('*.prg'))+[root/'tests/t1367_hb_pvalue_float_neg.prg']
for src in sources:
 n=src.stem;code=src.read_text();oracle_src=r/(n+'-oracle.prg');oracle_src.write_text(code.replace('? hb_memcheck()',''))
 q=subprocess.run([a.hbmk2,'-quiet','-gtstd','-w0',oracle_src,'-o'+str(r/'oracle')],capture_output=True,timeout=60);(r/(n+'.hb-build')).write_bytes(q.stdout+q.stderr);assert q.returncode==0,(n,q.stderr)
 q=subprocess.run([r/'oracle'],capture_output=True,timeout=15);assert q.returncode==0 and not q.stderr;want=q.stdout;(r/(n+'.hb.stdout')).write_bytes(want);(r/'oracle').unlink()
 for target in (['linux'] if n=='data-float' else ['linux','windows']):
  for inst in [False,True]:
   label=n+'-'+target+'-'+str(inst);exe=r/'mine';q=subprocess.run([a.compiler,src,exe,'--target='+target]+(['--instrument'] if inst else []),capture_output=True,timeout=60);(r/(label+'.build')).write_bytes(q.stdout+q.stderr);assert q.returncode==0,(label,q.stderr)
   q=subprocess.run(([a.wine] if target=='windows' else [])+[str(exe)],capture_output=True,env=env,timeout=15);exe.unlink();(r/(label+'.stdout')).write_bytes(q.stdout);(r/(label+'.stderr')).write_bytes(q.stderr)
   # Existing classes retain arena+template until exit. Heap float adds one
   # template item. Not a claim of zero whole-class retained allocations.
   retained=3 if n=='data-float' else 0
   expected=want+(b'\n         '+str(retained).encode() if 'hb_memcheck' in code else b'')
   assert (q.returncode,q.stdout,q.stderr)==(0,expected,b''),(label,q.returncode,q.stdout,expected,q.stderr)
   rows.append(dict(source=n,target=target,instrument=inst,exact=True,retained_class_allocations=retained))
(r/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(pathlib.Path(a.compiler).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print(len(rows),'differential lifetime configurations PASS')
