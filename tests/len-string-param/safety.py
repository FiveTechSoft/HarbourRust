from common import *
a=setup();rows=[]
for order in ['before','after']:
 for mode,statement in [('upper','s:=Upper(p)'),('assign','p:="changed"'),('trim','s:=AllTrim(p)')]:
  name=mode+'-'+order;w=a.output/name;w.mkdir();body=['n:=Len(p)',statement] if order=='before' else [statement,'n:=Len(p)'];value=7 if mode=='assign' and order=='after' else 4
  source='function Main()\nlocal i:=0,b:=0,total:=0\nfor i:=1 to 100\nPick("Abcd")\nnext\nb:=hb_memcheck()\nfor i:=1 to 10000\ntotal+=Pick("Abcd")\nnext\n? total,hb_memcheck()-b\nreturn nil\nfunction Pick(p)\nlocal n:=0,s:=""\n'+'\n'.join(body)+'\nreturn n\n';p=w/'p.prg';p.write_text(source);rr={}
  for backend,flags in [('int',[]),('ext',['--external-as'])]:
   b=run([a.compiler,p,w/backend,'--target=linux','--instrument',*flags],w,backend+'-build');assert b.returncode==0,(name,b);q=run([w/backend],w,backend+'-run');rr[backend]=dict(build_rc=0,run_rc=q.returncode,binary_sha256=h(w/backend));(w/backend).unlink();assert q.returncode==0 and not q.stderr and q.stdout.split()==[str(value*10000).encode(),b'0'],(name,q)
  rows.append(dict(name=name,source_sha256=h(p),zero_delta=True,results=rr));print(name,'delta0',flush=True)
finish(a,rows,'6modes100warmup+10000calls int/ext; parameter string ownership and retained locals,exact expected total and zero allocation delta. No oracle memory equivalence claim.')
