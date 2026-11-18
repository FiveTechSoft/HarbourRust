#!/usr/bin/env python3
"""Parameters without type evidence travel in a tagged (Dyn) slot, as in Harbour.
Positive programs: stdout byte-identical to the external Harbour 3.2.1dev oracle on Linux (ELF internal and external as)
and Windows (mingw oracle under Wine vs PE internal/external). forward-memory uses hb_memcheck (not in Harbour): hbc output
must equal forward-memory.expected on both targets (CRLF on Windows). Negative programs: named rejection on both targets.
Edge rows: an uncaught rejection exits 1 and the named error and call stack are written to STDOUT (stderr stays empty), like the other named runtime errors.
Original contribution: Julio Ponce (MIT); fixtures, S4 guard and gate added here."""
import argparse,pathlib,subprocess,json,hashlib,os,sys
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['--compiler','--hbmk2','--tree','--output','--mingw-lib']:ap.add_argument(k,required=True)
a=ap.parse_args();gate=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);compiler=str(P(a.compiler).resolve())
env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],HB_CCPATH='/tmp/toolchain/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',WINEDEBUG='-all',HBC_MINGW_LIB=a.mingw_lib,LC_ALL='C.UTF-8')
lenv={k:v for k,v in env.items() if k not in ('HB_CCPATH','HB_CCPREFIX')}
rows=[]
def add(name,kind,ok,**kw):
    rows.append(dict(test=name,kind=kind,pass_=bool(ok),**kw));print('PASS' if ok else 'FAIL',name,flush=True)
def sh(cmd,w,label,t=120,run_env=None):
    p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=run_env or env,stdin=subprocess.DEVNULL,timeout=t)
    for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
    return p
def builds(w):
    sh([compiler,'p.prg','lin-int'],w,'lin-int-build');sh([compiler,'p.prg','lin-ext','--external-as'],w,'lin-ext-build')
    sh([compiler,'p.prg','win-int.exe','--target=windows'],w,'win-int-build');sh([compiler,'p.prg','win-ext.exe','--target=windows','--external-as'],w,'win-ext-build')
targets=[('linux-internal',lambda w:[w/'lin-int']),('linux-external',lambda w:[w/'lin-ext']),('windows-internal',lambda w:['wine',w/'win-int.exe']),('windows-external',lambda w:['wine',w/'win-ext.exe'])]
for name in ['unused','forward','shared-element']:
    w=out/name;w.mkdir();(w/'p.prg').write_bytes((gate/(name+'.prg')).read_bytes())
    sh([a.hbmk2,'p.prg','-gtstd','-quiet','-w0','-olo'],w,'oracle-linux-build',run_env=lenv);sh([a.hbmk2,'p.prg','-gtstd','-plat=win','-comp=mingw64','-quiet','-w0','-oow'],w,'oracle-win-build')
    ol=sh([w/'lo'],w,'oracle-linux-run');ow=sh(['wine',w/'ow.exe'],w,'oracle-win-run');builds(w)
    for who,mk in targets:
        cmd=mk(w);ref=ol if who.startswith('linux') else ow
        ok=P(str(cmd[-1])).exists()
        if ok:
            r=sh(cmd,w,'run-'+who);ok=r.returncode==ref.returncode==0 and r.stdout==ref.stdout and r.stderr==ref.stderr
        add(name+'-'+who,'byte-identical-to-oracle',ok,stdout_sha256=hashlib.sha256(ref.stdout).hexdigest())
    add(name+'-oracle-sane','oracle-nonempty',ol.returncode==0 and len(ol.stdout)>0 and ow.stdout.replace(b'\r\n',b'\n')==ol.stdout)
name='forward-memory';w=out/name;w.mkdir();(w/'p.prg').write_bytes((gate/'forward-memory.prg').read_bytes());exp=(gate/'forward-memory.expected').read_bytes();builds(w)
for who,mk in targets:
    cmd=mk(w);ok=P(str(cmd[-1])).exists()
    if ok:
        r=sh(cmd,w,'run-'+who);want=exp if who.startswith('linux') else exp.replace(b'\n',b'\r\n');ok=r.returncode==0 and r.stdout==want and r.stderr==b''
    add(name+'-'+who,'hbc-measured-expected-bytes',ok)
