from common import *
a=setup(True);rows=[]
cases={
'string-array-before':'function Main()\n? Pick("abcd")\nreturn nil\nfunction Pick(p)\nlocal n:=Len(p),s:=Upper(p)\nif .f.\nAAdd(p,1)\nendif\nreturn n\n',
'string-array-after':'function Main()\n? Pick("abcd")\nreturn nil\nfunction Pick(p)\nlocal s:=Upper(p),n:=0\nif .f.\nAAdd(p,1)\nendif\nn:=Len(p)\nreturn n\n',
'string-number':'function Main()\n? Pick("abcd")\nreturn nil\nfunction Pick(p)\nlocal n:=Len(p),s:=Upper(p)\nif .f.\nn:=p+1\nendif\nreturn n\n',
'use-after-move':'function Main()\n? Pick("abcd")\nreturn nil\nfunction Pick(p)\nlocal n:=0\nSink(p)\nn:=Len(p)\nreturn n\nfunction Sink(s)\nreturn Upper(s)\n',
'wrong-boundary':'function Main()\nlocal a:=Array(2)\n? Pick(a)\nreturn nil\nfunction Pick(p)\nlocal n:=Len(p),s:=Upper(p)\nreturn n\n',
}
for name,source in cases.items():
 w=a.output/name;w.mkdir();p=w/'p.prg';p.write_text(source);rr={}
 for label,cc in [('base',a.baseline),('candidate',a.compiler)]:
  q=run([cc,p,w/label,'--target=linux','--instrument'],w,label+'-build');assert q.returncode==1 and q.stderr and not (w/label).exists(),(name,label,q);rr[label]=dict(build_rc=q.returncode,diagnostic=q.stderr.decode())
 # Rejected boundary/control programs are not run. The safe string/array
 # conflicts use dead branches so the fresh oracle can execute them.
 if name!='wrong-boundary':
  q=run([a.hbmk2,p,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert q.returncode==0,(name,q);z=run([w/'oracle'],w,'oracle-run');assert z.returncode==0 and not z.stderr,(name,z);rr['oracle']=dict(build_rc=0,run_rc=z.returncode,binary_sha256=h(w/'oracle'));(w/'oracle').unlink()
 rows.append(dict(name=name,source_sha256=h(p),results=rr,ok=True));print(name,'named rejection',flush=True)
finish(a,rows,'5compile rejection controls,base+candidate rc1,no rejected binary executed.4fresh oracle build/run0 controls;wrong boundary not run in oracle. No type coercion or use-after-move admission.')
