from pathlib import Path
import argparse,subprocess,os,json,hashlib
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','spec-root','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[2];here=Path(__file__).parent;out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
def run(cmd,w,t,env=None):
 cmd=list(map(str,cmd));en=dict(os.environ,TZ='UTC');en.update(env or {});z=subprocess.run(cmd,cwd=root,capture_output=True,timeout=30,env=en)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(root),env={k:v for k,v in en.items()if k in ['TZ','LD_PRELOAD','TONE_LOG']}))+'\n');return z
z=run(['gcc','-shared','-fPIC','-O2',here/'fakeclock.c','-o',out/'fakeclock.so'],out,'fake-build');assert z.returncode==0
sources={'original':(Path(a.spec_root)/'tests/sound.prg').read_text()}
for ticks in ['0','0.01','0.0182','0.36','0.364','0.36401','0.728','0.91','1','1.5','2','9.099','9.1','9.101','10','20']:
 sources['ticks-'+ticks]='PROCEDURE Main()\nTone(440,'+ticks+')\n? Tone(880,0),Seconds()\nRETURN\n'
sources['repeat']='PROCEDURE Main()\nTone(440,9.1)\nTone(880,9.1)\nTone(440,9.1)\n? Tone(0,0),Seconds()\nRETURN\n'
for name,source in sources.items():
 w=out/name;w.mkdir();src=w/'input.prg';src.write_text(source);(w/'input.sha256').write_text(hashlib.sha256(src.read_bytes()).hexdigest()+'\n');z=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert z.returncode==0,(name,z.stderr);want=run([w/'oracle'],w,'oracle-run',dict(LD_PRELOAD=str(out/'fakeclock.so'),TONE_LOG=str(w/'oracle-clock.log')));assert want.returncode==0 and not want.stderr
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  asm=w/(mode+'.s');z=run([cc,src,asm,*flags],w,mode+'-emit');assert z.returncode==0,(name,mode,z.stderr)
  fake=(here/'fake-syscall.s').read_text().split('hbc_panic_exit:')[0];checked=w/(mode+'-checked.s');checked.write_text(asm.read_text().replace('    syscall\n','    call fake_syscall\n')+'\n'+fake);z=run(['as','--64','-o',w/(mode+'.o'),checked],w,mode+'-as');assert z.returncode==0,z.stderr;z=run(['ld','-s','-o',w/mode,w/(mode+'.o')],w,mode+'-ld');assert z.returncode==0,z.stderr;got=run([w/mode],w,mode+'-run');assert(got.returncode,got.stdout,got.stderr)==(want.returncode,want.stdout,want.stderr),(name,mode,got.stdout,want.stdout,got.stderr);rows.append(dict(case=name,mode=mode,exact=True,controlled=True));(w/mode).unlink()
 (w/'oracle').unlink()
(out/'fakeclock.so').unlink();(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows,scope='Controlled both monotonic/realtime and 20ms select snapshots,UTC. Not live timestamp parity or audio pitch.'),indent=2)+'\n');print('PASS',len(rows))
