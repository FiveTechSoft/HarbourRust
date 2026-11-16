"""Bounded raw regression and full emission-diff capture, no normalization."""
from pathlib import Path
import argparse,subprocess,os,gzip,hashlib,json,resource,difflib
p=argparse.ArgumentParser();p.add_argument('--start',type=int,default=0);p.add_argument('--end',type=int,required=True);p.add_argument('--target',choices=['linux','windows'],required=True);a=p.parse_args()
R=Path(__file__).resolve().parents[3];O=R/'evidence'/'battery'/a.target;O.mkdir(parents=True,exist_ok=True)
W=os.environ.get('HB_WINE','/tmp/hr-wine11/opt/wine-stable/bin/wine');M='/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-';env=os.environ.copy();env.update(WINEPREFIX=os.environ.get('WINEPREFIX','/tmp/hr-m2-wine11-prefix'),WINEDEBUG='-all')
lines=[x for x in (R/'tests/manifest.txt').read_text().splitlines() if x.strip() and not x.lstrip().startswith('#')];rows=[]
def limits():
 resource.setrlimit(resource.RLIMIT_CPU,(5,5));resource.setrlimit(resource.RLIMIT_FSIZE,(4*1024**2,4*1024**2))
def call(cmd,timeout=20,limited=False):return subprocess.run(cmd,cwd=R,env=env,capture_output=True,stdin=subprocess.DEVNULL,timeout=timeout,preexec_fn=limits if limited else None)
for idx in range(a.start,min(a.end,len(lines))):
 parts=lines[idx].split(' ',2);kind,source=parts[:2];rest=parts[2]if len(parts)>2 else '';d=O/str(idx);d.mkdir(exist_ok=True);row=dict(index=idx,kind=kind,source=source);runs={};assemblies={}
 for label,compiler in [('base',os.environ.get('HB_BASE_COMPILER','/tmp/hr-b2-base-hbc')),('candidate',os.environ.get('HB_B2_COMPILER','/tmp/hr-b2-hbc-final'))]:
  try:
   asm=d/(label+'.s');q=call([compiler,source,str(asm),'--target='+a.target,'--instrument','-I','tests']);run=dict(compile_rc=q.returncode,compile_stderr=q.stderr.decode(errors='replace'))
   (d/(label+'.compile.stdout')).write_bytes(q.stdout);(d/(label+'.compile.stderr')).write_bytes(q.stderr);(d/(label+'.compile.rc')).write_text(str(q.returncode)+'\n')
   if q.returncode==0 and kind!='neg':
    text=asm.read_bytes();assemblies[label]=text;run['asm_sha256']=hashlib.sha256(text).hexdigest();(d/(label+'.s.gz')).write_bytes(gzip.compress(text,mtime=0));asm.unlink()
    # Reinflate only while assembling. Binary/object removed after capture.
    asm.write_bytes(text);obj=d/(label+'.o');binary=d/(label+('.exe'if a.target=='windows'else''));cmd=[M+'as'if a.target=='windows'else'as',str(asm),'-o',str(obj)];q=call(cmd);asm.unlink()
    if q.returncode==0:q=call(([M+'ld']if a.target=='windows'else['ld'])+[str(obj),'-o',str(binary)]+(['-e','_start','--subsystem','console','-L/tmp/hr-win-root/usr/x86_64-w64-mingw32/lib','-lkernel32']if a.target=='windows'else[]))
    (d/(label+'.link.stderr')).write_bytes(q.stderr);run['build_rc']=q.returncode
    if obj.exists():obj.unlink()
    if q.returncode==0:
     run['binary_sha256']=hashlib.sha256(binary.read_bytes()).hexdigest();q=call(([W]if a.target=='windows'else[])+[str(binary)],limited=True);runs[label]=(q.returncode,q.stdout,q.stderr)
     for ext,value in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (d/(label+'.'+ext)).write_bytes(value)
     run.update(rc=q.returncode,stdout_sha256=hashlib.sha256(q.stdout).hexdigest(),stderr_sha256=hashlib.sha256(q.stderr).hexdigest())
     binary.unlink()
   elif asm.exists():asm.unlink()
   row[label]=run
  except Exception as e:row[label]={'exception':str(e)}
 if kind=='neg':row['same_raw']=row.get('base')==row.get('candidate')
 else:
  row['same_raw']=('base'in runs and 'candidate'in runs and runs['base']==runs['candidate'])or(row.get('base')==row.get('candidate') and row.get('base',{}).get('compile_rc',0)!=0)
  row['executed']='base'in runs and 'candidate'in runs
 if assemblies.keys()=={'base','candidate'}:
  diff=''.join(difflib.unified_diff(assemblies['base'].decode().splitlines(True),assemblies['candidate'].decode().splitlines(True),fromfile='BASE/'+source,tofile='B2/'+source));row['same_emission']=not diff
  if diff:(d/'emission.diff.gz').write_bytes(gzip.compress(diff.encode(),mtime=0))
 rows.append(row)
 if (idx+1)%50==0:print(a.target,idx+1,'cases',flush=True)
(O/('results-%04d-%04d.json'%(a.start,a.end))).write_text(json.dumps(rows,indent=2)+'\n');different=[r for r in rows if not r['same_raw']];print(a.target,a.start,a.end,'count',len(rows),'raw differences',len(different));print(json.dumps(different[:12],indent=2))
