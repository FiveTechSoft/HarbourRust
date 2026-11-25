#!/usr/bin/env python3
"""Own MIT intact encoding/date/init original current replay gate with fresh Harbour oracle."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);p.add_argument('--spec-root',required=True);a=p.parse_args();root=Path(__file__).resolve().parents[2];here=Path(__file__).resolve().parent;out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(Path(a.compiler).resolve());sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import DELTA_GUARD,classify_memdelta

def emit_delta(compiler,env,src,d,want):
 asm=d/'checked.s'
 def runit(cmd,label):
  z=subprocess.run(list(map(str,cmd)),cwd=d,capture_output=True,stdin=subprocess.DEVNULL,timeout=60,env=env)
  for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(d/(label+'.'+k)).write_bytes(b)
  (d/(label+'.command.json')).write_text(json.dumps(dict(argv=list(map(str,cmd)),cwd=str(d))))
  return z
 z=runit([compiler,src,asm,'--instrument','--no-prune','-I',str(Path(a.spec_root)/'include')],'emit');assert z.returncode==0,z.stderr
 text=asm.read_text();anchor='    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n';assert text.count(anchor)==1
 if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor)+200]:anchor+='    call hbc_arena_flush\n'
 asm.write_text(text.replace(anchor,anchor+DELTA_GUARD))
 for cmd,label in [(['as','--64','-o',d/'checked.o',asm],'as'),(['ld','-s','-o',d/'checked',d/'checked.o'],'ld')]:
  z=runit(cmd,label);assert z.returncode==0,z.stderr
 z=runit([d/'checked'],'memdelta');return classify_memdelta(z.returncode,z.stderr,z.stdout,want)

rows=[]
(out/'oracle.sha256').write_text(hashlib.sha256(Path(a.hbmk2).read_bytes()).hexdigest()+'  hbmk2\n')
def run(cmd,w,label):
 (w/(label+'.command.json')).write_text(json.dumps(dict(argv=list(map(str,cmd)),cwd=str(root)),indent=2)+'\n')
 r=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=60,stdin=subprocess.DEVNULL)
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return r
for src in [Path(a.spec_root)/'tests'/n for n in ['base64.prg','sha1.prg','dates2.prg','initproc.prg']]:
 w=out/src.stem;w.mkdir();(w/src.name).write_bytes(src.read_bytes());(w/'input.sha256').write_text(hashlib.sha256(src.read_bytes()).hexdigest()+'  '+src.name+'\n')
 if src.stem.startswith('limit-'):
  r=run([cc,src,w/'limit'],w,'build');assert r.returncode==1 and any(t in r.stderr.lower()for t in [b'codeblock',b'for step',b'getter']) and not (w/'limit').exists(),(src,r.stderr);rows.append(dict(name=src.stem,kind='named-rejection'));continue
 r=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert r.returncode==0,(src,r.stderr)
 r=run([w/'oracle'],w,'oracle-run');assert r.returncode==0 and r.stderr==b'',(src,r.stderr);want=r.stdout;(w/'oracle').unlink()
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  r=run([cc,src,w/mode,'--instrument','-I',str(Path(a.spec_root)/'include'),*flags],w,mode+'-build');assert r.returncode==0,(src,r.stderr)
  r=run([w/mode],w,mode+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,want,b''),(src,r.returncode,r.stdout,want,r.stderr);(w/mode).unlink();rows.append(dict(name=src.stem,kind='exact-Harbour',mode=mode))
 d=w/'delta';d.mkdir();bal=emit_delta(cc,os.environ,src,d,want);assert bal['state_ok'] and bal['delta']==0,(src,bal);rows.append(dict(name=src.stem,kind='strict-final-balance',source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),**bal))
 for target in []:
  r=run([cc,src,w/(target+'.s'),*(['--experimental-llvm'] if target=='llvm' else ['--target='+target])],w,target);assert r.returncode==1,(src,target,r.stderr);rows.append(dict(name=src.stem,kind='profile-rejection',target=target))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows))
