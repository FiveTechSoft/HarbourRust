#!/usr/bin/env python3
"""DIRMAKE Windows PE: external Harbour+hbct (mingw) oracle under Wine, byte/tree compare,
live memory balance with mutation control, LLVM rejection."""
import argparse,pathlib,subprocess,json,hashlib,os,shutil,sys
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['--compiler','--hbmk2','--hbct-win','--tree','--output','--mingw-lib']:ap.add_argument(k,required=True)
a=ap.parse_args();gate=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);compiler=str(P(a.compiler).resolve())
base=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],HB_CCPATH='/tmp/toolchain/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',WINEDEBUG='-all',HBC_MINGW_LIB=a.mingw_lib)
rows=[]
def raw(cmd,w,label,env,t=90,logdir=None):
    p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=env,stdin=subprocess.DEVNULL,timeout=t)
    for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:((logdir or w)/(label+'.'+k)).write_bytes(v)
    return p
def add(name,kind,ok,**kw):
    rows.append(dict(test=name,kind=kind,pass_=bool(ok),**kw));print('PASS' if ok else 'FAIL',name,flush=True)
def tree(w):return sorted(str(p.relative_to(w))+('/' if p.is_dir() else '') for p in w.rglob('*'))
def fs(w):shutil.rmtree(w,ignore_errors=True);w.mkdir();(w/'plainfile').write_text('x');(w/'parent').mkdir()
def oracle(s):
    lines=s.splitlines();start=next(i for i,l in enumerate(lines) if l.lower().startswith('function main()'))+1
    while start<len(lines) and lines[start].strip().lower().startswith('local '):start+=1
    lines.insert(start,'ErrorBlock({|err| Break(err)})');s='\n'.join(lines)+'\n'
    return s.replace('try\n','begin sequence\n').replace('catch e\n','recover using e\n').replace('\nend\n','\nend sequence\n')
tmp=out/'oracle-lib';tmp.mkdir();shutil.copy(a.hbct_win,tmp/'libhbctw.a')
for loc in ['C.UTF-8','C']:
    env=dict(base,LC_ALL=loc)
    for src in sorted((gate/'programs').glob('*.prg')):
        w=out/(src.stem+'-'+loc);w.mkdir();shutil.copy(src,w/'p.prg');(w/'o.prg').write_text(oracle(src.read_text()))
        b=raw([a.hbmk2,'o.prg','-L'+str(tmp),'-lhbctw','-gtstd','-plat=win','-comp=mingw64','-quiet','-w0','-oorcw'],w,'oracle-build',env)
        res={}
        builds={'internal':[compiler,'p.prg','internal.exe','--target=windows'],'external':[compiler,'p.prg','external.exe','--target=windows','--external-as']}
        for who,cmd in builds.items():raw(cmd,w,who+'-build',env)
        for who,exe in [('oracle','orcw.exe'),('internal','internal.exe'),('external','external.exe')]:
            if not (w/exe).exists():res[who]=None;continue
            wd=w/('w-'+who);fs(wd);r=raw(['wine',w/exe],wd,'run-'+who,env,60,w);res[who]=(r.returncode,r.stdout,r.stderr,tree(wd))
        ok=res['oracle'] is not None and res['oracle'][0]==0 and res['internal']==res['oracle'] and res['external']==res['oracle']
        add(src.stem+'-'+loc,'byte-and-tree-oracle',ok)
# memory balance: patched asm, exit code 99 when allocs != frees at exit
GUARD='    mov hbc_mem_allocs(%rip), %rax\n    sub hbc_mem_frees(%rip), %rax\n    test %rax, %rax\n    jz .Lprobe_zero\n    mov $99, %ecx\n    call ExitProcess\n.Lprobe_zero:\n'
ANCHOR='    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n'
def mem(name,body,n,control=False,mutate=False):
    w=out/('mem-%s-%d%s%s'%(name,n,'-control' if control else '','-mutant' if mutate else ''));w.mkdir()
    prg='function main()\nlocal i,d,e,s := "mm"\nd := "dd"\nfor i := 1 to %d\n'%n+('if .f.\n' if control else '')+'try\n'+body+'\ncatch e\ne := NIL\nend\n'+('endif\n' if control else '')+'next\n? "ok"\nreturn nil\nfunction boom()\nbreak("boom")\nreturn "never"\n'
    (w/'p.prg').write_text(prg);env=dict(base,LC_ALL='C.UTF-8')
    r=raw([compiler,'p.prg','p.s','--target=windows','--instrument'],w,'emit',env)
    t=(w/'p.s').read_text();assert t.count(ANCHOR)==1
    if mutate:
        i=t.index('.Ldmw_free:');j=t.index('call hbc_freestr',i);t=t[:j]+'nop'+t[j+len('call hbc_freestr'):]
    (w/'p.s').write_text('    .globl _start\n'+t.replace(ANCHOR,ANCHOR+GUARD))
    assert raw(['x86_64-w64-mingw32-as','-o','p.o','p.s'],w,'as',env).returncode==0;assert raw(['x86_64-w64-mingw32-ld','p.o','-o','p.exe','-e','_start','--subsystem','console','-L'+a.mingw_lib,'-lkernel32'],w,'ld',env).returncode==0
    wd=w/'run';wd.mkdir();rr=raw(['wine',w/'p.exe'],wd,'run',env,60,w)
    return rr.returncode,rr.stdout
