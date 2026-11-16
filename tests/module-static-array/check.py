#!/usr/bin/env python3
"""Fresh Harbour oracle for persistent module STATIC fixed arrays. Raw bytes only."""
import argparse, hashlib, json, os, pathlib, subprocess
P=pathlib.Path
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--wine');ap.add_argument('--output',required=True);a=ap.parse_args()
root=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);compiler=str(P(a.compiler).resolve());hbmk2=str(P(a.hbmk2).resolve());env=os.environ.copy();env['LC_ALL']='C.UTF-8';env['WINEDEBUG']='-all';rows=[]
def run(cmd,work,label,e=env):
 r=subprocess.run(list(map(str,cmd)),cwd=work,env=e,capture_output=True,stdin=subprocess.DEVNULL,timeout=60)
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(work/(label+'.'+k)).write_bytes(v)
 return r
expect={**{n:'module STATIC requires a folded i64, logical, string or flat integer-array constant initializer'for n in ['nested','mixed','empty']},**{n:'whole-array, structural, multi-level, compound-cell or by-reference use'for n in ['alias','print_whole','call_arg','byref','multilevel','aadd','afill','compound','container','assign_whole']}}
for group in ['programs','negative']:
 for src in sorted((root/group).glob('*.prg')):
  for target in ['linux']+(['windows']if a.wine else[]):
   work=out/src.stem/target;work.mkdir(parents=True);(work/src.name).write_bytes(src.read_bytes());results={};builds={}
   for kind in ['harbour','hbc']:
    exe=work/(kind+('.exe'if target=='windows'else''));local=env.copy()
    if kind=='harbour':
     cmd=[hbmk2,src.name,'-gtstd','-o'+str(exe.with_suffix('')if target=='windows'else exe)]
     if target=='windows':cmd+=['-plat=win','-comp=mingw64']
     else:local.pop('HB_CCPREFIX',None)
    else:cmd=[compiler,src,str(exe)if group=='programs'else str(work/'rejected.s'),'--target='+target]
    r=run(cmd,work,kind+'-build',local);builds[kind]=r
    if group=='programs'and r.returncode==0:
     r=run(([a.wine]if target=='windows'else[])+[exe],work,kind+'-run');results[kind]=(r.returncode,r.stdout,r.stderr)
   if group=='programs':okay=len(results)==2 and results['harbour']==results['hbc']
   else:
    r=builds['hbc'];okay=r.returncode==1 and expect[src.stem].encode()in r.stderr and b'panicked'not in r.stderr
    # A duplicate is invalid Harbour; other declared limits must remain valid.
    okay=okay and ((builds['harbour'].returncode!=0)if src.stem in ['duplicate','late','branch_shadow','effectful']else builds['harbour'].returncode==0)
   row={'source':src.name,'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'target':target,'kind':group,'pass':okay,'harbour_build':builds['harbour'].returncode,'hbc_build':builds['hbc'].returncode,'diagnostic':builds['hbc'].stderr.decode(errors='replace')};rows.append(row);print(('PASS 'if okay else'FAIL ')+src.stem+' '+target,flush=True)
(out/'results.json').write_text(json.dumps({'compiler_sha256':hashlib.sha256(P(compiler).read_bytes()).hexdigest(),'rows':rows},indent=2)+'\n');assert all(r['pass']for r in rows),'see evidence'
