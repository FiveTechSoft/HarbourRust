#!/usr/bin/env python3
"""Byte-codepage case conversion, native target differential and ownership."""
import argparse,pathlib,subprocess,json,os
p=argparse.ArgumentParser()
for x in ['compiler','hbmk2','wine','wine-prefix','output']:p.add_argument('--'+x,required=True)
a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(parents=True,exist_ok=False);env=dict(os.environ,WINEDEBUG='-all',WINEPREFIX=a.wine_prefix)
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=45)
lines=['function Main()','local b:=0','local s:=""','for b:=0 to 255']
for n in [0,1,2,15,16,17,31,32,33,63,64,65]:
 lines += [f's:=Replicate(Chr(b),{n})', '? Len(Upper(s)),Len(Lower(s)),Upper(s)==s,Lower(s)==s']
 if n:lines+=['? Asc(Upper(s)),Asc(Lower(s)),Asc(Right(Upper(s),1)),Asc(Right(Lower(s),1))']
lines+=['next','return nil'];src=r/'all.prg';src.write_text('\n'.join(lines)+'\n');hb=r/'oracle';q=run([a.hbmk2,src,'-quiet','-gtstd','-o'+str(hb)]);assert q.returncode==0,q.stderr;q=run([hb]);hb.unlink();assert(q.returncode,q.stderr)==(0,b'');want=q.stdout;(r/'oracle.stdout').write_bytes(want);rows=[]
for target in ['linux','windows','macho']:
 for inst in [False,True]:
  label=target+str(inst);exe=r/label;q=run([a.compiler,src,exe,'--target='+target]+(['--instrument'] if inst else []));assert q.returncode==0,(label,q.stderr)
  if target!='macho':
   q=run([a.wine,exe] if target=='windows' else [exe]);(r/(label+'.stdout')).write_bytes(q.stdout);assert(q.returncode,q.stdout,q.stderr)==(0,want,b''),(label,q.returncode,q.stderr)
  exe.unlink();rows.append(dict(target=target,instrument=inst,status='emission only' if target=='macho' else 'byte-exact fresh Harbour',byte_length_pairs=256*12*2))
root=pathlib.Path(__file__).resolve().parent
src=root/'retained.prg';hb=r/'retained-oracle';q=run([a.hbmk2,src,'-quiet','-gtstd','-o'+str(hb)]);assert q.returncode==0,q.stderr;q=run([hb]);hb.unlink();assert(q.returncode,q.stderr)==(0,b'');want=q.stdout;(r/'retained.oracle').write_bytes(want)
for memory in [False,True]:
 src=r/('retained'+str(memory)+'.prg');text=(root/'retained.prg').read_text()
 if memory:text=text.replace('Work()\nreturn nil\n','Work()\n? hb_memcheck()\nreturn nil\n')
 src.write_text(text)
 for target in ['linux','windows','macho']:
  for inst in [False,True]:
   label='retained-'+str(memory)+'-'+target+str(inst);exe=r/label;q=run([a.compiler,src,exe,'--target='+target]+(['--instrument'] if inst else []));assert q.returncode==0,(label,q.stderr)
   if target!='macho':
    q=run([a.wine,exe] if target=='windows' else [exe]);(r/(label+'.stdout')).write_bytes(q.stdout);assert(q.returncode,q.stdout,q.stderr)==(0,want+(b'\n         0' if memory else b''),b''),(label,q.returncode,q.stdout,q.stderr)
   exe.unlink();rows.append(dict(case=label,status='emission only' if target=='macho' else 'exact retained oracle + registry0' if memory else 'exact retained oracle'))
(r/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('18 configs PASS,6144 byte/length/helper pairs per all-byte config; retained/registry included')
