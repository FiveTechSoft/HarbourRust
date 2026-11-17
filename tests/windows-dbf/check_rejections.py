from pathlib import Path
import subprocess,os,shutil,json
import argparse
ap=argparse.ArgumentParser();ap.add_argument('--compiler',default='hbc-final');ap.add_argument('--wine',required=True);ap.add_argument('--wine-prefix',required=True);ap.add_argument('--output',required=True);ap.add_argument('--fixtures',required=True);a=ap.parse_args()
r=Path(__file__).resolve().parents[2];compiler=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);src=Path(a.fixtures).resolve();rows=[]
for p in src.glob('*.cdx'):shutil.copyfile(p,out/p.name)
shutil.copyfile(src/'cdxprobe.dbf',out/'data.dbf')
b=(out/'names.cdx').read_bytes();(out/'trunc.cdx').write_bytes(b[:-1]);(out/'zero.cdx').write_bytes(bytes(len(b)))
mut=bytearray((out/'data.dbf').read_bytes());mut[100]=mut[100]^1;(out/'stale.dbf').write_bytes(mut)
# 100 is within first record, not header; independent mismatch, never a writer test.
env={**os.environ,'WINEPREFIX':a.wine_prefix,'WINEDEBUG':'-all'}
for index in ['unique','descending','conditional','numeric','expression','multi','trunc','zero','stale']:
 dbf='stale.dbf' if index=='stale' else 'data.dbf';idx='names' if index=='stale' else index
 for mode,flags in [('normal',[]),('instrument',['--instrument'])]:
  name=index+'-'+mode;p=out/(name+'.prg');p.write_text('request DBFCDX\nfunction Main()\ndbUseArea(.T.,"DBFCDX","'+dbf+'","P",.F.,.T.)\nOrdListAdd("'+idx+'.cdx")\n? "CURSOR EXPOSED"\nreturn nil\n')
  q=subprocess.run([compiler,p,out/(name+'.exe'),'--target=windows',*flags],capture_output=True);assert q.returncode==0,q.stderr
  q=subprocess.run([a.wine,str(out/(name+'.exe'))],cwd=out,env=env,capture_output=True,timeout=15)
  for ext,data in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(out/(name+'.'+ext)).write_bytes(data)
  assert q.returncode==1 and not q.stdout and b'rejected' in q.stderr,(name,q.returncode,q.stdout,q.stderr);rows.append(dict(case=name,pass_=True))
static=[('arity','dbUseArea(.T.,"DBFCDX","data.dbf","P",.F.)'),('shared','dbUseArea(.T.,"DBFCDX","data.dbf","P",.T.,.T.)'),('write','dbUseArea(.T.,"DBFCDX","data.dbf","P",.F.,.F.)'),('driver','dbUseArea(.T.,"BAD","data.dbf","P",.F.,.T.)'),('seek-type','dbSeek(3)'),('append','dbAppend()')]
for name,body in static:
 p=out/(name+'.prg');p.write_text('function Main()\n'+body+'\nreturn nil\n');q=subprocess.run([compiler,p,out/(name+'.exe'),'--target=windows'],capture_output=True);(out/(name+'.compile.stderr')).write_bytes(q.stderr);assert q.returncode!=0 and q.stderr,(name,q.stderr);rows.append(dict(case='static-'+name,pass_=True))
p=out/'platform.prg';p.write_text('function Main()\ndbCloseArea()\nreturn nil\n')
for target in ['--experimental-llvm']:  # Mach-O runs DBF since 17 November
 q=subprocess.run([compiler,p,out/'platform.out',target],capture_output=True);assert q.returncode!=0 and b'ordinary native backend' in q.stderr;(out/(target.replace('--','').replace('=','-')+'.stderr')).write_bytes(q.stderr);rows.append(dict(case=target,pass_=True))
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',len(rows),'explicit pre-cursor format/subset/runtime and static/platform rejections')
