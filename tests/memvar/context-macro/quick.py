from pathlib import Path
import subprocess,os,json
R=Path(__file__).resolve().parents[3];F=Path(__file__).with_name('fixtures');O=R/'evidence'/'prg';O.mkdir(parents=True,exist_ok=True)
env=os.environ.copy();env.update(WINEDEBUG='-all',WINEPREFIX='/tmp/hr-win11-prefix',PATH='/tmp/hr-win-root/usr/bin:'+env['PATH'],HB_CCPATH='/tmp/hr-win-root/usr/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',HB_CCSUFFIX='-posix')
core='/tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185';wine='/tmp/hr-wine11/opt/wine-stable/bin/wine'
for fixture in ['mixed','frames','defaults','names']:
 for target in ['linux','windows']:
  d=O/fixture/target;d.mkdir(parents=True,exist_ok=True);f=F/(fixture+'.prg');binary=d/('product.exe'if target=='windows'else'product')
  q=subprocess.run([os.environ.get('HB_B2_COMPILER','/tmp/hr-b2-hbc-final'),str(f),str(binary.with_suffix('.s') if target=='windows' else binary),'--target='+target,'--instrument','--external-as'],env=env,cwd=R,capture_output=True)
  for ext,value in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (d/('compile.'+ext)).write_bytes(value)
  if q.returncode:print(fixture,target,'compileFAIL',q.stderr.decode());continue
  if target=='windows':
   subprocess.run(['/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-as',str(binary.with_suffix('.s')),'-o',str(d/'product.o')],check=True)
   subprocess.run(['/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-ld',str(d/'product.o'),'-o',str(binary),'-e','_start','--subsystem','console','-L/tmp/hr-win-root/usr/x86_64-w64-mingw32/lib','-lkernel32'],check=True)
   (d/'product.o').unlink()
  q=subprocess.run(([wine]if target=='windows'else[])+[str(binary)],env=env,cwd=R,capture_output=True,timeout=10)
  for ext,value in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (d/('run.'+ext)).write_bytes(value)
  binary.unlink()
  # Oracle substitutes only harness-specific memcheck, records this scope.
  oracle_env=env.copy()
  if target=='linux':
   for key in ['HB_CCPATH','HB_CCPREFIX','HB_CCSUFFIX']:oracle_env.pop(key,None)
  source=d/'oracle.prg';source.write_text(f.read_text().replace('hb_memcheck()','0'))
  q=subprocess.run([core+'/bin/linux/gcc/hbmk2',source.name,'-ooracle','-gtstd']+(['-plat=win','-comp=mingw64']if target=='windows'else[]),env=oracle_env,cwd=d,capture_output=True)
  (d/'oracle-build.stdout').write_bytes(q.stdout);(d/'oracle-build.stderr').write_bytes(q.stderr);assert q.returncode==0,(fixture,target,q.stderr)
  executable=d/('oracle.exe'if target=='windows'else'oracle');q=subprocess.run(([wine]if target=='windows'else[])+[str(executable)],env=env,cwd=d,capture_output=True,timeout=10)
  for ext,value in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (d/('oracle.'+ext)).write_bytes(value)
  executable.unlink();same=(d/'run.stdout').read_bytes()==q.stdout and (d/'run.stderr').read_bytes()==q.stderr and (d/'run.rc').read_text()==str(q.returncode)+'\n';print(fixture,target,same)
