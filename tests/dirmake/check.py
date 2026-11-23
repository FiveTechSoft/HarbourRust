#!/usr/bin/env python3
"""DIRMAKE: disposable filesystem oracle comparisons, ownership and rejects."""
import argparse,hashlib,json,os,pathlib,subprocess,sys
P=pathlib.Path
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);ap.add_argument('--tree',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--hbct',required=True);a=ap.parse_args()
repo=P(__file__).resolve().parents[2];compiler=str(P(a.compiler).resolve());out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env={k:v for k,v in os.environ.items() if k not in ['HB_CCPATH','HB_CCPREFIX','HB_CCSUFFIX','HBC_MINGW_LIB']};env['LC_ALL']='C.UTF-8';rows=[]
sys.path.insert(0,str(repo/'tests/trycatch-linux'));from memdelta_guard import emit_delta
cases={
'page-lengths':'? DIRMAKE(Replicate("a/",2039)+""),DIRMAKE(Replicate("a/",2039)+"a"),DIRMAKE(Replicate("a/",2040)+""),DIRMAKE(Replicate("a/",2040)+"a"),DIRMAKE(Replicate("a/",2047)+"a"),DIRMAKE(Replicate("a/",2048)+""),DIRMAKE(Replicate("a/",2048)+"a")',
'cache-poison':'local d\nd:=Replicate("y",6)\nd:=NIL\n? DIRMAKE("abcde"),DIRMAKE("abcde")',
'basic':'? DIRMAKE("new"),DIRMAKE("new"),DIRMAKE("missing/leaf"),DIRMAKE(""),DIRMAKE(".")',
'file':'? DIRMAKE("plainfile"),DIRMAKE("plainfile/leaf"),DIRMAKE("space name"),DIRMAKE("parent/child")',
'slashes':'? DIRMAKE("back\\slash"),DIRMAKE("parent\\child"),DIRMAKE("slash/"),DIRMAKE("././dots")',
'nul':'? DIRMAKE("nul"+Chr(0)+"tail"),DIRMAKE("nul"),DIRMAKE(Chr(0)+"ignored")',
'owned':'local s:=Upper("owned")\n? DIRMAKE(s),DIRMAKE(s),s,DIRMAKE(Lower("TEMP"))',
'dyn':'local d\nd:="dyn"\n? DIRMAKE(d),DIRMAKE(d)\nd:=Space(5)+"owned"\n? DIRMAKE(d),d\nd:=NIL\n? DIRMAKE(d)\nd:=1.5\n? DIRMAKE(d)',
'nonstring':'? DIRMAKE(),DIRMAKE(NIL),DIRMAKE(7),DIRMAKE(.t.),DIRMAKE(1.5),DIRMAKE(CToD("2026-01-01"))',
'long':'? DIRMAKE(Replicate("a",255)),DIRMAKE(Replicate("b",256)),DIRMAKE(Replicate("c",4096))',
'symlink':'? DIRMAKE("linkdir"),DIRMAKE("broken"),DIRMAKE("linkdir/new"),DIRMAKE("broken/new"),DIRMAKE("loop/new")',
'permissions':'? DIRMAKE("blocked/child"),DIRMAKE("trail "),DIRMAKE(" lead"),DIRMAKE("café")',
'prefix':'? DIRMAKE(Chr(34)+"quoted"),DIRMAKE("a"+Chr(0)+"b"),DIRMAKE("a")',
'eval-once':'local n:=0\n? DIRMAKE(tick(@n)),n\nreturn nil\nfunction tick(n)\nn++\nreturn "once"',
'eval-bad':'local n:=0\n? DIRMAKE(tick(@n)),n\nreturn nil\nfunction tick(n)\nn++\nreturn 1.5',
'dyn-result':'? DIRMAKE(give())\nreturn nil\nfunction give()\nlocal d\nd:=Space(3)+"result"\nreturn d',
}
def source(body):return 'function main()\n'+body+('\n'if '\nfunction 'in body else '\nreturn nil\n')
def run(cmd,cwd,label):
 r=subprocess.run(list(map(str,cmd)),cwd=cwd,env=env,capture_output=True,timeout=45)
 for ext,data in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(cwd/(label+'.'+ext)).write_bytes(data)
 return r
def fs(w):
 w.mkdir();(w/'plainfile').touch();(w/'parent').mkdir();(w/'blocked').mkdir();(w/'blocked').chmod(0);(w/'linkdir').symlink_to('parent');(w/'broken').symlink_to('absent');(w/'loop').symlink_to('loop')
def entries(w):
 result=[]
 def walk(d):
  for x in sorted(d.iterdir()):
   result.append([str(x.relative_to(w)),x.is_symlink(),oct(x.lstat().st_mode&0o777)])
   if x.is_dir() and not x.is_symlink() and x.name!='blocked':walk(x)
 walk(w);return result
for name,body in cases.items():
 d=out/name;d.mkdir();src=d/'probe.prg';src.write_text(source(body));values={}
 for ver in ['ours']+(['oracle']if a.hbmk2 else[]):
  w=d/ver;fs(w);exe=d/(ver+'.bin');cmd=[compiler,src,exe,'--instrument']if ver=='ours'else[a.hbmk2,src,a.hbct,'-quiet','-gtstd','-o'+str(exe)]
  r=run(cmd,d,ver+'-build');assert not r.returncode,(name,ver,r.stderr,r.stdout)
  r=run([exe],w,'run');values[ver]=(r.returncode,r.stdout,r.stderr,entries(w))
  assert r.returncode==0 and r.stderr==b'',(name,ver,values[ver]);(d/(ver+'-fs.json')).write_text(json.dumps(values[ver][3],indent=2))
 if a.hbmk2:assert values['ours']==values['oracle'],(name,values)
 rows.append(dict(kind='filesystem',name=name,oracle=bool(a.hbmk2),passed=True))
 # Darwin emission only. Native execution is a separate gate.
 for target in ['macho','macho-arm64']:
  r=run([compiler,src,d/target,'--target='+target,'--instrument'],d,target+'-build');assert r.returncode==0,(name,target,r.stderr)
  rows.append(dict(kind='emission-only',name=name,target=target,passed=True))
for name,body in [('array','? DIRMAKE({1})'),('hash','? DIRMAKE({"a"=>1})'),('block','? DIRMAKE({||1})'),('extra','? DIRMAKE("a",1)'),('unknown','? DIRMAKE(missing())'),('malformed','? DIRMAKE(Space())'),('forward','? DIRMAKE(later())\nreturn nil\nfunction later()\nreturn Space()')]:
 d=out/('reject-'+name);d.mkdir();src=d/'probe.prg';src.write_text(source(body));r=run([compiler,src,d/'exe'],d,'build');expected=b'DIRMAKE supports zero or one scalar'if name in ['array','hash','block','extra']else(b'unknown function'if name=='unknown'else(b'`Space` takes one argument'if name=='forward'else b'space'))
 assert r.returncode==1 and expected.lower()in r.stderr.lower(),(name,r.returncode,r.stderr)
 rows.append(dict(kind='rejection',name=name,passed=True))
for target,mode in [('linux','--experimental-llvm'),('linux','--experimental-llvm-no-trace'),('windows','--experimental-llvm')]:
 d=out/('profile-'+target+'-'+str(mode));d.mkdir();src=d/'probe.prg';src.write_text(source('? DIRMAKE(".")'));r=run([compiler,src,d/'exe','--target='+target]+([mode]if mode else[]),d,'build');assert r.returncode==1 and b'DIRMAKE supports ordinary Linux, Darwin and Windows PE only'in r.stderr,(target,mode,r.stderr);rows.append(dict(kind='profile-rejection',target=target,mode=mode,passed=True))
forms={
'literal':('','DIRMAKE(".")',''),
'owned-temp':('','DIRMAKE(Lower("."))',''),
'owned-var':('local s:=Space(2)\n','DIRMAKE(s)',''),
'dyn-owned':('local d\nd:=Space(2)\n','DIRMAKE(d)',''),
'dyn-lit':('local d\nd:="."\n','DIRMAKE(d)',''),
'dyn-concat':('local d\nd:="."\n','DIRMAKE(d+"")',''),
'dyn-result':('','DIRMAKE(give())','function give()\nlocal d\nd:=Space(2)\nreturn d\n'),
'dyn-float':('local d\nd:=1.5\n','DIRMAKE(d)',''),
'dyn-float-result':('','DIRMAKE(give())','function give()\nlocal d\nd:=1.5\nreturn d\n'),
'noarg':('','DIRMAKE()',''),
'return':('','wrap()','function wrap()\nreturn DIRMAKE(Space(2))\n'),
'index':('local a:={".","."}\n','DIRMAKE(a[1])',''),
 'object-identity':('local o:=T():New()\no:s:=Space(2)\n','DIRMAKE(identity(o))','function identity(x)\nif .f.\n? x\nendif\nreturn x\n'),
 'hash-input':('local h:={"k"=>7}\n','DIRMAKE(h["k"])',''),
 'dyn-array-index':('local a:={NIL,"."}\n','DIRMAKE(a[2])',''),
 'static-input':('s:=Space(2)\n','DIRMAKE(s)',''),
 'iif-owned':('','DIRMAKE(IIF(.t.,Space(2),Space(3)))',''),
 'data-input':('local o:=T():New()\no:s:=Space(2)\n','DIRMAKE(o:s)',''),
'catch-producer':('local e\n','DIRMAKE(boom())','function boom()\nbreak("caught")\nreturn Space(2)\n'),
}
for name,(init,expr,tail) in forms.items():
 for n in [1,500,1000]:
  for control in [False,True]:
   d=out/('mem-'+name+'-'+str(n)+'-'+str(control));d.mkdir();src=d/'probe.prg'
   statement='x:=0'if control else 'x:='+expr
   if name=='catch-producer'and not control:statement='try\n'+statement+'\ncatch e\ne:=NIL\nend'
   src.write_text(('#include "hbclass.ch"\nCREATE CLASS T\nDATA s\nMETHOD New() CONSTRUCTOR\nENDCLASS\nMETHOD New() CLASS T\nreturn Self\n'if name in ('data-input','object-identity') else('STATIC s:=""\n'if name=='static-input'else''))+'function main()\nlocal i,x,hits:=0\n'+init+'for i:=1 to '+str(n)+'\n'+statement+'\nhits++\nnext\n? hits\nreturn nil\n'+tail)
   r=emit_delta(compiler,env,src,d,b'\n'+f'{n:10d}'.encode());assert r['state_ok']and r['delta']==(2 if name in ('data-input','object-identity') else 0),(name,n,control,r);rows.append(dict(kind='memory',name=name,n=n,control=control,result=r,passed=True))

# Poisoned-allocation gate: fill the helper clone with 'y' (len+1 bytes)
# right after allocation. Only the explicit terminator write keeps names exact.
for pname,expr,want in [('one','"x"',['x']),('three','"abc"',['abc'])]+[('len%d'%L,'Replicate("a/",%d)+%s'%(L//2,'"a"' if L%2 else '""'),[]) for L in [4079,4080,4081,4095]]:
 d=out/('poison-'+pname);d.mkdir();src=d/'probe.prg';src.write_text('function main()\n? DIRMAKE('+expr+')\nreturn nil\n');asm=d/'probe.s'
 r=run([compiler,src,asm,'--target=linux'],d,'emit');assert r.returncode==0,r.stderr
 t=asm.read_text();needle='    call hbc_stralloc\n    mov %rax, -24(%rbp)\n';assert t.count(needle)==1
 t=t.replace(needle,needle+'    mov %rax, %rdi\n    mov -16(%rbp), %rcx\n    inc %rcx\n    push %rax\n    mov $121, %eax\n    rep stosb\n    pop %rax\n');asm.write_text(t)
 assert run(['as','--64','-o',d/'probe.o',asm],d,'as').returncode==0 and run(['ld','-o',d/'probe',d/'probe.o'],d,'ld').returncode==0
 w=d/'work';w.mkdir();r=run([d/'probe'],w,'run');assert r.returncode==0 and r.stderr==b'',(pname,r)
 assert sorted(x.name for x in w.iterdir() if not x.name.startswith('run.'))==want,(pname,sorted(x.name for x in w.iterdir()))
 rows.append(dict(kind='poison',name=pname,passed=True))
report=dict(compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),compiler_tree=a.tree,compiler_git_tree=subprocess.check_output(['git','rev-parse',a.tree+'^{tree}'],cwd=repo,text=True).strip(),oracle_hbmk2=a.hbmk2,oracle_hbct_sha256=hashlib.sha256(P(a.hbct).read_bytes()).hexdigest()if a.hbct else None,records=rows,count=len(rows));(out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print('PASS',len(rows),'DIRMAKE checks')
