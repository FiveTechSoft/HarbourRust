#!/usr/bin/env python3
"""INKEY on Windows PE under Wine vs the external Harbour 3.2.1dev (mingw, -gtstd) oracle.
Values must be identical (stdout bytes, rc). Timing is compared as delta over a no-INKEY baseline
of the same program shape and stdin kind, with a persistent wineserver (no cold-start noise)."""
import argparse,pathlib,subprocess,json,hashlib,os,shutil,sys,time,threading
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['--compiler','--hbmk2','--tree','--output','--mingw-lib']:ap.add_argument(k,required=True)
a=ap.parse_args();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);compiler=str(P(a.compiler).resolve())
env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],HB_CCPATH='/tmp/toolchain/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',WINEDEBUG='-all',HBC_MINGW_LIB=a.mingw_lib,LC_ALL='C.UTF-8')
subprocess.run(['wineserver','-p'],env=env)
rows=[]
def add(name,kind,ok,**kw):
    rows.append(dict(test=name,kind=kind,pass_=bool(ok),**kw));print('PASS' if ok else 'FAIL',name,flush=True)
def sh(cmd,w,label,t=120):
    p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=env,stdin=subprocess.DEVNULL,timeout=t)
    for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
    return p
def run(exe,w,stdin,mode):
    """mode: ('file',bytes|None) | ('pipe',delay,payload,close). returns rc,stdout,elapsed"""
    t=time.time()
    if mode[0]=='file':
        f=w/'stdin.bin'
        if mode[1] is None:src=open('/dev/null','rb')
        else:f.write_bytes(mode[1]);src=open(f,'rb')
        r=subprocess.run(['wine',exe],cwd=w,stdin=src,capture_output=True,env=env,timeout=60);return r.returncode,r.stdout,time.time()-t,r.stderr
    _,delay,payload,close=mode
    p=subprocess.Popen(['wine',exe],cwd=w,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,env=env)
    time.sleep(delay)
    try:
        if payload:p.stdin.write(payload);p.stdin.flush()
        if close:p.stdin.close()
    except BrokenPipeError:pass  # the no-INKEY baseline exits before the late write
    try:p.wait(timeout=30)
    except subprocess.TimeoutExpired:p.kill()
    o=p.stdout.read();p.stdout.close();e=p.stderr.read();p.stderr.close()
    if not close:
        try:p.stdin.close()
        except BrokenPipeError:pass
    return p.returncode,o,time.time()-t,e
