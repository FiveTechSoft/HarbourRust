from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();r=Path(__file__).resolve().parents[2];here=Path(__file__).parent;out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
def run(cmd,w,tag,env=None):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=r,capture_output=True,env=env,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(tag+'.'+k)).write_bytes(b)
 (w/(tag+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(r),clock_env={k:v for k,v in (env or {}).items()if k in ['LD_PRELOAD','HB_TEST_NS','TZ']}),indent=2)+'\n');return z
src=out/'input.prg';src.write_bytes((here/'basic.prg').read_bytes());(out/'input.sha256').write_text(hashlib.sha256(src.read_bytes()).hexdigest()+'\n')
z=run(['gcc','-shared','-fPIC','-O2',here/'fakeclock.c','-o',out/'fakeclock.so'],out,'fake-build');assert z.returncode==0,z.stderr
z=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(out/'oracle')],out,'oracle-build');assert z.returncode==0,z.stderr
stamps=[0,1,999999,1000000,123999999,999999999,1000000000,86400000000000,951782400123456789,1795613599987654321,2147483647999999999,4102444799123456789]
for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
 w=out/mode;w.mkdir();asm=w/'base.s';z=run([cc,src,asm,*flags],w,'emit');assert z.returncode==0,z.stderr
 text=asm.read_text();lo=text.index('hbc_milliseconds:');hi=text.index('.Lmilliseconds_fail:',lo);assert text[lo:hi].count('    syscall\n')==1;text=text[:lo]+text[lo:hi].replace('    syscall\n','    call fake_milliseconds_clock\n')+text[hi:]
 for j,ns in enumerate(stamps):
  d=w/str(j);d.mkdir();s=d/'checked.s';s.write_text(text+(here/'fakeclock.s').read_text().replace('HB_SEC',str(ns//1000000000)).replace('HB_NSEC',str(ns%1000000000)))
  z=run(['as','--64','-o',d/'checked.o',s],d,'as');assert z.returncode==0,z.stderr
  z=run(['ld','-s','-o',d/'checked',d/'checked.o'],d,'ld');assert z.returncode==0,z.stderr
  for tz in ['UTC','Europe/Madrid','America/New_York']:
   tag=tz.replace('/','_');env=dict(os.environ,LD_PRELOAD=str(out/'fakeclock.so'),HB_TEST_NS=str(ns),TZ=tz);want=run([out/'oracle'],d,'oracle-'+tag,env);got=run([d/'checked'],d,'run-'+tag)
   assert(want.returncode,want.stdout,want.stderr)==(got.returncode,got.stdout,got.stderr)==(0,want.stdout,b''),(mode,ns,tz,want.stdout,got.stdout,got.stderr);rows.append(dict(mode=mode,ns=ns,TZ=tz,exact=True,clock_injected=True))
  (d/'checked').unlink()
(out/'oracle').unlink();(out/'fakeclock.so').unlink();(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows,scope='Controlled realtime, Harbour interposed libc time functions; native only milliseconds helper syscall replaced with fixed timespec writer. Format/type/delta triples exact, not live clock byte-parity.'),indent=2)+'\n');print('PASS controlled-clock exact',len(rows))
