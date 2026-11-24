#!/usr/bin/env python3
"""Own MIT intact upstream examples with explicit deterministic input."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output','spec-root']:p.add_argument('--'+n,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(Path(a.compiler).resolve());spec=Path(a.spec_root).resolve()
sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import DELTA_GUARD
sources=[spec/'tests'/n for n in ['base2.prg','for2.prg','longstr.prg']]
for s in [*sources,spec/'include/simpleio.ch']:
 if not s.is_file():p.error('required upstream source/include missing: '+str(s))
rows=[]
def run(cmd,w,label,data=b''):
 r=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=30,input=data)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
for src in sources:
 w=out/src.stem;w.mkdir();(w/src.name).write_bytes(src.read_bytes());data={'base2':b'\n','for2':b'\n\n','longstr':b''}[src.stem];(w/'stdin.bin').write_bytes(data)
 include=['-I',str(spec/'include')]
 r=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert r.returncode==0,(src,r.stderr)
 r=run([w/'oracle'],w,'oracle-run',data);assert r.returncode==0 and r.stderr==b'',(src,r.returncode,r.stderr);want=r.stdout;(w/'oracle').unlink()
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  r=run([cc,src,w/mode,'--instrument',*include,*flags],w,mode+'-build');assert r.returncode==0,(src,r.stderr)
  r=run([w/mode],w,mode+'-run',data);assert (r.returncode,r.stdout,r.stderr)==(0,want,b''),(src,mode,r.returncode,r.stdout,want,r.stderr);(w/mode).unlink();rows.append(dict(name=src.name,kind='original-exact-Harbour',mode=mode,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest()))
 d=w/'delta';d.mkdir();asm=d/'checked.s';r=run([cc,src,asm,'--instrument','--no-prune',*include],d,'emit');assert r.returncode==0,r.stderr
 text=asm.read_text();anchor='    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n';assert text.count(anchor)==1
 if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor)+200]:anchor+='    call hbc_arena_flush\n'
 asm.write_text(text.replace(anchor,anchor+DELTA_GUARD.replace('    je .Lprobe_zero\n','')))
 r=run(['as','--64','-o',d/'checked.o',asm],d,'as');assert r.returncode==0,r.stderr
 r=run(['ld','-s','-o',d/'checked',d/'checked.o'],d,'ld');assert r.returncode==0,r.stderr
 r=run([d/'checked'],d,'memdelta',data);assert (r.returncode,r.stdout,r.stderr)==(99,want,b'DELTA=0\n'),(src,r.returncode,r.stderr)
 rows.append(dict(name=src.name,kind='strict-final-balance',delta=0,rc=99,marker='DELTA=0',source_sha256=hashlib.sha256(src.read_bytes()).hexdigest()))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),simpleio_sha256=hashlib.sha256((spec/'include/simpleio.ch').read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS original exact=15 strict-zero=3; rows',len(rows))
