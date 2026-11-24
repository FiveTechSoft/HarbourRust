#!/usr/bin/env python3
"""Own MIT original filesystem/input gate, isolated effects and exact output."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib,shutil,os,stat
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output','spec-root']:p.add_argument('--'+n,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(Path(a.compiler).resolve());spec=Path(a.spec_root).resolve()
sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import DELTA_GUARD
sources=[spec/'tests'/n for n in ['fileio.prg','fileio2.prg','flink.prg','libname.prg','curdirt.prg','cursor.prg']]
for s in [*sources,spec/'include/simpleio.ch']:
 if not s.is_file():p.error('required upstream source/include missing: '+str(s))
rows=[]
def run(cmd,w,label,cwd=None,data=b''):
 r=subprocess.run(list(map(str,cmd)),cwd=cwd or root,capture_output=True,timeout=30,input=data)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
def snapshot(d):
 result={};inodes={}
 for p in sorted(d.rglob('*')):
  name=str(p.relative_to(d));s=p.lstat()
  if stat.S_ISLNK(s.st_mode):result[name]={'kind':'symlink','target':os.readlink(p)}
  elif p.is_dir():result[name]={'kind':'directory'}
  elif p.is_file():
   data=p.read_bytes();group=inodes.setdefault((s.st_dev,s.st_ino),name);result[name]={'kind':'file','bytes':len(data),'hex':data.hex(),'hardlink_group':group}
  else:raise AssertionError(('unexpected filesystem item',p))
 return result
for src in sources:
 w=out/src.stem;w.mkdir();(w/src.name).write_bytes(src.read_bytes());data=b'\n'*5 if src.stem=='cursor' else b'';(w/'stdin.bin').write_bytes(data);include=['-I',str(spec/'include')];sandbox=w/'execution-cwd'
 def execute(exe,label):
  if sandbox.exists():shutil.rmtree(sandbox)
  sandbox.mkdir();r=run([exe],w,label,cwd=sandbox,data=data);effects=snapshot(sandbox);(w/(label+'.effects.json')).write_text(json.dumps(effects,indent=2)+'\n');return r,effects
 r=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert r.returncode==0,(src,r.stderr)
 r,effects=execute(w/'oracle','oracle-run');assert r.returncode==0 and r.stderr==b'',(src,r.returncode,r.stderr);want=r.stdout;(w/'oracle').unlink()
 if src.stem in ['fileio','fileio2']:assert effects['test.txt']['hex']==b'This test worked if you can see this'.hex(),effects
 if src.stem=='flink':
  assert effects['_hb_h.tmp']['hardlink_group']==effects['_hb_hlnk.tmp']['hardlink_group'],effects
  assert effects['_hb_slnk.tmp']=={'kind':'symlink','target':'_hb_s.tmp'},effects
  assert effects['_hb_dlnk']=={'kind':'symlink','target':'_hb_d'},effects
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  r=run([cc,src,w/mode,'--instrument',*include,*flags],w,mode+'-build');assert r.returncode==0,(src,r.stderr)
  r,got=execute(w/mode,mode+'-run');assert (r.returncode,r.stdout,r.stderr,got)==(0,want,b'',effects),(src,mode,r.returncode,r.stderr,got,effects);(w/mode).unlink();rows.append(dict(name=src.name,kind='original-exact-output-and-effects',mode=mode,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest()))
 d=w/'delta';d.mkdir();asm=d/'checked.s';r=run([cc,src,asm,'--instrument','--no-prune',*include],d,'emit');assert r.returncode==0,r.stderr
 text=asm.read_text();anchor='    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n';assert text.count(anchor)==1
 if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor)+200]:anchor+='    call hbc_arena_flush\n'
 asm.write_text(text.replace(anchor,anchor+DELTA_GUARD.replace('    je .Lprobe_zero\n','').replace('    mov $60, %eax\n    mov $99, %edi\n    syscall\n','')))
 r=run(['as','--64','-o',d/'checked.o',asm],d,'as');assert r.returncode==0,r.stderr
 r=run(['ld','-s','-o',d/'checked',d/'checked.o'],d,'ld');assert r.returncode==0,r.stderr
 r,got=execute(d/'checked','memdelta');assert (r.returncode,r.stdout,r.stderr,got)==(0,want,b'DELTA=0\n',effects),(src,r.returncode,r.stderr)
 rows.append(dict(name=src.name,kind='strict-final-balance-and-effects',delta=0,rc=0,marker='DELTA=0',source_sha256=hashlib.sha256(src.read_bytes()).hexdigest()))
 shutil.rmtree(sandbox)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),simpleio_sha256=hashlib.sha256((spec/'include/simpleio.ch').read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS original exact-output-and-effects=30 strict-zero=6; rows',len(rows))
