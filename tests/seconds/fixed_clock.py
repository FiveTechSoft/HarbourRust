#!/usr/bin/env python3
"""Seconds() and Date(): deterministic fixed-clock checks of the Linux and Windows helpers, and the Linux zone reader.
The helper assembly (SECONDS_LINUX, DATE_TODAY_LINUX, TZ_LINUX, SECONDS_WINDOWS) is read from src/hbc.rs and linked into
small drivers. Only the clock source is replaced: the Linux `syscall` of the Seconds/Date helper (clock_gettime, time)
becomes a call to a fake that returns a chosen instant; the real TZ_LINUX (hbc_tz_off) is linked unchanged and reads the
real environment and files. The Windows `call GetLocalTime` resolves to a driver function that fills a chosen SYSTEMTIME.
Linux cases (30 instants, incl. 1970-01-01 and the first hours after it, 1 s before and exactly at the DST changes of
Madrid and New York, a day change, a leap day, the transitions of a crafted zone) run under 36 environments: named zones
with DST, negative and +14 offsets, ':Zone', an absolute path, TZ unset (expected from /etc/localtime), empty TZ, POSIX
string without a file, "..", unknown zone, a FIFO, /dev/zero, /dev/random, crafted TZif files (valid, offset at and beyond
+-26 h, INT32_MIN, transitions out of order or equal, type index out of range, no types, truncated, v1 only, bad second
header, exactly 65536 and 65537 bytes), an environment of about 50 KB and of about 70 KB, and a read that returns at most
100 bytes per call. Expected values come from Python (zoneinfo for named zones, a small reference reader for the
crafted files), never from the code under test. Mutants must give a built, run, functionally WRONG answer (a build
failure or a crash does not count as caught; the one mutant whose failure mode is a hang says so).
Seconds in the real-ELF rows is compared with a Python window (the oracle's Seconds changes every run); Date is compared
with the oracle (Harbour 3.2.1dev r2610242111, external, not Harbour 4) and with Python. A threaded program calls both
from four threads under a non-UTC zone.
Mach-O: not executed (the Darwin helper is whole seconds only and is compiled by the manifest check).
Original MIT."""
import argparse,pathlib,subprocess,json,os,re,time,struct,datetime,zoneinfo
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['--source','--output']:ap.add_argument(k,required=True)
ap.add_argument('--compiler');ap.add_argument('--hbmk2');ap.add_argument('--wine',default='wine')
a=ap.parse_args();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all',LC_ALL='C.UTF-8')
env.pop('TZ',None)
src=P(a.source).read_text()
def const(name):
    m=re.search(r'const '+name+r': &str = r#"(.*?)"#;',src,re.S);assert m,name;return m.group(1)
LIN=const('SECONDS_LINUX');WIN=const('SECONDS_WINDOWS');TZB=const('TZ_LINUX');DTL=const('DATE_TODAY_LINUX');DPH=const('DATE_PORT_HELPERS')
rows=[]
def add(n,ok,note=''):
    rows.append(dict(test=n,pass_=bool(ok),note=note));print('PASS' if ok else 'FAIL',n,note,flush=True)
def sh(cmd,w,label,e=None,t=60):
    try:
        p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=env if e is None else e,stdin=subprocess.DEVNULL,timeout=t)
    except subprocess.TimeoutExpired:
        (w/(label+'.rc')).write_bytes(b'timeout');return None
    for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
    return p
def utc(y,m,d,h=0,mi=0,se=0):return int(datetime.datetime(y,m,d,h,mi,se,tzinfo=datetime.timezone.utc).timestamp())
BASE=1699920000  # 2023-11-14 00:00:00 UTC
assert BASE%86400==0
LCASES=[(BASE,0),(BASE+45000,123000000),(BASE+45000,123999999),(BASE+45000,124000000),(BASE+45000,125000000),(BASE+45001,0),
        (BASE+86399,999000000),(BASE+86399,999999999),(BASE+86400,0),(BASE+86400+1,1000000)]
