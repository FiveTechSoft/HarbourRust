#!/usr/bin/env python3
"""Own MIT bounded static optional-block wrapper gate with fresh Harbour oracle."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);p.add_argument('--spec-root',required=True);a=p.parse_args();root=Path(__file__).resolve().parents[2];here=Path(__file__).resolve().parent;out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(Path(a.compiler).resolve());sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import emit_delta
rows=[]
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=60,stdin=subprocess.DEVNULL)
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return r
for src in [*sorted(here.glob('*.prg'))]:
 w=out/src.stem;w.mkdir()
 if src.stem.startswith('limit-'):
  r=run([cc,src,w/'limit'],w,'build');assert r.returncode==1 and not (w/'limit').exists(),(src,r.stderr);rows.append(dict(name=src.stem,kind='named-rejection'));continue
 r=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert r.returncode==0,(src,r.stderr)
 r=run([w/'oracle'],w,'oracle-run');assert r.returncode==0 and r.stderr==b'',(src,r.stderr);want=r.stdout;(w/'oracle').unlink()
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  r=run([cc,src,w/mode,'--instrument',*flags],w,mode+'-build');assert r.returncode==0,(src,r.stderr)
  r=run([w/mode],w,mode+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,want,b''),(src,r.returncode,r.stdout,want,r.stderr);(w/mode).unlink();rows.append(dict(name=src.stem,kind='exact-Harbour',mode=mode))
 d=w/'delta';d.mkdir();bal=emit_delta(cc,os.environ,src,d,want);assert bal['state_ok'] and bal['delta']==0,(src,bal);rows.append(dict(name=src.stem,kind='strict-final-balance',source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),**bal))
 for target in ['windows','macho','macho-arm64']:
  r=run([cc,src,w/(target+'.s'),'--target='+target],w,target);assert r.returncode==1,(src,target,r.stderr);rows.append(dict(name=src.stem,kind='profile-rejection',target=target))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows))