# Dyn values that hold an object (tag 13) passed to a defaulted-Dyn parameter (no body evidence) are rejected at RUNTIME with the
# named error "Object in untyped parameter" before the callee starts (caught by TRY here). Shapes: a Dyn variable (var13), a Dyn
# return used directly as the argument (ret13: owned temporary, its owner is released), a Dyn assigned from the call (ident13,
# identret13), and an earlier materialized argument in the same call (two13/two13b: the cloned string casilla must be released).
# Every program: fresh objects every turn, the survivor `o` is read AFTER new objects were created and written (7 + 11 + 13 per turn,
# a premature free or reused block would change the sum), hits == N (every call rejected), pending == 0. ctl: scalar, string, NIL,
# logical and float arguments are NOT rejected (hits 0). A v5 compiler (no runtime screen) fails every rejecting row.
dyn_rows=[('var13',31,True),('ret13',31,True),('ident13',31,True),('identret13',31,True),('two13',31,True),('two13b',31,True),('ctl',18,False)]
for shape,per,rej in dyn_rows:
  for n in [1,500,1000]:
    name='dynobj-%s-%d'%(shape,n);w=out/name;w.mkdir()
    (w/'p.prg').write_text((gate/'dynobj'/(shape+'.prg')).read_text().replace('@N@',str(n)));builds(w);ok=True
    h=n if rej else 0
    ex=(('\nhits %10d'%h)*2+'\nsum %10d\npending %10d'%(per*n,0)).encode()
    for who,mk in targets:
        cmd=mk(w);good=P(str(cmd[-1])).exists()
        if good:
            r=sh(cmd,w,'run-'+who);want=ex if who.startswith('linux') else ex.replace(b'\n',b'\r\n');good=r.returncode==0 and r.stdout==want and r.stderr==b''
        ok=ok and good
    add(name,'runtime-rejection-alive-and-memory-zero-both-targets' if rej else 'control-not-rejected',ok,bound=0,expected_hits=h,expected_sum=per*n)
# Edge rows: the callee body is NOT entered (sentinel "ENTERED" never printed; the parameters stay unevidenced), both argument orders and an
# omitted trailing argument are rejected under TRY, and an UNCAUGHT rejection exits 1 with the named error on stderr.
edge_rows=[('sentinel',b'\ncaught1\ncaught2\ncaught3\nend',0,b''),('uncaught',b'\nbefore',1,b'Object in untyped parameter'),('ctl-nest1',b'\nok',0,b''),('ctl-nest2',b'\nok',0,b'')]
for shape,ex0,rc0,errsub in edge_rows:
    name='edge-%s'%shape;w=out/name;w.mkdir();(w/'p.prg').write_bytes((gate/'edge'/(shape+'.prg')).read_bytes());builds(w);ok=True
    for who,mk in targets:
        cmd=mk(w);good=P(str(cmd[-1])).exists()
        if good:
            r=sh(cmd,w,'run-'+who);want=ex0 if who.startswith('linux') else ex0.replace(b'\n',b'\r\n');good=r.returncode==rc0 and b'ENTERED' not in r.stdout and r.stderr==b'' and ((r.stdout==want) if rc0==0 else (r.stdout.startswith(want) and errsub in r.stdout and b'after' not in r.stdout))
        ok=ok and good
    add(name,'callee-not-entered-named-runtime-error',ok)
S4=b'passing the shared module array'
OBJ=b'passing an object as argument'
OBJ2=b'cannot infer the type of parameter'
msgs={'other-arg-self-method':b'an object argument (argument 1) in a call to','other-arg-byref-first':b'a `@` argument (argument 1) in a call to','other-arg-byref':b'a `@` argument (argument 2) in a call to','other-arg-obj':b'an object argument (argument 2) in a call to','object-arg-return':OBJ,'object-arg-new':OBJ,'object-arg-byref':OBJ2,'object-data-member':b'DATA `ref` holding an object is not in this increment','object-arg-discarded':OBJ,'object-arg-print':OBJ,'object-arg-multi':OBJ,'object-arg-local':OBJ,'object-arg-file':OBJ,'shared-call-arg':S4,'shared-alias':S4,'shared-via-forwarder':S4,'shared-second-argument':S4,'shared-byref':b'shared-array use is outside the dynamic increment','local-array':b'a static array argument is copied at the boundary only into a flat dynamic-array parameter'}
for src in sorted((gate/'neg').glob('*.prg')):
    w=out/('neg-'+src.stem);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes());ok=True
    for tgt in ['linux','windows']:
        r=sh([compiler,'p.prg','x-'+tgt,'--target='+tgt],w,'build-'+tgt);ok=ok and r.returncode==1 and msgs[src.stem] in r.stderr and b'panic' not in r.stderr and not (w/('x-'+tgt)).exists()
    add('neg-'+src.stem,'named-rejection-both-targets',ok)
ident=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),scope='Linux ELF and Windows PE under Wine; external Harbour 3.2.1dev oracle (not Harbour 4)',total=len(rows),passed=sum(r['pass_'] for r in rows),rows=rows)
(out/'results.json').write_text(json.dumps(ident,indent=2));sys.exit(0 if ident['total']==ident['passed'] else 1)
