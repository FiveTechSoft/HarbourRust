#!/usr/bin/env python3
"""Bounded nullable method string boundary, not general frame unwind."""
import argparse,pathlib,subprocess,json,hashlib,os,sys
P=pathlib.Path
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--wine');ap.add_argument('--tree',required=True);ap.add_argument('--output',required=True);ap.add_argument('--stage',choices=['all','memory','oracle','negative'],default='all');ap.add_argument('--shape',choices=['typed','dyn','multi','mixed']);a=ap.parse_args()
compiler=str(P(a.compiler).resolve());out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=os.environ.copy();env['LC_ALL']='C.UTF-8';env['WINEDEBUG']='-all';oe={k:v for k,v in env.items() if k not in ['HB_CCPATH','HB_CCPREFIX','HBC_MINGW_LIB']};rows=[]
sys.path.insert(0,str(P(__file__).resolve().parent.parent/'trycatch-linux'));from memdelta_guard import emit_delta
header='''#include "hbclass.ch"
STATIC o := NIL
STATIC hits := 0
CREATE CLASS T
   METHOD New() CONSTRUCTOR
   METHOD Echo(x,y,z)
ENDCLASS
METHOD New() CLASS T
return Self
'''
def source(shape,receiver,expr,n,control=False):
 method={'typed':'   local keep := Upper(x)\n','dyn':'   if .f.\n      ? x\n   end\n','multi':'   local a := Upper(x), b := Upper(y), c := Upper(z)\n','mixed':'   local keep := Upper(x)\n   if y .and. z > 0\n      hits += 0\n   end\n'}[shape]
 s=header+'METHOD Echo(x,y,z) CLASS T\n'+method+'   hits += 1\nreturn nil\nfunction main()\n   local i,e,x := Space(7), a := o, catches := 0\n'
 if receiver=='live':s+='   o := T():New()\n   a := o\n'
 s+='   for i := 1 to '+str(n)+'\n      x := Space(7)\n'
 if control:s+='      if .f.\n'
 args=expr+(', Lower("two"), Space(3)' if shape=='multi' else ', .t., 3' if shape=='mixed' else '')
 s+='      try\n         a:Echo('+args+')\n      catch e\n         catches += 1\n      end\n'
 if control:s+='      end\n'
 s+='      x := Space(7)\n   next\n'
 if receiver=='null':s+='   o := T():New()\n'
 s+='   ? hits, catches\nreturn nil\n';return s

def raw(cmd,w,label,ex=env):
 p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=ex,stdin=subprocess.DEVNULL,timeout=60)
 for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p

def add(name,kind,ok,**details):
 rows.append(dict(test=name,kind=kind,pass_=bool(ok),**details));print('PASS' if ok else 'FAIL',name,flush=True)

sources=[('literal','"owned"'),('space','Space(7)'),('concat','"a" + "b"'),('variable','x'),('upper','Upper("mixed")'),('nested','Left(Upper("abcdef"),3)'),('empty','Space(0)')]
for shape in ['typed','dyn','multi','mixed']:
 if a.stage not in ['all','memory'] or (a.shape and shape!=a.shape):continue
 for receiver in ['live','null']:
  for name,expr in sources:
   for n in [1,500,1000]:
    w=out/(shape+'-'+receiver+'-'+name+'-'+str(n));w.mkdir();vals={}
    for control in [False,True]:
     path=w/('control' if control else 'actual');path.mkdir();src=path/'probe.prg';src.write_text(source(shape,receiver,expr,n,control));expected=b'\n'+f'{n if receiver=="live" and not control else 0:10d} {n if receiver=="null" and not control else 0:10d}'.encode()
     try:r=emit_delta(compiler,env,src,path,expected)
     except Exception as e:r=dict(state_ok=False,delta=None,error=str(e))
     vals['control' if control else 'actual']=r
    add(w.name,'memory-control',all(r['state_ok'] and r['delta']==2 for r in vals.values()),bound=2,states=vals)
