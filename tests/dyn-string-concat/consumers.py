import pathlib,sys,os,json
P=pathlib.Path;sys.path.insert(0,str(P(__file__).resolve().parent.parent/'trycatch-linux'));from memdelta_guard import emit_delta
import argparse,subprocess,hashlib
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);ap.add_argument('--tree',required=True);args=ap.parse_args();compiler=str(P(args.compiler).resolve());out=P(args.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
cases={
'user-arg':('take(d+"!")','function take(x)\nlocal k:=Upper(x)\nreturn nil\n'),
'dyn-arg':('take(d+"!")','function take(x)\nif .f.\n? x\nendif\nreturn nil\n'),
'sequence':('s:=(d+"!",d+"!")',''),
'array-literal':('a:={d+"!"}',''),
'hash-literal':('h:={d+"!"=>1}',''),
'block-result':('s:=Eval({||d+"!"})',''),
'file':('b:=File(d+"!")',''),
'return':('s:=give()','function give()\nlocal d\nd:="owned"\nreturn d+"!"\n'),
'discard':('give()','function give()\nlocal d\nd:="owned"\nreturn d+"!"\n'),
'len':('x:=Len(d+"!")',''),
'valtype':('s:=ValType(d+"!")',''),
'empty':('b:=Empty(d+"!")',''),
'isstring':('b:=HB_ISSTRING(d+"!")',''),
'upper':('s:=Upper(d+"!")',''),
'left':('s:=Left(d+"!",2)',''),
'lower':('s:=Lower(d+"!")',''),
'alltrim':('s:=AllTrim(d+"!")',''),
'substr':('s:=SubStr(d+"!",2,3)',''),
'right':('s:=Right(d+"!",2)',''),
'padr':('s:=PadR(d+"!",9)',''),
'padl':('s:=PadL(d+"!",9)',''),
'padc':('s:=PadC(d+"!",9)',''),
'rat':('x:=RAt(d+"!","owned!")',''),
'at':('x:=At(d+"!","owned!")',''),
'val':('f:=Val(d+"!")',''),
'strtran':('s:=StrTran(d+"!","o","O")',''),
'asc':('x:=Asc(d+"!")',''),
'array-scan':('x:=AScan(a,d+"!")',''),
'hash-del':('HB_HDel(h,d+"!")',''),
'public-store':('PUBLIC q:=d+"!"',''),
'compare':('b:=(d+"!")=="owned!"',''),
'contains':('b:=(d+"!") $ "owned!"',''),
'iif':('s:=iif(.t.,d+"!","fallback")',''),
'array-store':('a[1]:=d+"!"',''),
'array-add':('AAdd(a,d+"!")\nASize(a,1)',''),
'array-fill':('AFill(da,d+"!")',''),
'hash-key':('HB_HSet(h,d+"!",2)',''),
'hash-get':('x:=HB_HGet(h,d+"!",0)',''),
'byref-store':('put(@s)','function put(x)\nlocal d\nd:="owned"\nx:=d+"!"\nreturn nil\n'),
'array-shared-store':('shared[1]:=d+"!"',''),
'array-shared-add':('AAdd(shared,d+"!")\nASize(shared,1)',''),
}
for name,(expr,funcs) in cases.items():
 for n in [1,500,1000]:
  vals={}
  for ctrl in [False,True]:
   w=out/(name+'-'+str(n)+('-control' if ctrl else '-actual'));w.mkdir();src=w/'probe.prg'
   s='STATIC shared := {"old",NIL}\nfunction exercise()\nlocal d,i,s:=Space(7),x:=0,f:=0.0,b:=.f.,a:={"old"},h:={"owned!"=>1},da\nda:={1,NIL}\nd:="owned"\nfor i:=1 to '+str(n)+'\n'+('if .f.\n' if ctrl else '')+expr+'\n'+('endif\n' if ctrl else '')+'s:=Space(7)\nnext\nreturn nil\nfunction main()\nexercise()\n? "done"\nreturn nil\n'+funcs;src.write_text(s)
   try:r=emit_delta(compiler,os.environ.copy(),src,w,b'\ndone')
   except Exception as e:r=dict(state_ok=False,error=str(e),delta=None)
   vals['control' if ctrl else 'actual']=r
  rejections={'sequence':'parenthesized comma expressions support numeric/logical/borrowed-string results only','array-literal':'array elements must be integers or logicals','hash-literal':'hash keys are strings in this increment','block-result':'codeblock captures are not in this increment','valtype':'`ValType` over this expression is not measured','isstring':'HB_ISSTRING uses the measured ValType read contract','array-shared-store':'storing into a cell of the shared module array','array-shared-add':'`AAdd` on the shared module array'}
  if name in rejections:
   good=True
   for ctrl in [False,True]:
    w=out/(name+'-'+str(n)+('-control' if ctrl else '-actual'));r=subprocess.run([compiler,str(w/'probe.prg'),str(w/'rejected')],capture_output=True)
    for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/('reject.'+ext)).write_bytes(v)
    good=good and r.returncode==1 and rejections[name].encode() in r.stderr
  else:good=all(x['state_ok'] for x in vals.values()) and vals['actual']['delta']==vals['control']['delta']==0
  rows.append(dict(name=name,n=n,pass_=good,states=vals));print(rows[-1],flush=True)
