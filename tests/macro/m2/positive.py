from pathlib import Path
import subprocess,os,hashlib,json
R=Path(__file__).resolve().parents[3];E=R/'evidence'/'positive';E.mkdir(exist_ok=True);core='/tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185';env=os.environ.copy();env.update(WINEPREFIX='/tmp/hr-m2-wine11-prefix',WINEDEBUG='-all');wine='/tmp/hr-wine11/opt/wine-stable/bin/wine';rows=[]
for name in ['mixed','values']:
 for t in ['linux','windows']:
  d=E/name/t;d.mkdir(parents=True,exist_ok=True);ext='.exe'if t=='windows'else'';src=R/'tests/macro/m2'/(name+'.prg');exe=d/('product'+ext);q=subprocess.run(['/tmp/hr-m2-hbc',str(src),str(exe),'--target='+t,'--instrument'],capture_output=True);(d/'compile.stderr').write_bytes(q.stderr);assert not q.returncode,q.stderr
  (d/'product.sha256').write_text(hashlib.sha256(exe.read_bytes()).hexdigest()+'\n');p=subprocess.run(([wine]if ext else[])+[str(exe)],env=env,capture_output=True,timeout=45);exe.unlink();(d/'oracle.prg').write_text(src.read_text().replace('hb_memcheck()','0'))
  oe=env.copy()
  if ext:oe.update(PATH='/tmp/hr-win-root/usr/bin:'+oe['PATH'],HB_CCPATH='/tmp/hr-win-root/usr/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',HB_CCSUFFIX='-posix')
  q=subprocess.run([core+'/bin/linux/gcc/hbmk2','oracle.prg','-ooracle','-gtstd']+(['-plat=win','-comp=mingw64']if ext else[]),env=oe,cwd=d,capture_output=True);(d/'oracle-build.stdout').write_bytes(q.stdout);(d/'oracle-build.stderr').write_bytes(q.stderr);assert not q.returncode,q.stderr
  exe=d/('oracle'+ext);(d/'oracle.sha256').write_text(hashlib.sha256(exe.read_bytes()).hexdigest()+'\n');o=subprocess.run(([wine]if ext else[])+[str(exe)],env=env,capture_output=True,timeout=45);exe.unlink()
  for label,v in [('product',p),('oracle',o)]:
   for k,b in [('stdout',v.stdout),('stderr',v.stderr),('rc',str(v.returncode).encode()+b'\n')]: (d/(label+'.'+k)).write_bytes(b)
  same=(p.returncode,p.stdout,p.stderr)==(o.returncode,o.stdout,o.stderr);rows.append(dict(name=name,target=t,raw_pass=same));print(name,t,same,flush=True)
(E/'results.json').write_text(json.dumps(rows,indent=2)+'\n');assert all(x['raw_pass']for x in rows)
