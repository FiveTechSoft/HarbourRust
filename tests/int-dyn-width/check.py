#!/usr/bin/env python3
"""Original MIT: Int(Dyn integer) must retain tag-9 display provenance.
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
for src in sorted(P(__file__).resolve().parent.joinpath('programs').glob('*.prg')):
 w=out/src.stem;w.mkdir();text=src.read_text();(w/'p.prg').write_text(text)
 oracle=text
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
