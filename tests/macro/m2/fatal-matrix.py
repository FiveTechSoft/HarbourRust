from pathlib import Path
import subprocess,os,json,hashlib,argparse
ap=argparse.ArgumentParser();ap.add_argument('--target',choices=['linux','windows'],default='linux');ap.add_argument('--start',type=int,default=0);ap.add_argument('--end',type=int,default=16);a=ap.parse_args();win=a.target=='windows';env=os.environ.copy()
# Native-Windows host adaptation (2026-11-24): the product and oracle run
# directly (no Wine) and the oracle is the local native mingw64 hbmk2; the
# recorded Linux environment stays the default on non-NT hosts.
native_host=os.name=='nt' and win
if not native_host: env.update(WINEPREFIX='/tmp/hr-m2-wine11-prefix',WINEDEBUG='-all')
wine='/tmp/hr-wine11/opt/wine-stable/bin/wine';ext='.exe'if win else '';R=Path(__file__).resolve().parents[3];E=R/'evidence'/'m2-fatal'/a.target;E.mkdir(parents=True,exist_ok=True);cc=os.environ.get('HB_M2_COMPILER','/tmp/hr-m2-hbc');core=os.environ.get('HB_ORACLE_CORE','/tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185')
if native_host and Path(core+'/bin/win/mingw64/hbmk2.exe').exists():hbm=core+'/bin/win/mingw64/hbmk2.exe'
elif native_host:
 import sys;sys.exit('HB_ORACLE_CORE must point at the native Harbour mingw64 install (bin/win/mingw64/hbmk2.exe) on a Windows host')
else:hbm=core+'/bin/linux/gcc/hbmk2'
rows=[]
exprs=['Upper()','Lower()','Round()','Upper(1)','Lower(NIL)','Round(s,2)','Round(n,s)','Round(n)','Upper(s,1,2,3,4,5,6,7,8,missing)','Upper(1,missing)','Round(n,2,missing)','Unknown(1,missing)','Upper(missing)+)','Upper((missing,s))','Upper(Lower(s)+missing)','Round(n,2)+missing']
trap='''INIT PROCEDURE Setup()
ErrorBlock({|e|Trap(e)})
RETURN
function Trap(e)
local n:=1
OutErr(hb_eol()+'Error '+e:subsystem+'/'+LTrim(Str(e:subcode))+'  '+e:description+': '+e:operation)
DO WHILE !Empty(ProcName(++n))
OutErr(hb_eol()+'Called from '+ProcName(n)+'('+LTrim(Str(ProcLine(n)))+')  ')
ENDDO
ErrorLevel(1)
QUIT
return nil
'''
for i,expr in list(enumerate(exprs))[a.start:a.end]:
 d=E/str(i);d.mkdir(exist_ok=True);source='function Main()\nprivate s:=\'abc\',n:=3.555\nOutStd(&('+repr(expr)+'))\nreturn nil\n';(d/'case.prg').write_text(source);(d/'oracle.prg').write_text(source+trap)
 q=subprocess.run([cc,str(d/'case.prg'),str(d/('product'+ext)),'--target='+a.target,'--instrument'],cwd=R,capture_output=True);assert not q.returncode,q.stderr
 (d/'product.sha256').write_text(hashlib.sha256((d/('product'+ext)).read_bytes()).hexdigest()+'\n');p=subprocess.run(([wine]if (win and not native_host)else[])+[str(d/('product'+ext))],env=env,capture_output=True,timeout=15);(d/('product'+ext)).unlink()
 oe=env.copy()
 if win and not native_host:oe.update(PATH='/tmp/hr-win-root/usr/bin:'+oe['PATH'],HB_CCPATH='/tmp/hr-win-root/usr/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',HB_CCSUFFIX='-posix')
 q=subprocess.run([hbm,'oracle.prg','-ooracle','-gtstd','-comp=mingw64']+(['-plat=win','-comp=mingw64']if(win and not native_host)else[]),env=oe,cwd=d,capture_output=True);assert not q.returncode,q.stderr
 o=subprocess.run(([wine]if (win and not native_host)else[])+[str(d/('oracle'+ext))],env=env,capture_output=True,timeout=15);(d/('oracle'+ext)).unlink()
 for label,v in [('product',p),('oracle',o)]:
  for k,b in [('stdout',v.stdout),('stderr',v.stderr),('rc',str(v.returncode).encode()+b'\n')]: (d/(label+'.'+k)).write_bytes(b)
 same=(p.returncode,p.stdout,p.stderr)==(o.returncode,o.stdout,o.stderr);rows.append(dict(index=i,expr=expr,raw_pass=same));print(expr,same,repr(p.stderr)if not same else'',flush=True)
(E/('results-%02d-%02d.json'%(a.start,a.end))).write_text(json.dumps(rows,indent=2)+'\n');assert all(x['raw_pass']for x in rows)
