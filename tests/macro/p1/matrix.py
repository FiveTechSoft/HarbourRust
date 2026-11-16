from pathlib import Path
import subprocess,os,json,argparse,hashlib
ap=argparse.ArgumentParser();ap.add_argument('--target',choices=['linux','windows'],default='linux');a=ap.parse_args();win=a.target=='windows';R=Path(__file__).resolve().parents[3];E=R/'evidence/p1-matrix'/a.target;E.mkdir(parents=True,exist_ok=True);env=os.environ.copy();env.update(WINEPREFIX='/tmp/hr-m2-wine11-prefix',WINEDEBUG='-all');wine='/tmp/hr-wine11/opt/wine-stable/bin/wine';ext='.exe'if win else'';core='/tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185'
exprs=[str(n)for n in range(9223372036854775760,9223372036854775841)]+['-'+str(n)for n in range(9223372036854775760,9223372036854775841)]
for n in ['9223372036854775789','9223372036854775790','9223372036854775806','9223372036854775807','9223372036854775808','9223372036854775809']:
 exprs += [n+s for s in ['.0','.1','.5','.9','+1','-1','/1','%3','*1']]+['-'+n+s for s in ['.0','.1','.5','.9','+1','-1','/1','%3','*1']]
source='function Main()\nCheck()\nOutStd("mem",hb_memcheck(),Chr(10))\nreturn nil\nfunction Check()\nlocal text:=""\n'
for i,e in enumerate(exprs):source+='text:='+repr(e)+'\nOutStd('+repr(str(i)+'=')+',Str(&(text)),Chr(10))\n'
source+='return nil\n';(E/'case.prg').write_text(source);(E/'oracle.prg').write_text(source.replace('hb_memcheck()','0'));(E/'expressions.json').write_text(json.dumps(exprs,indent=2)+'\n');runs={}
for label,compiler in [('base','/tmp/hr-n1-hbc'),('candidate','/tmp/hr-p1-hbc')]:
 exe=E/(label+ext);q=subprocess.run([compiler,str(E/'case.prg'),str(exe),'--target='+a.target,'--instrument'],capture_output=True);assert not q.returncode,q.stderr;(E/(label+'.binary.sha256')).write_text(hashlib.sha256(exe.read_bytes()).hexdigest()+'\n');runs[label]=subprocess.run(([wine]if win else[])+[str(exe)],env=env,capture_output=True,timeout=45);exe.unlink()
oe=env.copy()
if win:oe.update(PATH='/tmp/hr-win-root/usr/bin:'+oe['PATH'],HB_CCPATH='/tmp/hr-win-root/usr/bin/',HB_CCPREFIX='x86_64-w64-mingw32-',HB_CCSUFFIX='-posix')
q=subprocess.run([core+'/bin/linux/gcc/hbmk2','oracle.prg','-ooracle','-gtstd']+(['-plat=win','-comp=mingw64']if win else[]),cwd=E,env=oe,capture_output=True);assert not q.returncode,(q.stdout,q.stderr);exe=E/('oracle'+ext);runs['oracle']=subprocess.run(([wine]if win else[])+[str(exe)],env=env,capture_output=True,timeout=45);exe.unlink()
for label,q in runs.items():
 for k,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (E/(label+'.'+k)).write_bytes(v)
rows=[]
for i,e in enumerate(exprs):
 b,c,o=[runs[l].stdout.splitlines()[i]for l in ['base','candidate','oracle']];rows.append(dict(expr=e,base_pass=b==o,candidate_pass=c==o,base=b.decode(),candidate=c.decode(),oracle=o.decode()))
(E/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(a.target,len(rows),'base failures',sum(not r['base_pass']for r in rows),'candidate failures',sum(not r['candidate_pass']for r in rows));print(json.dumps([r for r in rows if not r['candidate_pass']][:15],indent=2));assert not any(r['base_pass']and not r['candidate_pass']for r in rows);assert all(r['candidate']==r['oracle']or r['candidate']==r['base']for r in rows);assert all(q.returncode==0 and not q.stderr for q in runs.values())
