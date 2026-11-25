from pathlib import Path
import argparse,subprocess,json,hashlib,os,time
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','spec-root','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();r=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
def run(cmd,w,tag,env=None):
 cmd=list(map(str,cmd));lo=time.time_ns()//1000000;z=subprocess.run(cmd,cwd=r,capture_output=True,env=env,timeout=20);hi=time.time_ns()//1000000
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(tag+'.'+k)).write_bytes(b)
 (w/(tag+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(r),before_ms=lo,after_ms=hi,TZ=(env or {}).get('TZ')))+'\n');return z,lo,hi
for n in ['basic','ticktime']:
 src=Path(__file__).with_name('basic.prg')if n=='basic'else Path(a.spec_root)/'tests/ticktime.prg';w=out/n;w.mkdir();(w/'input.prg').write_bytes(src.read_bytes());(w/'input.sha256').write_text(hashlib.sha256(src.read_bytes()).hexdigest()+'\n')
 modes=[('native',[]),('oracle',[])]if n=='ticktime'else[('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune']),('oracle',[])]
 for mode,flags in modes:
  exe=w/mode;cmd=[a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(exe)]if mode=='oracle'else[cc,src,exe,*flags];z,_,_=run(cmd,w,mode+'-build');assert z.returncode==0,z.stderr
  for tz in (['UTC']if n=='ticktime'else['UTC','Europe/Madrid','America/New_York','Asia/Kolkata','Pacific/Kiritimati']):
   z,lo,hi=run([exe],w,mode+'-'+tz.replace('/','_'),dict(os.environ,TZ=tz));assert z.returncode==0 and not z.stderr,(n,mode,z.stdout,z.stderr)
   if n=='basic':
    tok=z.stdout.split();v=int(tok[1]);v2=int(tok[3]);assert tok[0]==b'N'and tok[2]==b'.T.'and tok[-1]==b'.T.'and lo+210866803200000<=v<=v2<=hi+210866803200000
   else:assert b'Wait for 10 seconds...'in z.stdout and b'Ticks per second:'in z.stdout and b'Loops per tick:'in z.stdout and 9950<=hi-lo<=18000
   rows.append(dict(source=n,mode=mode,TZ=tz,pass_=True,live_clock_not_exact=True))
  exe.unlink()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows,scope='Real clock bracketing/shape only, not byte exact independent timings. Intact ticktime native and fresh Harbour each10seconds.'),indent=2)+'\n');print('PASS live',len(rows))
