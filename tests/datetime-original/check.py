#!/usr/bin/env python3
"""Own MIT bounded original date-management gate with fresh Harbour oracle."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);p.add_argument('--spec-root',required=True);a=p.parse_args();root=Path(__file__).resolve().parents[2];here=Path(__file__).resolve().parent;out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(Path(a.compiler).resolve());sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import emit_delta
rows=[]
def run(cmd,w,label):
 cmd=list(map(str,cmd))
 if cmd[0]==cc:cmd+=['-I',str(Path(a.spec_root)/'include')]
 r=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=60,stdin=subprocess.DEVNULL)
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return r
for src in [*sorted(here.glob('*.prg')),Path(a.spec_root)/'tests/datetime.prg']:
 w=out/src.stem;w.mkdir()
 if src.stem.startswith('limit-'):
  r=run([cc,src,w/'limit'],w,'build');assert r.returncode==1 and not (w/'limit').exists(),(src,r.stderr);rows.append(dict(name=src.stem,kind='named-rejection'));continue
 r=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert r.returncode==0,(src,r.stderr)
 r=run([w/'oracle'],w,'oracle-run');assert r.returncode==0 and r.stderr==b'',(src,r.stderr);want=r.stdout;(w/'oracle').unlink()
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  r=run([cc,src,w/mode,'--instrument',*flags],w,mode+'-build');assert r.returncode==0,(src,r.stderr)
  r=run([w/mode],w,mode+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,want,b''),(src,r.returncode,r.stdout,want,r.stderr);(w/mode).unlink();rows.append(dict(name=src.stem,kind='exact-Harbour',mode=mode))
 d=w/'delta';d.mkdir()
 wrapper=out/'compiler-with-include';wrapper.write_text('#!/usr/bin/env python3\nimport os,sys\nos.execv('+repr(cc)+',['+repr(cc)+']+sys.argv[1:]+["-I",'+repr(str(Path(a.spec_root)/'include'))+'])\n');wrapper.chmod(0o755)
 bal=emit_delta(str(wrapper),os.environ,src,d,want);assert bal['state_ok'] and bal['delta']==0,(src,bal);rows.append(dict(name=src.stem,kind='strict-final-balance',source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),**bal))
 for target in ['windows','macho','macho-arm64']:
  r=run([cc,src,w/(target+'.s'),'--target='+target],w,target);assert r.returncode==1,(src,target,r.stderr);rows.append(dict(name=src.stem,kind='profile-rejection',target=target))
# Current time is inherently live: compare parsed local timestamp against
# host-clock brackets, not a static or concurrently sampled oracle string.
import datetime,time,zoneinfo
src=out/'now.prg';src.write_bytes((here/'now-source.txt').read_bytes())
for zone in ['UTC','Europe/Madrid','America/New_York','Pacific/Kiritimati']:
 w=out/('now-'+zone.replace('/','-'));w.mkdir()
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  q=run([cc,src,w/mode,*flags],w,mode+'-build');assert q.returncode==0,q.stderr
  before=time.time();q=subprocess.run([str(w/mode)],capture_output=True,env={**os.environ,'TZ':zone});after=time.time()
  (w/(mode+'.stdout')).write_bytes(q.stdout);(w/(mode+'.stderr')).write_bytes(q.stderr)
  text=q.stdout.strip().decode();assert q.returncode==0 and not q.stderr and len(text)==17,(zone,q.returncode,q.stdout,q.stderr)
  observed=datetime.datetime.strptime(text,'%Y%m%d%H%M%S%f').replace(tzinfo=zoneinfo.ZoneInfo(zone)).timestamp()
  assert before-0.002<=observed<=after+0.002,(zone,before,observed,after)
  (w/mode).unlink();rows.append(dict(name='now',kind='live-clock-bracket',zone=zone,mode=mode,before=before,observed=observed,after=after))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows))