for name,body in [('string','DIRMAKE("d"+s)'),('dyn','DIRMAKE(d)'),('nonstring','DIRMAKE(7)'),('rhs-break','DIRMAKE(boom())'),('owned-call','DIRMAKE(s+d)')]:
    for n in [1,500,1000]:
        act=mem(name,body,n);ctl=mem(name,body,n,control=True)
        add('mem-%s-%d'%(name,n),'memory-control',act[0]==0 and ctl[0]==0 and b'ok' in act[1] and b'ok' in ctl[1],bound=0)
mut=mem('string','DIRMAKE("d"+s)',3,mutate=True)
add('mem-mutant-detected','guard-negative-control',mut[0]==99)

# stubbed limits (no GiB reserved): patched asm + balance guard
def stub(name,old,new,want,count=1):
    w=out/('stub-'+name);w.mkdir();env=dict(base,LC_ALL='C.UTF-8')
    (w/'p.prg').write_text('function main()\n? DIRMAKE("stubdir")\nreturn nil\n')
    raw([compiler,'p.prg','p.s','--target=windows','--instrument'],w,'emit',env)
    t=(w/'p.s').read_text();assert t.count(old)==count,(name,t.count(old));t=t.replace(old,new)
    assert t.count(ANCHOR)==1
    (w/'p.s').write_text('    .globl _start\n'+t.replace(ANCHOR,ANCHOR+GUARD))
    assert raw(['x86_64-w64-mingw32-as','-o','p.o','p.s'],w,'as',env).returncode==0;assert raw(['x86_64-w64-mingw32-ld','p.o','-o','p.exe','-e','_start','--subsystem','console','-L'+a.mingw_lib,'-lkernel32'],w,'ld',env).returncode==0
    wd=w/'run';wd.mkdir();rr=raw(['wine',w/'p.exe'],wd,'run',env,60,w)
    add('stub-'+name,'limit-stub',rr.returncode==0 and rr.stdout.decode().split()==[want] and not (wd/'stubdir').exists(),stdout=rr.stdout.decode(),rc=rr.returncode)
CALL='    mov %rdx, %rsi\n    call hbc_dirmake\n'
stub('len-2^32+1',CALL,'    movabs $0x100000001, %rsi\n    call hbc_dirmake\n','-206')
stub('len-int32-max',CALL,'    mov $0x7fffffff, %rsi\n    call hbc_dirmake\n','-206')
stub('mbtwc-fails','    call MultiByteToWideChar\n','    xor %eax, %eax\n','-3')
# LLVM stays rejected by name
for flags in [['--experimental-llvm'],['--experimental-llvm-no-trace']]:
    w=out/('llvm'+flags[0]);w.mkdir();(w/'p.prg').write_text('function main()\n? DIRMAKE("x")\nreturn nil\n')
    r=raw([compiler,'p.prg','x.exe','--target=windows']+flags,w,'build',base)
    add('reject'+flags[0],'named-rejection',r.returncode==1 and b'DIRMAKE supports ordinary Linux, Darwin and Windows PE only' in r.stderr and not (w/'x.exe').exists())
ident=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),scope='Windows PE under Wine (not native Windows); external Harbour3.2.1dev+hbct mingw oracle',total=len(rows),passed=sum(x['pass_'] for x in rows),rows=rows)
(out/'results.json').write_text(json.dumps(ident,indent=2));sys.exit(0 if ident['total']==ident['passed'] else 1)
