from common import *
a=setup();rows=[]
cases={'string':'? hb_osDriveSeparator("x")','number':'? hb_osDriveSeparator(4)','nil':'? hb_osDriveSeparator(NIL)','two':'? hb_osDriveSeparator("x",4)','private':'PRIVATE x:=1\n? hb_osDriveSeparator()','macro':'local s:="1+2"\n? &(s),hb_osDriveSeparator()'}
for name,body in cases.items():
 w=a.output/name;w.mkdir();p=w/'p.prg';p.write_text('function Main()\n'+body+'\nreturn nil\n');q=run([a.compiler,p,w/'ours','--target=linux'],w,'build');assert q.returncode==1 and b'hb_osDriveSeparator' in q.stderr and not(w/'ours').exists();rows.append(dict(name=name,build_rc=1,source_sha256=h(p),ok=True))
for target in ['windows','macho','macho-arm64','llvm','threads']:
 w=a.output/target;w.mkdir();p=w/'p.prg';p.write_text('function Main()\n? hb_osDriveSeparator()\nreturn nil\n'+('function Unused()\nreturn hb_threadSelf()\n' if target=='threads' else ''));flags=['--target='+('linux' if target in ['llvm','threads'] else target)]+(['--experimental-llvm'] if target=='llvm' else []);q=run([a.compiler,p,w/'ours.s',*flags],w,'build');assert q.returncode==1 and b'hb_osDriveSeparator requires ordinary Linux' in q.stderr and not(w/'ours.s').exists();rows.append(dict(name=target,build_rc=1,source_sha256=h(p),ok=True))
finish(a,rows,'11named build limits,no rejected binary executed. Only zeroargs ordinary Linux. Oracle ignored argument contracts not admitted,no filesystem or drive support.')