# Fresh oracle and raw Linux/Wine comparison for all shapes/sources/states.
for shape in ['typed','dyn','multi','mixed']:
 if a.stage not in ['all','oracle'] or (a.shape and shape!=a.shape):continue
 for receiver in ['live','null']:
  for name,expr in sources:
   w=out/('oracle-'+shape+'-'+receiver+'-'+name);w.mkdir();src=w/'probe.prg';s=source(shape,receiver,expr,3);src.write_text(s)
   oracle=w/'oracle.prg';oracle.write_text(s.replace('   for i :=','   ErrorBlock({|err| Break(err)})\n   for i :=',1).replace('      try\n','      begin sequence\n').replace('      catch e\n','      recover using e\n').replace('      end\n','      end sequence\n'))
   b=raw([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),oracle],w,'oracle-build',oe);r=raw([w/'oracle'],w,'oracle',oe) if b.returncode==0 else None;ok=r is not None and r.returncode==0 and r.stderr==b''
   expected=b'\n'+f'{3 if receiver=="live" else 0:10d} {3 if receiver=="null" else 0:10d}'.encode();ok=ok and r is not None and r.stdout==expected
   for target in ['linux']+(['windows'] if a.wine else []):
    exe=w/target;b=raw([compiler,src,exe,'--target='+target],w,target+'-build');p=raw(([a.wine] if target=='windows' else [])+[exe],w,target) if b.returncode==0 else None
    ok=ok and p is not None and p.returncode==0 and p.stderr==b'' and p.stdout==(expected.replace(b'\n',b'\r\n') if target=='windows' else expected)
   add(w.name,'oracle-runtime',ok)
# These invalid shapes must not reach nested dispatch or abandon earlier
# string owners while a later argument throws. They are Harbour-valid.
neg=[('fresh-call','fresh()','return Space(7)\n'),('later-call','Space(7), fresh()','return 1\n'),('later-divide','Space(7), 1 / zero()','return 0\n'),('index','xs[1]','return 0\n'),('nested-send','a:Echo("x")','return 0\n'),('dyn-input','e','return 0\n'),('float-input','1.5','return 0\n'),('duplicate-local','x,x,x','return 0\n'),('constructor-receiver','CONSTRUCTOR_RECEIVER','return 0\n'),('unsupported-builtin','Trim("x")','return 0\n'),('dyn-left-count','Left("abcdefghi",d)','return 0\n'),('dyn-left-nested','Upper(Left("abcdefghi",d))','return 0\n'),('dyn-left-arithmetic','Left("abcdefghi",d+1)','return 0\n'),('dyn-space-arithmetic','Space(d+1)','return 0\n'),('dyn-later-nil','Space(7),d+1','return 0\n')]
for name,args,body in neg:
 if a.stage not in ['all','negative']:continue
 for receiver in ['live','null']:
  w=out/('reject-'+receiver+'-'+name);w.mkdir();src=w/'probe.prg';s=source('typed',receiver,'"x"',1).replace('   local i,e,x := Space(7), a := o, catches := 0','   local i,e,x := Space(7), a := o, catches := 0, xs := {"x"}').replace('a:Echo("x")','? T():New():Echo("x")' if name=='constructor-receiver' else 'a:Echo('+args+')')+'function fresh()\n'+body+'function zero()\nreturn 0\n';src.write_text(s)
  if name.startswith('dyn-') and name!='dyn-input':
   s=s.replace('catches := 0, xs :=', 'catches := 0, d := NIL, xs :=').replace('   for i :=',('   d := 2\n' if name!='dyn-later-nil' else '')+'   for i :=',1);src.write_text(s)
  oracle=w/'oracle.prg';oracle.write_text(s.replace('      try\n','      begin sequence\n').replace('      catch e\n','      recover using e\n').replace('      end\n','      end sequence\n'));p=raw([compiler,src,w/'reject.s'],w,'reject');o=raw([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),oracle],w,'oracle-build',oe)
  diag=b'moved value' if name=='duplicate-local' else b'increment'
  add(w.name,'named-rejection',p.returncode==1 and diag in p.stderr and o.returncode==0,diagnostic=p.stderr.decode(errors='replace'))
ident=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),stage=a.stage,shape=a.shape,scope='NIL receiver boundary only; method-body frame unwind not covered; Linux memory, Linux/Wine runtime, Harbour external oracle',total=len(rows),passed=sum(r['pass_'] for r in rows),rows=rows);(out/'results.json').write_text(json.dumps(ident,indent=2));sys.exit(0 if ident['total']==ident['passed'] else 1)
