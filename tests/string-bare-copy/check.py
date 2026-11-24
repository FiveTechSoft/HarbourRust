#!/usr/bin/env python3
"""Own MIT bounded original date-management gate with fresh Harbour oracle."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);p.add_argument('--spec-root',required=True);a=p.parse_args();root=Path(__file__).resolve().parents[2];here=Path(__file__).resolve().parent;out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(Path(a.compiler).resolve());sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import emit_delta
rows=[]
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=60,stdin=subprocess.DEVNULL)
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return r
for src in [*sorted(here.glob('*.prg')),Path(a.spec_root)/'tests/longstr2.prg']:
 w=out/src.stem;w.mkdir()
 if src.stem.startswith('limit-'):
  r=run([cc,src,w/'limit'],w,'build');assert r.returncode==1 and not (w/'limit').exists(),(src,r.stderr);rows.append(dict(name=src.stem,kind='named-rejection'));continue
 r=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert r.returncode==0,(src,r.stderr)
 r=run([w/'oracle'],w,'oracle-run');assert r.returncode==0,(src,r.stderr);want=r.stdout;want_err=r.stderr;(w/'oracle').unlink()
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  r=run([cc,src,w/mode,'--instrument',*flags],w,mode+'-build');assert r.returncode==0,(src,r.stderr)
  r=run([w/mode],w,mode+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,want,want_err),(src,r.returncode,r.stdout,want,r.stderr);(w/mode).unlink();rows.append(dict(name=src.stem,kind='exact-Harbour',mode=mode))
 d=w/'delta';d.mkdir()
 if not want_err:
  bal=emit_delta(cc,os.environ,src,d,want);assert bal['state_ok'] and bal['delta']==0,(src,bal)
 else:
  # Original writes stderr. Require its exact prefix plus an independent
  # unconditional final balance marker, rc0 and exact stdout.
  from memdelta_guard import DELTA_GUARD
  asm=d/'checked.s';q=run([cc,src,asm,'--instrument','--no-prune'],d,'emit');assert q.returncode==0,q.stderr
  text=asm.read_text();anchor='    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n';assert text.count(anchor)==1
  if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor)+200]:anchor+='    call hbc_arena_flush\n'
  guard=DELTA_GUARD.replace('    je .Lprobe_zero\n','')
  asm.write_text(text.replace(anchor,anchor+guard))
  q=run(['as','--64','-o',d/'checked.o',asm],d,'as');assert q.returncode==0,q.stderr
  q=run(['ld','-s','-o',d/'checked',d/'checked.o'],d,'ld');assert q.returncode==0,q.stderr
  q=run([d/'checked'],d,'memdelta');assert (q.returncode,q.stdout,q.stderr)==(99,want,want_err+b'DELTA=0\n'),(q.returncode,q.stderr)
  bal=dict(delta=0,state_ok=True,rc=q.returncode,stdout_match=True,stderr_prefix_match=True,marker='DELTA=0')
 rows.append(dict(name=src.stem,kind='strict-final-balance',source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),**bal))
 for target in ['windows','macho','macho-arm64']:
  r=run([cc,src,w/(target+'.s'),'--target='+target],w,target);assert r.returncode==1,(src,target,r.stderr);rows.append(dict(name=src.stem,kind='profile-rejection',target=target))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows))
