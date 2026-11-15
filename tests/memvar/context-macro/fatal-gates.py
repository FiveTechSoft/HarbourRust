from pathlib import Path
import os,subprocess,json,hashlib,difflib
R=Path(__file__).resolve().parents[3];E=R/'evidence'/'fatal-gates';E.mkdir(exist_ok=True)
core=Path('/tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185');wine='/tmp/hr-wine11/opt/wine-stable/bin/wine';env=os.environ.copy();env.update(WINEPREFIX='/tmp/hr-win11-prefix',WINEDEBUG='-all')
err=(core/'src/rtl/errsys.prg').read_text();start=err.index('   // Build buttons');end=err.index('   // "Quit" selected');err=err[:start]+'   // terminal-headless profile: omit Alert/retry UI only\n'+err[end:];(E/'terminal-errsys.prg').write_text(err);(E/'autoquit.prg').write_text('INIT PROCEDURE QueueQuit()\n   hb_keyPut(13)\nRETURN\n')
cases={'str-string':"function Main()\nprivate x:='text'\nOutStd(Str(x))\nreturn nil\n",'str-logical':"function Main()\nprivate x:=.T.\nOutStd(Str(x))\nreturn nil\n",'str-nil':"function Main()\nprivate x\nOutStd(Str(x))\nreturn nil\n",'first-left':"function Main()\nprivate s:='owned'\nOutStd(&(\"left + (s+' temp') + right\"))\nreturn nil\n",'first-right':"function Main()\nprivate s:='owned'\nOutStd(&(\"(s+' temp') + missing + later\"))\nreturn nil\n",'syntax-first':"function Main()\nprivate s:='owned'\nOutStd(&(\"missing + )\"))\nreturn nil\n",'explicit-missing':"function Main()\nprivate s:='owned'\nOutStd(&(\"M->absent\"))\nreturn nil\n",'child-fatal':"function Main()\nprivate x:='parent'\nChild()\nreturn nil\nfunction Child()\nprivate x:='child'\nOutStd(&(\"(x+' temp')+missing\"))\nreturn nil\n"}
rows=[]
for name,source in cases.items():
 for target in ['linux','windows']:
  d=E/name/target;d.mkdir(parents=True,exist_ok=True);(d/'case.prg').write_text(source);product=d/('product.exe'if target=='windows'else'product')
  q=subprocess.run([os.environ.get('HB_B2_COMPILER','/tmp/hr-b2-hbc-final'),str(d/'case.prg'),str(product),'--target='+target,'--instrument'],capture_output=True,cwd=R);(d/'compile.stderr').write_bytes(q.stderr);assert not q.returncode,q.stderr
  (d/'product.sha256').write_text(hashlib.sha256(product.read_bytes()).hexdigest()+'\n')
  q=subprocess.run(([wine]if target=='windows'else[])+[str(product)],capture_output=True,env=env,timeout=60);raw=(q.returncode,q.stdout,q.stderr)
  for k,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (d/('run.'+k)).write_bytes(v)
  product.unlink();oe=env.copy()
  if target=='windows':oe.update(PATH='/tmp/hr-win-root/usr/bin:'+oe['PATH'],HB_CCPATH='/tmp/hr-win-root/usr/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',HB_CCSUFFIX='-posix')
  (d/'oracle-case.prg').write_text(source+'''INIT PROCEDURE B2Setup()
ErrorBlock({|e|B2Trap(e)})
RETURN
function B2Trap(e)
local n:=1
OutErr(hb_eol()+'Error '+e:subsystem+'/'+LTrim(Str(e:subcode))+'  '+e:description+': '+e:operation)
DO WHILE !Empty(ProcName(++n))
OutErr(hb_eol()+'Called from '+ProcName(n)+'('+LTrim(Str(ProcLine(n)))+')  ')
ENDDO
ErrorLevel(1)
QUIT
return nil
''');q=subprocess.run([str(core/'bin/linux/gcc/hbmk2'),'oracle-case.prg','-ooracle','-gtstd']+(['-plat=win','-comp=mingw64']if target=='windows'else[]),cwd=d,env=oe,capture_output=True);(d/'oracle-build.stdout').write_bytes(q.stdout);(d/'oracle-build.stderr').write_bytes(q.stderr);assert not q.returncode,q.stderr
  binary=d/('oracle.exe'if target=='windows'else'oracle');(d/'oracle.sha256').write_text(hashlib.sha256(binary.read_bytes()).hexdigest()+'\n');q=subprocess.run(([wine]if target=='windows'else[])+[str(binary)],env=env,cwd=d,capture_output=True,timeout=60)
  for k,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (d/('oracle.'+k)).write_bytes(v)
  binary.unlink();same=raw==(q.returncode,q.stdout,q.stderr);rows.append(dict(case=name,target=target,raw_pass=same));print(name,target,same,repr(raw[2])if not same else'')
for name,expr in [('static-string',"'text'"),('static-array','{1}')]:
 d=E/name;d.mkdir(exist_ok=True);(d/'case.prg').write_text('function Main()\nlocal x:='+expr+'\nOutStd(Str(x))\nreturn nil\n')
 for target in ['linux','windows']:
  raw=[]
  for label,cc in [('base',os.environ.get('HB_BASE_COMPILER','/tmp/hr-b2-base-hbc')),('candidate',os.environ.get('HB_B2_COMPILER','/tmp/hr-b2-hbc-final'))]:
   q=subprocess.run([cc,str(d/'case.prg'),str(d/'unused.s'),'--target='+target],capture_output=True);raw.append((q.returncode,q.stdout,q.stderr))
   for k,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (d/(target+'.'+label+'.'+k)).write_bytes(v)
  rows.append(dict(case=name,target=target,raw_pass=raw[0]==raw[1]and raw[0][0]==1 and not raw[0][1]))
(E/'results.json').write_text(json.dumps(rows,indent=2)+'\n');assert all(x['raw_pass']for x in rows)
