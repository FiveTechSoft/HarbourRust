#!/usr/bin/env python3
"""Dyn*Dyn float multiplication. (1) PE under Wine: stdout byte-identical to the Linux external-oracle output of the same program (CRLF).
(2) Memory rows (hb_memcheck pending 0) N=1/500/1000 for owned temporaries, chained temporaries and the error path under TRY.
Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4)."""
import argparse,pathlib,subprocess,json,hashlib,os
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['--compiler','--hbmk2','--output','--mingw-lib']:ap.add_argument(k,required=True)
a=ap.parse_args();gate=P(__file__).resolve().parent;prog=gate.parent/'dyn-dyn-plus'/'programs';out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(P(a.compiler).resolve())
env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],HB_CCPATH='/tmp/toolchain/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',WINEDEBUG='-all',HBC_MINGW_LIB=a.mingw_lib,LC_ALL='C.UTF-8')
lenv={k:v for k,v in env.items() if k not in ('HB_CCPATH','HB_CCPREFIX')}
rows=[]
def add(n,k,ok,**kw):
    rows.append(dict(test=n,kind=k,pass_=bool(ok),**kw));print('PASS' if ok else 'FAIL',n,flush=True)
def sh(cmd,w,label,e=None):
    p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=e or env,stdin=subprocess.DEVNULL,timeout=120)
    for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
    return p
def oracle(s):
    lines=s.splitlines();st=next(i for i,l in enumerate(lines) if l.lower().startswith('function main()'))+1
    while st<len(lines) and lines[st].strip().lower().startswith('local '):st+=1
    lines.insert(st,'ErrorBlock({|err| Break(err)})');s='\n'.join(lines)+'\n'
    return s.replace('try\n','begin sequence\n').replace('catch e\n','recover using e\n').replace('\nend\n','\nend sequence\n')
# (1) PE vs oracle
for name in ['float-dyn','mulf-values','mulf-errors']:
    w=out/('pe-'+name);w.mkdir();(w/'o.prg').write_text(oracle((prog/(name+'.prg')).read_text()))
    ob=sh([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'o.prg'],w,'oracle-build',lenv);orr=sh([w/'oracle'],w,'oracle-run',lenv)
    (w/'p.prg').write_bytes((prog/(name+'.prg')).read_bytes());ok=ob.returncode==0 and orr.returncode==0
    want=orr.stdout.replace(b'\n',b'\r\n')
    for who,flag in [('internal',[]),('external',['--external-as'])]:
        c=sh([cc,'p.prg','x-'+who+'.exe','--target=windows']+flag,w,'build-'+who);good=c.returncode==0
        if good:
            r=sh(['wine',w/('x-'+who+'.exe')],w,'run-'+who);good=r.returncode==orr.returncode and r.stdout==want and r.stderr==b''
        ok=ok and good
    add('pe-'+name,'pe-stdout-byte-identical-to-oracle',ok)
# (2) memory rows, ELF internal/external and PE internal
TB='try\n  r:=a*s\n catch e\n  hits:=hits+1\n end'
for shape,tryb in [('owned',''),('try',TB)]:
  for n in [1,500,1000]:
    w=out/('mem-%s-%d'%(shape,n));w.mkdir();src=(gate/'mem'/'loop.prg').read_text().replace('@N@',str(n)).replace('TRYBLOCK',tryb)
    (w/'p.prg').write_text(src);ok=True
    h=n if shape=='try' else 0;exp=(('\nhits %10d'%h)*2+'\npending %10d'%0).encode()
    for who,cmd,flag in [('lin-int',[cc,'p.prg','x-lin-int'],None),('lin-ext',[cc,'p.prg','x-lin-ext','--external-as'],None),('win-int',[cc,'p.prg','x-win-int.exe','--target=windows'],'wine')]:
        c=sh(cmd,w,'build-'+who);good=c.returncode==0
        if good:
            r=sh(['wine',w/'x-win-int.exe'] if flag else [w/('x-'+who)],w,'run-'+who);want=exp.replace(b'\n',b'\r\n') if flag else exp
            good=r.returncode==0 and r.stdout==want and r.stderr==b''
        ok=ok and good
    add('mem-%s-%d'%(shape,n),'pending-zero-and-hits',ok)
ident=dict(compiler_sha256=hashlib.sha256(P(cc).read_bytes()).hexdigest(),total=len(rows),passed=sum(r['pass_'] for r in rows))
(out/'results.json').write_text(json.dumps(dict(ident=ident,rows=rows),indent=1))
print('%d/%d'%(ident['passed'],ident['total']));raise SystemExit(0 if ident['passed']==ident['total'] else 1)
