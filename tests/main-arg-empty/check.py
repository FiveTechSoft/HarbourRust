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
cases=[[],[''],[' '],['\t\r\n'],['x'],['0'],['','x'],['é',' ']]
for src in sorted(Path(__file__).parent.glob('*.prg')):
 w=out/src.stem;w.mkdir();(w/'input.prg').write_bytes(src.read_bytes());(w/'input.sha256').write_text(hashlib.sha256(src.read_bytes()).hexdigest()+'\n')
 if src.stem.startswith('limit-'):
  z=run([cc,src,w/'bad'],w,'reject');assert z.returncode==1 and (b'Empty' in z.stderr or b'sharing analysis' in z.stderr) and not(w/'bad').exists(),z.stderr;rows.append(dict(source=src.name,kind='named-limit'));continue
 z=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert z.returncode==0,z.stderr
 for name,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  z=run([cc,src,w/name,'--instrument',*flags],w,name+'-build');assert z.returncode==0,z.stderr
  for i,args in enumerate(cases):
   want=run([w/'oracle',*args],w,'oracle-'+str(i)+'-'+name);got=run([w/name,*args],w,name+'-'+str(i));assert(want.returncode,want.stdout,want.stderr)==(got.returncode,got.stdout,got.stderr)==(0,want.stdout,b''),(src,name,args);rows.append(dict(source=src.name,mode=name,args=args,exact=True))
  (w/name).unlink()
 (w/'oracle').unlink()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows))