def oracle_src(body):return 'function main()\nlocal k1,k2\n'+body+'\n?? "K=",k1,k2\nreturn nil\n'
# (name, program body, stdin mode, expected waiting seconds (None = no waiting), data expected)
Q='quiet-pipe'
cases=[
 ('noarg-devnull','k1:=inkey()',('file',None),None),
 ('noarg-Z','k1:=inkey()',('file',b'Z'),None),
 ('t1-devnull','k1:=inkey(1)',('file',None),1.0),
 ('t1-empty','k1:=inkey(1)',('file',b''),1.0),
 ('t3-Z-no-wait','k1:=inkey(3)',('file',b'Z'),None),
 ('two-AB','k1:=inkey(0.2)\nk2:=inkey(0.2)',('file',b'AB'),None),
 ('crlf','k1:=inkey(0.2)\nk2:=inkey(0.2)',('file',b'\r\n'),None),
 ('ff00','k1:=inkey(0.2)\nk2:=inkey(0.2)',('file',b'\xff\x00'),None),
 ('t0.2-empty','k1:=inkey(0.2)',('file',b''),0.2),
 ('t0.01-empty','k1:=inkey(0.01)',('file',b''),0.01),
 ('pipe-byte-late','k1:=inkey(3)',('pipe',0.5,b'Q',True),None),
 ('pipe-closed-t1','k1:=inkey(1)',('pipe',0.2,None,True),1.0),
 ('pipe-two','k1:=inkey(1)\nk2:=inkey(1)',('pipe',0.0,b'XY',True),None),
 ('pipe-closed-noarg','k1:=inkey()',('pipe',0.2,None,True),None),
]
def do_case(name,body,mode,wait,w):
    w.mkdir()
    (w/'o.prg').write_text(oracle_src(body));(w/'p.prg').write_text(oracle_src(body))
    (w/'base.prg').write_text('function main()\nlocal k1,k2\n?? "K=",k1,k2\nreturn nil\n')
    sh([a.hbmk2,'o.prg','-gtstd','-plat=win','-comp=mingw64','-quiet','-w0','-oo'],w,'oracle-build')
    sh([compiler,'p.prg','internal.exe','--target=windows'],w,'internal-build');sh([compiler,'p.prg','external.exe','--target=windows','--external-as'],w,'external-build')
    sh([compiler,'base.prg','base.exe','--target=windows'],w,'base-build')
    # pipe closing mode with delay None means: communicate immediately; quiet pipe: closes after the program ends via communicate
    res={}
    for who,exe in [('base0','base.exe'),('oracle','o.exe'),('internal','internal.exe'),('external','external.exe'),('base','base.exe')]:
        if not (w/exe).exists():res[who]=None;continue
        res[who]=run(str(w/exe),w,None,mode)
    # baseline = the faster of two no-INKEY runs of the same stdin shape (before and after), so a slow wine start cannot shrink a delta
    base=min(res['base'][2],res['base0'][2]);ok=True;info={}
    for who in ['oracle','internal','external']:
        if res[who] is None:ok=False;continue
        info[who]=dict(rc=res[who][0],stdout=res[who][1].decode('latin-1'),stderr=res[who][3].decode('latin-1'),delta=round(res[who][2]-base,2))
    # VALUES: rc, stdout and an empty stderr must match the oracle exactly. Any divergence fails, never retried.
    values_ok=ok and info['oracle']['rc']==0 and all(info[x]['rc']==info['oracle']['rc'] and info[x]['stdout']==info['oracle']['stdout'] and info[x]['stderr']==info['oracle']['stderr']=='' for x in ['internal','external'])
    # TIMING (load sensitive under Wine): only this part may be retried, explicitly and recorded.
    timing_ok=True
    if values_ok and wait is not None:
        timing_ok=all(info[x]['delta']>=wait-0.05 and abs(info[x]['delta']-info['oracle']['delta'])<0.8 for x in ['internal','external'])
    if values_ok and wait is None and 'late' not in name:
        timing_ok=all(info[x]['delta']<0.8 for x in ['internal','external'])
    if values_ok and name=='pipe-byte-late':timing_ok=all(info[x]['delta']<1.0 for x in ['internal','external']) and all('81' in info[x]['stdout'] for x in ['internal','external'])
    return values_ok,timing_ok,info

for name,body,mode,wait in cases:
    values_ok,timing_ok,info=do_case(name,body,mode,wait,out/name)
    attempts=1
    if values_ok and not timing_ok:  # explicit timing-only retry in a fresh directory; the first attempt is kept
        first=info;values_ok,timing_ok,info=do_case(name,body,mode,wait,out/(name+'-retry'));attempts=2;info=dict(info,first_attempt=first)
    add(name,'oracle-values-and-timing',values_ok and timing_ok,values_ok=values_ok,timing_ok=timing_ok,detail=info,attempts=attempts,timing_retry=attempts==2)
