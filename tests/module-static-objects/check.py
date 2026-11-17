#!/usr/bin/env python3
"""NIL-only module STATIC objects: oracle, Linux/Wine and fail-closed memory.
Retagging a scalar-initialized STATIC is a named limit, not a success row.
"""
import argparse,pathlib,subprocess,os,hashlib,json,sys
P=pathlib.Path;ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--wine');ap.add_argument('--tree',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
gate=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);compiler=str(P(a.compiler).resolve());env=os.environ.copy();env['LC_ALL']='C.UTF-8';env['WINEDEBUG']='-all';oe={k:v for k,v in env.items() if k not in ['HB_CCPATH','HB_CCPREFIX','HBC_MINGW_LIB']};rows=[]
def run(cmd,w,label,ex=env):
 p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=ex,stdin=subprocess.DEVNULL,timeout=60)
 for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p
def add(name,kind,ok,**details):
 rows.append(dict(test=name,kind=kind,pass_=bool(ok),**details));print('PASS' if ok else 'FAIL',name,flush=True)
for src in sorted((gate/'programs').glob('*.prg')):
 w=out/src.stem;w.mkdir();b=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),src],w,'oracle-build',oe);q=run([w/'oracle'],w,'oracle',oe) if b.returncode==0 else None;ok=q is not None and q.returncode==0 and q.stderr==b''
 for target in ['linux']+(['windows'] if a.wine else []):
  exe=w/target;b=run([compiler,src,exe,'--target='+target],w,target+'-build');r=run(([a.wine] if target=='windows' else [])+[exe],w,target) if b.returncode==0 else None
  expected=(gate/'expected'/(src.stem+'.'+target+'.out')).read_bytes(); oracle_expected=q.stdout if q is not None else None
  ok=ok and (gate/'expected'/(src.stem+'.linux.out')).read_bytes()==oracle_expected
  ok=ok and r is not None and r.returncode==0 and r.stderr==b'' and r.stdout==expected
 add(src.stem,'byte-exact-oracle',ok)
neg={'nil_owned_argument_neg':'only typed integer/logical/date arguments','array_capture_neg':'owned/container/inline-effect','byref_neg':'logical by-reference','rebind_data_rhs_neg':'inline-effect','rebind_method_arg_neg':'inline-effect','scalar_retag':'keeps the scalar type','thread_neg':'module STATIC object storage with threads'}
for name,diag in neg.items():
 src=gate/'negative'/(name+'.prg');w=out/name;w.mkdir();b=run([compiler,src,w/'reject.s'],w,'reject');o=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),src],w,'oracle-build',oe)
 add(name,'named-limit',b.returncode==1 and diag.encode() in b.stderr and o.returncode==0,diagnostic=b.stderr.decode())
# The REAL object path, not a fake retained address: fresh constructors,
# alias, self-assignment, function return, NIL release, then two DATA reads.
sys.path.insert(0,str(gate.parent/'trycatch-linux'));from memdelta_guard import emit_delta
for payload,bound in [('integer',2),('string',3)]:
 for n in [1,500,1000]:
  vals={}
  for stem in ['pool_control','ownership_loop']:
   w=out/(stem+'-memory-'+payload+'-'+str(n));w.mkdir();src=w/'probe.prg';text=(gate/'programs'/(stem+'.prg')).read_text().replace('to 500','to '+str(n));text=text.replace('DATA n INIT 3','DATA n INIT "owned-string"') if payload=='string' else text;src.write_text(text)
   try:r=emit_delta(compiler,env,src,w,(b'\nowned-string owned-string' if payload=='string' else b'\n         3          3')*n)
   except Exception as e:r=dict(state_ok=False,delta=None,error=str(e))
   vals[stem]=r
  add('ownership-'+payload+'-'+str(n),'memory-bound',all(r['state_ok'] and r['delta']==bound for r in vals.values()),bound=bound,states=vals)
# NULL receivers are a description-string failure mode, not Harbour's
# Error-object protocol. Each path must reach catch and execute afterwards.
base=(gate/'programs/callee_rebind.prg').read_text()
for kind,expr in [('read','? o:n'),('write','o:n := 4'),('method','? o:Echo(1)')]:
 w=out/('nil-receiver-'+kind);w.mkdir();src=w/'probe.prg';text=base.replace('   o := T():New()\n   ? hold(o)','   local e\n   try\n      '+expr+'\n   catch e\n      ? e\n   end\n   o := T():New()\n   ? hold(o)');src.write_text(text);ok=True
 for target in ['linux']+(['windows'] if a.wine else []):
  exe=w/target;b=run([compiler,src,exe,'--target='+target],w,target+'-build');p=run(([a.wine] if target=='windows' else [])+[exe],w,target) if b.returncode==0 else None;expected=b'\nObject access on NIL\n         3\n         8';expected=expected.replace(b'\n',b'\r\n') if target=='windows' else expected
  ok=ok and p is not None and p.returncode==0 and p.stdout==expected and p.stderr==b''
 add('nil-receiver-'+kind,'declared-error-model',ok)
w=out/'nil-data-rhs-order';w.mkdir();src=w/'probe.prg'
text=(gate/'programs/callee_rebind.prg').read_text().replace('   o := T():New()\n   ? hold(o)','   local a := o\n   local e\n   try\n      a:n := rhs()\n   catch e\n      ? "caught"\n   end\n   o := T():New()\n   ? hold(o)')+'function rhs()\n   ? "rhs"\nreturn "owned"\n'
src.write_text(text);expected=b'\nrhs\ncaught\n         3\n         8';ok=True
for target in ['linux']+(['windows'] if a.wine else []):
 exe=w/target;b=run([compiler,src,exe,'--target='+target],w,target+'-build');p=run(([a.wine] if target=='windows' else [])+[exe],w,target) if b.returncode==0 else None
 ok=ok and p is not None and p.returncode==0 and p.stderr==b'' and p.stdout==(expected.replace(b'\n',b'\r\n') if target=='windows' else expected)
add('nil-data-rhs-order','evaluation-order',ok)
for n in [1,500,1000]:
 mw=out/('nil-data-rhs-memory-'+str(n));mw.mkdir();ms=mw/'probe.prg'
 start='   try\n      a:n := rhs()\n   catch e\n      ? "caught"\n   end'
 mt=text.replace('   local e','   local e,i').replace(start,'   for i := 1 to '+str(n)+'\n'+start+'\n   next')
 ms.write_text(mt)
 try:r=emit_delta(compiler,env,ms,mw,b'\nrhs\ncaught'*n+b'\n         3\n         8')
 except Exception as e:r=dict(state_ok=False,delta=None,error=str(e))
 add('nil-data-rhs-memory-'+str(n),'memory-bound',r['state_ok'] and r['delta']==2,bound=2,state=r)
ident=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),scope='Linux runtime; Wine if supplied; not Mac native',total=len(rows),passed=sum(x['pass_'] for x in rows),rows=rows);(out/'results.json').write_text(json.dumps(ident,indent=2));sys.exit(0 if ident['total']==ident['passed'] else 1)
