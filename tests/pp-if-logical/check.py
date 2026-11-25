#!/usr/bin/env python3
"""Own MIT: exact fresh Harbour vs native, with lexical rejection controls."""
from pathlib import Path
import subprocess,argparse,json,hashlib,os,sys
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();r=Path(__file__).resolve().parents[2];d=Path(a.output).resolve();d.mkdir();cc=str(Path(a.compiler).resolve());env=dict(os.environ);rows=[]
def run(cmd,w,label):
 cmd=list(map(str,cmd));p=subprocess.run(cmd,cwd=w,env=env,capture_output=True,timeout=60)
 for ext,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(b)
 (w/(label+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(w),rc=p.returncode),indent=2)+'\n');return p
sources=sorted(Path(__file__).parent.glob('*.prg'))
for src in sources:
 w=d/src.stem;w.mkdir();copy=w/'input.prg';copy.write_bytes(src.read_bytes());(w/'input.sha256').write_text(hashlib.sha256(copy.read_bytes()).hexdigest()+'  input.prg\n')
 z=run([a.hbmk2,copy,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert z.returncode==0,z.stderr
 z=run([w/'oracle'],w,'oracle-run');assert z.returncode==0 and not z.stderr;want=z.stdout;(w/'oracle').unlink()
 for name,flags in [('native',[])]:
  if name=='native':
   exe=w/name;z=run([cc,copy,exe],w,name+'-build');assert z.returncode==0,z.stderr
  z=run([exe],w,name+'-run');rows.append(dict(source=src.name,mode=name,exact=(z.returncode,z.stdout,z.stderr)==(0,want,b'')));exe.unlink()
for name,expr in [('and','.F..AND.(1/0)'),('or','.T..OR.(1/0)'),('left','(1/0).AND..F.')]:
 w=d/name;w.mkdir();src=w/'input.prg';src.write_text('FUNCTION Main()\n#if '+expr+'\n? 1\n#endif\nRETURN NIL\n')
 z=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert z.returncode!=0
 for target in ['linux','windows']:
  dest=w/target;dest.write_bytes(b'OLD');z=run([cc,src,dest,'--target='+target],w,target)
  assert z.returncode==1 and dest.read_bytes()==b'OLD' and b'division by zero in #if' in z.stderr
  rows.append(dict(source=name,mode=target,kind='lexical-rejection',exact=False))
(d/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),hbmk2_sha256=hashlib.sha256(Path(a.hbmk2).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');assert all(x['exact']or x.get('kind')=='lexical-rejection'for x in rows);print('PASS',len(rows))
