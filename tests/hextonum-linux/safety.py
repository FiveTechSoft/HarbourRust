from common import *
a=setup();rows=[]
for name,key,value in [('empty','""',0),('plain','"1aF"',431),('invalid','"12x"',0),('temporary','Upper("1af")',431),('nul','"12"+Chr(0)+"FF"',18),('long','Replicate("F",70000)',-1)]:
 w=a.output/name;w.mkdir();p=w/'p.prg';p.write_text('function Main()\nlocal i:=0,b:=0,v:=0,total:=0\nfor i:=1 to 100\nv:=hb_HexToNum('+key+')\nnext\nb:=hb_memcheck()\nfor i:=1 to 10000\nv:=hb_HexToNum('+key+')\ntotal+=v\nnext\n? total,hb_memcheck()-b\nreturn nil\n');rr={}
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  q=run([a.compiler,p,w/mode,'--target=linux','--instrument',*flags],w,mode+'-build');assert q.returncode==0,(name,q);q=run([w/mode],w,mode+'-run');rr[mode]=dict(build_rc=0,run_rc=q.returncode,binary_sha256=h(w/mode));(w/mode).unlink();assert q.returncode==0 and not q.stderr and q.stdout.split()==[str(value*10000).encode(),b'0'],(name,q)
 rows.append(dict(name=name,source_sha256=h(p),zero_delta=True,results=rr));print(name,'delta0',flush=True)
finish(a,rows,'6modes100warmup+10000calls,int/ext,exact total+zero allocationdelta. Temporary input cleanup,numeric output. Not oracle memory equivalence.')
