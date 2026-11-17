#!/usr/bin/env python3
"""Type predicates (hb_IsHash/Object/Nil/Logical/Date/Block/Char), hb_Hash() and ValType of hash/block variables.
Positive programs: stdout byte-identical to the external Harbour 3.2.1dev oracle on Linux (ELF, internal and external as)
and on Windows (mingw oracle under Wine vs PE internal/external). Negative programs: named compile rejection.
Contributed by Julio Ponce (MIT); fixtures and oracle comparison added here."""
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
positives=[('predicates',gate/'predicates.prg'),('t415',gate.parent/'t415_valtype_hash.prg')]
for name,src in positives:
    w=out/name;w.mkdir();(w/'p.prg').write_bytes(src.read_bytes())
    sh([a.hbmk2,'p.prg','-gtstd','-quiet','-w0','-olo'],w,'oracle-linux-build',run_env=lenv);sh([a.hbmk2,'p.prg','-gtstd','-plat=win','-comp=mingw64','-quiet','-w0','-oow'],w,'oracle-win-build')
    ol=sh([w/'lo'],w,'oracle-linux-run');ow=sh(['wine',w/'ow.exe'],w,'oracle-win-run')
    sh([compiler,'p.prg','lin-int'],w,'lin-int-build');sh([compiler,'p.prg','lin-ext','--external-as'],w,'lin-ext-build')
    sh([compiler,'p.prg','win-int.exe','--target=windows'],w,'win-int-build');sh([compiler,'p.prg','win-ext.exe','--target=windows','--external-as'],w,'win-ext-build')
    res={}
    for who,cmd,ref in [('linux-internal',[w/'lin-int'],ol),('linux-external',[w/'lin-ext'],ol),('windows-internal',['wine',w/'win-int.exe'],ow),('windows-external',['wine',w/'win-ext.exe'],ow)]:
        ok=(w/(cmd[-1].name)).exists()
        if ok:
            r=sh(cmd,w,'run-'+who);ok=r.returncode==ref.returncode==0 and r.stdout==ref.stdout and r.stderr==ref.stderr
        add(name+'-'+who,'byte-identical-to-oracle',ok,stdout_sha256=hashlib.sha256(ref.stdout).hexdigest())
    add(name+'-oracle-sane','oracle-nonempty',ol.returncode==0 and len(ol.stdout)>0 and ow.stdout.replace(b'\r\n',b'\n')==ol.stdout)
# t415 must print exactly "\nH" (oracle) - guards the converted manifest row
add('t415-expected-bytes','manifest-row',(out/'t415'/'oracle-linux-run.stdout').read_bytes()==b'\nH' and (out/'t415'/'oracle-win-run.stdout').read_bytes()==b'\r\nH')
msgs={'dyn-hash-in-mixed-array':b'array elements must be integers','dyn-hash-from-hash-value':b'hash values are tagged scalars','dyn-hash-from-call':b'type mismatch in assignment','hb_isevalitem-block':b'unknown function `hb_isevalitem`','hb_isblock-symbol':b'`ValType` over this expression is not measured','logical-literal':b'`ValType` over this expression is not measured','float-literal':b'`ValType` over this expression is not measured','block-literal':b'`ValType` over this expression is not measured','two-arguments':b'unknown function `hb_ishash`','no-arguments':b'unknown function `hb_ishash`','hb_hash-with-arguments':b'unknown function `hb_hash`'}
for src in sorted((gate/'neg').glob('*.prg')):
    w=out/('neg-'+src.stem);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes())
    ok=True
    for tgt in ['linux','windows']:
        r=sh([compiler,'p.prg','x-'+tgt,'--target='+tgt],w,'build-'+tgt);ok=ok and r.returncode==1 and msgs[src.stem] in r.stderr and not (w/('x-'+tgt)).exists()
    add('neg-'+src.stem,'named-rejection-both-targets',ok)
ident=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),scope='Linux ELF and Windows PE under Wine; external Harbour 3.2.1dev oracle (not Harbour 4)',total=len(rows),passed=sum(r['pass_'] for r in rows),rows=rows)
(out/'results.json').write_text(json.dumps(ident,indent=2));sys.exit(0 if ident['total']==ident['passed'] else 1)
