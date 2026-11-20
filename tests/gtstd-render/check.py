#!/usr/bin/env python3
"""Original MIT. External Harbour GTSTD is a black-box executable oracle only."""
import argparse,pathlib,subprocess,json,hashlib,random
P=pathlib.Path;ap=argparse.ArgumentParser()
for f in ['compiler','hbmk2','output']:ap.add_argument('--'+f,required=True)
a=ap.parse_args();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=P(a.compiler).resolve();rows=[];hashes={};commands=[]
def run(cmd,w,label,args=[]):
 argv=list(map(str,cmd))+args;commands.append(dict(cwd=str(w.relative_to(out)),label=label,argv=argv))
 try:q=subprocess.run(argv,cwd=w,capture_output=True,timeout=10)
 except subprocess.TimeoutExpired as e:q=subprocess.CompletedProcess(argv,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for k,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return q

def case(name,source,argsets=[[]]):
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(source);ob=run([a.hbmk2,'p.prg','-quiet','-gtstd','-w0','-ooracle'],w,'oracle-build');builds={}
 for mode,flags in [('int',[]),('ext',['--external-as'])]:builds[mode]=run([cc,src,w/mode,'--target=linux','--instrument',*flags],w,'build-'+mode)
 for i,args in enumerate(argsets):
  o=run([w/'oracle'],w,'oracle-'+str(i),args) if not ob.returncode else None
  for mode in builds:
   b=builds[mode];q=run([w/mode],w,mode+'-'+str(i),args) if not b.returncode else None
   exact=bool(o and q and o.returncode==q.returncode==0 and o.stdout==q.stdout and o.stderr==q.stderr);row=dict(name=name+'-'+mode+'-'+str(i),build_rc=b.returncode,oracle_build_rc=ob.returncode,run_rc=q.returncode if q else None,exact=exact,args=args);rows.append(row)
   if not exact:print('FAIL',row['name'],('build-rejected' if b.returncode else 'raw-diff'),flush=True)
 for n in ['oracle','int','ext']:
  f=w/n
  if f.exists():hashes[str(f.relative_to(out))]=hashlib.sha256(f.read_bytes()).hexdigest();f.unlink()
for pos in [0,1,2,77,78,79,80,81]:
 case('bytes-position-'+str(pos),'function Main()\nlocal n\nfor n:=0 to 255\n? Replicate("a",'+str(pos)+')+Chr(n)+"XY"\nnext\nreturn nil\n')
case('raw-isolation','function Main()\nlocal n\nfor n:=0 to 255\nOutStd("ab"+Chr(n)+"cd")\nOutErr("ef"+Chr(n)+"gh")\nnext\nreturn nil\n')
position={
'back-cross':'?? "abc"\n?? Chr(8)\n?? "X"',
'items':'? "abc",Chr(8)+"X",Chr(8)+"Y"',
'back-over-line':'? "abc"+Replicate(Chr(8),5)+"X"',
'cr-cross':'?? "abc"\n?? Chr(13)\n?? "X"',
'crlf-cross':'?? "abc"+Chr(13)\n?? Chr(10)+"X"',
'outstd-mix':'?? "abc   "\nOutStd("X")\n?? "Y"',
'outstd-lf':'?? "abc"\nOutStd(Chr(10))\n?? "Y"',
'empty-space-items':'? "a ","",Space(3),"X"\n?? "  "\n?? ""\n?? "Y"',
'scroll':'?? Replicate("x"+Chr(10),50)+Replicate(Chr(8),81)+"Y"',
'last-col':'?? Replicate("a",80)+Chr(8)+"X"',
'last-space':'?? Replicate(" ",80)+"X"',
'owned':'? Upper("abc"+Chr(8)+"x")\n?? Left("ABC"+Chr(13)+"X",5)',
'dyn':'local a:={"ab'+chr(8)+'X",1,NIL}\n? a[1],a[2],a[3]',
'numeric':'? Replicate("x",77),123,.T.\n? 2.5,Date()',
}
for n,body in position.items():case(n,'function Main()\n'+body+'\nreturn nil\n')
rng=random.Random(1971)
def expr(bs):return '+'.join('Chr('+str(b)+')' for b in bs) if bs else '""'
for n in range(200):
 body=''
 for i in range(8):
  bs=bytes(rng.choice([0,1,7,8,8,9,10,13,13,31,32,32,65,66,67,127,255]) for _ in range(rng.randrange(1,75)))
  body+=('?' if rng.randrange(5)==0 else '??')+' '+expr(bs)+'\n'
 case('combination-'+str(n),'function Main()\n'+body+'return nil\n')
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),scope='ordinary Linux headless GTSTD, raw stdout+stderr+rc; no normalization; own sources, Harbour external oracle only',passed=sum(r['exact'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));(out/'binary-shas.json').write_text(json.dumps(hashes,indent=2));(out/'commands.json').write_text(json.dumps(commands,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(r['exact'] for r in rows))
