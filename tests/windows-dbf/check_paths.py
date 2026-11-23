from pathlib import Path
import subprocess,os,json,shutil
import argparse
ap=argparse.ArgumentParser();ap.add_argument('--compiler',default='hbc-final');ap.add_argument('--wine',required=True);ap.add_argument('--wine-prefix',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
r=Path(__file__).resolve().parents[2];compiler=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);wine=a.wine;rows=[]
env={**os.environ,'WINEPREFIX':a.wine_prefix,'WINEDEBUG':'-all'};wine=a.wine;rows=[]
# Real file paths, not parser-only acceptance; copy identical quiescent fixture.
(out/'dir.with.dot').mkdir();shutil.copy(r/'cdxprobe.dbf',out/'dir.with.dot'/'DATA.DBF');shutil.copy(r/'names.cdx',out/'names.cdx')
(out/'index.dir').mkdir();shutil.copy(r/'names.cdx',out/'index.dir'/'keys.CDX')
(out/'bad.dbf').write_bytes(bytes(40));b=bytearray((r/'cdxprobe.dbf').read_bytes());b[28]=1;(out/'struct.dbf').write_bytes(b)
def case(name,path,static=True,ok=False,index=None):
 value='"'+path+'"' if static else 'path+""'
 prefix='' if static else 'local path:="'+path+'"\n'
 body='request DBFCDX\nfunction Main()\n'+prefix+'dbUseArea(.T.,"DBFCDX",'+value+',"P",.F.,.T.)\n'
 if index:body+='OrdListAdd("'+index+'")\n'
 body+='? LastRec()\ndbCloseArea()\nreturn nil\n';p=out/(name+'.prg');p.write_text(body)
 q=subprocess.run([compiler,p,out/(name+'.exe'),'--target=windows','--instrument'],capture_output=True)
 (out/(name+'.compile.stderr')).write_bytes(q.stderr)
 if static and not ok and name.startswith('static-'):
  passed=q.returncode!=0 and b'Windows DBF path requires' in q.stderr;rc=q.returncode
 else:
  assert q.returncode==0,(name,q.stderr)
  q=subprocess.run([wine,str(out/(name+'.exe'))],cwd=out,env=env,capture_output=True,timeout=15);rc=q.returncode
  (out/(name+'.stdout')).write_bytes(q.stdout);(out/(name+'.stderr')).write_bytes(q.stderr)
  passed=(rc==0 and b'250' in q.stdout and not q.stderr) if ok else (rc==1 and b'hbc:' in q.stderr)
 if name=='same-basename':assert b'index read-only open rejected' in q.stderr,q.stderr  # other dir: not the structural bag, and missing
 rows.append(dict(case=name,path=path,static=static,expected_success=ok,rc=rc,pass_=passed));print(rows[-1]);assert passed
for n,p in [('slash','dir.with.dot/DATA.DBF'),('backslash','dir.with.dot\\DATA.DBF'),('mixed','./dir.with.dot\\DATA.DBF'),('absolute','Z:'+str(out/'dir.with.dot/DATA.DBF').replace('/','\\'))]:case(n,p,ok=True)
for n,p in [('index-slash','index.dir/keys.CDX'),('index-backslash','index.dir\\keys.CDX'),('index-mixed','./index.dir\\keys.CDX')]:case(n,'dir.with.dot/DATA.DBF',ok=True,index=p)
for n,p in [('unicode','dátá.dbf'),('unc','\\\\server\\data.dbf'),('namespace','\\\\?\\C:\\data.dbf'),('root','\\data.dbf'),('drive-relative','C:data.dbf'),('bad-drive','1:\\data.dbf'),('device','CON.dbf'),('device-space','CON .dbf'),('console','CONIN$'),('console-out','CONOUT$'),('clock','CLOCK$'),('deviceport','LPT1.dbf'),('trailing','data. '),('overlong','a'*260)]:
 case('static-'+n,p);case('runtime-'+n,p,static=False)
case('valid-device-prefix','COM123.dbf',static=False) # Valid lexical name, nonexistent file is explicit IO failure.
p=out/'nul.prg';p.write_text('function Main()\nlocal path:="cdxprobe.dbf"+Chr(0)+"junk"\ndbUseArea(.T.,"DBFCDX",path,"P",.F.,.T.)\nreturn nil\n')
q=subprocess.run([compiler,p,out/'nul.exe','--target=windows'],capture_output=True);assert q.returncode==0,q.stderr
q=subprocess.run([wine,str(out/'nul.exe')],cwd=out,env=env,capture_output=True);assert q.returncode==1 and b'contains NUL' in q.stderr
(out/'nul.stderr').write_bytes(q.stderr);rows.append(dict(case='runtime-nul',pass_=True,rc=q.returncode))
case('missing','missing.dbf');case('malformed','bad.dbf');case('structural','struct.dbf');case('same-basename','dir.with.dot/DATA.DBF',index='other\\data.cdx')
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',len(rows))
