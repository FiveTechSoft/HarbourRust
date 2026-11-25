#!/usr/bin/env python3
from pathlib import Path
import argparse,subprocess,json,hashlib,sys
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output','spec-root']:p.add_argument('--'+n,required=True)
a=p.parse_args();r=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
def run(cmd,w,tag):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=r,capture_output=True,stdin=subprocess.DEVNULL,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(tag+'.'+k)).write_bytes(b)
 (w/(tag+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(r)),indent=2)+'\n');return z
sys.path.insert(0,str(r/'tests/trycatch-linux'));from memdelta_guard import DELTA_GUARD,classify_memdelta
cases=[[]]
for src in sorted(Path(__file__).parent.glob('*.prg')):
 w=out/src.stem;w.mkdir();(w/'input.prg').write_bytes(src.read_bytes());(w/'input.sha256').write_text(hashlib.sha256(src.read_bytes()).hexdigest()+'\n')
 if src.stem.startswith('limit-'):
  z=run([cc,src,w/'bad'],w,'reject');assert z.returncode==1 and (b'`for` bounds must be integers' in z.stderr or b'type mismatch' in z.stderr) and not(w/'bad').exists(),z.stderr;rows.append(dict(source=src.name,kind='named-limit'));continue
 z=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert z.returncode==0,z.stderr
 for name,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  z=run([cc,src,w/name,'--instrument',*flags],w,name+'-build');assert z.returncode==0,z.stderr
  for i,args in enumerate(cases):
   want=run([w/'oracle',*args],w,'oracle-'+str(i)+'-'+name);got=run([w/name,*args],w,name+'-'+str(i));assert(want.returncode,want.stdout,want.stderr)==(got.returncode,got.stdout,got.stderr)==(0,want.stdout,b''),(src,name,args);rows.append(dict(source=src.name,mode=name,args=args,exact=True))
  (w/name).unlink()
 d=w/'delta';d.mkdir();asm=d/'checked.s';z=run([cc,src,asm,'--instrument','--no-prune'],d,'emit');assert z.returncode==0,z.stderr
 text=asm.read_text();anchor='    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n';assert text.count(anchor)==1
 if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor)+200]:anchor+='    call hbc_arena_flush\n'
 asm.write_text(text.replace(anchor,anchor+DELTA_GUARD))
 z=run(['as','--64','-o',d/'checked.o',asm],d,'as');assert z.returncode==0,z.stderr
 z=run(['ld','-s','-o',d/'checked',d/'checked.o'],d,'ld');assert z.returncode==0,z.stderr
 for i,args in enumerate(cases):
  want=run([w/'oracle',*args],w,'oracle-delta-'+str(i));got=run([d/'checked',*args],d,'run-'+str(i));bal=classify_memdelta(got.returncode,got.stderr,got.stdout,want.stdout);assert bal['state_ok']and bal['delta']==0,(src,args,bal);rows.append(dict(source=src.name,kind='strict-final-balance',args=args,**bal))
 (d/'checked').unlink()
 (w/'oracle').unlink()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows))
