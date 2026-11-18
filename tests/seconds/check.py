#!/usr/bin/env python3
"""Seconds(): runtime checks. The value is time dependent, so each run is
bracketed by the host clock (local time of TZ=Asia/Kolkata for the Linux ELF, local time for the PE under
Wine) and the printed format is compared with the external oracle's profile
(width 10, two decimals). Mach-O targets are only compiled here (not run).
Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4)."""
import argparse,pathlib,subprocess,json,hashlib,os,re,time
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['--compiler','--hbmk2','--output']:ap.add_argument(k,required=True)
a=ap.parse_args();gate=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(P(a.compiler).resolve())
env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all',LC_ALL='C.UTF-8')
rows=[]
def add(n,ok,note=''):
    rows.append(dict(test=n,pass_=bool(ok),note=note));print('PASS' if ok else 'FAIL',n,note,flush=True)
def sh(cmd,w,label,e=None):
    p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=e or env,stdin=subprocess.DEVNULL,timeout=120)
    for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
    return p
import zoneinfo,datetime
KTZ='Asia/Kolkata'  # non-UTC zone fixed for the ELF rows
def sec_utc(t):l=datetime.datetime.fromtimestamp(int(t),zoneinfo.ZoneInfo(KTZ));return l.hour*3600+l.minute*60+l.second
def sec_loc(t):l=time.localtime(t);return l.tm_hour*3600+l.tm_min*60+l.tm_sec
def parse(stdout):
    ls=stdout.decode().replace('\r\n','\n').split('\n')
    if ls and ls[-1]=='':ls.pop()
    if ls and ls[0]=='':ls.pop(0)  # QOut starts with a newline
    return ls
FMT=re.compile(r'^ *\d+\.\d\d$')
WIDTH=[None]  # set from the oracle's own output
def structure(ls):return len(ls)==4 and all(FMT.match(l) and (WIDTH[0] is None or len(l)==WIDTH[0]) for l in ls)
def check(name,ls,t0,t1,clock):
    if not structure(ls):return False,'structure %r'%ls
    v=[float(x) for x in ls]
    lo=clock(t0);span=(t1-t0)+2.0
    for x in v:
        if not (0<=x<86400 and (x-lo)%86400<=span+1):return False,'range %r window %s..+%.1f'%(v,lo,span)
    inc=all(((v[i+1]-v[i])%86400)<5 for i in range(3))
    return inc,'values %r'%v
# oracle: format profile only
w=out/'oracle';w.mkdir();(w/'p.prg').write_bytes((gate/'seconds.prg').read_bytes())
ob=sh([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'p.prg'],w,'build');orr=sh([w/'oracle'],w,'run')
ol=parse(orr.stdout);okf=ob.returncode==0 and orr.returncode==0 and structure(ol)
if okf:WIDTH[0]=len(ol[0])
add('oracle-format',okf,'printed width %s, 2 decimals'%WIDTH[0])
for who,flag,tgt in [('elf-internal',[],'linux'),('elf-external',['--external-as'],'linux'),('pe-internal',[],'windows')]:
    w=out/who;w.mkdir();(w/'p.prg').write_bytes((gate/'seconds.prg').read_bytes())
    ext='.exe' if tgt=='windows' else ''
    c=sh([cc,'p.prg','x'+ext,'--target='+tgt]+flag,w,'build')
    if c.returncode!=0:add(who,False,'build failed');continue
    cmd=['wine',w/'x.exe'] if tgt=='windows' else [w/'x']
    if tgt=='windows':sh(cmd,w,'warm')
    t0=time.time();r=sh(cmd,w,'run',None if tgt=='windows' else dict(env,TZ=KTZ));t1=time.time()
    ok=r.returncode==0 and r.stderr==b''
    good,note=check(who,parse(r.stdout),t0,t1,sec_loc if tgt=='windows' else sec_utc)
    add(who,ok and good,'rc=%d stderr=%d bytes %s'%(r.returncode,len(r.stderr),note))
for tg in ['macho','macho-arm64']:
    w=out/tg;w.mkdir();(w/'p.prg').write_bytes((gate/'seconds.prg').read_bytes())
    c=sh([cc,'p.prg','x','--target='+tg],w,'build')
    add(tg+'-compiles-only',c.returncode==0 and (w/'x').stat().st_size>0,'not executed')
ident=dict(compiler_sha256=hashlib.sha256(P(cc).read_bytes()).hexdigest(),total=len(rows),passed=sum(r['pass_'] for r in rows))
(out/'results.json').write_text(json.dumps(dict(ident=ident,rows=rows),indent=1))
print('%d/%d'%(ident['passed'],ident['total']));raise SystemExit(0 if ident['passed']==ident['total'] else 1)