DST=[utc(2026,3,29,0,59,59),utc(2026,3,29,1,0,0),utc(2026,10,25,0,59,59),utc(2026,10,25,1,0,0),utc(2026,3,8,6,59,59),utc(2026,3,8,7,0,0),
     utc(2026,7,1,12,0,0),utc(2026,12,31,23,30,0),utc(2024,2,29,23,59,59)]
EARLY=[0,1,3600,86399,86400,31536000]              # 1970: local seconds go negative west of Greenwich
CRAFT=[999,1000,1500,1999,2000]                    # around the transitions of the crafted two-transition zone
LCASES=LCASES+[(t,0) for t in DST+EARLY+CRAFT]
WCASES=[(0,0,0,0),(12,30,0,123),(12,30,0,124),(12,30,0,125),(12,30,1,0),(23,59,59,999),(0,0,0,0),(5,30,0,250)]
def wexp(c):h,m,s,ms=c;return float(h*3600+m*60+s)+ms/1000.0
# ---- crafted TZif files and their expected offsets (independent reference rule) ----
zd=out/'zones';zd.mkdir()
def tzif(types,trans=(),idx=None,version=b'2',h2magic=b'TZif',pad=0,cut=0):
    n=len(trans);t=len(types)
    idx=list(range(1,n+1)) if idx is None else idx
    body=b''.join(struct.pack('>q',x) for x in trans)+bytes(idx)+b''.join(struct.pack('>iBB',o,0,0) for o in types)+b'\0'
    h1=b'TZif'+version+b'\0'*15+struct.pack('>6I',0,0,0,0,0,0)
    h2=h2magic+b'2'+b'\0'*15+struct.pack('>6I',0,0,0,n,t,1)
    f=h1+h2+body+b'\n\n'
    f=f+b'\0'*pad
    return f[:len(f)-cut] if cut else f
def wf(name,data):p=zd/name;p.write_bytes(data);return str(p)
def ref_off(types,trans):
    def f(t):
        k=-1
        for i,x in enumerate(trans):
            if x<=t:k=i
        ti=0 if k<0 else (k+1)
        return types[ti]
    return f
SZ=len(tzif([50400]))
Z=[]   # (label, tz value or None=unset, extra env, expected-offset function)
def named(tz):
    z=tz.lstrip(':');zi=zoneinfo.ZoneInfo(z)
    return lambda t:int(datetime.datetime.fromtimestamp(t,zi).utcoffset().total_seconds())
zero=lambda t:0
for tz in ['UTC','Europe/Madrid','America/New_York','Asia/Kolkata','Pacific/Auckland','Pacific/Kiritimati','Pacific/Pago_Pago',':Europe/Madrid']:
    Z.append((tz,tz,{},named(tz)))
Z.append(('abs-path','/usr/share/zoneinfo/Asia/Kolkata',{},named('Asia/Kolkata')))
try:
    lz=zoneinfo.ZoneInfo.from_file(open('/etc/localtime','rb'));lo=lambda t:int(datetime.datetime.fromtimestamp(t,lz).utcoffset().total_seconds())
