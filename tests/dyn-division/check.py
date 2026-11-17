#!/usr/bin/env python3
"""I2 Dyn division regression gate. Native Linux + optional Wine byte pins,
Harbour GTSTD oracle, strict instrumented memory balance. No skipped compile
failures count as ownership coverage. Cross-frame Self retention is a separate
known runtime limit, measured against Break with the same caller/callee shape.
"""
import argparse, hashlib, json, os, pathlib, subprocess, sys
P=pathlib.Path
ap=argparse.ArgumentParser(); ap.add_argument('--compiler',required=True); ap.add_argument('--hbmk2',required=True); ap.add_argument('--output',required=True); ap.add_argument('--wine'); ap.add_argument('--tree',required=True); a=ap.parse_args()
gate=P(__file__).resolve().parent; root=gate.parent; out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
compiler=str(P(a.compiler).resolve());env=os.environ.copy();env.update(LC_ALL='C.UTF-8',WINEDEBUG='-all');oe={k:v for k,v in env.items() if k not in ('HB_CCPATH','HB_CCPREFIX','HBC_MINGW_LIB')}
sys.path.insert(0,str(root/'trycatch-linux'));from memdelta_guard import emit_delta
rows=[]
def run(cmd,w,label,envx=None):
 r=subprocess.run(list(map(str,cmd)),cwd=w,env=envx or env,capture_output=True,stdin=subprocess.DEVNULL,timeout=60)
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return r
def add(test,kind,ok,**details):
 rows.append(dict(test=test,kind=kind,pass_=bool(ok),**details));print('PASS' if ok else 'FAIL',test,flush=True)
def execute(src,w,expected,oracle=False,expected_win=None):
 b=run([compiler,src,w/'linux','--target=linux'],w,'build');r=run([w/'linux'],w,'linux') if b.returncode==0 else None
 ok=r is not None and r.returncode==0 and r.stdout==expected and r.stderr==b''
 if a.wine:
  b=run([compiler,src,w/'windows.exe','--target=windows'],w,'win-build');r=run([a.wine,w/'windows.exe'],w,'windows') if b.returncode==0 else None
  ok=ok and r is not None and r.returncode==0 and r.stdout==(expected_win if expected_win is not None else expected.replace(b'\n',b'\r\n')) and r.stderr==b''
 if oracle:
  oracle_src=w/'oracle.prg'; oracle_src.write_text('#include "hbclass.ch"\n'+P(src).read_text())
  b=run([a.hbmk2,oracle_src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build',oe);r=run([w/'oracle'],w,'oracle',oe) if b.returncode==0 else None
  ok=ok and r is not None and r.returncode==0 and r.stdout==expected and r.stderr==b''
 return ok
for n in range(1680,1684):
 src=next(root.glob('t'+str(n)+'_*.prg'));w=out/src.stem;w.mkdir();pin=(root/'expectations/qout'/(src.stem+'.linux.out')).read_bytes();add(src.stem,'oracle-byte-exact',execute(src,w,pin,True,(root/'expectations/qout'/(src.stem+'.windows.out')).read_bytes()))
src=root/'t1684_dyn_div_seq_catch.prg';w=out/src.stem;w.mkdir();pin=(root/'expectations/qout'/(src.stem+'.linux.out')).read_bytes();add(src.stem,'catch-string-pinned',execute(src,w,pin,expected_win=(root/'expectations/qout'/(src.stem+'.windows.out')).read_bytes()))
# Invalid-kind dispatch must wait for BOTH operands, including rhs zero.
base=(gate/'programs/order_error.prg').read_text()
for name,s in [('order_error',base),('order_rhs_zero',base.replace('d := 2','d := 0')),('order_rhs_bad',base.replace('d := 2','d := .T.'))]:
 w=out/name;w.mkdir();src=w/'probe.prg';src.write_text(s);add(name,'evaluation-order',execute(src,w,b'\nlhs\nrhs\nArgument error: /'))
# Per-route exact controls and bounds, three loop sizes defeat allocator caches.
for route in ['borrowed','call','memvar','send','selfget']:
 for n in [1,500,1000]:
  deltas={};states=[]
  for kind in ['control','float','string']:
   stem=route+'_'+kind;w=out/(stem+'-'+str(n));w.mkdir();src=w/'probe.prg';src.write_text((gate/'programs'/(stem+'.prg')).read_text().replace('to 500','to '+str(n)))
   try:r=emit_delta(compiler,env,src,w,b'\ndone')
   except Exception as e:r=dict(state_ok=False,error=str(e),delta=None)
   deltas[kind]=r.get('delta');states.append(r)
  bound=2 if route in ['send','selfget'] else 0
  add(route+'-'+str(n),'ownership-same-frame',all(r['state_ok'] for r in states) and all(v==bound for v in deltas.values()),bound=bound,deltas=deltas,states=states)
# Existing cross-frame error unwind retains one Self string block even for
# Break(). Report it as a frozen known limit, not as a zero-balance success.
for n in [1,500,1000]:
 results={}
 for kind in ['division','break']:
  w=out/('unwind-'+kind+'-'+str(n));w.mkdir();src=w/'probe.prg';s=(gate/'known-limits/selfget_crossframe.prg').read_text().replace('to 500','to '+str(n))
  if kind=='break':s=s.replace('return ::d / 2','   Break("control")\nreturn 7.5 / 2')
  src.write_text(s)
  try:results[kind]=emit_delta(compiler,env,src,w,b'\ndone')
  except Exception as e:results[kind]=dict(state_ok=False,error=str(e),delta=None)
 add('unwind-'+str(n),'known-runtime-limit',all(r['state_ok'] and r['delta']==3 for r in results.values()),states=results,bound=3)
# Non-executable frontiers stay explicit named rejections, never runtime rows.
for src in sorted((gate/'negative').glob('*.prg')):
 w=out/src.stem;w.mkdir();r=run([compiler,src,w/'probe','--target=linux'],w,'reject');diag='owned, Dyn, array and block results remain a named limit' if src.stem.startswith('seq_') else ('holding an array is not in this increment' if src.stem=='data_array' else 'holding an object is not in this increment')
 add(src.stem,'named-limit',r.returncode==1 and diag.encode() in r.stderr,rc=r.returncode,diagnostic=r.stderr.decode('utf-8','replace'))
identity=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),native_mac=False,wine=bool(a.wine),rows=rows,total=len(rows),passed=sum(r['pass_'] for r in rows))
(out/'results.json').write_text(json.dumps(identity,indent=2)+'\n');sys.exit(0 if identity['passed']==len(rows) else 1)
