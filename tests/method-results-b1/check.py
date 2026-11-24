#!/usr/bin/env python3
"""Own MIT B1 specification and ownership gate. Harbour is an external oracle."""
import argparse,hashlib,json,os,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2];here=Path(__file__).resolve().parent;out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
cc=str(Path(a.compiler).resolve());env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import emit_delta
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=60,stdin=subprocess.DEVNULL)
 for ext,data in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(data)
 return r
for src in sorted(here.glob('*.prg')):
 w=out/src.stem;w.mkdir()
 if src.stem.startswith('limit-'):
  r=run([cc,src,w/'limit'],w,'build');assert r.returncode==1 and not (w/'limit').exists(),(src,r.stderr)
  rows.append(dict(name=src.stem,kind='named-rejection',diagnostic=r.stderr.decode()));continue
 if src.stem.startswith('runtime-'):
  exe=w/'native';r=run([cc,src,exe,'--instrument'],w,'build');assert r.returncode==0,(src,r.stderr)
  r=run([exe],w,'run');assert (r.returncode,r.stdout,r.stderr)==(0,b'\nC\nC\nC\nC\nC',b''),(src,r.returncode,r.stdout,r.stderr)
  d=w/'delta';d.mkdir();row=emit_delta(cc,env,src,d,r.stdout);assert row['state_ok'] and row['delta']==0,(src,row)
  rows.append(dict(name=src.stem,kind='own-runtime-check',**row));exe.unlink();continue
 hb=w/'oracle';r=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(hb)],w,'oracle-build');assert r.returncode==0,(src,r.stderr,r.stdout)
 r=run([hb],w,'oracle-run');assert r.returncode==0,(src,r.stderr);want=r.stdout;hb.unlink()
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis'])]:
  exe=w/mode;r=run([cc,src,exe,'--instrument',*flags],w,mode+'-build');assert r.returncode==0,(src,mode,r.stderr)
  r=run([exe],w,mode+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,want,b''),(src,mode,r.returncode,r.stdout,want,r.stderr)
  exe.unlink();rows.append(dict(name=src.stem,mode=mode,kind='exact-Harbour'))
 d=w/'delta';d.mkdir();row=emit_delta(cc,env,src,d,want);assert row['state_ok'] and row['delta']==0,(src,row)
 rows.append(dict(name=src.stem,kind='strict-final-balance',**row))
 for target in ['windows','macho','macho-arm64']:
  r=run([cc,src,w/(target+'.s'),'--target='+target],w,target);assert r.returncode==1,(src,target,r.stderr)
  rows.append(dict(name=src.stem,kind='profile-rejection',target=target))
 (out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n')
print('PASS',len(rows))

(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n')
