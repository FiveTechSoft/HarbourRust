from common import *
a=setup();rows=[]
for name,expr in [('plain','hb_osDriveSeparator()'),('upper','Upper(hb_osDriveSeparator())'),('dirsep','hb_DirSepAdd(hb_osDriveSeparator())'),('return','Pick()')]:
 w=a.output/name;w.mkdir();p=w/'p.prg';p.write_text('function Pick()\nreturn hb_osDriveSeparator()\nfunction Main()\nlocal i:=0,b:=0,v:="",total:=0\nfor i:=1 to 100\nv:='+expr+'\nnext\nb:=hb_memcheck()\nfor i:=1 to 10000\nv:='+expr+'\ntotal+=Len(v)\nnext\n? total,hb_memcheck()-b\nreturn nil\n');rr={}
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  q=run([a.compiler,p,w/mode,'--target=linux','--instrument',*flags],w,mode+'-build');assert q.returncode==0;q=run([w/mode],w,mode+'-run');rr[mode]=dict(build_rc=0,run_rc=q.returncode,binary_sha256=h(w/mode));(w/mode).unlink();assert q.returncode==0 and not q.stderr and q.stdout.split()==[b'0',b'0'],(name,q)
 rows.append(dict(name=name,source_sha256=h(p),zero_delta=True,results=rr));print(name,'delta0',flush=True)
finish(a,rows,'4modes100warmup+10000calls,int/ext,exact zero total+allocationdelta. Direct,owned nested builtins and returned result. Not oracle memory equivalence.')
