#!/usr/bin/env python3
"""FILE compatibility manifest. Compare raw stdout, stderr and exit code.
Use a NEW --output directory. No normalization or golden updates in this gate.
"""
import argparse,hashlib,json,os,pathlib,shutil,subprocess
P=pathlib.Path
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);ap.add_argument('--wine');ap.add_argument('--hbmk2');ap.add_argument('--oracle-commit');ap.add_argument('--oracle-windows',action='store_true');a=ap.parse_args()
root=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cwd=out/'fs';cwd.mkdir();build=out/'build';build.mkdir();compiler=str(P(a.compiler).resolve());manifest=json.loads((root/'manifest.json').read_text());records=[]
for directory in ['sub','default','search','odd\\','a'*250]:(cwd/directory).mkdir()
for file in ['Exact.TXT','.hidden','noext','sub/nested.txt','default/only.txt','search/path.txt','*.star','?.question','[bracket',']bracket','[x','café.txt','odd\\/back.txt','a'*250+'/'+ 'b'*11]:(cwd/file).touch()
for name,dest in [('link.txt','Exact.TXT'),('broken','absent'),('linkdir','sub'),('cycle','cycle')]:(cwd/name).symlink_to(dest)
for source in root.glob('*.prg'):shutil.copyfile(source,cwd/source.name)
env=os.environ.copy();env['WINEDEBUG']='-all';env['LC_ALL']='C.UTF-8'
def run(cmd,label):
 local_env=env.copy()
 if a.hbmk2 and str(cmd[0])==a.hbmk2 and '-plat=win'not in cmd:local_env.pop('HB_CCPREFIX',None)
 r=subprocess.run(list(map(str,cmd)),cwd=cwd,env=local_env,capture_output=True,stdin=subprocess.DEVNULL,timeout=45)
 for suffix,data in [('stdout',r.stdout),('stderr',r.stderr)]: (out/(label+'.'+suffix)).write_bytes(data)
 (out/(label+'.rc')).write_text(str(r.returncode)+'\n');return r
def execute(exe,target,label):return run(([a.wine]if target=='windows'else[])+[str(exe)],label)
def check(r,stdout,stderr,rc,label):
 okay=(r.returncode,r.stdout,r.stderr)==(rc,stdout,stderr);records.append({'id':label,'pass':okay,'exit':r.returncode,'stdout_sha256':hashlib.sha256(r.stdout).hexdigest(),'stderr_sha256':hashlib.sha256(r.stderr).hexdigest()});assert okay,(label,r.returncode,r.stdout,r.stderr)
server=str(P(a.wine).with_name('wineserver'))if a.wine else None
if server:
 subprocess.run([server,'-p180'],env=env,check=True)
 subprocess.run([a.wine,'cmd','/c','exit'],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True,timeout=45)
try:
 for target in ['linux']+(['windows']if a.wine else[]):
  for entry in manifest['positive']:
   name=entry['name'];source=name+'.prg';expected=(root/(name+'.'+target+'.stdout')).read_bytes();err=(root/(name+'.'+target+'.stderr')).read_bytes();ext='.exe'if target=='windows'else''
   if a.hbmk2 and (target=='linux'or a.oracle_windows) and entry.get('oracle',True):
    exe=cwd/('oracle_'+name+ext);flags=['-plat=win','-comp=mingw64']if target=='windows'else[]
    r=run([a.hbmk2,source,*flags,'-gtstd','-o'+str(exe.with_suffix('')if target=='windows'else exe)],'oracle-build-'+name+'-'+target);assert r.returncode==0,(r.stdout,r.stderr)
    check(execute(exe,target,'oracle-'+name+'-'+target),expected,err,0,'oracle-'+name+'-'+target)
   for engine in ['internal','external']:
    label=name+'-'+target+'-'+engine;exe=build/(label+ext)
    r=run([compiler,source,exe,'--target='+target,'--instrument']+(['--external-as']if engine=='external'else[]),'build-'+label);assert r.returncode==0,(label,r.stdout,r.stderr)
    check(execute(exe,target,label),expected,err,0,label)
  for entry in manifest['negative']:
   label=entry['name']+'-'+target;r=run([compiler,entry['name']+'.prg',build/(label+ext),'--target='+target],label);okay=r.returncode==1 and entry['contains'].encode()in r.stderr
   records.append({'id':label,'pass':okay});assert okay,(label,r.returncode,r.stdout,r.stderr)
  for flags in [['--target=macho'],['--experimental-llvm']]:
   label='unsupported-'+target+'-'+flags[0].split('=')[-1].removeprefix('--');r=run([compiler,'file_basic.prg',build/(label+'.s'),*flags],label);assert r.returncode==1 and b'FILE/SET DEFAULT/PATH'in r.stderr,(label,r.stdout,r.stderr);records.append({'id':label,'pass':True})
  # Optional output: case-preserving stem, .exe only for Windows, explicit output unchanged.
  (cwd/'MixedTest.prg').write_text('procedure Main()\n? "ok"\nreturn\n');exe=cwd/('MixedTest'+ext)
  for explicit in [False,True]:
   targetfile=(cwd/('Chosen'+ext))if explicit else exe;label='output-'+target+('-explicit'if explicit else '-implicit')
   r=run([compiler,'MixedTest.prg']+([targetfile]if explicit else[])+['--target='+target],label+'-build');assert r.returncode==0 and targetfile.is_file(),(label,r.stdout,r.stderr)
   check(execute(targetfile,target,label),b'\r\nok'if target=='windows'else b'\nok',b'',0,label)
finally:
 if server:
  subprocess.run([server,'-k'],env=env,check=True);subprocess.run([server,'-w'],env=env,check=True)
 report={'compiler_sha256':hashlib.sha256(P(compiler).read_bytes()).hexdigest(),'oracle_commit':a.oracle_commit,'oracle_hbmk2':a.hbmk2,'manifest_sha256':hashlib.sha256((root/'manifest.json').read_bytes()).hexdigest(),'records':records,'count':len(records)}
 (out/'result.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS',len(records),'byte-exact execution and rejection checks')