# Win64 ABI stack-map proof: every API call inside hbc_inkey goes through a stub that, AFTER the real call, overwrites the whole
# outgoing area (32-byte shadow space + stack args 5/6 = rsp+0..47) with junk, as a legal callee may. A local living in that
# area (the pre-fix layout) is destroyed and the value/behaviour changes.
import re
APIS=['GetStdHandle','GetFileType','GetTickCount64','PeekNamedPipe','ReadFile','Sleep','GetLastError']
def abi_case(name,stdin_bytes,want):
    w=out/('abi-'+name);w.mkdir();(w/'p.prg').write_text(oracle_src('k1:=inkey(0.2)\nk2:=inkey(0.2)'))
    sh([compiler,'p.prg','p.s','--target=windows','--instrument'],w,'emit');t=(w/'p.s').read_text()
    i=t.index('hbc_inkey:');j=t.index('.Linkey_none:',i);j=t.index('ret\n',j)+4
    body=t[i:j]
    for api in APIS:body=re.sub(r'call '+api+r'\n','call stub_'+api+'\n',body)
    stubs=''.join('stub_%s:\n    pop %%r11\n    mov %%r11, stub_ret(%%rip)\n    call %s\n    movabs $0xdeadbeefdeadbeef, %%rcx\n    mov %%rcx, 0(%%rsp)\n    mov %%rcx, 8(%%rsp)\n    mov %%rcx, 16(%%rsp)\n    mov %%rcx, 24(%%rsp)\n    mov %%rcx, 32(%%rsp)\n    mov %%rcx, 40(%%rsp)\n    jmp *stub_ret(%%rip)\n'%(x,x) for x in APIS)
    t=t[:i]+body+t[j:]+'\n    .text\n'+stubs+'    .data\nstub_ret:\n    .quad 0\n'
    (w/'p.s').write_text('    .globl _start\n'+t)
    r1=sh(['x86_64-w64-mingw32-as','-o','p.o','p.s'],w,'as');r2=sh(['x86_64-w64-mingw32-ld','p.o','-o','p.exe','-e','_start','--subsystem','console','-L'+a.mingw_lib,'-lkernel32'],w,'ld')
    ok=r1.returncode==0 and r2.returncode==0 and (w/'p.exe').exists()
    got=None
    if ok:
        (w/'in.bin').write_bytes(stdin_bytes);r=subprocess.run(['wine',w/'p.exe'],cwd=w,stdin=open(w/'in.bin','rb'),capture_output=True,env=env,timeout=60);got=r.stdout.decode('latin-1')
        (w/'run.stdout').write_bytes(r.stdout);ok=r.returncode==0 and got.split()==want
    add('abi-'+name,'win64-outgoing-area-clobber',ok,stdout=got,expected=want)
abi_case('Z',b'Z',['K=','90','0'])
abi_case('AB',b'AB',['K=','65','66'])
abi_case('empty-eof',b'',['K=','0','0'])
# rejections: LLVM, runtime/zero timeouts stay rejected on the Windows target
Z=b'INKEY supports zero arguments or one numeric literal from 0.01 to 86400 seconds'
for tag,body,flags,msg in [('llvm','k:=inkey(1)',['--experimental-llvm'],b'INKEY supports ordinary Linux and Windows PE stdin only'),('zero','k:=inkey(0)',[],Z),('runtime','local t:=1\nk:=inkey(t)',[],Z),('two-args','k:=inkey(1,2)',[],b'mask and extra arguments')]:
    w=out/('reject-'+tag);w.mkdir();(w/'p.prg').write_text('function main()\nlocal k\n'+body+'\nreturn nil\n')
    r=sh([compiler,'p.prg','x.exe','--target=windows']+flags,w,'build')
    add('reject-'+tag,'named-rejection',r.returncode==1 and msg in r.stderr and not (w/'x.exe').exists(),expected_diagnostic=msg.decode(),stderr=r.stderr.decode()[:300])
ident=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),scope='Windows PE under Wine (not native Windows, no real console); external Harbour3.2.1dev mingw oracle',total=len(rows),passed=sum(r['pass_'] for r in rows),rows=rows)
(out/'results.json').write_text(json.dumps(ident,indent=2));sys.exit(0 if ident['total']==ident['passed'] else 1)