# Additional ownership boundaries: output, selector, string iteration,
# method arguments, and named rejections of unmeasured contexts.
header='#include "hbclass.ch"\nCREATE CLASS T\nMETHOD New(x) CONSTRUCTOR\nMETHOD Echo(x)\nENDCLASS\nMETHOD New(x) CLASS T\nlocal k:=Upper(x)\nreturn Self\nMETHOD Echo(x) CLASS T\nlocal k:=Upper(x)\nreturn nil\n'
extra={
 'qout':('QOut(d+"")',b'\n'),
 'qqout':('QQOut(d+"")',b''),
 'outstd':('OutStd(d+"")',b''),
 'outerr':('OutErr(d+"")',b''),
 'switch':('switch d+""\ncase ""\nhits+=1\notherwise\nhits+=0\nendswitch',b''),
 'foreach-result':('for each c in d+""\nhits+=1\nnext',b''),
 'method-arg':('o:Echo(d+"!")',b''),
 'constructor-arg':('o:=T():New(d+"!")',b''),
}
for name,(expr,printed) in extra.items():
 for n in [1,500,1000]:
  vals={}
  for ctrl in [False,True]:
   w=out/(name+'-'+str(n)+('-control' if ctrl else '-actual'));w.mkdir();src=w/'probe.prg'
   text=header+'function exercise()\nlocal d,i,c,o:=T():New(""),hits:=0\nd:=""\nfor i:=1 to '+str(n)+'\n'+('if .f.\n' if ctrl else '')+expr+'\n'+('endif\n' if ctrl else '')+'next\nreturn nil\nfunction main()\nexercise()\n? "done"\nreturn nil\n';src.write_text(text)
   try:r=emit_delta(compiler,os.environ.copy(),src,w,(printed*n if not ctrl else b'')+b'\ndone')
   except Exception as e:r=dict(state_ok=False,delta=None,error=str(e))
   vals['control' if ctrl else 'actual']=r
  if name=='foreach-result':
   good=True
   for ctrl in [False,True]:
    w=out/(name+'-'+str(n)+('-control' if ctrl else '-actual'));r=subprocess.run([compiler,str(w/'probe.prg'),str(w/'rejected')],capture_output=True)
    for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/('reject.'+ext)).write_bytes(v)
    good=good and r.returncode==1 and b'`for each` iterates a variable or a function result' in r.stderr
  else:good=all(x['state_ok'] for x in vals.values()) and vals['actual']['delta']==vals['control']['delta']==2
  rows.append(dict(name=name,n=n,pass_=good,states=vals));print(rows[-1],flush=True)
for stem,expr in [('external','d+"!"'),('external-nested','Upper(d+"!")')]:
 w=out/stem;w.mkdir();src=w/'probe.prg';src.write_text('EXTERNAL Take\nfunction main()\nlocal d\nd:="owned"\nTake('+expr+')\nreturn nil\n');r=subprocess.run([compiler,str(src),str(w/'reject')],capture_output=True)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/('reject.'+ext)).write_bytes(v)
 good=r.returncode==1 and b'Dyn/string concat temporary across C Extend is not in this increment' in r.stderr
 rows.append(dict(name=stem,pass_=good,named_limit=True,diagnostic=r.stderr.decode()));print(rows[-1],flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_tree=args.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),total=len(rows),passed=sum(x['pass_'] for x in rows),rows=rows),indent=2));sys.exit(0 if all(x['pass_'] for x in rows) else 1)
