#!/usr/bin/env python3
"""Original MIT: sequence unwinding must discard skipped MEMVAR frames.
Harbour is an external oracle only; source programs and harness are original.
"""
import argparse,hashlib,json,os,pathlib,re,subprocess
P=pathlib.Path
ap=argparse.ArgumentParser()
for k in ('compiler','hbmk2','output'): ap.add_argument('--'+k,required=True)
a=ap.parse_args(); out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
cc=P(a.compiler).resolve(); env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all')
rows=[]
def run(cmd,w,name):
 try: p=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=120)
 except subprocess.TimeoutExpired as e: p=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for ext,data in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]: (w/(name+'.'+ext)).write_bytes(data)
 return p
layout=run(['cc','-std=c99','-Wall','-Wextra','-Werror','-c',P(__file__).with_name('layout.c').resolve(),'-o',out/'layout.o'],out,'layout-build')
if layout.returncode: raise SystemExit('C layout no longer matches the assembly shim')
for src in sorted(P(__file__).resolve().parent.glob('*.prg')):
 w=out/src.stem;w.mkdir();text=src.read_text();(w/'p.prg').write_text(text)
 oracle=re.sub(r'(?im)^(\s*)try\s*$',r'\1begin sequence',text)
 oracle=re.sub(r'(?im)^(\s*)catch(?:\s+(\w+))?\s*$',lambda m:m[1]+'recover'+(' using '+m[2] if m[2] else ''),oracle)
 # All plain END statements in these fixtures close TRY; FOR uses NEXT.
 oracle=re.sub(r'(?im)^(\s*)end\s*$',r'\1end sequence',oracle)
 (w/'o.prg').write_text(oracle)
 ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'o.prg'],w,'oracle-build')
 rr=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None
 for variant,flags in [('elf-int',['--target=linux']),('elf-ext',['--target=linux','--external-as']),('pe',['--target=windows'])]:
  binary=w/('x.exe' if variant=='pe' else 'x-'+variant)
  b=run([cc,w/'p.prg',binary,*flags],w,'build-'+variant)
  r=run(['wine',binary] if variant=='pe' else [binary],w,'run-'+variant) if b.returncode==0 else None
  want=rr.stdout.replace(b'\n',b'\r\n') if rr and variant=='pe' else (rr.stdout if rr else None)
  ok=bool(rr and rr.returncode==0 and not rr.stderr and r and r.returncode==0 and not r.stderr and r.stdout==want)
  rows.append(dict(source=src.name,variant=variant,ok=ok,build_rc=b.returncode,run_rc=r.returncode if r else None))
  print(src.stem,variant,'PASS' if ok else 'FAIL',flush=True)
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),rows=rows,passed=sum(x['ok'] for x in rows),total=len(rows))
(out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
print(result['passed'], '/',result['total']);raise SystemExit(0 if all(x['ok'] for x in rows) else 1)
