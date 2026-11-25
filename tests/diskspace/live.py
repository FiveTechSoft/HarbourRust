from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();out=Path(a.output).resolve();out.mkdir();r=Path(__file__).resolve().parents[2];cc=str(Path(a.compiler).resolve());rows=[]
def run(cmd,w,t):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=r,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(r)))+'\n');return z
for ix,path in enumerate(['/dev/shm','/definitely/not/a/directory','/dev/shm/no-such-file','']):
 w=out/str(ix);w.mkdir();src=w/'input.prg';src.write_text('procedure Main()\nlocal c:="'+path+'"\n? hb_DiskSpace(c,0),hb_DiskSpace(c,1),hb_DiskSpace(c,2),hb_DiskSpace(c,3)\nreturn\n')
 want=None
 for mode,flags in [('oracle',[]),('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  cmd=[a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/mode)]if mode=='oracle'else[cc,src,w/mode,*flags];z=run(cmd,w,mode+'-build');assert z.returncode==0,z.stderr
  z=run([w/mode],w,mode+'-run');got=(z.returncode,z.stdout,z.stderr)
  if want is None:want=got
  assert got==want==(0,want[1],b''),(path,mode,got,want);rows.append(dict(path=path,mode=mode,exact=True,scope='stable tmpfs or failure path, not arbitrary changing disk'));(w/mode).unlink()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS stable live',len(rows))
