from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output','spec-root']:p.add_argument('--'+n,required=True)
a=p.parse_args();r=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir();src=Path(a.spec_root)/'tests/diskspac.prg';(out/'input.prg').write_bytes(src.read_bytes());rows=[];cc=str(Path(a.compiler).resolve());eng=[]
def run(cmd,w,t,exe=None):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=r,executable=exe,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(r),executable=exe))+'\n');return z
# Build on disk, not tmpfs whose stable values are under test.
for mode,flags in [('oracle',[]),('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
 w=out/mode;w.mkdir();exe=w/'exe';cmd=[a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(exe)]if mode=='oracle'else[cc,src,exe,'-I',str(Path(a.spec_root)/'include'),*flags];z=run(cmd,w,'build');assert z.returncode==0,z.stderr;eng.append((mode,w,exe))
for j,args in enumerate([[],[''],['/dev/shm'],['/definitely/not/present']]):
 want=None
 for mode,w,exe in eng:
  z=run(['/dev/shm/same',*args],w,'run-'+str(j),str(exe));got=(z.returncode,z.stdout,z.stderr)
  if want is None:want=got
  assert got==want==(0,want[1],b''),(mode,args,want,got);rows.append(dict(mode=mode,args=args,exact=True,stable_tmpfs=True))
for _,_,exe in eng:exe.unlink()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),rows=rows,scope='Intact source actual syscall, fixed same argv0 for honest DirBase equivalence; stable tmpfs or missing path only. Not arbitrary changing disk exactness.'),indent=2)+'\n');print('PASS original stable',len(rows))