except OSError:lo=zero
Z.append(('unset',None,{},lo))
for lab,tz in [('empty',''),('posix-string','CET-1CEST'),('dotdot','../x'),('unknown','Nope/Zone')]:Z.append((lab,tz,{},zero))
fifo=zd/'fifo'
os.mkfifo(fifo)
for lab,tz in [('fifo',str(fifo)),('dev-zero','/dev/zero'),('dev-random','/dev/random')]:Z.append((lab,tz,{},zero))
Z.append(('crafted-valid-plus14h',wf('v14',tzif([50400])),{},lambda t:50400))
Z.append(('crafted-valid-plus26h',wf('v26',tzif([93600])),{},lambda t:93600))
Z.append(('crafted-valid-minus26h',wf('vm26',tzif([-93600])),{},lambda t:-93600))
for lab,off in [('crafted-plus26h-and-1s',93601),('crafted-minus26h-and-1s',-93601),('crafted-INT32_MIN',-2**31),('crafted-INT32_MAX',2**31-1)]:Z.append((lab,wf(lab,tzif([off])),{},zero))
two=([3600,7200,10800],[1000,2000])
Z.append(('crafted-two-transitions',wf('two',tzif(two[0],two[1])),{},ref_off(*two)))
Z.append(('crafted-unordered',wf('unord',tzif([3600,7200,10800],[2000,1000])),{},zero))
Z.append(('crafted-equal-transitions',wf('eq',tzif([3600,7200,10800],[1000,1000])),{},zero))
Z.append(('crafted-type-index-out-of-range',wf('badidx',tzif([3600],[1000],idx=[5])),{},zero))
Z.append(('crafted-no-types',wf('notypes',tzif([])),{},zero))
Z.append(('crafted-truncated',wf('trunc',tzif([50400],cut=12)),{},zero))
Z.append(('crafted-v1-only',wf('v1',tzif([50400],version=b'\0')),{},zero))
Z.append(('crafted-bad-second-header',wf('hdr2',tzif([50400],h2magic=b'TZxx')),{},zero))
Z.append(('crafted-exactly-65536-bytes',wf('f65536',tzif([50400],pad=65536-SZ)),{},lambda t:50400))
Z.append(('crafted-65537-bytes',wf('f65537',tzif([50400],pad=65537-SZ)),{},zero))
Z.append(('env-50KB',  'Europe/Madrid',{'BIGENV':'a'*50000},named('Europe/Madrid')))
Z.append(('env-70KB',  'Europe/Madrid',{'BIGENV':'a'*70000},zero))
def zenv(tz,extra):
    e=dict(env);e.update(extra)
    if tz is not None:e['TZ']=tz
    return e
