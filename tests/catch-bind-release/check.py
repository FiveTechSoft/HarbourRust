#!/usr/bin/env python3
"""catch variable reuse: `CATCH e` now releases the value the slot still holds before it takes the new exception.
(1) programs/values.prg: ELF (internal, --external-as) and PE under Wine give stdout byte-identical to the external oracle
    (PE: CRLF); the oracle program is the same text with TRY/CATCH/END turned into BEGIN SEQUENCE/RECOVER USING/END SEQUENCE.
(2) Memory rows N=1/500/1000 x ELF internal, ELF external, PE: for each kind of value Break() admits (string literal, owned
    string, string-returning call, Dyn float, Dyn array, Dyn string, integer, NIL), plus the catch variable preset, reassigned
    by the user inside the CATCH (string and Dyn float), and a nested TRY reusing the same variable.
    Expected: hits == N*HITSMUL (printed twice-run second value) and hb_memcheck pending == 0.
Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4)."""
import argparse,pathlib,subprocess,json,hashlib,os,re
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
TARGETS=[('elf-int',['p.prg','x-elf-int'],False),('elf-ext',['p.prg','x-elf-ext','--external-as'],False),('pe',['p.prg','x-pe.exe','--target=windows'],True)]
def oracle(s):
    lines=s.splitlines();st=next(i for i,l in enumerate(lines) if l.lower().startswith('function main()'))+1
    while st<len(lines) and lines[st].strip().lower().startswith('local '):st+=1
    lines.insert(st,'ErrorBlock({|err| Break(err)})');s='\n'.join(lines)+'\n'
    s=re.sub(r'^(\s*)try$',r'\1begin sequence',s,flags=re.M);s=re.sub(r'^(\s*)catch e$',r'\1recover using e',s,flags=re.M)
    return re.sub(r'^(\s*)end$',r'\1end sequence',s,flags=re.M)
def run(w,who,cmd,win):
    c=sh([cc]+cmd,w,'build-'+who)
    if c.returncode!=0:return None
    return sh(['wine',w/'x-pe.exe'] if win else [w/('x-'+who)],w,'run-'+who)
# (1) programs vs oracle
for src in sorted((gate/'programs').glob('*.prg')):
    w=out/('prog-'+src.stem);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes());(w/'o.prg').write_text(oracle(src.read_text()))
    ob=sh([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'o.prg'],w,'oracle-build');orr=sh([w/'oracle'],w,'oracle-run')
    ok=ob.returncode==0 and orr.returncode==0 and len(orr.stdout)>0
    for who,cmd,win in TARGETS:
        r=run(w,who,cmd,win);want=orr.stdout.replace(b'\n',b'\r\n') if win else orr.stdout
        ok=ok and r is not None and r.returncode==0 and r.stdout==want and r.stderr==b''
    add('prog-'+src.stem,'stdout-byte-identical-to-oracle',ok)
# (2) memory rows
NEST='TRY\n    Break( "out" + Str( i, 3 ) )\n   CATCH e\n    hits++\n   END'
KINDS=[('lit','','"lit"','',1),('owned','','"a" + Str( i, 3 )','',1),('call','','Own()','',1),
 ('dynfloat','d := a * b','d','',1),('dynarr','d := { 1, "x" }','d','',1),('dynstr','d := "s" + Str( i, 3 )','d','',1),
 ('int','','i','',1),('nil','','NIL','',1),('preset','e := "pre" + Str( i, 3 )','"x" + Str( i, 3 )','',1),
 ('reassign-str','','"x" + Str( i, 3 )','e := "mine" + Str( i, 3 )',1),('reassign-float','','"x" + Str( i, 3 )','e := a * b',1),
 ('nested','','"in" + Str( i, 3 )',NEST,2)]
for kind,pre,ex,post,mul in KINDS:
    for n in [1,500,1000]:
        w=out/('mem-%s-%d'%(kind,n));w.mkdir()
        src=(gate/'mem'/'loop.prg').read_text().replace('@N@',str(n)).replace('KINDPRE',pre).replace('KINDEXPR',ex).replace('KINDPOST',post)
        (w/'p.prg').write_text(src);exp=('hits %10d\npending %10d\n'%(n*mul,0)).encode();ok=True
        for who,cmd,win in TARGETS:
            r=run(w,who,cmd,win)
            ok=ok and r is not None and r.returncode==0 and r.stdout.replace(b'\r\n',b'\n').strip()==exp.strip() and r.stderr==b''
        add('mem-%s-%d'%(kind,n),'pending-zero-and-hits',ok)
ident=dict(compiler_sha256=hashlib.sha256(P(cc).read_bytes()).hexdigest(),total=len(rows),passed=sum(r['pass_'] for r in rows))
(out/'results.json').write_text(json.dumps(dict(ident=ident,rows=rows),indent=1))
print('%d/%d'%(ident['passed'],ident['total']));raise SystemExit(0 if ident['passed']==ident['total'] else 1)
