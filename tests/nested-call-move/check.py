#!/usr/bin/env python3
"""Nested calls that consume an owned string variable, F(G(s), d): not a use after move.
(1) Programs: ELF (internal and --external-as) and PE under Wine give stdout byte-identical to the external oracle (PE: CRLF).
(2) Memory rows N=1/500/1000 (ELF internal, ELF external, PE): hb_memcheck pending 0.
Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4)."""
import argparse,pathlib,subprocess,json,hashlib,os
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['--compiler','--hbmk2','--output']:ap.add_argument(k,required=True)
a=ap.parse_args();gate=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(P(a.compiler).resolve())
env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all',LC_ALL='C.UTF-8')
rows=[]
def add(n,k,ok,**kw):
    rows.append(dict(test=n,kind=k,pass_=bool(ok),**kw));print('PASS' if ok else 'FAIL',n,flush=True)
def sh(cmd,w,label):
    p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=env,stdin=subprocess.DEVNULL,timeout=120)
    for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
    return p
for src in sorted((gate/'programs').glob('*.prg')):
    name=src.stem;w=out/('prog-'+name);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes())
    ob=sh([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'p.prg'],w,'oracle-build');orr=sh([w/'oracle'],w,'oracle-run')
    ok=ob.returncode==0 and orr.returncode==0 and len(orr.stdout)>0
    for who,cmd,win in [('elf-int',[cc,'p.prg','x-elf-int'],False),('elf-ext',[cc,'p.prg','x-elf-ext','--external-as'],False),('pe',[cc,'p.prg','x-pe.exe','--target=windows'],True)]:
        c=sh(cmd,w,'build-'+who);good=c.returncode==0
        if good:
            r=sh(['wine',w/'x-pe.exe'] if win else [w/('x-'+who)],w,'run-'+who)
            want=orr.stdout.replace(b'\n',b'\r\n') if win else orr.stdout
            good=r.returncode==orr.returncode and r.stdout==want and r.stderr==b''
        ok=ok and good
    add('prog-'+name,'stdout-byte-identical-to-oracle',ok)
for n in [1,500,1000]:
    w=out/('mem-%d'%n);w.mkdir();(w/'p.prg').write_text((gate/'mem'/'loop.prg').read_text().replace('@N@',str(n)))
    exp=b'\npending %10d'%0;ok=True
    for who,cmd,win in [('elf-int',[cc,'p.prg','x-elf-int'],False),('elf-ext',[cc,'p.prg','x-elf-ext','--external-as'],False),('pe',[cc,'p.prg','x-pe.exe','--target=windows'],True)]:
        c=sh(cmd,w,'build-'+who);good=c.returncode==0
        if good:
            r=sh(['wine',w/'x-pe.exe'] if win else [w/('x-'+who)],w,'run-'+who)
            good=r.returncode==0 and r.stdout==(exp.replace(b'\n',b'\r\n') if win else exp) and r.stderr==b''
        ok=ok and good
    add('mem-%d'%n,'pending-zero',ok)
ident=dict(compiler_sha256=hashlib.sha256(P(cc).read_bytes()).hexdigest(),total=len(rows),passed=sum(r['pass_'] for r in rows))
(out/'results.json').write_text(json.dumps(dict(ident=ident,rows=rows),indent=1))
print('%d/%d'%(ident['passed'],ident['total']));raise SystemExit(0 if ident['passed']==ident['total'] else 1)
