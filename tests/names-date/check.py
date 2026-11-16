#!/usr/bin/env python3
"""Own names/Date probes. Fresh external Harbour; raw stdout/stderr/exit."""
import argparse,hashlib,json,os,pathlib,subprocess
P=pathlib.Path
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--output',required=True);ap.add_argument('--wine');ap.add_argument('--group',choices=['names','date','all'],default='all');a=ap.parse_args()
out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);compiler=str(P(a.compiler).resolve());hbmk2=str(P(a.hbmk2).resolve());root=P(__file__).resolve().parent;rows=[];env=os.environ.copy();env.setdefault('WINEDEBUG','-all');env['LC_ALL']='C.UTF-8'
def run(cmd,work,label,environment=env):
 r=subprocess.run(list(map(str,cmd)),cwd=work,env=environment,capture_output=True,stdin=subprocess.DEVNULL,timeout=60)
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(work/(label+'.'+k)).write_bytes(v)
 return r
for src in sorted((root/'programs').glob('*.prg')):
 if a.group!='all' and not src.stem.startswith(a.group+'_'):continue
 for target in ['linux']+(['windows']if a.wine else[]):
  work=out/src.stem/target;work.mkdir(parents=True);(work/src.name).write_bytes(src.read_bytes());results={}
  for kind in ['harbour','hbc']:
   exe=work/(kind+('.exe'if target=='windows'else''));local=env.copy()
   if kind=='harbour':
    cmd=[hbmk2,src.name,'-gtstd','-o'+str(exe.with_suffix('')if target=='windows'else exe)]
    if target=='windows':cmd+=['-plat=win','-comp=mingw64']
    else:local.pop('HB_CCPREFIX',None)
   else:cmd=[compiler,str(src),str(exe),'--target='+target]
   r=run(cmd,work,kind+'-build',local);assert r.returncode==0,(src.name,target,kind,r.stdout,r.stderr)
   r=run(([a.wine]if target=='windows'else[])+[exe],work,kind+'-run');results[kind]=(r.returncode,r.stdout,r.stderr)
  okay=results['harbour']==results['hbc'];rows.append({'source':src.name,'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'target':target,'exact':okay,'harbour':repr(results['harbour']),'hbc':repr(results['hbc'])});print(('PASS 'if okay else'FAIL ')+src.stem+' '+target,flush=True)
(out/'results.json').write_text(json.dumps({'compiler_sha256':hashlib.sha256(P(compiler).read_bytes()).hexdigest(),'rows':rows},indent=2)+'\n')
assert all(x['exact']for x in rows),'byte mismatch, see evidence'
