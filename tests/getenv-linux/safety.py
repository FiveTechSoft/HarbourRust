from common import *
a=setup();rows=[]
for name,key in [('literal','"HR_GETENV_A"'),('temporary','Upper("hr_getenv_a")'),('absent','"HR_GETENV_MISSING"'),('long','"HR_GETENV_LONG"'),('nul','"HR_GETENV_A"+Chr(0)+"tail"'),('repeat','"HR_GETENV_A"')]:
 w=a.output/name;w.mkdir();p=w/'p.prg';source='function Main()\nlocal i:=0,b:=0,v:="",total:=0\nfor i:=1 to 100\nv:=GetEnv('+key+')\nnext\nb:=hb_memcheck()\nfor i:=1 to 10000\nv:=GetEnv('+key+')\ntotal+=Len(v)\nnext\n? total,hb_memcheck()-b\nreturn nil\n';p.write_text(source);rr={};length=0 if name=='absent' else 8192 if name=='long' else 5
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  b=run([a.compiler,p,w/mode,'--target=linux','--instrument',*flags],w,mode+'-build');assert b.returncode==0,(name,b);q=run([w/mode],w,mode+'-run');rr[mode]=dict(build_rc=0,run_rc=q.returncode,binary_sha256=h(w/mode));(w/mode).unlink();assert q.returncode==0 and not q.stderr and q.stdout.split()==[str(length*10000).encode(),b'0'],(name,q)
 rows.append(dict(name=name,source_sha256=h(p),zero_delta=True,results=rr));print(name,'delta0',flush=True)
finish(a,rows,'6modes100warmup+10000lookups,int/ext,exact total+zero allocationdelta; fixture keys only. Input temporary cleanup and output replacement ownership. Not oracle memory equivalence.')
