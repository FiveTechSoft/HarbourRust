#!/usr/bin/env python3
"""Own MIT explicitly adapted e20 semantic oracle, not raw-original equivalence."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);p.add_argument('--spec-root',required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2];here=Path(__file__).resolve().parent;out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(Path(a.compiler).resolve());sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import emit_delta
sources=list(Path(a.spec_root).glob('e20*.prg'));assert len(sources)==1
original=sources[0].read_text();start=original.index('FUNCTION Main()');exercise=original[:start]
assert exercise.count('      TRY\n')==3 and exercise.count('      CATCH\n')==3 and exercise.count('      END\n')==3
exercise=exercise.replace('      TRY\n','      BEGIN SEQUENCE\n').replace('      CATCH\n','      RECOVER\n').replace('      END\n','      END SEQUENCE\n')
# Deliberate harness boundary: identical Exercise, standard sequence spelling,
# user-installed Break error handler, no hb_memcheck call on either side. Compiler keeps TRY/CATCH spelling
# and its existing recovery behavior; only Harbour receives ErrorBlock INIT.
adapted=exercise+'''FUNCTION Main()
 LOCAL i
 FOR i:=1 TO 21
  Exercise()
 NEXT
 ? "exercise-count",i-1
RETURN NIL
INIT PROCEDURE RecoverErrors()
 ErrorBlock({|err|Break(err)})
RETURN
'''
oracle_src=out/'oracle-adapted-e20.prg';oracle_src.write_text(adapted)
src=out/'compiler-exercise-e20.prg';src.write_text(original[:start]+adapted[adapted.index('FUNCTION Main()'):adapted.index('INIT PROCEDURE')]);rows=[]
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=90,stdin=subprocess.DEVNULL)
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return r
w=out/'adapted-e20';w.mkdir()
r=run([a.hbmk2,oracle_src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert r.returncode==0,r.stderr
r=run([w/'oracle'],w,'oracle-run');assert r.returncode==0 and r.stderr==b'',(r.returncode,r.stdout,r.stderr);want=r.stdout;(w/'oracle').unlink()
for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
 r=run([cc,src,w/mode,'--instrument',*flags],w,mode+'-build');assert r.returncode==0,r.stderr
 r=run([w/mode],w,mode+'-run');assert (r.returncode,r.stdout,r.stderr)==(0,want,b''),(mode,r.returncode,r.stdout,want,r.stderr);(w/mode).unlink();rows.append(dict(kind='adapted-exact-Harbour',mode=mode))
d=w/'delta';d.mkdir();bal=emit_delta(cc,os.environ,src,d,want);assert bal['state_ok'] and bal['delta']==0,bal;rows.append(dict(kind='adapted-strict-final-balance',**bal))
# Isolate a row write with a scalar comparison result, not a row return.
limit=here/'limit-row-write-scalar.prg';lw=out/'row-write-scalar';lw.mkdir()
r=run([cc,limit,lw/'program'],lw,'build');assert r.returncode==1 and b'bounded read-only expressions' in r.stderr and not (lw/'program').exists(),r.stderr
rows.append(dict(kind='row-write-scalar-named-rejection'))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),original_sha256=hashlib.sha256(sources[0].read_bytes()).hexdigest(),compiler_fixture_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),oracle_fixture_sha256=hashlib.sha256(oracle_src.read_bytes()).hexdigest(),scope='adapted Exercise semantics only; original memory checks remain separate phase17 gate; default error handler and raw-original differential NOT established',rows=rows),indent=2)+'\n');print('PASS adapted',len(rows))
