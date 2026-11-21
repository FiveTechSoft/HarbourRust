from common import *
a=setup();rows=[]
for name,key,year in [('empty','""',0),('valid','"20240101"',2024),('invalid','"19000229"',0),('temporary','Upper("20240101")',2024),('yearzero','"00000101"',0),('long','"20240101"+Replicate("x",70000)',2024)]:
 w=a.output/name;w.mkdir();p=w/'p.prg';p.write_text('function Main()\nlocal i:=0,b:=0,d:=hb_SToD(""),total:=0\nfor i:=1 to 100\nd:=hb_SToD('+key+')\nnext\nb:=hb_memcheck()\nfor i:=1 to 10000\nd:=hb_SToD('+key+')\ntotal+=Year(d)\nnext\n? total,hb_memcheck()-b\nreturn nil\n');rr={}
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  q=run([a.compiler,p,w/mode,'--target=linux','--instrument',*flags],w,mode+'-build');assert q.returncode==0,(name,q);q=run([w/mode],w,mode+'-run');rr[mode]=dict(build_rc=0,run_rc=q.returncode,binary_sha256=h(w/mode));(w/mode).unlink();assert q.returncode==0 and not q.stderr and q.stdout.split()==[str(year*10000).encode(),b'0'],(name,q)
 rows.append(dict(name=name,source_sha256=h(p),zero_delta=True,results=rr));print(name,'delta0',flush=True)
finish(a,rows,'6modes100warmup+10000calls,int/ext,exact total+zero allocationdelta. Temporary input cleanup,Date output. Not oracle memory equivalence.')
