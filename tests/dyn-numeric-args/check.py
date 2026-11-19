#!/usr/bin/env python3
"""Numeric builtins Str Int Abs Max Min Round Sqrt Mod and the operator % with a Dyn operand, and arithmetic with a Dyn operand as their argument or as an argument of a
function with a Dyn parameter. Before, these compiled and stopped at run time with "NIL used as a number" (arithmetic argument), or were rejected by name (a plain Dyn).
(1) programs/values.prg: ELF (internal, --external-as) and PE under Wine give stdout byte-identical to the external oracle (PE: CRLF).
(2) memory rows N=1/500/1000 x ELF internal, ELF external, PE: owned temporaries as arguments, throws in the other argument of Max/Min, NIL and string
    operand errors; hb_memcheck pending 0, the Dyn float operand unchanged, hit and callee entry counters.
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
    s=re.sub(r'^(\s*)try$',r'\1begin sequence',s,flags=re.M);s=re.sub(r'^(\s*)catch$',r'\1recover',s,flags=re.M)
    return re.sub(r'^(\s*)end$',r'\1end sequence',s,flags=re.M)
def run(w,who,cmd,win):
    c=sh([cc]+cmd,w,'build-'+who)
    if c.returncode!=0:return None
    return sh(['wine',w/'x-pe.exe'] if win else [w/('x-'+who)],w,'run-'+who)
for src in sorted((gate/'programs').glob('*.prg')):
    w=out/('prog-'+src.stem);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes());(w/'o.prg').write_text(oracle(src.read_text()))
    ob=sh([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'o.prg'],w,'oracle-build');orr=sh([w/'oracle'],w,'oracle-run')
    ok=ob.returncode==0 and orr.returncode==0 and len(orr.stdout)>0
    for who,cmd,win in TARGETS:
        r=run(w,who,cmd,win);want=orr.stdout.replace(b'\n',b'\r\n') if win else orr.stdout
        ok=ok and r is not None and r.returncode==0 and r.stdout==want and r.stderr==b''
    add('prog-'+src.stem,'stdout-byte-identical-to-oracle',ok)
for src in []:
    w=out/('ctl-'+src.stem);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes());(w/'o.prg').write_text(oracle(src.read_text()))
    ob=sh([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'o.prg'],w,'oracle-build');orr=sh([w/'oracle'],w,'oracle-run')
    ok=ob.returncode==0 and orr.returncode==0 and len(orr.stdout)>0
    for who,cmd,win in TARGETS:
        r=run(w,who,cmd,win);want=orr.stdout.replace(b'\n',b'\r\n') if win else orr.stdout
        ok=ok and r is not None and r.returncode==0 and r.stdout==want and r.stderr==b''
    add('ctl-'+src.stem,'stdout-byte-identical-to-oracle',ok)
# (kind, TRY block, hits per round, callee entries per round)
ROUNDS=[('owned','r := Str( a + 1 ) + Str( b * c )\n  r := Int( a * b ) + Int( c - 1 )\n  r := Abs( a - b ) + Abs( c )\n  r := Max( a + 1, b ) + Min( a, c * 2 )\n  r := Round( a + 1.26, 1 ) + Sqrt( a * 4 ) + Mod( a + 1, 2 ) + a % 1\n  r := Id( a - b ) + Id( c * 2 )',0,0),
 ('max-right-throw','TRY\n   r := Max( a + 1, Boom() )\n  CATCH\n   hits++\n  END',1,1),
 ('min-left-throw','TRY\n   r := Min( Boom(), a * 2 )\n  CATCH\n   hits++\n  END',1,1),
 ('max-both-owned','TRY\n   r := Max( Id( a + 1 ), Boom() )\n  CATCH\n   hits++\n  END',1,1),
 ('abs-nil-error','TRY\n   r := Abs( e )\n  CATCH\n   hits++\n  END',1,0),
 ('max-string-error','TRY\n   r := Max( a + 1, s )\n  CATCH\n   hits++\n  END',1,0),
 ('int-nil-sum-error','TRY\n   r := Int( e + 1 )\n  CATCH\n   hits++\n  END',1,0),
 ('mod-string-error','TRY\n   r := Mod( s, 2 )\n  CATCH\n   hits++\n  END',1,0),
 ('mod-nil-tick','TRY\n   r := Mod( e, Tick() )\n  CATCH\n   hits++\n  END',1,1),
 ('round-nil-tick','TRY\n   r := Round( e, Tick() )\n  CATCH\n   hits++\n  END',1,1),
 ('pct-nil-tick','TRY\n   r := e % Tick()\n  CATCH\n   hits++\n  END',1,1),
 ('mod-nil-boom','TRY\n   r := Mod( e, Boom() )\n  CATCH\n   hits++\n  END',1,1),
 ('str-own-tick','TRY\n   r := Str( Id( s ), Tick() )\n  CATCH\n   hits++\n  END',1,1),
 ('round-str-tick','TRY\n   r := Round( s, Tick() )\n  CATCH\n   hits++\n  END',1,1)]
for kind,blk,hm,em in ROUNDS:
    for n in [1,500,1000]:
        w=out/('mem-%s-%d'%(kind,n));w.mkdir()
        (w/'p.prg').write_text((gate/'mem'/'loop.prg').read_text().replace('@N@',str(n)).replace('TRYBLOCK',blk))
        h=str(n*hm);e=str(n*em);want=['hits',h,'a','1.5','entered',e,'hits',h,'a','1.5','entered',e,'pending','0'];ok=True
        for who,cmd,win in TARGETS:
            r=run(w,who,cmd,win)
            ok=ok and r is not None and r.returncode==0 and r.stderr==b'' and r.stdout.replace(b'\r\n',b'\n').decode().split()==want
        add('mem-%s-%d'%(kind,n),'pending-zero-hits-entered-a-unchanged',ok)
ident=dict(compiler_sha256=hashlib.sha256(P(cc).read_bytes()).hexdigest(),total=len(rows),passed=sum(r['pass_'] for r in rows))
(out/'results.json').write_text(json.dumps(dict(ident=ident,rows=rows),indent=1))
print('%d/%d'%(ident['passed'],ident['total']));raise SystemExit(0 if ident['passed']==ident['total'] else 1)
