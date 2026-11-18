#!/usr/bin/env python3
"""iif() with scalar branches of different types (string, integer, logical, float, literal NIL).
(1) Programs: ELF (internal and --external-as) and PE under Wine give stdout byte-identical to the external oracle (PE: CRLF).
(2) Memory rows N=1/500/1000 (ELF internal, ELF external, PE): owned strings, copies, floats, NIL and a Break inside a taken arm under TRY;
    hb_memcheck pending 0 and hits == N//2.
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
# print consumer: byte-identical to the oracle (prints 'pending 0' last) and pending 0
w=out/'mem-print';w.mkdir();src=(gate/'mem'/'print.prg').read_text();(w/'p.prg').write_text(src)
(w/'o.prg').write_text(''.join(l for l in src.splitlines(True) if 'baseline' not in l and 'pending' not in l).replace('Round1( 20 )\n','Round1( 20 )\n',1))
ob=sh([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'o.prg'],w,'oracle-build');orr=sh([w/'oracle'],w,'oracle-run');ok=ob.returncode==0 and orr.returncode==0 and len(orr.stdout)>0
want0=orr.stdout+b'\npending          0'
for who,cmd,win in [('elf-int',[cc,'p.prg','x-elf-int'],False),('elf-ext',[cc,'p.prg','x-elf-ext','--external-as'],False),('pe',[cc,'p.prg','x-pe.exe','--target=windows'],True)]:
    c=sh(cmd,w,'build-'+who);good=c.returncode==0
    if good:
        r=sh(['wine',w/'x-pe.exe'] if win else [w/('x-'+who)],w,'run-'+who);good=r.returncode==0 and r.stdout==(want0.replace(b'\n',b'\r\n') if win else want0) and r.stderr==b''
    ok=ok and good
add('mem-print','print-consumer-oracle-identical-and-pending-zero',ok)
TB='TRY\n   x := IIf( i % 2 == 0, Fails(), i )\n  CATCH\n   hits++\n  END'
for n in [1,500,1000]:
    w=out/('mem-%d'%n);w.mkdir();(w/'p.prg').write_text((gate/'mem'/'loop.prg').read_text().replace('@N@',str(n)).replace('TRYBLOCK',TB))
    exp=(('\nhits %10d'%(n//2))*2+'\npending %10d'%0).encode();ok=True
    for who,cmd,win in [('elf-int',[cc,'p.prg','x-elf-int'],False),('elf-ext',[cc,'p.prg','x-elf-ext','--external-as'],False),('pe',[cc,'p.prg','x-pe.exe','--target=windows'],True)]:
        c=sh(cmd,w,'build-'+who);good=c.returncode==0
        if good:
            r=sh(['wine',w/'x-pe.exe'] if win else [w/('x-'+who)],w,'run-'+who)
            good=r.returncode==0 and r.stdout==(exp.replace(b'\n',b'\r\n') if win else exp) and r.stderr==b''
        ok=ok and good
    add('mem-%d'%n,'pending-zero-and-hits',ok)

# rejection rows: each mixed iif consumer that does not release an owned cell on error is refused with the named diagnostic and no output
for src in sorted((gate/'reject').glob('*.prg')):
    w=out/('reject-'+src.stem);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes())
    c=sh([cc,'p.prg','x-elf-int'],w,'build')
    ok=c.returncode!=0 and b'mixed-type `iif` result' in c.stderr+c.stdout and not (w/'x-elf-int').exists()
    add('reject-'+src.stem,'named-rejection-no-output',ok)
# control rows: the same consumers with a non-mixed iif under TRY with a Break each other round: pending 0, hits N//2
for n in [1,500,1000]:
    w=out/('ctl-%d'%n);w.mkdir();(w/'p.prg').write_text((gate/'control'/'loop.prg').read_text().replace('@N@',str(n)))
    exp=('hits %10d\npending %10d\n'%(n//2,0)).encode();ok=True
    for who,cmd,win in [('elf-int',[cc,'p.prg','x-elf-int'],False),('elf-ext',[cc,'p.prg','x-elf-ext','--external-as'],False),('pe',[cc,'p.prg','x-pe.exe','--target=windows'],True)]:
        c=sh(cmd,w,'build-'+who);good=c.returncode==0
        if good:
            r=sh(['wine',w/'x-pe.exe'] if win else [w/('x-'+who)],w,'run-'+who)
            good=r.returncode==0 and r.stdout.replace(b'\r\n',b'\n').strip()==exp.strip() and r.stderr==b''
        ok=ok and good
    add('ctl-%d'%n,'valid-branch-consumers-pending-zero',ok)
# control: mixed iif as the LAST output item, a Break after it each other round
for n in [1,500,1000]:
    w=out/('last-%d'%n);w.mkdir();(w/'p.prg').write_text((gate/'control'/'last.prg').read_text().replace('@N@',str(n)))
    ok=True
    for who,cmd,win in [('elf-int',[cc,'p.prg','x-elf-int'],False),('elf-ext',[cc,'p.prg','x-elf-ext','--external-as'],False),('pe',[cc,'p.prg','x-pe.exe','--target=windows'],True)]:
        c=sh(cmd,w,'build-'+who);good=c.returncode==0
        if good:
            r=sh(['wine',w/'x-pe.exe'] if win else [w/('x-'+who)],w,'run-'+who)
            t=r.stdout.replace(b'\r\n',b'\n').decode().split('\n')
            good=r.returncode==0 and ('hits %10d'%(n//2)) in t and ('pending %10d'%0) in t and r.stderr==b''
        ok=ok and good
    add('last-%d'%n,'mixed-iif-last-item-under-break-pending-zero',ok)
# documented limit (existing behaviour, not this change): IF on a Dyn string ends the process, not catchable
w=out/'limit-if-condition';w.mkdir();(w/'p.prg').write_bytes((gate/'failure-mode-if-condition.prg.txt').read_bytes())
c=sh([cc,'p.prg','x-elf-int'],w,'build');r=sh([w/'x-elf-int'],w,'run') if c.returncode==0 else None
add('limit-if-condition','process-ends-uncatchable-documented',c.returncode==0 and r.returncode==1 and b'condition is not a logical' in r.stderr+r.stdout and b'recovered' not in r.stdout)
ident=dict(compiler_sha256=hashlib.sha256(P(cc).read_bytes()).hexdigest(),total=len(rows),passed=sum(r['pass_'] for r in rows))
(out/'results.json').write_text(json.dumps(dict(ident=ident,rows=rows),indent=1))
print('%d/%d'%(ident['passed'],ident['total']));raise SystemExit(0 if ident['passed']==ident['total'] else 1)
