from common import *
a=setup();rows=[]
for name,key,length in [('empty','""',0),('plain','"abc"',4),('trailing','"abc/"',8),('temporary','Upper("abc")',4),('nul','"abc"+Chr(0)',8),('long','Replicate("a",70000)',93336)]:
 w=a.output/name;w.mkdir();p=w/'p.prg';p.write_text('function Main()\nlocal i:=0,b:=0,v:="",total:=0\nfor i:=1 to 100\nv:=hb_base64Encode('+key+')\nnext\nb:=hb_memcheck()\nfor i:=1 to 10000\nv:=hb_base64Encode('+key+')\ntotal+=Len(v)\nnext\n? total,hb_memcheck()-b\nreturn nil\n');rr={}
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  b=run([a.compiler,p,w/mode,'--target=linux','--instrument',*flags],w,mode+'-build');assert b.returncode==0,(name,b);q=run([w/mode],w,mode+'-run');rr[mode]=dict(build_rc=0,run_rc=q.returncode,binary_sha256=h(w/mode));(w/mode).unlink();assert q.returncode==0 and not q.stderr and q.stdout.split()==[str(length*10000).encode(),b'0'],(name,q)
 rows.append(dict(name=name,source_sha256=h(p),zero_delta=True,results=rr));print(name,'delta0',flush=True)
finish(a,rows,'6modes100warmup+10000calls,int/ext,exact total+zero allocationdelta. Input temporary cleanup and output ownership. Not oracle memory equivalence.')
