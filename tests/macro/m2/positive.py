from pathlib import Path
import subprocess,os,hashlib,json
R=Path(__file__).resolve().parents[3];E=R/'evidence'/'positive';E.mkdir(exist_ok=True)
# Host adaptation (2026-11-24): HB_M2_COMPILER/HB_ORACLE_CORE override the
# recorded paths; on a Windows host the windows target runs natively (no
# Wine) and the oracle is the native mingw64 hbmk2. The linux target keeps
# the recorded Wine environment and is skipped when it is absent.
cc=os.environ.get('HB_M2_COMPILER','/tmp/hr-m2-hbc');core=os.environ.get('HB_ORACLE_CORE','/tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185')
native=os.name=='nt'
if native:
 hbm=core+'/bin/win/mingw64/hbmk2.exe'
 if not Path(hbm).exists():import sys;sys.exit('HB_ORACLE_CORE must point at the native Harbour mingw64 install on a Windows host')
else:
 hbm=core+'/bin/linux/gcc/hbmk2'
env=os.environ.copy()
if not native:env.update(WINEPREFIX='/tmp/hr-m2-wine11-prefix',WINEDEBUG='-all');wine='/tmp/hr-wine11/opt/wine-stable/bin/wine'
def spawn(exe,env=env):
 if native:return subprocess.run([str(exe)],capture_output=True,timeout=45)
 return subprocess.run([wine,str(exe)],env=env,capture_output=True,timeout=45)
rows=[]
for name in ['mixed','values']:
 for t in ['windows']if native else['linux','windows']:
  d=E/name/t;d.mkdir(parents=True,exist_ok=True);ext='.exe'if t=='windows'else'';src=R/'tests/macro/m2'/(name+'.prg');exe=d/('product'+ext);q=subprocess.run([cc,str(src),str(exe),'--target='+t,'--instrument'],capture_output=True);(d/'compile.stderr').write_bytes(q.stderr);assert not q.returncode,q.stderr
  (d/'product.sha256').write_text(hashlib.sha256(exe.read_bytes()).hexdigest()+'\n');p=spawn(exe);(d/'oracle.prg').write_text(src.read_text().replace('hb_memcheck()','0'))
  if native:
   oe=env.copy();q=subprocess.run([hbm,'oracle.prg','-ooracle','-gtstd','-comp=mingw64'],env=oe,cwd=d,capture_output=True)
  else:
   oe=env.copy()
   if ext:oe.update(PATH='/tmp/hr-win-root/usr/bin:'+oe['PATH'],HB_CCPATH='/tmp/hr-win-root/usr/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',HB_CCSUFFIX='-posix')
   q=subprocess.run([hbm,'oracle.prg','-ooracle','-gtstd']+(['-plat=win','-comp=mingw64']if ext else[]),env=oe,cwd=d,capture_output=True)
  (d/'oracle-build.stdout').write_bytes(q.stdout);(d/'oracle-build.stderr').write_bytes(q.stderr);assert not q.returncode,q.stderr
  oe2=d/('oracle'+ext);o=spawn(oe2);oe2.unlink()
  for label,v in [('product',p),('oracle',o)]:
   for k,b in [('stdout',v.stdout),('stderr',v.stderr),('rc',str(v.returncode).encode()+b'\n')]: (d/(label+'.'+k)).write_bytes(b)
  same=(p.returncode,p.stdout,p.stderr)==(o.returncode,o.stdout,o.stderr);rows.append(dict(name=name,target=t,raw_pass=same));print(name,t,same,flush=True)
(E/'results.json').write_text(json.dumps(rows,indent=2)+'\n');assert all(x['raw_pass']for x in rows)
