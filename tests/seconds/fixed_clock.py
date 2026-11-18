#!/usr/bin/env python3
"""Seconds(): deterministic fixed-clock checks of the Linux and Windows helpers.
The helper assembly (SECONDS_LINUX, SECONDS_WINDOWS) is read from src/hbc.rs and linked into a small
driver. Only the clock source is replaced: the Linux `syscall` (clock_gettime) becomes a call to a fake that
returns a chosen time, and the Windows `call GetLocalTime` resolves to a driver-defined function that fills
a chosen SYSTEMTIME. The conversion code under test is otherwise the text the compiler emits.
Cases: 00:00:00.000, 12:30:00.123, 23:59:59.999, sub-millisecond truncation, 1 ms steps, midnight wrap,
and a Windows local time that differs from UTC (05:30:00.250). With --compiler, the real ELF is also run
under TZ=Asia/Kolkata and TZ=America/New_York and must still print UTC seconds (Linux helper is UTC).
Mutants of each helper (no millisecond fraction, wrong divisor) must be caught by the same comparison.
Mach-O: not executed (the Darwin helper is whole seconds only and is compiled by the manifest check).
Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4)."""
import argparse,pathlib,subprocess,json,os,re,time
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['--source','--output']:ap.add_argument(k,required=True)
ap.add_argument('--compiler');ap.add_argument('--wine',default='wine')
a=ap.parse_args();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all',LC_ALL='C.UTF-8')
src=P(a.source).read_text()
def const(name):
    m=re.search(r'const '+name+r': &str = r#"(.*?)"#;',src,re.S);assert m,name;return m.group(1)
LIN=const('SECONDS_LINUX');WIN=const('SECONDS_WINDOWS')
rows=[]
def add(n,ok,note=''):
    rows.append(dict(test=n,pass_=bool(ok),note=note));print('PASS' if ok else 'FAIL',n,note,flush=True)
def sh(cmd,w,label,e=None,t=120):
    p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=e or env,stdin=subprocess.DEVNULL,timeout=t)
    for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
    return p
BASE=1699920000  # 2023-11-14 00:00:00 UTC
assert BASE%86400==0
LCASES=[(BASE,0),(BASE+45000,123000000),(BASE+45000,123999999),(BASE+45000,124000000),(BASE+45000,125000000),(BASE+45001,0),
        (BASE+86399,999000000),(BASE+86399,999999999),(BASE+86400,0),(BASE+86400+1,1000000)]
WCASES=[(0,0,0,0),(12,30,0,123),(12,30,0,124),(12,30,0,125),(12,30,1,0),(23,59,59,999),(0,0,0,0),(5,30,0,250)]
def lexp(c):s,n=c;return float(s%86400)+(n//1000000)/1000.0
def wexp(c):h,m,s,ms=c;return float(h*3600+m*60+s)+ms/1000.0
LDRV='''#include <stdio.h>
long fake_sec,fake_nsec;
double hbc_seconds(void);
__asm__(".text\\n.globl fake_syscall\\nfake_syscall:\\n mov fake_sec(%rip),%rax\\n mov %rax,(%rsi)\\n mov fake_nsec(%rip),%rax\\n mov %rax,8(%rsi)\\n xor %eax,%eax\\n ret\\n");
int main(void){long c[][2]={'''+','.join('{%dL,%dL}'%x for x in LCASES)+'''};
for(unsigned i=0;i<sizeof c/sizeof c[0];i++){fake_sec=c[i][0];fake_nsec=c[i][1];printf("%.17g\\n",hbc_seconds());}return 0;}
'''
WDRV='''#include <stdio.h>
static unsigned short st[8];
void GetLocalTime(unsigned short*p){for(int i=0;i<8;i++)p[i]=st[i];}
double hbc_seconds(void);
int main(void){unsigned c[][4]={'''+','.join('{%d,%d,%d,%d}'%x for x in WCASES)+'''};
for(unsigned i=0;i<sizeof c/sizeof c[0];i++){st[4]=c[i][0];st[5]=c[i][1];st[6]=c[i][2];st[7]=c[i][3];printf("%.17g\\n",hbc_seconds());}return 0;}
'''
def run_linux(tag,asm):
    w=out/tag;w.mkdir();(w/'h.s').write_text('.globl hbc_seconds\n'+asm.replace('syscall','call fake_syscall'));(w/'d.c').write_text(LDRV)
    c=sh(['gcc','-O0','-no-pie','-o','t','d.c','h.s'],w,'build')
    if c.returncode:return None
    r=sh([w/'t'],w,'run');return [float(x) for x in r.stdout.decode().split()] if r.returncode==0 else None
def run_win(tag,asm):
    w=out/tag;w.mkdir();(w/'h.s').write_text('.globl hbc_seconds\n'+asm);(w/'d.c').write_text(WDRV)
    c=sh(['x86_64-w64-mingw32-gcc','-O0','-o','t.exe','d.c','h.s'],w,'build')
    if c.returncode:return None
    r=sh([a.wine,w/'t.exe'],w,'run');return [float(x) for x in r.stdout.decode().replace('\r\n','\n').split()] if r.returncode==0 else None
lw=[lexp(c) for c in LCASES];ww=[wexp(c) for c in WCASES]
got=run_linux('linux-fixed',LIN);add('linux-fixed-clock',got==lw,'cases %d values %r'%(len(lw),got))
got=run_win('windows-fixed',WIN);add('windows-fixed-clock',got==ww,'cases %d values %r'%(len(ww),got))
ml=LIN.replace('mov $1000000, %ecx','mov $1000000000, %ecx',1);assert ml!=LIN
g=run_linux('mutant-linux-no-ms',ml);add('mutant-linux-caught',g is not None and g!=lw,'mutant values differ from expected')
mw=WIN.replace('divsd %xmm2, %xmm1','mulsd %xmm2, %xmm1',1);assert mw!=WIN
g=run_win('mutant-windows-ms-scale',mw);add('mutant-windows-caught',g is not None and g!=ww,'mutant values differ from expected')
if a.compiler:
    cc=str(P(a.compiler).resolve());w=out/'real-elf-tz';w.mkdir()
    (w/'p.prg').write_text('FUNCTION Main()\n ? Seconds()\nRETURN NIL\n')
    c=sh([cc,'p.prg','x'],w,'build')
    for tz in ['Asia/Kolkata','America/New_York']:
        e=dict(env,TZ=tz);t0=time.time();r=sh([w/'x'],w,'run-'+tz.replace('/','-'),e);t1=time.time()
        try:v=float(r.stdout.decode().strip())
        except Exception:v=-1
        lo=int(t0)%86400
        add('elf-tz-'+tz.replace('/','-'),c.returncode==0 and r.returncode==0 and 0<=v<86400 and (v-lo)%86400<=(t1-t0)+2,'value %r utc window start %d'%(v,lo))
res=dict(total=len(rows),passed=sum(r['pass_'] for r in rows),rows=rows)
(out/'results.json').write_text(json.dumps(res,indent=1));print('%d/%d'%(res['passed'],res['total']));raise SystemExit(0 if res['passed']==res['total'] else 1)