def pk(t,off):d=datetime.datetime.fromtimestamp(t+off,datetime.timezone.utc);return d.year*10000+d.month*100+d.day
def lexp(c,off):s,n=c;return float((s+off(s))%86400)+(n//1000000)/1000.0
# ---- drivers ----
LDRV='''#include <stdio.h>
long fake_sec,fake_nsec;
double hbc_seconds(void);
__asm__(".text\\n.globl fake_syscall\\nfake_syscall:\\n mov fake_sec(%rip),%rax\\n mov %rax,(%rsi)\\n mov fake_nsec(%rip),%rax\\n mov %rax,8(%rsi)\\n xor %eax,%eax\\n ret\\n");
int main(void){long c[][2]={'''+','.join('{%dL,%dL}'%x for x in LCASES)+'''};
for(unsigned i=0;i<sizeof c/sizeof c[0];i++){fake_sec=c[i][0];fake_nsec=c[i][1];printf("%.17g\\n",hbc_seconds());}return 0;}
'''
DDRV='''#include <stdio.h>
long fake_sec;
unsigned long hbc_date_today(void);
__asm__(".text\\n.globl fake_syscall\\nfake_syscall:\\n mov fake_sec(%rip),%rax\\n ret\\n");
int main(void){long c[]={'''+','.join('%dL'%x[0] for x in LCASES)+'''};
for(unsigned i=0;i<sizeof c/sizeof c[0];i++){fake_sec=c[i];printf("%lu\\n",hbc_date_today());}return 0;}
'''
# a read(2) that returns at most 100 bytes per call: the zone reader must loop to EOF
SHORT='''.text
short_syscall:
 test %eax,%eax
 jne 1f
 cmp $100,%rdx
 jbe 1f
 mov $100,%edx
1: syscall
 ret
'''
def build(tag,kind,asm,tzb):
    w=out/tag;w.mkdir(exist_ok=True)
    if (w/'t').exists():return w
    tzt=tzb.replace('syscall','call short_syscall') if tag.endswith('shortread') else tzb
    if kind=='sec':
        (w/'h.s').write_text('.globl hbc_seconds\n'+asm.replace('syscall','call fake_syscall')+tzt+(SHORT if 'short_syscall' in tzt else ''));(w/'d.c').write_text(LDRV)
        c=sh(['gcc','-O0','-no-pie','-o','t','d.c','h.s'],w,'build')
    else:
        (w/'h.s').write_text('.globl hbc_date_today\n'+asm.replace('syscall','call fake_syscall')+DPH+tzt+(SHORT if 'short_syscall' in tzt else ''));(w/'d.c').write_text(DDRV)
        c=sh(['gcc','-O0','-no-pie','-Wl,--unresolved-symbols=ignore-all','-o','t','d.c','h.s'],w,'build')  # DATE_PORT_HELPERS render/print helpers are not called here
    return w if c is not None and c.returncode==0 else None
def run_case(w,kind,z):
    lab,tz,extra,off=z
    r=sh([w/'t'],w,'run-'+re.sub(r'\W','_',lab),zenv(tz,extra),t=15)
    if r is None or r.returncode!=0:return None
    got=r.stdout.decode().split()
    return [float(x) for x in got] if kind=='sec' else [int(x) for x in got]
def check(tag,kind,asm,tzb,zs=None):
    """-> (built, results {label: ok/None/False})"""
    w=build(tag,kind,asm,tzb)
    if w is None:return False,{}
    res={}
    for z in (zs or Z):
        got=run_case(w,kind,z)
        exp=[lexp(c,z[3]) for c in LCASES] if kind=='sec' else [pk(c[0],z[3](c[0])) for c in LCASES]
        res[z[0]]=None if got is None else (got==exp)
    return True,res
def good(tag,kind,asm=LIN,tzb=TZB):
    built,res=check(tag,kind,asm if kind=='sec' else DTL,tzb)
    bad=[k for k,v in res.items() if v is not True]
    add(tag,built and not bad,'%d instants x %d environments; failing: %r'%(len(LCASES),len(Z),bad))
def mutant(name,tag,kind,asm=None,tzb=None,hang_ok=False,only=None):
    zs=[z for z in Z if only is None or z[0] in only]
    built,res=check(tag,kind,asm or (LIN if kind=='sec' else DTL),tzb or TZB,zs)
    wrong=[k for k,v in res.items() if v is False]
    crash=[k for k,v in res.items() if v is None]
    ok=built and (len(wrong)>0 or (hang_ok and len(crash)>0))
    add(name,ok,'built=%s; functionally wrong in %d environments %r; crash/hang in %d %r%s'%(built,len(wrong),wrong[:6],len(crash),crash[:4],' (hang counts: its failure mode)' if hang_ok else ''))
good('linux-seconds-fixed','sec')
good('linux-seconds-fixed-shortread','sec')
good('linux-date-fixed','date')
good('linux-date-fixed-shortread','date')
# ---- Windows ----
WDRV='''#include <stdio.h>
static unsigned short st[8];
void GetLocalTime(unsigned short*p){for(int i=0;i<8;i++)p[i]=st[i];}
double hbc_seconds(void);
int main(void){unsigned c[][4]={'''+','.join('{%d,%d,%d,%d}'%x for x in WCASES)+'''};
for(unsigned i=0;i<sizeof c/sizeof c[0];i++){st[4]=c[i][0];st[5]=c[i][1];st[6]=c[i][2];st[7]=c[i][3];printf("%.17g\\n",hbc_seconds());}return 0;}
'''
def run_win(tag,asm):
    w=out/tag;w.mkdir();(w/'h.s').write_text('.globl hbc_seconds\n'+asm);(w/'d.c').write_text(WDRV)
    c=sh(['x86_64-w64-mingw32-gcc','-O0','-o','t.exe','d.c','h.s'],w,'build')
    if c is None or c.returncode:return None
    r=sh([a.wine,w/'t.exe'],w,'run',env,t=120);return [float(x) for x in r.stdout.decode().replace('\r\n','\n').split()] if r is not None and r.returncode==0 else None
ww=[wexp(c) for c in WCASES]
got=run_win('windows-fixed',WIN);add('windows-fixed-clock',got==ww,'cases %d values %r'%(len(ww),got))
mw=WIN.replace('divsd %xmm2, %xmm1','mulsd %xmm2, %xmm1',1);assert mw!=WIN
g=run_win('mutant-windows-ms-scale',mw);add('mutant-windows-wrong-answer',g is not None and g!=ww,'built and ran; values differ from expected')
# ---- mutants of the Linux code: each must build, run and answer wrongly ----
def rep(s,old,new):
    assert s.count(old)==1,old;return s.replace(old,new)
mutant('mutant-seconds-no-ms','mutant-seconds-no-ms','sec',asm=rep(LIN,'mov $1000000, %ecx','mov $1000000000, %ecx'))
mutant('mutant-seconds-no-offset','mutant-seconds-no-offset','sec',asm=rep(LIN,'    add %rax, -16(%rbp)\n',''))
mutant('mutant-seconds-negative-not-wrapped','mutant-seconds-neg','sec',asm=rep(LIN,'    jge .Lseconds_pos\n','    jmp .Lseconds_pos\n'))
mutant('mutant-date-no-offset','mutant-date-no-offset','date',asm=rep(DTL,'    add -24(%rbp), %rax\n','    mov -24(%rbp), %rax\n'))
mutant('mutant-date-negative-not-shifted','mutant-date-neg','date',asm=rep(DTL,'    movq $400, -32(%rbp)\n','    movq $0, -32(%rbp)\n'))
mutant('mutant-tz-variable-ignored','mutant-tz-ignored','sec',tzb=rep(TZB,'cmpb $84, (%rsi)','cmpb $85, (%rsi)'))
mutant('mutant-tz-transition-boundary','mutant-tz-boundary','sec',tzb=rep(TZB,'    cmp %r13, %rax\n    jg .Ltz_next\n','    cmp %r13, %rax\n    jge .Ltz_next\n'))
mutant('mutant-tz-order-not-checked','mutant-tz-order','sec',tzb=rep(TZB,'    jge .Ltz_chk\n','    jmp .Ltz_chk2\n').replace('.Ltz_chk:\n','.Ltz_chk2:\n    mov %rax, %r10\n    jmp .Ltz_ord\n.Ltz_chk:\n',1))
mutant('mutant-tz-offset-range-not-checked','mutant-tz-range','sec',tzb=rep(rep(TZB,'    cmp %rcx, %rax\n    jg .Ltz_utc\n    neg %rcx\n    cmp %rcx, %rax\n    jl .Ltz_utc\n','    nop\n'),'    mov $93600, %rcx\n','    nop\n'))
mutant('mutant-tz-type-index-not-checked','mutant-tz-typeidx','sec',tzb=rep(TZB,'    cmp -131304(%rbp), %rax\n    jae .Ltz_utc\n    inc %rcx\n','    cmp -131304(%rbp), %rax\n    nop\n    inc %rcx\n'))
mutant('mutant-tz-size-limit-not-checked','mutant-tz-size','sec',tzb=rep(TZB,'    sub %r14, %rdx\n    jz .Ltz_sclose\n','    sub %r14, %rdx\n    jz .Ltz_sok\n'),only=['crafted-65537-bytes','env-70KB'])
mutant('mutant-tz-single-read','mutant-tz-single-read-shortread','sec',tzb=rep(TZB,'    add %rax, %r14\n    jmp .Ltz_sread\n','    add %rax, %r14\n    jmp .Ltz_sdone\n'),only=['Europe/Madrid','America/New_York','abs-path'])
mutant('mutant-tz-open-blocking','mutant-tz-blocking','sec',tzb=rep(TZB,'    mov $0x80800, %esi\n','    mov $0x80000, %esi\n'),hang_ok=True,only=['fifo'])
# ---- real ELF, Python window for Seconds, oracle and Python for Date, threads ----
if a.compiler:
    cc=str(P(a.compiler).resolve());w=out/'real-elf-tz';w.mkdir()
    (w/'p.prg').write_text('FUNCTION Main()\n ? Seconds()\n ? Date()\nRETURN NIL\n')
    c=sh([cc,'p.prg','x'],w,'build',env)
    o=out/'real-oracle-tz';o.mkdir();(o/'p.prg').write_text((w/'p.prg').read_text())
    ob=sh([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(o/'oracle'),o/'p.prg'],o,'build',env) if a.hbmk2 else None
    for z in Z:
        lab,tz,extra,off=z;tag=re.sub(r'\W','_',lab);e=zenv(tz,extra)
        t0=time.time();r=sh([w/'x'],w,'run-'+tag,e,t=15);t1=time.time()
        if r is None or r.returncode!=0:add('elf-'+tag,False,'crash or hang');continue
        ls=r.stdout.decode().split()
        try:v=float(ls[0]);dt=ls[1]
        except Exception:v=-1;dt=''
        lo=(int(t0)+off(int(t0)))%86400
        okv=0<=v<86400 and (v-lo)%86400<=(t1-t0)+2
        okd=any(dt=='%02d/%02d/%02d'%(d//100%100,d%100,d//10000%100) for d in (pk(int(t0),off(int(t0))),pk(int(t1)+1,off(int(t1)+1))))
        ex=''
        if ob is not None and ob.returncode==0 and lab.split('-')[0] in ('UTC','Europe','America','Asia','Pacific',':Europe','abs','unset','empty','unknown','dotdot'):
            ro=sh([o/'oracle'],o,'run-'+tag,e,t=15);ol=ro.stdout.decode().split() if ro is not None else []
            okd=okd and ol[1:2]==[dt];ex=' Date: oracle %s ours %s'%(ol[1:2],dt)
        add('elf-'+tag,c is not None and c.returncode==0 and okv and okd,'Seconds %r vs Python window start %d; Date %r%s'%(v,lo,dt,ex))
    # threads: four workers call Seconds() and Date() 2000 times under Asia/Kolkata (a 128 KiB frame per call on each 1 MiB thread stack)
    (w/'th.prg').write_text('''FUNCTION Worker( nId )
 LOCAL i, bad := 0, s, d0 := Date()
 FOR i := 1 TO 2000
  s := Seconds()
  IF Date() != d0 .OR. s < 0 .OR. s >= 86400
   bad := bad + 1
  ENDIF
 NEXT
RETURN bad
FUNCTION Main()
 LOCAL t1, t2, t3, t4, r1, r2, r3, r4
 t1 := hb_threadStart( @Worker(), 1 )
 t2 := hb_threadStart( @Worker(), 2 )
 t3 := hb_threadStart( @Worker(), 3 )
 t4 := hb_threadStart( @Worker(), 4 )
 hb_threadJoin( t1, @r1 )
 hb_threadJoin( t2, @r2 )
 hb_threadJoin( t3, @r3 )
 hb_threadJoin( t4, @r4 )
 ? r1, r2, r3, r4
RETURN NIL
''')
    c=sh([cc,'th.prg','th'],w,'build-th',env)
    r=sh([w/'th'],w,'run-th',zenv('Asia/Kolkata',{}),t=60) if c is not None and c.returncode==0 else None
    add('elf-threads-4x2000',r is not None and r.returncode==0 and r.stdout.decode().split()==['0','0','0','0'],'output %r'%(r.stdout.decode() if r is not None else None))
res=dict(total=len(rows),passed=sum(r['pass_'] for r in rows),rows=rows)
(out/'results.json').write_text(json.dumps(res,indent=1));print('%d/%d'%(res['passed'],res['total']));raise SystemExit(0 if res['passed']==res['total'] else 1)
