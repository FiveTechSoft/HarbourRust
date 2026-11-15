#!/usr/bin/env python3
import argparse,pathlib,subprocess,json,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--wine');p.add_argument('--wine-prefix');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=a.wine_prefix
r=a.output;rows=[]
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
# Print only scalars so all byte values including NUL stay exact and no GT wrapping.
lines=['function Main()','local s:=""','local n:=0','local b:=0','local other:=0','for b:=0 to 255','other:=b+1','if other==256','other:=0','endif']
for length in [0,1,15,16,17,31,32,33,65]:
 lines += [f's:=Replicate(Chr(other),{length})','? At(Chr(b),s)','? At(Chr(b),s+Chr(b))','? At(Chr(b),Chr(b)+s)']
lines+=['next']
lines+=['? At("","abc"),At("a",""),At("ab","ababa"),At("ba","ababa"),At("abc","ab")','return nil'];src=r/'all.prg';src.write_text('\n'.join(lines)+'\n')
hb=r/'oracle';q=run([a.hbmk2,src,'-quiet','-gtstd','-o'+str(hb)]);assert q.returncode==0,q.stderr;q=run([hb]);hb.unlink();assert(q.returncode,q.stderr)==(0,b'');expected=q.stdout;(r/'oracle.stdout').write_bytes(expected)
for target in ['linux','windows','macho']:
 for inst in [False,True]:
  label=target+'-'+str(inst);exe=r/label;q=run([a.compiler,src,exe,'--target='+target]+(['--instrument'] if inst else []));assert q.returncode==0,(label,q.stderr)
  if target!='macho' and (target!='windows' or a.wine):
   q=run([a.wine,exe] if target=='windows' else [exe]);(r/(label+'.stdout')).write_bytes(q.stdout);assert(q.returncode,q.stdout,q.stderr)==(0,expected,b''),(label,q.returncode,q.stderr);status='exact run'
  else:status='emission only'
  exe.unlink();rows.append({'case':label,'status':status,'byte_length_cases':256*9*3})
root=pathlib.Path(__file__).resolve().parent
src=root/'retained.prg';hb=r/'retained-hb';q=run([a.hbmk2,src,'-quiet','-gtstd','-o'+str(hb)]);assert q.returncode==0,q.stderr;q=run([hb]);hb.unlink();assert(q.returncode,q.stderr)==(0,b'');want=q.stdout;(r/'retained.oracle').write_bytes(want)
for memory in [False,True]:
 for target in ['linux']+(['windows'] if a.wine else []):
  for inst in [False,True]:
   label='retained-'+str(memory)+'-'+target+str(inst);exe=r/label;src=root/('retained-memory.prg' if memory else 'retained.prg');q=run([a.compiler,src,exe,'--target='+target]+(['--instrument'] if inst else []));assert q.returncode==0,q.stderr;q=run([a.wine,exe] if target=='windows' else [exe]);exe.unlink();(r/(label+'.stdout')).write_bytes(q.stdout);assert(q.returncode,q.stdout,q.stderr)==(0,want+(b'\n         0' if memory else b''),b''),(label,q.returncode,q.stdout,q.stderr);rows.append({'case':label,'status':'retained needle/multi/empty registry0' if memory else 'retained needle/multi/empty exact'})
(r/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(len(rows),'configs PASS',256*9*3,'all-byte/length outputs each')
