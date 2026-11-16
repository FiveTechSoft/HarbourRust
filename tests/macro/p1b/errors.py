from pathlib import Path
import subprocess,os,json,argparse
ap=argparse.ArgumentParser();ap.add_argument('--target',default='linux',choices=['linux','windows']);a=ap.parse_args();win=a.target=='windows';R=Path(__file__).resolve().parents[3];E=R/'evidence/p1b-errors'/a.target;E.mkdir(parents=True,exist_ok=True);env=os.environ.copy();env.update(WINEPREFIX='/tmp/hr-m2-wine11-prefix',WINEDEBUG='-all');wine='/tmp/hr-wine11/opt/wine-stable/bin/wine';ext='.exe'if win else'';rows=[]
exprs=['a'*n for n in [1,63,64,469,470,509,510,511,700]]+['a'*n+'(s)'for n in [63,470,700]]+['&("Upper(s)+missing")','Upper(&("missing"))','&("Upper(1)")',"&('&(\"s+missing\")')",'Upper((s+missing,s))','s+Upper(1)+later','missing+Upper(1)','Upper(s,Lower(1))','Round(n,2)+missing','&("missing+)")','.T. .OR. &("missing")','.F. .AND. Upper(missing)']
for i,e in enumerate(exprs):
 d=E/str(i);d.mkdir(exist_ok=True);source='function Main()\nCheck()\nOutStd("mem",hb_memcheck(),Chr(10))\nreturn nil\nfunction Check()\nprivate s:="abc",n:=3.55\nOutStd(&( '+('['+e+']')+' ))\nreturn nil\n';(d/'case.prg').write_text(source);runs={}
 for label,compiler in [('base','/tmp/hr-p1b-base-hbc'),('candidate','/tmp/hr-p1b-hbc')]:
  exe=d/(label+ext);q=subprocess.run([compiler,str(d/'case.prg'),str(exe),'--target='+a.target,'--instrument'],capture_output=True);assert not q.returncode,q.stderr;q=subprocess.run(([wine]if win else[])+[str(exe)],env=env,capture_output=True,timeout=30);exe.unlink();runs[label]=(q.returncode,q.stdout,q.stderr)
  for k,v in [('rc',str(q.returncode).encode()+b'\n'),('stdout',q.stdout),('stderr',q.stderr)]: (d/(label+'.'+k)).write_bytes(v)
 rows.append(dict(expr=e,raw_pass=runs['base']==runs['candidate']));print(i,rows[-1]['raw_pass'],flush=True)
(E/'results.json').write_text(json.dumps(rows,indent=2)+'\n');assert all(x['raw_pass']for x in rows)
