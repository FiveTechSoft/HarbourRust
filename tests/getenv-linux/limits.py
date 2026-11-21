from common import *
a=setup();rows=[]
cases={
'noargs':'function Main()\n? GetEnv()\nreturn nil\n',
'extra':'function Main()\n? GetEnv("HR_GETENV_A",7)\nreturn nil\n',
'nil':'function Main()\n? GetEnv(NIL)\nreturn nil\n',
'int':'function Main()\n? GetEnv(7)\nreturn nil\n',
'logical':'function Main()\n? GetEnv(.t.)\nreturn nil\n',
'dyn':'function Main()\nlocal k\nk:="HR_GETENV_A"\n? GetEnv(k)\nreturn nil\n',
'private':'function Main()\nPRIVATE k:="HR_GETENV_A"\n? GetEnv("HR_GETENV_A")\nreturn nil\n',
'macro':'function Main()\nlocal k:="1+2"\n? &(k),GetEnv("HR_GETENV_A")\nreturn nil\n',
'extern':'EXTERNAL FixtureNeverCalled\nfunction Main()\n? GetEnv("HR_GETENV_A")\nreturn nil\n',
}
for name,s in cases.items():
 w=a.output/name;w.mkdir();p=w/'p.prg';p.write_text(s);b=run([a.compiler,p,w/'ours','--target=linux'],w,'build');assert b.returncode==1 and b'GetEnv' in b.stderr and not(w/'ours').exists(),(name,b);rows.append(dict(name=name,build_rc=b.returncode,source_sha256=h(p),ok=True));print(name,'rejected',flush=True)
for target in ['windows','macho','macho-arm64','llvm','threads']:
 w=a.output/target;w.mkdir();p=w/'p.prg';p.write_text('function Main()\n? GetEnv("HR_GETENV_A")\nreturn nil\n'+('function Unused()\nreturn hb_threadSelf()\n' if target=='threads' else ''));flags=['--target='+('linux' if target in ['llvm','threads'] else target)]+(['--experimental-llvm'] if target=='llvm' else []);b=run([a.compiler,p,w/'ours.s',*flags],w,'build');assert b.returncode==1 and b'GetEnv requires ordinary Linux' in b.stderr and not(w/'ours.s').exists(),(target,b);rows.append(dict(name=target,build_rc=b.returncode,source_sha256=h(p),ok=True));print(target,'rejected',flush=True)
finish(a,rows,'14named build limits,no rejected binary executed. Narrow1typedstringarg;noargs/nonstring/multiarg differ from broader oracle admission,deliberately rejected. Ordinary Linux only,no threads/macro/memvars/Cextensions.')
